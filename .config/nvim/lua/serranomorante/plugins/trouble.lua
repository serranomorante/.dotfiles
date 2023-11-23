return {
  "folke/trouble.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  keys = {
    {
      "<leader>xw",
      function() require("trouble").toggle("workspace_diagnostics") end,
      desc = "Toggle workspace diagnostics",
    },
  },
  config = true,
}
