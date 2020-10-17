{ config, pkgs, ... }: let
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
    welcometext = "Welcome to Sumner's Mumble Server. Enjoy your stay!";

    # Keys
    sslCert = "${certDirectory}/fullchain.pem";
    sslKey = "${certDirectory}/key.pem";
    sslCa = "${certDirectory}/full.pem";
  };

  # Always make sure that the certificate is accessible to the murmur service.
  systemd.services.murmur.serviceConfig = {
    PermissionsStartOnly = true;
    # ExecStartPre = ''
    #   ${pkgs.coreutils}/bin/chown -R murmur ${certDirectory}
    # '';
  };

  # Open up the ports for TCP and UDP
  networking.firewall = {
    allowedTCPPorts = [ 64738 ];
    allowedUDPPorts = [ 64738 ];
  };

  # Use nginx to do the ACME verification for mumble.
  services.nginx.virtualHosts."${serverName}" = {
    forceSSL = true;
    enableACME = true;
    locations."/".extraConfig = "return 301 https://mumble.info;";
  };
}
