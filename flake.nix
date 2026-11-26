{
  description = "LunaVim: a Neovim config in plain Lua, packaged with nixCats so it runs with or without Nix";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixCats.url = "github:BirdeeHub/nixCats-nvim";
  };

  # How this fits together:
  #   * All editor configuration lives in Lua (init.lua + lua/lunavim/**).
  #   * On Nix, this flake provides every plugin, LSP, formatter and linter,
  #     and lazy.nvim is pointed at the Nix store instead of downloading.
  #   * Without Nix (macOS / Windows), clone this repo into your nvim config
  #     dir; lazy.nvim downloads plugins and Mason installs the tools.
  # See :help nixCats for the full documentation.
  outputs =
    {
      self,
      nixpkgs,
      nixCats,
      ...
    }@inputs:
    let
      inherit (nixCats) utils;
      luaPath = ./.;
      forEachSystem = utils.eachSystem nixpkgs.lib.platforms.all;
      extra_pkg_config = {
        allowUnfree = true;
      };
      dependencyOverlays = [ (utils.standardPluginOverlay inputs) ];

      # Categories are named groups of dependencies. A package turns
      # categories on or off, and the Lua side can query them with
      # nixCats('<category>') (see lua/lunavim/plugins/*.lua).
      categoryDefinitions =
        { pkgs, ... }:
        {
          lspsAndRuntimeDeps = with pkgs; {
            general = [
              ripgrep
              fd
              git
              bat
              lazygit
            ]
            ++ lib.optional stdenv.isLinux wl-clipboard;

            lsp = [
              clang-tools
              vscode-langservers-extracted
              jdt-language-server
              lua-language-server
              nixd
              pyright
              ruff
              rust-analyzer
              typescript-language-server
            ];

            format = [
              nixfmt
              stylua
              prettierd
              google-java-format
              black
              rustfmt
            ];

            lint = [
              shellcheck
              cpplint
              checkstyle
              eslint_d
              selene
              statix
              python3Packages.flake8
            ];

            test = [
              rustc
              cargo
            ];
          };

          # lazy.nvim decides when each plugin loads, so everything can sit in
          # startupPlugins. Directory names here must match the `name` lazy.nvim
          # uses in the Lua specs. That is why some specs set `name = ...`.
          startupPlugins = with pkgs.vimPlugins; {
            general = [
              lazy-nvim
              plenary-nvim
              nui-nvim
              nvim-web-devicons
              nvim-nio

              # ui
              catppuccin-nvim
              alpha-nvim
              dropbar-nvim
              bufferline-nvim
              lualine-nvim
              nvim-notify
              indent-blankline-nvim
              fidget-nvim
              which-key-nvim

              # editing
              nvim-treesitter.withAllGrammars
              nvim-treesitter-textobjects
              nvim-treesitter-context
              nvim-ts-context-commentstring
              nvim-ts-autotag
              mini-nvim
              nvim-surround
              nvim-autopairs
              better-escape-nvim
              todo-comments-nvim
              undotree
              nvim-colorizer-lua
              cloak-nvim
              precognition-nvim

              # navigation
              telescope-nvim
              telescope-fzf-native-nvim
              telescope-ui-select-nvim
              neo-tree-nvim
              oil-nvim
              harpoon2
              project-nvim
              vim-tmux-navigator
              persistence-nvim
              toggleterm-nvim

              # git
              gitsigns-nvim
              lazygit-nvim
              diffview-nvim

              # completion
              blink-cmp
              luasnip
              friendly-snippets

              markview-nvim
            ];

            lsp = [
              nvim-lspconfig
              conform-nvim
              nvim-lint
              trouble-nvim
            ];

            debug = [
              nvim-dap
              nvim-dap-ui
              nvim-dap-virtual-text
              nvim-dap-python
            ];

            test = [
              neotest
              neotest-java
              neotest-plenary
              neotest-python
              neotest-vitest
            ];
          };
        };

      packageDefinitions = {
        nvim =
          { pkgs, ... }:
          {
            settings = {
              wrapRc = true;
              suffix-path = true;
              suffix-LD = true;
              aliases = [
                "vim"
                "lunavim"
              ];
              hosts.python3.enable = true;
              hosts.node.enable = false;
            };
            categories = {
              general = true;
              lsp = true;
              format = true;
              lint = true;
              debug = true;
              test = true;
            };
            # Arbitrary values readable from Lua via nixCats.extra('<key>').
            extra = {
              debugpyPython = "${pkgs.python3.withPackages (ps: [ ps.debugpy ])}/bin/python3";
            };
          };
      };
      defaultPackageName = "nvim";
    in
    forEachSystem (
      system:
      let
        nixCatsBuilder = utils.baseBuilder luaPath {
          inherit
            nixpkgs
            system
            dependencyOverlays
            extra_pkg_config
            ;
        } categoryDefinitions packageDefinitions;
        defaultPackage = nixCatsBuilder defaultPackageName;
        pkgs = import nixpkgs { inherit system; };
      in
      {
        # `nix run .` starts LunaVim
        packages = utils.mkAllWithDefault defaultPackage;

        # `nix flake check` starts nvim headless and fails on any startup error
        checks.default = pkgs.runCommand "lunavim-startup-check" { } ''
          export HOME=$(mktemp -d)
          ${defaultPackage}/bin/nvim --headless \
            -c 'lua vim.defer_fn(function() vim.cmd("qa!") end, 2000)' \
            > log 2>&1 || true
          cat log
          if grep -qiE 'error|E[0-9]+:' log; then
            echo "LunaVim reported errors during startup" >&2
            exit 1
          fi
          touch $out
        '';

        devShells.default = pkgs.mkShell {
          name = defaultPackageName;
          packages = [ defaultPackage ];
        };

        formatter = pkgs.nixfmt;
      }
    )
    // (
      let
        moduleArgs = {
          moduleNamespace = [ defaultPackageName ];
          inherit
            defaultPackageName
            dependencyOverlays
            luaPath
            categoryDefinitions
            packageDefinitions
            extra_pkg_config
            nixpkgs
            ;
        };
      in
      {
        overlays = utils.makeOverlays luaPath {
          inherit nixpkgs dependencyOverlays extra_pkg_config;
        } categoryDefinitions packageDefinitions defaultPackageName;
        nixosModules.default = utils.mkNixosModules moduleArgs;
        homeModules.default = utils.mkHomeModules moduleArgs;
        inherit (utils) templates;
      }
    );
}
