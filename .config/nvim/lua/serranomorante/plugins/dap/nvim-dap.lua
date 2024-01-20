local events = require("serranomorante.events")
local utils = require("serranomorante.utils")

---Debuggers can exist on one of 2 folders: `mason` or `debuggers`
---Mason: installed automatically. Usually for stable versions of packages.
---Debuggers: installed manually. Usually for nightly versions of packages. This is
---a custom folder on my system for things like `cpp_tools` or `vscode-js-debug`

---`h: dap.ext.vscode.load_launchjs`
local vscode_type_to_ft

return {
  "mfussenegger/nvim-dap",
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
      "<leader>d0",
      function()
        vim.ui.input({
          prompt = "Hit condition: ",
        }, function(hit_condition)
          if hit_condition then require("dap").set_breakpoint(nil, hit_condition) end
        end)
      end,
      desc = "Hit condition",
    },
    {
      "<leader>dl",
      function()
        vim.ui.input({ prompt = "Log message {foo}: " }, function(message)
          if message then require("dap").set_breakpoint(nil, nil, message) end
        end)
      end,
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
    vim.fn.sign_define("DapBreakpoint", { text = "⬤", texthl = "DapBreakpoint" })
    vim.fn.sign_define("DapBreakpointCondition", { text = " ", texthl = "DapBreakpoint" })
    vim.fn.sign_define("DapBreakpointRejected", { text = " ", texthl = "DapBreakpoint" })
    vim.fn.sign_define("DapLogPoint", { text = "", texthl = "DapLogPoint" })
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

    local c_fts = { "c" }
    local python_fts = { "python" }
    local javascript_fts = { "typescript", "javascript", "javascriptreact", "typescriptreact" }

    ---╔══════════════════════════════════════╗
    ---║               Adapters               ║
    ---╚══════════════════════════════════════╝

    ---This env variable comes from my personal .bashrc file
    local system_node_version = vim.env.SYSTEM_DEFAULT_NODE_VERSION or "latest"
    ---Bypass volta's context detection to prevent running the debugger with unsupported node versions
    local node_path = utils.cmd({ "volta", "run", "--node", system_node_version, "which", "node" }):gsub("\n", "")

    local vscode_js_debug_dap = mason_registry.get_package("js-debug-adapter")

    if node_path and vscode_js_debug_dap then
      local dap_executable = vscode_js_debug_dap:get_install_path() .. "/js-debug/src/dapDebugServer.js"

      for _, type in ipairs({
        "node",
        "chrome",
        "pwa-node",
        "pwa-chrome",
        "pwa-msedge",
        "node-terminal",
        "pwa-extensionHost",
      }) do
        local host = "localhost"
        dap.adapters[type] = {
          type = "server",
          host = host,
          port = "${port}",
          executable = {
            command = node_path,
            args = { dap_executable, "${port}", host },
          },
        }
      end
    end

    local dap_executable = vim.fn.stdpath("data") .. "/debuggers/cpp_tools/extension/debugAdapters/bin/OpenDebugAD7"

    ---https://github.com/mfussenegger/nvim-dap/wiki/C-C---Rust-(gdb-via--vscode-cpptools)
    if vim.fn.executable(dap_executable) == 1 then
      dap.adapters.cppdbg = {
        id = "cppdbg",
        type = "executable",
        command = dap_executable,
      }
    end

    ---╔══════════════════════════════════════╗
    ---║           Configurations             ║
    ---╚══════════════════════════════════════╝

    local function url_prompt(default)
      default = default or "http://localhost:3000"
      local co = coroutine.running()
      return coroutine.create(function()
        vim.ui.input({ prompt = "Enter URL: ", default = default }, function(url)
          if url == nil or url == "" then
            return
          else
            coroutine.resume(co, url)
          end
        end)
      end)
    end

    for _, language in ipairs(javascript_fts) do
      dap.configurations[language] = {
        {
          name = "DAP: Debug with PWA Chrome",
          type = "pwa-chrome",
          request = "launch",
          sourceMaps = true,
          url = url_prompt,
          ---These 2 options are important for nextjs apps
          webRoot = vim.fn.getcwd(),
          userDataDir = false,
          resolveSourceMapLocations = {
            "${workspaceFolder}/**",
            "!**/node_modules/**",
          },
        },
        ---While vscode supports typescript files as entrypoints to your debugger
        ---`nvim-dap-vscode-js` needs a loader like `ts-node`. A different approach
        ---could be using `vscode-node-debug2` but it is deprecated.
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
        {
          name = "Next.js: debug server-side",
          type = "pwa-node",
          request = "launch",
          cwd = "${workspaceFolder}",
          runtimeExecutable = "npm",
          runtimeArgs = { "run-script", "dev" },
          sourceMaps = true,
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

    ---Load dap plugins that can override previous adapters & configs
    ---@param buf integer?
    local load_dap_plugins = function(buf)
      local filetype = vim.api.nvim_get_option_value("filetype", { buf = buf or 0 })
      if vim.tbl_contains(javascript_fts, filetype) then events.event("LoadDapJsOverrides") end
      if vim.tbl_contains(python_fts, filetype) then events.event("LoadDapPyOverrides") end
    end

    vim.api.nvim_create_autocmd("FileType", {
      desc = "Lazy-load dap plugins by filetype",
      group = vim.api.nvim_create_augroup("dap_filetype_overrides", { clear = true }),
      callback = function(args) load_dap_plugins(args.buf) end,
    })

    load_dap_plugins()

    ---Only needed if your debugging type doesn't match your language type.
    ---For example, python is not necessary on this table because its debugging type is "python"
    ---@diagnostic disable-next-line: unused-local
    vscode_type_to_ft = {
      ["node"] = javascript_fts,
      ["chrome"] = javascript_fts,
      ["firefox"] = javascript_fts,
      ["pwa-node"] = javascript_fts,
      ["pwa-chrome"] = javascript_fts,
      ["pwa-msedge"] = javascript_fts,
      ["node-terminal"] = javascript_fts,
      ["pwa-extensionHost"] = javascript_fts,
      ["cppdbg"] = c_fts,
    }
  end,
}
