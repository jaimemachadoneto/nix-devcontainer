{
  description = "A DevContainer build with Home Manager";

  inputs = {
    # Default nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixos-unified.url = "github:srid/nixos-unified";

    # Software inputs
    # nix-index-database.url = "github:nix-community/nix-index-database";
    # nix-index-database.inputs.nixpkgs.follows = "nixpkgs";
    # nixvim.url = "github:nix-community/nixvim";
    # nixvim.inputs.nixpkgs.follows = "nixpkgs";
    # nixvim.inputs.flake-parts.follows = "flake-parts";
    nixos-vscode-server.flake = false;
    nixos-vscode-server.url = "github:nix-community/nixos-vscode-server";

  };

  # Wired using https://nixos-unified.org/autowiring.html
  outputs = inputs@{ self, nixpkgs, home-manager, ... }:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];
      imports = (with builtins;
        map
          (fn: ./modules/flake-parts/${fn})
          (attrNames (readDir ./modules/flake-parts)));

      perSystem = { lib, system, ... }: {
        _module.args.pkgs = import inputs.nixpkgs {
          inherit system;
          overlays = lib.attrValues self.overlays;
          config.allowUnfree = true;
        };
      };
    };
}
