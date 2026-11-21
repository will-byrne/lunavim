{ lib, config, ... }:
{
  options = {
    nvim-lint.enable = lib.mkEnableOption "Enable nvim-lint module";
  };
  config = lib.mkIf config.nvim-lint.enable {
    plugins.lint = {
      enable = true;
      # Install the linters listed below. Go/Haskell linters need their whole
      # toolchain, so they are left to the project environment (e.g. a devShell).
      autoInstall = {
        enable = true;
        overrides = {
          golangci-lint = null;
          hlint = null;
        };
      };
      # Don't error when a linter isn't on PATH (e.g. golangci-lint outside a Go devShell).
      autoCmd.callback.__raw = ''
        function()
          require("lint").try_lint(nil, { ignore_errors = true })
        end
      '';
      lintersByFt = {
        c = [ "cpplint" ];
        cpp = [ "cpplint" ];
        go = [ "golangci-lint" ];
        nix = [ "statix" ];
        lua = [ "selene" ];
        python = [ "flake8" ];
        javascript = [ "eslint_d" ];
        javascriptreact = [ "eslint_d" ];
        typescript = [ "eslint_d" ];
        typescriptreact = [ "eslint_d" ];
        java = [ "checkstyle" ];
        haskell = [ "hlint" ];
        bash = [ "shellcheck" ];
        sh = [ "shellcheck" ];
      };
    };
  };
}
