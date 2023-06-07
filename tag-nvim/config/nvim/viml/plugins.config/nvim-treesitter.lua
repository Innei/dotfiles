vim.api.nvim_set_option_value("foldmethod", "expr", {})
vim.api.nvim_set_option_value("foldexpr", "nvim_treesitter#foldexpr()", {})

require("nvim-treesitter.configs").setup({
  ensure_installed = {
    "bash",
    "lua",
    "make",
    "yaml",
    "rust",
    "json",
    "html",
    "javascript",
    "typescript",
    "vue",
    "css",
    "tsx",
    "git_rebase"
  },
  auto_install = true,
  highlight = {
    enable = true,
    disable = function(lang, buf)
      local max_filesize = 100 * 1024 -- 100 KB
      local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
      if ok and stats and stats.size > max_filesize then
        return true
      end
    end,
  },
  rainbow = {
    disable = {
      "html", "vim"
    },
    enable = true,
    extended_mode = true,
    -- loaded = true,
    module_path = "rainbow.internal",
    termcolors = { "Red", "Green", "Yellow", "Blue", "Magenta", "Cyan", "White" },
    colors = { "#ff99d7", "#ffd372", "#ff74b1", "#f5c7a9", "#8bbccc", "#90b77d", "#42c2ff" },
    max_file_lines = 1000, -- Do not enable for files with more than 1000 lines, int
  },
  context_commentstring = { enable = true, enable_autocmd = false },
  matchup = { enable = true },
  textsubjects = {
    enable = true,
    keymaps = {
      ['<cr>'] = 'textsubjects-smart',
    },
  },
  autotag = {
    enable = true,
  }
})
require("nvim-treesitter.install").prefer_git = true
local parsers = require("nvim-treesitter.parsers").get_parser_configs()
for _, p in pairs(parsers) do
  p.install_info.url = p.install_info.url:gsub("https://github.com/", "git@github.com:")
end
