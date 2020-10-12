{ config, pkgs, ... }: let
  serverName = "bitwarden.sumnerevans.com";
in
{
  services.bitwarden_rs = {
    enable = true;
    config = {
      domain = "https://${serverName}";
      rocketAddress = "0.0.0.0";
      rocketLog = "critical";
      rocketPort = 8222;
      signupsAllowed = false;
      websocketAddress = "0.0.0.0";
      websocketEnabled = true;
      websocketPort = 3012;
    };
  };

  # Reverse proxy Bitwarden.
  services.nginx.virtualHosts."${serverName}" = {
    forceSSL = true;
    enableACME = true;
    locations = {
      "/" = {
        proxyPass = "http://127.0.0.1:8222";
      };

      "/notifications/hub" = {
        proxyPass = "http://127.0.0.1:3012";
      };

      "/notifications/hub/negotiate" = {
        proxyPass = "http://127.0.0.1:8222";
      };
    };
  };

  # Add a backup service.
  services.backup.backups.bitwarden = {
    path = "/var/lib/bitwarden_rs";
  };
}
