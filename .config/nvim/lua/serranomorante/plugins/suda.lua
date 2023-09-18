return {
	"lambdalisue/suda.vim",
	cmd = "SudaRead",
	event = "BufEnter",
	init = function()
		vim.g.suda_smart_edit = 1
	end,
}
