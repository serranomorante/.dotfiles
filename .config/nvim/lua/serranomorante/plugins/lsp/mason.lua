local events = require("serranomorante.events")
local utils = require("serranomorante.utils")

---@type MasonEnsureInstall
local javascript = {
  formatter = { "prettierd" },
  linter = { "eslint_d" },
  lsp = { "tsserver" },
  dap = {
    "firefox-debug-adapter",
    ---Uncomment next line if you want to use `dapDebugServer` instead of `vsDebugServerBundle`
    -- { "js-debug-adapter", version = "v1.82.0" },
  },
}
---@type MasonEnsureInstall
local lua = { formatter = { "stylua" }, lsp = { "lua_ls" } }
---@type MasonEnsureInstall
local go = {
  formatter = { "gofumpt", "goimports", "gomodifytags" },
  lsp = { "gopls" },
  extra = { "iferr", "impl" },
}
---@type MasonEnsureInstall
local json = { lsp = { "jsonls" } }
---@type MasonEnsureInstall
local c = { lsp = { "clangd" } }
---@type MasonEnsureInstall
local python = {
  formatter = { "isort", "black" },
  linter = { "mypy", "pylint" },
  lsp = { "pyright", "ruff_lsp" },
  dap = { "debugpy" },
}
---@type MasonEnsureInstall
local rust = { lsp = { "rust_analyzer" } }
---@type MasonEnsureInstall
local bash = { lsp = { "bashls" } }
---@type MasonEnsureInstall
local markdown = { lsp = { "marksman" } }
---@type MasonEnsureInstall
local toml = { lsp = { "taplo" } }

return {
  -- mason-tool-installer.nvim should be in charge of installs/updates and not mason.nvim
  -- This is because we are pinning specific package versions on mason-tool-installer.nvim.
  -- We should leave mason.nvim to handle its core functionlity along with having
  -- a nice UI, but no programmatic installations or updates.
  {
    "williamboman/mason.nvim",
    lazy = false,
    cmd = "Mason",
    opts = {
      ui = {
        check_outdated_packages_on_open = false,
        keymaps = {
          update_all_packages = "noop",
        },
      },
    },
  },

  {
    "williamboman/mason-lspconfig.nvim",
    cmd = { "LspInstall", "LspUninstall" },
    config = function(_, opts)
      require("mason-lspconfig").setup(opts)
      events.event("MasonLspSetup")
    end,
  },

  -- We load this plugin on `CustomMasonLspSetup` because otherwise
  -- it would try to load `mason-lspconfig` and `lspconfig` on startup
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    event = "User CustomMasonLspSetup",
    cmd = { "MasonToolsInstall", "MasonToolsUpdate", "MasonToolsClean" },
    init = function()
      -- Thanks! https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim/issues/21#issuecomment-1406030068
      vim.api.nvim_create_autocmd("User", {
        desc = "Opens mason.nvim UI while installing/updating packages",
        group = vim.api.nvim_create_augroup("open_mason_ui", { clear = true }),
        pattern = "MasonToolsStartingInstall",
        command = "Mason",
      })
    end,
    opts = {
      ensure_installed = utils.mason_merge_tools(javascript, lua, go, json, c, python, rust, bash, markdown, toml),
    },
    config = function(_, opts)
      local mason_tool_installer = require("mason-tool-installer")
      mason_tool_installer.setup(opts)
      -- As this plugin is lazy loaded, the original event (VimEnter) will never get trigger
      -- That's why I'm forcing the `run_on_start()` trigger
      mason_tool_installer.run_on_start()
    end,
  },
}
