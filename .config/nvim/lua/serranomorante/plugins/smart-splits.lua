local utils = require("serranomorante.utils")
local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

return {
  {
    "kwkarlwang/bufresize.nvim",
    event = "VeryLazy",
    config = true,
    init = function()
      -- bufresize registers the "BufWinEnter", "WinEnter" events emitted from the cmd window
      -- This causes neo-tree to resize the cmd line if the cmd window was previously closed
      autocmd("CmdwinLeave", {
        desc = "Resize after leaving command line view",
        group = augroup("cmd_win_leave_resize", { clear = true }),
        callback = function()
          vim.schedule(function()
            -- Wrapped in a schedule so this executed when the cmd window is already closed
            require("bufresize").register()
          end)
        end,
      })

      -- Make bufresize aware of tab bar toggling
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
