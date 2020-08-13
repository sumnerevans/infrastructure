{ config, pkgs, ... }: {
  services.logrotate = {
    enable = true;
    # For when this method gets in to unstable
    # paths = {
    #   "/var/log/nginx/*.log /var/spool/nginx/logs/*.log" = {
    #     user = "nginx";
    #     group = "nginx";
    #     extraConfig = ''
    #       size 25M
    #       compress
    #       delaycompress
    #       create 0644 nginx nginx
    #       sharedscripts
    #       postrotate
    #         /usr/bin/env kill -USR1 `cat /run/nginx/nginx.pid 2>/dev/null` 2>/dev/null || true
    #       endscript
    #     '';
    #   };
    # };

    extraConfig = ''
      "/var/log/nginx/*.log" "/var/spool/nginx/logs/*.log" {
        size 25M
        missingok
        rotate 16
        compress
        delaycompress
        notifempty
        create 0644 nginx nginx
        sharedscripts
        postrotate
          /usr/bin/env kill -USR1 `cat /run/nginx/nginx.pid 2>/dev/null` 2>/dev/null || true
        endscript
      }
    '';
  };
}
