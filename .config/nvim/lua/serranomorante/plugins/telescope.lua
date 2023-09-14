local utils = require("serranomorante.utils")

-- Thanks to AstroNvim config
return {
	{ "nvim-lua/plenary.nvim" },

	{
		-- https://github.com/ThePrimeagen/git-worktree.nvim/pull/106
		"brandoncc/git-worktree.nvim",
		branch = "catch-and-handle-telescope-related-error",
		config = function(_, opts)
			local Worktree = require("git-worktree")
			Worktree.setup(opts)

			local Job = require("plenary.job")

			Worktree.on_tree_change(function(op, metadata)
				if op == Worktree.Operations.Switch then
					local pane_name = utils.shorten(metadata.path, 20, true)

					if vim.t.zellij_worktree_switch_history == nil then
						vim.t.zellij_worktree_switch_history = {}
					end

					-- Stop further execution if there's already a floating pane
					-- for this worktree
					if vim.tbl_contains(vim.t.zellij_worktree_switch_history, metadata.path) then
						return
					end

					local function toggle_zellij_floating_window()
						Job:new({
							command = "zellij",
							args = {
								"action",
								"toggle-floating-panes",
							},
						}):start()
					end

					local function rename_zellij_pane()
						Job:new({
							command = "zellij",
							args = {
								"action",
								"rename-pane",
								pane_name,
							},
							on_exit = toggle_zellij_floating_window,
						}):start()
					end

					local function new_zellij_floating_pane()
						Job:new({
							command = "zellij",
							args = {
								"run",
								"-f",
								"--",
								"fish",
							},
							on_exit = function()
								local history = vim.t.zellij_worktree_switch_history
								table.insert(history, 1, metadata.path)
								vim.t.zellij_worktree_switch_history = history

								rename_zellij_pane()
							end,
						}):start()
					end

					new_zellij_floating_pane()
				end
			end)
		end,
	},

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
			{ "rmagatti/auto-session" },
		},
		event = "VeryLazy",
		keys = {
			{
				"<leader>f<CR>",
				function()
					require("telescope.builtin").resume()
				end,
			},
			{
				"<leader>fb",
				function()
					require("telescope.builtin").buffers()
				end,
			},
			{
				"<leader>fh",
				function()
					require("telescope.builtin").help_tags()
				end,
			},
			{
				"<leader>fk",
				function()
					require("telescope.builtin").keymaps()
				end,
			},
			{
				"<leader>fm",
				function()
					require("telescope.builtin").man_pages()
				end,
			},
			{
				"<leader>fr",
				function()
					require("telescope.builtin").registers()
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
					require("telescope.builtin").find_files({ path_display = { "truncate" } })
				end,
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
			{
				"<leader>gw",
				function()
					require("telescope").extensions.git_worktree.git_worktrees()
				end,
			},
			{
				"<leader>gW",
				function()
					require("telescope").extensions.git_worktree.create_git_worktree()
				end,
			},
			{
				"<leader>xf",
				function()
					require("auto-session.session-lens").search_session()
				end,
			},
		},
		opts = function()
			local actions = require("telescope.actions")
			return {
				defaults = {
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
					-- Re-use open buffer instead of opening a new window
					-- Thanks: https://github.com/jensenojs/dotfiles/blob/08cef709e68b25b99173e3445291ff15b666226d/.config/nvim/lua/plugins/ide/telescope.lua#L139
					buffers = {
						show_all_buffers = true,
						sort_lastused = true,
						mappings = {
							n = {
								["<c-d>"] = actions.delete_buffer,
								["<CR>"] = actions.select_tab_drop,
							},
						},
					},
				},
			}
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
