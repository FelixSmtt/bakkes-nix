{
  description = "A portable BakkesMod module for Heroic Launcher";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs, ... }:
    {
      homeModules.default = import ./bakkes.nix;
    };
}
