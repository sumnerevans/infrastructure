{pkgs, services, ...}: {
  # Create a user for nginx to run as.
  users.extraUsers.nginx = {
    description = "Nginx";
    isSystemUser = true;
    group = "nginx";
  };

  services.nginx = {
    enable = true;
    enableReload = true;
    group = "nginx";
    user = "nginx";
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedTlsSettings = true;

    # Enable a status page and expose it.
    virtualHosts."status.sumnerevans.com" = {
      forceSSL= true;
      enableACME = true;
      locations."/".extraConfig = "stub_status on;access_log off;";
    };
  };
}
