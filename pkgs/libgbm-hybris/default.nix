{
  stdenv,
  fetchFromGitHub,
  callPackage,
  cmake,
  libdrm,
  libgbm,
  pkg-config,
  nix-update-script,
}:
let
  libhybris = callPackage ../libhybris { };
in
stdenv.mkDerivation {
  pname = "libgbm-hybris";
  version = "0-unstable-2026-02-10";

  src = fetchFromGitHub {
    owner = "Linux-on-droid";
    repo = "libgbm-hybris";
    rev = "b6c79d66ce20e02a936b3f502db7694104fc7572";
    hash = "sha256-TDmEIimG2tetmr9z1IqWFkuQQplGr4l9IFNSQ/XyxjA=";
  };

  patches = [ ./use-pkg-config-to-find-headers.patch ];

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    libdrm
    libgbm
    libhybris
  ];

  passthru = {
    updateScript = nix-update-script {
      extraArgs = [
        "--flake"
        "--version"
        "branch=master"
        "--version-regex"
        "(0-unstable.*)"
      ];
    };
  };
}
