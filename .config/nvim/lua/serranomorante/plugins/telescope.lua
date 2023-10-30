local utils = require("serranomorante.utils")

-- Thanks to AstroNvim config
return {
	{ "nvim-lua/plenary.nvim" },

	-- git-worktree.nvim
	{
		-- https://github.com/ThePrimeagen/git-worktree.nvim/pull/106
		"brandoncc/git-worktree.nvim",
		branch = "catch-and-handle-telescope-related-error",
		lazy = true,
		keys = {
			{
				"<leader>pw",
				function()
					local Job = require("plenary.job")

					local current_file = vim.fn.resolve(vim.fn.expand("%"))
					local file_directory = vim.fn.fnamemodify(current_file, ":p:h")
					local branch_name = utils.branch_name(nil, file_directory)

					Job:new({
						command = "zellij",
						args = {
							"run",
							"-f",
							"--",
							"fish",
						},
						cwd = file_directory,
						on_exit = function()
							Job:new({
								command = "zellij",
								args = {
									"action",
									"rename-pane",
									branch_name,
								},
							}):start()
						end,
					}):start()
				end,
			},
		},
		config = true,
	},

	-- telescope.nvim
	{
		"nvim-telescope/telescope.nvim",
		dependencies = {
			{ "nvim-telescope/telescope-live-grep-args.nvim" },
			{
				"nvim-telescope/telescope-fzf-native.nvim",
				enabled = vim.fn.executable("make") == 1,
				build = "make",
			},
			{ "debugloop/telescope-undo.nvim" },
		},
		keys = {
			{
				"<leader>f<CR>",
				function()
					require("telescope.builtin").resume()
				end,
				desc = "Resume last telescope session",
			},
			{
				"<leader>fb",
				function()
					require("telescope.builtin").buffers()
				end,
				desc = "Buffers",
			},
			{
				"<leader>fh",
				function()
					require("telescope.builtin").help_tags()
				end,
				desc = "Help tags",
			},
			{
				"<leader>fk",
				function()
					require("telescope.builtin").keymaps()
				end,
				desc = "Keymaps",
			},
			{
				"<leader>fm",
				function()
					require("telescope.builtin").man_pages()
				end,
				desc = "Man pages",
			},
			{
				"<leader>fr",
				function()
					require("telescope.builtin").registers()
				end,
				desc = "Registers",
			},
			{
				"<leader>fc",
				function()
					require("telescope.builtin").grep_string()
				end,
				desc = "Find word under cursor",
			},
			{
				"<leader>ff",
				function()
					require("telescope.builtin").find_files({ path_display = { "truncate" } })
				end,
				desc = "Find files",
			},
			{
				"<leader>fF",
				function()
					require("telescope.builtin").find_files({
						hidden = true,
						no_ignore = true,
						path_display = { "truncate" },
					})
				end,
				desc = "Find files (hidden)",
			},
			{
				"<leader>fw",
				function()
					require("telescope.builtin").live_grep()
				end,
				desc = "Live grep",
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
				desc = "Live grep (hidden)",
			},
			{
				"<leader>fg",
				function()
					require("telescope").extensions.live_grep_args.live_grep_args()
				end,
				desc = "Live grep (with args)",
			},
			{
				"<leader>uu",
				function()
					require("telescope").extensions.undo.undo()
				end,
				desc = "Undo history",
			},
			{
				"<leader>gw",
				function()
					require("telescope").extensions.git_worktree.git_worktrees()
				end,
				desc = "Git worktrees",
			},
			{
				"<leader>gW",
				function()
					require("telescope").extensions.git_worktree.create_git_worktree()
				end,
				desc = "Create git worktree",
			},
			{
				"<leader>gc",
				function()
					require("telescope.builtin").git_bcommits()
				end,
				desc = "Git commits (current file)",
			},
			{
				"<leader>gC",
				function()
					require("telescope.builtin").git_commits()
				end,
				desc = "Git commits (repository)",
			},
		},
		opts = function()
			local actions = require("telescope.actions")

			local opts = {
				defaults = {
					git_worktrees = vim.g.git_worktrees,
					path_display = { "shorten" },
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
						n = {
							["q"] = actions.close,

							["ss"] = actions.select_horizontal, -- default: ["<C-x>"]
							["sv"] = actions.select_vertical, -- default: ["<C-v>"]
							["te"] = actions.select_tab, -- default: ["<C-t>"]
							["Q"] = actions.send_selected_to_qflist + actions.open_qflist, -- default: ["<M-q>"]
						},
					},
				},
				extensions = {
					undo = {
						use_delta = false,
					},
				},
				pickers = {
					buffers = {
						show_all_buffers = true,
						sort_lastused = true,
						mappings = {
							n = {
								["<c-d>"] = actions.delete_buffer,
								-- Re-use open buffer instead of opening a new window
								-- Thanks: https://github.com/jensenojs/dotfiles/blob/08cef709e68b25b99173e3445291ff15b666226d/.config/nvim/lua/plugins/ide/telescope.lua#L139
								["<CR>"] = actions.select_tab_drop,
							},
						},
					},
				},
			}

			return opts
		end,
		config = function(_, opts)
			local telescope = require("telescope")
			telescope.setup(opts)
			local conditional_func = utils.conditional_func
			conditional_func(telescope.load_extension, utils.is_available("telescope-fzf-native.nvim"), "fzf")
			-- https://github.com/nvim-telescope/telescope-live-grep-args.nvim
			conditional_func(telescope.load_extension, utils.is_available("live_grep_args"))
			conditional_func(telescope.load_extension, utils.is_available("telescope-undo.nvim"), "undo")
			-- https://github.com/ThePrimeagen/git-worktree.nvim
			conditional_func(telescope.load_extension, utils.is_available("git-worktree.nvim"), "git_worktree")
			-- https://github.com/rmagatti/auto-session#-session-lens
			conditional_func(telescope.load_extension, utils.is_available("auto-sessions"), "session-lens")
		end,
	},
}
