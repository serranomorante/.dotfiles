return {
  "rcarriga/nvim-dap-ui",
  lazy = true,
  dependencies = "mfussenegger/nvim-dap",
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
      function() require("dapui").toggle() end,
      desc = "Toggle Debugger UI",
    },
  },
  opts = { floating = { border = "single" }, expand_lines = false, render = { max_value_lines = 10 } },
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
}
