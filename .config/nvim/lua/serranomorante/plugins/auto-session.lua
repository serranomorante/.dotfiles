local function notify_restore()
	vim.notify("Session restored", vim.log.levels.INFO)
end

local function notify_save()
	vim.notify("Session saved", vim.log.levels.INFO)
end

return {
	"rmagatti/auto-session",
	opts = {
		log_level = "error",
		auto_session_root_dir = vim.fn.stdpath("data") .. "/sessions/",
		auto_session_suppress_dirs = { os.getenv("HOME") },
		auto_session_enable_last_session = false,
		auto_session_enabled = false,
		auto_session_create_enabled = false,
		auto_save_enabled = false,
		auto_restore_enabled = false,
		auto_session_use_git_branch = false,
		session_lens = {
			path_display = { "shorten" },
		},
		post_restore_cmds = { notify_restore },
		post_save_cmds = { notify_save },
	},
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
