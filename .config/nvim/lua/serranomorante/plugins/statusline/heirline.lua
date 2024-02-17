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

    local Align = { provider = "%=" }
    local Space = { provider = " " }
    local Mode = heirline_utils.surround({ " ", " " }, nil, { components.Mode })
    local FileNameBlock = heirline_utils.surround({ " ", " " }, nil, { components.FileNameBlock })
    local FileName = heirline_utils.surround({ " ", " " }, nil, { components.FileName })
    local Git = heirline_utils.surround({ " ", " " }, nil, { components.Git })
    local Diagnostics = heirline_utils.surround({ " ", " " }, nil, { components.Diagnostics })
    local DAPMessages = heirline_utils.surround({ " ", " " }, nil, { components.DAPMessages })
    local LSPActive = heirline_utils.surround({ " ", " " }, nil, { components.LSPActive })
    local Ruler = heirline_utils.surround({ " ", " " }, nil, { components.Ruler })

    local DefaultStatusLine = {
      Mode,
      Space,
      FileNameBlock,
      Space,
      Git,
      Space,
      Diagnostics,
      Align,

      DAPMessages,
      Align,

      { flexible = 1, LSPActive, { provider = "" } },
      Space,
      Ruler,
    }

    local InactiveStatusLine = {
      condition = conditions.is_not_active,
      FileName,
      Align,
    }

    local DAPUIStatusLine = {
      condition = function() return conditions.is_active() and conditions.buffer_matches({ filetype = { "^dapui.*" } }) end,
      FileNameBlock,
      Align,
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
