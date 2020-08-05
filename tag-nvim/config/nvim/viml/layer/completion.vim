if !exists('g:vscode')
  " Auto Complete
  Plug 'neoclide/coc.nvim', {'branch': 'release'}

  " Snippets
  Plug 'Innei/vim-snippets'

  Plug 'mattn/emmet-vim', { 'for': ['html', 'vue', 'javascript', 'javascriptreact', 'typescriptreact'] }
  if (!empty($TMUX))
    Plug 'wellle/tmux-complete.vim'
  endif
endif
