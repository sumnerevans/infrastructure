{ pkgs, ... }: {
  services.quassel = {
    enable = true;
    interfaces = [ "0.0.0.0" ];
  };

  # TODO SSL Cert
}