{
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  outputs = { nixpkgs, ... }@self: let
    supportedArchitectures = [
      "aarch64-darwin"
      "aarch64-linux"
      "x86_64-darwin"
      "x86_64-linux"
    ];
  in rec {
    packages = nixpkgs.lib.genAttrs supportedArchitectures (system: {
      nix_templater = nixpkgs.legacyPackages.${system}.callPackage ./pkgs/nix_templater {};
    });
    legacyPackages = nixpkgs.lib.genAttrs supportedArchitectures (system: import ./lib.nix {
      pkgs = nixpkgs.legacyPackages.${system};
      nix_templater = packages.${system}.nix_templater;
    });
    checks = nixpkgs.lib.genAttrs supportedArchitectures (system: {
      template = import ./tests/template.nix { inherit legacyPackages system nixpkgs; };
    });
  };
}
