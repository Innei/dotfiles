" Editor Enhancement
Plug 'wellle/targets.vim'
Plug 'tpope/vim-surround' " type yskw' to wrap the word with '' or type cs'` to change 'word' to `word`
Plug 'kristijanhusak/vim-carbon-now-sh', { 'on': 'CarbonNowSh' }
Plug 'junegunn/vim-easy-align' " gaip= to align the = in paragraph,
Plug 'andymass/vim-matchup' " Extends vim's % motion to language-specific words.
Plug 'AndrewRadev/switch.vim' " gs to switch
Plug 'AndrewRadev/splitjoin.vim'  " gS to split line, gJ to join lines
Plug 'tomtom/tcomment_vim'
Plug 'jesseleite/vim-noh'
Plug 'gcmt/wildfire.vim' " in Visual mode, type i' to select all text in '', or type i) i] i} ip
Plug 'alpertuna/vim-header'
Plug 'voldikss/vim-floaterm'
" Plug 'xolox/vim-session'
" Plug 'xolox/vim-misc' vim-session dep
" Plug 'terryma/vim-multiple-cursors'
" Plug 'scrooloose/nerdcommenter'
" Plug 'junegunn/vim-peekaboo'
" Plug 'junegunn/vim-after-object' " da= to delete what's after =

if !exists('g:vscode')

  Plug 'wakatime/vim-wakatime'
  let g:wakatime_PythonBinary = '/usr/bin/python3'

  Plug 'jiangmiao/auto-pairs'
  Plug 'kkoomen/vim-doge', { 'on': ['DogeGenerate', 'DogeCreateDocStandard'] } " document genertor
  Plug 'mg979/vim-visual-multi', {'branch': 'master'}
  Plug 'Konfekt/FastFold'
  Plug 'wellle/context.vim'
  " Plug 'tyru/caw.vim'
  Plug 'Shougo/context_filetype.vim'
  Plug 'sgur/vim-editorconfig'
  Plug 'airblade/vim-rooter'
  Plug 'tpope/vim-sleuth' " auto adjust tabwidth base on current file
  Plug 'tweekmonster/startuptime.vim', { 'on': 'StartupTime' }
  " Plug 'brooth/far.vim', { 'on': ['F', 'Far', 'Fardo'] }
  Plug 'thaerkh/vim-workspace'
  " Plug 'osyo-manga/vim-anzu'
  Plug 'skywind3000/asyncrun.vim'
  Plug 'ConradIrwin/vim-bracketed-paste'
  Plug 'schickling/vim-bufonly'
  Plug '907th/vim-auto-save', { 'on': 'AutoSaveToggle', 'for': ['text', 'markdown', 'tex'] }

  " Dependencies
  Plug 'MarcWeber/vim-addon-mw-utils'
  " Plug 'kana/vim-textobj-user'
  Plug 'roxma/nvim-yarp'
  if !exists('g:started_by_firenvim')
    Plug 'mhinz/vim-startify'
  endif
endif


