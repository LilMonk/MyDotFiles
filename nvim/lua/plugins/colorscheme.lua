-- One Dark theme. Loaded eagerly (priority) so it's applied before UI draws.
return {
  "navarasu/onedark.nvim",
  lazy = false,
  priority = 1000,
  config = function()
    require("onedark").setup({
      style = "dark",
      transparent = false,
    })
    require("onedark").load()
  end,
}
