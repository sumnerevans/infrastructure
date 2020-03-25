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

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCs0CbfyzxbTTST4bYVZ4qhV8WQR1EWDRlzhaX4MfCGT3DyokXSfhe+RWdvo2FGFwduFMkVEKTGbMCkdt7Ip3vNYuWNB36oimEV9zB37ejD6wPZcEem/P9PR0gb0Cy/XuMkBhXaeA+vPSGU9WRBOuVuFQQRX+NoC62KTwmZac1ro9nx4bMa2OYDnDNh2ogSXVkHGutpP+iUnESTA3d2fB1j9x+wbDRmDQvrYKdlC8mNeSuzDd/1KL0eDI+Y2rmdKZ+QZW/E2Y41l7AI7IOG2i1Y+aS8JkhUjZmO9Ci3ApMHbGtL6X42oQ+TxDIQVBq/GKEbWLigsp1WlqeEzqA+GbOp GitLab"
  ];
}
