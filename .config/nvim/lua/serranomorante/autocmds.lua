local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd
local namespace = vim.api.nvim_create_namespace
local utils = require("serranomorante.utils")
local events = require("serranomorante.events")

local is_available = utils.is_available
local MAX_WIN_HISTORY_LENGTH = 4

local general = augroup("General Settings", { clear = true })

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

if is_available("neo-tree.nvim") then
	-- Thanks AstroNvim!
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

	-- Fix the neo-tree width even when vim window is resized
	autocmd("VimResized", {
		callback = function()
			local tabpages = vim.api.nvim_list_tabpages()

			for _, tabpage in ipairs(tabpages) do
				local winnr = vim.fn.tabpagewinnr(tabpage, "99999h")
				local winid = vim.fn.win_getid(winnr)
				local filetype = utils.buf_filetype_from_winid(winid)

				if filetype == "neo-tree" then
					vim.schedule(function()
						vim.api.nvim_win_set_width(winid, vim.g.neo_tree_width)
						vim.cmd.wincmd("=")
					end)
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

--- Keep track of valid window ids in a variable.
---
--- Thanks!
--- https://www.reddit.com/r/neovim/comments/szjysg/comment/hyli78a/?utm_source=share&utm_medium=web2x&context=3
autocmd({ "WinEnter", "VimEnter" }, {
	callback = function(_)
		-- Exclude floating windows
		if "" ~= vim.api.nvim_win_get_config(0).relative then
			return
		end

		local ignored_filetypes = { "DressingInput", "neo-tree" }
		local ignored_buftypes = { "nofile" }

		if vim.tbl_contains(ignored_filetypes, vim.bo.filetype) then
			return
		end

		if vim.tbl_contains(ignored_buftypes, vim.bo.buftype) then
			return
		end

		local current_win_id = vim.fn.win_getid()

		-- Initialize if not present
		if vim.t.win_history == nil then
			vim.t.win_history = { current_win_id }
		end

		local history = vim.t.win_history

		-- `history[1]` will be our previous window, we don't want to
		-- duplicate it in our history at the 1 position
		if history[1] == current_win_id then
			return
		end

		-- Restrict lenght of history
		if #vim.t.win_history >= MAX_WIN_HISTORY_LENGTH then
			table.remove(history)
		end

		-- Remove any invalid window id
		for _, history_win_id in ipairs(history) do
			if not vim.api.nvim_win_is_valid(history_win_id) then
				table.remove(history)
				break
			end
		end

		-- Insert new window id to the beginning of the history
		table.insert(history, 1, current_win_id)

		vim.t.win_history = history
	end,
})

--- This adds support for worktrees in gitsigns.nvim
--- Thanks AstroNvim!!
autocmd({ "BufReadPost", "BufNewFile", "BufWritePost" }, {
	group = augroup("file_user_events", { clear = true }),
	callback = function(args)
		local current_file = vim.fn.resolve(vim.fn.expand("%"))

		if not (current_file == "" or vim.api.nvim_get_option_value("buftype", { buf = args.buf }) == "nofile") then
			local worktree = utils.file_worktree()

			if worktree or utils.cmd({ "git", "-C", vim.fn.fnamemodify(current_file, ":p:h"), "rev-parse" }, false) then
				events.event("GitFile")
				vim.api.nvim_del_augroup_by_name("file_user_events")
			end
		end
	end,
})

--- Disable automatic comment on next line
autocmd("BufEnter", {
	callback = function()
		vim.opt.formatoptions:remove({ "c", "r", "o" })
	end,
	group = general,
	desc = "Disable New Line Comment",
})
