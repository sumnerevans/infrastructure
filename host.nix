{ pkgs, ... }: {
  imports = import ./services/default.nix;

  # General packages for system maintenance.
  environment.systemPackages = with pkgs; [
    git
    htop
    openssl
    tree
    unzip
    vim
  ];

  # Keep the system up-to-date automatically.
  system.autoUpgrade.enable = true;
  system.autoUpgrade.allowReboot = true;
  system.autoUpgrade.dates = "09:00"; # 09:00 UTC = 02:00 or 03:00 (MST/MDT)

  # All users must be added declaritively.
  users.mutableUsers = false;

  # Network configuration.
  networking = {
    domain = "sumnerevans.com";
    firewall.allowedTCPPorts = [ 80 443 ];
  };
}
