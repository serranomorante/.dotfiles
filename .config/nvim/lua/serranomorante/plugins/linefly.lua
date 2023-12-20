return {
  "bluz71/nvim-linefly",
  init = function()
    vim.g.linefly_options = {
      tabline = true,
      active_tab_symbol = " 󰓩",
      error_symbol = "",
      warning_symbol = "",
      information_symbol = "󰋼",
    }
  end,
}
