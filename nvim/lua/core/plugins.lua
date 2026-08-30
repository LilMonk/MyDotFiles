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
--
-- snacks.nvim is one plugin wrapping ~32 independent modules, so its value is a
-- table of per-module switches instead of a plain boolean. Set the whole key to
-- `false` to drop the plugin entirely.
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
  diffview    = true, -- sindrets/diffview.nvim
  gitconflict = true, -- akinsho/git-conflict.nvim
  lualine     = true, -- nvim-lualine/lualine.nvim
  bufferline  = true, -- akinsho/bufferline.nvim
  neotree     = true, -- nvim-neo-tree/neo-tree.nvim
  whichkey    = true, -- folke/which-key.nvim
  indent      = true, -- lukas-reineke/indent-blankline.nvim

  -- folke/snacks.nvim — per-module switches. Modules absent from this table are
  -- off: snacks only starts a module whose key we pass in `opts`.
  snacks = {
    -- Modules snacks starts on an event (or at setup, for notifier).
    bigfile   = true, -- trim expensive features on huge/minified files
    quickfile = true, -- render the file before the rest of the plugins load
    input     = true, -- better vim.ui.input (used by grn / LSP rename)
    notifier  = true, -- owns vim.notify; fidget keeps LSP progress only
    scope     = true, -- adds ii/ai text objects and [i/]i jumps
    words     = true, -- LSP reference highlight + ]]/[[ (replaces lsp.lua code)
    dashboard = true, -- start screen; its buttons drive telescope/neo-tree

    -- API-only modules: no event hook, loaded on first use by their keymap.
    bufdelete = true, -- close a buffer without wrecking the window layout
    gitbrowse = true, -- open the current file/line on the remote
    lazygit   = true, -- needs the `lazygit` binary
    rename    = true, -- LSP-aware file rename
    scratch   = true, -- persistent scratch buffers
    terminal  = true, -- toggleable float terminal
    toggle    = true, -- which-key-integrated option toggles

    -- Deliberately off. The first three replace plugins we already run; image
    -- needs a kitty-graphics terminal (we maintain alacritty) plus tmux
    -- allow-passthrough; the rest are cosmetic and unevaluated.
    picker       = false, -- would replace telescope
    explorer     = false, -- would replace neo-tree
    indent       = false, -- would replace indent-blankline
    statuscolumn = false,
    image        = false,
    scroll       = false,
    dim          = false,
    zen          = false,
  },
}

-- Returns whether a plugin is enabled. Unlisted (nil) plugins default to on;
-- only an explicit `false` disables.
function M.enabled(name)
  return M.map[name] ~= false
end

-- Returns whether a sub-module of a table-valued plugin (snacks) is on.
-- Unlisted modules default to *off*, matching snacks' own opt-in behavior.
function M.module(plugin, name)
  local t = M.map[plugin]
  return type(t) == "table" and t[name] == true
end

return M
