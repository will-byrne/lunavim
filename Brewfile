# macOS dependencies for LunaVim when running without Nix.
#
#   xcode-select --install     # git, make and a C compiler (needed once)
#   brew bundle                # run from this directory
#
# Language servers, formatters and linters are NOT listed here: Mason installs
# those on first launch (see lua/lunavim/plugins/lsp.lua).

# Editor
brew "neovim"

# Used by telescope, the git plugins and the dashboard
brew "git"
brew "ripgrep"
brew "fd"
brew "bat"
brew "lazygit"

# Compiles treesitter parsers on first launch
brew "tree-sitter-cli"

# Runtimes Mason needs to install tools
brew "node"            # pyright, typescript-language-server, eslint, prettierd
brew "python@3.13"     # black, flake8, debugpy
brew "openjdk@21"      # jdtls, checkstyle, google-java-format
brew "rustup"          # run `rustup default stable` after, for rustfmt and cargo

# vim-tmux-navigator and the <C-f> tmux-sessionizer keymap
brew "tmux"

# Icons in neo-tree, bufferline, lualine, etc. Set it as your terminal font.
cask "font-jetbrains-mono-nerd-font"
