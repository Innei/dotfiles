
" ===
" === coc
" ===
let g:coc_global_extensions = [
    \ 'coc-actions',
    \ 'coc-calc',
    \ 'coc-css',
    \ 'coc-cssmodules',
    \ 'coc-eslint',
    \ 'coc-explorer',
    \ 'coc-git',
    \ 'coc-gitignore',
    \ 'coc-go',
    \ 'coc-highlight',
    \ 'coc-html',
    \ 'coc-imselect',
    \ 'coc-json',
    \ 'coc-lists',
    \ 'coc-marketplace',
    \ 'coc-post',
    \ 'coc-postfix',
    \ 'coc-prettier',
    \ 'coc-pyright',
    \ 'coc-python',
    \ 'coc-smartf',
    \ 'coc-snippets',
    \ 'coc-spell-checker',
    \ 'coc-stylelint',
    \ 'coc-tailwindcss',
    \ 'coc-todolist',
    \ 'coc-translator',
    \ 'coc-tslint',
    \ 'coc-tsserver',
    \ 'coc-vimlsp',
    \ 'coc-yank',
    \ 'coc-zi',
    \ 'coc-discord-rpc',
    \ ]

inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
imap <expr> <silent> <CR>  "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"
nnoremap <expr> <silent> o "o\<c-r>=coc#on_enter()\<cr>"
inoremap <silent><expr> <TAB>
      \ pumvisible() ? coc#_select_confirm() :
      \ coc#expandableOrJumpable() ? "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])\<CR>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
imap <C-j> <Plug>(coc-snippets-expand-jump)
function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

let g:coc_snippet_next = '<tab>'
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

inoremap <silent><expr> <c-space> coc#refresh()
inoremap <silent><expr> ,. coc#refresh()
" Open up coc-commands
nnoremap <c-c> :CocList diagnostics<CR>
nnoremap <leader>l :CocList<CR>
" Text Objects
xmap kf <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap kf <Plug>(coc-funcobj-i)
omap af <Plug>(coc-funcobj-a)
" Useful commands
nnoremap <silent> <space>y :<C-u>CocList -A --normal yank<cr>
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)
nmap <leader>rn <Plug>(coc-rename)
nmap <leader>cw <Plug>(coc-rename)

nnoremap tt :CocCommand explorer<CR>
" coc-todolist
noremap ta :CocCommand todolist.create<CR>
noremap td :CocCommand todolist.upload<CR>
noremap tD :CocCommand todolist.download<CR>
noremap tc :CocCommand todolist.clearNotice<CR>
noremap tc :CocCommand todolist.clearNotice<CR>
noremap tl :CocList --normal todolist<CR>
" coc-translator
nmap ts <Plug>(coc-translator-p)
" coc-zi
noremap \d :CocList translators<CR>

nnoremap <silent> <leader>b :CocCommand actions.open<cr>

autocmd CursorHold * silent call CocActionAsync('highlight')
" hi CocHighlightText guifg=#eeffff guibg=#888888
autocmd! CompleteDone * if pumvisible() == 0 | pclose | endif

command! -nargs=0 Format :call CocAction('format')

command! -nargs=? Fold :call     CocAction('fold', <f-args>)

command! -nargs=0 OR   :call     CocAction('runCommand', 'editor.action.organizeImport')

command! -nargs=0 C             CocConfig
command! -nargs=0 R             CocRestart
command! -nargs=0 L             CocListResume
command! -nargs=0 -range D      CocCommand

nmap <silent> <TAB> <Plug>(coc-range-select)
xmap <silent> <TAB> <Plug>(coc-range-select)

xmap <leader>f  <Plug>(coc-format-selected)

nmap <leader>o <Plug>(coc-openlink)
nmap <leader>a <Plug>(coc-refactor)

" set workspace
autocmd FileType javascript,javascriptreact,typescript,typescriptreact,scss let b:coc_root_patterns = ['node_modules']

command! -nargs=0 Prettier :CocCommand prettier.formatFile
nnoremap <leader>p :Format<CR>

" coc-smartf
nmap f <Plug>(coc-smartf-forward)
nmap F <Plug>(coc-smartf-backward)
augroup Smartf
  autocmd User SmartfEnter :hi Conceal ctermfg=220 guifg=#e74c3c
  autocmd User SmartfLeave :hi Conceal ctermfg=239 guifg=#504945
augroup end
