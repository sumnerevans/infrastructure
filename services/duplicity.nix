# This is similar to
# https://github.com/NixOS/nixpkgs/blob/release-19.09/nixos/modules/services/backup/duplicity.nix
# But I wanted services per folder to backup.
{ config, lib, pkgs, ... }: with lib; let
  cfg = config.services.backup;
  backupDirOpts = { name, ... }: {
    options = {
      root = mkOption {
        type = types.str;
        description = "The folder to back up.";
      };

      bucket = mkOption {
        type = types.str;
        description = "The B2 bucket name to back up to.";
      };

      folder = mkOption {
        type = types.str;
        description = "The folder in the B2 bucket to back up to.";
      };

      frequency = mkOption {
        type = types.str;
        default = "0/3:0";
        description = ''
          Systemd calendar expression for how often to run the service. See
          <citerefentry><refentrytitle>systemd.time</refentrytitle>
          <manvolnum>7</manvolnum></citerefentry>.
        '';
      };
    };
  };

  # TODO make this actually work.
  # - Get the GPG key in here
  # - https://github.com/NixOS/nixpkgs/pull/78116
  duplicitySignEncryptArgs =
    "--sign-key $SIGN_KEY --encrypt-key $ENCRYPT_KEY";

  # The $1 is the folder to put the backups in.
  b2BucketDescriptor = "b2://$B2_ACCOUNT:$B2_KEY@$BUCKET/$FOLDER";
  duplicityBackupScript = pkgs.writeScriptBin "duplicity-backup" ''
    #!${pkgs.stdenv.shell}

    # Perfrom the backup
    ${pkgs.duplicity}/bin/duplicity \
        ${duplicitySignEncryptArgs} \
        --full-if-older-than 30D \
        $ROOT ${b2BucketDescriptor}

    # Remove backup sets older than 90 days
    ${pkgs.duplicity}/bin/duplicity \
        ${duplicitySignEncryptArgs} \
        remove-older-than 90D --force \
        ${b2BucketDescriptor}

    # Cleanup failures
    ${pkgs.duplicity}/bin/duplicity \
        ${duplicitySignEncryptArgs} \
        cleanup --force \
        ${b2BucketDescriptor}

    # Cleanup failures
    ${pkgs.duplicity}/bin/duplicity \
        ${duplicitySignEncryptArgs} \
        collection-status \
        ${b2BucketDescriptor}
  '';
  duplicityHome = "/var/lib/duplicity";
  duplicityBackupService = { root, bucket, folder, frequency ? "0/3:0", ... }: {
    description = "Backup ${root} to ${bucket}";
    environment = {
      HOME = duplicityHome;
      ROOT = root;
      BUCKET = bucket;
      FOLDER = folder;
    };
    startAt = frequency;
    path = [ pkgs.backblaze-b2 ];
    serviceConfig = {
      ExecStart = ''
        ${duplicityBackupScript}/bin/duplicity-backup
      '';
      EnvironmentFile = "/etc/nixos/secrets/duplicity-environment-variables";
      PrivateTmp = true;
      ProtectSystem = true;
      ProtectHome = "read-only";
    };
  };
in {
  options = {
    services.backup = mkOption {
      default = {};
      type = with types; attrsOf (submodule backupDirOpts );
      description = "Definition directories to backup.";
    };
  };
  config = mkIf (cfg != { }) {
    systemd = {
      services = let
        directoryBackupConfig = mapAttrsToList (name: data: {
            name = "backup-${name}";
            value = duplicityBackupService data;
          }) cfg;
      in
        listToAttrs directoryBackupConfig;
    };
  };
}
