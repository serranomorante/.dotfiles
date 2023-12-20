local utils = require("serranomorante.utils")

---`h: dap.ext.vscode.load_launchjs`
local vscode_type_to_ft

return {
  "mfussenegger/nvim-dap",
  event = "User CustomFile",
  dependencies = {
    "rcarriga/nvim-dap-ui",
    "mxsdev/nvim-dap-vscode-js",
    "mfussenegger/nvim-dap-python",
    {
      ---Mason don't have nightly version, so I'm using lazy to build this package from main.
      ---Notice that `vscode-js-debug` has 2 possible build commands: `vsDebugServerBundle` and `dapDebugServer`.
      ---dapDebugServer is DAP compliant and you don't need `mxsdev/nvim-dap-vscode-js` to make it work, but
      ---breakpoints don't work realiable (you must constantly refresh the browser). Also, you need `<=v1.82.0`
      ---vsDebugServerBundle is not DAP compliant, that's why you need `mxsdev/nvim-dap-vscode-js` to make it
      ---work with nvim-dap. The good part is that breakpoints work a lot better with this adapter.
      ---https://github.com/mxsdev/nvim-dap-vscode-js?tab=readme-ov-file#debugger
      "microsoft/vscode-js-debug",
      build = "npm install --no-save --legacy-peer-deps && npx gulp vsDebugServerBundle && mv dist out",
    },
  },
  keys = {
    { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Toggle Breakpoint (F9)" },
    { "<leader>dB", function() require("dap").clear_breakpoints() end, desc = "Clear Breakpoints" },
    {
      "<leader>dc",
      function()
        ---Load most recent `.vscode/launch.json` config
        ---https://github.com/mfussenegger/nvim-dap/issues/20#issuecomment-1356791734
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
    local mason_registry = require("mason-registry")
    dap.set_log_level(vim.env.DAP_LOG_LEVEL or "INFO")

    -- This env variable comes from my personal .bashrc file
    local system_node_version = vim.env.SYSTEM_DEFAULT_NODE_VERSION or "latest"
    -- Bypass volta's context detection to prevent running the debugger with unsupported node versions
    local node_path = utils.cmd({ "volta", "run", "--node", system_node_version, "which", "node" }):gsub("\n", "")

    local firefox_dap = mason_registry.get_package("firefox-debug-adapter")
    local python_dap = mason_registry.get_package("debugpy")

    if node_path and firefox_dap and python_dap then
      local vscode_js_debug_path = vim.fn.stdpath("data") .. "/lazy/vscode-js-debug"
      local firefox_dap_executable = firefox_dap:get_install_path() .. "/dist/adapter.bundle.js"
      local python_dap_executable = python_dap:get_install_path() .. "/venv/bin/python"

      require("dap-vscode-js").setup({
        node_path = node_path,
        debugger_path = vscode_js_debug_path,
        adapters = { "pwa-node", "pwa-chrome", "pwa-msedge", "node-terminal", "pwa-extensionHost" },
        log_file_level = vim.log.levels[vim.env.DAP_LOG_LEVEL or "INFO"],
      })

      require("dap-python").setup(python_dap_executable)

      dap.adapters.firefox = {
        type = "executable",
        command = node_path,
        args = { firefox_dap_executable },
      }

      local js_filtypes = { "typescript", "javascript", "javascriptreact", "typescriptreact" }
      for _, language in ipairs(js_filtypes) do
        dap.configurations[language] = {
          {
            name = "DAP: Debug with PWA Chrome",
            type = "pwa-chrome",
            request = "launch",
            url = "http://localhost:3000",
            sourceMaps = true,
          },
          {
            name = "DAP: Debug with PWA Edge",
            type = "pwa-msedge",
            request = "launch",
            url = "http://localhost:3000",
            sourceMaps = true,
          },
          {
            name = "DAP: Debug with Firefox",
            type = "firefox",
            request = "launch",
            reAttach = true,
            url = "http://localhost:3000",
            webRoot = "${workspaceFolder}",
            sourceMaps = true,
            skipFiles = {
              "${workspaceFolder}/<node_internals>/**",
              "${workspaceFolder}/node_modules/**",
            },
          },
          ---While vscode supports typescript files as entrypoints to your debugger
          ---`nvim-dap-vscode-js` needs a loader like `ts-node`. A different approach
          ---could be using `vscode-node-debug2` but it is archived.
          {
            name = "DAP: Debug with Node (ts-node)",
            type = "pwa-node",
            request = "launch",
            cwd = "${workspaceFolder}",
            runtimeExecutable = "node",
            runtimeArgs = { "--loader", "ts-node/esm" },
            args = { "${file}" },
            sourceMaps = true,
            protocol = "inspector",
            skipFiles = { "<node_internals>/**", "node_modules/**" },
            resolveSourceMapLocations = {
              "${workspaceFolder}/**",
              "!**/node_modules/**",
            },
          },
        }
      end

      ---https://github.com/stevearc/overseer.nvim/blob/master/doc/third_party.md#dap
      require("overseer").patch_dap(true)
      require("dap.ext.vscode").json_decode = require("overseer.json").decode

      ---@diagnostic disable-next-line: unused-local
      vscode_type_to_ft = {
        ["pwa-chrome"] = js_filtypes,
        ["pwa-msedge"] = js_filtypes,
        ["pwa-node"] = js_filtypes,
        ["firefox"] = js_filtypes,
      }
    end
  end,
}
