return {
  {
    "nvim-treesitter/nvim-treesitter",
    event = "VeryLazy",
    init = function(plugin)
      require("lazy.core.loader").add_to_rtp(plugin)
      require("nvim-treesitter.query_predicates")
    end,
    build = ":TSUpdate",
    cmd = { "TSUpdateSync", "TSUpdate", "TSInstall" },
    dependencies = {
      {
        "nvim-treesitter/nvim-treesitter-textobjects",
        config = function()
          require("nvim-treesitter.configs").setup({
            textobjects = {
              select = {
                enable = true,

                -- Automatically jump forward to textobj, similar to targets.vim
                lookahead = true,

                keymaps = {
                  -- You can use the capture groups defined in textobjects.scm
                  ["af"] = "@function.outer",
                  ["if"] = "@function.inner",
                  ["ac"] = "@class.outer",
                  -- You can optionally set descriptions to the mappings (used in the desc parameter of
                  -- nvim_buf_set_keymap) which plugins like which-key display
                  ["ic"] = { query = "@class.inner", desc = "Select textobject @class.inner" },
                },
                selection_modes = {
                  ["@parameter.outer"] = "v", -- charwise
                  ["@function.outer"] = "v", -- linewise
                  ["@class.outer"] = "v", -- blockwise
                  -- ["@function.outer"] = "V", -- linewise
                  -- ["@class.outer"] = "<c-v>", -- blockwise
                },
                include_surrounding_whitespace = true,
              },
            },
          })
        end,
      },
      {
        "nvim-treesitter/nvim-treesitter-context",
        -- event = "VeryLazy",
        cmd = "TSContextToggle",
        opts = {
          enable = false,
          mode = "cursor",
          max_lines = 5,
          separator = "─",
        },
        keys = {
          {
            "<Leader>tc",
            "<Cmd>TSContextToggle<CR>",
            desc = "TreesitterContext: Toggle",
          },
        },
      },
    },
    keys = {
      { "<C-j>", desc = "Selection: Increment" },
      { "<C-h>", desc = "Selection: Scope Increment", mode = "x" },
      { "<C-k>", desc = "Selection: Decrement", mode = "x" },
    },
    opts = {
      auto_install = true,
      sync_install = false,
      highlight = {
        enable = true,
        -- selene: allow(unused_variable)
        ---@diagnostic disable-next-line: unused-local
        disable = function(lang, buf)
          local max_filesize = 100 * 1024 -- 100 KB
          ---@diagnostic disable-next-line: undefined-field
          local ok, stats = pcall(vim.uv.fs_stat, vim.fs.normalize(vim.api.nvim_buf_get_name(buf)))
          if ok and stats and stats.size > max_filesize then
            return true
          end
        end,
        additional_vim_regex_highlighting = false,
      },
      -- still in experimental
      indent = { enable = true },
      ensure_installed = {
        -- the listed parsers should always be intalled
        "c",
        "lua",
        "vim",
        "vimdoc",
        "query",
        "markdown",
        "markdown_inline",
        -- additional parsers
        "bash",
        "cmake",
        "cpp",
        "css",
        "diff",
        vim.g.IN_LINUX and "dockerfile" or nil,
        "git_config",
        "git_rebase",
        "gitattributes",
        "gitcommit",
        "gitignore",
        -- "go",
        "html",
        "http",
        "javascript",
        "jsdoc",
        "json",
        "jsonc",
        -- require treesitter cli
        -- "latex",
        "luadoc",
        "luap",
        "make",
        "python",
        -- "sql",
        "regex",
        vim.g.IN_LINUX and "rust" or nil,
        -- rust object notation
        -- vim.g.IN_LINUX and "ron" or nil,
        "scss",
        vim.g.IN_LINUX and "terraform" or nil,
        "toml",
        "tsx",
        "typescript",
        -- "xml",
        "yaml",
      },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<C-j>",
          node_incremental = "<C-j>",
          scope_incremental = "<C-h>",
          node_decremental = "<C-k>",
        },
      },
      textobjects = {
        move = {
          enable = true,
          goto_next_start = { ["]f"] = "@function.outer", ["]a"] = "@class.outer" },
          goto_next_end = { ["]F"] = "@function.outer", ["]A"] = "@class.outer" },
          goto_previous_start = { ["[f"] = "@function.outer", ["[a"] = "@class.outer" },
          goto_previous_end = { ["[F"] = "@function.outer", ["[A"] = "@class.outer" },
        },
      },
    },
    config = function(_, opts)
      if vim.g.IN_WINDOWS then
        -- https://github.com/nvim-treesitter/nvim-treesitter/wiki/Windows-support
        require("nvim-treesitter.install").prefer_git = true
      end

      if type(opts.ensure_installed) == "table" then
        -- @type table<string, boolean>
        local added = {}
        opts.ensure_installed = vim.tbl_filter(function(lang)
          if added[lang] then
            return false
          end
          added[lang] = true
          return true
        end, opts.ensure_installed)
      end

      require("nvim-treesitter.configs").setup(opts)
    end,
  },
  {
    "windwp/nvim-ts-autotag",
    event = { "InsertEnter *.html,*.js,*.ts,*.jsx,*.tsx,*.xml" },
    opts = {
      opts = {
        enable_close = true, -- Auto close tags
        enable_rename = true, -- Auto rename pairs of tags
        enable_close_on_slash = true, -- Auto close on trailing </
      },
      per_filetype = {
        ["html"] = {
          -- diable for meta fields
          enable_close = false,
        },
      },
    },
  },
}
