{pkgs, services, ...}: {
  # Create a user for nginx to run as.
  users.extraUsers.nginx = {
    description = "Nginx";
    isSystemUser = true;
    group = "nginx";
  };

  services.nginx.enable = true;
  services.nginx.enableReload = true;
  services.nginx.group = "nginx";
  services.nginx.user = "nginx";
  services.nginx.recommendedGzipSettings = true;
  services.nginx.recommendedOptimisation = true;
  services.nginx.recommendedTlsSettings = true;
  services.nginx.statusPage = true;
}
