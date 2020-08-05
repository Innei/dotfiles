if !exists('g:started_by_firenvim')
  let g:airline_powerline_fonts = 1
  let g:airline#extensions#vista#enabled = 0
  let g:airline_theme='onedark'
  let g:airline#extensions#tabline#tabnr_formatter = 'tabnr'
  let g:airline#extensions#tabline#formatter = 'jsformatter'
  let g:airline_highlighting_cache = 1
  let g:airline_extensions = ['coc', 'tabline']
  let g:airline#extensions#tabline#switch_buffers_and_tabs = 1
  let g:airline#extensions#tabline#tabs_label = ' '
  let g:airline#extensions#tabline#buffers_label = '﬘'
  let g:airline#extensions#tabline#show_close_button = 0
  let g:airline#extensions#tabline#exclude_preview = 1
  " let airline#extensions#coc#stl_format_err = '%E{[%e(#%fe)]}'
  " let airline#extensions#coc#stl_format_warn = '%W{[%w(#%fw)]}'
  " let g:airline_section_c = airline#section#create(['%f  ' , '%{get(b:,''coc_current_function'','''')}'])
  let g:airline_section_b = airline#section#create(['%{get(b:,''coc_git_status'','''')}','%{get(g:,''coc_git_status'','''')}'])
  let g:airline_section_error = airline#section#create_right(['%{g:asyncrun_status}'])
  function! StatusDiagnostic() abort
    let info = get(b:, 'coc_diagnostic_info', {})
    if empty(info) | return '' | endif
    let msgs = []
    if get(info, 'error', 0)
      call add(msgs, ' ' . info['error'])
    endif
    if get(info, 'warning', 0)
      call add(msgs, ' ' . info['warning'])
    endif
    if get(info, 'information', 0)
      call add(msgs, ' ' . info['information'])
    endif
    if get(info, 'hint', 0)
      call add(msgs, ' ' . info['hint'])
    endif
    " echo get(g:, 'coc_status', '')
    return join(msgs, ' ')
  endfunction
  let g:airline_section_warning = airline#section#create_right(['%{StatusDiagnostic()}'])
  " let g:airline_section_warning = airline#section#create_right(['%{coc#status()}'])
  if !exists('g:airline_symbols')
    let g:airline_symbols = {}
  endif
  let g:airline_left_sep = '»'
  let g:airline_left_sep = '▶'
  let g:airline_right_sep = '«'
  let g:airline_right_sep = '◀'
  let g:airline_left_sep = ''
  let g:airline_left_alt_sep = ''
  let g:airline_right_sep = ''
  let g:airline_right_alt_sep = ''
  let g:airline_symbols.branch = ''
  let g:airline_symbols.readonly = ''

endif
