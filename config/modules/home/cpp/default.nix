{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # C++ development tools
    pkgs.gcc # GNU Compiler Collection
    pkgs.cmake # Build system
    pkgs.gnumake # Make build tool
    pkgs.gdb # GNU Debugger
    pkgs.lldb # LLVM debugger
    pkgs.clang-tools # Includes clangd language server
    pkgs.ninja # Fast build system
    pkgs.pkg-config # Helper tool for compiling applications
    pkgs.autoconf # Configure script builder
    pkgs.automake # Makefile generator
    pkgs.lcov # Code coverage reporting tool

    # Package from the specific version of nixpkgs
    swigFromPinned # Interface compiler for connecting C/C++ with scripting languages
  ];
}
 
 