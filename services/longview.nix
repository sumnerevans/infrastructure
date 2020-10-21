{ config, pkgs, ... }: let
  hostnameDomain = "${config.networking.hostName}.${config.networking.domain}";
in
{
  services.longview = {
    enable = true;
    apiKeyFile = ../secrets/longview-api-key;
    nginxStatusUrl = "https://${hostnameDomain}/status";
  };
}
