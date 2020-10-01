{ lib, pkgs, ... }: let
  issoConfig = ''
    [general]
    dbpath = /var/lib/isso/comments.db
    host = https://sumnerevans.com
    notify = smtp
    reply-notifications = true
    gravatar = true

    [moderation]
    enabled = true
    purge-after = 30d

    [server]
    listen = http://127.0.0.1:8888/

    [smtp]
    username = comments@sumnerevans.com
    password = ${builtins.readFile ../secrets/isso-comments-smtp-password}
    host = smtp.migadu.com
    port = 587
    security = starttls
    to = admin@sumnerevans.com
    from = comments@sumnerevans.com

    [guard]
    enabled = true
    ratelimit = 2
    direct-reply = 3
    reply-to-self = false

    [markup]
    options = tables, fenced-code, footnotes, autolink, strikethrough, underline, math, math-explicit
    allowed-elements = img
    allowed-attributes = src

    [admin]
    enabled = true
    password = ${builtins.readFile ../secrets/isso-admin-password}
  '';
  issoConfigFile = pkgs.writeTextFile {
    name = "isso.cfg";
    text = issoConfig;
  };
in {
  systemd.services.isso = {
    description = "Run an Isso server.";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target "];
    serviceConfig = {
      User = "isso";
      ExecStart = "${pkgs.isso}/bin/isso -c ${issoConfigFile} run";
    };
  };

  users.groups.isso = {};
  users.users.isso = {
    description = "Isso server user";
    group = "isso";
    home = "/var/lib/isso";
    createHome = true;
  };

  # Set up nginx to forward requests properly.
  services.nginx.virtualHosts = {
    "comments.sumnerevans.com" = {
      enableACME = true;
      forceSSL = true;

      locations."/".proxyPass = "http://127.0.0.1:8888";
    };
  };
}
