{ ... }: {
  imports = [
    ./acme.nix
    ./airsonic.nix
    ./bitwarden.nix
    ./goaccess.nix
    # ./gonic.nix
    ./isso.nix
    ./logrotate.nix
    ./longview.nix
    ./matrix/default.nix
    ./mumble.nix
    ./nginx.nix
    ./postgresql.nix
    ./quassel.nix
    ./restic.nix
    ./syncthing.nix
    ./thelounge.nix
    ./wireguard.nix
    ./xandikos.nix
  ];

  services.nginx.virtualHosts = {
    "music.sumnerevans.com" = {
      forceSSL = true;
      enableACME = true;
    };
  };
}
