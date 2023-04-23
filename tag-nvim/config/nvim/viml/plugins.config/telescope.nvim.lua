local actions = require("telescope.actions")

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
		mappings = {
			i = {
				["<Esc>"] = actions.close,       -- don't go into normal mode, just close
				["<C-j>"] = actions.move_selection_next, -- scroll the list with <c-j>
				["<C-k>"] = actions.move_selection_previous, -- scroll the list with <c-k>
				-- ["<C-\\->"] = actions.select_horizontal, -- open selection in new horizantal split
				-- ["<C-\\|>"] = actions.select_vertical, -- open selection in new vertical split
				["<C-t>"] = actions.select_tab, -- open selection in new tab
				["<C-y>"] = actions.preview_scrolling_up,
				["<C-e>"] = actions.preview_scrolling_down,
			},
		},
		vimgrep_arguments = {
			"rg",
			"--color=never",
			"--no-heading",
			"--with-filename",
			"--line-number",
			"--column",
			"--smart-case",
			"--trim",
		},
		initial_mode = "insert",
		selection_strategy = "reset",
		sorting_strategy = "ascending",
		layout_strategy = "horizontal",
		layout_config = {
			horizontal = {
				prompt_position = "top",
				preview_width = 0.55,
				results_width = 0.8,
			},
			vertical = {
				mirror = false,
			},
			width = 0.87,
			height = 0.80,
			preview_cutoff = 120,
		},
		path_display = { "truncate" },
		winblend = 0,
		border = {},
		borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
		color_devicons = true,
		use_less = true,
		set_env = { ["COLORTERM"] = "truecolor" }, -- default = nil,
		-- Developer configurations: Not meant for general override
		buffer_previewer_maker = require("telescope.previewers").buffer_previewer_maker,
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
			theme = "ivy",
			prefer_locations = true, -- always use Telescope locations to preview definitions/declarations/implementations etc
		},
	},
	pickers = {
		buffers = fixfolds,
		find_files = {
			find_command = { "rg", "--files", "--hidden", "--follow" },
			hidden = true,
		},
		git_files = fixfolds,
		grep_string = fixfolds,
		live_grep = fixfolds,
		oldfiles = fixfolds,
		colorscheme = {
			enable_preview = true
		}
	},
})

vim.api.nvim_set_keymap("n", "<leader>;", "<cmd>Telescope commands<cr>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>tl", "<cmd>Telescope<cr>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>tb", "<cmd>Telescope buffers<cr>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<C-r>", "<cmd>Telescope grep_string<cr>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<C-f>", "<cmd>Telescope live_grep<cr>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<C-p>", "<cmd>Telescope find_files<cr>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>gs", "<cmd>Telescope git_status<cr>", { noremap = true, silent = true })

local hasCoc = vim.g.coc_global_extensions ~= nil

require("telescope").load_extension("fzf")
require("telescope").load_extension("project")
if hasCoc then
	require("telescope").load_extension("coc")
end
require("telescope").load_extension("node_modules")
require("telescope").load_extension("neoclip")
require("telescope").load_extension("tmux")
require("telescope").load_extension("frecency")
