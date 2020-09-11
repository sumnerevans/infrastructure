{ pkgs, ... }: {
  services.nginx = {
    enable = true;
    enableReload = true;
    clientMaxBodySize = "250m";
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    virtualHosts = {
      # Enable a status page and expose it.
      "status.sumnerevans.com" = {
        forceSSL = true;
        enableACME = true;
        locations."/".extraConfig = "stub_status on;access_log off;";
      };

      "the-evans.family" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          root = "/var/www/the-evans.family";
        };
      };

      "qs.sumnerevans.com" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          root = "/var/www/qs.sumnerevans.com";
        };
      };

      "sumnerevans.com" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          root = "/var/www/sumnerevans.com";
        };
      };
    };
  };

  # Open up the ports
  networking.firewall.allowedTCPPorts = [ 80 443 ];
}
