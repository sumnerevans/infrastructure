{ config, lib, pkgs, ... }: let
  certs = config.security.acme.certs;
  serverName = "syncthing.${config.networking.domain}";
in
{
  services.syncthing = {
    enable = true;
    openDefaultPorts = true;
    guiAddress = "0.0.0.0:8384";
  };

  # Use nginx to do the ACME verification for mumble.
  services.nginx.virtualHosts."${serverName}" = {
    forceSSL = true;
    enableACME = true;
    locations."/".proxyPass = "http://localhost:8384";
  };

  # Add a backup service.
  services.backup.backups.syncthing = {
    path = "/var/lib/syncthing";
  };
}
