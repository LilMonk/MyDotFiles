-- LSP: server install (Mason) + configuration + keymaps.
-- Uses Neovim 0.11+ native vim.lsp.config/enable; mason-lspconfig v2 auto-enables
-- installed servers. Go: gopls. Python: basedpyright (types/hover) + ruff (lint).
return {
  "neovim/nvim-lspconfig",
  enabled = require("core.plugins").enabled("lsp"),
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    { "mason-org/mason.nvim", opts = {} },
    "mason-org/mason-lspconfig.nvim",
    "saghen/blink.cmp",
    -- Bottom-right progress spinner while a server indexes (gopls on a big module).
    { "j-hui/fidget.nvim", opts = { notification = { window = { winblend = 0 } } } },
  },
  config = function()
    -- Completion capabilities from blink, applied to every server.
    vim.lsp.config("*", {
      capabilities = require("blink.cmp").get_lsp_capabilities(),
    })

    vim.lsp.config("gopls", {
      settings = {
        gopls = {
          analyses = { unusedparams = true },
          staticcheck = true,
          hints = {
            assignVariableTypes = true,
            compositeLiteralFields = true,
            compositeLiteralTypes = true,
            constantValues = true,
            functionTypeParameters = true,
            parameterNames = true,
            rangeVariableTypes = true,
          },
        },
      },
    })

    vim.lsp.config("basedpyright", {
      settings = {
        basedpyright = {
          analysis = {
            typeCheckingMode = "standard",
            diagnosticMode = "openFilesOnly",
            inlayHints = {
              callArgumentNames = true,
              functionReturnTypes = true,
              variableTypes = true,
              genericTypes = true,
            },
          },
        },
      },
    })

    -- ruff owns lint + fixes; basedpyright owns hover, so silence ruff's hover.
    vim.lsp.config("ruff", {
      on_attach = function(client)
        client.server_capabilities.hoverProvider = false
      end,
    })

    require("mason-lspconfig").setup({
      ensure_installed = { "gopls", "basedpyright", "ruff" },
    })

    -- Buffer-local autocmds for symbol highlighting live here; entries are
    -- scoped per buffer and removed again on LspDetach.
    local highlight_group = vim.api.nvim_create_augroup("lsp_document_highlight", { clear = true })

    -- Buffer-local keymaps + inlay hints when a server attaches.
    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("lsp_attach", { clear = true }),
      callback = function(args)
        local bufnr = args.buf
        local builtin = require("telescope.builtin")
        local function bmap(lhs, rhs, desc)
          vim.keymap.set("n", lhs, rhs, { buffer = bufnr, desc = desc })
        end

        -- Go-to pickers open in Telescope (override 0.12 default grr/gri).
        bmap("gd", builtin.lsp_definitions, "Go to definition")
        bmap("gD", vim.lsp.buf.declaration, "Go to declaration")
        bmap("grr", builtin.lsp_references, "References")
        bmap("gri", builtin.lsp_implementations, "Implementation")
        bmap("grt", builtin.lsp_type_definitions, "Type definition")
        -- K (hover), grn (rename), gra (code action), gO (symbols) stay as 0.12 defaults.

        bmap("<leader>cf", function()
          require("conform").format({ async = true, lsp_format = "fallback" })
        end, "Format buffer")

        local client = vim.lsp.get_client_by_id(args.data.client_id)

        -- Highlight other occurrences of the symbol under the cursor after
        -- 'updatetime' (250ms), and clear them as soon as the cursor moves.
        -- The flag keeps a second server on the same buffer (ruff + basedpyright)
        -- from registering a duplicate set.
        if
          client
          and client:supports_method("textDocument/documentHighlight")
          and not vim.b[bufnr].lsp_highlight_attached
        then
          vim.b[bufnr].lsp_highlight_attached = true

          vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
            buffer = bufnr,
            group = highlight_group,
            callback = vim.lsp.buf.document_highlight,
          })
          vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
            buffer = bufnr,
            group = highlight_group,
            callback = vim.lsp.buf.clear_references,
          })
          vim.api.nvim_create_autocmd("LspDetach", {
            buffer = bufnr,
            group = highlight_group,
            callback = function(detach)
              -- Buffer-scoped: the detaching buffer may not be the current one.
              vim.lsp.util.buf_clear_references(bufnr)
              -- Only tear down once no remaining client can highlight.
              local still_supported = vim.iter(vim.lsp.get_clients({ bufnr = bufnr })):any(function(c)
                return c.id ~= detach.data.client_id and c:supports_method("textDocument/documentHighlight")
              end)
              if not still_supported then
                vim.b[bufnr].lsp_highlight_attached = nil
                vim.api.nvim_clear_autocmds({ group = highlight_group, buffer = bufnr })
              end
            end,
          })
        end

        if client and client:supports_method("textDocument/inlayHint") then
          vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
          bmap("<leader>ch", function()
            local enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr })
            vim.lsp.inlay_hint.enable(not enabled, { bufnr = bufnr })
          end, "Toggle inlay hints")
        end
      end,
    })
  end,
}
