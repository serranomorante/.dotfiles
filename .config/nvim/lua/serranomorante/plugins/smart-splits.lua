local utils = require("serranomorante.utils")
local autocmd = vim.api.nvim_create_autocmd

return {
	{
		"kwkarlwang/bufresize.nvim",
		event = "VeryLazy",
		config = true,
		init = function()
			-- Fix issue with bufresize and neotree in which toggling
			-- neo-tree (hidding it), then openinng the command line history
			-- window (q:), then closing it, then opening neo-tree again with
			-- `ctrl+o` will resize the cmd window height
			autocmd("CmdwinLeave", {
				callback = function()
					vim.schedule(function()
						require("bufresize").resize_close()
					end)
				end,
			})
		end,
	},

	{
		"mrjones2014/smart-splits.nvim",
		keys = {
			-- Resize splits keymaps
			{
				"<A-h>",
				function()
					require("smart-splits").resize_left()
				end,
			},
			{
				"<A-j>",
				function()
					require("smart-splits").resize_down()
				end,
			},
			{
				"<A-k>",
				function()
					require("smart-splits").resize_up()
				end,
			},
			{
				"<A-l>",
				function()
					require("smart-splits").resize_right()
				end,
			},
			-- Swap splits keymaps
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
			}
		end,
	},
}
