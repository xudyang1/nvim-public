return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    event = "VeryLazy",
    cmd = "TSUpdate",
    config = function()
      local ensure_installed = {
        -- builtin
        "c",
        "lua",
        "vim",
        "vimdoc",
        "query",
        "markdown",
        "markdown_inline",
        -- additional parsers
        "angular",
        "astro",
        "bash",
        -- "c_sharp",
        -- "caddy",
        "cmake",
        "cpp",
        "css",
        -- "csv",
        -- "diff",
        "dockerfile",
        -- "ecma", -- queries required by js, ts, tsx
        -- "editorconfig",
        "git_config",
        "git_rebase",
        "gitattributes",
        "gitcommit",
        "gitignore",
        "go",
        -- "hcl",
        "html",
        "http",
        "javascript",
        "jsdoc",
        "json",
        -- "latex",
        "luadoc",
        "luap",
        "make",
        -- "nginx",
        -- "powershell",
        "python",
        "sql",
        "regex",
        "rust",
        -- "ron", -- rust object notation
        -- "scss",
        "terraform",
        "toml",
        "tsx",
        "typescript",
        -- "vue",
        -- "xml",
        "yaml",
      }
      if vim.g.IN_WINDOWS and vim.env.CC == nil then
        vim.env.CC = "gcc"
      end
      require("nvim-treesitter").install(ensure_installed)

      vim.treesitter.language.register("tsx", { "javascriptreact", "typescriptreact" })
      local augroup = vim.api.nvim_create_augroup("CustomTSAugroup", { clear = true })
      vim.api.nvim_create_autocmd("FileType", {
        group = augroup,
        desc = "Custom Treesitter Start",
        pattern = "*",
        callback = function(ev)
          local buf = ev.buf
          local max_line_count = 5000
          if vim.api.nvim_buf_line_count(buf) > max_line_count then
            vim.treesitter.stop()
            vim.opt_local.spell = false
            vim.opt_local.syntax = "OFF"
            vim.opt_local.foldmethod = "manual"
            vim.opt_local.undofile = false
            vim.opt_local.swapfile = false
            vim.notify("Treesitter disabled: file exceeds 5000 lines limit.", vim.log.levels.WARN)
            return
          end

          local lang = vim.treesitter.language.get_lang(vim.bo[buf].filetype)
          if not vim.tbl_contains(require("nvim-treesitter").get_installed(), lang) then
            -- TODO: auto install...
            return
          end
          vim.treesitter.start(buf, lang)
          vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          -- vim.bo[buf].syntax = 'ON'  -- only if additional legacy syntax is needed
          vim.opt_local.foldmethod = "expr"
          vim.opt_local.foldexpr = "v:lua.vim.treesitter.foldexpr()"
        end,
      })
      vim.api.nvim_exec_autocmds("FileType", { buf = 0, group = augroup })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    event = "VeryLazy",
    config = function()
      require("nvim-treesitter-textobjects").setup({
        select = {
          lookahead = true,
          -- -- "v": charwise (default), "V": linewise "<c-v>": blockwise
          -- selection_modes = {
          --   -- ["@parameter.outer"] = "v",
          -- },
          move = {
            set_jumps = true,
          },
          include_surrounding_whitespace = false,
        },
      })

      local select_maps = {
        { "al", "@assignment.lhs" },
        { "ar", "@assignment.rhs" },
        { "aa", "@assignment.outer" },
        { "ia", "@assignment.inner" },

        { "af", "@function.outer" },
        { "if", "@function.inner" },
        { "ac", "@call.outer" },
        { "ic", "@call.inner" },
        { "ai", "@conditional.outer" },
        { "ii", "@conditional.inner" },
        { "ag", "@parameter.outer" }, -- @argument.outer
        { "ig", "@parameter.inner" }, -- @argument.inner
        -- { "as", "@statement.outer" },
        -- { "is", "@statement.inner" },

        { "aC", "@class.outer" },
        { "iC", "@class.inner" },
        { "aL", "@loop.outer" },
        { "iL", "@loop.inner" },
        { "aS", "@struct.outer" },
        { "iS", "@struct.inner" },
      }
      local map = vim.keymap.set
      for _, select_entry in ipairs(select_maps) do
        map({ "x", "o" }, select_entry[1], function()
          require("nvim-treesitter-textobjects.select").select_textobject(select_entry[2])
        end, { desc = select_entry[2] })
      end

      local move_maps = {
        { "f", "@function.outer" },
        { "C", "@class.outer" },
      }
      for _, move_entry in ipairs(move_maps) do
        map({ "n", "x", "o" }, "[" .. move_entry[1], function()
          require("nvim-treesitter-textobjects.move").goto_previous_start(move_entry[2], "textobjects")
        end, { desc = move_entry[2] .. ": prev start" })
        map({ "n", "x", "o" }, "]" .. move_entry[1], function()
          require("nvim-treesitter-textobjects.move").goto_next_start(move_entry[2], "textobjects")
        end, { desc = move_entry[2] .. ": next start" })
      end

      -- load custom autocmds
      require("core.autocmds")
    end,
  },
  {
    "windwp/nvim-ts-autotag",
    event = { "InsertEnter *.html,*.js,*.ts,*.jsx,*.tsx,*.astro,*.vue,*.svelte" },
    opts = {
      opts = {
        enable_close = true, -- auto close tags
        enable_rename = true, -- auto rename pairs of tags
        enable_close_on_slash = true, -- auto close on trailing </
      },
      per_filetype = {
        ["html"] = {
          -- disable for meta fields
          enable_close = false,
        },
      },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter-context",
    cmd = "TSContext",
    opts = {
      enable = false,
      mode = "cursor",
      max_lines = 5,
      separator = "─",
    },
    keys = { { "<Leader>tc", "<Cmd>TSContext toggle<CR>", desc = "Treesitter context: toggle" } },
  },
}
