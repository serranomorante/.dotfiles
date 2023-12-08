local utils = require("serranomorante.utils")

return {
  "lukas-reineke/indent-blankline.nvim",
  event = "User CustomFile",
  main = "ibl",
  opts = {
    indent = { char = "▏" },
    scope = { enabled = false },
    exclude = {
      buftypes = {
        "nofile",
        "terminal",
      },
      filetypes = {
        "help",
        "lazy",
        "neo-tree",
        "Trouble",
      },
    },
  },
  config = function(_, opts)
    if utils.is_available("nightfox.nvim") then
      local palette = require("nightfox.palette").load("nightfox")

      -- Dim the color of the indent separator char
      vim.api.nvim_set_hl(0, "IblIndent", { fg = palette.bg0 })
    end
    require("ibl").setup(opts)
  end,
}
