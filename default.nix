let pkgs = import <nixpkgs> {};
    profiled = pkgs.haskellPackages.override {
      overrides = self: super: {
        mkDerivation = args: super.mkDerivation (args // {
          enableLibraryProfiling = true;
        });
      };
    };
    drv = profiled.callPackage ./spacecookie.nix { };
in if pkgs.lib.inNixShell then drv.env else drv
