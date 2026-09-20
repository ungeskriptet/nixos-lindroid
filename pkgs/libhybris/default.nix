{
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  callPackage,
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
  nix-update-script,
}:
let
  android-headers = callPackage ../android-headers { };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "libhybris";
  version = "0-unstable-2026-07-02";

  src = fetchFromGitHub {
    owner = "Linux-on-droid";
    repo = "libhybris";
    rev = "c6a03429d12202f0b198d88140610a49ab73ddb0";
    hash = "sha256-K3OrXgH2iwkbk1hSwJuBizzEywgm1qrCNAr1tnJWanM=";
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

  passthru = {
    updateScript = nix-update-script {
      extraArgs = [
        "--flake"
        "--version"
        "branch=lindroid-drm"
        "--version-regex"
        "(0-unstable.*)"
      ];
    };
  };
})
