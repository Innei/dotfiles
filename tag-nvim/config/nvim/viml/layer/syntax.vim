if !exists('g:vscode')
  " HTML, CSS, JavaScript, PHP, JSON, etc.
  Plug 'neoclide/jsonc.vim', { 'for': 'jsonc' }
  Plug 'yuezk/vim-js', { 'for': ['php', 'html', 'javascript', 'css', 'less', 'javascriptreact'] }
  Plug 'AndrewRadev/tagalong.vim', { 'for': ['javascriptreact', 'javascript', 'html', 'typescriptreact'] } " auto rename tags
  Plug 'jelera/vim-javascript-syntax', { 'for': ['php', 'html', 'javascript', 'css', 'less', 'javascriptreact'] }
  Plug 'maxmellon/vim-jsx-pretty', { 'for': ['javascript', 'javascriptreact', 'typescriptreact'] }
  " Plug 'ruanyl/vim-sort-imports', { 'for': ['javascript', 'typescript', 'typescriptreact'] }
  Plug 'posva/vim-vue', { 'for': 'vue' }
  Plug 'leafgarland/typescript-vim', { 'for': ['typescript', 'typescriptreact'] }
  " Plug 'HerringtonDarkholme/yats.vim', { 'for': ['typescriptreact'] }
  Plug 'peitalin/vim-jsx-typescript'
  " Go
  Plug 'fatih/vim-go' , { 'for': ['go', 'vim-plug'], 'tag': '*' }

  " swift
  "   Plug 'keith/swift.vim', { 'for': ['swift'] }
  " Tex
  "   Plug 'lervag/vimtex'
  Plug 'sheerun/vim-polyglot'
endif
