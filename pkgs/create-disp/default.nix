{
  stdenv,
  fetchFromGitHub,
  callPackage,
  cmake,
  libdrm,
  pkg-config,
  systemd,
  nix-update-script,
}:
let
  libhybris = callPackage ../libhybris { };
in
stdenv.mkDerivation {
  pname = "create-disp";
  version = "0-unstable-2026-07-02";

  src = fetchFromGitHub {
    owner = "Linux-on-droid";
    repo = "create-disp";
    rev = "46c1d0414b3acb28b5902a2cb16b5ee40c1898ce";
    hash = "sha256-SqQb4o3wA2TdLb6M5G6qOgjne9lQ1DGw3spK4gRNTss=";
  };

  patches = [ ./0001-Improve-support-for-other-distros.patch ];

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    libdrm
    libhybris
    systemd
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
