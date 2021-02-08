{
  description = "license-compliance-toolbox flake";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    ort = {
      url = "github:oss-review-toolkit/ort";
      flake = false;
    };
  };

  outputs = { self, nixpkgs , ... }: let
    pkgs = import nixpkgs { system = "x86_64-linux"; };
  in {

    packages.x86_64-linux.ort = pkgs.callPackage ./oss-review-toolkit-ort {};
    packages.x86_64-linux.scancode = pkgs.callPackage ./nexB-scancode-toolkit {};

    packages.x86_64-linux.license-compliance-toolbox = pkgs.buildEnv {
      name = "license-compliance-toolbox";
      paths = with self.packages.x86_64-linux; [
        ort
        scancode
        # (pkgs.writeScriptBin "ort.sh" (builtins.readFile ./ort.sh))
        # (pkgs.writeScriptBin "scancode.sh" (builtins.readFile ./scancode.sh))
      ];
    };

    defaultPackage.x86_64-linux = self.packages.x86_64-linux.license-compliance-toolbox;
  };
}
