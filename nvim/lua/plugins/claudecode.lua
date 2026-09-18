-- coder/claudecode.nvim — connects this nvim to the Claude Code CLI.
--
-- It reimplements, in pure Lua, the same WebSocket + MCP protocol the official
-- VS Code / JetBrains extensions speak. On start it runs a WebSocket server and
-- writes a lockfile under $CLAUDE_CONFIG_DIR/ide/ (or ~/.claude/ide/ if unset);
-- when the `claude` CLI launches (in the terminal split here, or any terminal in
-- this cwd) it reads that lockfile and connects. Once connected you get
-- selection/buffer context, in-editor diffs for Claude's proposed edits, and a
-- terminal split — all driven from nvim.
--
-- Requires the `claude` CLI and folke/snacks.nvim (already installed; claudecode
-- uses snacks.terminal as its terminal provider).
--
-- Profile wiring (see `init`/`opts` below): we run the personal profile, i.e.
-- ~/.local/bin/claude with CLAUDE_CONFIG_DIR=~/.claude-personal/ — the same as
-- the `claudep` alias. The bare `claude` command can't be used: it's aliased in
-- .zshrc to a no-op reminder, and shell aliases don't reach the process nvim
-- spawns anyway.
local switches = require("core.plugins")

-- The lockfile directory is computed from CLAUDE_CONFIG_DIR read out of *nvim's
-- own* environment (lockfile.lua does os.getenv at module load), while the CLI
-- child reads the profile from the same variable. Setting it here, in nvim's
-- env, is what makes both halves agree on ~/.claude-personal/ide/ — setting it
-- only on the spawned terminal would move the CLI but leave the lockfile in
-- ~/.claude/ide/, and the handshake would silently never happen. `init` runs at
-- startup, before the lazy-loaded plugin computes its lockfile path. Expanded to
-- an absolute path because a literal ~ in an env-var *value* isn't tilde-expanded
-- by the CLI (only the shell expands it for the alias).
local claude_config_dir = vim.fn.expand("~/.claude-personal")

return {
  "coder/claudecode.nvim",
  enabled = switches.enabled("claudecode"),
  dependencies = { "folke/snacks.nvim" },
  init = function()
    vim.env.CLAUDE_CONFIG_DIR = claude_config_dir
  end,
  opts = {
    -- Point straight at the binary; the profile comes from CLAUDE_CONFIG_DIR,
    -- which the terminal child inherits from nvim's env (set in `init`).
    terminal_cmd = vim.fn.expand("~/.local/bin/claude"),
  },
  -- Lazy-load: the plugin wakes on any of its commands or the keymaps below.
  cmd = {
    "ClaudeCode",
    "ClaudeCodeFocus",
    "ClaudeCodeSelectModel",
    "ClaudeCodeAdd",
    "ClaudeCodeSend",
    "ClaudeCodeTreeAdd",
    "ClaudeCodeStatus",
    "ClaudeCodeStart",
    "ClaudeCodeStop",
    "ClaudeCodeOpen",
    "ClaudeCodeClose",
    "ClaudeCodeDiffAccept",
    "ClaudeCodeDiffDeny",
    "ClaudeCodeCloseAllDiffs",
  },
  keys = {
    { "<leader>a", nil, desc = "AI/Claude Code" },
    { "<leader>ac", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude" },
    { "<leader>af", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude" },
    { "<leader>ar", "<cmd>ClaudeCode --resume<cr>", desc = "Resume Claude" },
    { "<leader>aC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude" },
    { "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Select Claude model" },
    { "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add current buffer" },
    -- Visual mode: send the selected lines as context.
    { "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send to Claude" },
    -- Same lhs in neo-tree: add the file under the cursor. The `ft` guard means
    -- this binding only exists in the tree, so it never shadows the visual one.
    { "<leader>as", "<cmd>ClaudeCodeTreeAdd<cr>", ft = "neo-tree", desc = "Add file to Claude" },
    -- Accept / reject Claude's proposed edit while its diff is open.
    { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
    { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Deny diff" },
  },
}
