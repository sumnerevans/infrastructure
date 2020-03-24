{ pkgs, ... }: {
  # Install the matomo package.
  environment.systemPackages = with pkgs; [
    matomo
  ];
}
