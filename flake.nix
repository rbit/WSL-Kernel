{
  description = "WSL2 kernel package";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    flake-utils.url = "github:numtide/flake-utils";
    wsl-linux = {
      url = "github:microsoft/WSL2-Linux-Kernel";
      flake = false;
    };
  };

  outputs =
    { self, nixpkgs, flake-utils, wsl-linux }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages.default = pkgs.stdenv.mkDerivation {
          pname = "wsl-kernel";
          version = "0.1";
          src = wsl-linux;
          nativeBuildInputs = with pkgs; [
            perl
            bc
            nettools
            openssl
            rsync
            gmp
            libmpc
            mpfr
            zstd
            python3Minimal
            kmod
            ubootTools
            bison
            flex
            cpio
            pahole
            zlib
            elfutils
          ];
          patches = [ ./config-wsl.patch ];
          prePatch = ''
            mv Microsoft/config-wsl Microsoft/config-wsl.nosym
            cp Microsoft/config-wsl.nosym Microsoft/config-wsl
            rm Microsoft/config-wsl.nosym
          '';
          preBuild = "patchShebangs .";
          enableParallelBuilding = true;
          makeFlags = [ "KCONFIG_CONFIG=Microsoft/config-wsl" ];
          installPhase = ''
            mkdir -p $out/bin
            mkdir -p $out/lib/tmpfiles.d
            kvers=`make kernelversion`
            cp arch/x86/boot/bzImage $out/bin/bzImage-$kvers
            echo "C+  /mnt/c/Users/ray/Machines/kernels/bzImage-$kvers  -  -  -  -  $out/bin/bzImage-$kvers" > $out/lib/tmpfiles.d/krnl.conf
            echo "L+  /mnt/c/Users/ray/Machines/kernels/bzImage-latest  -  -  -  -  /mnt/c/Users/ray/Machines/kernels/bzImage-$kvers" >> $out/lib/tmpfiles.d/krnl.conf
          '';
          dontFixup = true;
        };
      });
}
