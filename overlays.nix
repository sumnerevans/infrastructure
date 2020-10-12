{ pkgs, lib, ... }: with pkgs; {
  # Awaiting https://github.com/NixOS/nixpkgs/pull/99017
  nixpkgs.overlays = [
    (
      self: super: {
        murmur = (
          super.murmur.override {
            iceSupport = false;
          }
        );
      }
    )
  ];
}
