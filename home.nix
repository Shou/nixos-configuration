{ pkgs, ... }:

{
  programs.home-manager.enable = true;

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      clock-show-seconds = true;
      clock-show-date = true;
    };
    "org/gnome/desktop/calendar".show-weekdate = true;
    "org/gnome/desktop/wm/preferences".resize-with-right-button = true;
    "org/gnome/desktop/wm/keybindings" = {
      close = ["<Super>c"];
      switch-to-workspace-down = ["<Super>j"];
      switch-to-workspace-up = ["<Super>k"];
      move-to-workspace-down = ["<Super><Shift>j"];
      move-to-workspace-up = ["<Super><Shift>k"];
      switch-to-workspace-1 = ["<Super>1"];
      switch-to-workspace-2 = ["<Super>2"];
      switch-to-workspace-3 = ["<Super>3"];
      switch-to-workspace-4 = ["<Super>4"];
      switch-to-workspace-5 = ["<Super>5"];
      switch-to-workspace-6 = ["<Super>6"];
      switch-to-workspace-7 = ["<Super>7"];
      switch-to-workspace-8 = ["<Super>8"];
      switch-to-workspace-9 = ["<Super>9"];
      move-to-workspace-1 = ["<Super><Shift>1"];
      move-to-workspace-2 = ["<Super><Shift>2"];
      move-to-workspace-3 = ["<Super><Shift>3"];
      move-to-workspace-4 = ["<Super><Shift>4"];
      move-to-workspace-5 = ["<Super><Shift>5"];
      move-to-workspace-6 = ["<Super><Shift>6"];
      move-to-workspace-7 = ["<Super><Shift>7"];
      move-to-workspace-8 = ["<Super><Shift>8"];
      move-to-workspace-9 = ["<Super><Shift>9"];
    };
    "org/gnome/terminal/legacy".default-show-menubar = false;
    "desktop/ibus/general".preload-engines = [ "mozc-jp" "xkb:us:altgr-intl:eng" ];
  };

  programs.fish = {
    enable = true;

    interactiveShellInit = ''
      set -gx PATH ~/.npm-packages/bin $PATH
    '';
  };

  programs.direnv.enableFishIntegration = true;

  programs.neovim = {
    enable = true;

    # withNodeJS = true;
    # withPython3 = true;

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
    ]);

    extraConfig = ''
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
    '';
  };
}
