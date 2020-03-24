{ pkgs, ... }: {
  services.bitwarden_rs = {
    enable = true;
    backupDir = "/backups/bitwarden_rs";
    config = {
      domain = "https://bitwarden.sumnerevans.com";
      signupsAllowed = false;
      rocketAddress = "0.0.0.0";
      rocketPort = 8222;
      rocketLog = "critical";
    };
  };

  # Enable a status page and expose it.
  services.nginx.virtualHosts."bitwarden.sumnerevans.com" = {
    forceSSL= true;
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
}
