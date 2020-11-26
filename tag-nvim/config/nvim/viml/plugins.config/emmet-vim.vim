" ===
" === emmet
" ===
let g:user_emmet_install_global = 0
autocmd FileType html,vue,javascript,javascriptreact,typescriptreact,html,vue,javascript,javascriptreact,typescriptreact,typescript.tsx,javascript.jsx,tsx,jsx EmmetInstall
let g:user_emmet_leader_key='<C-z>'
au FileType html,vue,javascript,javascriptreact,typescriptreact,typescript.tsx,javascript.jsx,tsx,jsx imap <silent><buffer> ,, <plug>(emmet-expand-abbr)
