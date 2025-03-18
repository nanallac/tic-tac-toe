{
  stdenvNoCC,
  buildNpmPackage,
  clojure,
  clj-builder,
  mk-deps-cache
}:

let
  pname = "tic-tac-toe";
  version = "2025-03-17.0";

  src = ../.;

  deps-cache = mk-deps-cache {
    lockfile = src + "/deps-lock.json";
  };

  npmDeps = buildNpmPackage {
    pname = "${pname}_node-modules";
    inherit version src;

    npmDepsHash = "sha256-7d7vT6E3p/xH77LDVxRzlFaFCY6uXyVQDYgCRvGeumQ=";
    dontBuild = true;
    installPhase = ''
      runHook preInstall

      mkdir $out
      cp -R node_modules $out/

      runHook postInstall
    '';
  };
in

stdenvNoCC.mkDerivation {
  inherit pname version src;

  nativeBuildInputs = [
    clojure
    clj-builder
  ];

  preBuildPhase = ''
    clj-builder patch-git-sha "$(pwd)"
    cp -R ${npmDeps}/node_modules node_modules
  '';

  buildPhase = ''
    runHook preBuild

    export HOME="${deps-cache}"
    export JAVA_TOOL_OPTIONS="-Duser.home=${deps-cache}"
    export CLJ_CACHE="$TMPDIR/.clojure"
    mkdir -p "$CLJ_CACHE"

    clj -M -m shadow.cljs.devtools.cli release app

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/public
    cp -r ./resources/public/{index.html,styles.css} $out/public/
    cp -r ./resources/public/app-js $out/public/

    runHook postInstall
  '';
}
