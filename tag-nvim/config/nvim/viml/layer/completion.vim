if !exists('g:vscode')
  " Auto Complete
  Plug 'neoclide/coc.nvim', {'branch': 'release'}

 " Plug 'hrsh7th/cmp-nvim-lsp'
 " Plug 'hrsh7th/cmp-buffer'
 " Plug 'hrsh7th/cmp-path'
 " Plug 'hrsh7th/cmp-cmdline'
 " Plug 'hrsh7th/nvim-cmp'
 " Plug 'hrsh7th/cmp-vsnip'
 " Plug 'hrsh7th/vim-vsnip'
 " Plug 'rafamadriz/friendly-snippets'
 " Plug 'onsails/lspkind-nvim'
 " Plug 'lukas-reineke/lsp-format.nvim'
 " Plug 'neovim/nvim-lspconfig'
 " Plug 'williamboman/nvim-lsp-installer'

  Plug 'github/copilot.vim'

  " Snippets
  " Plug 'Innei/vim-snippets'

  Plug 'mattn/emmet-vim', { 'for': ['html', 'vue'] }

  if (!empty($TMUX))
    Plug 'wellle/tmux-complete.vim'
  endif
endif
