-- core/autocmds.lua — small built-in behaviors (no plugins).

local aug = vim.api.nvim_create_augroup

-- Restore last cursor position when reopening a file (like VSCode).
vim.api.nvim_create_autocmd("BufReadPost", {
  group = aug("restore_cursor", { clear = true }),
  callback = function(args)
    local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
    local line_count = vim.api.nvim_buf_line_count(args.buf)
    if mark[1] > 0 and mark[1] <= line_count then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Briefly highlight yanked text.
vim.api.nvim_create_autocmd("TextYankPost", {
  group = aug("highlight_yank", { clear = true }),
  callback = function()
    vim.hl.on_yank({ timeout = 150 })
  end,
})
