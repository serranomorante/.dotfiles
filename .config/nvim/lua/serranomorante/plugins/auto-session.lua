return {
	"rmagatti/auto-session",
	opts = {
		log_level = "error",
		auto_session_enable_last_session = false,
		auto_session_root_dir = vim.fn.stdpath("data") .. "/sessions/",
		auto_session_enabled = true,
		auto_save_enabled = nil,
		auto_restore_enabled = false,
		auto_session_suppress_dirs = { os.getenv("HOME") },
		auto_session_use_git_branch = nil,
	},
	event = "BufReadPre",
	keys = {
		{
			"<leader>xr",
			"<cmd>SessionRestore<CR>",
		},
		{
			"<leader>xs",
			"<cmd>SessionSave<CR>",
		},
	},
}
