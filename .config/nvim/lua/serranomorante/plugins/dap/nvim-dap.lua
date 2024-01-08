local utils = require("serranomorante.utils")

---Debuggers can exist on one of 2 folders: `mason` or `debuggers`
---Mason: installed automatically. Usually for stable versions of packages.
---Debuggers: installed manually. Usually for nightly versions of packages.
---`debuggers` is a custom folder on my system for vscode extensions like `cpp_tools`.

---`h: dap.ext.vscode.load_launchjs`
local vscode_type_to_ft

return {
  "mfussenegger/nvim-dap",
  dependencies = {
    "mxsdev/nvim-dap-vscode-js",
    "mfussenegger/nvim-dap-python",
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
    require("cmp_dap")
    local dap = require("dap")
    local dapui = require("dapui")
    local mason_registry = require("mason-registry")
    dap.set_log_level(vim.env.DAP_LOG_LEVEL or "INFO")

    dap.listeners.before.attach["dapui_config"] = dapui.open
    dap.listeners.before.launch["dapui_config"] = dapui.open

    ---╔══════════════════════════════════════╗
    ---║               Adapters               ║
    ---╚══════════════════════════════════════╝

    ---This env variable comes from my personal .bashrc file
    local system_node_version = vim.env.SYSTEM_DEFAULT_NODE_VERSION or "latest"
    ---Bypass volta's context detection to prevent running the debugger with unsupported node versions
    local node_path = utils.cmd({ "volta", "run", "--node", system_node_version, "which", "node" }):gsub("\n", "")

    ---https://github.com/mxsdev/nvim-dap-vscode-js?tab=readme-ov-file#debugger
    local vscode_js_debug_path = vim.fn.stdpath("data") .. "/debuggers/vscode-js-debug"

    if node_path and utils.is_available("nvim-dap-vscode-js") and vim.fn.isdirectory(vscode_js_debug_path) then
      ---https://github.com/mxsdev/nvim-dap-vscode-js?tab=readme-ov-file#setup
      require("dap-vscode-js").setup({
        node_path = node_path,
        debugger_path = vscode_js_debug_path,
        adapters = { "pwa-node", "pwa-chrome", "pwa-msedge", "node-terminal", "pwa-extensionHost" },
        log_file_level = vim.log.levels[vim.env.DAP_LOG_LEVEL or "INFO"],
        log_console_level = false, -- too much noise
      })
    end

    local firefox_dap = mason_registry.get_package("firefox-debug-adapter")

    if node_path and firefox_dap then
      local firefox_dap_executable = firefox_dap:get_install_path() .. "/dist/adapter.bundle.js"

      ---https://github.com/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation#javascript-firefox
      dap.adapters.firefox = {
        type = "executable",
        command = node_path,
        args = { firefox_dap_executable },
      }
    end

    local python_dap = mason_registry.get_package("debugpy")

    if python_dap then
      local python_dap_executable = python_dap:get_install_path() .. "/venv/bin/python"

      ---https://github.com/mfussenegger/nvim-dap-python?tab=readme-ov-file#usage
      require("dap-python").setup(python_dap_executable)
    end

    local cpp_tools_executable = vim.fn.stdpath("data")
      .. "/debuggers/cpp_tools/extension/debugAdapters/bin/OpenDebugAD7"

    ---https://github.com/mfussenegger/nvim-dap/wiki/C-C---Rust-(gdb-via--vscode-cpptools)
    if vim.fn.executable(cpp_tools_executable) == 1 then
      dap.adapters.cppdbg = {
        id = "cppdbg",
        type = "executable",
        command = cpp_tools_executable,
      }
    end

    ---╔══════════════════════════════════════╗
    ---║           Configurations             ║
    ---╚══════════════════════════════════════╝

    local js_filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact" }
    for _, language in ipairs(js_filetypes) do
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

    dap.configurations.c = {
      {
        name = "Launch file",
        request = "launch",
        type = "cppdbg",
        cwd = "${workspaceFolder}",
        program = "${fileDirname}/${fileBasenameNoExtension}",
        preLaunchTask = "C/C++: gcc build active file",
      },
      {
        name = "Launch file by custom path",
        type = "cppdbg",
        request = "launch",
        program = function() return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file") end,
        cwd = "${workspaceFolder}",
        preLaunchTask = "C/C++: gcc build active file",
      },
    }

    ---https://github.com/stevearc/overseer.nvim/blob/master/doc/third_party.md#dap
    require("overseer").patch_dap(true)
    require("dap.ext.vscode").json_decode = require("overseer.json").decode

    ---Only needed if your debugging type doesn't match your language type.
    ---For example, python is not necessary on this table because its debugging type is "python"
    ---@diagnostic disable-next-line: unused-local
    vscode_type_to_ft = {
      ["pwa-chrome"] = js_filetypes,
      ["pwa-msedge"] = js_filetypes,
      ["pwa-node"] = js_filetypes,
      ["firefox"] = js_filetypes,
      ["cppdbg"] = { "c" },
    }
  end,
}
