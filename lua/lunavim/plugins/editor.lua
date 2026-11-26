-- Treesitter and general editing plugins.
local lazyAdd = require("nixCatsUtils").lazyAdd
local isNixCats = require("nixCatsUtils").isNixCats

-- Parsers to install when NOT on Nix. On Nix every grammar comes from
-- nvim-treesitter.withAllGrammars in flake.nix.
local parsers = {
  "bash",
  "c",
  "css",
  "html",
  "java",
  "javascript",
  "jsdoc",
  "json",
  "lua",
  "luadoc",
  "luap",
  "markdown",
  "markdown_inline",
  "nix",
  "python",
  "query",
  "regex",
  "rust",
  "toml",
  "tsx",
  "typescript",
  "vim",
  "vimdoc",
  "yaml",
}

return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = lazyAdd(":TSUpdate"),
    config = function()
      require("nvim-treesitter").setup({})
      if not isNixCats then
        -- Needs the `tree-sitter` CLI and a C compiler (see README).
        require("nvim-treesitter").install(parsers)
      end
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("lunavim_treesitter", { clear = true }),
        callback = function(args)
          local lang = vim.treesitter.language.get_lang(args.match) or args.match
          if pcall(vim.treesitter.start, args.buf, lang) then
            vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("nvim-treesitter-textobjects").setup({
        select = { lookahead = true },
        move = { set_jumps = true },
      })

      local select = require("nvim-treesitter-textobjects.select")
      for key, query in pairs({
        aa = "@parameter.outer",
        ia = "@parameter.inner",
        af = "@function.outer",
        ["if"] = "@function.inner",
        ac = "@class.outer",
        ic = "@class.inner",
        ai = "@conditional.outer",
        ii = "@conditional.inner",
        al = "@loop.outer",
        il = "@loop.inner",
        at = "@comment.outer",
      }) do
        vim.keymap.set({ "x", "o" }, key, function()
          select.select_textobject(query, "textobjects")
        end, { desc = "Select " .. query })
      end

      local move = require("nvim-treesitter-textobjects.move")
      local moves = {
        goto_next_start = { ["]m"] = "@function.outer", ["]]"] = "@class.outer" },
        goto_next_end = { ["]M"] = "@function.outer", ["]["] = "@class.outer" },
        goto_previous_start = { ["[m"] = "@function.outer", ["[["] = "@class.outer" },
        goto_previous_end = { ["[M"] = "@function.outer", ["[]"] = "@class.outer" },
      }
      for fn, maps in pairs(moves) do
        for key, query in pairs(maps) do
          vim.keymap.set({ "n", "x", "o" }, key, function()
            move[fn](query, "textobjects")
          end, { desc = fn:gsub("_", " ") .. " " .. query })
        end
      end

      local swap = require("nvim-treesitter-textobjects.swap")
      vim.keymap.set("n", "<leader>cs", function()
        swap.swap_next("@parameter.inner")
      end, { desc = "Swap with next parameter" })
      vim.keymap.set("n", "<leader>cS", function()
        swap.swap_previous("@parameter.inner")
      end, { desc = "Swap with previous parameter" })
    end,
  },

  { "nvim-treesitter/nvim-treesitter-context", event = "BufReadPost", opts = {} },
  -- Used by the built-in `gc` commenting (see lunavim.autocmds).
  { "JoosepAlviste/nvim-ts-context-commentstring", lazy = true, opts = { enable_autocmd = false } },
  { "windwp/nvim-ts-autotag", event = { "BufReadPre", "BufNewFile" }, opts = {} },

  {
    "echasnovski/mini.nvim",
    name = "mini.nvim",
    event = "VeryLazy",
    config = function()
      require("mini.cursorword").setup({ delay = 100 })
    end,
  },

  { "kylechui/nvim-surround", event = "VeryLazy", opts = {} },
  { "windwp/nvim-autopairs", event = "InsertEnter", opts = {} },

  {
    "max397574/better-escape.nvim",
    event = "InsertEnter",
    opts = {
      timeout = 200,
      default_mappings = false,
      mappings = {
        i = { j = { j = "<Esc>", k = "<Esc>" } },
        c = { j = { j = "<Esc>", k = "<Esc>" } },
        v = { j = { k = "<Esc>" } },
        s = { j = { k = "<Esc>" } },
      },
    },
  },

  { "folke/todo-comments.nvim", event = "VeryLazy", opts = {} },

  {
    "mbbill/undotree",
    cmd = { "UndotreeToggle", "UndotreeShow", "UndotreeFocus", "UndotreeHide" },
    init = function()
      vim.g.undotree_autoOpenDiff = true
      vim.g.undotree_focusOnToggle = true
    end,
  },

  { "catgoose/nvim-colorizer.lua", event = "VeryLazy", opts = {} },

  {
    "laytan/cloak.nvim",
    lazy = false,
    opts = {
      cloak_character = "*",
      highlight_group = "Comment",
      patterns = { { file_pattern = { ".env*", "wrangler.toml", ".dev.vars" }, cloak_pattern = "=.+" } },
    },
  },

  {
    -- Renders headings, tables, code blocks, etc. in the buffer; raw text in insert mode.
    -- markview lazy-loads itself, so it should not be lazy-loaded by lazy.nvim.
    "OXY2DEV/markview.nvim",
    lazy = false,
    dependencies = { "nvim-treesitter/nvim-treesitter" },
  },

  {
    -- Shows virtual-text hints for the motions available from the cursor (w, b, e, $, ^, ...).
    "tris203/precognition.nvim",
    event = "VeryLazy",
    opts = {
      highlightColor = { link = "Comment" },
      targetedMotionHints = { enabled = false },
    },
    keys = {
      {
        "<leader>up",
        function()
          require("precognition").toggle()
        end,
        desc = "Toggle Motion Hints (precognition)",
      },
    },
  },
}
