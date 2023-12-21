local utils = require("serranomorante.utils")

return {
  "stevearc/overseer.nvim",
  lazy = true,
  opts = {
    ---Disable the automatic patch and do it manually on nvim-dap config
    ---https://github.com/stevearc/overseer.nvim/blob/master/doc/third_party.md#dap
    dap = false,
  },
  config = function(_, opts)
    local overseer = require("overseer")
    overseer.setup(opts)

    ---@diagnostic disable-next-line: param-type-mismatch
    local template_path = "serranomorante/plugins/overseer/template"

    ---Register vscode custom tasks
    overseer.register_template(require(utils.join_paths(template_path, "vscode/tsc")))
  end,
}
