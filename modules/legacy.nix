{ self, ... }:

{
  flake.homeModules.bakkesmod-legacy =
    {
      lib,
      pkgs,
      config,
      ...
    }:

    let
      cfg = config.programs.bakkesmod.batchScript;

      system = pkgs.lib.systems.hostPlatform.system;

      legacyLaunchScript = pkgs.writeText "start-rl.bat" ''
        @echo off
        cd /d "Z:%STEAM_COMPAT_INSTALL_PATH%"
        start "" "Z:${self.packages.${system}.bakkesmod-bin}/BakkesMod.exe"
        start "" "Binaries\Win64\RocketLeague.exe" %*
      '';
    in
    {
      options.programs.bakkesmod.batchScript = {
        enable = lib.mkEnableOption "Enable legacy batch script for BakkesMod integration with Heroic Launcher (Breaks Anti Cheat)";
        heroicGameId = lib.mkOption {
          type = lib.types.str;
          default = "Sugar";
          description = "The internal ID Heroic uses for Rocket League (usually 'Sugar')";
        };
      };

      config = lib.mkIf (config.programs.bakkesmod.enable && cfg.enable) {
        home.packages = [ pkgs.jq ];

        home.activation.setupHeroicBakkes = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          CONFIG_FILE="${config.home.homeDirectory}/.config/heroic/GamesConfig/${cfg.heroicGameId}.json"

          mkdir -p "$(dirname "$CONFIG_FILE")"
          PATCH_DATA='{"Sugar":{"targetExe": "${legacyLaunchScript}"}}'

          if [ -f "$CONFIG_FILE" ]; then
            ${pkgs.jq}/bin/jq -s '.[0] * .[1]' "$CONFIG_FILE" <(echo "$PATCH_DATA") > "$CONFIG_FILE.tmp"
            mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
          else
            echo "$PATCH_DATA" > "$CONFIG_FILE"
          fi
          chmod 644 "$CONFIG_FILE"
        '';
      };
    };

}
