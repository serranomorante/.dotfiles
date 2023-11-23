local utils = require("serranomorante.utils")

return {
  -- Remove ugly numbers in the foldcolumn
  -- Thanks: https://github.com/kevinhwang91/nvim-ufo/issues/4#issuecomment-1512772530
  {
    "luukvbaal/statuscol.nvim",
    lazy = false,
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
  },

  {
    "kevinhwang91/nvim-ufo",
    event = "User CustomFile",
    keys = {
      {
        "zR",
        function() require("ufo").openAllFolds() end,
        desc = "Open all folds",
      },
      {
        "zM",
        function() require("ufo").closeAllFolds() end,
        desc = "Close all folds",
      },
      {
        "zr",
        function() require("ufo").openFoldsExceptKinds() end,
        desc = "Open folds except kinds",
      },
      {
        "zm",
        function() require("ufo").closeFoldsWith() end,
        desc = "Close folds with level",
      },
      {
        "zp",
        function() require("ufo").peekFoldedLinesUnderCursor() end,
        desc = "Peek folded lines under cursor",
      },
      {
        "<leader>zl",
        function()
          local winid = vim.api.nvim_get_current_win()
          local foldopen_visible = vim.wo[winid].fillchars:gsub("foldopen: ", "foldopen:")
          vim.wo[winid].fillchars = foldopen_visible

          -- Hide available folds after timout
          local timeout = 2000
          vim.defer_fn(function()
            local foldopen_hidden = vim.wo[winid].fillchars:gsub("foldopen:", "foldopen: ")
            vim.wo[winid].fillchars = foldopen_hidden
          end, timeout)
        end,
        desc = "Temporary show available folds",
      },
    },
    dependencies = "kevinhwang91/promise-async",
    init = function()
      vim.opt.fillchars:append({ eob = " ", fold = " ", foldopen = " ", foldsep = " ", foldclose = "+" })
      vim.opt.foldcolumn = "1"
      vim.opt.foldlevel = 99 -- set high foldlevel for nvim-ufo
      vim.opt.foldlevelstart = 99 -- start with all code unfolded
      vim.opt.foldenable = true -- enable fold for nvim-ufo
      vim.opt.foldopen:remove({ "hor" })
    end,
    opts = {
      -- fold_virt_text_handler = handler,
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
    config = function(_, opts)
      require("ufo").setup(opts)

      if utils.is_available("tokyonight.nvim") then
        local colors = require("tokyonight.colors").setup()

        -- Fix jsdoc comments not being visible with default `Folded` highlight
        vim.api.nvim_set_hl(0, "Folded", { bg = colors.bg_dark })
      end

      if utils.is_available("nightfox.nvim") then
        local palette = require("nightfox.palette").load("nightfox")

        -- Darker folded highlight to visually separate it from cursor line
        vim.api.nvim_set_hl(0, "Folded", { bg = palette.bg0 })
      end

      if utils.is_available("tint.nvim") then require("tint").refresh() end
    end,
  },
}
