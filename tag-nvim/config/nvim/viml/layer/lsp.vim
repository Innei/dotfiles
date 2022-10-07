function! Load_coc() 
  Plug 'neoclide/coc.nvim', {'branch': 'release'}
endfunction

function! Load_lsp()
  Plug 'hrsh7th/cmp-nvim-lsp'
  Plug 'hrsh7th/cmp-buffer'
  Plug 'hrsh7th/cmp-path'
  Plug 'hrsh7th/cmp-cmdline'
  Plug 'hrsh7th/nvim-cmp'
  Plug 'hrsh7th/cmp-vsnip'
  Plug 'hrsh7th/vim-vsnip'
  Plug 'rafamadriz/friendly-snippets'
  Plug 'onsails/lspkind-nvim'
  " Plug 'lukas-reineke/lsp-format.nvim'
  Plug 'mhartington/formatter.nvim'
  Plug 'neovim/nvim-lspconfig'
  Plug 'williamboman/nvim-lsp-installer'
  Plug 'ray-x/lsp_signature.nvim'
  Plug 'RRethy/vim-illuminate'

endfunction


if !exists('g:vscode')
  " Auto Complete
  " Plug 'neoclide/coc.nvim', {'branch': 'release'}
 call Load_lsp()

 Plug 'github/copilot.vim'

endif