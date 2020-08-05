" ==
" == GitGutter
" ==
let g:gitgutter_signs = 0
let g:gitgutter_map_keys = 0
let g:gitgutter_override_sign_column_highlight = 0
let g:gitgutter_preview_win_floating = 1
autocmd BufWritePost * GitGutter
" nnoremap gf :GitGutterFold<CR>
nnoremap <silent> gh :GitGutterPreviewHunk<CR>
nnoremap g- :GitGutterPrevHunk<CR>
nnoremap g= :GitGutterNextHunk<CR>
nnoremap gu :GitGutterUndoHunk<CR>
nnoremap gs :GitGutterStageHunk<CR>