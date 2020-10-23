{ lib, pkgs, fetchFromGitHub }: with pkgs; let
  py = python3.override {
    packageOverrides = self: super: {
      prompt_toolkit = super.prompt_toolkit.overridePythonAttrs (
        oldAttrs: rec {
          version = "1.0.14";
          src = oldAttrs.src.override {
            inherit version;
            sha256 = "cc66413b1b4b17021675d9f2d15d57e640b06ddfd99bb724c73484126d22622f";
          };
        }
      );

      mautrix = super.mautrix.overridePythonAttrs (
        oldAttrs: rec {
          version = "0.7.14";
          doCheck = false;
          src = oldAttrs.src.override {
            inherit version;
            sha256 = "d003cc0f36a6d1e632e4364c7ac7e25c66d7acf4fe65b4396de2aa41697dc2d0";
          };
        }
      );
    };
  };
  PyInquirer = py.pkgs.buildPythonApplication rec {
    pname = "PyInquirer";
    version = "1.0.3";
    src = python38.pkgs.fetchPypi {
      inherit pname version;
      sha256 = "c9a92d68d7727fbd886a7908c08fd9e9773e5dc211bf5cbf836ba90d366dee51";
    };
    propagatedBuildInputs = with py.pkgs; [
      prompt_toolkit
      pygments
      regex
    ];
    doCheck = false;
  };
in
buildPythonApplication rec {
  pname = "maubot";
  version = "0.1.0";

  propagatedBuildInputs = with py.pkgs;[
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
    ruamel_yaml
    sqlalchemy
    yarl
  ];

  doCheck = false;

  src = python38.pkgs.fetchPypi {
    inherit pname version;
    sha256 = "23da68ce05c55167d9e91d73b601d5050aec40d84269b662e14b9ae6a5ed08e2";
  };
}
