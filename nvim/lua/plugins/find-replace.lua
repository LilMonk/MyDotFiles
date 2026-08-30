-- Project-wide find & replace with a live-preview buffer (VSCode Ctrl+Shift+H).
return {
  "MagicDuck/grug-far.nvim",
  enabled = require("core.plugins").enabled("findreplace"),
  cmd = "GrugFar",
  opts = {},
  keys = {
    { "<leader>sr", "<cmd>GrugFar<cr>", desc = "Search & replace (project)" },
    {
      "<leader>sw",
      mode = { "n", "x" },
      function()
        require("grug-far").open({ prefills = { search = vim.fn.expand("<cword>") } })
      end,
      desc = "Search & replace word under cursor",
    },
  },
}
