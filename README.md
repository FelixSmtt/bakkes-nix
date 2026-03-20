# bakkes-nix

A portable, togglable NixOS Home Manager module to automatically inject BakkesMod into Rocket League when launched via the Heroic Games Launcher.

## Description

On Linux, running BakkesMod usually requires manual setup, shared Wine prefixes, and custom launch scripts. This flake automates that process by:

1. Fetching the latest BakkesMod injector.

2. Generating a Wine-compatible .bat entry point that respects your Nix store paths.

3. Patching your Heroic Sugar.json (or custom ID) configuration to use the "Alternative EXE" feature while keeping the file writable by the launcher.

## Usage

Add this flake to your `flake.nix` inputs:

```nix
{
  inputs.bakkesmod.url = "github:FelixSmtt/bakkes-nix";

  outputs = { nixpkgs, home-manager, bakkesmod, ... }: {
    homeConfigurations."your-user" = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      modules = [
        ./home.nix
        bakkesmod.homeModules.default
      ];
    };
  };
}
```

Enable the module in your `home.nix`:

```nix
{ config, pkgs, ... }:

{
    programs.bakkesmod.enable = true;

    # Optional: Heroic uses "Sugar" for the Epic Games version of Rocket League.
    # Change this if your internal ID is different (check ~/.config/heroic/GamesConfig/)
    # programs.bakkesmod.heroicGameId = "Sugar";
}
```

During first start in BakkesMod needs to download the actual BakkeMod files into the prefix. This might not happen automatically. Press "Reinstall BakkesMod" in the BakkesMod Injector to trigger the download.

## How it Works

The module creates a Nix Store Bundle containing the BakkesMod executable and a Windows Batch script.

When you click "Play" in Heroic, it executes the .bat file. The script uses the STEAM_COMPAT_INSTALL_PATH environment variable provided by Heroic to cd into the correct game directory and launch both the injector and the game binary simultaneously and in the same Wine Session.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Credits

- [BakkesMod](https://www.bakkesmod.com/) - The modding framework for Rocket League.
- [BakkesLinux](https://github.com/CrumblyLiquid/BakkesLinux) - Guide for running BakkesMod on Linux.
