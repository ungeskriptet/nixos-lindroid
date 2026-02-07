{
  description = "NixOS configs for Lindroid";

  nixConfig = {
    extra-substituters = [ "https://nixos-lindroid.cachix.org" ];
    extra-trusted-public-keys = [
      "nixos-lindroid.cachix.org-1:g7SNpJopCJnBYVanvtT6WIBnuO9S9XipSUsR22/cFwI="
    ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { nixpkgs, self, ... }@inputs:
    let
      forAllSystems = nixpkgs.lib.genAttrs [
        "x86_64-linux"
        "aarch64-linux"
      ];
    in
    {
      nixosConfigurations.lindroid = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        system = "aarch64-linux";
        modules = [
          ./nixos
        ];
      };

      packages = forAllSystems (
        system: import ./pkgs/all-packages.nix { pkgs = nixpkgs.legacyPackages.${system}; }
      );

      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-tree);
    };
}
