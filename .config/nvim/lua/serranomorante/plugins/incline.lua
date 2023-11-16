return {
	"b0o/incline.nvim",
	lazy = false,
	opts = {
		hide = {
			only_win = true,
		},
		window = {
			margin = {
				vertical = 0,
			},
		},
		-- Thanks: https://github.com/b0o/incline.nvim/issues/26#issuecomment-1204111467
		render = function(props)
			local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ":t")
			if vim.bo[props.buf].modified then
				filename = "[+] " .. filename
			end
			local icon, color = require("nvim-web-devicons").get_icon_color(filename)
			return {
				{ icon, guifg = color },
				{ " " },
				{ filename },
			}
		end,
	},
}
