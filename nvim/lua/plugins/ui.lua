-- UI plugins: statusline, buffer tabs, file explorer, keybinding hints,
-- indent guides, and the shared devicons dependency.
return {
  -- File-type icons (shared dependency).
  { "nvim-tree/nvim-web-devicons", lazy = true },

  -- Status bar.
  {
    "nvim-lualine/lualine.nvim",
    enabled = require("core.plugins").enabled("lualine"),
    event = "VeryLazy",
    opts = {
      options = {
        theme = "onedark",
        globalstatus = true,
        section_separators = "",
        component_separators = "|",
      },
    },
  },

  -- Open-file tabs.
  {
    "akinsho/bufferline.nvim",
    enabled = require("core.plugins").enabled("bufferline"),
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      options = {
        diagnostics = "nvim_lsp",
        show_buffer_close_icons = true,
        offsets = {
          { filetype = "neo-tree", text = "Explorer", highlight = "Directory", separator = true },
        },
      },
    },
  },

  -- Explorer sidebar.
  {
    "nvim-neo-tree/neo-tree.nvim",
    enabled = require("core.plugins").enabled("neotree"),
    branch = "v3.x",
    cmd = "Neotree",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    keys = {
      { "<leader>e", "<cmd>Neotree toggle<cr>", desc = "Toggle explorer" },
    },
    opts = {
      close_if_last_window = true,
      filesystem = {
        follow_current_file = { enabled = true },
        use_libuv_file_watcher = true,
      },
    },
  },

  -- Keybinding hints.
  {
    "folke/which-key.nvim",
    enabled = require("core.plugins").enabled("whichkey"),
    event = "VeryLazy",
    opts = {
      -- Default triggers include operator-pending mode ("o"), which pops up
      -- a help window on bare c/d/y before the motion/text-object is typed —
      -- visibly resizing the window mid-edit. Drop "o" to keep auto-triggering
      -- for normal/visual/select (leader groups, gc, etc.) without that.
      triggers = {
        { "<auto>", mode = "nxso" },
      },
    },
    config = function(_, opts)
      local wk = require("which-key")
      wk.setup(opts)
      wk.add({
        { "<leader>f", group = "find" },
        { "<leader>c", group = "code" },
        { "<leader>g", group = "git" },
        { "<leader>s", group = "search" },
        { "<leader>m", group = "multicursor" },
      })
    end,
  },

  -- Indent guides.
  {
    "lukas-reineke/indent-blankline.nvim",
    enabled = require("core.plugins").enabled("indent"),
    main = "ibl",
    event = { "BufReadPost", "BufNewFile" },
    opts = {},
  },
}
