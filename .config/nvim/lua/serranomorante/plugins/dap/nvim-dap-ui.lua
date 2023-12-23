local utils = require("serranomorante.utils")

return {
  "rcarriga/nvim-dap-ui",
  lazy = true,
  keys = {
    {
      "<leader>dE",
      function()
        vim.ui.input({ prompt = "Expression: " }, function(expr)
          if expr then require("dapui").eval(expr, { enter = true }) end
        end)
      end,
      desc = "Evaluate Input",
    },
    { "<leader>dE", function() require("dapui").eval() end, desc = "Evaluate Input" },
    {
      "<leader>du",
      function()
        if utils.is_available("bufresize.nvim") then require("bufresize").block_register() end
        if utils.is_available("neo-tree.nvim") then vim.cmd("Neotree close") end
        require("dapui").toggle()
        if utils.is_available("bufresize.nvim") then
          require("bufresize").unblock_register()
          require("bufresize").register()
        end
      end,
      desc = "Toggle Debugger UI",
    },
  },
  opts = { floating = { border = "rounded" }, expand_lines = false, render = { max_value_lines = 10 } },
  init = function()
    vim.api.nvim_create_autocmd("BufWinEnter", {
      desc = "Set options on DAP windows",
      group = vim.api.nvim_create_augroup("set_dap_win_options", { clear = true }),
      pattern = { "\\[dap-repl\\]", "DAP *" },
      callback = function(args)
        local win = vim.fn.bufwinid(args.buf)
        vim.schedule(function()
          if not vim.api.nvim_win_is_valid(win) then return end
          vim.api.nvim_set_option_value("number", true, { win = win })
        end)
      end,
    })
  end,
  config = function(_, opts)
    local dap, dapui = require("dap"), require("dapui")

    dap.listeners.after.event_initialized["dapui_config"] = function()
      -- Increase performance? Prevent bufresize autocmds from processing all the dap window events
      if utils.is_available("bufresize.nvim") then require("bufresize").block_register() end
      if utils.is_available("neo-tree.nvim") then vim.cmd("Neotree close") end
      dapui.open()

      -- Keep DAP windows dimensions in proportion when nvim is resized
      if utils.is_available("bufresize.nvim") then
        require("bufresize").unblock_register()
        require("bufresize").register()
      end
    end
    dap.listeners.before.event_terminated["dapui_config"] = function()
      if utils.is_available("bufresize.nvim") then require("bufresize").block_register() end
      dapui.close()
      if utils.is_available("bufresize.nvim") then
        require("bufresize").unblock_register()
        require("bufresize").register()
      end
    end
    dap.listeners.before.event_exited["dapui_config"] = function()
      if utils.is_available("bufresize.nvim") then require("bufresize").block_register() end
      dapui.close()
      if utils.is_available("bufresize.nvim") then
        require("bufresize").unblock_register()
        require("bufresize").register()
      end
    end
    dapui.setup(opts)
  end,
}
