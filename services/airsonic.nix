{ pkgs, config, ... }:
let
  serverName = "airsonic.${config.networking.domain}";
in
{
  # Create the airsonic service.
  services.airsonic = {
    enable = true;
    maxMemory = 1024;
    virtualHost = serverName;
  };

  services.nginx.virtualHosts = {
    ${serverName} = {
      forceSSL = true;
      enableACME = true;
    };
  };

  # Add a backup service.
  services.backup.backups.airsonic = {
    path = config.users.users.airsonic.home;
  };
}
