scriptencoding utf-8

let s:script_cwd = expand('<sfile>:p:h')

if len(get(g:, 'plugs_order', [])) !=# 0
  for s:plug in g:plugs_order
    let s:plug_config = s:script_cwd . '/plugins.config/' . s:plug . '.vim'
    if filereadable(s:plug_config)
      execute 'source ' . s:plug_config
    endif
  endfor
endif