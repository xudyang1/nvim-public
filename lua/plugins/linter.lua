return {
  "mfussenegger/nvim-lint",
  event = "VeryLazy",
  dependencies = { "williamboman/mason.nvim" },
  opts = {
    events = {
      "BufReadPost", -- loading buffer after nvim-lint: event="BufReadPost"
      "BufWritePost", -- some linters require saving file
      "InsertLeave",
      "TextChanged", -- more aggressive (e.g., undo)
    },
    linters = {
      selene = { root_markers = { "selene.toml", ".git" } },
      luacheck = { root_markers = { ".luacheckrc", ".git" } },
      yamllint = {
        root_markers = { ".yamllint.yaml", ".yamllint.yml", ".yamllint", ".git" },
        args = {
          "--format",
          "parsable",
          "-d",
          '"{extends: default, rules: {document-start: disable}}"',
          "-",
        },
      },
      shellcheck = {
        args = {
          "--format",
          "json1",
          "--exclude=SC1090,SC1091",
          "-",
        },
      },
    },
    linters_by_ft = {
      -- linting provided by LSPs:
      -- clangd: c/cpp, rust_analyzer: rust, ruff: python
      -- cssls: css, eslint: js/ts, taplo: toml
      lua = { "selene" },
      markdown = { "markdownlint" }, -- does not format tables
      yaml = { "yamllint" }, -- yamlls is weak at indentation/whitespace style check
      github_action = { "actionlint" }, -- also lint with yamllint
      sh = { "shellcheck" },
      html = { "htmlhint" },
      tf = { vim.g.IN_LINUX and "tflint" or nil }, -- terraform linter, no stdin support
      -- sql = { "sqlruff" }, -- supports auto-formatter
      -- gitcommit = { "commitlint" },
    },
  },
  config = function(_, opts)
    local lint = require("lint")
    local fs = vim.fs
    local api = vim.api

    lint.linters_by_ft = opts.linters_by_ft

    for name, config in pairs(opts.linters) do
      if config.args then
        lint.linters[name].args = config.args
      end
    end

    local augroup = api.nvim_create_augroup("nvim-lint", { clear = true })
    api.nvim_create_autocmd(opts.events, {
      group = augroup,
      callback = function(ev)
        local bufnr = ev.buf
        local filetype = vim.bo[bufnr].filetype
        local bufname = api.nvim_buf_get_name(bufnr)

        if not vim.bo[bufnr].modifiable or vim.bo[bufnr].readonly or filetype == "pager" or filetype == "qf" then
          return
        end
        if filetype == "markdown" and vim.g.started_by_firenvim then
          return
        end

        if filetype == "yaml" and string.find(bufname, vim.pesc(".github/workflows/")) then
          lint.try_lint(opts.linters_by_ft.github_action)
        end

        local linters = opts.linters_by_ft[filetype] or {}
        for _, linter in ipairs(linters) do
          local linter_config = opts.linters[linter] or {}
          local root_markers = linter_config.root_markers
          if root_markers and bufname ~= "" then
            local marker = fs.find(root_markers, {
              upward = true,
              stop = fs.normalize("~"),
              path = fs.dirname(bufname),
            })[1]
            -- project root or buffer directory (standalone file)
            lint.try_lint(linter, { cwd = fs.dirname(marker or bufname) })
          else
            lint.try_lint(linter)
          end
        end
      end,
    })

    -- lazy: run in current buffer
    api.nvim_exec_autocmds("BufReadPost", { buf = 0, group = augroup })

    vim.keymap.set("n", "<Leader>ll", function()
      vim.print(lint.linters_by_ft[vim.bo.filetype])
    end, { desc = "nvim-lint: list linters" })
  end,
}
