{ pkgs, ... }: {
  services.matomo = {
    enable = true;
    nginx = {
      serverName = "matomo.sumnerevans.com";
      onlySSL = true;
    };
  };
}
