-- Fuzzy finder: files, grep, symbols, keymaps, command palette.
--
-- <C-p> is a hand-rolled find_files that lists the files you touched most
-- recently first and the rest of the tree after them. Telescope has no notion
-- of recency, so `find_files_recent` below rebuilds the picker; `<leader>ff`
-- stays on the stock builtin as an escape hatch.

-- Paths (relative to `cwd`) of the most recently accessed files, best first:
-- the listed buffers ordered by last use, then `v:oldfiles` for earlier
-- sessions. Anything outside `cwd`, unreadable, or not a real file is dropped.
--
-- The current buffer is skipped on purpose. It is the most recent file by
-- definition, and leading with it would make <C-p><CR> reopen the file you are
-- already in; it still shows up further down in the find results.
local function recent_paths(cwd)
  local prefix = cwd:gsub("/$", "") .. "/"
  local seen, paths = {}, {}

  local function add(path)
    if path == "" or path:sub(1, #prefix) ~= prefix then
      return
    end
    local rel = path:sub(#prefix + 1)
    if not seen[rel] and vim.fn.filereadable(path) == 1 then
      seen[rel] = true
      paths[#paths + 1] = rel
    end
  end

  -- `v:oldfiles` is read from the shada file at startup and never updated, so
  -- the live buffer list is what covers the current session.
  local current = vim.api.nvim_get_current_buf()
  local buffers = vim.fn.getbufinfo({ buflisted = 1 })
  -- `lastused` is a whole-second timestamp, so files opened in the same second
  -- tie; the higher buffer number is the one created later.
  table.sort(buffers, function(a, b)
    if a.lastused == b.lastused then
      return a.bufnr > b.bufnr
    end
    return a.lastused > b.lastused
  end)
  for _, buf in ipairs(buffers) do
    -- buftype filters out terminals, help, quickfix and the like.
    if buf.bufnr ~= current and vim.bo[buf.bufnr].buftype == "" then
      add(buf.name)
    end
  end

  for _, path in ipairs(vim.v.oldfiles) do
    add(vim.fn.fnamemodify(path, ":p"))
  end

  return paths
end

-- telescope's own fallback chain for `find_files`, minus the flags we never
-- pass (hidden, no_ignore, follow, search_dirs).
local function find_command()
  if vim.fn.executable("rg") == 1 then
    return { "rg", "--files", "--color", "never" }
  elseif vim.fn.executable("fd") == 1 then
    return { "fd", "--type", "f", "--color", "never" }
  elseif vim.fn.executable("fdfind") == 1 then
    return { "fdfind", "--type", "f", "--color", "never" }
  end
  return { "find", ".", "-type", "f", "-not", "-path", "*/.*" }
end

local function find_files_recent()
  local conf = require("telescope.config").values
  local finders = require("telescope.finders")
  local make_entry = require("telescope.make_entry")
  local pickers = require("telescope.pickers")

  local cwd = vim.uv.cwd()
  local recent = recent_paths(cwd)

  -- Position in `recent`; anything absent from it sorts after everything in it.
  local rank = {}
  for i, rel in ipairs(recent) do
    rank[rel] = i
  end

  local opts = { cwd = cwd }
  local entry_of = make_entry.gen_from_file(opts)

  local seeded = {}
  for i, rel in ipairs(recent) do
    local entry = entry_of(rel)
    entry.index = i
    seeded[i] = entry
  end

  -- Drop the recents from the find output so they appear exactly once. `find`
  -- prefixes its paths with "./" and the others don't, so strip that first --
  -- it keeps the duplicate check honest and the two blocks displayed alike.
  opts.entry_maker = function(line)
    line = line:gsub("^%./", "")
    if rank[line] then
      return nil
    end
    return entry_of(line)
  end

  -- With an empty prompt every entry scores 1, and telescope's entry manager
  -- only consults `tiebreak` below a score of 1 -- so the unfiltered list is
  -- just the order the finder emits, which is what makes seeding work. Once
  -- you type, scores separate and this keeps recency as the deciding vote
  -- between equally good matches.
  opts.tiebreak = function(current, existing, _)
    local a, b = rank[current.value], rank[existing.value]
    if a or b then
      return (a or math.huge) < (b or math.huge)
    end
    return #current.ordinal < #existing.ordinal -- telescope's default
  end

  -- Emit the recents, then hand off to the streaming find job. Wrapping rather
  -- than replacing the job keeps its async behaviour and result cache intact.
  local job = finders.new_oneshot_job(find_command(), opts)
  local finder = setmetatable({}, {
    __index = job,
    __call = function(_, prompt, process_result, process_complete)
      for _, entry in ipairs(seeded) do
        -- Truthy means the picker has moved on to a newer prompt.
        if process_result(entry) then
          return
        end
      end
      return job(prompt, process_result, process_complete)
    end,
  })

  pickers
    .new(opts, {
      prompt_title = "Find Files (recent first)",
      __locations_input = true, -- lets the prompt carry a `file.lua:42` suffix
      finder = finder,
      previewer = conf.grep_previewer(opts),
      sorter = conf.file_sorter(opts),
    })
    :find()
end

return {
  "nvim-telescope/telescope.nvim",
  enabled = require("core.plugins").enabled("telescope"),
  cmd = "Telescope",
  dependencies = {
    "nvim-lua/plenary.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
  },
  keys = {
    -- Files. <C-p> puts recently accessed files first; a recent file that `rg`
    -- would skip (hidden or gitignored, say .env) is reachable there and only
    -- there, which is the one way it diverges from plain find_files.
    { "<C-p>", find_files_recent, desc = "Find files (recent first)" },
    { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find files" },
    { "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Recent files" },
    { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
    -- Search in project
    { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live grep (project)" },
    -- Symbols
    { "<leader>fs", "<cmd>Telescope lsp_document_symbols<cr>", desc = "Document symbols" },
    { "<leader>fS", "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>", desc = "Workspace symbols" },
    -- Diagnostics
    { "<leader>fd", "<cmd>Telescope diagnostics<cr>", desc = "Diagnostics" },
    -- Command palette + keymap search
    { "<leader>:", "<cmd>Telescope commands<cr>", desc = "Command palette" },
    { "<leader>fk", "<cmd>Telescope keymaps<cr>", desc = "Search keymaps" },
    { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Help tags" },
  },
  config = function()
    local telescope = require("telescope")
    telescope.setup({
      defaults = {
        path_display = { "truncate" },
        mappings = {
          i = { ["<esc>"] = require("telescope.actions").close },
        },
      },
    })
    pcall(telescope.load_extension, "fzf")
  end,
}
