local utils = require("serranomorante.utils")

return {
  "jackMort/ChatGPT.nvim",
  dependencies = "nvim-telescope/telescope.nvim",
  keys = {
    {
      "<leader>cc",
      "<cmd>ChatGPT<CR>",
      desc = "ChatGPT",
    },
    {
      "<leader>ce",
      "<cmd>ChatGPTEditWithInstruction<CR>",
      mode = { "n", "v" },
      desc = "Edit with instruction",
    },
  },
  opts = {
    ---This requires custom setup using GPG to encrypt your OpenAI API Key
    ---Instead of using environment variables you put your key on a file (say `openai_api_key`) and then encrypt the file:
    ---`gpg --encrypt --sign --armor -r <your public key identifier> openai_api_key`
    ---https://github.com/jackMort/ChatGPT.nvim?tab=readme-ov-file#secrets-management
    api_key_cmd = "gpg --decrypt " .. utils.join_paths(vim.env.HOME, "openai_api_key.asc"),
    edit_with_instructions = {
      ---Copied here for readability
      keymaps = {
        close = "<C-c>",
        accept = "<C-y>",
        toggle_diff = "<C-d>",
        toggle_settings = "<C-o>",
        toggle_help = "<C-h>",
        cycle_windows = "<Tab>",
        use_output_as_input = "<C-i>",
      },
    },
    chat = {
      welcome_message = "",
      question_sign = " ",
      sessions_window = {
        border = {
          style = "single",
        },
        win_options = {
          winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder",
        },
      },
      ---Copied here for readability
      keymaps = {
        close = "<C-c>",
        yank_last = "<C-y>",
        yank_last_code = "<C-k>",
        scroll_up = "<C-u>",
        scroll_down = "<C-d>",
        new_session = "<C-n>",
        cycle_windows = "<Tab>",
        cycle_modes = "<C-f>",
        next_message = "<C-j>",
        prev_message = "<C-k>",
        select_session = "<Space>",
        rename_session = "r",
        delete_session = "d",
        draft_message = "<C-r>",
        edit_message = "e",
        delete_message = "d",
        toggle_settings = "<C-o>",
        toggle_sessions = "<C-p>",
        toggle_help = "<C-h>",
        toggle_message_role = "<C-r>",
        toggle_system_role_open = "<C-s>",
        stop_generating = "<C-x>",
      },
    },
    popup_window = {
      border = {
        style = "single",
      },
      win_options = {
        winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder",
      },
    },
    system_window = {
      border = {
        style = "single",
      },
      win_options = {
        winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder",
      },
    },
    popup_input = {
      border = {
        style = "single",
      },
      win_options = {
        winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder",
      },
      submit = "<C-Enter>",
      submit_n = "<Enter>",
    },
    settings_window = {
      border = {
        style = "single",
      },
      win_options = {
        winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder",
      },
    },
    help_window = {
      border = {
        style = "single",
      },
      win_options = {
        winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder",
      },
    },
  },
  config = function(_, opts) require("chatgpt").setup(opts) end,
}
