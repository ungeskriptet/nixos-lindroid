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
  version = "0-unstable-2026-03-26";

  src = fetchFromGitHub {
    owner = "Linux-on-droid";
    repo = "libgbm-hybris";
    rev = "8172b8236438c54bee111f071d9f069ac5b229e9";
    hash = "sha256-99F73SC8Db75nUyKzMcdAZn8N3MKyi4v8h6lgfD1jas=";
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
