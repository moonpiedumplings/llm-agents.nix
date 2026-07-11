{
  lib,
  buildNpmPackage,
  fetchurl,
  nodejs,
  runCommand,
  versionCheckHook,
  versionCheckHomeHook,
}:

let
  versionData = lib.importJSON ./hashes.json;
  version = versionData.version;
  # Create a source with package-lock.json included (npm tarball ships without one)
  srcWithLock = runCommand "zaly-src-with-lock" { } ''
    mkdir -p $out
    tar -xzf ${
      fetchurl {
        url = "https://registry.npmjs.org/@zaly/cli/-/cli-${version}.tgz";
        hash = versionData.sourceHash;
      }
    } -C $out --strip-components=1
    cp ${./package-lock.json} $out/package-lock.json
  '';
in
buildNpmPackage rec {
  npmDepsFetcherVersion = 2;
  inherit nodejs;
  pname = "zaly";
  inherit version;

  src = srcWithLock;

  npmDepsHash = versionData.npmDepsHash;

  npmInstallFlags = [ "--ignore-scripts" ];
  npmRebuildFlags = [ "--ignore-scripts" ];

  # The package from npm ships a prebuilt dist/
  dontNpmBuild = true;

  # Forcefully disable all scripts (the package has a postinstall script)
  NPM_CONFIG_IGNORE_SCRIPTS = "true";

  doInstallCheck = true;
  nativeInstallCheckInputs = [
    versionCheckHook
    versionCheckHomeHook
  ];

  passthru.category = "AI Coding Agents";

  meta = with lib; {
    description = "Hackable terminal coding agent";
    homepage = "https://github.com/folke/zaly";
    downloadPage = "https://www.npmjs.com/package/@zaly/cli";
    changelog = "https://github.com/folke/zaly/releases/tag/cli-v${version}";
    license = licenses.mit;
    sourceProvenance = with sourceTypes; [ binaryBytecode ];
    maintainers = with maintainers; [ sei40kr ];
    mainProgram = "zaly";
    platforms = platforms.all;
  };
}
