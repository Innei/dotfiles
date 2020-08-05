" ===
" === xtabline
" ===
let g:xtabline_settings = {}
let g:xtabline_settings.enable_mappings = 0
" let g:xtabline_settings.tabline_modes = ['tabs', 'buffers']
let g:xtabline_settings = {
      \ 'relative_paths':           0,
      \ 'tabline_modes':            ['buffers', 'tabs', 'arglist'],
      \ 'buffer_filtering':         1,
      \}
let g:xtabline_settings.enable_persistance = 0
let g:xtabline_settings.last_open_first = 1
noremap to :XTabCycleMode<CR>
noremap \p :XTabInfo<CR>

let g:xtabline_settings.buffers_paths = 0
let g:xtabline_settings.current_tab_paths = 0
let g:xtabline_settings.other_tabs_paths = 0
