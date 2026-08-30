-- Syntax parsing/highlighting via the nvim-treesitter `main` branch.
--
-- IMPORTANT: `main` is the only branch that supports Neovim 0.11+/0.12. The old
-- `master` branch is frozen and its injection queries crash on 0.12's treesitter
-- runtime ("attempt to call method 'range' (a nil value)"). `main` has a different
-- API: it installs parsers with the external `tree-sitter` CLI, and highlighting is
-- Neovim-native (vim.treesitter.start), enabled per-filetype below. It cannot be
-- lazy-loaded.
return {
  "nvim-treesitter/nvim-treesitter",
  enabled = require("core.plugins").enabled("treesitter"),
  branch = "main",
  lazy = false,
  build = ":TSUpdate",
  config = function()
    local ts = require("nvim-treesitter")
    ts.setup()

    -- Attach highlighting + (experimental) indentation. Returns false when the
    -- buffer's parser isn't installed, which is the signal to go fetch it.
    local function start(buf)
      if not vim.api.nvim_buf_is_valid(buf) or not pcall(vim.treesitter.start, buf) then
        return false
      end
      vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      return true
    end

    -- A parser arriving mid-session has to be attached to every buffer already
    -- waiting on it, not just the one whose FileType triggered the install.
    local function attach_ft(ft)
      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.bo[buf].filetype == ft then
          start(buf)
        end
      end
    end

    -- Parsers nvim-treesitter knows how to build. Resolved on the first miss and
    -- cached: get_available() sorts the whole list and fires `User TSUpdate` on
    -- every call, which is too much to pay per FileType event.
    local available
    -- Languages we've already kicked off a build for, so a filetype opened
    -- repeatedly while its parser compiles doesn't queue duplicate jobs.
    local attempted = {}

    local ensure = {
      "python", "go", "gomod", "gosum", "lua", "vim", "vimdoc",
      "json", "yaml", "toml", "markdown", "markdown_inline", "bash",
    }
    for _, lang in ipairs(ensure) do
      attempted[lang] = true
    end

    -- Async; a no-op for parsers already installed. On a fresh machine the
    -- first files open before this finishes, hence the re-attach pass.
    ts.install(ensure):await(function()
      vim.schedule(function()
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
          start(buf)
        end
      end)
    end)

    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("treesitter_start", { clear = true }),
      callback = function(args)
        local buf, ft = args.buf, args.match
        if start(buf) then
          return
        end

        -- No parser for this filetype yet: build it, then attach. get_lang
        -- falls back to the filetype itself, so `available` is what filters out
        -- filetypes with no grammar (help, netrw, dashboards, …).
        local lang = vim.treesitter.language.get_lang(ft)
        if not lang or attempted[lang] then
          return
        end

        available = available or ts.get_available()
        if not vim.list_contains(available, lang) then
          return
        end

        attempted[lang] = true
        ts.install({ lang }):await(function(err, ok)
          -- install() reports a failed build as `ok == false` rather than an
          -- error; clear the flag so the next visit retries.
          if err or ok == false then
            attempted[lang] = nil
            return
          end
          vim.schedule(function()
            attach_ft(ft)
          end)
        end)
      end,
    })
  end,
}
