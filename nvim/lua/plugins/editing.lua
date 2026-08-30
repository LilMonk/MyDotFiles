-- Editing helpers: auto-close pairs, surround, git gutter/hunks.
return {
  {
    "windwp/nvim-autopairs",
    enabled = require("core.plugins").enabled("autopairs"),
    event = "InsertEnter",
    opts = {},
  },

  {
    "kylechui/nvim-surround",
    enabled = require("core.plugins").enabled("surround"),
    event = "VeryLazy",
    opts = {}, -- ys / cs / ds
  },

  {
    "lewis6991/gitsigns.nvim",
    enabled = require("core.plugins").enabled("gitsigns"),
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      -- Staged hunks get their own (hollow) glyphs, so the gutter distinguishes
      -- "changed" from "changed and already staged" the way VSCode's does.
      signs = {
        add = { text = "▎" }, change = { text = "▎" },
        delete = { text = "" }, topdelete = { text = "" },
        changedelete = { text = "▎" }, untracked = { text = "▎" },
      },
      signs_staged = {
        add = { text = "┃" }, change = { text = "┃" },
        delete = { text = "" }, topdelete = { text = "" },
        changedelete = { text = "┃" }, untracked = { text = "┃" },
      },

      -- Both are too noisy to leave on; they're bound to <leader>uW / <leader>uB
      -- in plugins/snacks.lua instead.
      word_diff = false,
      current_line_blame = false,
      current_line_blame_opts = { delay = 300, virt_text_pos = "eol" },

      preview_config = { border = "rounded" }, -- matches the completion border

      on_attach = function(bufnr)
        local gs = require("gitsigns")
        local function map(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
        end

        -- In a diff-mode buffer (diffsplit, and diffview's 3-way merge view)
        -- ]c/[c must stay the builtin diff-change motion — hunk-nav there would
        -- fight the very view you opened to resolve a conflict.
        map("n", "]c", function()
          if vim.wo.diff then
            vim.cmd.normal({ "]c", bang = true })
          else
            gs.nav_hunk("next")
          end
        end, "Next hunk")
        map("n", "[c", function()
          if vim.wo.diff then
            vim.cmd.normal({ "[c", bang = true })
          else
            gs.nav_hunk("prev")
          end
        end, "Prev hunk")

        -- Normal mode acts on the hunk under the cursor; visual mode acts on the
        -- selected lines only, which is how you stage part of a hunk.
        map("n", "<leader>gs", gs.stage_hunk, "Stage hunk")
        map("n", "<leader>gr", gs.reset_hunk, "Reset hunk")
        map("x", "<leader>gs", function()
          gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, "Stage selected lines")
        map("x", "<leader>gr", function()
          gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, "Reset selected lines")

        map("n", "<leader>gp", gs.preview_hunk, "Preview hunk (float)")
        map("n", "<leader>gi", gs.preview_hunk_inline, "Preview hunk (inline)")
        map("n", "<leader>gb", function() gs.blame_line({ full = true }) end, "Blame line")

        map("n", "<leader>gS", gs.stage_buffer, "Stage buffer")
        map("n", "<leader>gR", gs.reset_buffer, "Reset buffer")
        -- undo_stage_hunk is deprecated: stage_hunk now toggles, so invoking it
        -- on a staged sign is the unstage path.
        map("n", "<leader>gu", gs.stage_hunk, "Unstage hunk (on a staged sign)")

        map("n", "<leader>gd", gs.diffthis, "Diff against index")
        map("n", "<leader>gD", function() gs.diffthis("~") end, "Diff against last commit")
      end,
    },
  },
}

