{
  description = "license-compliance-toolbox flake";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = { self, nixpkgs }: let
    pkgs = import nixpkgs { system = "x86_64-linux"; };
  in {

    packages.x86_64-linux.ort = pkgs.callPackage ./oss-review-toolkit-ort {};
    packages.x86_64-linux.license-compliance-toolbox = pkgs.buildEnv {
      name = "license-compliance-toolbox";
      paths = with self.packages.x86_64-linux; [ ort ];
    };

    defaultPackage.x86_64-linux = self.packages.x86_64-linux.license-compliance-toolbox;

  };
}
