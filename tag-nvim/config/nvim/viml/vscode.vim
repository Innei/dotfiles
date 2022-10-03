set hidden
set ignorecase
set smartcase
command! -nargs=0 BufOnly :tabo

nnoremap <silent> gr :<C-u>call VSCodeNotify('editor.action.goToReference')<CR>
nnoremap <silent> K :<C-u>call VSCodeNotify('editor.action.showHover')<CR>

syntax off
set noundofile
set noswapfile
set noloadplugins