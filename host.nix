{ pkgs, ... }: {
  imports = [
    ./overlays.nix
    ./programs/default.nix
    ./services/default.nix
  ];

  # General packages for system maintenance.
  environment.systemPackages = with pkgs; [
    bind
    direnv
    fd
    git
    gnupg
    htop
    iftop
    inetutils
    mtr
    neovim
    nix-direnv
    openssl
    restic
    ripgrep
    rsync
    sysstat
    tmux
    tree
    unzip
    vim
    zsh
  ];

  # nix-direnv
  # nix options for derivations to persist garbage collection
  nix.extraOptions = ''
    keep-outputs = true
    keep-derivations = true
  '';

  environment.pathsToLink = [
    "/share/nix-direnv"
  ];

  # Keep the system up-to-date automatically.
  system.autoUpgrade = {
    enable = true;
    allowReboot = true;
    dates = "monthly";
  };

  # Garbage collect the old generations.
  nix.gc = {
    automatic = true;
    dates = "10:00"; # 10:00 UTC = 03:00 or 04:00 (MST/MDT)
    options = "--delete-older-than 30d";
  };

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

  # All users must be added declaratively.
  users.mutableUsers = false;

  # Disable password authentication for SSH.
  services.openssh.passwordAuthentication = false;

  users.users.root = {
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      # Allow Sourcehut deploy to SSH in and upgrade the server.
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCs0CbfyzxbTTST4bYVZ4qhV8WQR1EWDRlzhaX4MfCGT3DyokXSfhe+RWdvo2FGFwduFMkVEKTGbMCkdt7Ip3vNYuWNB36oimEV9zB37ejD6wPZcEem/P9PR0gb0Cy/XuMkBhXaeA+vPSGU9WRBOuVuFQQRX+NoC62KTwmZac1ro9nx4bMa2OYDnDNh2ogSXVkHGutpP+iUnESTA3d2fB1j9x+wbDRmDQvrYKdlC8mNeSuzDd/1KL0eDI+Y2rmdKZ+QZW/E2Y41l7AI7IOG2i1Y+aS8JkhUjZmO9Ci3ApMHbGtL6X42oQ+TxDIQVBq/GKEbWLigsp1WlqeEzqA+GbOp Sourcehut"

      # Allow personal computers to SSH in to the server.
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDasJXb4uvxPh0Z1NLa22dTx42VdWD+utRMbK0WeXS6XakIipx1YPb4yqbtUMJkoTLuFW/BUAEXSiks+ARD3Lc4K/iJeHHXbYvgklvr5dAPV6P2KtiVRZ+ipSLv1TF+al6hVUAnp4PPUQTv+3ZRA64QFrCAt26A7OnxKlowyW2KZVSqAcWPdQEbCdwILRCRIWTpbSj1rDeEsnvmu1G+Id5v7+uybQ+twBHbGpfYH7yWYLEhDtRyYu5SgnBcEh0bqszEgt+iLH/XzTQJILKdDaf4x8j/FJ9Px7+VQVfc+yADZ882ZsFzaxlmn7ndstAssmSSsHfRmNye0exIJqGXdxUfpF3w4h5qnR/0AJM7ljtXuDNOlOxflX0WvZinhhOJ/gF3No8sCXG/OcqlMNyrWd+vpJH4f9Xa0PTOn3Qpltq3YxWOZrWopUIDZw5jSsgLpLfC2NtGE/p5nEFnJCmMqrXPDY7dYS+65qYYjWXCzY3d9i3offwIQtV780Gu1VvT/zE= sumner@coruscant"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDPswA82WA6tHR8rccfVrmBflIfC9SmZpG1Y+Gr8WPxcMy/fdlOt8zV4FveUA466pu9oOsZKmuz8WlP2RK96mhhf/CB68QyPAObo6NyIKQgDC97owRGpNtGTUw4bWdGT+9VKDcuoJdK0cI1dY3jrhIgKL43rOfBnhJfDEBWpRJFof79AfN+Zcs1hTprCjPbiHdXuc7E+uhvxdKfoC2lTDYneVNFUBubcH6SSCJ27AZURPca2aSMkWgGCVTom1ch4Y8jZ5e6Kg0pNZW8LQoLC/kzdwC/f8DHXPFSFipVP5jJ6qtXWm0WCY62nsuV6GyphmmC2H25gV3GefD1ano2pJixRMfj8Muvwm+XKXD7GqmprEKMr0KZjkMGKq144T31TWG/LXkRKuGmHf9wNx4gmFTr6stG30nDYlhaMf/jpeoSAPV9o48x6DZqgd+ukQHKG/uXIYU9gj6OtFOi5bJQp+64P1pBc78942PdnvgC4Bk2sqOyj8nPFeFZKAURctib38U= sumner@jedha"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC9J5GLv9e/k1yDFw/pWyGFcHeRaLMI3j22ihQfGKgfX9Kl3X/R2s5+4a4c98PbPeeO0WlFvu0JiwhT1MLb5Kk5iLxVf8C32kNPQ0kLpa+g/L7YSsvYMThUF8qcLhw0imDVEye4gKrKc6uQDwaCr/Rd+93elfeZ+OQj34czWV1vf4Tnpiad7WZ0IVklN5GQTdVTVPDzjiLaKgl/f3E/wv7DYibDUwwdCBWxo+4RJ9QbSwbgxQykLe3TOydPbwyIk5jmGSdNjtxhT4223lVZICBD2AYf23ERPZz/VtPZvF4qv+55C9YjoatAlW68esKTV3X2qV7K19RbeD58N8Yk16SMgs/HyLzXk4L1pPVNMZVAKX7nqNWnn12VMzHa+DJsEBvcnzwaGsBqEuf3fPzP7Isp9IKwQcBEF+mM1UgGRx8OA5tYt9vOnXtYJG+nOkupfga/fT1Zl9Imao+B0Gz1gG6ywM6bxUr5kkjvuQggc4J6pTslG11IQrnBll7k04vKDtM= sumner@mustafar"
    ];
  };
}
