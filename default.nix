{ config, lib, pkgs, ... }:

{
  ort = pkgs.callPackage ./oss-review-toolkit-ort {};
}
