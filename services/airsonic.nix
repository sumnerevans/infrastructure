{ pkgs, ... }: {
  # Install the airsonic package.
  environment.systemPackages = with pkgs; [
    airsonic
  ];

  # Create the airsonic service.
  services.airsonic = {
    enable = false;
    maxMemory = 1024;
    virtualHost = "airsonic.sumnerevans.com";
  };

  # Get a cert for it and make it only available over HTTPS.
  services.nginx.virtualHosts = {
    "airsonic.sumnerevans.com" = {
      forceSSL= true;
      enableACME = true;
    };
  };
}
