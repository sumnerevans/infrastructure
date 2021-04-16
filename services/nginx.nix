{ config, lib, pkgs, ... }: with lib; let
  hostnameDomain = "${config.networking.hostName}.${config.networking.domain}";
  websites = [
    { hostname = "the-evans.family"; }
    { hostname = "qs.${config.networking.domain}"; }
    {
      # sumnerevans.com
      hostname = config.networking.domain;
      extraLocations = {
        "/teaching" = {
          root = "/var/www";
          priority = 0;
          extraConfig = ''
            access_log /var/log/nginx/${config.networking.domain}.access.log;
            autoindex on;
          '';
        };
      };
      excludeTerms = [
        "/.well-known/"
        "/dark-theme.min.js"
        "/favicon.ico"
        "/js/isso.min.js"
        "/profile.jpg"
        "/robots.txt"
        "/style.css"
        "/teaching/csci564-s21/_static/"
      ];
    }
  ];
in
{
  # Enable nginx and add the static websites.
  services.nginx = {
    enable = true;
    enableReload = true;
    clientMaxBodySize = "250m";
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    virtualHosts =
      let
        websiteConfig = { hostname, extraLocations ? { }, ... }: {
          name = hostname;
          value = {
            forceSSL = true;
            enableACME = true;
            locations = extraLocations // {
              "/" = {
                root = "/var/www/${hostname}";
                extraConfig = ''
                  # Put logs for each website in a separate log file.
                  access_log /var/log/nginx/${hostname}.access.log;

                  # Disable using my website in FLoC calculations.
                  add_header Permissions-Policy interest-cohort=();
                '';
              };
            };
          };
        };
      in
      {
        ${hostnameDomain} = {
          forceSSL = true;
          enableACME = true;

          # Enable a status page and expose it.
          locations."/status".extraConfig = ''
            stub_status on;
            access_log off;
          '';
        };
      } // listToAttrs (map websiteConfig websites);
  };

  # Add metrics displays for each of the websites.
  services.metrics.websites = websites;

  # Open up the ports
  networking.firewall.allowedTCPPorts = [ 80 443 ];
}
