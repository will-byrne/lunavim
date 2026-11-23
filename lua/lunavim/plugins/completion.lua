local lazyAdd = require("nixCatsUtils").lazyAdd

return {
  {
    "L3MON4D3/LuaSnip",
    name = "luasnip",
    lazy = true,
    build = lazyAdd((function()
      if vim.fn.has("win32") == 1 or vim.fn.executable("make") == 0 then
        return
      end
      return "make install_jsregexp"
    end)()),
    dependencies = { "rafamadriz/friendly-snippets" },
    config = function()
      require("luasnip").config.setup({ enable_autosnippets = true, store_selection_keys = "<Tab>" })
      require("luasnip.loaders.from_vscode").lazy_load()
    end,
  },
  { "rafamadriz/friendly-snippets", lazy = true },

  {
    "saghen/blink.cmp",
    name = "blink.cmp",
    -- Release tags ship a prebuilt fuzzy matcher, so non-Nix machines don't
    -- need a Rust toolchain. On Nix the package is already built.
    version = "1.*",
    event = { "InsertEnter", "CmdlineEnter" },
    dependencies = { "luasnip" },
    opts = {
      snippets = { preset = "luasnip" },
      keymap = {
        preset = "none",
        ["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
        ["<C-e>"] = { "cancel", "fallback" },
        ["<CR>"] = { "accept", "fallback" },
        ["<S-CR>"] = { "accept", "fallback" },
        ["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
        ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
        ["<C-j>"] = { "select_next", "fallback" },
        ["<C-k>"] = { "select_prev", "fallback" },
        ["<C-b>"] = { "scroll_documentation_up", "fallback" },
        ["<C-f>"] = { "scroll_documentation_down", "fallback" },
      },
      completion = {
        -- Like the old cmp setup: nothing is selected until you pick it,
        -- so <CR> only accepts after <Tab>/<C-j>.
        list = { max_items = 30, selection = { preselect = false, auto_insert = false } },
        menu = { border = "rounded" },
        documentation = { auto_show = true, auto_show_delay_ms = 200, window = { border = "rounded" } },
        ghost_text = { enabled = true },
      },
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
        providers = {
          buffer = { min_keyword_length = 5 },
          snippets = { min_keyword_length = 3 },
        },
      },
      cmdline = {
        keymap = { preset = "cmdline" },
        completion = { menu = { auto_show = true } },
      },
      fuzzy = { implementation = "prefer_rust_with_warning" },
    },
  },
}
