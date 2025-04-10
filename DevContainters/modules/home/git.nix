{ pkgs, flake, lib, ... }:
let
  # git commit --amend, but for older commits
  git-fixup = pkgs.writeShellScriptBin "git-fixup" ''
    rev="$(git rev-parse "$1")"
    git commit --fixup "$@"
    GIT_SEQUENCE_EDITOR=true git rebase -i --autostash --autosquash $rev^
  '';
  delta-toggle = pkgs.writeShellApplication {
    name = "delta-toggle";
    runtimeInputs = [ pkgs.delta ];
    text = builtins.readFile ./zsh/helpers/delta_toggle.sh;
  };

in
{
  home.packages = with pkgs; [
    git-filter-repo
    git-fixup
    delta-toggle
  ];

  home.shellAliases = {
    toggle-delta-l = "export DELTA_FEATURES=\${delta-toggle l}";
    toggle-delta-s = "export DELTA_FEATURES=\${delta-toggle s}";
    gcl = "git clone --recurse-submodules";
  };
  programs.git = {
    # difftastic.enable = true;
    enable = true;
    lfs.enable = true;

    delta = {
      #TODO: Take a look to toggle side-by-side: https://dandavison.github.io/delta/tips-and-tricks/toggling-delta-features.html
      enable = true;
      options = {
        decorations = {
          # commit-decoration-style = "bold yellow box ul";
          # file-decoration-style = "none";
          # file-style = "bold yellow ul";
          theme = "Dracula";
          # line-numbers = true;
          # side-by-side = true;
          hyperlinks = true;
          commit-decoration = true;
          # line-numbers-left-format = "";
          # line-numbers-right-format = "│ ";
        };
        features = "decorations";
        whitespace-error-style = "22 reverse";
        width = 100; # Automatically use full width
        max-line-length = 250; # Increase max line length for better side-by-side display
        navigate = true; # Enable hunk navigation with 'n' and 'N'

      };
    };

    aliases = {
      co = "checkout";
      ci = "commit";
      cia = "commit --amend";
      s = "status";
      st = "status";
      b = "branch";
      # p = "pull --rebase";
      pu = "push";
      p = "pull --ff-only";
      ff = "merge --ff-only";
      graph = "log --decorate --oneline --graph";
      pushall = "!git remote | xargs -L1 git push --all";
      add-nowhitespace = "!git diff -U0 -w --no-color | git apply --cached --ignore-whitespace --unidiff-zero -";
      lgb = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset%n' --abbrev-commit --date=relative --branches";
      lg1 = "log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)' --all";
      lg2 = "log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(reset) %C(bold green)(%ar)%C(reset)%C(bold yellow)%d%C(reset)%n''          %C(white)%s%C(reset) %C(dim white)- %an%C(reset)' --all";
      lg = "!\"git lg1\"";
      dt = "\"!f() { vim -p $(git diff --name-only) +\"tabdo Gdiff $@\" +tabfirst; }; f\"";
    };
    iniContent = {
      # Branch with most recent change comes first
      branch.sort = "-committerdate";
      # Remember and auto-resolve merge conflicts
      # https://git-scm.com/book/en/v2/Git-Tools-Rerere
      rerere.enabled = true;
    };
    ignores = [
      "*~"
      "*.swp"
      ".csvignore"
      # nix
      "*.drv"
      "result"
      # python
      "*.py?"
      "__pycache__/"
      ".venv/"
      # direnv
      ".direnv"
    ];
    extraConfig = {
      init.defaultBranch = "main"; # Undo breakage due to https://srid.ca/luxury-belief
      core.editor = "nvim";
      #protocol.keybase.allow = "always";
      credential.helper = "store --file ~/.git-credentials";
      pull.rebase = "false";
      user.signing.key = "BDFCAAEA65BD25AD";
      commit.gpgSign = lib.mkDefault false;
      #TODO: enable gpg signing
      # gpg.program = "${config.programs.gpg.package}/bin/gpg2";

      merge.conflictStyle = "zdiff3";
      commit.verbose = true;
      diff.algorithm = "histogram";
      log.date = "iso";
      column.ui = "auto";
      # Automatically track remote branch
      push.autoSetupRemote = true;
      # Reuse merge conflict fixes when rebasing
      rerere.enabled = true;
    };
  };

  programs.lazygit = {
    enable = true;
    settings = {
      gui = {
        scrollHeight = 2;
        scrollPastBottom = true;
        sidePanelWidth = 0.3333;
        expandFocusedSidePanel = false;
        mainPanelSplitMode = "flexible";
        language = "auto";
        timeFormat = "02 Jan 06 15:04 MST";
        theme = {
          lightTheme = false;
          activeBorderColor = [ "green" "bold" ];
          inactiveBorderColor = [ "white" ];
          optionsTextColor = [ "blue" ];
          selectedLineBgColor = [ "blue" ];
          selectedRangeBgColor = [ "blue" ];
          cherryPickedCommitBgColor = [ "cyan" ];
          cherryPickedCommitFgColor = [ "blue" ];
          unstagedChangesColor = [ "red" ];
        };
        commitLength = { show = true; };
        mouseEvents = true;
        skipDiscardChangeWarning = false;
        skipStashWarning = false;
        showFileTree = true;
        showListFooter = true;
        showRandomTip = true;
        showBottomLine = true;
        showCommandLog = true;
        showIcons = false;
        commandLogSize = 8;
        splitDiff = "auto";
      };
      git = {
        paging = {
          colorArg = "always";
          pager = "delta --syntax-theme \"Dracula\" --paging=never";
        };
        commit = { signOff = false; };
        merging = {
          manualCommit = false;
          args = "";
        };
        log = {
          order = "topo-order";
          showGraph = "when-maximised";
          showWholeGraph = false;
        };
        skipHookPrefix = "WIP";
        autoFetch = true;
        autoRefresh = true;
        branchLogCmd = "git log --graph --color=always --abbrev-commit --decorate --date=relative --pretty=medium {{branchName}} --";
        allBranchesLogCmd = "git log --graph --all --color=always --abbrev-commit --decorate --date=relative  --pretty=medium";
        overrideGpg = false;
        disableForcePushing = false;
        parseEmoji = false;
        diffContextSize = 3;
      };
      os = {
        editCommand = "";
        editCommandTemplate = "";
        openCommand = "";
      };
      refresher = {
        refreshInterval = 10;
        fetchInterval = 60;
      };
      update = {
        method = "prompt";
        days = 14;
      };
      reporting = "undetermined";
      confirmOnQuit = false;
      quitOnTopLevelReturn = false;
      disableStartupPopups = false;
      notARepository = "prompt";
      promptToReturnFromSubprocess = true;
      keybinding = {
        universal = {
          quit = "q";
          quit-alt1 = "<c-c>";
          return = "<esc>";
          quitWithoutChangingDirectory = "Q";
          togglePanel = "<tab>";
          prevItem = "<up>";
          nextItem = "<down>";
          prevItem-alt = "k";
          nextItem-alt = "j";
          prevPage = ",";
          nextPage = ".";
          gotoTop = "<";
          gotoBottom = ">";
          scrollLeft = "H";
          scrollRight = "L";
          prevBlock = "<left>";
          nextBlock = "<right>";
          prevBlock-alt = "h";
          nextBlock-alt = "l";
          jumpToBlock = [ "1" "2" "3" "4" "5" ];
          nextMatch = "n";
          prevMatch = "N";
          optionMenu = "x";
          optionMenu-alt1 = "?";
          select = "<space>";
          goInto = "<enter>";
          openRecentRepos = "<c-r>";
          confirm = "<enter>";
          confirm-alt1 = "y";
          remove = "d";
          new = "n";
          edit = "e";
          openFile = "o";
          scrollUpMain = "<pgup>";
          scrollDownMain = "<pgdown>";
          scrollUpMain-alt1 = "K";
          scrollDownMain-alt1 = "J";
          scrollUpMain-alt2 = "<c-u>";
          scrollDownMain-alt2 = "<c-d>";
          executeShellCommand = ":";
          createRebaseOptionsMenu = "m";
          pushFiles = "P";
          pullFiles = "p";
          refresh = "R";
          createPatchOptionsMenu = "<c-p>";
          nextTab = "]";
          prevTab = "[";
          nextScreenMode = "+";
          prevScreenMode = "_";
          undo = "z";
          redo = "<c-z>";
          filteringMenu = "<c-s>";
          diffingMenu = "W";
          diffingMenu-alt = "<c-e>";
          copyToClipboard = "<c-o>";
          submitEditorText = "<enter>";
          appendNewline = "<a-enter>";
          extrasMenu = "@";
          toggleWhitespaceInDiffView = "<c-w>";
          increaseContextInDiffView = "}";
          decreaseContextInDiffView = "{";
        };
        status = {
          checkForUpdate = "u";
          recentRepos = "<enter>";
        };
        files = {
          commitChanges = "c";
          commitChangesWithoutHook = "w";
          amendLastCommit = "A";
          commitChangesWithEditor = "C";
          ignoreFile = "i";
          refreshFiles = "r";
          stashAllChanges = "s";
          viewStashOptions = "S";
          toggleStagedAll = "a";
          viewResetOptions = "D";
          fetch = "f";
          toggleTreeView = "`";
        };
        branches = {
          createPullRequest = "o";
          viewPullRequestOptions = "O";
          checkoutBranchByName = "c";
          forceCheckoutBranch = "F";
          rebaseBranch = "r";
          renameBranch = "R";
          mergeIntoCurrentBranch = "M";
          viewGitFlowOptions = "i";
          fastForward = "f";
          pushTag = "P";
          setUpstream = "u";
          fetchRemote = "f";
        };
        commits = {
          squashDown = "s";
          renameCommit = "r";
          renameCommitWithEditor = "R";
          viewResetOptions = "g";
          markCommitAsFixup = "f";
          createFixupCommit = "F";
          squashAboveCommits = "S";
          moveDownCommit = "<c-j>";
          moveUpCommit = "<c-k>";
          amendToCommit = "A";
          pickCommit = "p";
          revertCommit = "t";
          cherryPickCopy = "c";
          cherryPickCopyRange = "C";
          pasteCommits = "v";
          tagCommit = "T";
          checkoutCommit = "<space>";
          resetCherryPick = "<c-R>";
          copyCommitMessageToClipboard = "<c-y>";
          openLogMenu = "<c-l>";
          viewBisectOptions = "b";
        };
        stash = { popStash = "g"; };
        commitFiles = { checkoutCommitFile = "c"; };
        main = {
          toggleDragSelect = "v";
          toggleDragSelect-alt = "V";
          toggleSelectHunk = "a";
          pickBothHunks = "b";
        };
        submodules = {
          init = "i";
          update = "u";
          bulkMenu = "b";
        };
      };
    };
  };
}
