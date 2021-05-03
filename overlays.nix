{ pkgs, lib, ... }: with pkgs; {
  nixpkgs.overlays = [
    (
      self: super: { }
    )
  ];
}
