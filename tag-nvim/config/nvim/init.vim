" Author:   Innei
" Github:   https://github.com/innei
" License:  MIT

scriptencoding utf-8

let s:script_path = expand('<sfile>:p:h')

let s:sourceList = [
      \ 'init',
      \ 'mapping',
      \ 'plugins',
      \ 'functions',
      \ 'commands',
      \ 'autocmds',
      \ 'plugins.config',
      \ 'style',
      \]

for s:item in s:sourceList
  exec 'source ' . s:script_path . '/viml/' . s:item . '.vim'
endfor

if exists('g:vscode')
  exec 'source ' . s:script_path . '/viml/vscode.vim'
else
  exec 'source ' . s:script_path . '/viml/general.vim'
endif

if has('nvim')
  exec 'source ' . s:script_path . '/viml/neovim.vim'
endif

" Free memory
unlet s:script_path
unlet s:sourceList
