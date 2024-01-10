return {
  "EdenEast/nightfox.nvim",
  lazy = false,
  priority = 1000, -- make sure to load this before all the other start plugins
  opts = function()
    local opts = {
      options = {
        transparent = true,
        dim_inactive = false,
      },
      groups = {
        nightfox = {
          ---Make window splits more obvious
          WinSeparator = { fg = "bg2" },
          ---Dim the folded highlight
          Folded = { bg = "bg0" },
          ---Differentiate CodeLens from comments
          LspCodeLens = { bg = "bg0" },
        },
      },
    }

    local C = require("nightfox.lib.color")
    local palette = require("nightfox.palette").load("nightfox")
    ---Improve nightfox colors on diff view
    local DiffViewAdd = C(palette.bg0):blend(C(palette.green.dim), 0.25):to_css()
    local DiffViewChange = C(palette.bg0):blend(C(palette.blue.dim), 0.10):to_css()
    local DiffViewText = C(palette.bg0):blend(C(palette.cyan.dim), 0.5):to_css()

    opts.specs = {
      nightfox = {
        diff = {
          add = DiffViewAdd,
          change = DiffViewChange,
          text = DiffViewText,
        },
      },
    }

    return opts
  end,
  config = function(_, opts)
    require("nightfox").setup(opts)

    local colors_name = {
      nightfox = "nightfox",
      dayfox = "dayfox",
      dawnfox = "dawnfox",
      duskfox = "duskfox",
      nordfox = "nordfox",
      terafox = "terafox",
      carbonfox = "carbonfox",
    }

    vim.cmd("colorscheme " .. colors_name.nightfox)
  end,
}
