{
  flake.homeModules.bakkesmod-heroic =
    {
      lib,
      pkgs,
      config,
      ...
    }:

    let
      cfg = config.programs.bakkesmod.heroic;
    in
    {
      options.programs.bakkesmod.heroic = {
        enable = lib.mkEnableOption "Enable Heroic Launcher config integration for BakkesMod";
        gameId = lib.mkOption {
          type = lib.types.str;
          default = "Sugar";
          description = "The internal ID Heroic uses for Rocket League (usually 'Sugar')";
        };
        settings = lib.mkOption {
          type = lib.types.attrsOf lib.types.anything;
          default = { };
          description = "Additional settings to add to the Heroic config file for Rocket League";
        };
      };

      config = lib.mkIf (config.programs.bakkesmod.enable && cfg.enable) {
        home.activation.setupHeroicBakkes = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          CONFIG_FILE="${config.home.homeDirectory}/.config/heroic/GamesConfig/${cfg.gameId}.json"

          mkdir -p "$(dirname "$CONFIG_FILE")"
          PATCH_DATA='{"Sugar":${lib.toJSON cfg.settings}}'

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
