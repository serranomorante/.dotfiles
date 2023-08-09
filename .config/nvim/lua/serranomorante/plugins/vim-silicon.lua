return {
	"segeljakt/vim-silicon",
	cmd = "Silicon",
	config = function()
		vim.g.silicon = {
			output = "~/Pictures/silicon-{time:%Y-%m-%d-%H%M%S}.png",
		}
	end,
}
