return {
  "mfussenegger/nvim-lint",
  -- event = { "BufReadPre", "BufNewFile" },
  event = "VeryLazy",
  dependencies = { "williamboman/mason.nvim" },
  opts = {
    events = {
      -- loading buffer after nvim-lint: event="BufReadPost"
      "BufReadPost",
      -- some linters require saving file
      "BufWritePost",
      "InsertLeave",
      -- more aggresive (e.g., undo)
      "TextChanged",
    },
    linters_by_ft = {
      lua = {
        "selene",
        -- "luacheck",
      },
      -- clangd lsp supports static check (clang-tidy)
      -- cpp = {},
      markdown = {
        -- does not format tables
        "markdownlint",
        -- "vale",
      },
      tf = {
        -- specific to terraform files
        vim.g.IN_LINUX and "tflint",
        -- security check for many languages
        -- "trivy",
      },
      yaml = {
        -- CloudFormation linter
        -- "cfn-lint",
        -- general yaml linter
        "yamllint",
      },
      github_action = {
        -- Static checker for GitHub Actions workflow files
        "actionlint",
        -- general yaml linter
        "yamllint",
      },
      -- sql = {
      --   -- supports auto-formatter
      --   "sqlfluff"
      -- },
      -- gitcommit = {
      --   "commitlint"
      -- },
      sh = {
        "shellcheck",
      },
      html = {
        "htmlhint",
      },
      -- TODO: work more with stylelint without configuration file needed
      -- WORK_AROUND: cssls or tailwind have linting services
      -- css = {
      --   "stylelint",
      -- },
      -- less = {
      --   "stylelint",
      -- },
      -- sass = {
      --   "stylelint",
      -- },
      -- scss = {
      --   "stylelint",
      -- },
      -- rustaceannvim
      -- rust = {},
    },
    root_patterns_by_ft = {
      lua = {
        selene = { "selene.toml", ".git" },
        -- luacheck = { ".luacheckrc", ".git" },
      },
      yaml = {
        yamllint = { ".yamllint.yaml", ".yamllint.yml", ".yamllint" },
      },
      github_action = {
        yamllint = { ".yamllint.yaml", ".yamllint.yml", ".yamllint" },
      },
    },
    linters = {},
  },
  config = function(_, opts)
    local lint = require("lint")
    local api = vim.api
    local fs = vim.fs
    lint.linters_by_ft = opts.linters_by_ft

    ---Find pattern path from buf dir to $HOME
    ---@param patterns string[] file or directory name patterns
    ---@return string? full path of the pattern if found, nil otherwise
    local function find_path(patterns)
      return fs.find(patterns, {
        upward = true,
        -- stops at $HOME/.., so search includes $HOME
        stop = fs.normalize("~/.."),
        path = fs.dirname(api.nvim_buf_get_name(0)),
      })[1]
    end

    ---Set cwd for linters specified by opts.root_patterns_by_ft[filetype] or buffer's parent
    ---@param linter_root_patterns table<string, string[]>? a mapping of linter to patterns
    local function set_linters_cwd(linter_root_patterns)
      for linter, root_patterns in pairs(linter_root_patterns or {}) do
        local pattern_path = root_patterns and find_path(root_patterns)
        lint.linters[linter].cwd = fs.dirname(pattern_path or api.nvim_buf_get_name(0))
      end
    end

    -- shellcheck can check posix by setting shebang `#!/bin/sh` or specify `--shell=sh`
    lint.linters.shellcheck.args = { "--format", "json", "--exclude=SC1090,SC1091", "-" }

    -- selene: allow(unused_variable)
    ---@diagnostic disable-next-line: unused-local
    local run_linters = function(args)
      -- disable linter for readonly help pages and library files
      if not vim.bo.modifiable then
        return
      end

      local filetype = vim.bo.filetype
      local path = fs.normalize(api.nvim_buf_get_name(0))

      -- disable markdown linting for buffers under firenvim runtime
      if filetype == "markdown" and vim.g.started_by_firenvim then
        return
      end

      if filetype == "yaml" and string.find(path, ".github/workflows/") then
        set_linters_cwd(opts.root_patterns_by_ft.github_action)
        lint.try_lint(opts.linters_by_ft.github_action)
        return
      end
      set_linters_cwd(opts.root_patterns_by_ft[filetype])
      lint.try_lint()
    end

    local lint_augroup = api.nvim_create_augroup("nvim-lint", { clear = true })
    api.nvim_create_autocmd(opts.events, {
      group = lint_augroup,
      callback = run_linters,
    })

    run_linters()
  end,
}
