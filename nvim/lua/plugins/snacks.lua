-- folke/snacks.nvim — one plugin, many small independent modules. The
-- per-module switches live in core/plugins.lua under the `snacks` key.
--
-- Two kinds of module, and they're configured differently:
--
--   1. Event-started: snacks hooks an early autocmd for bigfile (BufReadPre),
--      quickfile (BufReadPost), input/scope/dashboard (UIEnter), words
--      (LspAttach), and swaps vim.notify at setup for notifier. These only run
--      if their key is present in `opts`, so each gets an explicit `enabled`.
--   2. API-only: bufdelete, gitbrowse, lazygit, rename, scratch, terminal and
--      toggle have no event hook. They load lazily on the first `Snacks.<mod>`
--      access, so a keymap is the entire setup — no `opts` entry needed.
--
-- Loaded eagerly because of (1): the event hooks have to exist before the first
-- file is read. snacks' own health check requires priority >= 1000; the
-- colorscheme sits one above so colors are defined before snacks draws.
local switches = require("core.plugins")
local function on(name)
  return switches.module("snacks", name)
end

-- Keymaps, each gated on its own module switch so a disabled module leaves no
-- dead mapping behind.
local function keys()
  local k = {}
  local function add(module, spec)
    if on(module) then
      k[#k + 1] = spec
    end
  end

  add("bufdelete", { "<leader>bd", function() Snacks.bufdelete.delete() end, desc = "Delete buffer" })
  add("bufdelete", { "<leader>bo", function() Snacks.bufdelete.other() end, desc = "Delete other buffers" })

  add("gitbrowse", { "<leader>gB", mode = { "n", "x" }, function() Snacks.gitbrowse.open() end, desc = "Open in browser (remote)" })
  add("lazygit", { "<leader>gg", function() Snacks.lazygit.open() end, desc = "LazyGit" })
  add("lazygit", { "<leader>gl", function() Snacks.lazygit.log() end, desc = "LazyGit log" })
  add("lazygit", { "<leader>gf", function() Snacks.lazygit.log_file() end, desc = "LazyGit file history" })

  add("rename", { "<leader>cR", function() Snacks.rename.rename_file() end, desc = "Rename file" })

  add("scratch", { "<leader>.", function() Snacks.scratch.open() end, desc = "Toggle scratch buffer" })
  add("scratch", { "<leader>S", function() Snacks.scratch.select() end, desc = "Select scratch buffer" })

  add("terminal", { "<leader>tt", function() Snacks.terminal.toggle() end, desc = "Toggle terminal" })

  -- Navigate the LSP references that snacks.words highlights.
  add("words", { "]]", function() Snacks.words.jump(vim.v.count1) end, desc = "Next reference" })
  add("words", { "[[", function() Snacks.words.jump(-vim.v.count1) end, desc = "Prev reference" })

  return k
end

return {
  "folke/snacks.nvim",
  enabled = switches.enabled("snacks"),
  lazy = false,
  priority = 1000,
  dependencies = { "nvim-tree/nvim-web-devicons" },
  keys = keys(),
  opts = {
    bigfile = { enabled = on("bigfile") },
    quickfile = { enabled = on("quickfile") },
    input = { enabled = on("input") },
    notifier = { enabled = on("notifier"), timeout = 3000 },
    scope = { enabled = on("scope") },
    words = { enabled = on("words") },

    dashboard = {
      enabled = on("dashboard"),
      preset = {
        -- Snacks.dashboard.pick() walks a pcall chain (snacks.picker, fzf-lua,
        -- telescope, mini.pick) and would reach telescope only after two failed
        -- requires. Point it straight at telescope, since that's our picker.
        pick = function(cmd, opts)
          require("telescope.builtin")[cmd == "files" and "find_files" or cmd](opts or {})
        end,
        -- The upstream default also carries a "Restore Session" button, which
        -- hides itself unless a session plugin is installed. We have none, so
        -- it's omitted rather than shipped as a key that renders nothing.
        -- stylua: ignore
        keys = {
          { icon = " ", key = "f", desc = "Find file",    action = ":lua Snacks.dashboard.pick('files')" },
          { icon = " ", key = "r", desc = "Recent files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
          { icon = " ", key = "g", desc = "Find text",    action = ":lua Snacks.dashboard.pick('live_grep')" },
          { icon = " ", key = "e", desc = "Explorer",     action = ":Neotree reveal", enabled = switches.enabled("neotree") },
          { icon = " ", key = "n", desc = "New file",     action = ":ene | startinsert" },
          { icon = " ", key = "c", desc = "Config",       action = ":lua Snacks.dashboard.pick('files', { cwd = vim.fn.stdpath('config') })" },
          { icon = "󰒲 ", key = "L", desc = "Lazy",         action = ":Lazy" },
          { icon = " ", key = "q", desc = "Quit",         action = ":qa" },
        },
      },
    },
  },
  config = function(_, opts)
    require("snacks").setup(opts)
    if on("toggle") then
      local toggle = Snacks.toggle
      toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
      toggle.option("spell", { name = "Spelling" }):map("<leader>us")
      toggle.option("relativenumber", { name = "Relative number" }):map("<leader>uL")
      toggle.line_number():map("<leader>ul")
      toggle.diagnostics():map("<leader>ud")
      toggle.treesitter():map("<leader>uT")

      if switches.enabled("gitsigns") then
        local function gs_toggle(name, fn, field, key)
          toggle({
            name = name,
            get = function() return require("gitsigns.config").config[field] end,
            set = function(state) require("gitsigns")[fn](state) end,
          }):map(key)
        end
        gs_toggle("Git Signs", "toggle_signs", "signcolumn", "<leader>ug")
        gs_toggle("Git Word Diff", "toggle_word_diff", "word_diff", "<leader>uW")
        gs_toggle("Git Line Blame", "toggle_current_line_blame", "current_line_blame", "<leader>uB")
      end
    end
  end,
}
