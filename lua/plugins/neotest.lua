return {
  -- TODO: complete setup
  "nvim-neotest/neotest",
  -- event = "VeryLazy",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-neotest/nvim-nio",
    -- issue: https://github.com/antoinemadec/FixCursorHold.nvim/issues/13
    -- "antoinemadec/FixCursorHold.nvim",
    "nvim-treesitter/nvim-treesitter",
    "nvim-neotest/neotest-plenary",
    -- "nvim-neotest/neotest-python",
    -- "nvim-neotest/neotest-jest",
    "marilari88/neotest-vitest",
  },
  keys = {
    -- stylua: ignore start
    { "<Leader>tr", function() require("neotest").run.run() end,                     desc = "Test: run nearest",          },
    { "<Leader>tR", function() require("neotest").watch.toggle() end,                desc = "Test: toggle watch nearest", },
    { "<Leader>td", function() require("neotest").run.run({ strategy = "dap" }) end, desc = "Test: run nearest dap",      },
    { "<Leader>tl", function() require("neotest").run.run_last() end,                desc = "Test: run last",             },
    { "<Leader>tp", function() require("neotest").output_panel.toggle() end,         desc = "Test: toggle output panel",  },
    { "<Leader>ts", function() require("neotest").summary.toggle() end,              desc = "Test: toggle summary",       },
    -- stylua: ignore end
    {
      "<Leader>tS",
      function()
        -- require("neotest").run.stop(vim.fn.getcwd())
        require("neotest").run.stop(vim.lsp.buf.list_workspace_folders()[1])
      end,
      desc = "Test: stop run",
    },
    {
      "<Leader>tt",
      function()
        require("neotest").watch.toggle(vim.fs.normalize(vim.api.nvim_buf_get_name(0)))
      end,
      desc = "Test: toggle watch file",
    },
    {
      "<leader>tT",
      function()
        -- require("neotest").watch.toggle(vim.fn.getcwd())
        require("neotest").watch.toggle(vim.lsp.buf.list_workspace_folders()[1])
      end,
      desc = "Test: toggle watch workspace",
    },
  },
  config = function()
    local adapters = {
      require("neotest-plenary"),
      -- require("neotest-jest")({
      --   jestCommand = require('neotest-jest.jest-util').getJestCommand(vim.fs.dirname(vim.api.nvim_buf_get_name(0))) .. ' --watch',
      --   jestConfigFile = "custom.jest.config.ts",
      --   env = { CI = true },
      --   cwd = function(path)
      --     -- return vim.fn.getcwd()
      --     return vim.lsp.buf.list_workspace_folders()[1]
      --   end,
      -- }),
      require("neotest-vitest")({
        -- Filter directories when searching for test files. Useful in large projects (see Filter directories notes).
        -- selene: allow(unused_variable)
        ---@diagnostic disable-next-line: unused-local
        filter_dir = function(name, rel_path, root)
          return name ~= "node_modules" and name ~= "dist" and name ~= "build"
        end,
        ---Custom criteria for a file path to determine if it is a vitest test file.
        ---@async
        ---@param file_path string Path of the potential vitest test file
        ---@return boolean
        is_test_file = function(file_path)
          local match = string.match(file_path, "__tests__")
            or string.match(file_path, "%.spec%.[jt]sx?$")
            or string.match(file_path, "%.test%.[jt]sx?$")
          return match and true or false
        end,
      }),
      -- require("neotest-python")({
      --   -- Extra arguments for nvim-dap configuration
      --   -- See https://github.com/microsoft/debugpy/wiki/Debug-configuration-settings for values
      --   -- dap = { justMyCode = false },
      --   -- -- Command line arguments for runner
      --   -- Can also be a function to return dynamic values
      --   args = { "--log-level", "DEBUG" },
      --   -- Runner to use. Will use pytest if available by default.
      --   -- Can be a function to return dynamic value.
      --   runner = "pytest",
      --   -- Custom python path for the runner.
      --   -- Can be a string or a list of strings.
      --   -- Can also be a function to return dynamic value.
      --   -- If not provided, the path will be inferred by checking for
      --   -- virtual envs in the local directory and for Pipenev/Poetry configs
      --   python = ".venv/bin/python",
      --   -- Returns if a given file path is a test file.
      --   -- NB: This function is called a lot so don't perform any heavy tasks within it.
      --   -- is_test_file = function(file_path)
      --   --   ...
      --   -- end,
      --   -- !!EXPERIMENTAL!! Enable shelling out to `pytest` to discover test
      --   -- instances for files containing a parametrize mark (default: false)
      --   pytest_discover_instances = true,
      -- }),
    }
    if vim.g.IN_LINUX then
      table.insert(adapters, require("rustaceanvim.neotest"))
    end
    require("neotest").setup({
      adapters = adapters,
      highlights = {
        adapter_name = "GruvboxRedBold",
        dir = "GruvboxGreenBold",
        expand_marker = "GruvboxGray",
        failed = "GruvboxRedBold",
        file = "GruvboxBlueBold",
        focused = "NeotestFocused",
        indent = "GruvboxGrey",
        marked = "GruvboxOrangeBold",
        namespace = "GruvboxPurpleBold",
        passed = "GruvboxAquaBold",
        running = "GruvboxYellowBold",
        -- select_win = "NeotestWinSelect", -- light blue
        skipped = "GruvboxGray",
        target = "GruvboxRed",
        -- test = "NeotestTest", --normal
        unknown = "GruvboxGray",
        watching = "GruvboxYellowBold",
      },
      icons = {
        expanded = "",
        child_prefix = "",
        child_indent = "",
        final_child_prefix = "",
        non_collapsible = "",
        collapsed = "",

        passed = "",
        -- running = "",
        failed = "",
        unknown = "",
      },
    })
  end,
}
