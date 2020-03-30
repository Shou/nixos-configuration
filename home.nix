{ pkgs, ... }:

{
  programs.home-manager.enable = true;

  home.packages = (with pkgs; [
    google-chrome spotify hexchat xsel
  ]);

  programs.fish = {
    enable = true;

    interactiveShellInit = ''
      set -gx PATH ~/.npm-packages/bin $PATH
      set -gx EDITOR nvim
    '';
  };

  programs.bash = {
    enable = true;
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

    extraConfig = ''
# mouse support
set -g mouse on

# split vertically
bind-key | split-window -h
# split horizontally
bind-key - split-window -v

# make it hjkl instead of left,down,up,right to switch between split panes
unbind Down
bind-key -r j select-pane -D
unbind Up
bind-key -r k select-pane -U
unbind Left
bind-key -r h select-pane -L
unbind Right
bind-key -r l select-pane -R

# Same as above except for resizing panes and not moving between them
unbind M-down
bind-key -r M-j resize-pane -D 5
unbind M-Up
bind-key -r M-k resize-pane -U 5
unbind M-Left
bind-key -r M-h resize-pane -L 5
unbind M-Right
bind-key -r M-l resize-pane -R 5

# Turn off status bar
set -g status off

# Turn on window titles, so that it's titled `vim', `weechat', etc
set -g set-titles on
set -g set-titles-string '#W'
set-window-option -g automatic-rename on
    '';
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
    ]);

    extraConfig =
      let
        loadPlugin = plugin: ''
            set rtp^=${plugin.rtp}
            set rtp+=${plugin.rtp}/after
          '';

      in ''
" https://github.com/NixOS/nixpkgs/issues/39364#issuecomment-425536054
filetype off | syn off
${builtins.concatStringsSep "\n" (map loadPlugin plugins)}
filetype indent plugin on | syn on
set shell=/bin/sh

syntax on
" Keep ExtraWhitespace highlight groups
autocmd ColorScheme * highlight ExtraWhitespace ctermbg=red guibg=red
autocmd ColorScheme * highlight CocUnderline cterm=underline ctermbg=lightred

" Bright summer theme for happy summer days *unsheathes ice cold coke can*
" color Tomorrow
" Make the highlight a softer gray
" hi CursorColumn ctermbg=255
" hi CursorLine ctermbg=255

" Dark winter theme like my soul *unsheathes blade*
color alduin
" Make cursor line/column less bright with alduin
hi CursorLine ctermbg=237
hi CursorColumn ctermbg=237

filetype plugin indent on

set foldenable foldmethod=indent

" Autocomplete
set omnifunc=syntaxcomplete#Complete

set number
set autoindent
set tabstop=2
set softtabstop=2
set shiftwidth=2
set expandtab
set mouse=a

" Set <leader> key to spacebar
let mapleader = ' '

" Show commands as you type them
set showcmd

" Highlight current row and column
set cursorline cursorcolumn

" Highlight unwanted spaces (trailing spaces)
highlight ExtraWhitespace ctermbg=lightred guibg=lightred
match ExtraWhitespace /\s\+$/

" Ale linter config
let g:ale_linters = {'haskell': ['hlint', 'stack-ghc']}
let g:ale_haskell_ghc_options = '-fno-code -v0 -isrc'

" Neomake config
let g:neomake_open_list = 2
" When writing a buffer (no delay), and on normal mode changes (after 750ms).
call neomake#configure#automake('nw', 750)

let g:ghcid_command = "bghcid"

" purescript-ide-vim key bindings
autocmd FileType purescript nnoremap <buffer> <silent> <leader>L :Plist<CR>
autocmd FileType purescript nnoremap <buffer> <silent> <leader>l :Pload!<CR>
autocmd FileType purescript nnoremap <buffer> <silent> <leader>r :Prebuild!<CR>
autocmd FileType purescript nnoremap <buffer> <silent> <leader>f :PaddClause<CR>
autocmd FileType purescript nnoremap <buffer> <silent> <leader>t :PaddType<CR>
autocmd FileType purescript nnoremap <buffer> <silent> <leader>a :Papply<CR>
autocmd FileType purescript nnoremap <buffer> <silent> <leader>A :Papply!<CR>
autocmd FileType purescript nnoremap <buffer> <silent> <leader>C :Pcase!<CR>
autocmd FileType purescript nnoremap <buffer> <silent> <leader>i :Pimport<CR>
autocmd FileType purescript nnoremap <buffer> <silent> <leader>qa :PaddImportQualifications<CR>
autocmd FileType purescript nnoremap <buffer> <silent> <leader>g :Pgoto<CR>
autocmd FileType purescript nnoremap <buffer> <silent> <leader>p :Pursuit<CR>
autocmd FileType purescript nnoremap <buffer> <silent> <leader>T :Ptype<CR>

" Javascript syntax config
let g:javascript_conceal_function = "🔪"
let g:javascript_conceal_null = "🍩"
let g:javascript_conceal_this = "🤳"
let g:javascript_conceal_return = "🔫"
let g:javascript_conceal_undefined = "🔞"
let g:javascript_conceal_prototype = "🌃"
let g:javascript_conceal_super = "💪"
let g:javascript_conceal_arrow_function = "👉"
let g:javascript_conceal_noarg_arrow_function = "🌀"
let g:javascript_conceal_underscore_arrow_function = "🎇"

syntax keyword jsBooleanTrue true conceal cchar=👌
syntax keyword jsBooleanFalse false conceal cchar=👎
    '';
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

  home.stateVersion = "19.09";
}
