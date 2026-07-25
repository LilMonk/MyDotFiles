-- Central enable/disable switchboard for optional plugins.
--
-- Set a plugin's key to `false` to disable it; anything else (or leaving it
-- out entirely) keeps it enabled. After toggling, run `:Lazy` to uninstall a
-- disabled plugin or `:Lazy sync` to reinstall a re-enabled one.
--
-- Only top-level feature plugins live here. Dependencies (plenary, nui,
-- web-devicons, mason-lspconfig, …) load automatically with their parent and
-- are intentionally omitted. The colorscheme is also omitted because
-- init.lua's `install.colorscheme` depends on it at startup.
local M = {}

M.map = {
  flash       = true, -- folke/flash.nvim
  multicursor = true, -- jake-stewart/multicursor.nvim
  telescope   = true, -- nvim-telescope/telescope.nvim
  treesitter  = true, -- nvim-treesitter/nvim-treesitter
  lsp         = true, -- neovim/nvim-lspconfig
  completion  = true, -- saghen/blink.cmp
  format      = true, -- stevearc/conform.nvim
  findreplace = true, -- MagicDuck/grug-far.nvim
  autopairs   = true, -- windwp/nvim-autopairs
  surround    = true, -- kylechui/nvim-surround
  gitsigns    = true, -- lewis6991/gitsigns.nvim
  lualine     = true, -- nvim-lualine/lualine.nvim
  bufferline  = true, -- akinsho/bufferline.nvim
  neotree     = true, -- nvim-neo-tree/neo-tree.nvim
  whichkey    = true, -- folke/which-key.nvim
  indent      = true, -- lukas-reineke/indent-blankline.nvim
}

-- Returns whether a plugin is enabled. Unlisted (nil) plugins default to on;
-- only an explicit `false` disables.
function M.enabled(name)
  return M.map[name] ~= false
end

return M
