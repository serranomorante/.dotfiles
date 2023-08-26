local uv = vim.loop
local path_sep = uv.os_uname().version:match("Windows") and "\\" or "/"

local M = {}

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
	local stat = uv.fs_stat(path)
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

--- Get the first worktree that a file belongs to
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
--- @return string branch # The branch name
function M.branch_name(worktree)
	local branch

	if worktree then
		branch = vim.fn.system(
			("git --git-dir=%s --work-tree=%s branch --show-current 2> /dev/null | tr -d '\n'"):format(
				worktree.gitdir,
				worktree.toplevel
			)
		)
	else
		branch = vim.fn.system("git branch --show-current 2> /dev/null | tr -d '\n'")
	end

	if branch ~= "" then
		return branch
	else
		return ""
	end
end

return M
