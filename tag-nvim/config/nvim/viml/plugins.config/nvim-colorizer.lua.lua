vim.o.termguicolors = true
require'colorizer'.setup {}

vim.api.nvim_create_autocmd({ "BufEnter" }, { pattern = {"*"}, command = "ColorizerAttachToBuffer" })