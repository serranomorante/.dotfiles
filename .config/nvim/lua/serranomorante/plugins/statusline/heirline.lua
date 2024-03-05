return {
  "rebelot/heirline.nvim",
  event = "UiEnter",
  opts = function()
    local conditions = require("heirline.conditions")
    local heirline_utils = require("heirline.utils")
    local components = require("serranomorante.plugins.statusline.components")

    local Function = heirline_utils.get_highlight("Function")
    local Constant = heirline_utils.get_highlight("Constant")
    local String = heirline_utils.get_highlight("String")
    local Statement = heirline_utils.get_highlight("Statement")
    local Folded = heirline_utils.get_highlight("Folded")
    local DiagnosticError = heirline_utils.get_highlight("DiagnosticError")
    local DiffDelete = heirline_utils.get_highlight("DiffDelete")
    local NonText = heirline_utils.get_highlight("NonText")
    local Special = heirline_utils.get_highlight("Special")
    local DiagnosticWarn = heirline_utils.get_highlight("DiagnosticWarn")
    local DiagnosticHint = heirline_utils.get_highlight("DiagnosticHint")
    local DiagnosticInfo = heirline_utils.get_highlight("DiagnosticInfo")
    local DiffRemoved = heirline_utils.get_highlight("diffRemoved")
    local DiffAdded = heirline_utils.get_highlight("diffAdded")
    local DiffChanged = heirline_utils.get_highlight("diffChanged")
    local Directory = heirline_utils.get_highlight("Directory")

    local colors = {
      normal = Function.fg,
      insert = Constant.fg,
      command = String.fg,
      terminal = Constant.fg,
      visual = Statement.fg,
      replace = DiagnosticError.fg,
      directory = Directory.fg,
      ---https://github.com/rebelot/heirline.nvim/blob/master/cookbook.md#colors-colors-more-colors
      bright_bg = Folded.bg,
      bright_fg = Folded.fg,
      red = DiagnosticError.fg,
      dark_red = DiffDelete.bg,
      green = String.fg,
      blue = Function.fg,
      gray = NonText.fg,
      orange = Constant.fg,
      purple = Statement.fg,
      cyan = Special.fg,
      diag_warn = DiagnosticWarn.fg,
      diag_error = DiagnosticError.fg,
      diag_hint = DiagnosticHint.fg,
      diag_info = DiagnosticInfo.fg,
      git_del = DiffRemoved.fg,
      git_add = DiffAdded.fg,
      git_change = DiffChanged.fg,
    }

    local DefaultStatusLine = {
      components.Mode,
      components.Space,
      components.FileNameBlock,
      components.Space,
      components.Git,
      components.Diagnostics,
      components.Align,

      components.DAPMessages,
      components.Space,
      components.Overseer,
      components.Align,

      components.LSPActive,
      components.Space,
      components.Ruler,
    }

    local InactiveStatusLine = {
      condition = conditions.is_not_active,
      components.FileName,
      components.Align,
    }

    local DAPUIStatusLine = {
      condition = function() return conditions.is_active() and conditions.buffer_matches({ filetype = { "^dap-.*" } }) end,
      components.FileNameBlock,
      components.Align,
    }

    local StatusLines = {
      hl = function() return conditions.is_active() and "StatusLine" or "StatusLineNC" end,
      fallthrough = false,
      DAPUIStatusLine,
      InactiveStatusLine,
      DefaultStatusLine,
    }

    return {
      statusline = StatusLines,
      opts = { colors = colors },
    }
  end,
}
