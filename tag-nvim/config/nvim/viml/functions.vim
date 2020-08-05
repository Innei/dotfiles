" Author:   Innei
" Github:   https://github.com/innei
" License:  MIT
scriptencoding utf-8

" Compile function
noremap <F5> :call CompileRunGcc()<CR>
func! CompileRunGcc()
  exec "w"
  if &filetype == 'c'
    exec "!g++ % -o %<"
    exec "!time ./%<"
  elseif &filetype == 'cpp'
    set splitbelow
    exec "!g++ -std=c++11 % -Wall -o %<"
    :sp
    :res -15
    :term ./%<
  elseif &filetype == 'java'
    exec "!javac %"
    exec "!time java %<"
  elseif &filetype == 'sh'
    :!time bash %
  elseif &filetype == 'python'
    :AsyncRun python3 %
  elseif &filetype == 'tex'
    silent! exec "VimtexStop"
    silent! exec "VimtexCompile"
  elseif &filetype == 'go'
    exec "GoRun %"
  elseif &filetype == 'javascript'
    :AsyncRun node %
  elseif &filetype == 'typescript'
    :AsyncRun yarn run babel-node % --extensions ".ts"
  endif
endfunc

func! Replace_Chn()                     " for writing latex
	let chinese={"（" : "(" , "）" : ")" , "，" : ",", "；" : ";", "：" : ":",
	"？" : "?", "！" : "!", "“" : "\"", "’" : "'" ,
	""”" : "\"", "℃" : "\\\\textcelsius", "μ" : "$\\\\mu$"}
	for i in keys(chinese)
		silent! exec '%substitute/' . i . '/'. chinese[i] . '/g'
	endfor
endfunc
function! ToggleVerbose()
 if !&verbose
 set verbosefile=/tmp/vim-verbose.log
 set verbose=15
 else
 set verbose=0
 set verbosefile=
 endif
endfunction

function! QuickFix_toggle()
  for i in range(1, winnr('$'))
    let bnum = winbufnr(i)
    if getbufvar(bnum, '&buftype') == 'quickfix'
      cclose
      return
    endif
  endfor
  copen
endfunction

nnoremap <Leader>cc :call QuickFix_toggle()<cr>
