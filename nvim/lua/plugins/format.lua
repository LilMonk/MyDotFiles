-- Format on save. Go: goimports then gofmt. Python: ruff_format.
return {
  "stevearc/conform.nvim",
  enabled = require("core.plugins").enabled("format"),
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  opts = {
    formatters_by_ft = {
      go = { "goimports", "gofmt" },
      python = { "ruff_format" },
    },
    format_on_save = {
      timeout_ms = 1000,
      lsp_format = "fallback",
    },
  },
}
