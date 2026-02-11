return {
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      { 'saghen/blink.cmp' },
      {
        'j-hui/fidget.nvim',
        opts = {
          notification = {
            override_vim_notify = true,
          },
        },
      },
      { 'towolf/vim-helm', ft = 'helm' },
    },
    opts = {
      inlay_hints = { enabled = true },
    },
    config = function(_, opts)
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          map('<leader>rn', vim.lsp.buf.rename, 'Rename')
          map('<leader>ca', vim.lsp.buf.code_action, 'Code Action', { 'n', 'x' })
          map('<leader>cl', function()
            vim.lsp.codelens.refresh()
            vim.lsp.codelens.run()
          end, 'Run CodeLens actions', { 'n', 'x' })
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
            local highlight_augroup = vim.api.nvim_create_augroup('lsp-highlight', { clear = false })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            })

            vim.api.nvim_create_autocmd('LspDetach', {
              group = vim.api.nvim_create_augroup('lsp-detach', { clear = true }),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds({ group = 'lsp-highlight', buffer = event2.buf })
              end,
            })

            vim.diagnostic.config({
              virtual_text = true,
              underline = true,
              update_in_insert = true,
              severity_sort = true,
              float = {
                border = 'rounded',
                source = false,
              },
              signs = {
                text = {
                  [vim.diagnostic.severity.ERROR] = '󰅚 ',
                  [vim.diagnostic.severity.WARN] = '󰀪 ',
                  [vim.diagnostic.severity.INFO] = '󰋽 ',
                  [vim.diagnostic.severity.HINT] = '󰌶 ',
                },
                numhl = {
                  [vim.diagnostic.severity.ERROR] = 'ErrorMsg',
                  [vim.diagnostic.severity.WARN] = 'WarningMsg',
                },
              },
            })
          end
        end,
      })

      local servers = {
        gopls = {
          usePlaceholders = true,
          completeUnimported = true,
          staticcheck = true,
          analyses = {
            unusedparams = true,
            unreachable = true,
            fieldalignment = false, -- expensive
          },
          hints = {
            assignVariableTypes = true,
            compositeLiteralFields = true,
            constantValues = true,
            rangeVariableTypes = true,
          },
          codelenses = {
            generate = true,
            gc_details = false,
            test = true,
            tidy = true,
            upgrade_dependency = true,
          },
        },
        terraformls = {},
        lua_ls = {
          settings = {
            Lua = {
              completion = {
                callSnippet = 'Replace',
              },
            },
          },
        },
        helm_ls = {},
      }

      for server, config in pairs(servers) do
        vim.lsp.config(server, config)
        vim.lsp.enable(server)
      end
    end,
  },
}
