{ pkgs ? import <nixpkgs> {} }:
pkgs.mkShell {
  propagatedBuildInputs = with pkgs; [
    gnutar
    nodePackages.bash-language-server
    openssl
    pass
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
