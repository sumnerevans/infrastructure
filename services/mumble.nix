{ config, lib, pkgs, ... }:
let
  certs = config.security.acme.certs;
  serverName = "mumble.${config.networking.domain}";
  certDirectory = "${certs.${serverName}.directory}";
  port = config.services.murmur.port;
in
{
  services.murmur = {
    enable = true;
    registerHostname = serverName;
    registerName = "Sumner's Mumble Server";
    welcometext = ''
      Welcome to Sumner's Mumble Server.

      If you are here for office hours, join the "Office Hours" channel. I will
      manually move you to a breakout room if necessary.
    '';

    # Keys
    sslCert = "${certDirectory}/fullchain.pem";
    sslKey = "${certDirectory}/key.pem";
    sslCa = "${certDirectory}/full.pem";
  };

  # Open up the ports for TCP and UDP
  networking.firewall = {
    allowedTCPPorts = [ 64738 ];
    allowedUDPPorts = [ 64738 ];
  };

  # Use nginx to do the ACME verification for mumble.
  services.nginx.virtualHosts."${serverName}" = {
    enableACME = true;
    locations."/".extraConfig = "return 301 https://mumble.info;";
  };

  # https://github.com/NixOS/nixpkgs/issues/106068#issuecomment-739534275
  security.acme.certs."mumble.sumnerevans.com".group = "murmur-cert";
  users.groups.murmur-cert.members = [ "murmur" "nginx" ];

  # Add a backup service.
  services.backup.backups.murmur = {
    path = config.users.users.murmur.home;
  };
}
