{
  description = "A very basic flake";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";


  outputs = { self, nixpkgs }: {

    packages.x86_64-linux = import ./default.nix {
      pkgs = import nixpkgs { system = "x86_64-linux"; };

    };
    defaultPackage.x86_64-linux = self.packages.x86_64-linux.ort;
  };
}
