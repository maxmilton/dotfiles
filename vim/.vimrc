set nocompatible      " Needed for advanced features
set modelines=0       " Disable modlines for security

" Compatibility with multibyte characters (日本語 & 한글)
set encoding=utf-8
setglobal fileencoding=utf-8
set fileencodings=utf-8
scriptencoding utf-8


" ----------------------------------------------------------------------------
"  External Files
" ----------------------------------------------------------------------------

" Allow unsaved background buffers and remember marks/undo
set hidden

" Backup files
if isdirectory($HOME . '/.vim/backup') == 0
  :silent !mkdir -p ~/.vim/backup >/dev/null 2>&1
endif
set backupdir-=.
set backupdir+=.
set backupdir-=~/
set backupdir^=~/.vim/backup/
set backupdir^=./.vim-backup/
set backup

" Swap files
if isdirectory($HOME . '/.vim/swap') == 0
  :silent !mkdir -p ~/.vim/swap >/dev/null 2>&1
endif
set directory=./.vim-swap//
set directory+=~/.vim/swap//
set directory+=~/tmp//
set directory+=.

" Store state of previous editing session
set viminfo+=n~/.vim/viminfo

if exists("+undofile")
  " Allow persistent undo even after exiting
  if isdirectory($HOME . '/.vim/undo') == 0
    :silent !mkdir -p ~/.vim/undo > /dev/null 2>&1
  endif
  set undodir=./.vim-undo//
  set undodir+=~/.vim/undo//
  set undofile
endif


" ----------------------------------------------------------------------------
"  Text Formatting
" ----------------------------------------------------------------------------

set autoindent             " Automaticly indent new lines
set smartindent            " Be smart about it
inoremap # X<BS>#
set scrolloff=7            " Show min 3 lines when scrolling
set softtabstop=2
set shiftwidth=2
set tabstop=4
set expandtab              " Expand tabs to spaces
set nosmarttab             " No tabs
set formatoptions+=n       " Support for numbered/bullet lists
set textwidth=80           " Wrap at 80 chars by default
set virtualedit=block      " allow virtual edit in visual block ..
set wrap                   " Do wrap lines
set linebreak
set nolist                 " list disables linebreak
set formatoptions-=t       " Disable auto wraping while typing


" ----------------------------------------------------------------------------
"  Remapping
" ----------------------------------------------------------------------------

" Lead with ,
let mapleader = ","

" Exit to normal mode with 'jj'
inoremap jj <ESC>

" Reflow paragraph with Q in normal and visual mode
nnoremap Q gqap
vnoremap Q gq

" Sane movement with wrap turned on
nnoremap j gj
nnoremap k gk
vnoremap j gj
vnoremap k gk
nnoremap <Down> gj
nnoremap <Up> gk
vnoremap <Down> gj
vnoremap <Up> gk
inoremap <Down> <C-o>gj
inoremap <Up> <C-o>gk

" Remap movement in split windows
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l


" ----------------------------------------------------------------------------
"  UI
" ----------------------------------------------------------------------------

syntax enable
set t_Co=256               " 256 colors
set background=dark
colorscheme grb256
set mouse=a                " Automatically enable mouse usage
set mousehide              " Hide the mouse cursor while typing
set ruler                  " Show the cursor position all the time
set noshowcmd              " Don't display incomplete commands
set nolazyredraw           " Turn off lazy redraw
set number                 " Line numbers
set wildmenu               " Turn on wild menu
set wildmode=list:longest,full
set ch=2                   " Command line height
set backspace=2            " Allow backspacing over everything in insert mode
set whichwrap+=<,>,h,l,[,] " Backspace and cursor keys wrap to
set shortmess=filtIoOA     " Shorten messages
set report=0               " Tell us about changes
set nostartofline          " Don't jump to the start of line when scrolling
set relativenumber         " Show line number relative to cursor
set history=1000           " Store a ton of history (default is 20)
set hidden                 " Allow buffer switching without saving


" ----------------------------------------------------------------------------
" Visual Cues
" ----------------------------------------------------------------------------

set showmatch              " Brackets/braces that is
set mat=5                  " Duration to show matching brace (1/10 sec)
set incsearch              " Do incremental searching
set laststatus=2           " Always show the status line
set ignorecase             " Ignore case when searching
set smartcase              " Search case if you use uppercase character
set hlsearch               " Highlight searches
set visualbell             " No audible bell
set timeoutlen=50          " Prevent pause leaving insert mode


" ---------------------------------------------------------------------------
"  Custom Extras
" ---------------------------------------------------------------------------

" Strip all trailing whitespace in file
function! StripWhitespace ()
    exec ':%s/ \+$//gc'
endfunction
map ,s :call StripWhitespace ()<CR>

" Make and switch to virtical split screen
nnoremap <leader>w <C-w>v<C-w>l

" Toggle paste mode with F2
nnoremap <F2> :set invpaste paste?<CR>
set pastetoggle=<F2>
set showmode

" Toggle spell checking
set spelllang=en_au
nmap <F7> :set spell!<CR>

" Force write as sudo
cmap w!! w !sudo tee >/dev/null %

" Shift key fixes
if has("user_commands")
    command! -bang -nargs=* -complete=file E e<bang> <args>
    command! -bang -nargs=* -complete=file W w<bang> <args>
    command! -bang -nargs=* -complete=file Wq wq<bang> <args>
    command! -bang -nargs=* -complete=file WQ wq<bang> <args>
    command! -bang Wa wa<bang>
    command! -bang WA wa<bang>
    command! -bang Q q<bang>
    command! -bang QA qa<bang>
    command! -bang Qa qa<bang>
endif

" For markdown mode on md files
autocmd BufNewFile,BufReadPost *.md set filetype=markdown


" ----------------------------------------------------------------------------
"  FOR LEARNING
" ----------------------------------------------------------------------------

"" Disable arrow keys
"nnoremap <up> <nop>
"nnoremap <down> <nop>
"nnoremap <left> <nop>
"nnoremap <right> <nop>
"inoremap <up> <nop>
"inoremap <down> <nop>
"inoremap <left> <nop>
"inoremap <right> <nop>
"nnoremap j gj
