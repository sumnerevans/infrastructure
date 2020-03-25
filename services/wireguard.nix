{ pkgs, ... }: {
  networking.wg-quick.interfaces.wg0 = {
    address = [ "10.100.100.1/24" ];
    privateKeyFile = "/etc/nixos/secrets/wireguard-privatekey";
    peers = [
      {
        # jedha
        allowedIPs = [ "192.168.69.2/32" ];
        publicKey = "x1BDx/V7ylfF8lKr5ZbYH+XR3UjJG4M0VZTBJTz1Jmo=";
        presharedKeyFile = "/etc/nixos/secrets/wireguard-jedha-presharedkey";
      }
      {
        # coruscant
        allowedIPs = [ "192.168.69.3/32" ];
        publicKey = "z2sm3HzY+9+7+lT9rt2Ny7fTxbDVMJv4+jZ3eFlyUCc=";
        presharedKeyFile = "/etc/nixos/secrets/wireguard-coruscant-presharedkey";
      }
      {
        # iPad
        allowedIPs = [ "192.168.69.4/32" ];
        publicKey = "4qHoCiAVYm2kR6Ak4PaEpdUeRJ/oJDlVQvR8Axffv2U=";
        presharedKeyFile = "/etc/nixos/secrets/wireguard-ipad-presharedkey";
      }
      {
        # Google Pixel 3a
        allowedIPs = [ "192.168.69.5/32" ];
        publicKey = "MGeD4bj63h/EAvI3EYGM3kyQ0mh0Srxv02pTTVl5KwY=";
        presharedKeyFile = "/etc/nixos/secrets/wireguard-pixel-presharedkey";
      }
    ];
  };

  # TODO run unbound
}
