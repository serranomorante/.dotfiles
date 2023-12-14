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
    { "<leader>du", function() require("dapui").toggle() end, desc = "Toggle Debugger UI" },
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
    dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
    dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
    dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end
    dapui.setup(opts)
  end,
}
