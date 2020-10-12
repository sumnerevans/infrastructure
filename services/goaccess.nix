{ config, lib, pkgs, ... }: let
  metricsDomain = "metrics.${config.networking.domain}";
  goaccessDir = "/var/www/${metricsDomain}";
  goaccessScript = pkgs.writeShellScript "goaccess" ''
    set -xe
    ${pkgs.coreutils}/bin/mkdir -p ${goaccessDir}
    cd /var/log/nginx
    ${pkgs.gzip}/bin/zcat -q access.log.*.gz | \
      ${pkgs.goaccess}/bin/goaccess $(find . -regextype awk -regex ".*/access.log(\.[0-9]+)?" | xargs) - \
        -o ${goaccessDir}/index.html \
        --ignore-crawlers \
        --log-format=COMBINED
  '';
in
{
  systemd.services.goaccess = {
    description = "Goaccess Web log report.";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    serviceConfig = {
      User = "root";
      ExecStart = "${goaccessScript}";
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
}
