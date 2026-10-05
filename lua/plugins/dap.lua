return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      {
        "rcarriga/nvim-dap-ui",
        dependencies = { "nvim-neotest/nvim-nio" },
        keys = {
          -- stylua: ignore start
          { "<Leader>du", function() require("dapui").toggle({ layout=2, reset = true }) end, desc = "Dap: toggle layout (repl+console)" },
          { "<Leader>dU", function() require("dapui").toggle({ reset = true }) end,           desc = "Dap: toggle layout (all)" },
          { mode = { "n", "x" }, "<Leader>de", function() require("dapui").eval() end,        desc = "Dap: eval" },
          -- stylua: ignore end
        },
        opts = {
          -- mappings = {
          --   edit = "e",
          --   expand = { "<CR>", "<2-LeftMouse>" },
          --   open = "o",
          --   remove = "d",
          --   repl = "r",
          --   toggle = "t",
          -- },
          layouts = {
            {
              elements = {
                { id = "scopes", size = 0.25 },
                { id = "breakpoints", size = 0.25 },
                { id = "stacks", size = 0.25 },
                { id = "watches", size = 0.25 },
              },
              position = "left",
              size = 0.2,
            },
            {
              elements = {
                { id = "repl", size = 0.5 },
                { id = "console", size = 0.5 },
              },
              position = "bottom",
              size = 0.25,
            },
          },
        },
      },
      {
        "theHamsta/nvim-dap-virtual-text",
        opts = {
          -- enabled = true,
          all_references = true,
          -- selene: allow(unused_variable)
          --- @diagnostic disable-next-line: unused-local
          display_callback = function(variable, buf, stackframe, node, options)
            -- by default, strip out new line characters
            if options.virt_text_pos == "inline" then
              return " : " .. variable.value:gsub("%s+", " ")
            else
              return variable.name .. " : " .. variable.value:gsub("%s+", " ")
            end
          end,
        },
      },
    },
    keys = {
      -- stylua: ignore start
      { "<Leader>db", function() require("dap").toggle_breakpoint() end, desc = "DAP: toggle breakpoint" },
      { "<Leader>dc", function() require("dap").continue() end,          desc = "DAP: continue"          },
      { "<Leader>dC", function() require("dap").run_to_cursor() end,     desc = "DAP: run to cursor"     },
      { "<Leader>dl", function() require("dap").run_last() end,          desc = "DAP: run last"          },
      { "<Leader>dj", function() require("dap").down() end,              desc = "DAP: down"              },
      { "<Leader>dk", function() require("dap").up() end,                desc = "DAP: up"                },
      { "<Leader>di", function() require("dap").step_into() end,         desc = "DAP: step into"         },
      { "<Leader>do", function() require("dap").step_over() end,         desc = "DAP: step over"         },
      { "<Leader>dO", function() require("dap").step_out() end,          desc = "DAP: step out"          },
      { "<Leader>dP", function() require("dap").pause() end,             desc = "DAP: pause"             },
      { "<Leader>dT", function() require("dap").terminate() end,         desc = "DAP: terminate"         },
      { "<Leader>dt", function() require("dap").repl.toggle() end,       desc = "DAP: repl toggle"       },
      { "<Leader>ld", "<Cmd>DapShowLog<Cr>",                             desc = "DAP: log"               },
      -- stylua: ignore end
      {
        "<Leader>dB",
        function()
          local actions = {
            {
              desc = "Set conditional breakpoint",
              cmd = function()
                require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
              end,
            },
            {
              desc = "Set exception breakpoints",
              cmd = function()
                require("dap").set_exception_breakpoints()
              end,
            },
            {
              desc = "Clear all breakpoints",
              cmd = function()
                require("dap").clear_breakpoints()
              end,
            },
            {
              desc = "List all breakpoints in quickfix window",
              cmd = function()
                require("dap").list_breakpoints()
              end,
            },
          }

          local options = {}
          for _, action in ipairs(actions) do
            table.insert(options, action.desc)
          end

          vim.ui.select(options, {
            prompt = "Select Breakpoint Action:",
          }, function(choice)
            for _, action in ipairs(actions) do
              if action.desc == choice then
                action.cmd()
                break
              end
            end
          end)
        end,
        desc = "DAP: breakpoint actions menu",
      },
      {
        "<Leader>dr",
        function()
          local dap = require("dap")
          if dap.session() then
            dap.restart()
          else
            dap.run_last()
          end
        end,
        desc = "DAP: restart",
      },
      {
        mode = { "n", "x" },
        "<Leader>dh",
        function()
          require("dap.ui.widgets").hover()
        end,
        desc = "DAP: widget hover",
      },
      {
        "<Leader>df",
        function()
          local widgets = require("dap.ui.widgets")
          widgets.cursor_float(widgets.frames)
        end,
        desc = "DAP: float frames",
      },
      {
        "<Leader>ds",
        function()
          local widgets = require("dap.ui.widgets")
          widgets.cursor_float(widgets.scopes)
        end,
        desc = "DAP: float scopes",
      },
    },
    config = function()
      local dap = require("dap")
      dap.set_log_level(vim.log.levels.ERROR)
      -- dap.listeners.after.event_initialized.dapui_config = function() require("dapui").open({}) end
      -- dap.listeners.before.event_terminated.dapui_config = function() require("dapui").close({}) end
      -- dap.listeners.before.event_exited.dapui_config = function() require("dapui").close({}) end

      local custom_dap_providers = {}
      dap.providers.configs["custom"] = function(bufnr)
        local filetype = vim.bo[bufnr].filetype
        local ft_configs = custom_dap_providers[filetype] or {}
        if type(ft_configs) == "function" then
          ft_configs = ft_configs(bufnr)
        end
        local final_ft_configs = {}
        for _, ft_config in pairs(ft_configs) do
          local config
          if
            type(ft_config) == "function"
            or (getmetatable(ft_config) and type(getmetatable(ft_config).__call) == "function")
          then
            config = ft_config(bufnr)
          elseif type(ft_config) == "table" then
            config = ft_config
          end
          assert(
            type(config) == "table",
            string.format(
              "custom_dap_providers[%s]: configurations resolved must be type table, got %s.",
              filetype,
              vim.inspect(type(config))
            )
          )
          table.insert(final_ft_configs, config)
        end
        return final_ft_configs
      end

      local mason_packs = string.format("%s/mason/packages", vim.fn.stdpath("data"))

      local pwa_node_adapter = {
        type = "server",
        host = "127.0.0.1",
        port = "${port}",
        executable = {
          command = "node",
          args = { string.format("%s/js-debug-adapter/js-debug/src/dapDebugServer.js", mason_packs), "${port}" },
        },
      }

      local prompt_for_target_path = function()
        return vim.fn.input({
          prompt = "Path to executable: ",
          default = vim.fn.getcwd() .. "/",
          completion = "file",
        })
      end

      local dap_adapters = {
        --- c/cpp/rust
        gdb = {
          type = "executable",
          command = "gdb",
          args = { "--interpreter=dap", "--eval-command", "set print pretty on" },
        },
        codelldb = {
          type = "executable",
          command = string.format(
            "%s/codelldb/extension/adapter/codelldb%s",
            mason_packs,
            vim.g.IN_WINDOWS and ".exe" or ""
          ),
          options = {
            detached = not vim.g.IN_WINDOWS,
          },
        },
        --- js/ts
        ["pwa-node"] = pwa_node_adapter,
        ["pwa-chrome"] = pwa_node_adapter,
        ["pwa-msedge"] = pwa_node_adapter,
        firefox = {
          type = "executable",
          command = "node",
          args = { string.format("%s/firefox-debug-adapter/dist/adapter.bundle.js", mason_packs) },
        },
        --- python
        python = function(callback, config)
          if config.request == "attach" then
            local port = (config.connect or config).port
            local host = (config.connect or config).host or "127.0.0.1"
            assert(
              tonumber(port) and tonumber(port) <= 65535,
              "A valid `connect.port` is required for a python `attach` configuration"
            )
            local adapter = {
              type = "server",
              port = port,
              host = host,
              options = {
                source_filetype = "python",
              },
            }
            callback(adapter)
          else
            local python_command = string.format(
              "%s/debugpy/venv/%s",
              mason_packs,
              vim.g.IN_WINDOWS and "Scripts/python.exe" or "bin/python"
            ) or config.pythonPath

            local adapter = {
              type = "executable",
              command = python_command,
              args = { "-m", "debugpy.adapter" },
              options = {
                source_filetype = "python",
                detached = not vim.g.IN_WINDOWS,
              },
            }
            callback(adapter)
          end
        end,
        bashdb = {
          type = "executable",
          command = string.format("%s/bash-debug-adapter/bash-debug-adapter", mason_packs),
          name = "bashdb",
        },
      }

      local codelldb_configs = function(bufnr)
        local progress_opts = {
          kind = "progress",
          source = "dap-codelldb",
          title = "",
          status = "running",
          percent = 0,
        }

        local function compile_and_get_path(target_opts)
          return coroutine.create(function(dap_co)
            local progress = vim.deepcopy(progress_opts)
            progress.id = vim.api.nvim_echo({ { "Start building executable..." } }, true, progress)
            vim.system({ "sh", "-c", target_opts.build_command }, { text = true }, function(obj)
              vim.schedule(function()
                local output, target
                if obj.code ~= 0 then
                  progress.err = true
                  progress.status = "failed"
                  output = obj.stderr and obj.stderr ~= "" and obj.stderr
                    or string.format("Build failed: %s", target_opts.build_command)
                  target = dap.ABORT
                else
                  output = obj.stdout and obj.stdout ~= "" and obj.stdout or "Build successful."
                  target = target_opts.target_path or dap.ABORT
                end

                local lines = vim.split(output, vim.g.IN_WINDOWS and "\r?\n" or "\n")
                if lines[#lines] == "" then
                  table.remove(lines)
                end
                local i = 1
                local function process_queue()
                  if i <= #lines then
                    progress.percent = math.floor(100 / #lines * i)
                    if i == #lines and progress.status ~= "failed" then
                      progress.status = "success"
                    end

                    if vim.v.exiting == vim.NIL then
                      vim.api.nvim_echo({ { lines[i] } }, true, progress)
                    end

                    i = i + 1
                    vim.defer_fn(process_queue, 10)
                  else
                    coroutine.resume(dap_co, target)
                  end
                end
                process_queue()
              end)
            end)
          end)
        end

        local utils = require("utils.cpp")
        local build_options = utils.new(bufnr, { debug = true })

        local config_name
        if build_options and build_options and build_options.build_command then
          config_name = string.format(
            "Launch (codelldb) [%s]: %s",
            string.find(build_options.build_command, "^cmake") and "cmake" or "standalone",
            build_options.build_command
          )
        end
        return {
          build_options and {
            name = config_name,
            type = "codelldb",
            request = "launch",
            program = function()
              return compile_and_get_path(build_options)
            end,
            -- cwd = "${workspaceFolder}",
            cwd = build_options.root_dir,
            stopOnEntry = false,
          },
          {
            name = "Launch (codelldb): input executable path",
            type = "codelldb",
            request = "launch",
            program = prompt_for_target_path,
            cwd = "${workspaceFolder}",
            stopOnEntry = false,
          },
        }
      end

      local gdb_configs = {
        {
          name = "Launch (gdb): input executable path",
          type = "gdb",
          request = "launch",
          program = prompt_for_target_path,
          args = {}, -- provide arguments if needed
          cwd = "${workspaceFolder}",
          stopAtBeginningOfMainSubprogram = false,
        },
        {
          name = "Attach (gdb): filter running executable name",
          type = "gdb",
          request = "attach",
          program = prompt_for_target_path,
          pid = function()
            local name = vim.fn.input({ prompt = "Executable name (filter): ", completion = "file" })
            return require("dap.utils").pick_process({ filter = name })
          end,
          cwd = "${workspaceFolder}",
        },
        {
          name = "Attach (gdb) to gdbserver[localhost:2345]: input executable path",
          type = "gdb",
          request = "attach",
          target = "localhost:2345",
          program = prompt_for_target_path,
          cwd = "${workspaceFolder}",
        },
      }

      -- note: chrome has to be started with a remote debugging port
      -- google-chrome-stable --remote-debugging-port=9222
      local firefox_config = {
        name = "Launch (firefox): input debug url",
        type = "firefox",
        request = "launch",
        reAttach = true,
        url = function()
          return vim.fn.input({
            prompt = "Debug in Firefox URL: ",
            default = "http://localhost:5173",
          })
        end,
        webRoot = "${workspaceFolder}",
        firefoxExecutable = vim.fn.exepath("firefox"),
      }
      local pwa_chrome_config = {
        name = "Attach (chrome)",
        type = "pwa-chrome",
        request = "attach",
        program = "${file}",
        cwd = vim.fn.getcwd(),
        sourceMaps = true,
        protocol = "inspector",
        port = 9222,
        webRoot = "${workspaceFolder}",
      }
      local pwa_node_config = {
        name = "Launch file (node)",
        type = "pwa-node",
        request = "launch",
        program = "${file}",
        cwd = "${workspaceFolder}",
      }
      local deno_pwa_node_config = {
        name = "Launch file (deno)",
        type = "pwa-node",
        request = "launch",
        runtimeExecutable = "deno",
        runtimeArgs = {
          "run",
          "--inspect-wait",
          "--allow-all",
        },
        program = "${file}",
        cwd = "${workspaceFolder}",
        attachSimplePort = 9229,
      }
      local node_configs = { firefox_config, pwa_chrome_config, pwa_node_config, deno_pwa_node_config }

      local python_configs = function(bufnr)
        local python_executable
        if vim.env.VIRTUAL_ENV and vim.fs.normalize(vim.fn.exepath("python")) ~= "" then
          python_executable = vim.fs.normalize(vim.fn.exepath("python"))
        else
          local venv_path = vim.fs.find({ ".venv", "venv" }, {
            upward = true,
            stop = vim.fs.normalize("~"),
            type = "directory",
            path = vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr or 0)),
          })[1]
          python_executable = venv_path
            and string.format("%s/%s", venv_path, vim.g.IN_WINDOWS and "Scripts/python.exe" or "bin/python")
        end
        assert(
          python_executable and vim.fn.executable(python_executable) == 1,
          string.format("Dap: need a python path, got %s.", python_executable)
        )
        local root_dir = vim.fs.normalize(python_executable .. "/../../..")

        local default_opts = {
          type = "python",
          pythonPath = python_executable,
          console = "integratedTerminal", -- internalConsole: repl, integratedTerminal: dap-terminal, externalTerminal: external program
          cwd = root_dir,
          -- env = { PYTHONPATH = root_dir },
        }

        local partial_configs = {
          {
            -- type = "debugpy",
            request = "launch",
            name = "Launch (debugpy) for current buffer",
            -- @see https://github.com/microsoft/debugpy/wiki/Debug-configuration-settings
            program = "${file}",
            -- console = "internalConsole",
            -- pythonPath = default_opts.pythonPath,
            -- cwd = "${workspaceFolder}",
          },
          {
            request = "launch",
            name = "Launch (debugpy) for current buffer: input arguments",
            program = "${file}",
            args = function()
              local args_string = vim.fn.input("Arguments: ")
              return vim.split(args_string, " +")
            end,
          },
          {
            request = "attach",
            name = "Attach (debugpy)[127.0.0.1:5678]: input debug url",
            connect = function()
              local host = vim.fn.input("Host [127.0.0.1]: ")
              host = host ~= "" and host or "127.0.0.1"
              local port = tonumber(vim.fn.input("Port [5678]: ")) or 5678
              return { host = host, port = port }
            end,
          },
          {
            request = "launch",
            name = "Launch (debugpy) for current file: run doctests",
            module = "doctest",
            args = { "${file}" },
            noDebug = true,
          },
        }

        local resolved_configs = {}
        for _, config in pairs(partial_configs) do
          table.insert(resolved_configs, vim.tbl_extend("keep", config, default_opts))
        end

        return resolved_configs
      end

      local sh_configs = {
        {
          type = "bashdb",
          request = "launch",
          name = "Launch file (bashdb)",
          showDebugOutput = true,
          pathBashdb = string.format("%s/bash-debug-adapter/extension/bashdb_dir/bashdb", mason_packs),
          pathBashdbLib = string.format("%s/bash-debug-adapter/extension/bashdb_dir", mason_packs),
          trace = true,
          file = "${file}",
          program = "${file}",
          cwd = "${workspaceFolder}",
          pathCat = "cat",
          pathBash = "/bin/bash",
          pathMkfifo = "mkfifo",
          pathPkill = "pkill",
          args = {},
          argsString = "",
          env = {},
          terminalKind = "integrated",
        },
      }

      local dap_config_maps = {
        c = gdb_configs,
        cpp = codelldb_configs,
        javascript = node_configs,
        typescript = node_configs,
        javascriptreact = node_configs,
        typescriptreact = node_configs,
        sh = sh_configs,
        python = python_configs,
      }

      for debugger, adapter in pairs(dap_adapters) do
        dap.adapters[debugger] = adapter
      end

      for lang, config in pairs(dap_config_maps) do
        custom_dap_providers[lang] = config
      end
    end,
  },
}
