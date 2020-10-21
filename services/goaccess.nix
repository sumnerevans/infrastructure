{ config, lib, pkgs, ... }: with lib; let
  cfg = config.services.metrics;
  hostnameDomain = "${config.networking.hostName}.${config.networking.domain}";
  goaccessDir = "/var/goaccess/metrics";
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

  hostListItem = { hostname, ... }: ''echo "<li><a href=\"/${hostname}\">${hostname}</a></li>" >> ${goaccessDir}/index.html'';
  makeIndexScriptPart = websites: ''
    echo "<html>"                                > ${goaccessDir}/index.html
    echo "<head><title>Metrics</title></head>"  >> ${goaccessDir}/index.html
    echo "<body>"                               >> ${goaccessDir}/index.html
    echo "<h1>Metrics</h1>"                     >> ${goaccessDir}/index.html
    echo "<ul>"                                 >> ${goaccessDir}/index.html

    ${concatMapStringsSep "\n" hostListItem websites}

    echo "</ul>"                                >> ${goaccessDir}/index.html
    echo "</body>"                              >> ${goaccessDir}/index.html
  '';

  goaccessScript = websites: pkgs.writeShellScript "goaccess" ''
    set -xe
    ${pkgs.coreutils}/bin/mkdir -p ${goaccessDir}
    cd /var/log/nginx

    ${concatMapStringsSep "\n" goaccessWebsiteMetricsScriptPart websites}

    ${makeIndexScriptPart websites}
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
    services.nginx.virtualHosts."${hostnameDomain}" = {
      locations."/metrics/" = {
        root = "${goaccessDir}";
        index = "index.html";
      };
    };
  };
}
