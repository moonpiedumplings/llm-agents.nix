{
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
in
stdenv.mkDerivation rec {
  pname = "umr-cli";
  inherit version;

  src = (fetchFromGitHub {
    owner = "EvanZhouDev";
    repo = "umr";
    rev = "998a4a9d251933a8c8df801396105f6f87c8e3b4";
    inherit hash;
  });
  packageJson = "${src}/package.json";

  nativeBuildInputs = [
    bun2nix.hook
    makeWrapper
  ];

  bunDeps = bun2nix.fetchBunDeps {
    bunNix = ./bun.nix;
    # overrides = {
    #     "umr-cli" = "${src}/apps/cli";
    #     "@umr/core" = "${src}/packages/core";
    # };
  };

  module = "${src}/apps/cli/index.ts";

  buildPhase = ''
    bun build apps/cli/src/cli.ts --compile --outfile umr
  '';

  installPhase = ''
    ls -la

    mkdir -p $out/bin
    cp umr $out/bin/
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
