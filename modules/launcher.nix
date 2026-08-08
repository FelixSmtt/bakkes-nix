{ self, ... }:

{
  flake.homeModules.bakkesmod-launcher =
    {
      lib,
      config,
      pkgs,
      ...
    }:

    let
      cfg = config.programs.bakkesmod.launcher;

      system = pkgs.stdenv.hostPlatform.system;
    in
    {
      options.programs.bakkesmod.launcher = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Enable BakkesMod launcher";
        };
        prefixPath = lib.mkOption {
          type = lib.types.str;
          default = "$HOME/Games/Heroic/Prefixes/default";
          description = "Path to the Wine prefix used by Heroic Launcher";
        };
        winePath = lib.mkOption {
          type = lib.types.str;
          default = "$HOME/.local/share/Steam/compatibilitytools.d/GE-Proton-latest/files/bin/wine";
          description = "Path to the Wine binary used by Heroic Launcher";
        };
      };

      config = lib.mkIf (config.programs.bakkesmod.enable && cfg.enable) (
        let
          launcher = self.packages.${system}.bakkesmod-launcher.override {
            winePrefix = cfg.prefixPath;
            wineBin = cfg.winePath;
          };
        in
        {
          home.packages = [ launcher ];

          xdg.desktopEntries.bakkesmod-launcher = {
            name = "BakkesMod Launcher";
            comment = "Launch BakkesMod for Rocket League";
            exec = "${launcher}/bin/bakkesmod";
            categories = [
              "Game"
              "Utility"
            ];
            terminal = false;
          };
        }
      );
    };
}
