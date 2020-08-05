
" ===
" === vim-visual-multi
" ===
let g:VM_default_mappings             = 0
let g:VM_maps                         = {}
let g:VM_maps['Find Under']           = '<C-d>'           " replace C-n
let g:VM_maps['Find Subword Under']   = '<C-d>'           " replace visual C-n
let g:VM_maps["Select All"]           = '<leader>A'
let g:VM_mouse_mappings               = 1
" let g:VM_leader                       = { 'default': '\', 'visual': '''', 'buffer': '\'}
let g:VM_maps["Case Conversion Menu"] = '<leader>cc'
let g:VM_maps["Switch Mode"]          = '<Tab>'
let g:VM_maps["Tools Menu"]           = '<leader>`'
let g:VM_maps['Skip Region']          = '<c-n>'
let g:VM_maps["Undo"]                 = 'u'
let g:VM_maps["Redo"]                 = 'r'
let g:VM_maps['Remove Region']        = 'q'