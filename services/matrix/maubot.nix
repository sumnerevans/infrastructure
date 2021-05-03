{ pkgs, ... }:
let
  maubot = pkgs.callPackage ../../pkgs/maubot.nix { };
in
{
  systemd.services.maubot = {
    description = "Run maubot";
    serviceConfig = {
      ExecStart = "${maubot}/bin/maubot";
    };
  };
}
