-- core/keymaps.lua — non-plugin keymaps. Leader is <Space> (set in init.lua).
-- Plugin-specific maps live with their plugin spec (keys = {...}) or on_attach.

local map = vim.keymap.set

-- Save (VSCode/Sublime Ctrl+S), in normal and insert.
map("n", "<C-s>", "<cmd>silent! write<cr>", { desc = "Save file" })
map("i", "<C-s>", "<Esc><cmd>silent! write<cr>", { desc = "Save file" })

-- Toggle comment (VSCode/Sublime Ctrl+/). Terminals send it as <C-/> (kitty
-- protocol) or the legacy <C-_>; map both. Uses native gc/gcc.
map("n", "<C-/>", "gcc", { remap = true, desc = "Toggle comment" })
map("x", "<C-/>", "gc", { remap = true, desc = "Toggle comment" })
map("n", "<C-_>", "gcc", { remap = true, desc = "Toggle comment" })
map("x", "<C-_>", "gc", { remap = true, desc = "Toggle comment" })

-- Move line/selection up/down (VSCode/Sublime Alt+Up/Down -> Alt+j/k).
map("n", "<A-j>", "<cmd>m .+1<cr>==", { desc = "Move line down" })
map("n", "<A-k>", "<cmd>m .-2<cr>==", { desc = "Move line up" })
map("i", "<A-j>", "<Esc><cmd>m .+1<cr>==gi", { desc = "Move line down" })
map("i", "<A-k>", "<Esc><cmd>m .-2<cr>==gi", { desc = "Move line up" })
map("x", "<A-j>", ":m '>+1<cr>gv=gv", { desc = "Move selection down" })
map("x", "<A-k>", ":m '<-2<cr>gv=gv", { desc = "Move selection up" })

-- Move focus between splits with Ctrl+h/j/k/l.
map("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Go to lower window" })
map("n", "<C-k>", "<C-w>k", { desc = "Go to upper window" })
map("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })

-- Buffer navigation (Shift+H / Shift+L). :bnext/:bprevious follow bufferline order.
map("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Previous buffer" })

-- Clear search highlight.
map("n", "<Esc>", "<cmd>nohlsearch<cr><Esc>", { desc = "Clear search highlight" })
map("n", "<leader>nh", "<cmd>nohlsearch<cr>", { desc = "Clear search highlight" })

-- System clipboard on demand (via the "+ register). Plain y/p stay internal;
-- only these keymaps touch the OS clipboard. Copy goes through OSC 52 (no flash,
-- see init.lua). Paste falls back to wl-paste and flashes focus once on Mutter --
-- for flash-free paste, use Ctrl+Shift+V in insert mode (Alacritty's own paste).
map({ "n", "x" }, "<leader>y", '"+y', { desc = "Copy to system clipboard" })
map("n", "<leader>Y", '"+y$', { desc = "Copy to end of line to system clipboard" })
map({ "n", "x" }, "<leader>p", '"+p', { desc = "Paste system clipboard after cursor" })
map({ "n", "x" }, "<leader>P", '"+P', { desc = "Paste system clipboard before cursor" })

-- Diagnostics navigation (works without a server attached).
map("n", "]d", function() vim.diagnostic.jump({ count = 1, float = true }) end, { desc = "Next diagnostic" })
map("n", "[d", function() vim.diagnostic.jump({ count = -1, float = true }) end, { desc = "Prev diagnostic" })
map("n", "]e", function()
  vim.diagnostic.jump({ count = 1, float = true, severity = vim.diagnostic.severity.ERROR })
end, { desc = "Next error" })
map("n", "[e", function()
  vim.diagnostic.jump({ count = -1, float = true, severity = vim.diagnostic.severity.ERROR })
end, { desc = "Prev error" })
map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line diagnostics" })
map('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })


-- Exit terminal mode in the builtin terminal.
-- Otherwise, you normally need to press <C-\><C-n>.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc.
map('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })