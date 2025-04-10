{ inputs, ... }:
{
  perSystem = { pkgs, config, ... }: {
    devShells.default = pkgs.mkShell {
      name = "nixos-config-shell";
      meta.description = "Shell environment for modifying this Nix configuration";
      packages = with pkgs; [
        go-task
        nixd
        nix-output-monitor
        nixpkgs-fmt
        trunk-io
      ];
    };
  };
}
