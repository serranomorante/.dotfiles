return {
  "kevinhwang91/nvim-ufo",
  event = "User CustomFile",
  cmd = "UfoInspect",
  dependencies = { "kevinhwang91/promise-async", "neovim/nvim-lspconfig", "nvim-treesitter/nvim-treesitter" },
  keys = {
    {
      "zR",
      function() require("ufo").openAllFolds() end,
      desc = "Ufo: Open all folds",
    },
    {
      "zM",
      function() require("ufo").closeAllFolds() end,
      desc = "Ufo: Close all folds",
    },
    {
      "zr",
      function() require("ufo").openFoldsExceptKinds() end,
      desc = "Ufo: Open folds except kinds",
    },
    {
      "zm",
      function() require("ufo").closeFoldsWith() end,
      desc = "Ufo: Close folds with level",
    },
    {
      "zp",
      function() require("ufo").peekFoldedLinesUnderCursor() end,
      desc = "Ufo: Peek folded lines under cursor",
    },
  },
  opts = {
    preview = {
      win_config = {
        winblend = 0,
        winhighlight = "Normal:Folded",
      },
      mappings = {
        scrollB = "<C-b>",
        scrollF = "<C-f>",
        scrollU = "<C-u>",
        scrollD = "<C-d>",
      },
    },
    provider_selector = function(_, filetype, buftype)
      local function handleFallbackException(bufnr, err, providerName)
        if type(err) == "string" and err:match("UfoFallbackException") then
          return require("ufo").getFolds(bufnr, providerName)
        else
          return require("promise").reject(err)
        end
      end

      return (filetype == "" or buftype == "nofile") and "indent" -- only use indent until a file is opened
        or function(bufnr)
          return require("ufo")
            .getFolds(bufnr, "lsp")
            :catch(function(err) return handleFallbackException(bufnr, err, "treesitter") end)
            :catch(function(err) return handleFallbackException(bufnr, err, "indent") end)
        end
    end,
  },
  config = function(_, opts) require("ufo").setup(opts) end,
}
