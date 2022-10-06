require("onedarkpro").setup({
  dark_theme = "onedark", -- The default dark theme
  light_theme = "onelight", -- The default light theme
  caching = true, -- Use caching for the theme?
  cache_path = vim.fn.expand(vim.fn.stdpath("cache") .. "/onedarkpro/"), -- The path to the cache directory
  plugins = {
    nvim_ts_rainbow = false,
    native_lsp = true,
    treesitter = true,

    copilot = true, startify = true, telescope = true, which_key = true, gitsigns = false
  },
  colors = {
    cursorline = "#2D313B" -- This is optional. The default cursorline color is based on the background
  },
  options = {
    cursorline = true,
    terminal_colors = true,
    underline = true
  }

})

vim.cmd("colorscheme onedarkpro") -- Lua
