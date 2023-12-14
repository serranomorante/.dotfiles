local utils = require("serranomorante.utils")

return {
  "mfussenegger/nvim-dap",
  event = "User CustomFile",
  dependencies = "rcarriga/nvim-dap-ui",
  keys = {
    { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Toggle Breakpoint (F9)" },
    { "<leader>dB", function() require("dap").clear_breakpoints() end, desc = "Clear Breakpoints" },
    { "<leader>dc", function() require("dap").continue() end, desc = "Start/Continue (F5)" },
    {
      "<leader>dC",
      function()
        vim.ui.input({ prompt = "Condition: " }, function(condition)
          if condition then require("dap").set_breakpoint(condition) end
        end)
      end,
      desc = "Conditional Breakpoint (S-F9)",
    },
    { "<leader>di", function() require("dap").step_into() end, desc = "Step Into (F11)" },
    { "<leader>do", function() require("dap").step_over() end, desc = "Step Over (F10)" },
    { "<leader>dO", function() require("dap").step_out() end, desc = "Step Out (S-F11)" },
    { "<leader>dq", function() require("dap").close() end, desc = "Close Session" },
    { "<leader>dQ", function() require("dap").terminate() end, desc = "Terminate Session (S-F5)" },
    { "<leader>dp", function() require("dap").pause() end, desc = "Pause (F6)" },
    { "<leader>dr", function() require("dap").restart_frame() end, desc = "Restart (C-F5)" },
    { "<leader>dR", function() require("dap").repl.toggle() end, desc = "Toggle REPL" },
    { "<leader>ds", function() require("dap").run_to_cursor() end, desc = "Run To Cursor" },
    { "<leader>dh", function() require("dap.ui.widgets").hover() end, desc = "Debugger Hover" },
  },
  config = function()
    local mason_js_debug_adapter = require("mason-registry").get_package("js-debug-adapter")
    local dynamic_port = "${port}" -- make nvim-dap resolve a free port.

    -- This env variable comes from my personal .bashrc file
    local system_node_version = vim.env.SYSTEM_DEFAULT_NODE_VERSION or "latest"
    -- Bypass volta's context detection to prevent running the debugger with unsupported node versions
    local node_path = utils.cmd({ "volta", "run", "--node", system_node_version, "which", "node" }):gsub("\n", "")

    if node_path and mason_js_debug_adapter then
      local js_debug_adapter_entrypoint = mason_js_debug_adapter:get_install_path() .. "/js-debug/src/dapDebugServer.js"

      -- [docs]: https://github.com/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation#javascript
      -- [issue]: https://github.com/microsoft/vscode-js-debug/issues/1388#issuecomment-1483168025
      -- [example]: https://github.com/mxsdev/nvim-dap-vscode-js/issues/63#issuecomment-1801935986
      require("dap").adapters["pwa-chrome"] = {
        type = "server",
        host = "localhost",
        port = dynamic_port,
        executable = {
          command = node_path,
          args = {
            js_debug_adapter_entrypoint,
            dynamic_port,
          },
        },
      }

      for _, language in ipairs({ "typescript", "javascript" }) do
        require("dap").configurations[language] = {
          {
            type = "pwa-chrome",
            request = "launch",
            name = "Launch Chrome",
          },
        }
      end
    end
  end,
}
