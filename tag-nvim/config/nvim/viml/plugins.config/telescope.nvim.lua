-- local telescope_actions = require("telescope.actions.set")
local fixfolds = {
	hidden = true,
	-- attach_mappings = function(_)
	-- 	telescope_actions.select:enhance({
	-- 		post = function()
	-- 			vim.cmd(":normal! zx")
	-- 		end,
	-- 	})
	-- 	return true
	-- end,
}
require("telescope").setup({
	defaults = {
		file_ignore_patterns = {"node_modules"},
		find_command = {"rg", "--no-ignore", "--files"},
		initial_mode = "insert",
		prompt_prefix = " ❯ ",
		selection_caret = " ",
		entry_prefix = " ",
		scroll_strategy = "limit",
		results_title = false,
		borderchars = { " ", " ", " ", " ", " ", " ", " ", " " },
		layout_strategy = "horizontal",
		path_display = { "absolute" },
		file_ignore_patterns = { ".git/", ".cache", "%.class", "%.pdf", "%.mkv", "%.mp4", "%.zip", ".DS_Store" },
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
		coc = {
			theme = 'ivy',
			prefer_locations = true, -- always use Telescope locations to preview definitions/declarations/implementations etc
		}
	},
	pickers = {
		buffers = fixfolds,
		find_files = {
			find_command = { "rg", "--files", "--hidden", "--follow" },
			hidden = true
		},
		git_files = fixfolds,
		grep_string = fixfolds,
		live_grep = fixfolds,
		oldfiles = fixfolds,
	},
})

vim.api.nvim_set_keymap("n", "<leader>;", "<cmd>Telescope commands<cr>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>t", "<cmd>Telescope<cr>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<C-r>", "<cmd>Telescope grep_string<cr>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<C-f>", "<cmd>Telescope live_grep<cr>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<C-p>", "<cmd>Telescope find_files<cr>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>gs", "<cmd>Telescope git_status<cr>", { noremap = true, silent = true })


require('telescope').load_extension('fzf')
require 'telescope'.load_extension('project')
require('telescope').load_extension('coc')
