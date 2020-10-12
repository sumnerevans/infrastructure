{ pkgs, ... }: let
  serverName = "airsonic.sumnerevans.com";
in
{
  # Create the airsonic service.
  services.airsonic = {
    enable = true;
    maxMemory = 1024;
    virtualHost = "${serverName}";
  };

  # Get a cert for it and make it only available over HTTPS.
  services.nginx.virtualHosts = {
    "${serverName}" = {
      forceSSL = true;
      enableACME = true;
    };
  };

  # Add a backup service.
  services.backup.backups.airsonic = {
    path = "/var/lib/airsonic";
  };
}
