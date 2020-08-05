" Pretty Dress
if !exists('g:vscode')
  " Plug 'theniceboy/eleline.vim'
  " Plug 'mg979/vim-xtabline'
  Plug 'Yggdroot/indentLine', { 'for': ['python', 'yaml', 'bash'], 'on': ['IndentLinesToggle']}
  Plug 'luochen1990/rainbow'
  if !exists('g:started_by_firenvim')
    Plug 'vim-airline/vim-airline'
    Plug 'vim-airline/vim-airline-themes'
  endif
  Plug 'ryanoasis/vim-devicons'

  " ColorScheme
  " Plug 'kaicataldo/material.vim'
  " Plug 'jacoborus/tender.vim'
  " Plug 'dracula/vim'
  Plug 'iamcco/onedark.vim'
  " Plug 'flazz/vim-colorschemes'
endif

" for tsx
" dark red
hi tsxTagName guifg=#E06C75
hi tsxComponentName guifg=#E06C75
hi tsxCloseComponentName guifg=#E06C75

" orange
hi tsxCloseString guifg=#F99575
hi tsxCloseTag guifg=#F99575
hi tsxCloseTagName guifg=#F99575
hi tsxAttributeBraces guifg=#F99575
hi tsxEqual guifg=#F99575

" yellow
hi tsxAttrib guifg=#F8BD7F cterm=italic
" light-grey
hi tsxTypeBraces guifg=#999999
" dark-grey
hi tsxTypes guifg=#666666

hi ReactState guifg=#C176A7
hi ReactProps guifg=#D19A66
hi ApolloGraphQL guifg=#CB886B
hi Events ctermfg=204 guifg=#56B6C2
hi ReduxKeywords ctermfg=204 guifg=#C678DD
hi ReduxHooksKeywords ctermfg=204 guifg=#C176A7
hi WebBrowser ctermfg=204 guifg=#56B6C2
hi ReactLifeCycleMethods ctermfg=204 guifg=#D19A66
