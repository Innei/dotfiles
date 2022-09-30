require'hop'.setup{
  case_insensitive = false,
  current_line_only = false,
  multi_windows = true,
}

vim.api.nvim_set_keymap('', '\'', "<cmd>lua require'hop'.hint_char1({ direction = require'hop.hint'.HintDirection.AFTER_CURSOR })<cr>", {})
vim.api.nvim_set_keymap('', '"', "<cmd>lua require'hop'.hint_char1({ direction = require'hop.hint'.HintDirection.BEFORE_CURSOR })<cr>", {})