{
  perSystem = { pkgs, ... }: {
    packages.bakkesmod-bin = pkgs.stdenv.mkDerivation {
      pname = "bakkesmod-bin";
      version = "2.0.72";
      src = pkgs.fetchurl {
        url = "https://github.com/bakkesmodorg/BakkesModInjectorCpp/releases/download/2.0.72/BakkesMod.exe";
        sha256 = "sha256-TjQrECyzNNtzhrqbn8bFihxNi5OBHaeF0JI/CuPOet4=";
      };
      dontUnpack = true;
      installPhase = ''
        mkdir -p $out
        cp $src $out/BakkesMod.exe
      '';
    };
  };
}
