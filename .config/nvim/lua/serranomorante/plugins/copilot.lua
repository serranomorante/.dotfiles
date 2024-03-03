return {
  "github/copilot.vim",
  event = "User CustomFile",
  init = function()
    vim.g.copilot_node_command = vim.g.node_system_executable
    vim.g.copilot_no_tab_map = true -- I use `tab` for completion
  end,
  config = function()
    -- vim.api.nvim_exec_autocmds("InsertEnter", { buffer = vim.api.nvim_get_current_buf(), modeline = false })

    vim.keymap.set("i", "<M-c>", 'copilot#Accept("\\<CR>")', {
      expr = true,
      replace_keycodes = false,
      desc = "Copilot: Accept suggestion",
    })
  end,
}
