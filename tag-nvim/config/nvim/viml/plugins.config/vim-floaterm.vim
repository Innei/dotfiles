nnoremap <leader>. <ESC>:FloatermNew<CR>
tnoremap <F2> <C-\><C-N>:FloatermToggle<CR>
nnoremap <F2> <C-\><C-N>:FloatermToggle<CR>
tnoremap <PageUp> <C-\><C-N>:FloatermPrev<CR>
tnoremap <PageDown> <C-\><C-N>:FloatermNext<CR>
tnoremap <F4> <C-\><C-N>:FloatermPrev<CR>
tnoremap <F3> <C-\><C-N>:FloatermNext<CR>

" === git
command! -nargs=0 G :FloatermNew lazygit
