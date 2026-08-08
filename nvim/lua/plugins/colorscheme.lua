-- One Dark theme. Loaded eagerly (priority) so it's applied before UI draws.
-- Priority stays above snacks.nvim's required 1000 so colors exist first.
return {
  "navarasu/onedark.nvim",
  lazy = false,
  priority = 1001,
  config = function()
    require("onedark").setup({
      style = "dark",
      transparent = false,
    })
    require("onedark").load()
  end,
}
