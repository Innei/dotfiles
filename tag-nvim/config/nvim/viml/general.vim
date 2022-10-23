" Author:   Innei
" Github:   https://github.com/innei
" License:  MIT

scriptencoding utf-8

" ===
" === System
" ===
" set clipboard=unnamedplus
let &t_ut=''
" set autochdir

" ===
" === Editor behavior
" ===
set number
set relativenumber
set mouse=a
set mousehide
set cursorline
set expandtab
set tabstop=4
set shiftwidth=2
set softtabstop=2
set backspace=2
set autoindent
set smartindent
set smarttab
set list
set listchars=tab:→\ ,trail:·
set scrolloff=8
set viewoptions=cursor,folds,slash,unix
" set notimeout
set timeout
set timeoutlen=500
set ttimeoutlen=0
set nowrap
set sidescroll=8
" set linebreak
set wrapmargin=8
set tw=0
set indentexpr=
set foldmethod=indent
set foldlevel=99
set foldenable
set formatoptions-=cro
set splitright
" autocmd BufEnter * setlocal formatoptions-=c formatoptions-=r formatoptions-=o
set splitbelow
set noshowmode
set showcmd
set wildmenu
set ignorecase
set smartcase
set shortmess+=cOtT
set ttyfast "should make scrolling faster
set lazyredraw "same as above
set visualbell
set autoread
set hidden
set pastetoggle=<F10>
" set colorcolumn=80
set updatetime=500
set termguicolors " enable true colors support

" toggle number releative or absolute
autocmd InsertEnter * :set norelativenumber
autocmd InsertLeave * :set relativenumber

if !has('gui_running')
    augroup FastEscape
        autocmd!
        au InsertEnter * set timeoutlen=0
        au InsertLeave * set timeoutlen=500
    augroup END
endif

au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
" disable syntax if large
" autocmd BufWinEnter * if line2byte(line("$") + 1) > 10000 | syntax clear | endif

" experimental
set lazyredraw
" set regexpengine=0

set guicursor=n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50
                                    \,a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor
                                    \,sm:block-blinkwait175-blinkoff150-blinkon175
set signcolumn=yes:2
set inccommand=split
" ===
" === Ignore File
" ===
set wildignore+=*node_modules/**
set wildignore+=*.o,*.obj,*~
set wildignore+=*.git*
set wildignore+=*.meteor*
set wildignore+=*vim/backups*
set wildignore+=*sass-cache*
set wildignore+=*cache*
set wildignore+=*logs*
set wildignore+=*node_modules/**
set wildignore+=*DS_Store*
set wildignore+=*.gem
set wildignore+=log/**
set wildignore+=tmp/**
set wildignore+=*.png,*.jpg,*.gif

