{ pkgs ? import <nixpkgs> { } }:

let

in

pkgs.mkShell {
  name = "Gravity";
  buildInputs = [

    pkgs.nixd
    pkgs.nix-output-monitor
    pkgs.nixpkgs-fmt
    pkgs.go-task

  ];
  hardeningDisable = [ "fortify" ];
  shellHook = ''
    echo "Development environment loaded."
  '';
}
