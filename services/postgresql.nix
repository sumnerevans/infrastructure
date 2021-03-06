{ config, pkgs, ... }: {
  services.postgresql.enable = true;

  # Run backup every 3 hours.
  services.postgresqlBackup = {
    enable = true;
    backupAll = true;
    startAt = "0/3:0"; # systemd-analyze calendar "0/3:0"
  };

  # Add a backup service.
  services.backup.backups.postgresql = {
    path = config.services.postgresqlBackup.location;
  };
}
