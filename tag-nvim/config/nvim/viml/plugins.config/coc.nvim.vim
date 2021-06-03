
" ===
" === coc
" ===
" Set internal encoding of vim, not needed on neovim, since coc.nvim using some
" unicode characters in the file autoload/float.vim
set encoding=utf-8

" TextEdit might fail if hidden is not set.
set hidden

" Some servers have issues with backup files, see #649.
set nobackup
set nowritebackup

" Give more space for displaying messages.
set cmdheight=2

" Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
" delays and poor user experience.
set updatetime=300

" Don't pass messages to |ins-completion-menu|.
set shortmess+=c

" Always show the signcolumn, otherwise it would shift the text each time
" diagnostics appear/become resolved.
if has("nvim-0.5.0") || has("patch-8.1.1564")
  " Recently vim can merge signcolumn and number column into one
  set signcolumn=number
else
  set signcolumn=yes
endif


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
" Map function and class text objects
" NOTE: Requires 'textDocument.documentSymbol' support from the language server.
xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
omap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ac <Plug>(coc-classobj-a)
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
