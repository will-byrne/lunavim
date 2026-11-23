-- Fuzzy finding, file trees, harpoon, sessions and terminals.
local lazyAdd = require("nixCatsUtils").lazyAdd

local fzf_build = vim.fn.has("win32") == 1
    and "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release"
  or "make"

return {
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    dependencies = {
      "plenary.nvim",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = lazyAdd(fzf_build),
        cond = lazyAdd(function()
          return vim.fn.executable(vim.fn.has("win32") == 1 and "cmake" or "make") == 1
        end, true),
      },
      "nvim-telescope/telescope-ui-select.nvim",
    },
    config = function()
      local telescope = require("telescope")
      telescope.setup({
        defaults = {
          mappings = {
            i = {
              ["<esc>"] = function(...)
                return require("telescope.actions").close(...)
              end,
            },
          },
        },
        pickers = { colorscheme = { enable_preview = true } },
        extensions = {
          fzf = {
            fuzzy = true,
            case_mode = "smart_case",
            override_file_sorter = true,
            override_generic_sorter = true,
          },
          ["ui-select"] = { specific_opts = { codeactions = true } },
        },
      })

      -- Extensions that live in other plugins must be loaded before
      -- telescope can find them.
      require("lazy").load({ plugins = { "harpoon2", "lazygit.nvim", "project.nvim", "todo-comments.nvim" } })
      for _, ext in ipairs({ "ui-select", "fzf", "harpoon", "lazygit", "projects", "todo-comments" }) do
        pcall(telescope.load_extension, ext)
      end
    end,
  },

  {
    "nvim-neo-tree/neo-tree.nvim",
    lazy = false,
    dependencies = { "plenary.nvim", "nui.nvim", "nvim-web-devicons" },
    opts = {
      close_if_last_window = true,
      enable_diagnostics = true,
      enable_git_status = true,
      enable_modified_markers = true,
      enable_refresh_on_write = true,
      popup_border_style = "rounded",
      buffers = { bind_to_cwd = false, follow_current_file = { enabled = true } },
      window = {
        width = 40,
        height = 15,
        auto_expand_width = false,
        mappings = { ["<space>"] = "none" },
      },
    },
  },

  {
    "stevearc/oil.nvim",
    cmd = "Oil",
    opts = {
      default_file_explorer = false,
      delete_to_trash = true,
      use_default_keymaps = true,
      view_options = { show_hidden = true },
      float = { padding = 2, max_width = 0, max_height = 0, border = "rounded", win_options = { winblend = 0 } },
      preview_win = { win_options = { winblend = 0 } },
      keymaps = {
        ["g?"] = "actions.show_help",
        ["<CR>"] = "actions.select",
        ["<C-\\>"] = "actions.select_vsplit",
        ["<C-enter>"] = "actions.select_split",
        ["<C-t>"] = "actions.select_tab",
        ["<C-p>"] = "actions.preview",
        ["<C-c>"] = "actions.close",
        ["<C-r>"] = "actions.refresh",
        ["-"] = "actions.parent",
        ["_"] = "actions.open_cwd",
        ["`"] = "actions.cd",
        ["~"] = "actions.tcd",
        ["gs"] = "actions.change_sort",
        ["gx"] = "actions.open_external",
        ["g."] = "actions.toggle_hidden",
        ["q"] = "actions.close",
      },
    },
  },

  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    name = "harpoon2",
    dependencies = { "plenary.nvim" },
    config = function()
      require("harpoon"):setup({})
    end,
    keys = {
      {
        "<leader>ha",
        function()
          require("harpoon"):list():add()
        end,
        desc = "Add file to Harpoon",
      },
      {
        "<C-e>",
        function()
          local harpoon = require("harpoon")
          harpoon.ui:toggle_quick_menu(harpoon:list())
        end,
        desc = "Harpoon menu",
      },
      -- <leader>1-4 instead of <C-j/k/l/m>: those clashed with tmux/window
      -- navigation, and <C-m> is the same key as <CR> in a terminal.
      {
        "<leader>1",
        function()
          require("harpoon"):list():select(1)
        end,
        desc = "Harpoon File 1",
      },
      {
        "<leader>2",
        function()
          require("harpoon"):list():select(2)
        end,
        desc = "Harpoon File 2",
      },
      {
        "<leader>3",
        function()
          require("harpoon"):list():select(3)
        end,
        desc = "Harpoon File 3",
      },
      {
        "<leader>4",
        function()
          require("harpoon"):list():select(4)
        end,
        desc = "Harpoon File 4",
      },
    },
  },

  {
    "DrKJeff16/project.nvim",
    name = "project.nvim",
    event = "VeryLazy",
    config = function()
      require("project").setup({})
    end,
  },

  { "christoomey/vim-tmux-navigator", lazy = false },
  { "folke/persistence.nvim", event = "BufReadPre", opts = {} },

  {
    "akinsho/toggleterm.nvim",
    cmd = { "ToggleTerm", "TermSelect", "ToggleTermSetName", "TermExec" },
    opts = {
      size = 10,
      direction = "float",
      float_opts = { border = "rounded" },
      shading_factor = 2,
      on_create = function(t)
        vim.opt_local.foldcolumn = "0"
        vim.opt_local.signcolumn = "no"
        if t.hidden then
          vim.keymap.set({ "n", "t", "i" }, "<F7>", function()
            t:toggle()
          end, { desc = "Toggle terminal", buffer = t.bufnr })
        end
      end,
      highlights = {
        Normal = { link = "Normal" },
        NormalNC = { link = "NormalNC" },
        NormalFloat = { link = "NormalFloat" },
        FloatBorder = { link = "FloatBorder" },
        StatusLine = { link = "StatusLine" },
        StatusLineNC = { link = "StatusLineNC" },
        WinBar = { link = "WinBar" },
        WinBarNC = { link = "WinBarNC" },
      },
    },
  },
}
