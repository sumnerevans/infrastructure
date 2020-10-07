{ pkgs ? import <nixpkgs> {} }:
pkgs.mkShell {
  propagatedBuildInputs = with pkgs; [
    (python38.withPackages(ps: with ps; [
      digital-ocean
      flake8
      pynvim
      yapf
    ]))
    nodePackages.bash-language-server
    # python-language-server
    rst2html5
  ];
}
