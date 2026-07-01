{
  pkgs,
  lib,
  flake,
  stdenv,
  bun2nix,
  bun,
  fetchFromGitHub,
  makeWrapper,
}:

let
  versionData = builtins.fromJSON (builtins.readFile ./hashes.json);
  inherit (versionData) version hash;
  pythonDeps =
    ps: with ps; [
      huggingface-hub
    ];
  pythonDist = (pkgs.python314.withPackages pythonDeps);
in
stdenv.mkDerivation rec {
  pname = "umr-cli";
  inherit version;

  src = (
    fetchFromGitHub {
      owner = "EvanZhouDev";
      repo = "umr";
      rev = "998a4a9d251933a8c8df801396105f6f87c8e3b4";
      inherit hash;
    }
  );

  patches = [
    ./env-python.patch
    ./symlink-fix.patch
  ];

  nativeBuildInputs = [
    bun2nix.hook
    makeWrapper
  ];

  propagatedBuildInputs = [
    pythonDist
  ];

  bunDeps = bun2nix.fetchBunDeps {
    bunNix = ./bun.nix;
    # overrides = {
    #     "umr-cli" = "${src}/apps/cli";
    #     "@umr/core" = "${src}/packages/core";
    # };
  };

  buildPhase = ''
    bun build --compile ./apps/cli/src/index.ts --outfile umr
  '';

  dontStrip = true;

  installPhase = ''
    mkdir -p $out/bin
    cp ./umr $out/bin/
  '';

  preFixup = ''
    wrapProgram $out/bin/umr \
          --set-default UMR_PYTHON ${lib.getExe pythonDist}
  '';

  passthru.category = "Workflow & Project Management";

  meta = with lib; {
    description = "";
    homepage = "https://github.com/EvanZhouDev/umr";
    changelog = "https://github.com/EvanZhouDev/umr";
    license = lib.licenses.agpl3Only;
    sourceProvenance = with sourceTypes; [ fromSource ];
    maintainers = with flake.lib.maintainers; [ afterthought ];
    mainProgram = "umr";
    platforms = platforms.unix;
  };
}
