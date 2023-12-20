local events = require("serranomorante.events")

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
      ensure_installed = {
        -- Formatters
        "stylua", -- lua
        "prettierd", -- javascript/typescript
        "isort", -- python
        "black", -- python
        "gofumpt", -- go
        "goimports", -- go
        "gomodifytags", -- go

        -- Linters
        "mypy", -- python
        "pylint", -- python
        "eslint_d", -- javascript/typescript

        -- LSP servers
        "lua_ls", -- lua
        "tsserver", -- javascript/typescript
        "jsonls", -- json
        "pyright", -- python
        "ruff_lsp", -- python
        "gopls", -- go
        "taplo", -- toml
        "rust_analyzer", -- rust
        "clangd", -- c/c++
        "marksman", -- markdown
        "bashls", -- bash

        -- Others
        "iferr", -- go
        "impl", -- go

        -- DAP
        "firefox-debug-adapter",
        "debugpy",
        ---Uncomment next line if you want to use `dapDebugServer` instead of `vsDebugServerBundle`
        -- { "js-debug-adapter", version = "v1.82.0" },
      },
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
