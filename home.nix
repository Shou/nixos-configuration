{ ... }:

let
  sources = import ./nix/sources.nix;
  stable = import sources.nixpkgs {};
  pkgs = import sources.unstable {};
  lib = pkgs.lib;

in {
  programs.home-manager.enable = true;

  home.packages = (with pkgs; [
    spotify hexchat xsel firefox-bin killall pulseeffects
    xlibs.xkill
    haskellPackages.haskell-language-server # actually this does work (with stack)
  ]);

  programs.fish = {
    enable = true;

    interactiveShellInit = ''
      set -gx PATH ~/.npm-packages/bin $PATH
      set -gx EDITOR nvim
    '';

    shellAliases = {
      tmux = "direnv exec / tmux";
    };

    functions = {
      nixcmd = {
        body = ''nix run nixpkgs."$argv[1]" -c $argv[1..-1]'';
      };
    };
  };

  programs.bash = {
    # TODO enable this on peril
    enable = lib.mkDefault false;
    # :trollface:
    initExtra =
      let fish = "${pkgs.fish}/bin/fish";
      in "exec env SHELL=${fish} ${fish}";
    profileExtra = ''
      . ~/.nix-profile/etc/profile.d/nix.sh
    '';
  };

  services.lorri.enable = true;
  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    enableFishIntegration = true;
  };

  programs.starship = {
    enable = true;
    enableFishIntegration = true;

    settings = {
      character.symbol = "➜";
    };
  };

  programs.ssh = {
    # We don't want to manage this because it's PRIVATE!!!
    enable = false;
  };

  programs.git = {
    enable = true;
    lfs.enable = true;
    userName = "Benedict Aas";

    aliases = {
      diff = "diff --word-diff";
    };
    extraConfig = {
      merge = {
        tool = "vimdiff";
      };
      mergetool = {
        prompt = true;
        vimdiff = {
          cmd = ''
            nvim -d ''$LOCAL ''$MERGED ''$BASE ''$REMOTE -c 'wincmd w' -c 'wincmd J'
          '';
        };
      };
      diff = {
        tool = "vimdiff";
      };
    };
  };

  programs.tmux = {
    enable = true;
    historyLimit = 10000;
    shortcut = "x";
    escapeTime = 0;

    extraConfig = builtins.readFile ./config/tmux.conf;
  };

  programs.neovim = rec {
    enable = true;

    withNodeJs = true;
    withPython3 = true;

    plugins = (with pkgs.vimPlugins; [
      vim-colorschemes
      coc-nvim
      neomake
      haskell-vim
      ghcid
      purescript-vim
      psc-ide-vim
      vim-nix
      dhall-vim
      typescript-vim
      vim-signify
      fzf-vim
      vim-jsx-pretty
      yats-vim
      tsuquyomi
      rust-vim
      coc-json
      coc-tsserver
      coc-yaml
      coc-fzf
    ]);

    extraConfig = builtins.readFile ./config/nvim/init.vim;
  };

  home.file."coc-settings" = {
    source = ./config/nvim/coc-settings.json;
    target = ".config/nvim/coc-settings.json";
  };

  dconf.settings = {
    "org/gnome/desktop/wm/keybindings" = {
      "switch-to-workspace-up" = ["<Super>k"];
      "switch-to-workspace-down" = ["<Super>j"];
      "switch-to-workspace-1" = ["<Super>1"];
      "switch-to-workspace-2" = ["<Super>2"];
      "switch-to-workspace-3" = ["<Super>3"];
      "switch-to-workspace-4" = ["<Super>4"];
      "switch-to-workspace-5" = ["<Super>5"];
      "switch-to-workspace-6" = ["<Super>6"];
      "switch-to-workspace-7" = ["<Super>7"];
      "switch-to-workspace-8" = ["<Super>8"];
      "switch-to-workspace-9" = ["<Super>9"];
      "switch-to-workspace-10"  = ["<Super>0"];

      "move-to-workspace-up" = ["<Super><Shift>k"];
      "move-to-workspace-down" = ["<Super><Shift>j"];
      "move-to-workspace-1" = ["<Super><Shift>1"];
      "move-to-workspace-2" = ["<Super><Shift>2"];
      "move-to-workspace-3" = ["<Super><Shift>3"];
      "move-to-workspace-4" = ["<Super><Shift>4"];
      "move-to-workspace-5" = ["<Super><Shift>5"];
      "move-to-workspace-6" = ["<Super><Shift>6"];
      "move-to-workspace-7" = ["<Super><Shift>7"];
      "move-to-workspace-8" = ["<Super><Shift>8"];
      "move-to-workspace-9" = ["<Super><Shift>9"];
      "move-to-workspace-10" = ["<Super><Shift>0"];

      "close" = ["<Super>c"];
      "toggle-fullscreen" = ["<Super>f"];
      "toggle-maximized" = ["<Super>t"];
    };

    "desktop/ibus/general".preload-engines = [ "mozc-jp" "xkb:us:altgr-intl:eng" ];

    "org/gnome/mutter/keybindings" = {
      "toggle-tiled-left" = ["<Super>comma"];
      "toggle-tiled-right" = ["<Super>period"];
      "switch-monitor" = [];
    };
    "org/gnome/settings-daemon/plugins/media-keys".video-out = [];

    "org/gnome/shell/app-switcher" = {
      "current-workspace-only" = true;
    };

    # no thanks; remove all of these
    "org/gnome/shell/keybindings" = {
      "switch-to-application-1" = [];
      "switch-to-application-2" = [];
      "switch-to-application-3" = [];
      "switch-to-application-4" = [];
      "switch-to-application-5" = [];
      "switch-to-application-6" = [];
      "switch-to-application-7" = [];
      "switch-to-application-8" = [];
      "switch-to-application-9" = [];
      "switch-to-application-10"  = [];
    };

    "org/gnome/desktop/interface" = {
      "clock-show-seconds" = true;
      "clock-show-date" = true;
      "clock-show-weekday" = true;
    };

    "org/gnome/desktop/calendar".show-weekdate = true;

    "org/gnome/desktop/wm/preferences".resize-with-right-button = true;

    # There is an option under packages.gnome-terminal.showMenubar for
    # this but it doesn't work????
    "org/gnome/terminal/legacy".default-show-menubar = false;

    # beeg thumbnail limit (30MB)
    "org/gnome/nautilus/preferences".thumbnail-limit = ''"30000000"'';
  };

  gtk = {
    enable = true;
    iconTheme = {
      name = "Adwaita";
      package = pkgs.gnome3.adwaita-icon-theme;
    };
    theme = {
      name = "Adwaita-dark";
    };
  };
  qt = {
    enable = true;
    platformTheme = "gtk";
  };

  # Enable Bluetooth media controls through Mpris
  systemd.user.services.mpris-proxy = {
    Unit.Description = "Mpris proxy";
    Unit.After = [ "network.target" "sound.target" ];
    Service.ExecStart = "${pkgs.bluez}/bin/mpris-proxy";
    Install.WantedBy = [ "default.target" ];
  };

  home.stateVersion = "20.03";
}
