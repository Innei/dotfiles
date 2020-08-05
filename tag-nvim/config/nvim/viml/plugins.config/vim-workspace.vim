" May you be blessed by the world with its tenderness.
" File              : vim-workspace.vim
" Author            : Innei <tukon479@gmail.com>
" Date              : 29.07.2020
" Last Modified Date: 29.07.2020
" Last Modified By  : Innei <tukon479@gmail.com>

" ===
" === vim-workspace
" ===
let g:workspace_session_directory = $HOME . '/.config/nvim/tmp/sessions/'
let g:workspace_autosave = 0
let g:workspace_session_name = 'vim-workspace'
nnoremap ss :ToggleWorkspace<CR>
nnoremap srm :!rm -r $HOME/.config/nvim/tmp/sessions<CR>
