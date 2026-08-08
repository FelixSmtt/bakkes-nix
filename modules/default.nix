{ self, inputs, ... }:

{
  flake.homeModules.default =
    {
      lib,
      ...
    }:

    {
      imports = [
        self.homeModules.bakkesmod-legacy
        self.homeModules.bakkesmod-launcher
      ];

      options.programs.bakkesmod = {
        enable = lib.mkEnableOption "BakkesMod integration for Heroic Launcher";
      };
    };

  imports = [
    inputs.home-manager.flakeModules.home-manager
  ];
}
