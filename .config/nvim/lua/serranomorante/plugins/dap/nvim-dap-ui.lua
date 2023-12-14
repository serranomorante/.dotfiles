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
  opts = { floating = { border = "rounded" }, expand_lines = false },
  config = function(_, opts)
    local dap, dapui = require("dap"), require("dapui")
    dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
    dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
    dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end
    dapui.setup(opts)
  end,
}
