<!-- markdownlint-disable MD013 -->
# Neovim Configuration

## Dependencies

- Requited:
  - [git](https://git-scm.com/downloads), `curl` or `wget`, `unzip`, `tar` or `gtar`, `gzip`
    - `add-apt-repository ppa:git-core/ppa; apt update; apt install git # latest stable git for ubuntu`
  - `npm`, `cargo`(`rust-analyzer`): mason.nvim need these package managers to download packages
  - C compiler (gcc, clang, etc) and libstdc++: nvim-treesitter

- Optional:
  - [ripgrep](https://github.com/BurntSushi/ripgrep): telescope.nvim `live_grep` and `grep_string`
    - `apt install rg`
  - [fdfind](https://github.com/sharkdp/fd): telescope.nvim finder
    - `apt install fd-find`
  - make: LuaSnip build jsregexp
  - python3-venv: module for creating python virtual environment, linux only
