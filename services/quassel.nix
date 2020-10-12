{ config, pkgs, ... }: let
  certs = config.security.acme.certs;
  serverName = "irc.sumnerevans.com";
in
{
  services.quassel = {
    enable = true;
    interfaces = [ "0.0.0.0" ];
    certificateFile = "${certs.${serverName}.directory}/fullchain.pem";
  };

  networking.firewall.allowedTCPPorts = [ 4242 ];

  security.acme.certs."${serverName}" = {
    postRun = "systemctl restart quassel && systemctl reload nginx";
  };
}
