-- LSP, formatting and linting.
--
-- The same server list is used everywhere. The only difference is where the
-- binaries come from:
--   * Nix:     flake.nix puts them on PATH (lspsAndRuntimeDeps)
--   * Non-Nix: Mason downloads them and adds its bin dir to PATH
local nixUtils = require("nixCatsUtils")
local isNixCats = nixUtils.isNixCats

-- Mason package names to install when not on Nix.
local mason_tools = {
  -- LSPs
  "clangd",
  "eslint-lsp",
  "jdtls",
  "lua-language-server",
  "pyright",
  "ruff",
  "rust-analyzer",
  "typescript-language-server",
  -- formatters
  "stylua",
  "prettierd",
  "google-java-format",
  "black",
  -- linters
  "shellcheck",
  "cpplint",
  "eslint_d",
  "selene",
  "flake8",
  "checkstyle",
  -- debuggers
  "debugpy",
}

local inlay_hints = {
  includeInlayEnumMemberValueHints = true,
  includeInlayFunctionLikeReturnTypeHints = true,
  includeInlayFunctionParameterTypeHints = true,
  includeInlayParameterNameHints = "all",
  includeInlayParameterNameHintsWhenArgumentMatchesName = true,
  includeInlayPropertyDeclarationTypeHints = true,
  includeInlayVariableTypeHints = true,
  includeInlayVariableTypeHintsWhenTypeMatchesName = true,
}

local function servers()
  local s = {
    clangd = {},
    eslint = {},
    pyright = {},
    ruff = {},
    jdtls = {
      settings = { java = { signatureHelp = true, completion = true } },
    },
    lua_ls = {
      settings = {
        Lua = {
          completion = { callSnippet = "Replace" },
          diagnostics = { globals = { "vim", "nixCats" } },
          hint = { enable = true },
          telemetry = { enable = false },
        },
      },
    },
    rust_analyzer = {
      settings = {
        ["rust-analyzer"] = {
          checkOnSave = true,
          check = { command = "clippy" },
          procMacro = { enable = true },
        },
      },
    },
    ts_ls = {
      settings = {
        javascript = { inlayHints = inlay_hints },
        typescript = { inlayHints = inlay_hints },
      },
    },
  }
  if isNixCats then
    -- nixd only makes sense where Nix exists.
    s.nixd = {}
    -- nixpkgs' jdtls wrapper already picks a per-project workspace dir.
    s.jdtls.cmd = { "jdtls" }
  end
  return s
end

return {
  {
    "mason-org/mason.nvim",
    enabled = not isNixCats,
    lazy = true,
    opts = {},
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    enabled = not isNixCats,
    lazy = true,
    opts = { ensure_installed = mason_tools },
  },

  {
    "neovim/nvim-lspconfig",
    enabled = nixUtils.enableForCategory("lsp"),
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      if not isNixCats then
        -- Run Mason setup first so its bin dir is on PATH before servers start.
        require("mason").setup()
        require("mason-tool-installer").setup({ ensure_installed = mason_tools })
      end

      local capabilities = require("blink.cmp").get_lsp_capabilities()
      capabilities.offsetEncoding = { "utf-16" }

      local function bordered(handler)
        return function(err, result, ctx, config)
          handler(err, result, ctx, vim.tbl_extend("force", config or {}, { border = "rounded" }))
        end
      end

      vim.lsp.config("*", {
        capabilities = capabilities,
        handlers = {
          ["textDocument/hover"] = bordered(vim.lsp.handlers.hover),
          ["textDocument/signatureHelp"] = bordered(vim.lsp.handlers.signature_help),
        },
      })

      for name, cfg in pairs(servers()) do
        vim.lsp.config(name, cfg)
        vim.lsp.enable(name)
      end

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("lunavim_lsp_attach", { clear = true }),
        callback = function(event)
          local function map(lhs, rhs, desc)
            vim.keymap.set("n", lhs, rhs, { buffer = event.buf, silent = true, desc = desc })
          end
          -- Signature help: Neovim's built-in insert-mode <C-s>. (<C-k> in normal
          -- mode is left to vim-tmux-navigator.)
          map("<leader>cd", vim.diagnostic.open_float, "Line Diagnostics")
          map("<leader>ca", vim.lsp.buf.code_action, "Code Action")
          map("<leader>cr", vim.lsp.buf.rename, "Rename")
          map("<leader>cw", vim.lsp.buf.workspace_symbol, "Workspace Symbol")
          map("K", vim.lsp.buf.hover, "Hover")
          map("gD", vim.lsp.buf.declaration, "Goto Declaration")
          map("gI", vim.lsp.buf.implementation, "Goto Implementation")
          map("gT", vim.lsp.buf.type_definition, "Type Definition")
          map("gd", vim.lsp.buf.definition, "Goto Definition")
          map("gr", vim.lsp.buf.references, "Goto References")
        end,
      })
    end,
  },

  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    cmd = "ConformInfo",
    opts = {
      notify_on_error = true,
      format_on_save = function(bufnr)
        if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
          return
        end
        return { timeout_ms = 500, lsp_format = "fallback" }
      end,
      formatters_by_ft = (function()
        local prettier = { "prettierd", "prettier", stop_after_first = true }
        return {
          css = prettier,
          html = prettier,
          javascript = prettier,
          javascriptreact = prettier,
          typescript = prettier,
          typescriptreact = prettier,
          markdown = prettier,
          java = { "google-java-format" },
          lua = { "stylua" },
          nix = { "nixfmt" },
          python = { "black" },
          rust = { "rustfmt" },
        }
      end)(),
    },
  },

  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPost", "BufWritePost" },
    config = function()
      local lint = require("lint")
      lint.linters_by_ft = {
        bash = { "shellcheck" },
        sh = { "shellcheck" },
        c = { "cpplint" },
        cpp = { "cpplint" },
        go = { "golangci-lint" },
        haskell = { "hlint" },
        java = { "checkstyle" },
        javascript = { "eslint_d" },
        javascriptreact = { "eslint_d" },
        typescript = { "eslint_d" },
        typescriptreact = { "eslint_d" },
        lua = { "selene" },
        nix = { "statix" },
        python = { "flake8" },
      }
      vim.api.nvim_create_autocmd("BufWritePost", {
        group = vim.api.nvim_create_augroup("lunavim_lint", { clear = true }),
        callback = function()
          lint.try_lint(nil, { ignore_errors = true })
        end,
      })
    end,
  },

  { "folke/trouble.nvim", cmd = "Trouble", opts = { auto_close = true } },
}
