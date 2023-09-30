local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

local function notify_restore()
	vim.notify("Session restored", vim.log.levels.INFO)
end

local function notify_save()
	vim.notify("Session saved", vim.log.levels.INFO)
end

return {
	"rmagatti/auto-session",
	dependencies = "nvim-telescope/telescope.nvim",
	lazy = true,
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
			load_on_setup = false,
		},
		post_restore_cmds = { notify_restore },
		post_save_cmds = { notify_save },
	},
	init = function()
		autocmd("User LazyLoad", {
			desc = "Lazy setup session lens when loading telescope.nvim",
			group = augroup("AutoSession", { clear = true }),
			callback = function(event)
				if event and event.data == "telescope.nvim" then
					require("auto-session").setup_session_lens()
				end
			end,
		})
	end,
	keys = {
		{
			"<leader>xr",
			"<cmd>SessionRestore<CR>",
			desc = "Restore session",
		},
		{
			"<leader>xs",
			"<cmd>SessionSave<CR>",
			desc = "Save session",
		},
		{
			"<leader>xf",
			function()
				require("auto-session.session-lens").search_session()
			end,
			desc = "Search session",
		},
	},
}
