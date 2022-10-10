function! Load_coc() 
  Plug 'neoclide/coc.nvim', {'branch': 'release'}
endfunction

function! Load_lsp()
  Plug 'hrsh7th/cmp-nvim-lsp'
  Plug 'hrsh7th/cmp-buffer'
  Plug 'hrsh7th/cmp-path'
  Plug 'hrsh7th/cmp-cmdline'
  Plug 'hrsh7th/nvim-cmp'
  Plug 'onsails/lspkind-nvim'
  " Plug 'lukas-reineke/lsp-format.nvim'
  " Plug 'mhartington/formatter.nvim'
  Plug 'creativenull/efmls-configs-nvim', { 'tag': 'v0.1.2' } " tag is optional
  Plug 'neovim/nvim-lspconfig'
  " Plug 'williamboman/nvim-lsp-installer'
  Plug 'williamboman/mason.nvim'
  Plug 'williamboman/mason-lspconfig.nvim'
  Plug 'ray-x/lsp_signature.nvim'
  Plug 'RRethy/vim-illuminate'
  Plug 'folke/trouble.nvim'
  Plug 'folke/lsp-colors.nvim'
  Plug 'kyazdani42/nvim-tree.lua'
  " Plug 'hrsh7th/cmp-copilot'
  Plug 'f3fora/cmp-spell'
  Plug 'SmiteshP/nvim-navic'
  Plug 'glepnir/lspsaga.nvim', { 'branch': 'main' }

  " snippets
  Plug 'rafamadriz/friendly-snippets'
  Plug 'saadparwaiz1/cmp_luasnip'
  Plug 'L3MON4D3/LuaSnip'
  " Plug 'hrsh7th/vim-vsnip'
  " Plug 'hrsh7th/cmp-vsnip'

endfunction


if !exists('g:vscode')
  " Auto Complete
  " Plug 'neoclide/coc.nvim', {'branch': 'release'}
 call Load_lsp()

 Plug 'github/copilot.vim'

endif