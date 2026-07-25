-- Multiple independent cursors (closest to VSCode's model).
return {
  "jake-stewart/multicursor.nvim",
  enabled = require("core.plugins").enabled("multicursor"),
  branch = "1.0",
  event = "VeryLazy",
  config = function()
    local mc = require("multicursor-nvim")
    mc.setup()
    local map = vim.keymap.set

    -- Add a cursor at the next occurrence of the word/selection (VSCode Ctrl+D -> Alt+d).
    map({ "n", "x" }, "<A-d>", function() mc.matchAddCursor(1) end, { desc = "MC: add cursor at next match" })
    -- Skip the current match and jump to the next.
    map({ "n", "x" }, "<A-S-d>", function() mc.matchSkipCursor(1) end, { desc = "MC: skip match" })
    -- Add cursors to every match of the word/selection.
    map({ "n", "x" }, "<leader>ma", function() mc.matchAllAddCursors() end, { desc = "MC: add cursors to all matches" })
    -- Alt+Click to toggle a cursor (VSCode Alt+Click).
    map("n", "<A-LeftMouse>", mc.handleMouse, { desc = "MC: toggle cursor (mouse)" })

    -- Esc clears cursors when multi-cursor is active, else clears search highlight.
    map("n", "<esc>", function()
      if mc.hasCursors() then
        mc.clearCursors()
      else
        vim.cmd("nohlsearch")
      end
    end, { desc = "Clear cursors / search highlight" })
  end,
}
