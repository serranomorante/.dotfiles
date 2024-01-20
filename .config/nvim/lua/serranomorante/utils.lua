local lspconfig_names_map = require("serranomorante.plugins.lsp.mason-tools.lspconfig_names_map")

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

---Check if a plugin spec exists in lazy config.
---This will not load the plugin.
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
  if condition and type(func) == "function" then return func(...) end
end

--- Checks whether a given path exists and is a directory
--- Thanks LunarVim!
--@param path (string) path to check
--@returns (bool)
function M.is_directory(path)
  local stat = (vim.uv or vim.loop).fs_stat(path)
  return stat and stat.type == "directory" or false
end

local path_sep = (vim.uv or vim.loop).os_uname().version:match("Windows") and "\\" or "/"

---Join path segments that were passed as input
---Thanks LunarVim!
---@param ... string
---@return string
function M.join_paths(...)
  local result = table.concat({ ... }, path_sep)
  return result
end

--- Run a shell command and capture the output and if the command succeeded or failed
---
---@param cmd string|string[] The terminal command to execute
---@param show_error? boolean Whether or not to show an unsuccessful command as an error to the user
---@return string|nil # The result of a successfully executed command or nil
function M.cmd(cmd, show_error)
  if type(cmd) == "string" then cmd = { cmd } end
  if vim.fn.has("win32") == 1 then cmd = vim.list_extend({ "cmd.exe", "/C" }, cmd) end
  local result = vim.fn.system(cmd)
  local success = vim.api.nvim_get_vvar("shell_error") == 0
  if not success and (show_error == nil or show_error) then
    vim.api.nvim_err_writeln(("Error running command %s\nError message:\n%s"):format(table.concat(cmd, " "), result))
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
  if not worktrees then return end
  file = file or vim.fn.resolve(vim.fn.expand("%"))

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

--- Toggle buffer LSP inlay hints
--- Thanks AstroNvim
---@param bufnr? number of the buffer to toggle the clients on
function M.toggle_buffer_inlay_hints(bufnr)
  bufnr = bufnr or 0
  vim.b[bufnr].inlay_hints_enabled = not vim.b[bufnr].inlay_hints_enabled
  vim.lsp.inlay_hint.enable(bufnr, vim.b[bufnr].inlay_hints_enabled)
end

--- Toggle LSP codelens
function M.toggle_codelens()
  vim.g.codelens_enabled = not vim.g.codelens_enabled
  if not vim.g.codelens_enabled then vim.lsp.codelens.clear() end
end

function M.bool2str(bool) return bool and "on" or "off" end

--- Helper function to check if any active LSP clients given a filter provide a specific capability
---@param capability string The server capability to check for (example: "documentFormattingProvider")
---@param filter vim.lsp.get_clients.filter|nil (table|nil) A table with
---              key-value pairs used to filter the returned clients.
---              The available keys are:
---               - id (number): Only return clients with the given id
---               - bufnr (number): Only return clients attached to this buffer
---               - name (string): Only return clients with the given name
---@return boolean # Whether or not any of the clients provide the capability
function M.has_capability(capability, filter)
  for _, client in ipairs(vim.lsp.get_clients(filter)) do
    if client.supports_method(capability) then return true end
  end
  return false
end

function M.del_buffer_autocmd(augroup, bufnr)
  local cmds_found, cmds = pcall(vim.api.nvim_get_autocmds, { group = augroup, buffer = bufnr })
  if cmds_found then vim.tbl_map(function(cmd) vim.api.nvim_del_autocmd(cmd.id) end, cmds) end
end

---@alias MasonEnsureInstall table<"formatters"|"lsp"|"linters"|"dap"|"extra", string[]|table[]>

---Merge several arrays into 1 array for `mason-tool-installer.nvim`
---@param ... MasonEnsureInstall
function M.mason_merge_tools(...)
  local merge = {}
  for _, v in ipairs({ ... }) do
    if vim.tbl_isarray(v.formatters) then vim.list_extend(merge, v.formatters) end
    if vim.tbl_isarray(v.lsp) then vim.list_extend(merge, v.lsp) end
    if vim.tbl_isarray(v.linters) then vim.list_extend(merge, v.linters) end
    if vim.tbl_isarray(v.dap) then vim.list_extend(merge, v.dap) end
    if vim.tbl_isarray(v.extra) then vim.list_extend(merge, v.extra) end
  end

  local unique_merge = {}
  for _, v in ipairs(merge) do
    if not vim.list_contains(unique_merge, v) then table.insert(unique_merge, v) end
  end
  return unique_merge
end

---Get a list of tools from a specific tool type: lsp, dap, etc.
---@param base table<string, MasonEnsureInstall> The base list of tools
---@param tool_type string The type to extract tools from
---@param with_map boolean? If the name of the tool should be map (lua-language-server -> lua_ls)
---@return string[]
function M.get_from_tools(base, tool_type, with_map)
  local should_map = with_map or false
  local types = {}
  for _, v in pairs(base) do
    if vim.tbl_isarray(v[tool_type]) then
      for _, tool in ipairs(v[tool_type]) do
        local tool_name = should_map and lspconfig_names_map[tool] or tool
        if tool_name and not vim.list_contains(types, tool_name) then table.insert(types, tool_name) end
      end
    end
  end
  return types
end

---Check if buffer belongs to a cwd
---@param bufnr integer
---@param cwd string? Uses current if no cwd is passed
---@return boolean
function M.buf_inside_cwd(bufnr, cwd)
  local dir = cwd or vim.fn.getcwd()
  dir = dir:sub(-1) ~= "/" and dir .. "/" or dir
  return vim.startswith(vim.api.nvim_buf_get_name(bufnr), dir)
end

return M
