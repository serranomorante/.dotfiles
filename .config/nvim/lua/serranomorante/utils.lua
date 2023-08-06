local uv = vim.loop
local path_sep = uv.os_uname().version:match("Windows") and "\\" or "/"

local M = {}

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

return M
