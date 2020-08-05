" ===
" === vim session
" ===
let g:session_directory = $HOME."/.config/nvim/tmp/sessions"
let g:session_autosave = 'no'
let g:session_autoload = 'no'
"let g:session_autosave_periodic = 1
let g:session_autosave_silent = 1
set sessionoptions+=buffers
set sessionoptions-=options
noremap sl :OpenSession<CR>
noremap ss :SaveSession<CR>
noremap sc :CloseSession<CR>
noremap sD :DeleteSession<CR>
noremap sA :AppendTabSession<CR>
