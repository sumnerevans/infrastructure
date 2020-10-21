{ config, lib, pkgs, ... }: with lib; let
  cfg = config.services.metrics;
  metricsDomain = "metrics.${config.networking.domain}";
  goaccessDir = "/var/www/${metricsDomain}";
  excludeIPs = [
    "184.96.89.215"
  ];

  goaccessWebsiteMetricsScriptPart = { hostname, excludeTerms ? [] }: ''
    mkdir -p ${goaccessDir}/${hostname}

    # combine the gzipped and non-gziped logs together
    ${pkgs.coreutils}/bin/cat \
      <(${pkgs.findutils}/bin/find . -regextype awk -regex "./${hostname}.access.log.[0-9]+.gz" &&
          ${pkgs.gzip}/bin/zcat -q ${hostname}.access.log.*.gz) \
      <(${pkgs.findutils}/bin/find . -regextype awk -regex "./${hostname}.access.log(\.[0-9]+)?" |
          ${pkgs.findutils}/bin/xargs ${pkgs.coreutils}/bin/cat) |

    # Filter out any logs that match the excludeTerms.
    ${pkgs.gnugrep}/bin/grep -v \
      ${concatMapStringsSep " " (e: "-e \"${e}\"") excludeTerms} |

    # Pipe the logs to goaccess
    ${pkgs.goaccess}/bin/goaccess - \
      -o ${goaccessDir}/${hostname}/index.html \
      --ignore-crawlers \
      ${concatMapStringsSep " " (e: "-e \"${e}\"") excludeIPs} \
      --real-os \
      --log-format=COMBINED
  '';

  goaccessScript = websites: pkgs.writeShellScript "goaccess" ''
    set -xe
    ${pkgs.coreutils}/bin/mkdir -p ${goaccessDir}
    cd /var/log/nginx

    ${(concatStringsSep "\n\n" (map goaccessWebsiteMetricsScriptPart websites))}
  '';
in
{
  options = let
    websiteOpts = { ... }: {
      options = {
        hostname = mkOption {
          type = types.str;
          description = "Website name";
        };
        excludeTerms = mkOption {
          type = types.listOf types.str;
          description = "Exclude patterns for metrics.";
          default = [];
        };
      };
    };
  in
    {
      services.metrics = {
        websites = mkOption {
          type = with types; listOf (submodule websiteOpts);
          description = ''
            A list of websites to create metrics for.
          '';
          default = [];
        };
      };
    };

  config = mkIf (cfg != {}) {
    systemd.services.goaccess = {
      description = "Goaccess Web log report.";
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      serviceConfig = {
        User = "root";
        ExecStart = (goaccessScript cfg.websites);
        Restart = "always";
        RestartSec = 600;
      };
    };

    # Set up nginx to forward requests properly.
    services.nginx.virtualHosts = {
      "${metricsDomain}" = {
        enableACME = true;
        forceSSL = true;

        locations."/".root = "${goaccessDir}";
      };
    };
  };
}
