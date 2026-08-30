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
      { '\\', ':Neotree reveal<CR>', desc = 'NeoTree reveal', silent = true },
      { "<leader>ge", "<cmd>Neotree git_status toggle<cr>", desc = "Git explorer" },
      { "<leader>be", "<cmd>Neotree buffers toggle<cr>", desc = "Buffer explorer" },
    },
    deactivate = function()
      vim.cmd([[Neotree close]])
    end,
    opts = {
      close_if_last_window = true,
      sources = { "filesystem", "buffers", "git_status" },
      open_files_do_not_replace_types = { "terminal", "Trouble", "trouble", "qf", "Outline" },
      event_handlers = {
        {
          event = "file_opened",
          handler = function(file_path)
            -- auto close
            require("neo-tree.command").execute({ action = "close" })
          end
        }
      },
      filesystem = {
        follow_current_file = { enabled = true },
        use_libuv_file_watcher = true,
        window = {
          mappings = {
            ['\\'] = 'close_window',
          },
        },
      },
      window = {
        mappings = {
          ["l"] = "open",
          ["h"] = "close_node",
          ["<space>"] = "none",
          ["Y"] = {
            function(state)
              vim.fn.setreg("+", state.tree:get_node():get_id(), "c")
            end,
            desc = "Copy path to clipboard",
          },
          ["gy"] = {
            function(state)
              local node = state.tree:get_node()
              if not node then
                return
              end
              local path = node.path or node:get_id()
              -- ":." is relative to cwd, and degrades to the absolute path
              -- when the entry lives outside cwd.
              local rel = vim.fn.fnamemodify(path, ":.")
              vim.fn.setreg("+", rel, "c")
              vim.notify("Copied: " .. rel)
            end,
            desc = "Copy relative path to clipboard",
          },
          ["gO"] = {
            function(state)
              local node = state.tree:get_node()
              if not node then
                return
              end
              local path = node.path or node:get_id()
              -- open the containing folder with the entry itself selected.
              if vim.fn.executable("nautilus") == 1 then
                vim.system({ "nautilus", "--select", path }, { detach = true })
              else
                vim.ui.open(vim.fs.dirname(path))
              end
            end,
            desc = "Open containing folder",
          },
          ["O"] = {
            function(state)
              require("lazy.util").open(state.tree:get_node().path, { system = true })
            end,
            desc = "Open with system application",
          },
        },
      },
      default_component_configs = {
        git_status = {
          symbols = {
            unstaged = "󰄱",
            staged = "󰱒",
          },
        },
      },
    },
    config = function(_, opts)
      -- When renaming or moving the file from neotree, this helps snacks rename 
      -- plugin to rename the imports in all the files that have the old file references.
      if require("core.plugins").module("snacks", "rename") then
        local function on_move(data)
          Snacks.rename.on_rename_file(data.source, data.destination)
        end
        local events = require("neo-tree.events")
        vim.list_extend(opts.event_handlers, {
          { event = events.FILE_MOVED, handler = on_move },
          { event = events.FILE_RENAMED, handler = on_move },
        })
      end

      require("neo-tree").setup(opts)

      -- Refresh when terminal exits. This helps the git actions taken in
      -- terminal to be reflected in neotree.
      vim.api.nvim_create_autocmd("TermClose", {
        pattern = "*lazygit",
        callback = function()
          if package.loaded["neo-tree.sources.git_status"] then
            require("neo-tree.sources.git_status").refresh()
          end
        end,
      })
    end,
  },

  -- Keybinding hints.
  {
    "folke/which-key.nvim",
    enabled = require("core.plugins").enabled("whichkey"),
    event = "VeryLazy",
    opts = {
      triggers = {
        { "<auto>", mode = "nxso" },
      },
    },
    config = function(_, opts)
      local wk = require("which-key")
      wk.setup(opts)
      wk.add({
        { "<leader>f", group = "find" },
        { "<leader>c", group = "code/conflict" },
        { "<leader>g", group = "git" },
        { "<leader>s", group = "search" },
        { "<leader>m", group = "multicursor" },
        { "<leader>b", group = "buffer" },
        { "<leader>t", group = "terminal" },
        { "<leader>u", group = "ui/toggle" },
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

  {
    "nmac427/guess-indent.nvim",
    enabled = require("core.plugins").enabled("indent"),
    event = { "BufReadPost", "BufNewFile" },
    opts = {},
  }
}
