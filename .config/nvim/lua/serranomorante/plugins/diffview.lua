return {
	"sindrets/diffview.nvim",
	cmd = "DiffviewOpen",
	init = function()
		vim.opt.fillchars:append({ diff = "╱" })
	end,
	opts = {
		use_icons = false,
	},
}
