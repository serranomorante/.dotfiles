local utils = require("serranomorante.utils")
local autocmd = vim.api.nvim_create_autocmd

return {
  {
    "kwkarlwang/bufresize.nvim",
    event = "VeryLazy",
    config = true,
    init = function()
      -- Fix issue with bufresize and neotree in which toggling
      -- neo-tree (hidding it), then openinng the command line history
      -- window (q:), then closing it, then opening neo-tree again with
      -- `ctrl+o` will resize the cmd window height
      autocmd("CmdwinLeave", {
        callback = function()
          vim.schedule(function() require("bufresize").resize_close() end)
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
        "<A-h>",
        function() require("smart-splits").resize_left() end,
        desc = "Resize left",
      },
      {
        "<A-j>",
        function() require("smart-splits").resize_down() end,
        desc = "Resize down",
      },
      {
        "<A-k>",
        function() require("smart-splits").resize_up() end,
        desc = "Resize up",
      },
      {
        "<A-l>",
        function() require("smart-splits").resize_right() end,
        desc = "Resize right",
      },
      -- Swap splits keymaps
      {
        "<leader><leader>h",
        function()
          -- Quick return if next window is neo-tree
          local next_winid = vim.fn.win_getid(vim.fn.winnr(utils.DirectionKeys[utils.Direction.left]))
          local filetype = utils.buf_filetype_from_winid(next_winid)
          if filetype == "neo-tree" then return end

          require("smart-splits").swap_buf_left()
        end,
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
        function()
          -- Quick return if next window is neo-tree
          local swap_direction = utils.Direction.right
          local will_wrap = utils.win_at_edge(swap_direction)
          if will_wrap then
            local wrap_winid = utils.win_wrap_id(swap_direction)
            local filetype = utils.buf_filetype_from_winid(wrap_winid)
            if filetype == "neo-tree" then return end
          end

          require("smart-splits").swap_buf_right()
        end,
        desc = "Swap right",
      },
    },
    opts = function()
      return {
        cursor_follows_swapped_bufs = true,
        ignored_filetypes = {
          "nofile",
          "prompt",
          "neo-tree",
          "harpoon",
          "NvimTree",
        },
      }
    end,
  },
}
