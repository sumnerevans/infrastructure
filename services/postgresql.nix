{ config, pkgs, ... }: {
  services.postgresql.enable = true;

  services.postgresqlBackup = {
    enable = true;
    backupAll = true;
    startAt = "*-*-* 11:00:00"; # 11:00 UTC = 04:00 or 05:00 (MST/MDT)
  };
}
