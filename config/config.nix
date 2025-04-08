{ config, pkgs, ... }:
{
  # User-specific packages
  home.packages = [
    pkgs.any-nix-shell
    pkgs.bat
    pkgs.bat-extras.batman
    pkgs.curl
    pkgs.diff-so-fancy
    pkgs.direnv
    pkgs.fd
    pkgs.fzf
    pkgs.gawk
    pkgs.gh
    pkgs.gnused
    pkgs.jq
    pkgs.less
    pkgs.oh-my-zsh
    pkgs.pure-prompt
    pkgs.ripgrep
    pkgs.tldr


    # Go development tools
    pkgs.go_1_23 # Go compiler and tools
    pkgs.gopls # Language server for Go
    pkgs.gotools # Additional Go tools
    pkgs.delve

    # Node.js and npm
    pkgs.nodejs_18 # Node.js 18.x
    pkgs.nodePackages_18.npm # npm package manager

    # Java
    pkgs.jre # Java Runtime Environment

    # C++ development tools
    pkgs.gcc # GNU Compiler Collection
    pkgs.cmake # Build system
    pkgs.gnumake # Make build tool
    pkgs.gdb # GNU Debugger
    pkgs.lldb # LLVM debugger
    pkgs.clang-tools # Includes clangd language server
    pkgs.ninja # Fast build system
    pkgs.boost # Boost libraries
    pkgs.pkg-config # Helper tool for compiling applications
    pkgs.autoconf # Configure script builder
    pkgs.automake # Makefile generator
    # inputs.pkgsPkgSwig.swig4 # Interface compiler for connecting C/C++ with scripting languages
    pkgs.lcov # Code coverage reporting tool    
  ];

  # Enable home-manager
  programs.home-manager.enable = true;

  # Enable direnv with nix support
  programs.direnv = {
    enable = true;
    nix-direnv = {
      enable = true;
    };
  };

  # zsh configuration
  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    enableSyntaxHighlighting = true;
    oh-my-zsh = {
      enable = true;
      plugins = [
        "fzf"
        "gh"
        "git"
      ];
      theme = "";
    };

    plugins = [
      {
        name = "you-should-use";
        src = pkgs.fetchFromGitHub {
          owner = "MichaelAquilina";
          repo = "zsh-you-should-use";
          rev = "1.7.3";
          sha256 = "/uVFyplnlg9mETMi7myIndO6IG7Wr9M7xDFfY1pG5Lc=";
        };
      }
    ];

    shellAliases = {
      ".." = "cd ..";
      "..." = "cd ../..";
      cat = "bat --paging=never";
      grep = "rg";
      ll = "ls -la";
      man = "batman";
    };

    # Extra environment variables
    envExtra = ''
      # Load exports
      export FZF_DEFAULT_COMMAND='fd --type f'
      if [[ -f $HOME/.extra ]]; then
          source $HOME/.extra
      fi

      # Load shell.nix
      # Automatically enter nix-shell on shell startup
      if [ -f ~/.config/devcontainer/shell.nix ] && [ -z "$IN_NIX_SHELL" ]; then
        nix-shell ~/.config/devcontainer/shell.nix
      fi      
    '';

    # Extra content for .envrc
    initExtra = ''
      # Setup pure
      fpath+=${pkgs.pure-prompt}/share/zsh/site-functions
      autoload -U promptinit; promptinit
      prompt pure
      zstyle :prompt:pure:path color green

      # Configure any-nix-shell
      any-nix-shell zsh --info-right | source /dev/stdin

      # Show the message only once per shell session
      if [ -z "$DEV_ENV_LOADED" ]; then
        export DEV_ENV_LOADED=1
        echo "Development environment loaded."
        echo "Go $(go version) installed"
        echo "Node.js $(node --version) installed"
        echo "Java $(java -version 2>&1 | head -n 1) installed"
        echo "GCC $(gcc --version | head -n 1) installed"
        echo "Clang $(clang --version | head -n 1) installed"
        echo "$(swig -version | head -n 3) installed"
        echo "LCOV $(lcov --version) installed"
      fi

      export GOPATH=$HOME/go
      export GOPRIVATE="github.azc.ext.hp.com"
      export PATH=$GOPATH/bin:$PATH
    '';

    # Extra content for .envrc loaded before compinit()
    initExtraBeforeCompInit = ''
        '';
  };
}
