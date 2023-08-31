local utils = require("serranomorante.utils")

return {
	"nvim-neo-tree/neo-tree.nvim",
	branch = "v3.x",
	cmd = "Neotree",
	keys = {
		{
			"<leader>e",
			"<cmd>Neotree toggle<cr>",
		},
		{
			"<leader>o",
			function()
				if vim.bo.filetype == "neo-tree" then
					local win_history = vim.t.win_history
					local prev_win = win_history[1]

					-- Go to the window to the right as a fallback
					if vim.fn.win_getid() == prev_win then
						vim.cmd.wincmd("l")
					-- Go to the previous window
					else
						vim.fn.win_gotoid(prev_win)
					end
				else
					vim.cmd.Neotree("focus")
				end
			end,
		},
		{
			"<leader>rb",
			"<cmd>Neotree filesystem reveal left<cr>",
		},
	},
	dependencies = {
		"nvim-lua/plenary.nvim",
		-- "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
		"MunifTanjim/nui.nvim",
	},
	opts = {
		close_if_last_window = true,
		enable_normal_mode_for_inputs = true,
		window = {
			width = vim.g.neo_tree_width,
			mappings = {
				["h"] = "parent_or_close",
				["l"] = "child_or_open",
				["z"] = "noop", -- disable close all nodes
			},
		},
	  -- Thanks AstroNvim!
		commands = {
			parent_or_close = function(state)
				local node = state.tree:get_node()
				if (node.type == "directory" or node:has_children()) and node:is_expanded() then
					state.commands.toggle_node(state)
				else
					require("neo-tree.ui.renderer").focus_node(state, node:get_parent_id())
				end
			end,
			child_or_open = function(state)
				local node = state.tree:get_node()
				if node.type == "directory" or node:has_children() then
					if not node:is_expanded() then -- if unexpanded, expand
						state.commands.toggle_node(state)
					else -- if expanded and has children, seleect the next child
						require("neo-tree.ui.renderer").focus_node(state, node:get_child_ids()[1])
					end
				else -- if not a directory just open it
					state.commands.open(state)
				end
			end,
		},
		filesystem = {
			window = {
				fuzzy_finder_mappings = {
					["<C-j>"] = "move_cursor_down",
					["<C-k>"] = "move_cursor_up",
					["<down>"] = "noop",
					["<up>"] = "noop",
					["<C-n>"] = "noop",
					["<C-p>"] = "noop",
				},
			},
		},
		default_component_configs = {
			git_status = {
				symbols = {
					added = "",
					deleted = "",
					-- modified = "",
					renamed = "",
					untracked = "",
					ignored = "",
					unstaged = "",
					staged = "",
					conflict = "",
				},
			},
		},
		event_handlers = {
			{
				event = "before_render",
				handler = function()
					local worktree = utils.file_worktree()
					local branch_name = utils.branch_name(worktree)
					vim.g.neo_tree_git_branch = branch_name
				end,
			},
			-- See https://github.com/kwkarlwang/bufresize.nvim/pull/8
			{
				event = "neo_tree_window_before_open",
				handler = function()
					require("bufresize").block_register()
				end,
			},
			{
				event = "neo_tree_window_after_open",
				handler = function()
					require("bufresize").resize_open()
				end,
			},
			{
				event = "neo_tree_window_before_close",
				handler = function()
					require("bufresize").block_register()
				end,
			},
			{
				event = "neo_tree_window_after_close",
				handler = function()
					require("bufresize").resize_close()
				end,
			},
		},
	},
}
