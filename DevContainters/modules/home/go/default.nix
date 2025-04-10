{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Go development tools
    pkgs.go_1_23 # Go compiler and tools
    pkgs.gopls # Language server for Go
    pkgs.git # Version control
    pkgs.gotools # Additional Go tools
    pkgs.delve # Go debug tool
    pkgs.go-outline # Go code outline tool
  ];

  # Add environment variables
  home.sessionVariables = {
    GOPATH = "/go";
    PATH = "/go/bin:$PATH";
  };
}

