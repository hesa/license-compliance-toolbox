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

  outputs = { self, nixpkgs, ... }:
    let pkgs = import nixpkgs { system = "x86_64-linux"; };
    in {
      nixosModule = {
        config.environment.systemPackages =
          [ self.defaultPackage.x86_64-linux ];
      };

      packages.x86_64-linux = {
        ort = #pkgs.callPackage ./oss-review-toolkit-ort { };
            pkgs.writeScriptBin "ort.sh" (builtins.readFile ./oss-review-toolkit-ort/ort.sh);
        octrc = pkgs.writeScriptBin "octrc.sh" (builtins.readFile ./octrc/octrc.sh);

        scancode = pkgs.callPackage ./nexB-scancode-toolkit { };
        tern = pkgs.callPackage ./tern-tools-tern { };
        scanoss = pkgs.callPackage ./scanoss-scanner { };
        license-compliance-toolbox = pkgs.buildEnv {
          name = "license-compliance-toolbox";
          paths = with self.packages.x86_64-linux; [
            ort
            octrc
            scancode
            tern
            scanoss
            (pkgs.writeScriptBin "fossology.sh"
              (builtins.readFile ./fossology.sh))
            (pkgs.writeScriptBin "dependencytrac.sh"
              (builtins.readFile ./dependencytrac.sh))
          ];
        };
      };

      defaultPackage.x86_64-linux =
        self.packages.x86_64-linux.license-compliance-toolbox;
    };
}
