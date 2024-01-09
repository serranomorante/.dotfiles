local utils = require("serranomorante.utils")

return {
  "lukas-reineke/indent-blankline.nvim",
  event = "User CustomFile",
  main = "ibl",
  opts = {
    indent = {
      char = "▏",
      priority = 11, -- Fix visibility on folded lines
    },
    scope = {
      enabled = true,
      include = { node_type = { ["*"] = { "function_declaration" } } },
      show_start = false,
      show_end = false,
    },
    exclude = {
      buftypes = {
        "nofile",
        "terminal",
      },
      filetypes = {
        "help",
        "lazy",
      },
    },
  },
  config = function(_, opts)
    if utils.is_available("nightfox.nvim") then
      if vim.g.colors_name == "nightfox" then
        local palette = require("nightfox.palette").load("nightfox")

        -- Dim the color of the indent separator char
        vim.api.nvim_set_hl(0, "IblIndent", { fg = palette.bg0 })
        vim.api.nvim_set_hl(0, "IblScope", { fg = palette.bg3 })
      end
    end
    require("ibl").setup(opts)
  end,
}
