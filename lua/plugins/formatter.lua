return {
  "stevearc/conform.nvim",
  event = "BufWritePre",
  dependencies = { "williamboman/mason.nvim" },
  keys = { { "<Leader>lf", "<Cmd>ConformInfo<CR>", desc = "ConformInfo" } },
  opts = {
    formatters_by_ft = {
      --- LSP formatters
      c = { lsp_format = "prefer" },
      cpp = { lsp_format = "prefer" },
      cmake = { lsp_format = "prefer" },
      python = { lsp_format = "prefer" },
      terraform = { lsp_format = "prefer" },
      hcl = { lsp_format = "prefer" },
      toml = { lsp_format = "prefer" },
      --- non-LSP formatters
      lua = { "stylua" },
      -- may use biome for json/js/ts formatting
      -- Use a sub-list to run only the first available formatter
      -- TODO: make prettier use asterisk instead of underline in italics
      markdown = { "markdownlint", "prettierd", "prettier" },
      yaml = { "prettierd", "prettier" },
      -- TODO: angular, vue, astro, dockerfmt
      json = { "prettierd", "prettier" }, -- or use jsonls
      jsonc = { "prettierd", "prettier" },
      html = { "prettierd", "prettier" },
      css = { "prettierd", "prettier" },
      less = { "prettierd", "prettier" },
      sass = { "prettierd", "prettier" },
      scss = { "prettierd", "prettier" },
      javascript = { "prettierd", "prettier" },
      typescript = { "prettierd", "prettier" },
      javascriptreact = { "prettierd", "prettier" },
      typescriptreact = { "prettierd", "prettier" },
      sh = { "shfmt" },
      -- Use the "*" filetype to run formatters on all filetypes.
      -- ["*"] = { "typos" },
      -- Use the "_" filetype to run formatters on filetypes that don't have other formatters configured.
      ["_"] = { "trim_whitespace" },
    },
    default_format_opts = {
      lsp_format = "fallback",
      async = true,
      stop_after_first = true,
    },
    format_on_save = {
      timeout_ms = 1000,
      lsp_format = "fallback",
      stop_after_first = true,
    },
    log_level = vim.log.levels.OFF,
  },
}
