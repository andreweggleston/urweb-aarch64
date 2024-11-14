{
  description = "urweb shell";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs =
    {
      self,
      nixpkgs,
      ...
    }@inputs:
    let
      inherit (self) outputs;
      forAllSystems = nixpkgs.lib.genAttrs [
        "aarch64-linux"
        "x86_64-linux"
      ];
    in
    {
      devShell = forAllSystems (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [
              (final: prev: {
                # mlton = pkgs.callPackage ./mlton/mlton-binary.nix { };
                mlton = pkgs.callPackage ./mlton/from-git-source.nix {
                  mltonBootstrap = pkgs.callPackage ./mlton/mlton-binary.nix { };
                  version = "20210117";
                  rev = "on-20210117-release";
                  sha256 = "sha256-rqL8lnzVVR+5Hc7sWXK8dCXN92dU76qSoii3/4StODM=";
                };
              })
            ];
          };
        in
        pkgs.mkShell {
          nativeBuildInputs = with pkgs; [
            urweb
            mlton
            gmp
          ];
          buildInputs = with pkgs; [
            gmp
          ];
          shellHook = ''
            export PATH=${pkgs.mlton}/bin:$PATH
          '';
        }
      );
    };
}
