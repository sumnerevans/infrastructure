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
    statusPage = true;
  };
}
