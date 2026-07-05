{
  lib,
  flake,
  python3,
  fetchFromGitHub,
  versionCheckHook,
  versionCheckHomeHook,
}:
let
  x = true;
  # pythonDeps =
  #   ps: with ps; [
  #     jupyter-core
  #     pyyaml
  #     nbformat
  #     nbclient
  #     ipykernel
  #     requests
  #   ];
  # pythonDist = (python3.withPackages pythonDeps);
in
python3.pkgs.buildPythonApplication rec {
  pname = "openlumara";
  version = "dev";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "Rose22";
    repo = "openlumara";
    rev = "b02aa01850c89ce852cac27071c7f78b45cc55cb";
    hash = "sha256-fp7dUHbbN/XHMDZ2VVyuvDx9OGkR8VhuVrh24tXGj+Y=";
  };

  patches = [
    #./pyproject.patch
    ./core_path.patch
  ];

  postUnpack = ''
    cp ${./pyproject.toml} source/pyproject.toml
  '';

  build-system = with python3.pkgs; [
    setuptools
  ];

  dependencies = with python3.pkgs; [
    openai
    tiktoken
    msgpack
    pyyaml
    json-repair
    python-ulid
    requests
    httpx
  ];

  doInstallCheck = true;

  # nativeInstallCheckInputs = [
  #   versionCheckHook
  #   versionCheckHomeHook
  # ];

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
