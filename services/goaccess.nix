{ config, lib, options, pkgs, ... }: with lib; let
  cfg = config.services.metrics;
  hostnameDomain = "${config.networking.hostName}.${config.networking.domain}";
  goaccessDir = "/var/www/goaccess";
  excludeIPs = [
    "184.96.89.215"
  ];

  goaccessCmd = infile: outfile: ''
    ${pkgs.goaccess}/bin/goaccess ${infile} \
      -o ${outfile} \
      --ignore-crawlers \
      ${concatMapStringsSep " " (e: "-e \"${e}\"") excludeIPs} \
      --real-os \
      --log-format=COMBINED
  '';

  goaccessWebsiteMetricsForDayScriptPart = infile: hostname: n: ''
    # Output log for day $DATE - ${toString n}
    logdatefmt=$(${pkgs.coreutils}/bin/date +%d/%b/%Y -d "$DATE - ${toString n} day")
    outdatefmt=$(${pkgs.coreutils}/bin/date +%Y-%m-%d -d "$DATE - ${toString n} day")
    ${pkgs.coreutils}/bin/cat ${infile} |
      ${pkgs.gnugrep}/bin/grep "\[$logdatefmt" |
      ${goaccessCmd "-" "${goaccessDir}/${hostname}/days/$outdatefmt.html"}
  '';

  pipeIf = condition: cmd: if condition then "| ${cmd}" else "";

  goaccessWebsiteMetricsScriptPart = { hostname, excludeTerms ? [], ... }: ''
    mkdir -p ${goaccessDir}/${hostname}/days

    logtmp=$(${pkgs.coreutils}/bin/mktemp)
    trap "rm -rfv $logtmp" EXIT

    # combine the gzipped and non-gziped logs together
    ${pkgs.coreutils}/bin/cat \
      <(${pkgs.findutils}/bin/find . -regextype awk -regex "./${hostname}.access.log.[0-9]+.gz" &&
          ${pkgs.findutils}/bin/xargs ${pkgs.gzip}/bin/zcat -fq) \
      <(${pkgs.findutils}/bin/find . -regextype awk -regex "./${hostname}.access.log(\.[0-9]+)?" |
          ${pkgs.findutils}/bin/xargs ${pkgs.coreutils}/bin/cat) \
          ${pipeIf (excludeTerms != [])
            "${pkgs.gnugrep}/bin/grep -v ${concatMapStringsSep " " (e: "-e \"${e}\"") excludeTerms}"} \
      > $logtmp

    # Run Goaccess for all of the logs that we have.
    ${goaccessCmd "$logtmp" "${goaccessDir}/${hostname}/index.html"}

    # Run Goaccess for the past week days as well.
    ${concatMapStringsSep "\n" (goaccessWebsiteMetricsForDayScriptPart "$logtmp" hostname) (lib.range 0 7)}

    # Clean-up days older than a month.
    # TODO
  '';

  hostListItem = { hostname, ... }: ''
    echo "
        <li>
          <a href=\"/metrics/${hostname}\">${hostname}</a>
          (<a href=\"/metrics/${hostname}/days\">Per Day</a>)
        </li>" >> ${goaccessDir}/index.html
  '';

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
        extraLocations = mkOption {
          type = types.attrsOf (types.submodule options.services.nginx.virtualHosts.locations.type);
          description = "Exclude patterns for metrics.";
          default = [];
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
        alias = "${goaccessDir}/";
        extraConfig = ''
          autoindex on;
        '';
      };
    };
  };
}
