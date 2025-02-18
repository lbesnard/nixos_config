{ config, pkgs, ... }:

{
  boot.kernelPackages = pkgs.linuxPackages_latest.extend (self: super: {
    ipu6-drivers = super.ipu6-drivers.overrideAttrs (final: previous: rec {
      src = builtins.fetchGit {
        url = "https://github.com/intel/ipu6-drivers.git";
        ref = "master";
        rev = "b4ba63df5922150ec14ef7f202b3589896e0301a";
      };
      patches = [
        "${src}/patches/0001-v6.10-IPU6-headers-used-by-PSYS.patch"
      ];
    });
  });

  # Other config options...
}
