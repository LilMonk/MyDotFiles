-- Syntax parsing/highlighting via the nvim-treesitter `main` branch.
--
-- IMPORTANT: `main` is the only branch that supports Neovim 0.11+/0.12. The old
-- `master` branch is frozen and its injection queries crash on 0.12's treesitter
-- runtime ("attempt to call method 'range' (a nil value)"). `main` has a different
-- API: it installs parsers with the external `tree-sitter` CLI, and highlighting is
-- Neovim-native (vim.treesitter.start), enabled per-filetype below. It cannot be
-- lazy-loaded.
return {
  "nvim-treesitter/nvim-treesitter",
  enabled = require("core.plugins").enabled("treesitter"),
  branch = "main",
  lazy = false,
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter").setup()

    local ensure = {
      "python", "go", "gomod", "gosum", "lua", "vim", "vimdoc",
      "json", "yaml", "toml", "markdown", "markdown_inline", "bash",
    }
    -- Async; a no-op for parsers already installed.
    require("nvim-treesitter").install(ensure)

    -- Enable highlighting + (experimental) indentation once a buffer's filetype
    -- is known and its parser is available.
    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("treesitter_start", { clear = true }),
      callback = function(args)
        local buf = args.buf
        if pcall(vim.treesitter.start, buf) then
          vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
      end,
    })
  end,
}
