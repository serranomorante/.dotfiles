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
				local buftype = vim.api.nvim_buf_get_option(bufid, "buftype")
				local filetype = vim.api.nvim_buf_get_option(bufid, "filetype")
				local floating = vim.api.nvim_win_get_config(winid).relative ~= ""

				-- Do not tint `terminal` or floating windows, tint everything else
				return buftype == "terminal" or floating or filetype == "harpoon"
			end,
		}

		return opts
	end,
}
