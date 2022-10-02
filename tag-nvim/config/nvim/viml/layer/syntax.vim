if !exists('g:vscode')
  " HTML, CSS, JavaScript, PHP, JSON, etc.
  " Plug 'AndrewRadev/tagalong.vim', { 'for': ['javascriptreact', 'javascript', 'html', 'typescriptreact'] } " auto rename tags
  " Plug 'neoclide/jsonc.vim', { 'for': 'jsonc' }
  " Plug 'yuezk/vim-js', { 'for': ['php', 'html', 'javascript', 'css', 'less', 'javascriptreact'] }
  " Plug 'jelera/vim-javascript-syntax', { 'for': ['php', 'html', 'javascript', 'css', 'less', 'javascriptreact'] }
  " Plug 'maxmellon/vim-jsx-pretty', { 'for': ['javascript', 'javascriptreact', 'typescriptreact'] }
  " Plug 'peitalin/vim-jsx-typescript'
  " Plug 'posva/vim-vue', { 'for': 'vue' }
  " Plug 'leafgarland/typescript-vim', { 'for': ['typescript', 'typescriptreact'] }

  Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
  Plug 'p00f/nvim-ts-rainbow'
  Plug 'JoosepAlviste/nvim-ts-context-commentstring'
  Plug 'nvim-treesitter/nvim-treesitter-context'
  Plug 'SmiteshP/nvim-gps'

  " Plug 'windwp/nvim-ts-autotag'
  Plug 'terrortylor/nvim-comment'
endif
