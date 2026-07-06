{
  pkgs,
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  runCommand,
  fetchurl,
}:

let
  versionData = lib.importJSON ./hashes.json;
  version = versionData.version;
  # Create a source with the vendored package-lock.json included
  srcWithLock = runCommand "dirac-src-with-lock" { } ''
    mkdir -p $out
    tar -xzf ${
      fetchurl {
        url = "https://github.com/dirac-run/dirac/archive/refs/tags/v${version}.tar.gz";
        hash = versionData.sourceHash;
      }
    } -C $out --strip-components=1
    cp ${./package-lock.json} $out/package-lock.json
  '';
in
buildNpmPackage (finalAttrs: {
  npmDepsFetcherVersion = 2;
  pname = "dirac";
  version = "0.4.13";

  src = srcWithLock;

  # src = fetchFromGitHub {
  #   owner = "dirac-run";
  #   repo = "dirac";
  #   tag = "v${finalAttrs.version}";
  #   hash = "sha256-CDIpWmIjcnBxPifmXfwrxOMN1WR4dC1dot2QimxDQK8=";
  # };
  #
  nativeBuildInputs = with pkgs; [
    protobuf
    grpc
  ];

  #npmDepsHash = versionData.npmDepsHash;
  npmDepsHash = "sha256-RQmyNPlA1oNqypprxGLaS4H96fEzJdsJ8XLHmnKfPvg=";
  npmRoot = ".";
  npmFlags = [
    "--workspaces"
    "--include-workspace-root"
    "--ignore-scripts"
  ];

  # npmBuildFlags = [
  #   "--workspace"
  #   "cli"
  # ];
  makeCacheWritable = true;

  passthru = {
    category = "AI Coding Agents";
  };

  meta = {
    description = "AI agent that brings the power of Gemini directly into your terminal";
    homepage = "https://github.com/dirac-run/dirac";
    changelog = "https://github.com/dirac-run/diracv${finalAttrs.version}";
    license = lib.licenses.asl20;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    platforms = lib.platforms.all;
    mainProgram = "gemini";
  };
})
