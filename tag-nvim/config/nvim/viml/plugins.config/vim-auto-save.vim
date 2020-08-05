let g:auto_save = 0
augroup ft_markdown
  au!
  au FileType markdown let b:auto_save = 1
augroup END
" let g:auto_save_write_all_buffers = 1  " write all open buffers as if you would use :wa
" let g:auto_save_silent = 1  " do not display the auto-save notification
