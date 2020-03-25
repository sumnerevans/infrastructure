{ pkgs, ... }: {
  networking.wireguard.enable = true;
  networking.wireguard.interfaces.wg0 = {
    ips = [ "192.168.69.1/24" ];
    listenPort = 51820;
    privateKeyFile = "/etc/nixos/secrets/wireguard-privatekey";

    peers = [
      {
        # jedha
        allowedIPs = [ "192.168.69.2/32" ];
        presharedKeyFile = "/etc/nixos/secrets/wireguard-jedha-presharedkey";
        publicKey = "x1BDx/V7ylfF8lKr5ZbYH+XR3UjJG4M0VZTBJTz1Jmo=";
      }
      {
        # coruscant
        allowedIPs = [ "192.168.69.3/32" ];
        presharedKeyFile = "/etc/nixos/secrets/wireguard-coruscant-presharedkey";
        publicKey = "z2sm3HzY+9+7+lT9rt2Ny7fTxbDVMJv4+jZ3eFlyUCc=";
      }
      {
        # iPad
        allowedIPs = [ "192.168.69.4/32" ];
        presharedKeyFile = "/etc/nixos/secrets/wireguard-ipad-presharedkey";
        publicKey = "4qHoCiAVYm2kR6Ak4PaEpdUeRJ/oJDlVQvR8Axffv2U=";
      }
      {
        # Google Pixel 3a
        allowedIPs = [ "192.168.69.5/32" ];
        presharedKeyFile = "/etc/nixos/secrets/wireguard-pixel-presharedkey";
        publicKey = "MGeD4bj63h/EAvI3EYGM3kyQ0mh0Srxv02pTTVl5KwY=";
      }
    ];
  };

  # Open up the ports
  networking.firewall.allowedTCPPorts = [ 51820 ];

  # TODO run unbound
}
