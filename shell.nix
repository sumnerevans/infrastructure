{ pkgs ? import <nixpkgs> {} }:
pkgs.mkShell {
  propagatedBuildInputs = with pkgs; [
    (python38.withPackages(ps: with ps; [
      digital-ocean
      flake8
      pynvim
      python-language-server
      yapf
    ]))
    nodePackages.bash-language-server
    rst2html5
  ];
}
