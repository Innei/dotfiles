" === startify
nnoremap <LEADER>st :Startify<CR>
let g:startify_session_dir= $HOME."/.config/nvim/tmp/sessions"
let g:startify_lists = [
      \ { 'type': 'sessions',  'header': ['   Sessions']       },
      \ { 'type': 'dir',       'header': ['   Dirs '. getcwd()] },
      \ { 'type': 'files',     'header': ['   Files']            },
      \ { 'type': 'bookmarks', 'header': ['   Bookmarks']      },
      \ { 'type': 'commands',  'header': ['   Commands']       },
      \ ]

let g:startify_files_number = 5
let g:startify_change_to_vcs_root = 1
let g:startify_session_sort = 1
let g:startify_relative_path = 1
let g:startify_bookmarks = [
      \ { 'v': '~/.config/nvim' },
      \ { 'z': '~/.zshrc' },
      \ ]
