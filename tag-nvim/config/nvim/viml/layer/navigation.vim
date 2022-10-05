Plug 'easymotion/vim-easymotion'

if !exists('g:vscode')
  Plug 'mbbill/undotree'
  " Plug 'junegunn/fzf.vim'
  " Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
  Plug 'liuchengxu/vista.vim'
  Plug 'kevinhwang91/rnvimr', {'do': 'make sync'}
  " Plug 'yuki-ycino/fzf-preview.vim'
  " Plug 'phaazon/hop.nvim', {'branch': 'v2'} " https://github.com/phaazon/hop.nvim/issues/278

  Plug 'nvim-telescope/telescope.nvim', { 'tag': '0.1.x' }
  Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'make' }
  Plug 'nvim-telescope/telescope-project.nvim'
  Plug 'fannheyward/telescope-coc.nvim'
  " Plug 'nvim-telescope/telescope-fzf-writer.nvim'

  Plug 'folke/which-key.nvim', {'on': 'WhichKey'}

  " deps of telescope, diffview
  Plug 'nvim-lua/plenary.nvim'
  " Plug 'kkharji/sqlite.lua'
else
endif
