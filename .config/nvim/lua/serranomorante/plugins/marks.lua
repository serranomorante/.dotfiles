return {
	"serranomorante/marks.nvim",
	event = "VeryLazy",
	keys = {
		{
			"<leader>qe",
			"<cmd>MarksQFListBuf<CR>",
		},
		{
			"<leader>qE",
			"<cmd>MarksQFListAll<CR>",
		},
	},
	opts = {
		refresh_interval = 1000,
	},
}
