{
  pkgs,
  lib,
  flake,
  fetchFromGitHub,
  stdenv,
  makeWrapper,
}:

stdenv.mkDerivation rec {
  pname = "clio";
  version = "20260704.1";

  src = fetchFromGitHub {
    owner = "SyntheticAutonomicMind";
    repo = "CLIO";
    tag = "${version}";
    hash = "sha256-g4Cn0bcbJ28GyWhKIjatFpacWI7+yaKyMgU+cYZBX/o=";
  };

  dontBuild = true;

  buildInputs = with pkgs; [
    perl
    git
    curl
    libtinfo
    unixtools.script
    gnutar
    coreutils
    bash
    which
    makeWrapper
  ];

  installPhase = ''
    patchShebangs .
    ./install.sh $out --symlink $out/bin/clio
    cp clio-container $out/bin
    cp check-deps $out/bin/clio-check-deps
    patchShebangs $out

    wrapProgram $out/bin/clio \
      --prefix PATH : ${lib.makeBinPath buildInputs}
    wrapProgram $out/bin/clio-container \
      --prefix PATH : ${lib.makeBinPath buildInputs}
    wrapProgram $out/bin/clio-check-deps \
      --prefix PATH : ${lib.makeBinPath buildInputs}
  '';

  passthru.category = "AI Coding Agents";

  meta = with lib; {
    description = "An AI-assisted coding agent that runs in your terminal and supports many providers and models.";
    homepage = "https://github.com/SyntheticAutonomicMind/CLIO/";
    changelog = "https://github.com/SyntheticAutonomicMind/CLIO/releases/tag/20260704.1";
    license = licenses.gpl3Only;
    sourceProvenance = with sourceTypes; [ fromSource ];
    maintainers = with flake.lib.maintainers; [ moonpiedumplings ];
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
    mainProgram = "clio";
  };
}
