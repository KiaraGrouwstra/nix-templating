{
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  outputs = { nixpkgs, ... }: let
    supportedArchitectures = [
      "aarch64-darwin"
      "aarch64-linux"
      "x86_64-darwin"
      "x86_64-linux"
    ];
  in {
    packages = nixpkgs.lib.genAttrs supportedArchitectures (system: {
      nix_templater = nixpkgs.legacyPackages.${system}.callPackage ./pkgs/nix_templater {};
    });
    legacyPackages = nixpkgs.lib.genAttrs supportedArchitectures (system: import ./lib.nix { pkgs = nixpkgs.legacyPackages.${system}; });
  };
}
