---Names should be mason.nvim compatible
---@type table<string, MasonEnsureInstall>
local tools_by_filetype = {
  javascript = {
    formatters = { "prettierd" },
    linters = { "eslint_d" },
    lsp = { "typescript-language-server" },
    dap = {
      "firefox-debug-adapter",
      ---Uncomment next line if you want to use `dapDebugServer` instead of `vsDebugServerBundle`
      -- { "js-debug-adapter", version = "v1.82.0" },
    },
  },
  lua = { formatters = { "stylua" }, lsp = { "lua-language-server" } },
  go = {
    formatters = { "gofumpt", "goimports", "gomodifytags" },
    lsp = { "gopls" },
    extra = { "iferr", "impl" },
  },
  json = { lsp = { "json-lsp" } },
  c = { lsp = { "clangd" } },
  python = {
    formatters = { "isort", "black" },
    linters = { "mypy", "pylint" },
    lsp = { "pyright", "ruff-lsp" },
    dap = { "debugpy" },
  },
  rust = { lsp = { "rust-analyzer" } },
  bash = { lsp = { "bash-language-server" } },
  markdown = { lsp = { "marksman" }, formatters = { "prettierd" } },
  toml = { lsp = { "taplo" } },
}

return tools_by_filetype
