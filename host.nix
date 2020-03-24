{pkgs, ...}: {
  imports = [
    ./services/airsonic.nix
    ./services/nextcloud.nix
    ./services/nginx.nix
  ];

  # General packages for system maintenance.
  environment.systemPackages = with pkgs; [
    vim git
  ];

  # Keep the system up-to-date automatically.
  system.autoUpgrade.enable = true;
  system.autoUpgrade.allowReboot = true;
  system.autoUpgrade.dates = "09:00"; # 09:00 UTC = 02:00 or 03:00 (MST/MDT)

  # All users must be added declaritively.
  users.mutableUsers = false;

  # Firewall configuration.
  networking.firewall.allowedTCPPorts = [ 80 443 ];
}
