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

  yarnCache = stdenv.mkDerivation {
    name = "${pname}-${version}-${system}-yarn-cache";
    inherit src patches;
    phases = [ "unpackPhase" "buildPhase" ];
    nativeBuildInputs = [ yarn ];
    buildPhase = ''
      export HOME=$NIX_BUILD_ROOT

      pushd maubot/management/frontend

        yarn config set yarn-offline-mirror $out
        yarn --frozen-lockfile --ignore-scripts --ignore-platform \
          --ignore-engines --no-progress --non-interactive

      popd
    '';

    outputHashMode = "recursive";
    outputHashAlgo = "sha256";
    outputHash = {
      x86_64-linux = "0000000000000000000000000000000000000000000000000000";
    }.${system} or (throw "Unsupported platform ${system}");
  };

  nativeBuildInputs = [ makeWrapper nodejs yarn ];

  configurePhase = ''
    # Yarn and bundler wants a real home directory to write cache, config, etc to
    export HOME=$NIX_BUILD_ROOT

    pushd maubot/management/frontend

      # Make yarn install packages from our offline cache, not the registry
      yarn config --offline set yarn-offline-mirror ${yarnCache}

    popd
  '';

  buildPhase = ''
    pushd maubot/management/frontend
      yarn install --production --offline --ignore-scripts --frozen-lockfile --no-progress --non-interactive

      patchShebangs node_modules/

      yarn build
    popd
  '';


  src = pkgs.fetchFromGitHub {
    owner = "maubot";
    repo = "maubot";
    rev = "a078bdd120908367923cf80445f267f165e89e12";
    sha256 = "1669iy01d59h33g3fz1190v6daldjzb1l9msyqmkdznw72q3vxc4";
  };

  patches = [ ./0001-Update-peer-dependencies.patch ];
}
