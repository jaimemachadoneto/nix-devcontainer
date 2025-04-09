{ flake, ... }:

let
  inherit (flake) inputs;
  inherit (inputs) self;
  packages = self + /packages;
in
self: super: {
  findin = self.callPackage "${packages}/findin" { };
  binocular-cli = self.callPackage "${packages}/binocular-cli" { };
}
