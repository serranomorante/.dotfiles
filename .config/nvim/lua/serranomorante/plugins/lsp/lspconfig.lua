local utils = require("serranomorante.utils")
local tools_by_filetype = require("serranomorante.plugins.lsp.mason-tools.by_filetype")
local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

return {
  { "pmizio/typescript-tools.nvim", lazy = true },

  {
    "neovim/nvim-lspconfig",
    cmd = { "LspInfo", "LspInstall", "LspStart" },
    event = "User CustomFile",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "p00f/clangd_extensions.nvim",
      "b0o/SchemaStore.nvim",
    },
    init = function()
      -- See: https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/guides/under-the-hood.md
      -- See: https://github.com/mfussenegger/nvim-lint/issues/340#issuecomment-1676438571
      vim.diagnostic.config({
        signs = {
          text = {
            [vim.diagnostic.severity.INFO] = "",
            [vim.diagnostic.severity.HINT] = "",
            [vim.diagnostic.severity.WARN] = "",
            [vim.diagnostic.severity.ERROR] = "",
          },
        },
        virtual_text = { source = true },
        float = { border = "single", source = true },
        update_in_insert = true,
      })

      vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "single" })

      vim.lsp.handlers["textDocument/signatureHelp"] =
        vim.lsp.with(vim.lsp.handlers.signature_help, { border = "single" })
    end,
    config = function()
      if utils.is_available("neodev.nvim") then require("neodev") end
      local lspconfig = require("lspconfig")
      local cmp_nvim_lsp = require("cmp_nvim_lsp")
      vim.lsp.set_log_level(vim.env.LSP_LOG_LEVEL or "INFO")

      local on_init = function(client)
        -- Disable semanticTokensProvider
        -- https://gist.github.com/swarn/fb37d9eefe1bc616c2a7e476c0bc0316
        client.server_capabilities.semanticTokensProvider = nil
      end

      local on_attach = function(client, bufnr)
        local opts = { noremap = true, silent = true, buffer = bufnr }

        if utils.is_available("telescope.nvim") then
          if client.supports_method("textDocument/references") then
            opts.desc = "Show LSP references"
            local options = { show_line = false }
            vim.keymap.set("n", "gr", function() require("telescope.builtin").lsp_references(options) end, opts)
          end

          if client.supports_method("textDocument/definition") then
            opts.desc = "Show LSP definitions"
            vim.keymap.set("n", "gd", function() require("telescope.builtin").lsp_definitions() end, opts)
          end

          if client.supports_method("textDocument/implementation") then
            opts.desc = "Show LSP implementations"
            vim.keymap.set("n", "gI", function() require("telescope.builtin").lsp_implementations() end, opts)
          end

          if client.supports_method("textDocument/typeDefinition") then
            opts.desc = "Show LSP type definitions"
            vim.keymap.set("n", "gy", function() require("telescope.builtin").lsp_type_definitions() end, opts)
          end

          opts.desc = "Show buffer diagnostics"
          vim.keymap.set(
            "n",
            "<leader>ld",
            function() require("telescope.builtin").diagnostics({ bufnr = 0 }) end,
            opts
          )

          opts.desc = "Show workspace diagnostics"
          vim.keymap.set("n", "<leader>lD", function() require("telescope.builtin").diagnostics() end, opts)

          opts.desc = "Document symbols"
          vim.keymap.set("n", "<leader>ls", function() require("telescope.builtin").lsp_document_symbols() end, opts)
        end

        if client.supports_method("textDocument/declaration") then
          opts.desc = "Go to declaration"
          vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
        end

        if client.supports_method("textDocument/codeAction") then
          opts.desc = "See available code actions"
          vim.keymap.set({ "n", "v" }, "<leader>la", vim.lsp.buf.code_action, opts)
        end

        if client.supports_method("textDocument/rename") then
          opts.desc = "Smart rename"
          vim.keymap.set("n", "<leader>lr", vim.lsp.buf.rename, opts)
        end

        if client.supports_method("textDocument/signatureHelp") then
          opts.desc = "Signature help"
          vim.keymap.set("n", "<leader>lh", vim.lsp.buf.signature_help, opts)
        end

        if client.supports_method("workspace/symbol") then
          opts.desc = "Search workspace symbols"
          vim.keymap.set("n", "<leader>lG", vim.lsp.buf.workspace_symbol, opts)
        end

        opts.desc = "Show line diagnostics"
        vim.keymap.set("n", "gl", vim.diagnostic.open_float, opts)

        opts.desc = "Go to previous diagnostic"
        vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)

        opts.desc = "Go to next diagnostic"
        vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)

        opts.desc = "Restart LSP"
        vim.keymap.set("n", "<leader>rs", function()
          local buf = vim.api.nvim_get_current_buf()
          local clients = vim.lsp.get_clients({ bufnr = buf })
          for _, c in pairs(clients) do
            vim.cmd("LspRestart " .. c.id)
          end
        end, opts)

        vim.keymap.set("n", "<leader>li", "<cmd>LspInfo<cr>", { desc = "LSP information" })

        -- Toggle inlay hints with keymap
        if client.supports_method("textDocument/inlayHint") then
          vim.keymap.set("n", "<leader>uH", function()
            utils.toggle_buffer_inlay_hints(bufnr)
            vim.notify(
              string.format("Inlay hints %s", utils.bool2str(vim.b[bufnr].inlay_hints_enabled)),
              vim.log.levels.INFO
            )
          end, { desc = "Toggle inlay hints" })
        end

        -- Refresh codelens if supported
        if client.supports_method("textDocument/codeLens") then
          if vim.g.codelens_enabled then vim.lsp.codelens.refresh() end

          vim.keymap.set("n", "<leader>uL", function()
            utils.toggle_codelens()
            vim.notify(string.format("CodeLens %s", utils.bool2str(vim.g.codelens_enabled)), vim.log.levels.INFO)
            if vim.g.codelens_enabled then vim.lsp.codelens.refresh() end
          end, { desc = "Toggle codelens" })

          vim.keymap.set(
            "n",
            "<leader>ll",
            function() vim.lsp.codelens.refresh() end,
            { desc = "LSP CodeLens refresh" }
          )

          vim.keymap.set("n", "<leader>lL", function() vim.lsp.codelens.run() end, { desc = "LSP CodeLens run" })

          -- Create autocmd to refresh codelens on BufEnter and InsertLeave
          local codelens_augroup = augroup("lsp_codelens_augroup", { clear = true })
          autocmd({ "InsertLeave", "BufEnter" }, {
            desc = "Refresh codelens",
            group = codelens_augroup,
            buffer = bufnr,
            callback = function()
              if not utils.has_capability("textDocument/codeLens", { bufnr = bufnr }) then
                utils.del_buffer_autocmd("lsp_codelens_augroup", bufnr)
                return
              end
              if vim.g.codelens_enabled then vim.lsp.codelens.refresh() end
            end,
          })
        end
      end

      local capabilities =
        vim.tbl_deep_extend("force", lspconfig.util.default_config, cmp_nvim_lsp.default_capabilities())

      local servers = utils.get_from_tools(tools_by_filetype, "lsp", true)

      local custom = {
        ["tsserver"] = function()
          require("typescript-tools").setup({
            on_init = on_init,
            capabilities = capabilities,
            on_attach = on_attach,
            single_file_support = false,
            settings = {
              code_lens = "all",
              publish_diagnostic_on = "change",
              complete_function_calls = true,
              expose_as_code_action = { "fix_all", "add_missing_imports", "remove_unused" },
              tsserver_file_preferences = {
                includeInlayParameterNameHints = "all",
                includeInlayParameterNameHintsWhenArgumentMatchesName = true,
                includeInlayFunctionParameterTypeHints = true,
                includeInlayVariableTypeHints = true,
                includeInlayVariableTypeHintsWhenTypeMatchesName = true,
                includeInlayPropertyDeclarationTypeHints = true,
                includeInlayFunctionLikeReturnTypeHints = true,
                includeInlayEnumMemberValueHints = true,
              },
            },
          })
        end,
        ["clangd"] = function()
          lspconfig["clangd"].setup({
            on_init = on_init,
            capabilities = vim.tbl_deep_extend("force", capabilities, { offsetEncoding = "utf-16" }),
            on_attach = on_attach,
          })
        end,
        ["jsonls"] = function()
          if utils.is_available("SchemaStore.nvim") then
            lspconfig["jsonls"].setup({
              on_init = on_init,
              on_attach = on_attach,
              capabilities = capabilities,
              settings = {
                json = { schemas = require("schemastore").json.schemas(), validate = { enable = true } },
              },
            })
          else
            lspconfig["jsonls"].setup({
              on_init = on_init,
              on_attach = on_attach,
              capabilities = capabilities,
            })
          end
        end,
        ["ruff_lsp"] = function()
          lspconfig["ruff_lsp"].setup({
            on_init = on_init,
            on_attach = function(client, bufnr)
              -- Disable hover in favor of Pyright
              client.server_capabilities.hoverProvider = false
              on_attach(client, bufnr)
            end,
            capabilities = capabilities,
          })
        end,
        ["lua_ls"] = function()
          lspconfig["lua_ls"].setup({
            on_init = on_init,
            capabilities = capabilities,
            on_attach = on_attach,
            settings = {
              Lua = {
                runtime = {
                  version = "LuaJIT",
                },
                diagnostics = {
                  globals = { "vim" },
                },
                completion = {
                  callSnippet = "Replace",
                },
                workspace = {
                  library = {
                    vim.env.VIMRUNTIME,
                  },
                },
                codeLens = {
                  enable = true,
                },
                hint = {
                  enable = true,
                },
              },
            },
          })
        end,
      }

      for _, server in ipairs(servers) do
        if not vim.tbl_contains(vim.tbl_keys(custom), server) then
          lspconfig[server].setup({
            on_init = on_init,
            on_attach = on_attach,
            capabilities = capabilities,
          })
        else
          custom[server]()
        end
      end

      ---Forces nvim-lspconfig to launch the language server
      ---See `:h lspconfig-setup` "autostart"
      local function setup_servers()
        vim.api.nvim_exec_autocmds("FileType", {
          buffer = vim.api.nvim_get_current_buf(),
        })
      end

      if utils.is_available("mason-tool-installer.nvim") then
        vim.api.nvim_create_autocmd("User", {
          desc = "Set up LSP servers after mason-tool-installer",
          pattern = "MasonToolsUpdateCompleted",
          once = true,
          callback = function() setup_servers() end,
        })
      end

      setup_servers()
    end,
  },
}
