local utils = require("serranomorante.utils")

return {
	"akinsho/bufferline.nvim",
	version = "*",
	event = "VeryLazy",
	opts = {
		options = {
			offsets = {
				{
					filetype = "NvimTree",
					text = "File Explorer",
					text_align = "left",
					highlight = "Directory",
				},
				{
					filetype = "neo-tree",
					text = "File Explorer",
					text_align = "left",
					highlight = "Directory",
				},
			},
			mode = "tabs",
			enforce_regular_tabs = false,
			show_buffer_icons = false,
			show_buffer_close_icons = false,
			show_close_icon = false,
			indicator = {
				style = "none",
			},
			---@diagnostic disable-next-line: unused-local
			custom_filter = function(buf_number, buf_numbers)
				-- filter out filetypes you don't want to see
				local exclude_list = { "NvimTree", "neo-tree", "harpoon", "TelescopePrompt" }
				local ft = vim.bo[buf_number].filetype
				if not utils.has_value(exclude_list, ft) then
					return true
				end
			end,
		},
	},
}
