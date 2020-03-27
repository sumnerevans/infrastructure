{ config, pkgs, ... }: {
  services.mysql = {
    enable = true;
    package = pkgs.mysql;
  };

  # Run backup every 3 hours.
  services.mysqlBackup = {
    enable = true;
    calendar = "0/3:0";  # systemd-analyze calendar "0/3:0"
  };

  # Add a backup service.
  services.backup.mysql = {
    root = config.services.mysqlBackup.location;
  };
}
