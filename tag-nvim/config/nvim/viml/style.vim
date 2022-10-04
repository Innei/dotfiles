" Author:   Innei
" Github:   https://github.com/innei
" License:  MIT

" if !exists('g:vscode')
"   colorscheme onedark
" endif

exec "nohlsearch"

if exists('g:started_by_firenvim')
  colorscheme xcodelight
  set wrap
  set laststatus=0
else
  set laststatus=2
endif

let g:firenvim_config = {
      \ "globalSettings": {
      \ "alt": "all"
      \}
      \}

