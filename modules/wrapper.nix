{ self, ... }:

{
  flake.homeModules.bakkesmod-wrapper =
    {
      lib,
      config,
      pkgs,
      ...
    }:

    let
      baseCfg = config.programs.bakkesmod.settings;
      cfg = config.programs.bakkesmod.wrapper;

      system = pkgs.stdenv.hostPlatform.system;

      launcher = self.packages.${system}.bakkesmod-launcher.override {
        winePrefix = baseCfg.prefixPath;
        wineBin = baseCfg.winePath;
      };
      wrapperScript = pkgs.writeShellScript "bakkesmod-wrapper" ''
        #!/usr/bin/env bash
        set -euo pipefail

        # Check if -noeac is present in the launch arguments
        has_noeac=false
        for arg in "$@"; do
          if [[ "$arg" == "-noeac" ]]; then
            has_noeac=true
            break
          fi
        done

        if [[ "$has_noeac" == "false" ]]; then
          exec "$@"
        else
          "$@" &
          GAME_PID=$!

          # Wait until RocketLeague.exe actually appears in the process list
          set +e
          while ! pgrep -f "RocketLeague.exe" > /dev/null; do
            sleep 1
          done
          set -e

          sleep 5
          "${lib.getExe launcher}" &

          # Keep the wrapper alive until Rocket League closes,
          wait "$GAME_PID" || true
        fi
      '';
    in
    {
      options.programs.bakkesmod.wrapper = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Enable BakkesMod heroic launcher wrapper";
        };
      };

      config = lib.mkIf (config.programs.bakkesmod.enable && cfg.enable) {
        programs.bakkesmod.heroic = {
          enable = true;
          settings = {
            wrapperOptions = [
              {
                exe = "${wrapperScript}";
                args = "";
              }
            ];
          };
        };
      };
    };
}
