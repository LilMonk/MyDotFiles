local switches = require("core.plugins")

return {
  {
    "sindrets/diffview.nvim",
    enabled = switches.enabled("diffview"),
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory", "DiffviewToggleFiles" },
    keys = {
      { "<leader>gv", "<cmd>DiffviewOpen<cr>", desc = "Diff view (working tree)" },
      { "<leader>gV", "<cmd>DiffviewClose<cr>", desc = "Close diff view" },
      { "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "File history (current file)" },
      { "<leader>gH", "<cmd>DiffviewFileHistory<cr>", desc = "File history (repo)" },
    },
    opts = {
      enhanced_diff_hl = true,
      file_panel = { listing_style = "tree" },
      view = {
        -- diff3_mixed stacks OURS and THEIRS above the merged result (the plugin default,
        -- diff3_horizontal, is three side-by-side panes). It has no BASE pane,
        -- so on the rare conflict where you need base, cycle with g<C-x>.
        merge_tool = { layout = "diff3_mixed", disable_diagnostics = true, winbar_info = true },
      },
      -- Defaults are kept: they already bind ]x/[x for conflict navigation and
      -- 2do/3do to pull a hunk from OURS/THEIRS.
      keymaps = { disable_defaults = false },
    },
  },

  {
    "akinsho/git-conflict.nvim",
    enabled = switches.enabled("gitconflict"),
    version = "*",
    event = "BufReadPre",
    opts = {
      -- The plugin's default mappings put "choose theirs" on `ct`, which
      -- shadows the builtin ct{char} change-till operator behind timeoutlen
      -- (400ms here). Ours go under <leader>c, matching diffview's merge-tool
      -- bindings exactly.
      default_mappings = false,
      default_commands = true,
      -- Left off deliberately -- see the config function below. We still want
      -- diagnostics suppressed on conflict markers, just not via this flag.
      disable_diagnostics = false,
      highlights = { incoming = "DiffAdd", current = "DiffText" },
    },
    config = function(_, opts)
      require("git-conflict").setup(opts)

      -- LSPs report conflict markers as syntax errors, so diagnostics need to
      -- go quiet while a buffer is conflicted. The plugin's own
      -- `disable_diagnostics` option can't do it on Neovim 0.12: it calls
      -- vim.diagnostic.disable(), removed in 0.12, and its re-enable path
      -- passes a bufnr where 0.12 expects a boolean (which would turn
      -- diagnostics back on globally). Both events are handled here instead.
      local group = vim.api.nvim_create_augroup("git_conflict_diagnostics", { clear = true })
      local function on(event, enabled)
        vim.api.nvim_create_autocmd("User", {
          group = group,
          pattern = event,
          callback = function()
            vim.diagnostic.enable(enabled, { bufnr = vim.api.nvim_get_current_buf() })
          end,
        })
      end
      on("GitConflictDetected", false)
      on("GitConflictResolved", true)
    end,
    keys = {
      { "<leader>co", "<cmd>GitConflictChooseOurs<cr>", desc = "Conflict: choose ours" },
      { "<leader>ct", "<cmd>GitConflictChooseTheirs<cr>", desc = "Conflict: choose theirs" },
      { "<leader>cb", "<cmd>GitConflictChooseBoth<cr>", desc = "Conflict: choose both" },
      { "<leader>cB", "<cmd>GitConflictChooseBase<cr>", desc = "Conflict: choose base" },
      { "<leader>cn", "<cmd>GitConflictChooseNone<cr>", desc = "Conflict: choose none" },
      { "<leader>cl", "<cmd>GitConflictListQf<cr>", desc = "Conflict: list in quickfix" },
      { "]x", "<cmd>GitConflictNextConflict<cr>", desc = "Next conflict" },
      { "[x", "<cmd>GitConflictPrevConflict<cr>", desc = "Prev conflict" },
    },
  },
}
