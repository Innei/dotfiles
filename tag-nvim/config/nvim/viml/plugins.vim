scriptencoding utf-8
let s:script_path = expand('<sfile>:p:h')
function! s:source(layer) abort
  execute 'source ' . s:script_path . '/layer/' . a:layer . '.vim'
endfunction

call plug#begin('~/.config/nvim/plugged')
call s:source('navigation')
call s:source('syntax')
call s:source('format')
call s:source('completion')
call s:source('enhance')
call s:source('utils')
call s:source('git')
call s:source('writing')
call s:source('style')

call plug#end()

" Free memory
delfunction s:source
unlet s:script_path
