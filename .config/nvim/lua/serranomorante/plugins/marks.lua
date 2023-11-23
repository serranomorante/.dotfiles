return {
	"serranomorante/marks.nvim",
	event = "User CustomFile",
	keys = {
		{
			"<leader>qe",
			"<cmd>MarksQFListBuf<CR>",
			desc = "Export marks in current buffer",
		},
		{
			"<leader>qE",
			"<cmd>MarksQFListAll<CR>",
			desc = "Export marks in all buffers",
		},
	},
	opts = {
		refresh_interval = 4000,
	},
}
