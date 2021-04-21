{
  imports = [
    ./gonic-module.nix
  ];

  services.gonic = {
    enable = true;
    virtualHost = "music.sumnerevans.com";
    musicPath = "/var/lib/gonic/music";
    podcastPath = "/var/lib/gonic/podcasts";
  };
}
