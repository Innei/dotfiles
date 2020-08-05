
" ===
" === fzf-preview.vim
" ===
" let g:fzf_preview_default_key_bindings = 'ctrl-e:down,ctrl-u:up'
let g:fzf_preview_layout = 'belowright split new'
let g:fzf_preview_rate = 0.4
let g:fzf_full_preview_toggle_key = '<C-f>'
let g:fzf_preview_command = 'ccat --color=always {-1}'
let g:fzf_binary_preview_command = 'echo "It is a binary file"'