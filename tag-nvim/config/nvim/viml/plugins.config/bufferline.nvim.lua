local opts = {
  options = {
    number = nil,
    modified_icon = "",
    buffer_close_icon = "",
    left_trunc_marker = "",
    right_trunc_marker = "",
    max_name_length = 14,
    max_prefix_length = 13,
    tab_size = 20,
    show_buffer_close_icons = true,
    show_buffer_icons = true,
    show_tab_indicators = true,
    diagnostics = "coc",
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


require("bufferline").setup(opts)