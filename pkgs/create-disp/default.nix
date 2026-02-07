{
  lib,
  stdenv,
  fetchFromGitHub,
  callPackage,
  cmake,
  libdrm,
  pkg-config,
  systemd,
}:
let
  libhybris = callPackage ../libhybris { };
in
stdenv.mkDerivation {
  pname = "create-disp";
  version = "0-unstable-2025-01-28";

  src = fetchFromGitHub {
    owner = "Linux-on-droid";
    repo = "create-disp";
    rev = "a97aa3edce8807c39bd00cdf072a24717152a1fb";
    hash = "sha256-xeShqgutbo5n/rbmuDi9HN5e3w9eY8iyixIiuEAZf4A=";
  };

  patches = [ ./improve-support-for-other-distros.patch ];

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    libdrm
    libhybris
    systemd
  ];
}
