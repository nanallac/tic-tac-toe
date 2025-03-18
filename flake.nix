{
  description = "replicant/tic-tac-toe";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    clj-nix.url = "github:jlesquembre/clj-nix";
  };

  outputs = { self, nixpkgs, clj-nix, ... }@inputs:
    let
      system = "x86_64-linux";

      pkgs = import nixpkgs {
        inherit system;
        overlays = [ clj-nix.overlays.default ];
      };
    in {

      packages.${system}.default = pkgs.callPackage ./pkgs/default.nix {};

      devShells.${system}.default = pkgs.mkShellNoCC {
        packages = [
          pkgs.figlet
          pkgs.lolcat
          pkgs.clojure
          pkgs.nodejs_23
        ];
        shellHook = ''
          echo "Welcome to tic-tac-toe dev environment" | figlet | lolcat
        '';
      };
    };
}
