local utils = require("serranomorante.utils")
local tools_by_filetype = require("serranomorante.plugins.lsp.mason-tools.by_filetype")

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
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    lazy = false,
    dependencies = "williamboman/mason.nvim",
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
      ensure_installed = utils.mason_merge_tools(
        tools_by_filetype.c,
        tools_by_filetype.go,
        tools_by_filetype.lua,
        tools_by_filetype.bash,
        tools_by_filetype.json,
        tools_by_filetype.rust,
        tools_by_filetype.toml,
        tools_by_filetype.python,
        tools_by_filetype.markdown,
        tools_by_filetype.javascript
      ),
    },
    config = function(_, opts)
      local mason_tool_installer = require("mason-tool-installer")
      mason_tool_installer.setup(opts)
      if vim.v.vim_did_enter then mason_tool_installer.run_on_start() end
    end,
  },
}
