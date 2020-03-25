{ pkgs, ... }: {
  services.murmur = {
    enable = true;
    registerHostname = "mumble.sumnerevans.com";
    registerName = "Sumner's Mumble Server";
    welcometext = "Welcome to Sumner's Mumble Server. Enjoy your stay!";
  };

  # Open up the ports for TCP and UDP
  networking.firewall = {
    allowedTCPPorts = [ 64738 ];
    allowedUDPPorts = [ 64738 ];
  };

  # TODO get the certs
}
