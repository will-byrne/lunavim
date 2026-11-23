-- Colorscheme, dashboard, statusline, bufferline and other visual plugins.
--
-- A note on `name = ...`: on Nix, lazy.nvim finds each plugin in the Nix store
-- by its directory name, which is the nixpkgs pname. When that differs from the
-- repo name, the spec sets `name` to the nixpkgs name.

local function alpha_button(shortcut, text, action)
  local on_press = type(action) == "function" and action or function()
    vim.cmd(action)
  end
  return {
    type = "button",
    val = text,
    on_press = on_press,
    opts = {
      position = "center",
      shortcut = shortcut,
      cursor = 3,
      width = 38,
      align_shortcut = "right",
      hl_shortcut = "Keyword",
      keymap = { "n", shortcut, "", { noremap = true, silent = true, nowait = true, callback = on_press } },
    },
  }
end

return {
  { "nvim-lua/plenary.nvim", lazy = true },
  { "MunifTanjim/nui.nvim", lazy = true },
  { "nvim-neotest/nvim-nio", lazy = true },
  { "nvim-tree/nvim-web-devicons", lazy = true, opts = {} },

  {
    "catppuccin/nvim",
    name = "catppuccin-nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        flavour = "macchiato",
        background = { dark = "macchiato", light = "macchiato" },
        transparent_background = true,
        term_colors = true,
        integrations = {
          blink_cmp = true,
          dropbar = { enabled = true },
          gitsigns = true,
          harpoon = true,
          illuminate = { enabled = true },
          indent_blankline = { enabled = true },
          mini = { enabled = true },
          native_lsp = {
            enabled = true,
            inlay_hints = { background = true },
            underlines = {
              errors = { "underline" },
              hints = { "underline" },
              information = { "underline" },
              warnings = { "underline" },
            },
          },
          neotree = true,
          noice = true,
          notify = true,
          telescope = { enabled = true },
          treesitter = true,
          treesitter_context = true,
          which_key = true,
        },
      })
      vim.env.BAT_THEME = "catppuccin"
      vim.cmd.colorscheme("catppuccin")
    end,
  },

  {
    "rcarriga/nvim-notify",
    lazy = false,
    priority = 900,
    config = function()
      local notify = require("notify")
      notify.setup({
        background_colour = "#000000",
        fps = 60,
        render = "default",
        timeout = 500,
        top_down = true,
      })

      local filtered_messages = { ["No information available"] = true }
      ---@diagnostic disable-next-line: duplicate-set-field
      vim.notify = function(message, level, opts)
        if filtered_messages[message] then
          return
        end
        local merged = vim.tbl_extend("force", {
          on_open = function(win)
            vim.bo[vim.api.nvim_win_get_buf(win)].filetype = "markdown"
          end,
        }, opts or {})
        return notify(message, level, merged)
      end
    end,
  },

  {
    "goolord/alpha-nvim",
    event = "VimEnter",
    config = function()
      require("alpha").setup({
        layout = {
          { type = "padding", val = 2 },
          {
            type = "text",
            opts = { hl = "AlphaHeader", position = "center" },
            val = {
              "            ⠲⣶⡶⠶⠦⢤⣄⡀          ⠂                                ",
              "              ⠙⢦   ⠙⠳⣄                                        ⠄",
              "               ⠈⢷⡀   ⠈⢳⡄                  ⠴⣄    ⣀⣀⣀⠤⣤⣄         ",
              "                ⠈⣇     ⢻⡄   ⠁            ⣏ ⠋  ⢀⣨⡭⠽⠿⢯⡛⢿⡑⢦⡀      ",
              "                 ⣿      ⣧                ⠘⢦⡤⠤⢖⣉⣁⣀   ⠙⡄⠱⡀⠹⡄     ",
              "                 ⡟      ⣿           ⣀   ⢀⠜⣁⠴⠚⠉⣁⣀⡀⠑⡀    ⡇ ⠹⡄    ",
              "                ⡼⠁      ⡟          ⢺⠉⠃ ⢠⡿⠚⣁⣤⠞⠉⣠⠤⠬⣷⡀    ⠇ ⢀⣷    ",
              "              ⢀⡾⠁      ⣼⠃           ⠙⠒⣲⠟⠓⠋⣵⠋  ⠈⠁ ⠈⢧      ⡼ ⣇   ",
              "          ⢀⣀⡤⠞⠉      ⢀⡼⠃          ⠶⠤⠤⠖⢡⠶⣄⡜⠁     ⠰⠖⣾     ⡜  ⢸   ",
              "       ⠘⢿⣏⠉⠁       ⣠⡴⠋        ⠠        ⠉⠁         ⡏    ⠊   ⢸   ",
              "         ⠈⠙⠓⠶⠶⠶⠶⠖⠚⠋⠁                            ⣠⠞         ⡸   ",
              "                                              ⡠⠊⠁       ⢀⣠⠴⠛⣉⡗ ",
              "                                            ⣠⠞⠁       ⢰⠋⣡⡶⠛⠉⠁  ",
              "      ⠂                                    ⢠⠇   ⢀⣠⠤⢤⣤⣤⡾ ⣏⣄     ",
              "                                           ⡾   ⠰⠛⠉⠉⠉⠛⠉  ⣿ ⡆    ",
              "                                           ⢧        ⢀⣤⠖⠚⡟⡆⢿    ",
              "                    ⠁                      ⠘⣆     ⢀⣾⣍⣀ ⣸⠇⢹⠈⢦   ",
              "                                            ⠘⢦⡀   ⠈⠸⡄⠈⠉⠁  ⢣⣠⠃  ",
              "                                      ⣰⢷⡀     ⠹⣆    ⢳          ",
              "                                      ⢻ ⠉⠍⠳⠤⠤⠤⢶⡄⣇    ⢱⡀        ",
              "            ⠂                          ⢷⡀    ⡴⠋ ⢹     ⣇        ",
              "                                        ⢇⣀⣀⣴⡄⠉⠲⠶⠚     ⢸        ",
              "                                        ⠸⡄⠈⠉          ⣸        ",
              "                                         ⢹⡄    ⢠     ⡴⠃        ",
              "                          ⠈               ⣙⡶⣄ ⢀⡘⣆  ⣶⠞          ",
              "                                    ⣠⠶⠒⠒⠋⠉⠁ ⠈⣹⠻⠏⣻⠇ ⢘⡇          ",
              "                                   ⣼⣥⡶⠋⠉⠉⠉⠉⠉⠉⠁⢠⡞⠁⣠⡶⠋           ",
              "                                   ⠈⠉        ⢠⠏⣠⠞⠁             ",
              "                                            ⢠⠏⣼⠃               ",
              "                                            ⣈ ⡇                ",
              "                                            ⠿⠟⠁                ",
              "                                                               ",
              "               git@github.com:will-byrne/lunavim               ",
            },
          },
          { type = "padding", val = 2 },
          alpha_button("f", "   Find File", "Telescope find_files"),
          { type = "padding", val = 1 },
          alpha_button("n", "   New File", "ene | startinsert"),
          { type = "padding", val = 1 },
          alpha_button("r", "󰈚  Recent Files", "Telescope oldfiles"),
          { type = "padding", val = 1 },
          alpha_button("g", "󰈭  Find Word", "Telescope live_grep"),
          { type = "padding", val = 1 },
          alpha_button("s", "   Restore Session", function()
            require("persistence").load()
          end),
          { type = "padding", val = 1 },
          alpha_button("q", "   Quit Neovim", "qa"),
        },
      })
    end,
  },

  -- Breadcrumbs winbar (path > class > function), replaces the archived barbecue.nvim.
  {
    "Bekaboo/dropbar.nvim",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "nvim-web-devicons" },
    opts = {},
  },

  {
    "akinsho/bufferline.nvim",
    lazy = false,
    dependencies = { "nvim-web-devicons" },
    opts = {
      options = {
        separator_style = "thick",
        offsets = {
          { filetype = "neo-tree", text = "Neo-tree", highlight = "Directory", text_align = "left" },
        },
      },
    },
  },

  {
    "nvim-lualine/lualine.nvim",
    lazy = false,
    opts = {
      options = {
        theme = "auto",
        globalstatus = true,
        always_divide_middle = true,
        ignore_focus = { "neo-tree" },
        component_separators = { left = "|", right = "|" },
        section_separators = { left = "█", right = "█" },
      },
      extensions = { "fzf" },
      sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch", "diff", "diagnostics" },
        lualine_c = { "filename" },
        lualine_x = { "filetype" },
        lualine_y = { "progress" },
        lualine_z = {
          function()
            return " " .. os.date("%R")
          end,
        },
      },
    },
  },

  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = "VeryLazy",
    opts = {
      indent = { char = "│" },
      scope = { enabled = true, show_start = true },
      exclude = {
        buftypes = { "terminal", "nofile" },
        filetypes = {
          "help",
          "alpha",
          "dashboard",
          "neo-tree",
          "Trouble",
          "trouble",
          "lazy",
          "mason",
          "notify",
          "toggleterm",
          "lazyterm",
          "nvterm",
        },
      },
    },
  },

  {
    "j-hui/fidget.nvim",
    event = "VeryLazy",
    opts = {
      progress = {
        suppress_on_insert = true,
        display = { done_icon = "✔", overrides = { rust_analyzer = { name = "rust-analyzer" } } },
      },
      notification = {
        override_vim_notify = false,
        window = { winblend = 0, border = "none" },
        redirect = function(msg, level, opts)
          if opts and opts.on_open then
            return require("fidget.integration.nvim-notify").delegate(msg, level, opts)
          end
        end,
      },
    },
  },

  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      icons = { breadcrumb = "»", group = "+", separator = "" },
      win = { border = "none", wo = { winblend = 0 } },
      spec = {
        { "<leader>h", group = "+harpoon", icon = "󱡁" },
        { "<leader>ha", desc = "Add file to Harpoon" },
        { "<leader>c", group = "+code", mode = { "n", "v" } },
        { "<leader>d", group = "+debug", mode = { "n", "v" } },
        { "<leader>f", group = "+find/file" },
        { "<leader>g", group = "+git", mode = { "n", "v" } },
        { "<leader>gh", group = "+hunks", mode = { "n", "v" } },
        { "<leader>a", desc = "Open Alpha dashboard", icon = "󰀫" },
        { "<leader>b", group = "+buffer" },
        { "<leader>q", group = "+quit/session" },
        { "<leader>s", group = "+search" },
        { "<leader><Tab>", group = "+tab" },
        { "<leader>t", group = "+term", icon = "󰀫" },
        { "<leader>T", group = "+test" },
        { "<leader>u", group = "+ui" },
        { "<leader>w", group = "+windows" },
        { "<leader>x", group = "+diagnostics/quickfix" },
      },
    },
  },
}
