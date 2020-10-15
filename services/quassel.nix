{ config, pkgs, ... }: let
  certs = config.security.acme.certs;
  serverName = "irc.${config.networking.domain}";
  certDirectory = "${certs.${serverName}.directory}";
in
{
  services.quassel = {
    enable = true;
    interfaces = [ "0.0.0.0" ];
    certificateFile = "${certDirectory}/fullchain.pem";
  };

  networking.firewall.allowedTCPPorts = [ 4242 ];

  security.acme.certs."${serverName}" = {
    postRun = "systemctl restart quassel && systemctl reload nginx";
  };
}
