{pkgs, ...}: {
  # Packages for the system.
  environment.systemPackages = with pkgs; [
    vim git
  ];
}
