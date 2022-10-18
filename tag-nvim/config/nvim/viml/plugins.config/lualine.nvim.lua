-- local gps = require("nvim-gps")
local navic = require("nvim-navic")
require("lualine").setup({
	options = {
		icons_enabled = true,
		theme = "auto",
		component_separators = { left = "", right = "" },
		section_separators = { left = "", right = "" },
		disabled_filetypes = {
			"coc-explorer",
			"",
			"DiffviewFiles",
			"NvimTree",
			"Trouble",
			"packer",
		},
		ignore_focus = {},
		always_divide_middle = true,
		globalstatus = false,
		refresh = {
			statusline = 1000,
			tabline = 1000,
			winbar = 1000,
		},
	},
	sections = {
		-- lualine_a = { {
		-- 	"mode",
		-- 	icons_enabled = true,
		-- } },
		lualine_a = { { "branch" }, { "diff", source = diff_source } },
		lualine_b = {},
		lualine_c = {
			{ "filename", path = 1, shorting_target = 40 },
			{ navic.get_location, cond = navic.is_available },
		},
		lualine_x = { { "filetype", colored = true, icon_only = true } },
		lualine_y = {
			{
				"diagnostics",
				sources = { "coc", "nvim_lsp", "nvim_diagnostic" },
				-- Displays diagnostics for the defined severity types
				sections = { "error", "warn", "hint" },
				symbols = { error = " ", warn = " ", info = " " },
				colored = true, -- Displays diagnostics status in color if set to true.
			},
		},
		lualine_z = { "progress", "location" },
	},
	inactive_sections = {
		lualine_a = {},
		lualine_b = {},
		lualine_c = { "filename" },
		lualine_x = { "location" },
		lualine_y = {},
		lualine_z = {},
	},
	tabline = {},
	winbar = {
		-- lualine_a = {{'filename', path = 1, shorting_target = 40, }}
	},
	inactive_winbar = {},
	mini_sections = {
		lualine_a = {},
		lualine_b = {},
		lualine_c = {},
		lualine_x = {},
		lualine_y = {},
		lualine_z = { "location" },
	},
	extensions = {
		"fugitive",
	},
})
