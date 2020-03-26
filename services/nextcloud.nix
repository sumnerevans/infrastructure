# See https://nixos.org/nixos/manual/index.html#module-services-nextcloud
{ pkgs, ... }: {
  services.nextcloud = {
    enable = true;
    hostName = "nextcloud.sumnerevans.com";
    https = true;
    nginx.enable = true;
    config = {
      dbtype = "pgsql";
      dbuser = "nextcloud";
      dbhost = "/run/postgresql"; # nextcloud will add /.s.PGSQL.5432 by itself
      dbname = "nextcloud";
      adminpassFile = "/etc/nixos/secrets/nextcloud-sumner";
      adminuser = "sumner";
      overwriteProtocol = "https";
    };
    autoUpdateApps.enable = true;
  };

  # Make the Nextcloud database.
  services.postgresql = {
    ensureDatabases = [ "nextcloud" ];
    ensureUsers = [
      {
        name = "nextcloud";
        ensurePermissions."DATABASE nextcloud" = "ALL PRIVILEGES";
      }
    ];
  };

  # ensure that postgres is running *before* running the setup
  systemd.services."nextcloud-setup" = {
    requires = ["postgresql.service"];
    after = ["postgresql.service"];
  };
}
