{ config, pkgs, ... }: {
  services.logrotate = {
    enable = true;
    paths = {
      "nginx" = {
        user = "nginx";
        group = "nginx";
        path = "/var/log/nginx/*.log /var/spool/nginx/logs/*.log";
        extraConfig = ''
          size 25M
          missingok
          compress
          delaycompress
          notifempty
          create 0644 nginx nginx
          sharedscripts
          postrotate
            /usr/bin/env kill -USR1 `cat /run/nginx/nginx.pid 2>/dev/null` 2>/dev/null || true
          endscript
        '';
      };
    };
  };
}
