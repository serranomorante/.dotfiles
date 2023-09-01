local utils = require("serranomorante.utils")

return {
	{
		"kwkarlwang/bufresize.nvim",
		event = "VeryLazy",
		config = true,
	},

	{
		"mrjones2014/smart-splits.nvim",
		-- enabled = false,
		keys = {
			{
				"<leader>rs",
				function()
					require("smart-splits").start_resize_mode()
				end,
			},
			{
				"<leader><leader>h",
				function()
					-- Quick return if next window is neo-tree
					local next_winid = vim.fn.win_getid(vim.fn.winnr(utils.DirectionKeys[utils.Direction.left]))
					local filetype = utils.buf_filetype_from_winid(next_winid)
					if filetype == "neo-tree" then
						return
					end

					require("smart-splits").swap_buf_left()
				end,
			},
			{
				"<leader><leader>j",
				function()
					require("smart-splits").swap_buf_down()
				end,
			},
			{
				"<leader><leader>k",
				function()
					require("smart-splits").swap_buf_up()
				end,
			},
			{
				"<leader><leader>l",
				function()
					-- Quick return if next window is neo-tree
					local swap_direction = utils.Direction.right
					local will_wrap = utils.win_at_edge(swap_direction)
					if will_wrap then
						local wrap_winid = utils.win_wrap_id(swap_direction)
						local filetype = utils.buf_filetype_from_winid(wrap_winid)
						if filetype == "neo-tree" then
							return
						end
					end

					require("smart-splits").swap_buf_right()
				end,
			},
		},
		opts = function()
			return {
				cursor_follows_swapped_bufs = true,
				ignored_filetypes = {
					"nofile",
					"quickfix",
					"prompt",
					"neo-tree",
					"harpoon",
					"NvimTree",
				},
				resize_mode = {
					silent = true,
					hooks = {
						on_leave = function()
							require("bufresize").register()
							vim.notify("Smart Splits: RESIZE MODE OFF", vim.log.levels.INFO)

							-- Navigate display lines
							-- TODO: delete this after smart-splits fix the bug
							vim.keymap.set({ "n", "x" }, "j", function()
								return vim.v.count > 0 and "j" or "gj"
							end, { noremap = true, expr = true })
							vim.keymap.set({ "n", "x" }, "k", function()
								return vim.v.count > 0 and "k" or "gk"
							end, { noremap = true, expr = true })
						end,
						on_enter = function()
							vim.notify("Smart Splits: RESIZE MODE ON", vim.log.levels.WARN)
						end,
					},
				},
			}
		end,
	},
}
