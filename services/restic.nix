# This is similar to
# https://github.com/NixOS/nixpkgs/blob/release-19.09/nixos/modules/services/backup/restic.nix
# But this module is a bit more specific to my use case. This is what it does:
# 1. It exposes a very simple interface to the other modules where they can
#    just specify a directory that needs to be backed up.
# 2. Each folder that's backed up by this service is backed up to B2.
# 3. After each backup, I check it's validity.
# 4. I forget old snapshots and prune every day.
# 5. It creates a new service for each of the configured backup paths that is
#    run at startup. If a special `.restic-backup-restored` file does not exist
#    in that directory, it will restore all data from B2 to that directory.
#    This service can be set as a prerequisite for starting up other services
#    that depend on that data.

{ config, lib, pkgs, ... }: with lib; let
  cfg = config.services.backup;
  bucket = "test-scarif-backup";
  repoPath = config.networking.hostName;
  frequency = "0/1:0"; # Run backup every hour
  pruneFrequency = "00:15"; # Run prune every day a few minutes after midnight to not interfere with hourly backup
  resticPasswordFile = "/etc/nixos/secrets/restic-password";
  resticEnvironmentFile = "/etc/nixos/secrets/restic-environment-variables";
  resticRepository = "b2:${bucket}:${repoPath}";
  # TODO be able to restore from a different repo path

  resticCmd = "${pkgs.restic}/bin/restic";

  resticEnvironment = {
    RESTIC_PASSWORD_FILE = resticPasswordFile;
    RESTIC_REPOSITORY = resticRepository;
    RESTIC_CACHE_DIR = "/var/cache";
  };

  # Scripts
  # ===========================================================================
  resticBackupScript = paths: exclude: pkgs.writeScriptBin "restic-backup" ''
    #!${pkgs.stdenv.shell}
    set -xe

    ${pkgs.curl}/bin/curl -fsS --retry 10 https://hc-ping.com/a42858af-a9d7-4385-b02d-2679f92873ed/start

    # Perfrom the backup
    ${resticCmd} backup \
      --verbose \
      ${concatStringsSep " " paths} \
      ${concatMapStringsSep " " (e: "-e \"${e}\"") exclude}

    # Check the validity of the repository.
    ${resticCmd} check

    # Ping healthcheck.io
    ${pkgs.curl}/bin/curl -fsS --retry 10 https://hc-ping.com/a42858af-a9d7-4385-b02d-2679f92873ed
  '';

  resticPruneScript = pkgs.writeScriptBin "restic-prune" ''
    #!${pkgs.stdenv.shell}
    set -xe

    ${pkgs.curl}/bin/curl -fsS --retry 10 https://hc-ping.com/14ed7839-784f-4dee-adf2-f9e03c2b611e/start

    # Remove old backup sets. Keep hourly backups from the past week, daily
    # backups for the past 90 days, weekly backups for the last half year,
    # monthly backups for the last two years, and yearly backups for the last
    # two decades.
    ${resticCmd} forget \
      --prune \
      --group-by host \
      --keep-hourly 168 \
      --keep-daily 90 \
      --keep-weekly 26 \
      --keep-monthly 24 \
      --keep-yearly 20

    # Ping healthcheck.io
    ${pkgs.curl}/bin/curl -fsS --retry 10 https://hc-ping.com/14ed7839-784f-4dee-adf2-f9e03c2b611e
  '';

  resticAutoRestoreScript = path: pkgs.writeScriptBin "restic-restore" ''
    #!${pkgs.stdenv.shell}
    set -xe

    # If the backup has already been restored, exit.
    [[ -f ${path}/.restic-backup-restored ]] && exit 0

    # Perfrom the restoration.
    ${resticCmd} restore latest --verify --target / -i ${path}

    # Create the .restic-backup-restored file.
    touch ${path}/.restic-backup-restored
  '';

  # Services
  # ===========================================================================
  resticBackupService = backups: exclude: let
    paths = mapAttrsToList (n: { path, ... }: path) backups;
    script = resticBackupScript paths (exclude ++ [ ".restic-backup-restored" ]);
  in
    {
      name = "restic-backup";
      value = {
        description = "Backup ${concatStringsSep ", " paths} to ${resticRepository}";
        environment = resticEnvironment;
        startAt = frequency;
        serviceConfig = {
          ExecStart = "${script}/bin/restic-backup";
          EnvironmentFile = resticEnvironmentFile;
          PrivateTmp = true;
          ProtectSystem = true;
          ProtectHome = "read-only";
        };
        # Initialize the repository if it doesn't exist already.
        preStart = ''
          ${resticCmd} snapshots || ${resticCmd} init
        '';
      };
    };

  resticPruneService = {
    name = "restic-prune";
    value = {
      description = "Prune ${resticRepository}";
      environment = resticEnvironment;
      startAt = pruneFrequency;
      serviceConfig = {
        ExecStart = "${resticPruneScript}/bin/restic-prune";
        EnvironmentFile = resticEnvironmentFile;
        PrivateTmp = true;
        ProtectSystem = true;
        ProtectHome = "read-only";
      };
      # Initialize the repository if it doesn't exist already.
      preStart = ''
        ${resticCmd} snapshots || ${resticCmd} init
      '';
    };
  };

  resticAutoRestoreService = name: { path, serviceName, ... }: let
    script = resticAutoRestoreScript path;
  in
    {
      name = serviceName;
      value = {
        description = "Auto-restore ${path} on system startup.";
        environment = resticEnvironment;
        serviceConfig = {
          ExecStart = "${script}/bin/restic-restore";
          EnvironmentFile = resticEnvironmentFile;
        };

        # Run after the network comes up.
        # wantedBy = [ "multi-user.target" ];
        # after = [ "network-online.target" ];
        # wants = [ "network-online.target" ];
      };
    };
in
{
  options = let
    backupDirOpts = { name, ... }: {
      options = {
        path = mkOption {
          type = types.str;
          description = "The path to backup using restic.";
        };
        autoRestore = mkOption {
          type = types.bool;
          default = true;
          description = ''
            Whether an auto-restore service should be added for this path. If
            <literal>true</literal>, a service with the name specified by the
            <option>serviceName</option> will be created.
          '';
        };
        serviceName = mkOption {
          type = types.str;
          default = "restic-auto-restore-${name}";
          description = "The name of the auto-restore service to create.";
        };
      };
    };
  in
    {
      services.backup = {
        backups = mkOption {
          default = {};
          type = with types; attrsOf (submodule backupDirOpts);
          description = "List of backup configurations.";
        };

        exclude = mkOption {
          type = types.listOf types.str;
          default = [];
          description = ''
            List of patterns to exclude. `.restic-backup-restored` files are
            already ignored.
          '';
          example = [ ".git/*" ];
        };
      };
    };

  config = mkIf (cfg != {}) {
    systemd.services = let
      resticServices = [
        # The main backup service.
        (resticBackupService cfg.backups cfg.exclude)

        # The main prune service.
        resticPruneService
      ] ++ # The auto-restore services.
      (
        mapAttrsToList resticAutoRestoreService
          (
            filterAttrs
              (n: { autoRestore, ... }: autoRestore)
              cfg.backups
          )
      );
    in
      listToAttrs resticServices;
  };
}
