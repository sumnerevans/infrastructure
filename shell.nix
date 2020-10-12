{ pkgs ? import <nixpkgs> {} }:
pkgs.mkShell {
  propagatedBuildInputs = with pkgs; [
    nodePackages.bash-language-server
    rnix-lsp
    rst2html5

    (
      python38.withPackages (
        ps: with ps; [
          digital-ocean
          flake8
          jedi
          pynvim
          yapf
        ]
      )
    )
  ];
}
