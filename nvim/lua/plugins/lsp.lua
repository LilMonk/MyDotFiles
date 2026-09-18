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
      -- uv/poetry workspaces keep the venv + lockfile at the workspace root while
      -- each member carries its own pyproject.toml. basedpyright only auto-detects
      -- `.venv` in its LSP root dir, so with the default markers it roots at the
      -- nearest member pyproject.toml (which has no .venv), falls back to system
      -- python, and reports every third-party/workspace import as unresolved.
      -- Anchor the root at the workspace root instead (the dir holding .venv/lock).
      root_dir = function(bufnr, on_dir)
        local fname = vim.api.nvim_buf_get_name(bufnr)
        if fname == "" then
          return
        end
        local root = vim.fs.root(bufnr, { ".venv", "uv.lock", "poetry.lock" })
        -- Don't let a stray ~/.venv capture unrelated projects.
        if root == vim.env.HOME then
          root = nil
        end
        root = root
          or vim.fs.root(bufnr, { "pyrightconfig.json", "pyproject.toml", "setup.py", "setup.cfg", ".git" })
        on_dir(root)
      end,
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

    -- Symbol-under-cursor highlighting (and ]]/[[ navigation between the
    -- references) is handled by snacks.words — see plugins/snacks.lua.

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
