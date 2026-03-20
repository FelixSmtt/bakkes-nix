{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.programs.bakkesmod;

  bakkes-bundle =
    let
      bakkes-bin = pkgs.stdenv.mkDerivation {
        pname = "bakkesmod-bin";
        version = "2.0.66";
        src = pkgs.fetchurl {
          url = "https://github.com/bakkesmodorg/BakkesModInjectorCpp/releases/download/2.0.66/BakkesMod.exe";
          sha256 = "1m5mlxy5fh2z2jk0lw49wbq712zfqqy9xx660pclfg258fzrfsvs";
        };
        dontUnpack = true;
        installPhase = ''
          mkdir -p $out
          cp $src $out/BakkesMod.exe
        '';
      };

      launch-script = pkgs.writeText "start-rl.bat" ''
        @echo off
        cd /d "Z:%STEAM_COMPAT_INSTALL_PATH%"
        start "" "Z:${bakkes-bin}/BakkesMod.exe"
        start "" "Binaries\Win64\RocketLeague.exe" %*
      '';
    in
    pkgs.symlinkJoin {
      name = "bakkesmod-bundle";
      paths = [ bakkes-bin ];
      postBuild = "cp ${launch-script} $out/start-rl.bat";
    };

in
{
  options.programs.bakkesmod = {
    enable = mkEnableOption "BakkesMod integration for Heroic Launcher";
    heroicGameId = mkOption {
      type = types.str;
      default = "Sugar";
      description = "The internal ID Heroic uses for Rocket League (usually 'Sugar')";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.jq ];

    home.activation.setupHeroicBakkes = hm.dag.entryAfter [ "writeBoundary" ] ''
      CONFIG_FILE="${config.home.homeDirectory}/.config/heroic/GamesConfig/${cfg.heroicGameId}.json"

      mkdir -p "$(dirname "$CONFIG_FILE")"
      PATCH_DATA='{"Sugar":{"targetExe": "${bakkes-bundle}/start-rl.bat"}}'

      if [ -f "$CONFIG_FILE" ]; then
        ${pkgs.jq}/bin/jq -s '.[0] * .[1]' "$CONFIG_FILE" <(echo "$PATCH_DATA") > "$CONFIG_FILE.tmp"
        mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
      else
        echo "$PATCH_DATA" > "$CONFIG_FILE"
      fi
      chmod 644 "$CONFIG_FILE"
    '';
  };
}
