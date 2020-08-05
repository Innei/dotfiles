let g:asyncrun_open = 8
let g:asyncrun_rootmarks = ['.svn', '.git', '.root', '.bzr', '_darcs', 'build.xml', 'node_modules']
let g:asyncrun_shell = 'zsh -c'
let g:asyncrun_status = ''
nnoremap <leader>rr :AsyncRun -cwd=<root>
command! -bang -nargs=* -complete=file Make AsyncRun -program=make @ <args>