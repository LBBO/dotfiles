" Manual config
syntax enable
set mouse=a
set showcmd
set encoding=utf-8
set statusline=%F%m%r%h%w\ [FORMAT=%{&ff}]\ [TYPE=%Y]\ [POS=%l,%v][%p%%]\ [BUFFER=%n]\ %{strftime('%x')}
" Show a few lines of context around the cursor. Note that this makes the
" text scroll if you mouse-click near the start or end of the window.
set scrolloff=5

""" Map leader to space ---------------------
let mapleader=" "

""" Plugins  --------------------------------
set surround
set easymotion
set multiple-cursors
set commentary
set textobj-entire
set highlightedyank
set textobj-indent
set matchit

set which-key
set notimeout

set incsearch

""" Mappings --------------------------------
map <leader>f <Plug>(easymotion-s)
map <leader>e <Plug>(easymotion-f)

map <leader>d <Action>(Debug)
map <leader>rn <Action>(RenameElement)

" Clear search results on double-escape
nnoremap <esc> :noh<return><esc>

"## General
set number	"# Show line numbers
set relativenumber "# Show relative line numbers
set linebreak	"# Break lines at word (requires Wrap lines)
set showbreak=+++ 	"# Wrap-broken line prefix
set textwidth=100	"# Line wrap (number of cols)
set showmatch	"# Highlight matching brace
set visualbell	"# Use visual bell (no beeping)

set hlsearch	"# Highlight all search results
set smartcase	"# Enable smart-case search
set ignorecase	"# Always case-insensitive
set incsearch	"# Searches for strings incrementally

set autoindent	"# Auto-indent new lines
set expandtab	"# Use spaces instead of tabs
set shiftwidth=2	"# Number of auto-indent spaces
set smartindent	"# Enable smart-indent
set smarttab	"# Enable smart-tabs
set softtabstop=2	"# Number of spaces per Tab

"## Advanced
set ruler	"# Show row and column ruler information

set undolevels=1000	"# Number of undo levels
set backspace=indent,eol,start	"# Backspace behaviour


"## Generated by VimConfig.com
