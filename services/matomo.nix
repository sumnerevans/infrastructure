{ config, pkgs, ... }: let
  dbName = "matomo";
in {
  services.matomo = {
    enable = true;
    nginx.serverName = "matomo.sumnerevans.com";
  };

  services.mysql = {
    ensureDatabases = [ dbName ];
    ensureUsers = [
      {
        name = dbName;
        ensurePermissions = {
          "${dbName}.*" = "ALL PRIVILEGES";
          "${config.services.mysqlBackup.user}.*" = "ALL PRIVILEGES";
        };
      }
    ];
  };

  services.mysqlBackup.databases = [ dbName ];
}
