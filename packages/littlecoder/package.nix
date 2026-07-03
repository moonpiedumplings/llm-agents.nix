{
  lib,
  buildNpmPackage,
  fetchurl,
  fd,
  ripgrep,
  runCommand,
  versionCheckHook,
  versionCheckHomeHook,
  importNpmLock,
}:

let
  versionData = lib.importJSON ./hashes.json;
  version = versionData.version;

  # Create a source with package-lock.json included
  srcWithLock = runCommand "pi-src-with-lock" { } ''
    mkdir -p $out
    tar -xzf ${
      fetchurl {
        url = "https://github.com/itayinbarr/little-coder/archive/refs/tags/v${version}.tar.gz";
        hash = versionData.sourceHash;
      }
    } -C $out --strip-components=1
    rm -f $out/npm-shrinkwrap.json
    cp ${./package-lock.json} $out/package-lock.json
  '';
in
buildNpmPackage {
  npmDepsFetcherVersion = 2;
  inherit version;
  pname = "littlecoder";

  src = srcWithLock;

  npmDeps = importNpmLock {
    npmRoot = srcWithLock;
    fetcherOpts = {
      # Pass 'curlOptsList' to 'pkgs.fetchurl' while fetching 'axios'
      "node_modules/axios" = {
        curlOptsList = [ "--verbose" ];
      };
    };
  };

  npmConfigHook = importNpmLock.npmConfigHook;
  npmDepsHash = versionData.npmDepsHash;
  makeCacheWritable = true;

  # The package from npm is already built
  #dontNpmBuild = true;

  # postInstall = ''
  #   wrapProgram $out/bin/pi \
  #     --prefix PATH : ${
  #       lib.makeBinPath [
  #         fd
  #         ripgrep
  #       ]
  #     } \
  #     --set PI_SKIP_VERSION_CHECK 1 \
  #     --set PI_TELEMETRY 0
  # '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [
    versionCheckHook
    versionCheckHomeHook
  ];

  passthru.category = "AI Coding Agents";

  meta = {
    description = "A terminal-based coding agent with multi-model support";
    homepage = "https://github.com/earendil-works/pi";
    changelog = "https://github.com/earendil-works/pi/releases";
    license = lib.licenses.mit;
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
    maintainers = with lib.maintainers; [ aos ];
    platforms = lib.platforms.all;
    mainProgram = "pi";
  };
}
