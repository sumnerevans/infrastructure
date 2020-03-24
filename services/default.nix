{pkgs, ...}: {
  imports = [
    ./airsonic.nix
    ./bitwarden.nix
    ./matomo.nix
    ./matrix.nix
    ./mumble.nix
    ./nextcloud.nix
    ./nginx.nix
    ./quassel.nix
    ./wireguard.nix
  ];
}
