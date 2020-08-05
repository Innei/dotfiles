
" ===
" === FZF
" ===
set rtp+=/usr/local/opt/fzf
set rtp+=/home/linuxbrew/.linuxbrew/opt/fzf
let g:fzf_history_dir = '~/.config/nvim/tmp/fzf-history'
nnoremap <C-f> :Ag<CR>
nnoremap <C-p> :FZF<CR>
nnoremap <C-r> :Rg<CR>
nnoremap <leader>f :BLines<CR>
" Insert mode completion
imap <c-x><c-k> <plug>(fzf-complete-word)
imap <c-x><c-f> <plug>(fzf-complete-path)
imap <c-x><c-j> <plug>(fzf-complete-file-ag)
imap <c-x><c-l> <plug>(fzf-complete-line)

autocmd! FileType fzf
autocmd  FileType fzf set laststatus=0 noruler
      \| autocmd BufLeave <buffer> set laststatus=2 ruler

command! -bang -nargs=* Buffers
      \ call fzf#vim#buffers(
      \   '',
      \   <bang>0 ? fzf#vim#with_preview('up:60%')
      \           : fzf#vim#with_preview('right:0%', '?'),
      \   <bang>0)


command! -bang -nargs=* LinesWithPreview
      \ call fzf#vim#grep(
      \   'rg --with-filename --column --line-number --no-heading --color=always --smart-case . '.fnameescape(expand('%')), 1,
      \   fzf#vim#with_preview({}, 'up:50%', '?'),
      \   1)

command! -bang -nargs=* Ag
      \ call fzf#vim#ag(
      \   '',
      \   <bang>0 ? fzf#vim#with_preview('up:60%')
      \           : fzf#vim#with_preview('right:50%', '?'),
      \   <bang>0)


command! -bang -nargs=* MRU call fzf#vim#history(fzf#vim#with_preview())

command! -bang BTags
      \ call fzf#vim#buffer_tags('', {
      \     'down': '40%',
      \     'options': '--with-nth 1
      \                 --reverse
      \                 --prompt "> "
      \                 --preview-window="70%"
      \                 --preview "
      \                     tail -n +\$(echo {3} | tr -d \";\\\"\") {2} |
      \                     head -n 16"'
      \ })

