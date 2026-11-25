-- Small helpers, user commands and autocommands that aren't tied to one plugin.
_G.LunaVim = _G.LunaVim or {}

local function notify(message, title)
  vim.notify(message, vim.log.levels.INFO, { title = title })
end

-- Formatting toggles ---------------------------------------------------------
-- Autoformat starts disabled; use :FormatToggle or :FormatToggle! to enable it.
vim.g.disable_autoformat = true

local function in_nixpkgs()
  return vim.fn.getcwd():match("nixpkgs$") ~= nil
end

vim.api.nvim_create_autocmd("BufReadPost", {
  callback = function()
    if in_nixpkgs() then
      vim.b.disable_autoformat = true
      notify("Autoformat-on-save disabled for nixpkgs", "conform.nvim")
    end
  end,
})

vim.api.nvim_create_user_command("FormatToggle", function(args)
  if not args.bang then
    vim.g.disable_autoformat = not vim.g.disable_autoformat
    notify(
      "Autoformat-on-save " .. (vim.g.disable_autoformat and "disabled" or "enabled") .. " globally",
      "conform.nvim"
    )
  else
    vim.b.disable_autoformat = not vim.b.disable_autoformat
    local scope = in_nixpkgs() and "for nixpkgs" or "for this buffer"
    notify("Autoformat-on-save " .. (vim.b.disable_autoformat and "disabled " or "enabled ") .. scope, "conform.nvim")
  end
end, { desc = "Toggle autoformat-on-save", bang = true })

-- UI toggles -----------------------------------------------------------------
function LunaVim.toggle_line_number()
  if vim.wo.number then
    vim.wo.number = false
    notify("Line numbers disabled", "Toggle")
  else
    vim.wo.number = true
    vim.wo.relativenumber = false
    notify("Line numbers enabled", "Toggle")
  end
end

function LunaVim.toggle_relative_line_number()
  if vim.wo.relativenumber then
    vim.wo.relativenumber = false
    notify("Relative line numbers disabled", "Toggle")
  else
    vim.wo.relativenumber = true
    vim.wo.number = false
    notify("Relative line numbers enabled", "Toggle")
  end
end

function LunaVim.toggle_wrap()
  vim.wo.wrap = not vim.wo.wrap
  notify(vim.wo.wrap and "Wrap enabled" or "Wrap disabled", "Toggle")
end

function LunaVim.toggle_inlay_hints()
  local is_enabled = vim.lsp.inlay_hint.is_enabled()
  vim.lsp.inlay_hint.enable(not is_enabled)
  notify(is_enabled and "Inlay Hints disabled" or "Inlay Hints enabled", "Toggle")
end

-- Spelling -------------------------------------------------------------------
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("lunavim_spell", { clear = true }),
  pattern = { "markdown", "gitcommit", "text", "tex", "plaintex", "rst", "asciidoc" },
  callback = function()
    vim.opt_local.spell = true
  end,
})

-- Markdown: markview can't draw tables in wrapped windows (it falls back to raw pipes).
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("lunavim_markdown_nowrap", { clear = true }),
  pattern = "markdown",
  callback = function()
    vim.opt_local.wrap = false
  end,
})

-- Diagnostics ----------------------------------------------------------------
vim.diagnostic.config({
  float = { border = "rounded" },
  virtual_text = { prefix = "" },
  signs = true,
  underline = true,
  update_in_insert = false,
})

-- Commenting -----------------------------------------------------------------
-- Neovim's built-in `gc` commenting, made aware of embedded languages
-- (JSX, Vue, Svelte, Lua inside Nix, ...) via ts_context_commentstring.
local get_option = vim.filetype.get_option
---@diagnostic disable-next-line: duplicate-set-field
vim.filetype.get_option = function(filetype, option)
  if option == "commentstring" then
    local ok, internal = pcall(require, "ts_context_commentstring.internal")
    local cs = ok and internal.calculate_commentstring() or nil
    if cs then
      return cs
    end
  end
  return get_option(filetype, option)
end
