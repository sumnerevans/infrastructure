{pkgs, services, ...}: {
  services.nginx = {
    enable = true;
    enableReload = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    # Enable a status page and expose it.
    virtualHosts."status.sumnerevans.com" = {
      forceSSL= true;
      enableACME = true;
      locations."/".extraConfig = "stub_status on;access_log off;";
    };
  };
}
