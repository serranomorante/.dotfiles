local path_sep = (vim.uv or vim.loop).os_uname().version:match("Windows") and "\\" or "/"

local M = {}

M.Direction = {
	left = "left",
	right = "right",
	up = "up",
	down = "down",
}

M.DirectionKeys = {
	left = "h",
	right = "l",
	up = "k",
	down = "j",
}

M.DirectionKeysOpposite = {
	left = "l",
	right = "h",
	up = "j",
	down = "k",
}

--- assert that the given argument is in fact of the correct type.
---
--- Thanks!!
--- https://github.com/lunarmodules/Penlight
---
-- @param n argument index
-- @param val the value
-- @param tp the type
-- @param verify an optional verification function
-- @param msg an optional custom message
-- @param lev optional stack position for trace, default 2
-- @return the validated value
-- @raise if `val` is not the correct type
-- @usage
-- local param1 = assert_arg(1,"hello",'table')  --> error: argument 1 expected a 'table', got a 'string'
-- local param4 = assert_arg(4,'!@#$%^&*','string',path.isdir,'not a directory')
--      --> error: argument 4: '!@#$%^&*' not a directory
function M.assert_arg(n, val, tp, verify, msg, lev)
	if type(val) ~= tp then
		error(("argument %d expected a '%s', got a '%s'"):format(n, tp, type(val)), lev or 2)
	end
	if verify and not verify(val) then
		error(("argument %d: '%s' %s"):format(n, val, msg), lev or 2)
	end
	return val
end

--- Thanks!!
--- https://github.com/lunarmodules/Penlight
local function assert_string(n, s)
	M.assert_arg(n, s, "string")
end

--- Check if a plugin is defined in lazy. Useful with lazy loading when a plugin is not necessarily loaded yet
---@param plugin string # The plugin to search for
---@return boolean available # Whether the plugin is available
function M.is_available(plugin)
	local lazy_config_avail, lazy_config = pcall(require, "lazy.core.config")
	return lazy_config_avail and lazy_config.plugins[plugin] ~= nil
end

--- Call function if a condition is met
---@param func function # The function to run
---@param condition boolean # Wether to run the function or not
---@return any|nil result # The result of the function running or nil
function M.conditional_func(func, condition, ...)
	if condition and type(func) == "function" then
		return func(...)
	end
end

--- Check if a list of strings has a value
--- @param options string[] # The list of strings to check
--- @param val string # The value to check
function M.has_value(options, val)
	for _, value in ipairs(options) do
		if value == val then
			return true
		end
	end

	return false
end

--- Checks whether a given path exists and is a directory
--- Thanks LunarVim!
--@param path (string) path to check
--@returns (bool)
function M.is_directory(path)
	local stat = (vim.uv or vim.loop).fs_stat(path)
	return stat and stat.type == "directory" or false
end

--- Thanks LunarVim!
---Join path segments that were passed as input
---@return string
function M.join_paths(...)
	local result = table.concat({ ... }, path_sep)
	return result
end

local ellipsis = "..."
local n_ellipsis = #ellipsis

--- Return a shortened version of a string.
--- Fits string within w characters. Removed characters are marked with ellipsis.
---
--- Thanks!!
--- https://github.com/lunarmodules/Penlight
---
-- @string s the string
-- @int w the maxinum size allowed
-- @bool tail true if we want to show the end of the string (head otherwise)
-- @usage ('1234567890'):shorten(8) == '12345...'
-- @usage ('1234567890'):shorten(8, true) == '...67890'
-- @usage ('1234567890'):shorten(20) == '1234567890'
function M.shorten(s, w, tail)
	assert_string(1, s)
	if #s > w then
		if w < n_ellipsis then
			return ellipsis:sub(1, w)
		end
		if tail then
			local i = #s - w + 1 + n_ellipsis
			return ellipsis .. s:sub(i)
		else
			return s:sub(1, w - n_ellipsis) .. ellipsis
		end
	end
	return s
end

--- Run a shell command and capture the output and if the command succeeded or failed
---
--- Thanks AstroNvim!!
---
---@param cmd string|string[] The terminal command to execute
---@param show_error? boolean Whether or not to show an unsuccessful command as an error to the user
---@return string|nil # The result of a successfully executed command or nil
function M.cmd(cmd, show_error)
	if type(cmd) == "string" then
		cmd = { cmd }
	end
	if vim.fn.has("win32") == 1 then
		cmd = vim.list_extend({ "cmd.exe", "/C" }, cmd)
	end
	local result = vim.fn.system(cmd)
	local success = vim.api.nvim_get_vvar("shell_error") == 0
	if not success and (show_error == nil or show_error) then
		vim.api.nvim_err_writeln(
			("Error running command %s\nError message:\n%s"):format(table.concat(cmd, " "), result)
		)
	end
	return success and result:gsub("[\27\155][][()#;?%d]*[A-PRZcf-ntqry=><~]", "") or nil
end

--- Get the first worktree that a file belongs to (from a predefined list of worktrees only)
--- Very useful for `.dotfiles` repository
---
--- Thanks AstroNvim!!
--- https://astronvim.com/Recipes/detached_git_worktrees
---
---@param file string? the file to check, defaults to the current file
---@param worktrees table<string, string>[]? an array like table of worktrees with entries `toplevel` and `gitdir`, default retrieves from `vim.g.git_worktrees`
---@return table<string, string>|nil # a table specifying the `toplevel` and `gitdir` of a worktree or nil if not found
function M.file_worktree(file, worktrees)
	worktrees = worktrees or vim.g.git_worktrees
	if not worktrees then
		return
	end
	file = file or vim.fn.resolve(vim.fn.expand("%"))

	if string.find(file, "neo-tree", 1, true) then
		-- Not valid file, use a directory
		file = vim.fn.fnamemodify(file, ":p:h")
	end

	for _, worktree in ipairs(worktrees) do
		if
			M.cmd({
				"git",
				"--work-tree",
				worktree.toplevel,
				"--git-dir",
				worktree.gitdir,
				"ls-files",
				"--error-unmatch",
				file,
			}, false)
		then
			return worktree
		end
	end
end

--- Get the focused buffer filetype from a window id
--- @param winid number # The window id to get the filetype from
--- @return string filetype # The filetype of the focused buffer
function M.buf_filetype_from_winid(winid)
	local bufnr = vim.api.nvim_win_get_buf(winid)
	local filetype = vim.bo[bufnr].filetype
	return filetype
end

--- Get the branch name with git-dir and worktree support
--- @param worktree table<string, string>|nil # a table specifying the `toplevel` and `gitdir` of a worktree
--- @param as_path string|nil # execute the git command from specific path
--- @return string branch # The branch name
function M.branch_name(worktree, as_path)
	local branch

	if worktree then
		branch = vim.fn.system(
			("git --git-dir=%s --work-tree=%s branch --show-current 2> /dev/null | tr -d '\n'"):format(
				worktree.gitdir,
				worktree.toplevel
			)
		)
	elseif as_path then
		branch = vim.fn.system(("git -C %s branch --show-current 2> /dev/null | tr -d '\n'"):format(as_path))
	else
		branch = vim.fn.system("git branch --show-current 2> /dev/null | tr -d '\n'")
	end

	if branch ~= "" then
		return branch
	else
		return ""
	end
end

---@param direction string # The direction key to check
---@return boolean
function M.win_at_edge(direction)
	return vim.fn.winnr() == vim.fn.winnr(M.DirectionKeys[direction])
end

--- Get the extreme opposite window id of the direction you pass
---@param direction string # The direction key to check
---@return number
function M.win_wrap_id(direction)
	return vim.fn.win_getid(vim.fn.winnr(string.format("%s%s", "99999", M.DirectionKeysOpposite[direction])))
end

-- Thanks! https://gitlab.com/ranjithshegde/dotbare/-/blob/master/.config/nvim/lua/r/extensions/qf.lua?ref_type=heads
-- 'q': find the quickfix window
-- 'l': find all loclist windows
local function find_qf(type)
	local wininfo = vim.fn.getwininfo()
	local win_tbl = {}
	for _, win in pairs(wininfo) do
		local found = false
		if type == "l" and win["loclist"] == 1 then
			found = true
		end
		-- loclist window has 'quickfix' set, eliminate those
		if type == "q" and win["quickfix"] == 1 and win["loclist"] == 0 then
			found = true
		end
		if found then
			table.insert(win_tbl, { winid = win["winid"], bufnr = win["bufnr"] })
		end
	end
	return win_tbl
end

-- Thanks! https://gitlab.com/ranjithshegde/dotbare/-/blob/master/.config/nvim/lua/r/extensions/qf.lua?ref_type=heads
-- open quickfix if not empty
local function open_qf()
	if not vim.tbl_isempty(vim.fn.getqflist()) then
		vim.cmd("botright copen")
		vim.cmd.wincmd("J")
	else
		vim.notify("qflist is empty")
	end
end

-- Thanks! https://gitlab.com/ranjithshegde/dotbare/-/blob/master/.config/nvim/lua/r/extensions/qf.lua?ref_type=heads
-- loclist on current window where not empty
local function open_loclist()
	if not vim.tbl_isempty(vim.fn.getloclist(0)) then
		vim.cmd("botright lopen")
	else
		vim.notify("loclist is empty")
	end
end

--- Thanks! https://gitlab.com/ranjithshegde/dotbare/-/blob/master/.config/nvim/lua/r/extensions/qf.lua?ref_type=heads
--- type='*': qf toggle and send to bottom
--- type='l': loclist toggle (all windows)
--- map to ":lua require'utils'.toggle_qf('l')"
function M.toggle_qf(type)
	local windows = find_qf(type)
	if not vim.tbl_isempty(windows) then
		-- hide all visible windows
		for _, win in pairs(windows) do
			vim.api.nvim_win_hide(win.winid)
		end
	else
		-- no windows are visible, attempt to open
		if type == "l" then
			open_loclist()
		else
			open_qf()
		end
	end
end

--- Toggle buffer LSP inlay hints
--- Thanks AstroNvim
---@param bufnr? number of the buffer to toggle the clients on
function M.toggle_buffer_inlay_hints(bufnr)
	bufnr = bufnr or 0
	vim.b[bufnr].inlay_hints_enabled = not vim.b[bufnr].inlay_hints_enabled
	vim.lsp.inlay_hint(bufnr, vim.b[bufnr].inlay_hints_enabled)
end

function M.bool2str(bool)
	return bool and "on" or "off"
end

return M
