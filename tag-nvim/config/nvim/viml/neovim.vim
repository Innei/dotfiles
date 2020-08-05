let g:python_host_skip_check = 1
let g:python3_host_skip_check = 1
let g:loaded_node_provider = 0
let g:loaded_ruby_provider = 0
let g:loaded_python_provider = 0
" let g:loaded_python3_provider = 0
set guicursor=n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50
                                    \,a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor
                                    \,sm:block-blinkwait175-blinkoff150-blinkon175
set signcolumn=yes:2
set inccommand=split
" ===
" === Terminal Behaviors
" ===
let g:neoterm_autoscroll = 1
autocmd TermOpen term://* startinsert
" tnoremap <C-N> <C-\><C-N>
" tnoremap <C-O> <C-\><C-N><C-O>

