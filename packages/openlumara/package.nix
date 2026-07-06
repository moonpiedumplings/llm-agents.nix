{
  lib,
  flake,
  python3,
  fetchFromGitHub,
  versionCheckHook,
  versionCheckHomeHook,
  stdenv,
  runtimeShell,
  makeWrapper,
}:
let
  pythonDeps =
    ps: with ps; [
      openai
      tiktoken
      msgpack
      pyyaml
      json-repair
      python-ulid
      requests
      httpx
    ];
  pythonDist = (python3.withPackages pythonDeps);
in
stdenv.mkDerivation rec {
  pname = "openlumara";
  version = "dev";

  src = fetchFromGitHub {
    owner = "Rose22";
    repo = "openlumara";
    rev = "b02aa01850c89ce852cac27071c7f78b45cc55cb";
    hash = "sha256-fp7dUHbbN/XHMDZ2VVyuvDx9OGkR8VhuVrh24tXGj+Y=";
  };

  dontBuild = true;

  buildInputs = [ makeWrapper ];

  patches = [
    ./core_path.patch
  ];

  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/share/openlumara

    # Install the sources
    cp -r . $out/share/openlumara

    # Main executable
    makeWrapper ${pythonDist}/bin/python $out/bin/openlumara \
       --add-flags "$out/share/openlumara/main.py" \
       --run 'export PYTHONPATH="$HOME/.config/openlumara:$PYTHONPATH"'
  '';

  passthru.category = "AI Assistants";

  meta = with lib; {
    description = "A modular, token-efficient AI agent framework.";
    homepage = "https://github.com/Rose22/openlumara/";
    changelog = "https://github.com/Rose22/openlumara/commits/main/";
    license = licenses.gpl3Only;
    sourceProvenance = with sourceTypes; [ fromSource ];
    maintainers = with flake.lib.maintainers; [ moonpiedumplings ];
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
    mainProgram = "openlumara";
  };
}
