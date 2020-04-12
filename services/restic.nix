# This is similar to
# https://github.com/NixOS/nixpkgs/blob/release-19.09/nixos/modules/services/backup/restic.nix
# But this module is a bit more specific to my use case. This is what it does:
# 1. It exposes a very simple interface to the other modules where they can
#    just specify a directory that needs to be backed up.
# 2. Each folder that's backed up by this service is backed up to B2.
# 3. After each backup, I forget old snapshots and prune.
# 4. After each backup, I print the statistics of the repository and check it's
#    validity.
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
  resticPasswordFile = "/etc/nixos/secrets/restic-password";
  resticEnvironmentFile = "/etc/nixos/secrets/restic-environment-variables";
  resticRepository = "b2:${bucket}:${repoPath}";

  resticCmd = "${pkgs.restic}/bin/restic";

  resticEnvironment = {
    RESTIC_PASSWORD_FILE = resticPasswordFile;
    RESTIC_REPOSITORY = resticRepository;
  };

  # Scripts
  # ===========================================================================
  resticBackupScript = paths: exclude: pkgs.writeScriptBin "restic-backup" ''
    #!${pkgs.stdenv.shell}

    # Perfrom the backup
    ${resticCmd} backup \
      ${concatStringsSep " " paths} \
      ${concatMapStringsSep " " (e: "-e \"${e}\"") exclude}

    # Remove old backup sets. Keep hourly backups from the past day, daily
    # backups for the past month, weekly backups for the last 3 months, monthly
    # backups for the last year, and yearly backups for the last decade.
    ${resticCmd} forget \
      --prune \
      --keep-hourly 24 \
      --keep-daily 31 \
      --keep-weekly 12 \
      --keep-monthly 12 \
      --keep-yearly 10

    # Print some details about the repository.
    ${resticCmd} snapshots
    ${resticCmd} stats
    ${resticCmd} check
  '';

  resticAutoRestoreScript = path: pkgs.writeScriptBin "restic-restore" ''
    #!${pkgs.stdenv.shell}

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
    script = resticBackupScript paths (exclude ++ [".restic-backup-restored"]);
  in {
    name = "restic-backup";
    value = {
      description = "Backup ${concatStringsSep ", " paths} to ${resticRepository}";
      environment = resticEnvironment;
      # startAt = frequency;
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

  resticAutoRestoreService = name: { path, serviceName, ... }: let
    script = resticAutoRestoreScript path;
  in {
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
in {
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
  in {
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

  config = mkIf (cfg != { }) {
    systemd.services = let
      resticServices = [
        # The main backup service.
        (resticBackupService cfg.backups cfg.exclude)
      ] ++
      # The auto-restore services.
      (mapAttrsToList resticAutoRestoreService
        (filterAttrs
          (n: { autoRestore, ... }: autoRestore)
          cfg.backups));
    in
      listToAttrs resticServices;
  };
}
