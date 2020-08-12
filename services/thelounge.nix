{ config, pkgs, ... }: let
  serverName = "irc.sumnerevans.com";
in {
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

  users.users.thelounge = {
    useDefaultShell = true;
    home = "/var/lib/thelounge";
  };

  # Set up nginx to forward requests properly.
  services.nginx.virtualHosts = {
    "${serverName}" = {
      enableACME = true;
      forceSSL = true;

      locations."/".proxyPass = "http://127.0.0.1:9000";
    };
  };
}
