{ config, pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./configuration.nix
  ];

  # This tells your Flake to use the specific unstable package stream
  nixpkgs.config.allowUnfree = true;
}
