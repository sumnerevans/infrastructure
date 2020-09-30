# See: https://nixos.org/nixos/manual/index.html#module-services-matrix-synapse
{ config, pkgs, ... }:
let
  matrixDomain = "matrix.${config.networking.domain}";
in {
  # Run Synapse
  services.matrix-synapse = {
    enable = true;
    enable_metrics = true;
    enable_registration = false;
    server_name = config.networking.domain;
    max_upload_size = "250M";
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

  # Run go-neb for the echo bot.
  services.go-neb = {
    baseUrl = "http://localhost";
    enable = true;
  };

  # Make sure that Postgres is setup for Synapse.
  services.postgresql = {
    ensureDatabases = [ "matrix-synapse" ];
    ensureUsers = [
      {
        name = "matrix-synapse";
        ensurePermissions."DATABASE \"matrix-synapse\"" = "ALL PRIVILEGES";
      }
    ];
  };

  # Set up nginx to forward requests properly.
  services.nginx.virtualHosts = {
    # Reverse proxy for Matrix client-server and server-server communication
    ${matrixDomain} = {
      enableACME = true;
      forceSSL = true;

      # If they access root, redirect to Element. If they access the API, then
      # forward on to Synapse.
      locations."/".extraConfig = "return 301 https://app.element.io;";
      locations."/_matrix" = {
        proxyPass = "http://[::1]:8008"; # without a trailing /
      };
    };
  };
}
