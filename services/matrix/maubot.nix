{ config, lib, pkgs, ... }:
let
  matrixDomain = "matrix.${config.networking.domain}";

  maubot = pkgs.callPackage ../../pkgs/maubot.nix { };
  python = pkgs.python38.withPackages (
    ps: with ps; [ maubot ]
  );

  maubotDir = "/var/lib/maubot";
  cryptoDir = "${maubotDir}/crypto";
  pluginDir = "${maubotDir}/plugins";
  logDir = "${maubotDir}/logs";
  trashDir = "${maubotDir}/trash";
  alembicDir = "${maubotDir}/alembic";

  # https://raw.githubusercontent.com/maubot/maubot/master/example-config.yaml
  maubotConfig = {
    database = "sqlite://${maubotDir}/maubot.db";
    crypto_database.pickle_dir = cryptoDir;
    plugin_directories = {
      upload = pluginDir;
      load = [ pluginDir ];
      trash = trashDir;
      db = pluginDir;
    };
    server = {
      hostname = "0.0.0.0";
      port = 29316;
      public_url = "https://${matrixDomain}";
      base_path = "/_matrix/maubot/v1";
      ui_base_path = "/_matrix/maubot";
      plugin_base_path = "/_matrix/maubot/plugin/";
      override_resource_path = false;
      appservice_base_path = "/_matrix/app/v1";
      unshared_secret = "generate";
    };
    registration_secrets = {
      ${matrixDomain} = {
        url = "https://${matrixDomain}";
        secret = lib.removeSuffix "\n"
          (builtins.readFile ../../secrets/matrix-registration-shared-secret);
      };
    };
    logging = {
      version = 1;
      handlers.file = {
        class = "logging.handlers.RotatingFileHandler";
        formatter = "normal";
        filename = "${logDir}/mautrix.log";
        maxBytes = 10485760;
        backupCount = 10;
      };
      loggers = {
        maubot.level = "DEBUG";
        mautrix.level = "DEBUG";
        aiohttp.level = "DEBUG";
      };
      root = {
        level = "DEBUG";
        handlers = [ "file" "console" ];
      };
    };
  };

  alembicConfig = {
    alembic.scriptLocation = alembicDir;
    loggers.keys = [ "root" "sqlalchemy" "alembic" ];
    handlers.keys = [ "console" ];
    formatters.keys = [ "generic" ];
    logger_root = { level = "WARN"; handlers = "console"; };
    logger_sqlalchemy = { level = "WARN"; qualname = "sqlalchemy.engine"; };
    logger_alembic = { level = "INFO"; qualname = "alembic"; };
    handler_console = {
      class = "StreamHandler";
      args = "(sys.stderr,)";
      level = "NOTSET";
      formatter = "generic";
    };
    formatter_generic = {
      format = "%(levelname)-5.5s [%(name)s] %(message)s";
      datefmt = "%H:%M:%S";
    };
  };

  configFile = pkgs.writeText "config.yaml" (lib.generators.toYAML { } maubotConfig);
  alembicConfigFile = pkgs.writeText "alembic.ini" (lib.generators.toINI { } alembicConfig);
in
{
  systemd.services.maubot = {
    description = "Maubot bots for Matrix";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target " ];

    serviceConfig = {
      ExecStartPre = [
        "${pkgs.coreutils}/bin/mkdir -p ${cryptoDir} ${pluginDir} ${logDir} ${trashDir} ${alembicDir}"
        "${python}/bin/alembic -c ${alembicConfigFile} -x config=${configFile} upgrade head"
      ];
      ExecStart = "${python}/bin/python -m maubot -c ${configFile}";
    };
  };

  services.nginx.virtualHosts = {
    # Reverse proxy for Matrix client-server and server-server communication
    ${matrixDomain} = {
      locations."/_matrix/maubot/v1/logs" = {
        proxyPass = "http://[::1]:29316"; # without a trailing /
        proxyWebsockets = true;
        extraConfig = ''
          access_log /var/log/nginx/matrix.access.log;
        '';
      };
      locations."/_matrix/maubot" = {
        proxyPass = "http://[::1]:29316"; # without a trailing /
        extraConfig = ''
          access_log /var/log/nginx/matrix.access.log;
        '';
      };
    };
  };
}

