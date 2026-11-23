-- LunaVim entry point.
--
-- On Nix, the nixCats flake wraps neovim around this directory and provides
-- every plugin and tool. Anywhere else (macOS, Windows, a Linux box without
-- Nix), clone this repo into your nvim config dir and lazy.nvim + Mason
-- download what is needed on first start.

-- Without Nix this creates a stand-in `nixCats` module, so nixCats('cat')
-- calls return true and every category is on.
require("nixCatsUtils").setup({ non_nix_value = true })

vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("lunavim.options")
require("lunavim.keymaps")
require("lunavim.autocmds")

local isNixCats = require("nixCatsUtils").isNixCats

require("nixCatsUtils.lazyCat").setup(nixCats.pawsible({ "allPlugins", "start", "lazy.nvim" }), {
  { import = "lunavim.plugins" },
}, {
  -- On Nix the config dir is a read-only store path, so keep the lockfile in data.
  lockfile = isNixCats and (vim.fn.stdpath("data") .. "/lazy-lock.json") or nil,
  install = { colorscheme = { "catppuccin" } },
  change_detection = { notify = false },
  checker = { enabled = false },
  rocks = { enabled = false },
})
