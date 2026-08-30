-- Fuzzy finder: files, grep, symbols, keymaps, command palette.
return {
  "nvim-telescope/telescope.nvim",
  enabled = require("core.plugins").enabled("telescope"),
  cmd = "Telescope",
  dependencies = {
    "nvim-lua/plenary.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
  },
  keys = {
    -- Files
    { "<C-p>", "<cmd>Telescope find_files<cr>", desc = "Find files" },
    { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find files" },
    { "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Recent files" },
    { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
    -- Search in project
    { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live grep (project)" },
    -- Symbols
    { "<leader>fs", "<cmd>Telescope lsp_document_symbols<cr>", desc = "Document symbols" },
    { "<leader>fS", "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>", desc = "Workspace symbols" },
    -- Diagnostics
    { "<leader>fd", "<cmd>Telescope diagnostics<cr>", desc = "Diagnostics" },
    -- Command palette + keymap search
    { "<leader>:", "<cmd>Telescope commands<cr>", desc = "Command palette" },
    { "<leader>fk", "<cmd>Telescope keymaps<cr>", desc = "Search keymaps" },
    { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Help tags" },
  },
  config = function()
    local telescope = require("telescope")
    telescope.setup({
      defaults = {
        path_display = { "truncate" },
        mappings = {
          i = { ["<esc>"] = require("telescope.actions").close },
        },
      },
    })
    pcall(telescope.load_extension, "fzf")
  end,
}
