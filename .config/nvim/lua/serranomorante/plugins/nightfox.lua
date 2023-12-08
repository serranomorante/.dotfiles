return {
  "EdenEast/nightfox.nvim",
  lazy = false,
  priority = 1000, -- make sure to load this before all the other start plugins
  opts = {
    options = {
      transparent = true,
      dim_inactive = false,
    },
    groups = {
      nightfox = {
        -- Make window splits more obvious
        WinSeparator = { fg = "bg2" },
        -- Dim the folded highlight
        Folded = { bg = "bg0" },
        -- Differentiate CodeLens from comments
        LspCodeLens = { bg = "bg0" },
      },
    },
  },
  config = function(_, opts)
    require("nightfox").setup(opts)

    vim.cmd([[colorscheme nightfox]])
  end,
}
