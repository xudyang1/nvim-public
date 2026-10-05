return {
  "mason-org/mason.nvim",
  build = ":MasonUpdate",
  keys = {
    { "<Leader>ma", "<Cmd>Mason<Cr>", desc = "Mason" },
    { "<Leader>ml", "<Cmd>MasonLog<Cr>", desc = "MasonLog" },
  },
  opts = {
    -- prepend: first in $PATH, append: last in $PATH, skip: do not edit $PATH
    PATH = "prepend",
    -- log_level = vim.log.levels.OFF,
    ensure_installed = {
      --- lua
      "lua-language-server", -- lua_ls
      "selene", -- "luacheck",
      "stylua",
      --- c/cpp
      "clangd",
      "neocmakelsp", -- cmake
      "codelldb",
      --- rust
      vim.g.IN_LINUX and "rust-analyzer" or nil, -- rust_analyzer
      --- web development
      "emmet-language-server", -- emmet_language_server
      "html-lsp", -- html
      "css-lsp", -- cssls
      "cssmodules-language-server", -- cssmodules_ls
      "tailwindcss-language-server", -- tailwindcss
      "eslint-lsp", -- eslint
      "tsc",
      -- "angular-language-server", -- angularls
      -- "deno",
      -- "biome",
      "htmlhint",
      "prettier",
      -- "prettierd",
      "firefox-debug-adapter",
      "js-debug-adapter",
      --- markdown
      "marksman",
      "markdownlint",
      --- json
      "json-lsp", -- jsonls
      --- toml
      "taplo",
      --- yaml
      "yaml-language-server", -- yamlls
      "yamllint",
      "actionlint",
      --- terraform
      vim.g.IN_LINUX and "terraform-ls" or nil, -- "terraformls"
      vim.g.IN_LINUX and "tflint" or nil,
      --- sh(bash)
      "bash-language-server",
      "shellcheck",
      "shfmt",
      "bash-debug-adapter",
      --- python
      "pyright",
      -- "basedpyright",
      "ruff", -- lint & format
      "debugpy",
      --- all filetypes: code spell check
      "typos-lsp",
    },
  },
  config = function(_, opts)
    require("mason").setup(opts)

    local mr = require("mason-registry")
    local is_installed, get_package = mr.is_installed, mr.get_package

    mr.refresh(function()
      for _, pkg_name in pairs(opts.ensure_installed) do
        if not is_installed(pkg_name) then
          get_package(pkg_name):install()
        end
      end
    end)
  end,
}
