{ lib, pkgs, ... }: with lib; let
  websites = [
    { hostname = "the-evans.family"; }
    { hostname = "qs.sumnerevans.com"; }
    {
      hostname = "sumnerevans.com";
      excludeTerms = [
        "/.well-known/"
        "/dark-theme.min.js"
        "/favicon.ico"
        "/js/isso.min.js"
        "/profile.jpg"
        "/robots.txt"
        "/style.css"
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

    virtualHosts = let
      # Put logs for each website in a separate log file.
      websiteConfig = { hostname, ... }: {
        name = hostname;
        value = {
          forceSSL = true;
          enableACME = true;
          locations."/" = {
            root = "/var/www/${hostname}";
            extraConfig = ''
              access_log /var/log/nginx/${hostname}.access.log;
            '';
          };
        };
      };
    in
      {
        # Enable a status page and expose it.
        "status.sumnerevans.com" = {
          forceSSL = true;
          enableACME = true;
          locations."/".extraConfig = "stub_status on;access_log off;";
        };
      } // listToAttrs (map websiteConfig websites);
  };

  # Add metrics displays for each of the websites.
  services.metrics.websites = websites;

  # Open up the ports
  networking.firewall.allowedTCPPorts = [ 80 443 ];
}
