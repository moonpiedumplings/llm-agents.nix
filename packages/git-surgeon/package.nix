{
  lib,
  fetchFromGitHub,
  rustPlatform,
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "git-surgeon";
  version = "0.1.15";

  src = fetchFromGitHub {
    owner = "raine";
    repo = "git-surgeon";
    tag = "v${finalAttrs.version}";
    hash = "sha256-e/s24yyJnxs7vwDCRPTV60rUkPq2pwZil4UjsPKfbGI=";
  };

  cargoHash = "sha256-UIK5dsVacUSioBwVvGsLWh+V+XkMw9d7saYsYmCW4Ps=";

  postInstall = ''
    install -d $out/share/git-surgeon
    cp -r skills $out/share/git-surgeon/skills
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  passthru.category = "Utilities";

  meta = {
    description = "Git primitives for autonomous coding agents";
    longDescription = ''
      git-surgeon gives AI agents surgical control over git changes without
      interactive prompts. Stage, unstage, or discard individual hunks. Commit
      hunks directly with line-range precision. Restructure history by
      splitting commits or folding fixes into earlier ones.
    '';
    homepage = "https://github.com/raine/git-surgeon";
    changelog = "https://github.com/raine/git-surgeon/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;
    mainProgram = "git-surgeon";
    maintainers = with lib.maintainers; [ sei40kr ];
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    platforms = lib.platforms.unix;
  };
})
