{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  callPackage,
  file,
  libdrm,
  libgbm,
  libglvnd,
  libx11,
  libxcb,
  libxext,
  pkg-config,
  python3,
  wayland,
  wayland-protocols,
  wayland-scanner,
}:
let
  android-headers = callPackage ../android-headers { };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "libhybris";
  version = "0-unstable-2026-01-28";

  src = fetchFromGitHub {
    owner = "Linux-on-droid";
    repo = "libhybris";
    rev = "bba9553f39d1ca72e886ae7940adc0fc90f23329";
    hash = "sha256-vPWv0rfDdKnBMGEtzKnE7F4TWnv2no6veE58OkM60II=";
  };

  sourceRoot = "${finalAttrs.src.name}/hybris";

  outputs = [
    "out"
    "dev"
  ];

  patches = [
    ./Fix-gralloc-wrapper-include-file-installation.patch
    ./hybris-platforms-common-fix-include-dir-and-install-.patch
    ./glvnd-use-absolute-path.patch
  ];

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
    python3
    wayland-scanner
  ];

  buildInputs = [
    libdrm
    libgbm
    libglvnd
    libx11
    libxcb
    libxext
    wayland
    wayland-protocols
  ];

  propagatedBuildInputs = [ android-headers ];

  configureFlags = [
    "--enable-adreno-quirks"
    "--enable-arch=arm64"
    "--enable-clicd"
    "--enable-experimental"
    "--enable-glvnd"
    "--enable-lindroid-drm"
    "--enable-mali-quirks"
    "--enable-property-cache"
    "--enable-wayland"
  ];
})
