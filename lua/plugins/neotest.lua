return {
  "nvim-neotest/neotest",
  dependencies = {
    "nvim-neotest/nvim-nio",
    -- "nvim-treesitter/nvim-treesitter",

    "nvim-neotest/neotest-plenary",
    "nvim-neotest/neotest-python",
    -- "nvim-neotest/neotest-jest",
    "marilari88/neotest-vitest",
  },
  keys = {
    -- stylua: ignore start
    { "[n", function() require("neotest").jump.prev({ status = "failed" }) end,      desc = "Test: goto previous failed"  },
    { "]n", function() require("neotest").jump.next({ status = "failed" }) end,      desc = "Test: goto next failed"      },
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
        require("neotest").watch.toggle(vim.api.nvim_buf_get_name(0))
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
    -- TODO: more adapters
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
        -- selene: allow(unused_variable)
        ---@diagnostic disable-next-line: unused-local
        filter_dir = function(name, rel_path, root)
          return name ~= "node_modules" and name ~= "dist" and name ~= "build"
        end,
        is_test_file = function(file_path)
          local match = string.match(file_path, "__tests__")
            or string.match(file_path, "%.spec%.[jt]sx?$")
            or string.match(file_path, "%.test%.[jt]sx?$")
          return match and true or false
        end,
      }),
      require("neotest-python")({
        -- Extra arguments for nvim-dap configuration
        -- See https://github.com/microsoft/debugpy/wiki/Debug-configuration-settings for values
        -- dap = { justMyCode = false },
        args = { "--log-level", "DEBUG" },
        runner = "pytest",
        python = function()
          local python_executable
          if vim.env.VIRTUAL_ENV and vim.fs.normalize(vim.fn.exepath("python")) ~= "" then
            python_executable = vim.fs.normalize(vim.fn.exepath("python"))
          else
            local venv_path = vim.fs.find({ ".venv", "venv" }, {
              upward = true,
              stop = vim.fs.normalize("~"),
              type = "directory",
              path = vim.fs.dirname(vim.api.nvim_buf_get_name(0)),
            })[1]
            python_executable = venv_path
              and string.format("%s/%s", venv_path, vim.g.IN_WINDOWS and "Scripts/python.exe" or "bin/python")
          end
          assert(
            python_executable and vim.fn.executable(python_executable) == 1,
            string.format("Neotest: need a python path, got %s.", python_executable)
          )
          return python_executable
        end,
        pytest_discover_instances = true,
      }),
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
    })
  end,
}
