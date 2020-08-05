" Author:   Innei
" Github:   https://github.com/innei
" License:  MIT

set termguicolors " enable true colors support
if (empty($TMUX))
  if (has("nvim"))
    let $NVIM_TUI_ENABLE_TRUE_COLOR=1
  endif
  if (has("termguicolors"))
    set termguicolors
  endif
endif

" let g:xcodedark_green_comments = 1
" let g:xcodedark_emph_types = 1
" let g:xcodedark_emph_funcs = 1
" let g:xcodedark_emph_idents = 1
" let g:xcodedark_match_paren_style = 1
" let g:xcodedark_dim_punctuation = 1

" colorscheme material
" color xcodedark

" hi Normal guibg=NONE ctermbg=NONE
" hi NonText guibg=NONE ctermbg=NONE ctermfg=NONE guifg=NONE
colorscheme onedark

exec "nohlsearch"


if exists('g:started_by_firenvim')
  colorscheme xcodelight
  set wrap
  set laststatus=0
else
  set laststatus=2
endif
au BufEnter github.com_*.txt set filetype=markdown
let g:firenvim_config = {
      \ "globalSettings": {
      \ "alt": "all"
      \}
      \}

