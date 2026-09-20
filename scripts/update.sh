#!/usr/bin/env nix-shell
#!nix-shell -i bash -p git jq
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

arch=aarch64-linux
packages=$(nix eval --json ".#packages.$arch" --apply builtins.attrNames 2>/dev/null | jq -r '.[]')

for package in $packages; do
  if nix eval --json ".#packages.$arch.$package.updateScript" &>/dev/null; then
    echo "Updating:                  $package"
    $(nix build --no-link --print-out-paths --impure --expr '
      let
        flake = builtins.getFlake '\"$PWD\"';
      in
      with import flake.inputs.nixpkgs { };
      pkgs.writeScript "updateScript" (
        lib.escapeShellArgs (
          flake.packages.'$arch'.'$package'.updateScript ++ [ "packages.'$arch'.'$package'" ]
        )
      )
    ')
  else
    echo "Skipped (no updateScript): $package"
  fi
done
