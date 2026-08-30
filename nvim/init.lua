
-- Core (non-plugin) configuration.
require("core.options")
require("core.keymaps")
require("core.autocmds")

-- Bootstrap lazy.nvim.
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"--branch=stable",
		"https://github.com/folke/lazy.nvim.git",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

-- Load every spec under lua/plugins/. Nothing but the colorscheme and core
-- options load eagerly; each plugin declares its own lazy trigger.
require("lazy").setup({
	spec = { { import = "plugins" } },
	install = { colorscheme = { "onedark" } },
	checker = { enabled = false },
	change_detection = { notify = false },
	ui = { border = "rounded" },
})
