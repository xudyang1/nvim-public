return {
  "stevearc/conform.nvim",
  event = "BufWritePre",
  dependencies = { "williamboman/mason.nvim" },
  keys = { { "<Leader>lf", "<Cmd>ConformInfo<CR>", desc = "ConformInfo" } },
  opts = {
    formatters_by_ft = {
      lua = { "stylua" },
      toml = { "taplo" },
      -- may use biome for json/js/ts formatting
      -- Use a sub-list to run only the first available formatter
      -- TODO: make prettier use asterisk instead of underline in italics
      markdown = { "markdownlint", "prettierd", "prettier" },
      yaml = { "prettierd", "prettier" },
      -- use jsonls
      -- json = { "prettierd", "prettier" },
      -- jsonc = { "prettierd", "prettier" },
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
      -- ["*"] = { "codespell" },
      -- Use the "_" filetype to run formatters on filetypes that don't have other formatters configured.
      -- ["_"] = { "trim_whitespace" },
    },
    -- Set this to change the default values when calling conform.format()
    -- This will also affect the default values for format_on_save/format_after_save
    default_format_opts = {
      lsp_format = "fallback",
      stop_after_first = true,
    },
    -- If this is set, Conform will run the formatter on save.
    -- It will pass the table to conform.format().
    -- This can also be a function that returns the table.
    format_on_save = {
      -- I recommend these options. See :help conform.format for details.
      lsp_format = "fallback",
      timeout_ms = 1000,
    },
    -- If this is set, Conform will run the formatter asynchronously after save.
    -- It will pass the table to conform.format().
    -- This can also be a function that returns the table.
    -- format_after_save = {
    --   lsp_format = "fallback",
    -- },
    -- Set the log level. Use `:ConformInfo` to see the location of the log file.
    -- log_level = vim.log.levels.ERROR,
    log_level = vim.log.levels.OFF,
    -- Conform will notify you when a formatter errors
    notify_on_error = true,
    -- Custom formatters and changes to built-in formatters
    formatters = {
      -- defaults to tab indent, then neovim can convert tab to spaces
      -- shfmt = {
      --   args = { "--indent=2", "--filename", "$FILENAME" },
      -- },
    },
  },
}
