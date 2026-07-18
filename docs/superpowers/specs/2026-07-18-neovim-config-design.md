# Neovim Config Design

## Goal

A lean, lazy-loaded Neovim config for Python and Go development that replicates the
VSCode features the user relies on day to day: fuzzy file/project search, go-to
definition/implementation/references, hover docs, project-wide find & replace,
multi-cursor editing, EasyMotion-style jump navigation, a file tree sidebar, open-file
tabs, and format-on-save — on a One Dark theme.

## Non-goals (v1)

Explicitly deferred to keep the plugin count small:
- Debugger/DAP integration
- Session management
- TODO-comment highlighting
- Dedicated diagnostics/"Problems" panel (`trouble.nvim`)
- Programming ligatures — the user's primary terminal is Alacritty, which does not
  support ligature rendering (a permanent renderer limitation, not a config gap).
  Neovim is a TUI and cannot render ligatures on its own regardless of font; this is
  purely a terminal capability. If the user later switches to a ligature-capable
  terminal (their dotfiles already contain a `kitty` config with `FiraCode Nerd Font`
  and ligatures enabled) or to Neovide, no nvim config changes are needed.

## Architecture

- **Plugin manager:** `lazy.nvim`. Every plugin below is lazy-loaded — on filetype,
  command, keymap, or event — nothing but the colorscheme and core options load at
  startup.
- **No pre-built distro** (no LazyVim/NvChad/AstroNvim layered on top) — config is
  hand-assembled from individual plugins to stay lean and fully understood by the user.

### File layout

New `nvim/` directory at the repo root:

```
nvim/
  init.lua                    -- bootstraps lazy.nvim, requires core modules
  lua/
    core/
      options.lua              -- vim.opt settings (numbers, indenting, etc.)
      keymaps.lua               -- non-plugin keymaps, leader key = <space>
    plugins/
      colorscheme.lua           -- onedark.nvim
      treesitter.lua
      telescope.lua              -- + telescope-fzf-native.nvim
      flash.lua
      lsp.lua                    -- mason.nvim + mason-lspconfig.nvim + nvim-lspconfig
      completion.lua             -- blink.cmp
      format.lua                 -- conform.nvim
      find-replace.lua           -- grug-far.nvim
      multicursor.lua            -- multicursor.nvim
      ui.lua                     -- lualine, bufferline, neo-tree, which-key,
                                     indent-blankline, nvim-web-devicons
      editing.lua                -- nvim-autopairs, nvim-surround, gitsigns.nvim
```

Commenting (`gc`/`gcc`) uses Neovim 0.10's built-in native comment support — no plugin.
Hover docs use the built-in `vim.lsp.buf.hover()` (`K`) — no plugin.

## Feature → plugin mapping

| VSCode feature | Plugin | Notes |
|---|---|---|
| Theme | `navarasu/onedark.nvim` | Lua-native, treesitter-aware highlight groups |
| Syntax/parsing | `nvim-treesitter` | Python + Go parsers auto-installed |
| Ctrl+P file finder | `telescope.nvim` + `telescope-fzf-native.nvim` | native fzf matcher for speed |
| Ctrl+Shift+F find-in-project | `telescope.nvim` live_grep | requires `ripgrep` on PATH |
| Ctrl+H find & replace across project | `grug-far.nvim` | live-preview buffer, edit and apply |
| Go to Definition / Implementation / References | `nvim-lspconfig` via Telescope pickers | opens as a Telescope list with preview; pick to jump |
| Hover docs | built-in `vim.lsp.buf.hover` (`K`) | no extra plugin |
| EasyMotion | `flash.nvim` | label-jump to any visible location |
| Multi-cursor (Ctrl+D / Alt+Click) | `multicursor.nvim` | independent cursors, closest match to VSCode's model |
| Explorer sidebar | `neo-tree.nvim` | git status + diagnostics icons in the tree |
| Open-file tabs | `bufferline.nvim` | |
| Autocomplete | `blink.cmp` | native fuzzy matcher, built-in snippet expansion |
| LSP server install | `mason.nvim` + `mason-lspconfig.nvim` | auto-installs `gopls`, `basedpyright`, `ruff` |
| Format on save | `conform.nvim` | `goimports`/`gofmt` for Go, `ruff_format` for Python |
| Status bar | `lualine.nvim` | |
| Keybinding hints | `which-key.nvim` | popup of available bindings as `<leader>` is typed |
| Git gutter/hunks | `gitsigns.nvim` | |
| Indent guides | `indent-blankline.nvim` | |
| Auto-close brackets | `nvim-autopairs` | |
| Surround text objects | `nvim-surround` | `ys`/`cs`/`ds` |

19 plugins total, all lazy-loaded.

## External dependencies

- `ripgrep` — required by Telescope live_grep and grug-far
- `fd` — optional, speeds up Telescope's file finder
- Nerd Font — already installed and configured (`FiraMono Nerd Font` in Alacritty) for
  file-type icons (`nvim-web-devicons`, neo-tree, bufferline, lualine)
- `git` — for gitsigns
- Go and Python toolchains on PATH so `gopls`/`basedpyright`/`ruff` (installed via
  Mason) can find project dependencies

## Isolated testing workflow

To validate the config without touching (or risking) any pre-existing Neovim setup:

1. Config is developed at `nvim/` in this repo from the start — the final destination
   layout, not a throwaway.
2. Add `"nvim": "~/.config/nvim-test"` to `.dotfiles/mappings.json` and run `link.sh` to
   symlink it.
3. Launch with `NVIM_APPNAME=nvim-test nvim`. Neovim then reads config from
   `~/.config/nvim-test` and keeps plugin installs / shada / state under
   `~/.local/share/nvim-test` and `~/.local/state/nvim-test` — fully isolated from any
   real `~/.config/nvim`. A temporary shell alias (e.g. `nvt`) is added for convenience
   during this phase.
4. Once satisfied, promotion to daily-driver status is a one-line change: point (or add)
   the mapping to `~/.config/nvim` and launch as plain `nvim` — the config itself is
   unchanged.

## Verification plan

- `nvim` (test appname) starts with no errors on a blank buffer.
- `:Lazy` shows all 19 plugins loaded/lazy as expected, no load errors.
- `:Mason` shows `gopls`, `basedpyright`, `ruff` installed.
- `:checkhealth` clean for treesitter, lsp, telescope.
- Open a `.go` file and a `.py` file each: LSP attaches (checked via `:LspInfo`),
  diagnostics appear on an intentional error, `K` shows hover docs, go-to-definition via
  Telescope picker jumps correctly, save triggers formatting.
- Telescope: file finder, live_grep, and LSP reference/definition pickers all open and
  return results.
- `flash.nvim` jump motion works within a buffer.
- `multicursor.nvim`: create multiple cursors and confirm independent edits.
- `grug-far.nvim`: open on a project, search a term, confirm replace-and-apply works.
- neo-tree toggles, bufferline shows open buffers, lualine renders, which-key popup
  appears on `<leader>`.
- Onedark theme applied correctly across normal/treesitter/LSP highlight groups.
