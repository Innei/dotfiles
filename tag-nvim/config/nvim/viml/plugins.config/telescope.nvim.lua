local telescope_actions = require("telescope.actions.set")
local fixfolds = {
	hidden = true,
	attach_mappings = function(_)
		telescope_actions.select:enhance({
			post = function()
				vim.cmd(":normal! zx")
			end,
		})
		return true
	end,
}
require("telescope").setup({
	defaults = {
		initial_mode = "insert",
		prompt_prefix = "  ",
		selection_caret = " ",
		entry_prefix = " ",
		scroll_strategy = "limit",
		results_title = false,
		borderchars = { " ", " ", " ", " ", " ", " ", " ", " " },
		layout_strategy = "horizontal",
		path_display = { "absolute" },
		file_ignore_patterns = { ".git/", ".cache", "%.class", "%.pdf", "%.mkv", "%.mp4", "%.zip" },
		layout_config = {
			prompt_position = "bottom",
			horizontal = {
				preview_width = 0.5,
			},
		},
		file_previewer = require("telescope.previewers").vim_buffer_cat.new,
		grep_previewer = require("telescope.previewers").vim_buffer_vimgrep.new,
		qflist_previewer = require("telescope.previewers").vim_buffer_qflist.new,
		file_sorter = require("telescope.sorters").get_fuzzy_file,
		generic_sorter = require("telescope.sorters").get_generic_fuzzy_sorter,
	},
	extensions = {
		fzf = {
			fuzzy = true,
			override_generic_sorter = true,
			override_file_sorter = true,
			case_mode = "smart_case",
		},
		frecency = {
			show_scores = true,
			show_unindexed = true,
			ignore_patterns = { "*.git/*", "*/tmp/*" },
		},
	},
	pickers = {
		buffers = fixfolds,
		find_files = fixfolds,
		git_files = fixfolds,
		grep_string = fixfolds,
		live_grep = fixfolds,
		oldfiles = fixfolds,
	},
})
