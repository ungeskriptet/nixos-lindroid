{ pkgs }:
{
  android-headers = pkgs.callPackage ./android-headers { };
  create-disp = pkgs.callPackage ./create-disp { };
  libgbm-hybris = pkgs.callPackage ./libgbm-hybris { };
  libhybris = pkgs.callPackage ./libhybris { };
  sddm-unwrapped = pkgs.kdePackages.callPackage ./sddm-unwrapped { };
}
