return {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  dependencies = "nvim-lua/plenary.nvim",
  keys = {
    {
      "<leader>aa",
      function() require("harpoon"):list():append() end,
      desc = "Add file to harpoon",
    },
    {
      "<leader>ae",
      function() require("harpoon").ui:toggle_quick_menu(require("harpoon"):list()) end,
      desc = "Toggle harpoon menu",
    },
  },
  opts = {
    settings = {
      save_on_toggle = true,
    },
  },
  config = function(_, opts) require("harpoon").setup(opts) end,
}
