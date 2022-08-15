if !exists('g:vscode')
  Plug 'mbbill/undotree'
  Plug 'junegunn/fzf.vim'
  Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
  Plug 'liuchengxu/vista.vim'
  Plug 'kevinhwang91/rnvimr', {'do': 'make sync'}
  " Plug 'yuki-ycino/fzf-preview.vim'
  Plug 'easymotion/vim-easymotion'
else
endif
