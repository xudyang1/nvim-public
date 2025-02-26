return {
  "williamboman/mason.nvim",
  build = ":MasonUpdate",
  keys = {
    { "<Leader>ma", "<Cmd>Mason<Cr>", desc = "Mason" },
  },
  opts = {
    ui = {
      border = "rounded",
    },
    -- custom ensure_installed
    ensure_installed = {
      --- lua
      "lua-language-server", -- lua_ls
      -- "luacheck",
      "selene",
      "stylua",
      --- c/cpp
      "clangd",
      -- "cmake-language-server", -- cmake
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
      "typescript-language-server", -- ts_ls
      -- "angular-language-server", -- angularls
      -- "deno",
      -- "biome",
      "htmlhint",
      "stylelint",
      "prettier",
      -- "prettierd",
      "firefox-debug-adapter",
      "chrome-debug-adapter",
      --- markdown
      "marksman",
      "markdownlint",
      -- "vale",
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
    },
  },
  config = function(_, opts)
    -- use lazyVim's Mason ensure_installed:
    -- or from: https://github.com/williamboman/mason.nvim/issues/1309#issuecomment-1555018732
    require("mason").setup(opts)

    local mr = require("mason-registry")
    local function ensure_installed()
      for _, tool in pairs(opts.ensure_installed) do
        local p = mr.get_package(tool)
        if not p:is_installed() then
          p:install()
        end
      end
    end
    mr.refresh(ensure_installed)
  end,
}
