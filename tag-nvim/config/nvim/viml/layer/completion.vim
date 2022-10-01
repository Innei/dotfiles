if !exists('g:vscode')
  " Auto Complete
  Plug 'neoclide/coc.nvim', {'branch': 'release'}
  Plug 'github/copilot.vim'

  " Snippets
  Plug 'Innei/vim-snippets'

  Plug 'mattn/emmet-vim', { 'for': ['html', 'vue'] }

  if (!empty($TMUX))
    Plug 'wellle/tmux-complete.vim'
  endif
endif
