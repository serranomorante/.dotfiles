local utils = require("serranomorante.utils")

---`h: dap.ext.vscode.load_launchjs`
local vscode_type_to_ft

return {
  "mfussenegger/nvim-dap",
  event = "User CustomFile",
  dependencies = "rcarriga/nvim-dap-ui",
  keys = {
    { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Toggle Breakpoint (F9)" },
    { "<leader>dB", function() require("dap").clear_breakpoints() end, desc = "Clear Breakpoints" },
    {
      "<leader>dc",
      function()
        -- https://github.com/mfussenegger/nvim-dap/issues/20#issuecomment-1356791734
        require("dap.ext.vscode").load_launchjs(nil, vscode_type_to_ft)
        require("dap").continue()
      end,
      desc = "Start/Continue (F5)",
    },
    {
      "<leader>dC",
      function()
        vim.ui.input({ prompt = "Condition: " }, function(condition)
          if condition then require("dap").set_breakpoint(condition) end
        end)
      end,
      desc = "Conditional Breakpoint (S-F9)",
    },
    {
      "<leader>dl",
      function() require("dap").set_breakpoint(nil, nil, vim.fn.input("Log point message: ")) end,
      desc = "Log Point",
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
  init = function()
    vim.api.nvim_create_autocmd("ColorScheme", {
      pattern = "*",
      group = vim.api.nvim_create_augroup("preserve_self_defined_colors", { clear = true }),
      desc = "prevent colorscheme clears self-defined DAP icon colors.",
      callback = function()
        vim.api.nvim_set_hl(0, "DapBreakpoint", { ctermbg = 0, fg = "#993939" })
        vim.api.nvim_set_hl(0, "DapLogPoint", { ctermbg = 0, fg = "#61afef" })
        vim.api.nvim_set_hl(0, "DapStopped", { ctermbg = 0, fg = "#98c379" })
      end,
    })

    vim.fn.sign_define("DapBreakpoint", { text = " ", texthl = "DapBreakpoint" })
    vim.fn.sign_define("DapBreakpointCondition", { text = " ", texthl = "DapBreakpoint" })
    vim.fn.sign_define("DapBreakpointRejected", { text = " ", texthl = "DapBreakpoint" })
    vim.fn.sign_define("DapLogPoint", { text = ".>", texthl = "DapLogPoint" })
    vim.fn.sign_define("DapStopped", { text = "󰁕 ", texthl = "DapStopped" })
  end,
  config = function()
    local dap = require("dap")
    -- require("dap").set_log_level("TRACE")
    local mason_js_debug_adapter = require("mason-registry").get_package("js-debug-adapter")
    local mason_firefox_debug_adapter = require("mason-registry").get_package("firefox-debug-adapter")
    local dynamic_port = "${port}" -- make nvim-dap resolve a free port.

    -- This env variable comes from my personal .bashrc file
    local system_node_version = vim.env.SYSTEM_DEFAULT_NODE_VERSION or "latest"
    -- Bypass volta's context detection to prevent running the debugger with unsupported node versions
    local node_path = utils.cmd({ "volta", "run", "--node", system_node_version, "which", "node" }):gsub("\n", "")

    if node_path and mason_js_debug_adapter then
      local js_debug_adapter_entrypoint = mason_js_debug_adapter:get_install_path() .. "/js-debug/src/dapDebugServer.js"
      local firefox_debug_adapter_entrypoint = mason_firefox_debug_adapter:get_install_path()
        .. "/dist/adapter.bundle.js"

      -- [docs]: https://github.com/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation#javascript
      -- [issue]: https://github.com/microsoft/vscode-js-debug/issues/1388#issuecomment-1483168025
      -- [example]: https://github.com/mxsdev/nvim-dap-vscode-js/issues/63#issuecomment-1801935986
      for _, chromium in ipairs({ "pwa-chrome", "pwa-msedge", "chrome" }) do
        dap.adapters[chromium] = {
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
      end

      dap.adapters.firefox = {
        type = "executable",
        command = node_path,
        args = { firefox_debug_adapter_entrypoint },
      }

      local js_filtypes = { "typescript", "javascript", "javascriptreact", "typescriptreact" }
      for _, language in ipairs(js_filtypes) do
        dap.configurations[language] = {
          {
            name = "DAP: Debug with PWA Chrome",
            type = "pwa-chrome",
            request = "launch",
            url = "http://localhost:3000",
          },

          {
            name = "DAP: Debug with PWA Edge",
            type = "pwa-msedge",
            request = "launch",
            url = "http://localhost:3000",
          },

          {
            name = "DAP: Debug with Firefox",
            type = "firefox",
            request = "launch",
            reAttach = true,
            url = "http://localhost:3000",
            webRoot = "${workspaceFolder}",
            skipFiles = {
              "${workspaceFolder}/<node_internals>/**",
              "${workspaceFolder}/node_modules/**",
            },
            firefoxExecutable = "/usr/bin/firefox-developer-edition",
          },
        }
      end

      ---@diagnostic disable-next-line: unused-local
      vscode_type_to_ft = {
        ["pwa-chrome"] = js_filtypes,
        ["firefox"] = js_filtypes,
        ["chrome"] = js_filtypes,
      }
    end
  end,
}
