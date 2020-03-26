{ pkgs, ... }: {
  services.nginx = {
    enable = true;
    enableReload = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    virtualHosts = {
      # Enable a status page and expose it.
      "status.sumnerevans.com" = {
        forceSSL= true;
        enableACME = true;
        locations."/".extraConfig = "stub_status on;access_log off;";
      };
    };
  };

  # Open up the ports
  networking.firewall.allowedTCPPorts = [ 80 443 ];
}
