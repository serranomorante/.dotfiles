local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd
local namespace = vim.api.nvim_create_namespace
local utils = require("serranomorante.utils")

local is_available = utils.is_available
local MAX_WIN_HISTORY_LENGTH = 4

-- Highlight when yanking
autocmd("TextYankPost", {
	desc = "Highlight yanked text",
	group = augroup("highlightyank", { clear = true }),
	pattern = "*",
	callback = function()
		vim.highlight.on_yank({
			higroup = "IncSearch",
			timeout = 40,
		})
	end,
})

-- Highlight timeout when searching
vim.on_key(function(char)
	if vim.fn.mode() == "n" then
		local new_hlsearch = vim.tbl_contains({
			"<CR>",
			"n",
			"N",
			"*",
			"#",
			"?",
			"/",
		}, vim.fn.keytrans(char))

		if vim.opt.hlsearch:get() ~= new_hlsearch then
			vim.opt.hlsearch = new_hlsearch
		end
	end
end, namespace("auto_hlsearch"))

local view_group = augroup("auto_view", { clear = true })

-- Mkview and loadview
-- Thanks AstroNvim!
autocmd({ "BufWinLeave", "BufWritePost", "WinLeave" }, {
	desc = "Save view with mkview for real files.",
	group = view_group,
	callback = function(event)
		if vim.b[event.buf].view_activated then
			vim.cmd.mkview({ mods = { emsg_silent = true } })
		end
	end,
})

-- Mkview and loadview
-- Thanks AstroNvim!
autocmd("BufWinEnter", {
	desc = "Try to load file view if available and enable view saving for real files",
	group = view_group,
	callback = function(event)
		if not vim.b[event.buf].view_activated then
			local filetype = vim.api.nvim_get_option_value("filetype", { buf = event.buf })
			local buftype = vim.api.nvim_get_option_value("buftype", { buf = event.buf })
			local ignore_filetypes = { "gitcommit", "gitrebase", "svg", "hgcommit" }
			if buftype == "" and filetype and filetype ~= "" and not vim.tbl_contains(ignore_filetypes, filetype) then
				vim.b[event.buf].view_activated = true
				vim.cmd.loadview({ mods = { emsg_silent = true } })
			end
		end
	end,
})

-- Make q close windows
-- Thanks AstroNvim!
autocmd("BufWinEnter", {
	desc = "Make q close help, man, quickfix, dap floats",
	group = augroup("q_close_windows", { clear = true }),
	callback = function(event)
		local buftype = vim.api.nvim_get_option_value("buftype", { buf = event.buf })
		if vim.tbl_contains({ "help", "nofile", "quickfix" }, buftype) and vim.fn.maparg("q", "n") == "" then
			vim.keymap.set("n", "q", "<cmd>close<cr>", {
				desc = "Close window",
				buffer = event.buf,
				silent = true,
				nowait = true,
			})
		end
	end,
})

-- Thanks AstroNvim!
if is_available("neo-tree.nvim") then
	autocmd("BufEnter", {
		desc = "Open Neo-Tree on startup with directory",
		group = augroup("neotree_start", { clear = true }),
		callback = function()
			if package.loaded["neo-tree"] then
				vim.api.nvim_del_augroup_by_name("neotree_start")
			else
				local stats = (vim.uv or vim.loop).fs_stat(vim.api.nvim_buf_get_name(0)) -- TODO: REMOVE vim.loop WHEN DROPPING SUPPORT FOR Neovim v0.9
				if stats and stats.type == "directory" then
					vim.api.nvim_del_augroup_by_name("neotree_start")
					require("neo-tree")
				end
			end
		end,
	})
end

--- Add syntax highlighting to zellij .dump temp files
autocmd({ "BufEnter", "BufWinEnter" }, {
	pattern = { "*.dump" },
	callback = function(_)
		vim.bo.filetype = "bash"
	end,
})

--- Add syntax highlighting to .conf files
autocmd({ "BufEnter", "BufWinEnter" }, {
	pattern = { "*.conf" },
	callback = function(_)
		vim.bo.filetype = "dosini"
	end,
})

-- vim.api.nvim_create_autocmd({ "filetype" }, {
-- 	pattern = "harpoon",
-- 	callback = function()
-- 		vim.cmd([[highlight HarpoonBorder guibg=#313132]])
-- 		vim.cmd([[highlight HarpoonWindow guibg=#313132]])
-- 	end,
-- })

-- Save win ids in history. This helps to fix issue with neo-tree
-- not going back to previous window with <leader>o
-- Thanks!
-- https://www.reddit.com/r/neovim/comments/szjysg/comment/hyli78a/?utm_source=share&utm_medium=web2x&context=3
autocmd({ "WinEnter", "VimEnter" }, {
	callback = function(_)
		-- Exclude floating windows
		if "" ~= vim.api.nvim_win_get_config(0).relative then
			return
		end

		if vim.t.winid_rec == nil then
			vim.t.winid_rec = { vim.fn.win_getid() }
		end

		local history = vim.t.winid_rec

		if #vim.t.winid_rec >= MAX_WIN_HISTORY_LENGTH then
			table.remove(history, 1)
		end

		table.insert(history, vim.fn.win_getid())
		vim.t.winid_rec = history
	end,
})
