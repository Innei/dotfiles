if !exists('g:vscode')
  Plug 'mbbill/undotree'
  Plug 'junegunn/fzf.vim'
  Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
  Plug 'liuchengxu/vista.vim'
  Plug 'kevinhwang91/rnvimr', {'do': 'make sync'}
  " Plug 'yuki-ycino/fzf-preview.vim'
  " Plug 'easymotion/vim-easymotion'
  Plug 'phaazon/hop.nvim', {'branch': 'v2'}

  Plug 'nvim-telescope/telescope.nvim', { 'tag': '0.1.x' }
  Plug 'nvim-telescope/telescope-fzf-native.nvim'
  Plug 'nvim-telescope/telescope-project.nvim'
  Plug 'nvim-telescope/telescope-frecency.nvim'

  Plug 'folke/which-key.nvim', {'on': 'WhichKey'}

  " deps of telescope, diffview
  Plug 'nvim-lua/plenary.nvim'
  Plug 'kkharji/sqlite.lua'
else
endif
