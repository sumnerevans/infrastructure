{ pkgs, ... }: {
  systemd.services.heartbeat = {
    description = "Heartbeat service";
    startAt = "*:0/1"; # Run a ping every minute to ensure that the server is up.
    serviceConfig = {
      ExecStart = "${pkgs.curl}/bin/curl -fsS --retry 10 https://hc-ping.com/43c45999-cc22-430f-a767-31a1a17c6d1b";
    };
  };
}
