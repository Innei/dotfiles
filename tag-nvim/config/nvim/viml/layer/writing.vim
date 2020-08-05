if !exists('g:vscode')
  " For general writing
  Plug 'junegunn/goyo.vim', { 'for': ['markdown', 'text', 'tex'], 'on': 'Goyo' }
  Plug 'amix/vim-zenroom2', { 'for': ['markdown', 'text', 'tex'], 'on': 'Goyo' }
  " Plug 'glacambre/firenvim', { 'do': { _ -> firenvim#install(0) } }
  " Markdown
  Plug 'dhruvasagar/vim-table-mode', { 'on': 'TableModeToggle', 'for': 'markdown' }
  Plug 'theniceboy/bullets.vim'
endif
