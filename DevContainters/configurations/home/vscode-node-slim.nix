{ flake, pkgs, lib, config, ... }:
let
  inherit (flake) inputs;
  inherit (inputs) self;
in
{
  imports = [
    self.homeModules.node
    self.homeModules.vscode-server
    self.homeModules.gotask
  ];

  nixpkgs.config = { allowBroken = true; allowUnfree = true; };
  # To use the `nix` from `inputs.nixpkgs` on templates using the standalone `home-manager` template

  # `nix.package` is already set if on `NixOS` or `nix-darwin`.
  # TODO: Avoid setting `nix.package` in two places. Does https://github.com/juspay/nixos-unified-template/issues/93 help here?
  nix.package = lib.mkDefault pkgs.nix;
  nix.settings.auto-optimise-store = true;
  home.packages = [
    config.nix.package
  ];

  home.username = "vscode-go-slim";
  home.homeDirectory = lib.mkDefault "/${if pkgs.stdenv.isDarwin then "Users" else "home"}/vscode-go-slim";
  home.stateVersion = "24.11";

}
