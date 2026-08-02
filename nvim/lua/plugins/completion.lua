-- Autocompletion with native fuzzy matching + built-in snippet expansion.
return {
  "saghen/blink.cmp",
  enabled = require("core.plugins").enabled("completion"),
  dependencies = { 'rafamadriz/friendly-snippets' },
  version = "1.*", -- release tag ships a prebuilt fuzzy-matcher binary
  event = "InsertEnter",
  opts = {
    keymap = {
      preset = "super-tab", -- VSCode-like: <Tab> accepts/cycles, arrows or <C-n>/<C-p> to cycle
    },
    appearance = { nerd_font_variant = "mono" },
    completion = {
      accept = { auto_brackets = { enabled = true } },
      documentation = {
          auto_show = true,
          auto_show_delay_ms = 200,
          window = { border = "single" },
        },

        menu = {
          border = "single",
          draw = {
            treesitter = { "lsp" },
          },
        },
        
        -- Optional: Enable VSCode-like ghost text for inline suggestions
        ghost_text = {
          enabled = false, -- Set to true if you want the inline grey text preview
        },
    },
    signature = { enabled = true }, -- parameter hints while typing a call
    sources = {
      default = { "lsp", "path", "snippets", "buffer" },
    },
    fuzzy = { implementation = "prefer_rust_with_warning" },
  },
}
