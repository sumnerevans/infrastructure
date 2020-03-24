{ pkgs, ... }: {
  services.murmur = {
    enable = true;
    registerHostname = "mumble.sumnerevans.com";
    registerName = "Sumner's Mumble Server";
    welcometext = "Welcome to Sumner's Mumble Server. Enjoy your stay!";
  };

  # TODO get the certs
}
