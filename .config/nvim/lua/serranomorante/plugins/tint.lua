local utils = require("serranomorante.utils")

return {
	"levouh/tint.nvim",
	event = "VeryLazy",
	opts = function()
		local opts = {
			tint = -50,
			highlight_ignore_patterns = { "WinSeparator" },
			--- Without `transforms` there's an error on `vim-illuminate` and other plugins that use this tint's `refresh` function
			transforms = {
				require("tint.transforms").tint_with_threshold(-100, "#1C1C1C", 150), -- Try to tint by `-100`, but keep all colors at least `150` away from `#1C1C1C`
				require("tint.transforms").saturate(0.5),
			},
			window_ignore_function = function(winid)
				local bufid = vim.api.nvim_win_get_buf(winid)
				local buftype = vim.api.nvim_get_option_value("buftype", { buf = bufid })
				local filetype = vim.api.nvim_get_option_value("filetype", { buf = bufid })
				local floating = vim.api.nvim_win_get_config(winid).relative ~= ""

				if utils.is_available("diffview.nvim") then
					-- Disable tint.nvim on diff windows
					if vim.wo.diff or require("diffview.lib").get_current_view() ~= nil then
						return true
					end
				end

				-- Do not tint `terminal` or floating windows, tint everything else
				return buftype == "terminal" or floating or filetype == "harpoon"
			end,
		}

		return opts
	end,
}
