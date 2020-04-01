{ config, pkgs, ... }: let
  certs = config.security.acme.certs;
  serverName = "irc.sumnerevans.com";
in {
  services.quassel = {
    enable = true;
    interfaces = [ "0.0.0.0" ];
    certificateFile = "${certs.${serverName}.directory}/fullchain.pem";
  };

  networking.firewall.allowedTCPPorts = [ 4242 ];

  # Use nginx to do the ACME verification for mumble.
  services.nginx.virtualHosts."${serverName}" = {
    locations."/".extraConfig = "return 301 https://https://quassel-irc.org;";
    locations."/.well-known/acme-challenge".root = "/var/lib/acme/acme-challenges";
  };

  security.acme.certs."${serverName}" = {
    webroot = "/var/lib/acme/acme-challenges";
    postRun = "systemctl restart quassel";
    user = "quassel";
  };
}
