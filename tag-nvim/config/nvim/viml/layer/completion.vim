if !exists('g:vscode')
  " Snippets
  " Plug 'Innei/vim-snippets'

  Plug 'mattn/emmet-vim', { 'for': ['html', 'vue'] }

  if (!empty($TMUX))
    Plug 'wellle/tmux-complete.vim'
  endif
endif
