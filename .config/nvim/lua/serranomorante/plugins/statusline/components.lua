local constants = require("serranomorante.constants")
local heirline_conditions = require("heirline.conditions")
local heirline_utils = require("heirline.utils")

local M = {}

---https://github.com/rebelot/heirline.nvim/blob/master/cookbook.md#crash-course-the-vimode
M.Mode = {
  init = function(self) self.mode = vim.fn.mode() end,
  static = {
    modes = constants.modes,
  },
  provider = function(self)
    ---Control the padding and make sure our string is always at least 2
    ---characters long.
    return "%2(" .. self.modes[self.mode][1] .. "%)"
  end,
  hl = function(self)
    ---Change the foreground according to the current mode
    return { fg = self.modes[self.mode][2], bold = true }
  end,
  update = {
    "ModeChanged",
    pattern = "*:*",
    callback = vim.schedule_wrap(function() vim.cmd("redrawstatus") end),
  },
}

---https://github.com/rebelot/heirline.nvim/blob/master/cookbook.md#crash-course-part-ii-filename-and-friends
M.FileNameBlock = {
  init = function(self) self.filename = vim.api.nvim_buf_get_name(0) end,
}

M.FileIcon = {
  init = function(self)
    local filename = self.filename
    local extension = vim.fn.fnamemodify(filename, ":e")
    self.icon, self.icon_color = require("nvim-web-devicons").get_icon_color(filename, extension, { default = true })
  end,
  provider = function(self) return self.icon and (self.icon .. " ") end,
  hl = function(self) return { fg = self.icon_color } end,
}

M.FileName = {
  provider = function(self)
    local filename = vim.fn.fnamemodify(self.filename or vim.api.nvim_buf_get_name(0), ":.")
    if filename == "" then return "[No Name]" end
    if not heirline_conditions.width_percent_below(#filename, 0.25) then filename = vim.fn.pathshorten(filename) end
    return filename
  end,
  hl = { fg = heirline_utils.get_highlight("Directory").fg },
}

M.FileFlags = {
  {
    condition = function() return vim.bo.modified end,
    provider = "[+]",
    hl = { fg = "green" },
  },
  {
    condition = function() return not vim.bo.modifiable or vim.bo.readonly end,
    provider = "",
    hl = { fg = "orange" },
  },
}

M.FileNameModifier = {
  hl = function()
    if vim.bo.modified then return { fg = "cyan", bold = true, force = true } end
  end,
}

M.FileNameBlock = heirline_utils.insert(
  M.FileNameBlock,
  M.FileIcon,
  heirline_utils.insert(M.FileNameModifier, M.FileName),
  M.FileFlags,
  { provider = "%<" }
)

---https://github.com/rebelot/heirline.nvim/blob/master/cookbook.md#cursor-position-ruler-and-scrollbar
M.Ruler = {
  -- %l = current line number
  -- %L = number of lines in the buffer
  -- %c = column number
  -- %P = percentage through file of displayed window
  provider = "%P",
}

---https://github.com/rebelot/heirline.nvim/blob/master/cookbook.md#lsp
M.LSPActive = {
  condition = heirline_conditions.lsp_attached,
  update = { "LspAttach", "LspDetach" },

  -- You can keep it simple,
  -- provider = " [LSP]",

  -- Or complicate things a bit and get the servers names
  provider = function()
    local names = {}
    for _, server in pairs(vim.lsp.get_clients({ bufnr = 0 })) do
      table.insert(names, server.name)
    end
    return " [" .. table.concat(names, ", ") .. "]"
  end,
  hl = { fg = "green", bold = true },
}

---https://github.com/rebelot/heirline.nvim/blob/master/cookbook.md#diagnostics
---https://github.com/neovim/neovim/commit/4ee656e4f35766bef4e27c5afbfa8e3d8d74a76c
M.Diagnostics = {
  condition = heirline_conditions.has_diagnostics,
  static = {
    error_icon = " ",
    warn_icon = " ",
    hint_icon = "󰌵 ",
    info_icon = "󰋼 ",
  },
  init = function(self) self.diagnostics = vim.diagnostic.count(0) or {} end,
  update = { "DiagnosticChanged", "LspAttach", "LspDetach", "BufEnter" },
  {
    provider = function(self)
      local errors = self.diagnostics[vim.diagnostic.severity.ERROR]
      return errors and (self.error_icon .. errors .. " ")
    end,
    hl = { fg = "diag_error" },
  },
  {
    provider = function(self)
      local warns = self.diagnostics[vim.diagnostic.severity.WARN]
      return warns and (self.warn_icon .. warns .. " ")
    end,
    hl = { fg = "diag_warn" },
  },
  {
    provider = function(self)
      local info = self.diagnostics[vim.diagnostic.severity.INFO]
      return info and (self.info_icon .. info .. " ")
    end,
    hl = { fg = "diag_info" },
  },
  {
    provider = function(self)
      local hints = self.diagnostics[vim.diagnostic.severity.HINT]
      return hints and (self.hint_icon .. hints)
    end,
    hl = { fg = "diag_hint" },
  },
}

---https://github.com/rebelot/heirline.nvim/blob/master/cookbook.md#git
M.Git = {
  condition = heirline_conditions.is_git_repo,
  init = function(self)
    self.status_dict = vim.b.gitsigns_status_dict
    self.has_changes = self.status_dict.added ~= 0 or self.status_dict.removed ~= 0 or self.status_dict.changed ~= 0
  end,
  hl = { fg = "orange" },
  { -- git branch name
    provider = function(self) return " " .. self.status_dict.head end,
    hl = { bold = true },
  },
  -- You could handle delimiters, icons and counts similar to Diagnostics
  {
    condition = function(self) return self.has_changes end,
    provider = "(",
  },
  {
    provider = function(self)
      local count = self.status_dict.added or 0
      return count > 0 and ("+" .. count)
    end,
    hl = { fg = "git_add" },
  },
  {
    provider = function(self)
      local count = self.status_dict.removed or 0
      return count > 0 and ("-" .. count)
    end,
    hl = { fg = "git_del" },
  },
  {
    provider = function(self)
      local count = self.status_dict.changed or 0
      return count > 0 and ("~" .. count)
    end,
    hl = { fg = "git_change" },
  },
  {
    condition = function(self) return self.has_changes end,
    provider = ")",
  },
}

---https://github.com/rebelot/heirline.nvim/blob/master/cookbook.md#debugger
M.DAPMessages = {
  condition = function()
    local session = require("dap").session()
    return session ~= nil
  end,
  provider = function() return " " .. require("dap").status() end,
  hl = "Debug",
}

return M
