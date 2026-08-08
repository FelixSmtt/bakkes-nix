{ inputs, ... }:

{
  perSystem =
    {
      self',
      system,
      lib,
      ...
    }:

    let
      pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfreePredicate =
          pkg:
          builtins.elem (lib.getName pkg) [
            "steam-unwrapped"
          ];
      };

      steamRunNoTmpfs = pkgs.stdenv.mkDerivation {
        pname = "steam-run-notmpfs";
        version = pkgs.steam-run.version;
        src = pkgs.steam-run;
        nativeBuildInputs = [ pkgs.makeWrapper ];

        installPhase = ''
          runHook preInstall

          mkdir -p $out/bin

          cat ${pkgs.steam-run}/bin/steam-run > $out/bin/steam-run-notmpfs
          chmod +w $out/bin/steam-run-notmpfs

          substituteInPlace $out/bin/steam-run-notmpfs \
          --replace-fail "--bind-try /tmp/dumps /tmp/dumps" "--bind-try /tmp/dumps /tmp/dumps --bind-try /tmp/.wine-$(id -u) /tmp/.wine-$(id -u)"

          chmod +x $out/bin/steam-run-notmpfs

          runHook postInstall
        '';
      };

      mkLauncher =
        {
          winePrefix ? "$HOME/Games/Heroic/Prefixes/default",
          wineBin ? "$HOME/.local/share/Steam/compatibilitytools.d/GE-Proton-latest/files/bin/wine",
        }:

        pkgs.writeShellScriptBin "bakkesmod" ''
          WINE_BIN="${wineBin}"
          WINE_PREFIX="${winePrefix}"
          TARGET_EXE="${self'.packages.bakkesmod-bin}/BakkesMod.exe"

          export WINEPREFIX="$WINE_PREFIX"
          export PROTONPATH="$WINE_BIN"
          export PROTON_VERB="runinprefix"
          export STEAM_COMPAT_DATA_PATH="$WINE_PREFIX"

          exec ${steamRunNoTmpfs}/bin/steam-run-notmpfs "$WINE_BIN" "$TARGET_EXE"
        '';
    in
    {
      packages.bakkesmod-launcher = pkgs.lib.makeOverridable mkLauncher { };
    };
}
