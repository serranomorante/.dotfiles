return {
  -- Remove ugly numbers in the foldcolumn
  -- Thanks: https://github.com/kevinhwang91/nvim-ufo/issues/4#issuecomment-1512772530
  "luukvbaal/statuscol.nvim",
  lazy = false,
  branch = "0.10", -- https://github.com/luukvbaal/statuscol.nvim/commit/ec939ac7d5e8560d0305b6d54f41bc8a3f7be0c7
  config = function()
    local builtin = require("statuscol.builtin")
    require("statuscol").setup({
      relculright = true,
      segments = {
        { text = { "%s" }, click = "v:lua.ScSa" },
        { text = { builtin.lnumfunc }, click = "v:lua.ScLa" },
        {
          text = { " ", builtin.foldfunc, " " },
          condition = { builtin.not_empty, true, builtin.not_empty },
          click = "v:lua.ScFa",
        },
      },
    })
  end,
}
