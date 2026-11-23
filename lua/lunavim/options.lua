local opt = vim.opt

vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0

-- ts_context_commentstring is driven by the built-in `gc` (see lunavim.autocmds)
vim.g.skip_ts_context_commentstring_module = true

opt.backup = false
opt.swapfile = false
opt.undofile = true
opt.encoding = "utf-8"
opt.fileencoding = "utf-8"

opt.number = true
opt.relativenumber = true
opt.cursorline = false
opt.signcolumn = "yes"
opt.cmdheight = 2
opt.laststatus = 3
opt.showtabline = 2
opt.showmode = false
opt.termguicolors = true
opt.mouse = "a"
opt.scrolloff = 8
opt.wrap = true
opt.breakindent = true
opt.pumheight = 0
opt.list = true
opt.listchars = "eol:↲,tab:|->,lead:·,space: ,trail:•,extends:→,precedes:←,nbsp:␣"
opt.guicursor = {
  "n-v-c:block",
  "i-ci-ve:ver25",
  "r-cr:hor20",
  "o:hor50",
  "a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor",
  "sm:block-blinkwait175-blinkoff150-blinkon175",
}

opt.expandtab = true
opt.tabstop = 2
opt.softtabstop = 2
opt.shiftwidth = 2
opt.smartindent = true

opt.hlsearch = true
opt.incsearch = true
opt.ignorecase = true
opt.smartcase = true
opt.inccommand = "split"
opt.grepprg = "rg --vimgrep"
opt.grepformat = "%f:%l:%c:%m"

opt.splitbelow = true
opt.splitright = true
opt.timeoutlen = 200
opt.updatetime = 250
opt.completeopt = { "menuone", "noselect", "noinsert" }

-- Spell checking only for prose; see the FileType autocmd in lunavim.autocmds.
opt.spell = false
opt.spelllang = "en"

opt.foldcolumn = "0"
opt.foldenable = true
opt.foldlevel = 99
opt.foldlevelstart = 99
opt.foldmethod = "expr"
opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
opt.formatexpr = "v:lua.require'conform'.formatexpr()"

-- Neovide
if vim.g.neovide then
  local g = vim.g
  g.neovide_fullscreen = false
  g.neovide_hide_mouse_when_typing = false
  g.neovide_refresh_rate = 165
  g.neovide_cursor_vfx_mode = "ripple"
  g.neovide_cursor_animate_command_line = true
  g.neovide_cursor_animate_in_insert_mode = true
  g.neovide_cursor_vfx_particle_lifetime = 5.0
  g.neovide_cursor_vfx_particle_density = 14.0
  g.neovide_cursor_vfx_particle_speed = 12.0
  g.neovide_transparency = 0.8
  vim.o.guifont = "JetBrainsMono Nerd Font:h14:Medium:i"
end
