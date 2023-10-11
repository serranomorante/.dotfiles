local utils = require("serranomorante.utils")

return {
	"nvim-neo-tree/neo-tree.nvim",
	branch = "v3.x",
	cmd = "Neotree",
	keys = {
		{
			"<leader>e",
			"<cmd>Neotree toggle<cr>",
			desc = "Toggle neo-tree",
		},
		{
			"<leader>o",
			function()
				if vim.bo.filetype == "neo-tree" then
					-- The next code is heavily dependant on the
					-- window id history autocmd
					local win_history = vim.t.win_history
					local prev_win = win_history[1]

					-- If the previous window is a neo-tree window, then
					-- look for the window before that one.
					if utils.buf_filetype_from_winid(prev_win) == "neo-tree" then
						prev_win = win_history[2]
					end

					if vim.fn.win_getid() == prev_win then
						-- Go to the window to the right as a fallback
						vim.cmd.wincmd("l")
					else
						-- Go to the previous window
						vim.fn.win_gotoid(prev_win)
					end
				else
					-- Is a mistery to me why executing `vim.cmd.Neotree("focus")`
					-- is appending an unexpected additional window id.
					vim.cmd.Neotree("focus")
				end
			end,
			desc = "Focus neo-tree",
		},
		{
			"<leader>rb",
			"<cmd>Neotree filesystem reveal left<cr>",
			desc = "Reveal file in neo-tree",
		},
	},
	dependencies = {
		"nvim-lua/plenary.nvim",
		-- "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
		"MunifTanjim/nui.nvim",
	},
	opts = {
		popup_border_style = "single",
		close_if_last_window = true,
		enable_normal_mode_for_inputs = true,
		window = {
			width = vim.g.neo_tree_width,
			mappings = {
				["h"] = "parent_or_close",
				["l"] = "child_or_open",
				["z"] = "noop", -- disable close all nodes
				["H"] = "noop", -- disable toggle_hidden
				["."] = "toggle_hidden", -- replace set_root with toggle_hidden
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
					if utils.is_available("bufresize.nvim") then
						require("bufresize").block_register()
					end
				end,
			},
			{
				event = "neo_tree_window_after_open",
				handler = function()
					if utils.is_available("bufresize.nvim") then
						require("bufresize").resize_open()
					end
				end,
			},
			{
				event = "neo_tree_window_before_close",
				handler = function()
					if utils.is_available("bufresize.nvim") then
						require("bufresize").block_register()
					end
				end,
			},
			{
				event = "neo_tree_window_after_close",
				handler = function()
					if utils.is_available("bufresize.nvim") then
						require("bufresize").resize_close()
					end
				end,
			},
		},
	},
	config = function(_, opts)
		require("neo-tree").setup(opts)

		if utils.is_available("tokyonight.nvim") then
			local colors = require("tokyonight.colors").setup()

			-- Adapt neo-tree popus to general window theme
			vim.api.nvim_set_hl(0, "NeoTreeFloatBorder", { fg = colors.border_highlight, bg = colors.bg_dark })
			vim.api.nvim_set_hl(0, "NeoTreeFloatTitle", { fg = colors.border_highlight, bg = colors.bg_dark })
		end
	end,
}
