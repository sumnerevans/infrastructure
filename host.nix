{ pkgs, ... }: {
  imports = import ./services/default.nix;

  # General packages for system maintenance.
  environment.systemPackages = with pkgs; [
    bind
    git
    htop
    openssl
    tree
    unzip
    vim
  ];

  # Keep the system up-to-date automatically.
  system.autoUpgrade = {
    enable = true;
    allowReboot = true;
    dates = "09:00"; # 09:00 UTC = 02:00 or 03:00 (MST/MDT)
  };

  # Garbage collect the old generations.
  nix.gc = {
    automatic = true;
    dates = "10:00"; # 10:00 UTC = 03:00 or 04:00 (MST/MDT)
    options = "--delete-older-than 30d";
  };

  # All users must be added declaritively.
  users.mutableUsers = false;

  # Domain name.
  networking.domain = "sumnerevans.com";

  # Enable a lot of swap since we have enough disk. This way, if Airsonic eats
  # memory, it won't crash the box.
  swapDevices = [
    {
      device = "/var/swapfile";
      size = 4096;
    }
  ];

  # Allow GitLab CI/CD to SSH in and upgrade the server.
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCs0CbfyzxbTTST4bYVZ4qhV8WQR1EWDRlzhaX4MfCGT3DyokXSfhe+RWdvo2FGFwduFMkVEKTGbMCkdt7Ip3vNYuWNB36oimEV9zB37ejD6wPZcEem/P9PR0gb0Cy/XuMkBhXaeA+vPSGU9WRBOuVuFQQRX+NoC62KTwmZac1ro9nx4bMa2OYDnDNh2ogSXVkHGutpP+iUnESTA3d2fB1j9x+wbDRmDQvrYKdlC8mNeSuzDd/1KL0eDI+Y2rmdKZ+QZW/E2Y41l7AI7IOG2i1Y+aS8JkhUjZmO9Ci3ApMHbGtL6X42oQ+TxDIQVBq/GKEbWLigsp1WlqeEzqA+GbOp GitLab-CD"
  ];
}
