" ===
" === emmet
" ===
let g:user_emmet_install_global = 0
autocmd FileType html,vue,javascript,javascriptreact,typescriptreact EmmetInstall
let g:user_emmet_leader_key='<M-e>'
au FileType html,vue,javascript,javascriptreact,typescriptreact imap <silent><buffer> ,, <plug>(emmet-expand-abbr)
