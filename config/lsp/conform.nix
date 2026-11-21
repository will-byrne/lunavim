{
  lib,
  config,
  pkgs,
  ...
}:
{
  options = {
    conform.enable = lib.mkEnableOption "Enable conform module";
  };
  config = lib.mkIf config.conform.enable {

    extraPackages = with pkgs; [
      black
      google-java-format
      rustfmt
    ];

    extraConfigLua = ''
      -- Start with autoformat disabled; use :FormatToggle or :FormatToggle! to enable it.
      vim.g.disable_autoformat = true

      local function format_notify(message)
        vim.notify(message, vim.log.levels.INFO, { title = "conform.nvim" })
      end

      local function in_nixpkgs()
        return vim.fn.getcwd():match("nixpkgs$") ~= nil
      end

      vim.api.nvim_create_autocmd("BufReadPost", {
        callback = function()
          if in_nixpkgs() then
            vim.b.disable_autoformat = true
            format_notify("Autoformat-on-save disabled for nixpkgs")
          end
        end,
      })

      vim.api.nvim_create_user_command("FormatToggle", function(args)
        if not args.bang then
          vim.g.disable_autoformat = not vim.g.disable_autoformat
          format_notify("Autoformat-on-save " .. (vim.g.disable_autoformat and "disabled" or "enabled") .. " globally")
        else
          vim.b.disable_autoformat = not vim.b.disable_autoformat
          local scope = in_nixpkgs() and "for nixpkgs" or "for this buffer"
          format_notify("Autoformat-on-save " .. (vim.b.disable_autoformat and "disabled " or "enabled ") .. scope)
        end
      end, {
        desc = "Toggle autoformat-on-save",
        bang = true,
      })
    '';

    plugins.conform-nvim = {
      enable = true;
      settings = {
        notify_on_error = true;
        # default_format_opts = {
        #   lsp_format = "fallback";
        # };
        # format_after_save = {
        #   lsp_format = "fallback";
        # };
        format_on_save = ''
          function(bufnr)
            -- Disable with a global or buffer-local variable
            if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
              return
            end
            return { timeout_ms = 500, lsp_format = 'fallback' }
          end
        '';
        formatters_by_ft = {
          html = {
            __unkeyed-1 = "prettierd";
            __unkeyed-2 = "prettier";
            stop_after_first = true;
          };
          css = {
            __unkeyed-1 = "prettierd";
            __unkeyed-2 = "prettier";
            stop_after_first = true;
          };
          javascript = {
            __unkeyed-1 = "prettierd";
            __unkeyed-2 = "prettier";
            stop_after_first = true;
          };
          javascriptreact = {
            __unkeyed-1 = "prettierd";
            __unkeyed-2 = "prettier";
            stop_after_first = true;
          };
          typescript = {
            __unkeyed-1 = "prettierd";
            __unkeyed-2 = "prettier";
            stop_after_first = true;
          };
          typescriptreact = {
            __unkeyed-1 = "prettierd";
            __unkeyed-2 = "prettier";
            stop_after_first = true;
          };
          java = [ "google-java-format" ];
          python = [ "black" ];
          lua = [ "stylua" ];
          nix = [ "nixfmt" ];
          markdown = {
            __unkeyed-1 = "prettierd";
            __unkeyed-2 = "prettier";
            stop_after_first = true;
          };
          rust = [ "rustfmt" ];
        };
      };
    };

    keymaps = [
      {
        mode = "n";
        key = "<leader>uf";
        action = ":FormatToggle<CR>";
        options = {
          desc = "Toggle Format Globally";
          silent = true;
        };
      }
      {
        mode = "n";
        key = "<leader>uF";
        action = ":FormatToggle!<CR>";
        options = {
          desc = "Toggle Format Locally";
          silent = true;
        };
      }
      {
        mode = "n";
        key = "<leader>cf";
        action = "<cmd>lua require('conform').format()<cr>";
        options = {
          silent = true;
          desc = "Format Buffer";
        };
      }

      {
        mode = "v";
        key = "<leader>cF";
        action = "<cmd>lua require('conform').format()<cr>";
        options = {
          silent = true;
          desc = "Format Lines";
        };
      }
    ];
  };
}
