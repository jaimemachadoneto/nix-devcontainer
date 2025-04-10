{ flake, ... }:
final: prev: {
  swigFromPinned = (import
    (fetchTarball {
      url = "https://github.com/NixOS/nixpkgs/archive/05bbf675397d5366259409139039af8077d695ce.tar.gz";
      sha256 = "1r26vjqmzgphfnby5lkfihz6i3y70hq84bpkwd43qjjvgxkcyki0"; # Will be provided by Nix when you first build
    })
    {
      system = prev.system;
    }).swig;
}
