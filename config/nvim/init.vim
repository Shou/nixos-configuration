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
set cursorline
set cursorcolumn

" Highlight unwanted spaces (trailing spaces)
highlight ExtraWhitespace ctermbg=lightred guibg=lightred
match ExtraWhitespace /\s\+$/
highlight CocUnderline cterm=underline ctermbg=0

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

" Javascript syntax config -- this isn't really used but i'm keeping it here for posterity
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
