# See: https://nixos.org/nixos/manual/index.html#module-services-matrix-synapse
{ pkgs, config, ... }:
let
  subdomain = "matrix";
  fqdn = "${subdomain}.${config.networking.domain}";
in {
  # Run Synapse
  services.matrix-synapse = {
    enable = true;
    enable_metrics = true;
    enable_registration = false;
    server_name = config.networking.domain;
    listeners = [
      {
        port = 8008;
        bind_address = "::1";
        type = "http";
        tls = false;
        x_forwarded = true;
        resources = [
          {
            names = [ "client" "federation" ];
            compress = false;
          }
        ];
      }
    ];
  };

  # Set up nginx to forward requests properly.
  services.nginx.virtualHosts = {
    # Reverse proxy for Matrix client-server and server-server communication
    ${fqdn} = {
      enableACME = true;
      forceSSL = true;

      # Or do a redirect instead of the 404, or whatever is appropriate for you.
      # But do not put a Matrix Web client here! See the Riot Web section below.
      locations."/".extraConfig = ''
        return 404;
      '';

      # forward all Matrix API calls to the synapse Matrix homeserver
      locations."/_matrix" = {
        proxyPass = "http://[::1]:8008"; # without a trailing /
      };
    };
  };
}
