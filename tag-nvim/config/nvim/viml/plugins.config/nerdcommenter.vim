" ===
" === nerdcommenter
" ===
" Vue comment hook
let g:ft = ''
function! NERDCommenter_before()
  if &ft == 'vue'
    let g:ft = 'vue'
    let stack = synstack(line('.'), col('.'))
    if len(stack) > 0
      let syn = synIDattr((stack)[0], 'name')
      if len(syn) > 0
        exe 'setf ' . substitute(tolower(syn), '^vue_', '', '')
      endif
    endif
  endif
endfunction
function! NERDCommenter_after()
  if g:ft == 'vue'
    setf vue
    let g:ft = ''
  endif
endfunction
map <Leader>/ <plug>NERDCommenterToggle
imap <C-c> <plug>NERDCommenterInsert
let g:NERDSpaceDelims = 1
let g:NERDCompactSexyComs = 1
let g:NERDToggleCheckAllLines = 1
let g:NERDDefaultAlign = 'left'
let g:NERDTrimTrailingWhitespace = 1
let g:NERDCommentEmptyLines = 1
let g:NERDCreateDefaultMappings = 0