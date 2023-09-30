return {
	"lambdalisue/suda.vim",
	cmd = "SudaRead",
	event = "User CustomFile",
	init = function()
		vim.g.suda_smart_edit = 1
	end,
}
