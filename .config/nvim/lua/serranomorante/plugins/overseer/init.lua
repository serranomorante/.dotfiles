local utils = require("serranomorante.utils")

return {
  "stevearc/overseer.nvim",
  lazy = true,
  keys = {
    { "<leader>oo", "<cmd>OverseerToggle<CR>" },
    { "<leader>or", "<cmd>OverseerRun<CR>" },
    { "<leader>oc", "<cmd>OverseerRunCmd<CR>" },
    { "<leader>ol", "<cmd>OverseerLoadBundle<CR>" },
    { "<leader>ob", "<cmd>OverseerToggle! bottom<CR>" },
    { "<leader>od", "<cmd>OverseerQuickAction<CR>" },
    { "<leader>os", "<cmd>OverseerTaskAction<CR>" },
  },
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
    local vscode_bundle = require(utils.join_paths(template_path, "vscode"))

    for _, name in ipairs(vscode_bundle) do
      overseer.register_template(require(utils.join_paths(template_path, "vscode", name)))
    end
  end,
}
