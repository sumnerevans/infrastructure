{ config, pkgs, ... }: {
  services.thelounge = {
    enable = true;
    private = true;
    extraConfig = {
      reverseProxy = true;
      theme = "morning";
      defaults = {
        name = "Freenode";
        host = "chat.freenode.net";
        port = 6697;
        tls = true;
      };
    };
  };

  # Set up nginx to forward requests properly.
  services.nginx.virtualHosts = {
    "lounge.sumnerevans.com" = {
      enableACME = true;
      forceSSL = true;

      locations."/".proxyPass = "http://127.0.0.1:9000";
    };
  };
}

