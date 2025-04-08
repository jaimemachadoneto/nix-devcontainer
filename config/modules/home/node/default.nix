{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Node.js and npm
    pkgs.nodejs_18 # Node.js 18.x
  ];
}
 
 