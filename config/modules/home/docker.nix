{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Node.js and npm
    pkgs.docker-client # Docker client
    pkgs.docker-compose # Docker Compose
  ];
}
 
 