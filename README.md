<h1 align="center">
<a href='#'><img src="https://raw.githubusercontent.com/catppuccin/catppuccin/main/assets/palette/macchiato.png" width="600px"/></a>
  <br>
  <br>
  <div>
    <a href="https://github.com/will-byrne/lunavim/issues">
        <img src="https://img.shields.io/github/issues/will-byrne/lunavim?color=fab387&labelColor=303446&style=for-the-badge">
    </a>
    <a href="https://github.com/will-byrne/lunavim/stargazers">
        <img src="https://img.shields.io/github/stars/will-byrne/lunavim?color=ca9ee6&labelColor=303446&style=for-the-badge">
    </a>
    <a href="https://github.com/will-byrne/lunavim">
        <img src="https://img.shields.io/github/repo-size/will-byrne/lunavim?color=ea999c&labelColor=303446&style=for-the-badge">
    </a>
    <a href="https://github.com/will-byrne/lunavim/blob/main/LICENCE">
        <img src="https://img.shields.io/static/v1.svg?style=for-the-badge&label=License&message=MIT&logoColor=ca9ee6&colorA=313244&colorB=cba6f7"/>
    </a>
    <br>
            <img href="https://builtwithnix.org" src="https://builtwithnix.org/badge.svg"/>
    </div>
   </h1>

<h1 align="center">🌙 LunaVim 🌙</h1>

## What's LunaVim?

LunaVim is a Neovim configuration written in plain Lua that runs the same way **with or without Nix**:

| | On Nix (NixOS, nix-darwin, Linux with Nix) | Without Nix (macOS, Windows, any Linux) |
|---|---|---|
| Config | This repo, wrapped into a package by [nixCats](https://github.com/BirdeeHub/nixCats-nvim) | This repo, cloned into your Neovim config folder |
| Plugins | From nixpkgs, pinned by `flake.lock` | Downloaded by [lazy.nvim](https://github.com/folke/lazy.nvim), pinned by `lazy-lock.json` |
| LSPs, formatters, linters | From nixpkgs (`flake.nix`) | Downloaded by [Mason](https://github.com/mason-org/mason.nvim) |
| Treesitter parsers | All grammars, prebuilt | Compiled on first launch |

lazy.nvim loads the plugins in both cases, so the Lua is identical everywhere. On Nix it's told to find each plugin in the Nix store instead of downloading it.

LunaVim is based on, and inspired by, [redyf/Neve](https://github.com/redyf/Neve), a Nixvim configuration. It started as a fork of Neve and keeps much of its plugin selection, keymaps and settings, rewritten in Lua so it also runs without Nix. Thanks to redyf for the original.

## Installation

### With Nix

Try it without installing:

```sh
nix run github:will-byrne/lunavim
```

To install it, add the flake to your inputs:

```nix
inputs.lunavim.url = "github:will-byrne/lunavim";
```

Then either add the package to `environment.systemPackages` or `home.packages`:

```nix
inputs.lunavim.packages.${pkgs.stdenv.hostPlatform.system}.default
```

Or use the home-manager module (`inputs.lunavim.nixosModules.default` works the same way for NixOS):

```nix
imports = [ inputs.lunavim.homeModules.default ];
nvim = {
  enable = true;
  packageNames = [ "nvim" ];
};
```

The package provides `nvim`, plus `vim` and `lunavim` aliases.

### macOS (without Nix)

1. Install the command-line tools and the dependencies in the [`Brewfile`](Brewfile):

   ```sh
   xcode-select --install
   git clone https://github.com/will-byrne/lunavim ~/.config/nvim
   cd ~/.config/nvim
   brew bundle
   rustup default stable      # rustfmt and cargo
   brew analytics off         # optional: stop Homebrew's usage analytics
   ```

   To keep an existing Neovim config side by side, clone into `~/.config/lunavim` instead and start it with `NVIM_APPNAME=lunavim nvim`.

2. Set your terminal font to **JetBrainsMono Nerd Font** (installed by the Brewfile) so icons render.

3. Start `nvim`. On the first launch:
   - lazy.nvim downloads the plugins.
   - Mason installs the language servers, formatters and linters in the background (`:Mason` shows progress).
   - The treesitter parsers compile.

   Wait for those to finish, then restart Neovim.

4. Run `:checkhealth` if anything looks wrong.

5. Commit the `lazy-lock.json` that the first launch writes, so other machines get the same plugin versions.

### Windows (untested)

Clone into `%LOCALAPPDATA%\nvim`. Install Neovim, git, ripgrep, fd, Node.js, Python, a JDK, rustup, `cmake` (for telescope-fzf-native), and a C compiler plus the `tree-sitter` CLI (for treesitter parsers), e.g. with `winget` or `scoop`. Then follow steps 2–5 above.

### Linux without Nix

Clone into `~/.config/nvim` and install the same tools as the Brewfile using your package manager. Then follow steps 2–5 above.

## Layout

```
flake.nix                  Nix packaging: plugins, tools and categories (Nix only)
Brewfile                   macOS dependencies (non-Nix only)
init.lua                   entry point: options, keymaps, then lazy.nvim
lua/lunavim/
  options.lua              vim options
  keymaps.lua              global keymaps
  autocmds.lua             :FormatToggle, UI toggles, spelling, diagnostics, commenting
  plugins/                 one lazy.nvim spec file per area
    ui.lua                 colorscheme, start screen, statusline, bufferline, which-key
    editor.lua             treesitter, editing helpers, markdown rendering (markview)
    navigation.lua         telescope, neo-tree, oil, harpoon, terminals, sessions
    completion.lua         blink.cmp + LuaSnip
    lsp.lua                language servers, Mason, conform (formatting), nvim-lint
    git.lua                gitsigns, lazygit, diffview
    debug.lua              nvim-dap
    test.lua               neotest
lua/nixCatsUtils/          nixCats helpers that make the config work without Nix
queries/nix/               highlights Lua embedded in Nix strings
```

## Customizing

### Adding a plugin

1. Add a lazy.nvim spec to a file in `lua/lunavim/plugins/`:

   ```lua
   { "author/some-plugin.nvim", event = "VeryLazy", opts = {} },
   ```

2. On Nix, also add its nixpkgs package to `startupPlugins` in `flake.nix` (e.g. `some-plugin-nvim`).

   lazy.nvim finds the plugin in the Nix store by **directory name**, which is the package's nixpkgs `pname`. If that differs from the repo name, set `name = "<pname>"` in the spec; for example LuaSnip uses `name = "luasnip"`. If the names don't match, lazy.nvim falls back to downloading the plugin, even on Nix.

### Language servers, formatters and linters

All three are configured in `lua/lunavim/plugins/lsp.lua`:
- **Language servers:** the `servers()` table.
- **Formatters:** `formatters_by_ft` (conform).
- **Linters:** `linters_by_ft` (nvim-lint).

When you add a tool, make it available on both sides:
- **Nix:** add the package to `lspsAndRuntimeDeps` in `flake.nix`.
- **Without Nix:** add the Mason package name to `mason_tools`.

### Categories (Nix only)

`flake.nix` groups dependencies into categories: `general`, `lsp`, `format`, `lint`, `debug` and `test`. Turning one off in `packageDefinitions` removes its packages. Specs that check `enableForCategory("<name>")` are also skipped in Lua.

Without Nix every category is on.

### Formatting

Format-on-save starts **off**:
- `<leader>uf` (or `:FormatToggle`) turns it on or off globally.
- `<leader>uF` (or `:FormatToggle!`) does the same for the current buffer.
- `<leader>cf` formats the buffer once.

## Key bindings

`<leader>` is <kbd>Space</kbd>. Press it and wait for which-key to show everything. Some highlights:

| Keys | Action |
|---|---|
| `<leader><space>` / `<leader>/` | Find files / grep |
| `<leader>e` | File tree (neo-tree) |
| `<leader>o` | Oil (edit the directory as a buffer) |
| `<S-h>` / `<S-l>` | Previous / next buffer |
| `<leader>ha`, `<C-e>`, `<leader>1`–`4` | Harpoon: add file, menu, jump to file 1–4 |
| `<C-h/j/k/l>` | Move between windows and tmux panes |
| `gd`, `gr`, `K`, `<leader>ca`, `<leader>cr` | LSP: definition, references, hover, code action, rename |
| `<C-s>` (insert mode) | Signature help |
| `gc` | Comment (built-in) |
| `<leader>gg` | LazyGit |
| `<leader>gb` | Toggle inline git blame |
| `<leader>gh…` | Git hunks: stage, reset, preview, blame line |
| `<leader>x…` | Trouble: diagnostics, quickfix, todos |
| `<leader>d…` | Debugging |
| `<leader>T…` | Tests (neotest) |
| `<leader>t…` / `<F7>` | Terminals |
| `<leader>cp` | Toggle markdown rendering |
| `<leader>u…` | UI toggles: format on save, line numbers, wrap, inlay hints |
| `<leader>q…` | Sessions |

## License

This project is licensed under the [MIT License](LICENCE).
