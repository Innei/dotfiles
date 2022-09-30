vim.api.nvim_set_option_value("foldmethod", "expr", {})
vim.api.nvim_set_option_value("foldexpr", "nvim_treesitter#foldexpr()", {})

require("nvim-treesitter.configs").setup({
  ensure_installed = {
    "bash",
    "c",
    "cpp",
    "lua",
    "go",
    "gomod",
    "json",
    "yaml",
    "latex",
    "make",
    "python",
    "rust",
    "html",
    "javascript",
    "typescript",
    "vue",
    "css",
  },
  auto_install = true,
  highlight = { enable = true, disable = { "vim" } },
  textobjects = {
    select = {
      enable = true,
      keymaps = {
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
        ["ac"] = "@class.outer",
        ["ic"] = "@class.inner",
      },
    },
    move = {
      enable = true,
      set_jumps = true, -- whether to set jumps in the jumplist
      goto_next_start = {
        ["]["] = "@function.outer",
        ["]m"] = "@class.outer",
      },
      goto_next_end = {
        ["]]"] = "@function.outer",
        ["]M"] = "@class.outer",
      },
      goto_previous_start = {
        ["[["] = "@function.outer",
        ["[m"] = "@class.outer",
      },
      goto_previous_end = {
        ["[]"] = "@function.outer",
        ["[M"] = "@class.outer",
      },
    },
  },
  rainbow = {
    enable = true,
    extended_mode = true, -- Highlight also non-parentheses delimiters, boolean or table: lang -> boolean
    max_file_lines = 1000, -- Do not enable for files with more than 1000 lines, int
  },
  context_commentstring = { enable = true, enable_autocmd = false },
  matchup = { enable = true },
})
require("nvim-treesitter.install").prefer_git = true
local parsers = require("nvim-treesitter.parsers").get_parser_configs()
for _, p in pairs(parsers) do
  p.install_info.url = p.install_info.url:gsub("https://github.com/", "git@github.com:")
end