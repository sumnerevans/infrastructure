{ config, lib, pkgs, ... }: let
  serverName = "dav.${config.networking.domain}";
in
{
  services.xandikos = {
    enable = true;
    extraOptions = [
      "--current-user-principal /sumner/"
    ];

    nginx = {
      enable = true;
      hostName = serverName;
    };
  };

  # Set up nginx to forward requests properly.
  services.nginx.virtualHosts = {
    "${serverName}" = {
      enableACME = true;
      forceSSL = true;
      basicAuth = {
        sumner = lib.removeSuffix "\n" (builtins.readFile ../secrets/xandikos);
      };
    };
  };

  # Add a backup service.
  services.backup.backups.xandikos = {
    path = "/var/lib/private/xandikos";
  };
}
