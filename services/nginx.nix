{ pkgs, config, ... }: {
  services.nginx = {
    enable = true;
    enableReload = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    virtualHosts = {
      # Enable a status page and expose it.
      "status.sumnerevans.com" = {
        forceSSL= true;
        enableACME = true;
        locations."/".extraConfig = "stub_status on;access_log off;";
      };

      # By default, proxy requests to sumnerevans.com to GitLab.
      "${config.networking.domain}" = {
        locations."/" = {
          proxyPass = "https://35.185.44.232";
        };
      };
    };
  };
}
