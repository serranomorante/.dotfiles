return {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
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
  -- opts = {
  --   global_settings = {
  --     excluded_filetypes = { "harpoon", "neo-tree", "NvimTree" },
  --   },
  --   menu = {
  --     width = is_valid_width and width or DEFAULT_WIDTH,
  --   },
  -- },
  config = function(_, opts) require("harpoon").setup(opts) end,
}
