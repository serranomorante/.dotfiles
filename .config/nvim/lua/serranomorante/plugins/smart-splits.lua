local utils = require("serranomorante.utils")
local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

return {
  {
    "kwkarlwang/bufresize.nvim",
    event = "VeryLazy",
    config = true,
    init = function()
      ---Make bufresize aware of tab bar toggling
      autocmd({ "TabNewEntered", "TabClosed" }, {
        desc = "Resize after tab open/close shifts the view",
        group = augroup("tab_bufresize", { clear = true }),
        callback = function()
          local tabpages = vim.api.nvim_list_tabpages()
          local is_first_tab_to_enter = #tabpages == 1
          local is_last_tab_to_leave = #tabpages == 2

          if is_first_tab_to_enter then require("bufresize").register() end
          if is_last_tab_to_leave then require("bufresize").register() end
        end,
      })
    end,
  },

  {
    "mrjones2014/smart-splits.nvim",
    keys = {
      -- Moving between splits
      {
        "<C-h>",
        function() require("smart-splits").move_cursor_left() end,
        desc = "Move cursor left",
      },
      {
        "<C-j>",
        function() require("smart-splits").move_cursor_down() end,
        desc = "Move cursor down",
      },
      {
        "<C-k>",
        function() require("smart-splits").move_cursor_up() end,
        desc = "Move cursor up",
      },
      {
        "<C-l>",
        function() require("smart-splits").move_cursor_right() end,
        desc = "Move cursor right",
      },
      -- Resize splits keymaps
      {
        "<C-Left>",
        function()
          require("smart-splits").resize_left()
          if utils.is_available("bufresize.nvim") then require("bufresize").register() end
        end,
        desc = "Resize left",
      },
      {
        "<C-Down>",
        function()
          require("smart-splits").resize_down()
          if utils.is_available("bufresize.nvim") then require("bufresize").register() end
        end,
        desc = "Resize down",
      },
      {
        "<C-Up>",
        function()
          require("smart-splits").resize_up()
          if utils.is_available("bufresize.nvim") then require("bufresize").register() end
        end,
        desc = "Resize up",
      },
      {
        "<C-Right>",
        function()
          require("smart-splits").resize_right()
          if utils.is_available("bufresize.nvim") then require("bufresize").register() end
        end,
        desc = "Resize right",
      },
      -- Swap splits keymaps
      {
        "<leader><leader>h",
        function() require("smart-splits").swap_buf_left() end,
        desc = "Swap left",
      },
      {
        "<leader><leader>j",
        function() require("smart-splits").swap_buf_down() end,
        desc = "Swap down",
      },
      {
        "<leader><leader>k",
        function() require("smart-splits").swap_buf_up() end,
        desc = "Swap up",
      },
      {
        "<leader><leader>l",
        function() require("smart-splits").swap_buf_right() end,
        desc = "Swap right",
      },
    },
    opts = {
      cursor_follows_swapped_bufs = true,
      ignored_filetypes = {
        "nofile",
        "prompt",
        "neo-tree",
        "harpoon",
        "NvimTree",
      },
    },
  },
}
