{ config, pkgs, ... }: let
  certs = config.security.acme.certs;
  serverName = "syncthing.${config.networking.domain}";
in
{
  services.syncthing = {
    enable = true;
    openDefaultPorts = true;
  };

  # Use nginx to do the ACME verification for mumble.
  services.nginx.virtualHosts."${serverName}" = {
    forceSSL = true;
    enableACME = true;
    locations."/".proxyPass = "http://${config.services.syncthing.guiAddress}";

    basicAuth = {
      sumner = lib.removeSuffix "\n"
        (builtins.readFile ../secrets/syncthing-admin-password);
    };
  };
}
