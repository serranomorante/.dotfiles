local utils = require("serranomorante.utils")

--- A delta previewer for git status, commits and bcommits
---
--- You should copy this `.gitconfig` pager change for scroll (<C-d> and <C-u>) to work
--- https://github.com/dandavison/delta/issues/630#issuecomment-860046929
---
---@param previewers table Don't import the telescope `previewers` inside this function to avoid issues. Use only from parameter.
---@param mode string? The preview git mode: bcommits, commits, etc.
---@param worktree table<string, string>? Make the previewer compatible with `.dotfiles`
local get_delta_previewer = function(previewers, mode, worktree)
	local delta = previewers.new_termopen_previewer({
		get_command = function(entry)
			local args = { "git", "diff" }

			-- Make it compatible with `.dotfiles`
			local worktree_match = worktree or utils.file_worktree() -- don't rely on `utils.file_worktree()` in here. Prefer the passing the param.
			if worktree_match ~= nil then
				table.insert(args, 2, ("--work-tree=%s"):format(worktree_match.toplevel))
				table.insert(args, 2, ("--git-dir=%s"):format(worktree_match.gitdir))
			end

			-- git commits and git bcommits
			if mode == "bcommits" then
				table.insert(args, entry.value .. "^!")
				table.insert(args, "--")
				table.insert(args, vim.fn.expand("#:p"))
			elseif mode == "commits" then
				table.insert(args, entry.value .. "^!")
			-- git status
			elseif mode == "status" then
				local value = worktree_match and ("%s/%s"):format(worktree_match.toplevel, entry.value) or entry.value
				table.insert(args, value)
			-- fallback
			else
				table.insert(args, entry.value .. "^!")
			end

			return args
		end,
	})
	return delta
end

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
				"<leader>pf",
				function()
					local Job = require("plenary.job")

					local current_file = vim.fn.resolve(vim.fn.expand("%"))
					local file_directory = vim.fn.fnamemodify(current_file, ":p:h")
					local branch_name = utils.branch_name(nil, file_directory)

					if vim.env.TMUX ~= nil then
						Job:new({
							command = "tmux",
							args = {
								"split-window",
							},
							cwd = file_directory,
						}):start()
					elseif vim.env.ZELLIJ == "0" then
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
					end
				end,
				desc = "Open tmux/zellij pane inside worktree",
			},
			{
				"<leader>pw",
				function()
					vim.ui.input({ prompt = "Git branch: " }, function(branch)
						local data = {}
						data.git_branch = branch

						vim.ui.input({ prompt = "Unique path: " }, function(path)
							data.unique_path = path

							require("git-worktree").create_worktree(data.unique_path, data.git_branch)
						end)
					end)
				end,
				desc = "Create new worktree",
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
					local worktree = utils.file_worktree()
					local previewers = require("telescope.previewers")
					local delta = get_delta_previewer(previewers, "bcommits", worktree)
					local options = { previewer = delta }
					require("telescope.builtin").git_bcommits(options)
				end,
				desc = "List commits for current buffer (bcommits)",
			},
			{
				"<leader>gC",
				function()
					local worktree = utils.file_worktree()
					local previewers = require("telescope.previewers")
					local delta = get_delta_previewer(previewers, "commits", worktree)
					local options = { previewer = delta }
					require("telescope.builtin").git_commits(options)
				end,
				desc = "List commits for current directory",
			},
			{
				"<leader>gt",
				function()
					local worktree = utils.file_worktree()
					local previewers = require("telescope.previewers")
					local delta = get_delta_previewer(previewers, "status", worktree)

					local options = { previewer = delta }

					if worktree ~= nil then
						options = vim.tbl_deep_extend("force", options, {
							-- if we should use git root as cwd or the cwd
							use_git_root = false,
						})
					else
						local current_file = vim.fn.resolve(vim.fn.expand("%"))
						local file_directory = vim.fn.fnamemodify(current_file, ":p:h")

						-- Make `git_bcommits` compatible with git worktrees in bare repos
						options = vim.tbl_deep_extend("force", options, {
							-- if we should use the current buffer git root
							use_file_path = true,
							-- specify the path of the repo
							cwd = file_directory,
						})
					end

					require("telescope.builtin").git_status(options)
				end,
				desc = "Git status",
			},
		},
		opts = function()
			local actions = require("telescope.actions")
			local action_state = require("telescope.actions.state")
			local action_set = require("telescope.actions.set")

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
						use_delta = true,
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
					git_status = {
						mappings = {
							n = {
								-- Fix selection not working for `.dotfiles` repo
								["<CR>"] = function(prompt_bufnr)
									local entry = action_state.get_selected_entry()
									local extracted_entry = getmetatable(entry)
									if extracted_entry.toplevel ~= nil then
										actions.close(prompt_bufnr)
										local selected_file = extracted_entry.toplevel .. "/" .. entry.value
										return vim.cmd("edit " .. selected_file)
									end
									action_set.select(prompt_bufnr, "default")
								end,
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
