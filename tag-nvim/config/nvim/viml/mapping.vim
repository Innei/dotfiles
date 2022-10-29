" Author:   Innei
" Github:   https://github.com/innei
" License:  MIT
scriptencoding utf-8

" ===
" === Basic Mappings
" ===
let mapleader=" "
noremap ; :
noremap r <C-r>
nnoremap X r
" map 0 To the first non-blank character of the line.
nnoremap 0 ^
nnoremap ) g_


if exists('g:vscode')
  nnoremap Q :tabc<CR>
  command! -nargs=0 Q :tabonly
else
  command! -nargs=0 Q :q!
  nnoremap Q :bd<CR>
endif

noremap <C-q> :qa<CR>
nnoremap <silent> S :w<CR>
noremap <silent> <C-S> :wa<CR>
inoremap <silent> <C-s> <ESC>:w<CR>i

nnoremap <S-CR> <ESC>o<ESC>
inoremap <S-CR> <ESC>o
" Meta key remap
vnoremap <M-c> "+y
inoremap <M-v> <C-o>"+]p

" Open the vimrc file anytime
nnoremap <LEADER>rc :e ~/.config/nvim/init.vim<CR>


" make Y to copy till the end of the line
nnoremap Y yg_

" Paste from system clipboard
nnoremap P "+p

" Copy to system clipboard
xnoremap y "+y

" Indentation
nnoremap < <<
nnoremap > >>
xnoremap < <gv
xnoremap > >gv

" Search
nnoremap <LEADER><CR> :nohlsearch<CR>

" Adjacent duplicate words
noremap <LEADER>dw /\(\<\w\+\>\)\_s*\1

" Space to Tab
nnoremap <LEADER>tt :%s/    /\t/g
xnoremap <LEADER>tt :s/    /\t/g
nnoremap <LEADER>ss :%s/\t/    /g
xnoremap <leader>ss :s/\t/    /g

" Toggle wrap
nnoremap <LEADER>tw :set wrap!<CR>
" ===
" === Cursor Movement
" ===
nnoremap . <C-I>
nnoremap , <C-O>

map ! %
nnoremap <C-a> <nop>
nnoremap <C-x> <nop>
inoremap <C-j> <Down>
inoremap <C-k> <Up>
inoremap <C-h> <Left>
inoremap <C-l> <Right>

cnoremap <C-j> <Down>
cnoremap <C-k> <Up>
cnoremap <C-h> <Left>
cnoremap <C-l> <Right>


" number increment and decrement
nnoremap = <C-a>
nnoremap - <C-x>

if !exists('g:vscode')
  inoremap <Home> <esc>^i
  inoremap <Del> <ESC>lxi
  nnoremap <Del> "_x
  xnoremap <Del> "_d
  xnoremap <silent> , ^
  xnoremap <silent> . g_
  xnoremap <silent> <End> g_
  xnoremap <silent> <Home> ^
endif

" rename a word
nnoremap cw ciw

" Go next or forward word under cursor
nnoremap \\ *
nnoremap \| #
if !exists('g:vscode')
  " select word
  inoremap <M-d> <ESC>viw<C-g>
  nnoremap <M-d> viw<C-g>
  snoremap <M-d> <ESC>*ve<C-g>
  snoremap <M-D> <ESC>#ve<C-g>

  " Ctrl + U or E will move up/down the view port without moving the cursor
  noremap <C-W> 5<C-y>
  noremap <C-E> 5<C-e>
  " ===
  " === Insert Mode Cursor Movement
  " ===
  inoremap jj <ESC>l
  inoremap kk <ESC>l
  " undo
  inoremap <M-z> <ESC>u
  inoremap jk <ESC>u
  " ===
  " === Command Mode Cursor Movement
  " ===
  cnoremap <C-a> <Home>
  cnoremap <C-e> <End>
  cnoremap <C-p> <Up>
  cnoremap <C-n> <Down>
  cnoremap <C-b> <Left>
  cnoremap <C-f> <Right>
  cnoremap <M-b> <S-Left>
  cnoremap <M-w> <S-Right>

  " use shift(Meta) + arrow keys to move line up/down
  nnoremap <S-up> :m .-2<CR>
  nnoremap <S-down> :m .+1<CR>
  inoremap <M-up> <ESC>:m .-2<CR>==gi
  inoremap <M-down> <ESC>:m .+1<CR>==gi
  inoremap <M-left> <ESC>bi
  inoremap <M-right> <Esc>ea
  inoremap <S-up> <ESC>:m .-2<CR>==gi
  inoremap <S-down> <ESC>:m .+1<CR>==gi
  inoremap <S-left> <ESC>bi
  inoremap <S-right> <Esc>ea
  " multi-lines move up/down in visual mode
  vnoremap <M-up> :m '<-2<CR>gv=gv
  vnoremap <M-down> :m '>+1<CR>gv=gv
  vnoremap <M-left> b
  vnoremap <M-right> e
  vnoremap <S-up> <nop>
  vnoremap <S-down> <nop>
  vnoremap <S-left> <nop>
  vnoremap <S-right> <nop>
  " ===
  " === Window management
  " ===
  " Use <space> + new arrow keys for moving the cursor around windows
  noremap <LEADER>w <C-w>w
  noremap <LEADER><Up> <C-w>k
  noremap <LEADER><Down> <C-w>j
  noremap <LEADER><Left> <C-w>h
  noremap <LEADER><Right> <C-w>l

  " Disable the default s key
  noremap s <nop>

  " split the screens to up (horizontal), down (horizontal), left (vertical), right (vertical)
  nnoremap s<up> :set nosplitbelow<CR>:split<CR>:set splitbelow<CR>
  nnoremap s<down> :set splitbelow<CR>:split<CR>
  nnoremap s<left> :set nosplitright<CR>:vsplit<CR>:set splitright<CR>
  nnoremap s<right> :set splitright<CR>:vsplit<CR>

  " Resize splits with arrow keys
  nnoremap <M-up> :res +5<CR>
  nnoremap <M-down> :res -5<CR>
  nnoremap <M-left> :vertical resize-5<CR>
  nnoremap <M-right> :vertical resize+5<CR>

  " Place the two screens up and down
  nnoremap sh <C-w>t<C-w>K
  " Place the two screens side by side
  nnoremap sv <C-w>t<C-w>H

  " Rotate screens
  nnoremap srh <C-w>b<C-w>K
  nnoremap srv <C-w>b<C-w>H

  " Press <SPACE> + q to close the window below the current window
  nnoremap <LEADER>q <C-w>j:q<CR>
endif
" ===
" === Tab management
" ===
if !exists('g:vscode')
  " Create a new tab with t/
  nnoremap t/ :tabe<CR>
  " Move around tabs with t, and t.
  nnoremap t, :-tabnext<CR>
  nnoremap t. :+tabnext<CR>
  " Move the tabs with tm, and tm.
  nnoremap tm, :-tabmove<CR>
  nnoremap tm. :+tabmove<CR>
endif
" ===
" === Buffer manage
" ===
if exists('g:vscode')
  nnoremap gB :tabp<CR>
  nnoremap gb :tabn<CR>
  nnoremap tb :tabnew<CR>
  nnoremap <Leader>Q tabo<CR>
else
  nnoremap gB :bprevious<CR>
  nnoremap gb :bnext<CR>
  nnoremap tb :enew<CR>
endif

" ===
" === Other useful stuff
" ===
xnoremap L <ESC>^v$h
nnoremap [p o<ESC>p
" Move the next character to the end of the line with ctrl+9
inoremap <C-u> <ESC>lx$p

" Opening a terminal window
" noremap <LEADER>. :set nosplitbelow<CR>:split<CR><C-w>w:terminal<CR><C-\><C-n>:set splitbelow<CR>i

" Press space twice to jump to the next '<++>' and edit it
nnoremap <silent> <LEADER><LEADER> <Esc>/<++><CR>:nohlsearch<CR>v3l<C-g>
inoremap <silent> <C-p> <++>
" Spelling Check with <space>sc
noremap <LEADER>sc :set spell!<CR>

" Press ` to change case (instead of ~)
noremap ` ~<left>

" find and replace
noremap \s :%s//g<left><left>

if !exists('g:vscode')
  " ---------------------------------------------------------------------
  " About Chinese: f[[
  " punctuations auto changing has unexpected problems
  imap （ (
  imap ） )
  imap 』 }
  imap 『 {
  imap 【 [
  imap 】 ]
  imap 。 .
  imap ， ,
  imap ； ;
  imap ： :
  imap “ "
  imap ” "
  imap ‘ '
  imap ’ '
  imap ？ ?
  imap ！ !
  imap 》 >
  imap 《 <
  imap 、 /
  imap ￥ $
  imap 》 >
  imap 《 <
  map ： :
  map ； :
endif
