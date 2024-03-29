local opts = {
  options = {
    number = nil,
    modified_icon = "",
    buffer_close_icon = "×",
    left_trunc_marker = "",
    right_trunc_marker = "",
    max_name_length = 14,
    max_prefix_length = 13,
    tab_size = 20,
    show_buffer_close_icons = true,
    show_buffer_icons = true,
    show_tab_indicators = true,
    diagnostics = "nvim_lsp",
    always_show_bufferline = true,
    separator_style = "thin",
    offsets = {
      {
        filetype = "NvimTree",
        text = "File Explorer",
        text_align = "center",
        padding = 1,
      },

      {
        filetype = 'coc-explorer',
        text = "Coc Explorer",
        text_align = "center",
        padding = 1,
      },
    },
    diagnostics_indicator = function(count)
      return "(" .. count .. ")"
    end,
  },
  -- Change bufferline's highlights here! See `:h bufferline-highlights` for detailed explanation.
  -- Note: If you use catppuccin then modify the colors below!
  highlights = {},
}


if vim.g.colors_name == "catppuccin" then
  local cp = require("catppuccin.palettes").get_palette() -- Get the palette.
  cp.none = "NONE" -- Special setting for complete transparent fg/bg.

  local catppuccin_hl_overwrite = {
    highlights = require("catppuccin.groups.integrations.bufferline").get({
      styles = { "italic", "bold" },
      custom = {
        mocha = {
          -- Hint
          hint = { fg = cp.rosewater },
          hint_visible = { fg = cp.rosewater },
          hint_selected = { fg = cp.rosewater },
          hint_diagnostic = { fg = cp.rosewater },
          hint_diagnostic_visible = { fg = cp.rosewater },
          hint_diagnostic_selected = { fg = cp.rosewater },
        },
      },
    }),
  }

  opts = vim.tbl_deep_extend("force", opts, catppuccin_hl_overwrite)
end

require("bufferline").setup(opts)

vim.cmd([[command! -nargs=0 BufOnly .,$-bdelete]])
