{ pkgs }:

{
  pkgs.callPackage ./from-git-source {
    mltonBootstrap = pkgs.callPackage ./mlton-binary.nix { };
    version = "20210117";
    rev = "on-20210117-release";
    sha256 = "sha256-rqL8lnzVVR+5Hc7sWXK8dCXN92dU76qSoii3/4StODM=";
  };
}
