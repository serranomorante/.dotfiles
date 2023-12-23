local utils = require("serranomorante.utils")
if not utils.is_available("overseer.nvim") then return {} end
local overseer = require("overseer")

return {
  name = "C/C++: gcc build active file",
  builder = function()
    -- Full path to current file (see :help expand())
    local file = vim.fn.expand("%:p")
    local filename = vim.fn.expand("%:p:r")
    return {
      cmd = { "/usr/bin/gcc" },
      args = {
        "-fdiagnostics-color=always",
        "-g",
        file,
        "-o",
        filename,
      },
      components = {
        { "on_output_quickfix", open = true },
        "default",
      },
    }
  end,
  condition = {
    filetype = { "c" },
  },
  tags = { overseer.TAG.BUILD },
}
