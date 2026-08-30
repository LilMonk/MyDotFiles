-- core/options.lua — editor behavior (no plugins).

local g = vim.g
local opt = vim.opt

-- Leader keys must be set before lazy.nvim and any plugin loads.
g.mapleader = " "
g.maplocalleader = " "
g.have_nerd_font = true
local osc52 = require("vim.ui.clipboard.osc52")
g.clipboard = {
  name = "osc52-copy+wl-paste",
  copy = {
    ["+"] = osc52.copy("+"),
    ["*"] = osc52.copy("*"),
  },
  paste = {
    ["+"] = { "wl-paste", "--no-newline" },
    ["*"] = { "wl-paste", "--no-newline", "--primary" },
  },
}


-- UI / display
opt.number = true
opt.relativenumber = true
opt.termguicolors = true
opt.signcolumn = "yes" -- stable gutter so diagnostics/git signs don't shift text
opt.cursorline = true
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.splitright = true
opt.splitbelow = true
opt.showmode = false -- don't show the mode, since it's already in the status line

-- Indentation (LSP/formatters refine per-language; these are sane defaults)
opt.expandtab = true
opt.shiftwidth = 4
opt.tabstop = 4
opt.softtabstop = 4
opt.smartindent = true
opt.wrap = true
opt.linebreak = true     -- Wrap lines at word boundaries instead of mid-word
opt.breakindent = true   -- Indent wrapped lines to match the start of the line
opt.breakindentopt = 'shift:2,min:40' -- Shift wrapped lines by 2 spaces, minimum text width 40

-- Whitespaces display
opt.list = true
opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Search
opt.ignorecase = true
opt.smartcase = true
opt.incsearch = true
opt.hlsearch = true
opt.inccommand = 'split' -- preview substitution live

-- VSCode-parity behaviors
opt.mouse = "a" -- required for Alt+Click multi-cursor + click-to-position
-- opt.clipboard = "unnamedplus" -- share the OS clipboard (provider set in init.lua)
opt.undofile = true -- persistent undo across sessions

-- Misc quality-of-life
opt.updatetime = 250
opt.timeoutlen = 400
opt.confirm = true -- prompt instead of failing on unsaved changes

-- Diagnostics presentation (built-in vim.diagnostic).
vim.diagnostic.config({
  -- `if_many` names the server only when several are attached to the buffer,
  -- which is what tells a ruff complaint apart from a basedpyright one.
  virtual_text = { spacing = 2, prefix = "●", source = "if_many" },
  signs = g.have_nerd_font and {
    text = {
      [vim.diagnostic.severity.ERROR] = "󰅚 ",
      [vim.diagnostic.severity.WARN] = "󰀪 ",
      [vim.diagnostic.severity.INFO] = "󰋽 ",
      [vim.diagnostic.severity.HINT] = "󰌶 ",
    },
  } or true,
  underline = { severity = vim.diagnostic.severity.ERROR }, -- hints/info stay unsquiggled
  update_in_insert = false,
  severity_sort = true,
  float = { border = "rounded", source = "if_many" },
})
