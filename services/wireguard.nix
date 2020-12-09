{ lib, pkgs, ... }: {
  # Need to have NAT to be able to forward on things like a VPN endpoint.
  networking.nat = {
    enable = true;
    externalInterface = "eth0";
    internalInterfaces = [ "wg0" ];
  };

  # Set up the Wireguard interface.
  networking.wg-quick.interfaces.wg0 = {
    address = [ "192.168.69.1/24" ];
    listenPort = 51820;
    privateKeyFile = "/etc/nixos/secrets/wireguard-privatekey";
    postUp = "iptables -A FORWARD -i %i -j ACCEPT; iptables -A FORWARD -o %i -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE";
    postDown = "iptables -D FORWARD -i %i -j ACCEPT; iptables -D FORWARD -o %i -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE";

    peers = let
      presharedKeyPath = deviceName: "/etc/nixos/secrets/wireguard-${deviceName}-presharedkey";
    in
      [
        {
          # jedha
          allowedIPs = [ "192.168.69.2/32" ];
          presharedKeyFile = presharedKeyPath "jedha";
          publicKey = "kcHAXPtOWQsX8sc9gGXI5q9uxSBdOA1ryk9yNLJIFk8=";
        }
        {
          # coruscant
          allowedIPs = [ "192.168.69.3/32" ];
          presharedKeyFile = presharedKeyPath "coruscant";
          publicKey = "z2sm3HzY+9+7+lT9rt2Ny7fTxbDVMJv4+jZ3eFlyUCc=";
        }
        {
          # iPad Pro
          allowedIPs = [ "192.168.69.4/32" ];
          presharedKeyFile = presharedKeyPath "ipad";
          publicKey = "4qHoCiAVYm2kR6Ak4PaEpdUeRJ/oJDlVQvR8Axffv2U=";
        }
        {
          # Google Pixel 3a
          allowedIPs = [ "192.168.69.5/32" ];
          presharedKeyFile = presharedKeyPath "pixel";
          publicKey = "MGeD4bj63h/EAvI3EYGM3kyQ0mh0Srxv02pTTVl5KwY=";
        }
        {
          # mustafar
          allowedIPs = [ "192.168.69.6/32" ];
          presharedKeyFile = presharedKeyPath "mustafar";
          publicKey = "x8uqET3xM3rA2zNXViousJoJAQEL0YS7I4RXcp04jm4=";
        }
      ];
  };

  # Open up the ports
  networking.firewall = {
    allowedTCPPorts = [ 53 51820 ];
    allowedUDPPorts = [ 53 51820 ];

    # This allows the wireguard server to route your traffic to the internet
    # and hence be like a VPN
    extraCommands = ''
      iptables -t nat -A POSTROUTING -s 192.168.69.0/24 -o eth0 -j MASQUERADE
    '';
  };

  # Run unbound DNS so that the DNS requests can be tunneled through this VPN.
  services.unbound = with lib; let
    extraConfig = "  " + concatStringsSep "\n  " [
      "num-threads: 4"
      "private-address: 192.168.69.1/24"

      # Hide DNS Server info
      "hide-identity: yes"
      "hide-version: yes"

      # Add an unwanted reply threshold to clean the cache and avoid when
      # possible a DNS Poisoning
      "unwanted-reply-threshold: 10000000"

      # Have the validator print validation failures to the log.
      "val-log-level: 1"
    ];
  in
    {
      enable = true;
      allowedAccess = [ "127.0.0.1" "192.168.69.1/24" ];
      enableRootTrustAnchor = true;
      interfaces = [ "0.0.0.0" ];
      extraConfig = extraConfig;
    };

  # Remove after https://github.com/NixOS/nixpkgs/pull/106308 is in unstable.
  systemd.services.unbound.serviceConfig.RestrictAddressFamilies = [ "AF_NETLINK" ];
}
