{ config, pkgs, ... }: {
  services.longview = {
    enable = true;
    apiKeyFile = ../secrets/longview-api-key;
    nginxStatusUrl = "https://status.sumnerevans.com";
  };
}
