# See: https://nixos.org/nixos/manual/index.html#module-services-matrix-synapse
{ config, pkgs, ... }:
let
  matrixDomain = "matrix.${config.networking.domain}";
  riotDomain = "riot.${config.networking.domain}";
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
    ${matrixDomain} = {
      enableACME = true;
      forceSSL = true;

      # If they access root, redirect to Riot. If they access the API, then
      # forward on to Synapse.
      locations."/".extraConfig = "return 301 https://riot.sumnerevans.com;";
      locations."/_matrix" = {
        proxyPass = "http://[::1]:8008"; # without a trailing /
      };
    };

    ${riotDomain} = {
      enableACME = true;
      forceSSL = true;
      root = pkgs.riot-web;
    };
  };
}
