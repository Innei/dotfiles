vim.o.runtimepath = vim.o.runtimepath .. "," .. os.getenv("HOME") .. "/.config/nvim/my-snippets/,"

require("luasnip").config.set_config({
  history = false
})

require("luasnip.loaders.from_lua").lazy_load()
require("luasnip.loaders.from_vscode").lazy_load()
