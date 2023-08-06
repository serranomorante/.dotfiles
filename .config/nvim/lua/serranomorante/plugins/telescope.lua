-- Thanks to AstroNvim config
return {
	"nvim-telescope/telescope.nvim",
	tag = "0.1.1",
	dependencies = {
		{ "nvim-lua/plenary.nvim" },
		{ "nvim-telescope/telescope-live-grep-args.nvim" },
		{
			"nvim-telescope/telescope-fzf-native.nvim",
			enabled = vim.fn.executable("make") == 1,
			build = "make",
		},
		{ "debugloop/telescope-undo.nvim" },
	},
	lazy = false,
	keys = {
		{
			"<leader>f<CR>",
			function()
				require("telescope.builtin").resume()
			end,
		},
		{
			"<leader>fc",
			function()
				require("telescope.builtin").grep_string()
			end,
		},
		{
			"<leader>ff",
			function()
				require("telescope.builtin").find_files()
			end,
		},
		{
			"<leader>fF",
			function()
				require("telescope.builtin").find_files({ hidden = true, no_ignore = true })
			end,
		},
		{
			"<leader>fw",
			function()
				require("telescope.builtin").live_grep()
			end,
		},
		{
			"<leader>fW",
			function()
				require("telescope.builtin").live_grep({
					additional_args = function(args)
						return vim.list_extend(args, { "--hidden", "--no-ignore" })
					end,
				})
			end,
		},
		{
			"<leader>fg",
			function()
				require("telescope").extensions.live_grep_args.live_grep_args()
			end,
		},
		{
			"<leader>uu",
			function()
				require("telescope").extensions.undo.undo()
			end,
		},
	},
	opts = function()
		local actions = require("telescope.actions")
		return {
			defaults = {
				path_display = { "truncate" },
				sorting_strategy = "ascending",
				layout_config = {
					horizontal = {
						prompt_position = "top",
						preview_width = 0.55,
					},
					vertical = {
						mirror = false,
					},
					width = 0.87,
					height = 0.80,
					preview_cutoff = 120,
				},

				mappings = {
					i = {
						["<C-l>"] = actions.cycle_history_next,
						["<C-h>"] = actions.cycle_history_prev,
					},
					n = { ["q"] = actions.close },
				},
			},
			extensions = {
				undo = {
					use_delta = false,
				},
			},
		}
	end,
	config = function(_, opts)
		local telescope = require("telescope")
		telescope.setup(opts)
		local utils = require("serranomorante.utils")
		local conditional_func = utils.conditional_func
		conditional_func(telescope.load_extension, utils.is_available("telescope-fzf-native.nvim"), "fzf")
		-- https://github.com/nvim-telescope/telescope-live-grep-args.nvim
		conditional_func(telescope.load_extension, utils.is_available("live_grep_args"))
		conditional_func(telescope.load_extension, utils.is_available("telescope-undo.nvim"), "undo")
	end,
}
