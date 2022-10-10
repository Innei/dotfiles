" Editor Enhancement
Plug 'wellle/targets.vim'
Plug 'tpope/vim-surround' " type yskw' to wrap the word with '' or type cs'` to change 'word' to `word`
Plug 'junegunn/vim-easy-align' " gaip= to align the = in paragraph,
Plug 'andymass/vim-matchup' " Extends vim's % motion to language-specific words.
Plug 'AndrewRadev/switch.vim' " gs to switch
Plug 'AndrewRadev/splitjoin.vim'  " gS to split line, gJ to join lines
" Plug 'schickling/vim-bufonly'
" Plug 'gcmt/wildfire.vim' " in Visual mode, type i' to select all text in '', or type i) i] i} ip

if !exists('g:vscode')
  Plug 'rhysd/accelerated-jk'
  Plug 'voldikss/vim-floaterm'
  " Plug 'norcalli/nvim-colorizer.lua'
  Plug 'jesseleite/vim-noh' " A vim plugin for automatically clearing search highlighting when cursor is moved.
  Plug 'romainl/vim-cool' " A very simple plugin that makes hlsearch more useful.
  Plug 'kristijanhusak/vim-carbon-now-sh', { 'on': 'CarbonNowSh' }
  Plug 'dstein64/nvim-scrollview'
  Plug 'windwp/nvim-autopairs'
  Plug 'kkoomen/vim-doge', { 'on': ['DogeGenerate', 'DogeCreateDocStandard'] } " document genertor
  Plug 'mg979/vim-visual-multi', {'branch': 'master'}
  Plug 'Konfekt/FastFold'
  Plug 'sgur/vim-editorconfig'
  Plug 'airblade/vim-rooter' " auto change project cwd
  Plug 'tpope/vim-sleuth' " auto adjust tabwidth base on current file
  " Plug 'wellle/context.vim'
  Plug 'famiu/bufdelete.nvim' " Neovim's default :bdelete command can be quite annoying, since it also messes up your entire window layout by deleting windows. 
  Plug 'edluffy/specs.nvim' " Show where your cursor moves when jumping large distances (e.g between windows). Fast and lightweight, written completely in Lua.

  Plug 'dstein64/vim-startuptime', { 'on': 'StartupTime' }
  " Plug 'thaerkh/vim-workspace'
  Plug 'skywind3000/asyncrun.vim'
  Plug 'ConradIrwin/vim-bracketed-paste'
  Plug '907th/vim-auto-save', { 'on': 'AutoSaveToggle', 'for': ['text', 'markdown', 'tex'] }

  Plug 'max397574/better-escape.nvim'
  Plug 'akinsho/bufferline.nvim', { 'tag': 'v2.*' }
  
  " Plug 'kdheepak/tabline.nvim'
  " Plug 'rcarriga/nvim-notify'

  Plug 'nvim-lualine/lualine.nvim'
  Plug 'lukas-reineke/indent-blankline.nvim'
  " Plug 'fgheng/winbar.nvim'
  " Plug 'Shatur/neovim-session-manager'
  Plug 'Shatur/neovim-session-manager'

  if !exists('g:started_by_firenvim')
    Plug 'kyazdani42/nvim-web-devicons'
    Plug 'mhinz/vim-startify'
  endif

  " Dependencies
  " Plug 'roxma/nvim-yarp'
endif


