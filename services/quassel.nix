{ pkgs, ... }: {
  services.quassel = {
    enable = true;
    interfaces = [ "0.0.0.0" ];
  };

  networking.firewall.allowedTCPPorts = [ 4242 ];
}
