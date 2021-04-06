{ lib, pkgs, fetchFromGitHub }: with pkgs; let
  PyInquirer = python38Packages.buildPythonPackage rec {
    pname = "PyInquirer";
    version = "unstable-2021-04-06";
    src = pkgs.fetchFromGitHub {
      owner = "CITGuru";
      repo = "PyInquirer";
      rev = "7485a1fd5442332399d5f05c84e4fd74b63a5823";
      sha256 = "18nv1ck212s14qsyv9r0awlv24qwz0r8vc4yajv70icaf56mdlc4";
    };
    propagatedBuildInputs = with python38Packages; [
      prompt_toolkit
      pygments
    ];
    doCheck = false;
  };
in
python38Packages.buildPythonPackage rec {
  pname = "maubot";
  version = "unstable-2021-04-06";

  propagatedBuildInputs = with python38Packages; [
    aiohttp
    alembic
    attrs
    bcrypt
    click
    colorama
    CommonMark
    jinja2
    mautrix
    packaging
    PyInquirer
    ruamel-yaml
    sqlalchemy
    yarl
  ];

  doCheck = false;

  src = pkgs.fetchFromGitHub {
    owner = "maubot";
    repo = "maubot";
    rev = "a078bdd120908367923cf80445f267f165e89e12";
    sha256 = "1669iy01d59h33g3fz1190v6daldjzb1l9msyqmkdznw72q3vxc4";
  };
}
