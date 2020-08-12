{ config, pkgs, ... }: let
  serverName = "dav.sumnerevans.com";
in {
  services.xandikos = {
    enable = true;
    extraOptions = [
      "--defaults"
      "--current-user-principal /sumner/"
    ];

    nginx = {
      enable = true;
      hostName = "${serverName}";
    };
  };

  # Set up nginx to forward requests properly.
  services.nginx.virtualHosts = {
    "${serverName}" = {
      enableACME = true;
      forceSSL = true;
      basicAuth = {
        sumner = "${builtins.readFile "/etc/nixos/secrets/xandikos"}";
      };
    };
  };
}
