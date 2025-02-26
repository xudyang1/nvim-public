return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      -- vim.ui.select
      "nvim-telescope/telescope.nvim",
      -- fancy UI for the debugger
      {
        "rcarriga/nvim-dap-ui",
        dependencies = { "nvim-neotest/nvim-nio" },
        keys = {
          {
            "<Leader>gu",
            function()
              require("dapui").toggle({})
            end,
            desc = "Dap UI",
          },
          {
            "<Leader>ge",
            function()
              require("dapui").eval()
            end,
            desc = "Eval",
            mode = { "n", "x" },
          },
        },
        opts = {},
        config = function()
          local dap = require("dap")
          local dapui = require("dapui")
          dapui.setup({ log_level = "OFF" })
          dap.listeners.after.event_initialized.dapui_config = function()
            dapui.open({})
          end
          -- dap.listeners.before.event_terminated.dapui_config = function()
          --   dapui.close({})
          -- end
          -- dap.listeners.before.event_exited.dapui_config = function()
          --   dapui.close({})
          -- end
        end,
      },
      {
        "theHamsta/nvim-dap-virtual-text", -- virtual text for the debugger
        opts = {
          all_references = true, -- show virtual text on all all references of the variable (not only definitions)
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
      {
        "<Leader>gc",
        function()
          -- save before run dap
          vim.cmd("update")
          require("dap").continue()
        end,
        desc = "DAP: continue",
      },
      -- stylua: ignore start
      { "<Leader>gb", function() require("dap").toggle_breakpoint() end, desc = "DAP: toggle breakpoint" },
      { "<Leader>gB", function() require("dap").step_back() end,         desc = "DAP: step back"         },
      { "<Leader>gC", function() require("dap").run_to_cursor() end,     desc = "DAP: run to cursor"     },
      { "<Leader>go", function() require("dap").step_over() end,         desc = "DAP: step over"         },
      { "<Leader>gO", function() require("dap").step_out() end,          desc = "DAP: step out"          },
      { "<Leader>gi", function() require("dap").step_into() end,         desc = "DAP: step into"         },
      { "<Leader>gp", function() require("dap").pause() end,             desc = "DAP: pause"             },
      { "<Leader>gr", function() require("dap").repl.toggle() end,       desc = "DAP: repl toggle"       },
      { "<Leader>gR", function() require("dap").restart() end,           desc = "DAP: restart"           },
      { "<Leader>gs", function() require("dap").session() end,           desc = "DAP: session"           },
      { "<Leader>gt", function() require("dap").terminate() end,         desc = "DAP: terminate"         },
      { "<Leader>gk", function() require("dap").up() end,                desc = "DAP: up"                },
      { "<Leader>gj", function() require("dap").down() end,              desc = "DAP: down"              },
      { "<Leader>gl", function() require("dap").run_last() end,          desc = "DAP: run last"          },
      { "<Leader>gw", function() require("dap.ui.widgets").hover() end,  desc = "DAP: widget"            },
      -- stylua: ignore end
    },
    config = function()
      -- setup dap config by VsCode launch.json file
      local vscode = require("dap.ext.vscode")
      local json = require("plenary.json")
      -- nvim-dap defaults to vim.json.decode, which errors on comments
      vscode.json_decode = function(str)
        return vim.json.decode(json.json_strip_comments(str))
      end

      local dap = require("dap")
      local user_dap_configs = {}

      dap.providers.configs["user"] = function(bufnr)
        local filetype = vim.bo[bufnr].filetype
        local configurations = user_dap_configs[filetype] or {}
        if type(configurations) == "function" then
          configurations = configurations(bufnr)
        else
          assert(
            vim.islist(configurations),
            string.format(
              "`user_dap_config.%s` must be a function or a list of configurations, got %s",
              filetype,
              vim.inspect(configurations)
            )
          )
        end
        return configurations
      end

      local mason_packages = vim.fn.stdpath("data") .. "/mason/packages"

      local codelldb_path = mason_packages .. "/codelldb/extension/adapter/codelldb"
      if vim.g.IN_WINDOWS then
        codelldb_path = codelldb_path .. ".exe"
      end
      dap.adapters.codelldb = {
        type = "server",
        port = "${port}",
        -- host = "127.0.0.1",
        executable = {
          command = codelldb_path,
          args = { "--port", "${port}" },
        },
        -- on windows you may have to uncomment this:
        -- detached = not vim.g.IN_WINDOWS,
      }
      local codelldb_configuration = function(bufnr)
        local configs = {}
        local options = {}
        local compile_config = {
          name = "Launch (codelldb): " .. options.build_command,
          type = "codelldb",
          request = "launch",
          program = function()
            -- selene: allow(unused_variable)
            ---@diagnostic disable-next-line: unused-local
            local output = vim.api.nvim_exec2(options.build_command, { output = true }).output
            -- vim.notify(output, vim.log.levels.INFO)
            return options.target_path or dap.ABORT
          end,
          -- cwd = "${workspaceFolder}",
          cwd = options.root_dir,
          stopOnEntry = false,
        }
        table.insert(configs, compile_config)

        local custom_config = {
          name = "Launch (codelldb): custom executable",
          type = "codelldb",
          request = "launch",
          program = function()
            return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
          end,
          cwd = "${workspaceFolder}",
          stopOnEntry = false,
        }
        table.insert(configs, custom_config)

        return configs
      end
      user_dap_configs.c = codelldb_configuration
      user_dap_configs.cpp = codelldb_configuration

      local web_languages = { "javascript", "typescript", "javascriptreact", "typescriptreact" }
      local firefox_adapter = mason_packages .. "/firefox-debug-adapter/dist/adapter.bundle.js"
      local firefox = (vim.g.IN_WINDOWS and "C:/" or "/mnt/c/") .. "Program Files/Mozilla Firefox/firefox.exe"
      dap.adapters.firefox = {
        type = "executable",
        command = "node",
        args = { firefox_adapter },
      }
      local firefox_debug_config = {
        name = "Debug with Firefox",
        type = "firefox",
        request = "launch",
        reAttach = true,
        url = "http://localhost:3000",
        webRoot = "${workspaceFolder}",
        firefoxExecutable = firefox,
      }
      -- note: chrome has to be started with a remote debugging port
      -- google-chrome-stable --remote-debugging-port=9222
      local chrome_adapter = mason_packages .. "/chrome-debug-adapter/out/src/chromeDebug.js"
      dap.adapters.chrome = {
        type = "executable",
        command = "node",
        args = { chrome_adapter },
      }
      local chrome_debug_config = {
        type = "chrome",
        request = "attach",
        program = "${file}",
        cwd = vim.fn.getcwd(),
        sourceMaps = true,
        protocol = "inspector",
        port = 9222,
        webRoot = "${workspaceFolder}",
      }
      for _, lang in ipairs(web_languages) do
        dap.configurations[lang] = {}
        table.insert(dap.configurations[lang], firefox_debug_config)
        table.insert(dap.configurations[lang], chrome_debug_config)
      end

      local bin_python = vim.g.IN_WINDOWS and "/Scripts/python.exe" or "/bin/python"
      local debugpy_python = mason_packages .. "/debugpy/venv" .. bin_python
      dap.adapters.debugpy = function(callback, config)
        if config.request == "attach" then
          local port = (config.connect or config).port
          local host = (config.connect or config).host or "127.0.0.1"
          local adapter = {
            type = "server",
            port = assert(port, "`connect.port` is required for a python `attach` configuration"),
            host = host,
            options = {
              source_filetype = "python",
            },
            -- enrich_config = debugpy_enrich_config,
          }
          callback(adapter)
        else
          local adapter = {
            type = "executable",
            command = debugpy_python or config.pythonPath,
            args = { "-m", "debugpy.adapter" },
            options = {
              source_filetype = "python",
              detached = not vim.g.IN_WINDOWS,
            },
            -- enrich_config = debugpy_enrich_config,
          }
          callback(adapter)
        end
      end
      -- dap.adapters.debugpy = dap.adapters.python
      -- dap.configurations.python = {
      ---Get python executable from venv or .venv or nil
      ---@param bufname string current buffer name
      ---@return string? path to python executable
      local function get_python_path(bufname)
        if vim.env.VIRTUAL_ENV then
          return vim.fs.normalize(vim.env.VIRTUAL_ENV) .. bin_python
        end
        local venv_path = vim.fs.find({ "venv", ".venv" }, {
          upward = true,
          -- stops at $HOME/.., so search includes $HOME
          stop = vim.fs.normalize("~/.."),
          path = vim.fs.dirname(bufname),
        })[1]
        local python_path = venv_path and (venv_path .. bin_python)
        return python_path
      end
      user_dap_configs.python = function(bufnr)
        local bufname = vim.fs.normalize(vim.api.nvim_buf_get_name(bufnr))
        local python_executable = get_python_path(bufname)
        local root_dir = python_executable and vim.fs.normalize(python_executable .. "/../../..")
          or vim.fs.dirname(bufname)

        local default_opts = {
          type = "debugpy",
          -- debugpy supports launching an application with a different interpreter then the one used to launch debugpy itself.
          -- The code below looks for a `venv` or `.venv` folder in the current directly and uses the python within.
          -- You could adapt this - to for example use the `VIRTUAL_ENV` environment variable.
          pythonPath = python_executable or debugpy_python,
          -- nvim-dap default to integratedTerminal
          console = "integratedTerminal",
          cwd = root_dir,
          env = { PYTHONPATH = root_dir },
        }

        local configs = {
          {
            -- type = "debugpy",
            request = "launch",
            name = "Launch file (debugpy): " .. bufname,
            -- Options below are for debugpy, see https://github.com/microsoft/debugpy/wiki/Debug-configuration-settings for supported options
            program = "${file}", -- This configuration will launch the current file if used.
            -- console = "internalConsole", -- internalConsole: repl, integratedTerminal: dap-terminal, externalTerminal: external program
            -- pythonPath = default_opts.pythonPath,
            -- cwd = "${workspaceFolder}",
          },
          {
            request = "launch",
            name = "Launch file with arguments",
            program = "${file}",
            args = function()
              local args_string = vim.fn.input("Arguments: ")
              return vim.split(args_string, " +")
            end,
          },
          {
            request = "attach",
            name = "Attach debugpy remote: default [127.0.0.1:5678]",
            connect = function()
              local host = vim.fn.input("Host [127.0.0.1]: ")
              host = host ~= "" and host or "127.0.0.1"
              local port = tonumber(vim.fn.input("Port [5678]: ")) or 5678
              return { host = host, port = port }
            end,
          },
          {
            request = "launch",
            name = "Run doctests in file: " .. bufname,
            module = "doctest",
            args = { "${file}" },
            noDebug = true,
          },
        }

        local configurations = {}
        for _, config in pairs(configs) do
          table.insert(configurations, vim.tbl_extend("keep", config, default_opts))
        end

        return configurations
      end

      local bashdb_adapter_dir = mason_packages .. "/bash-debug-adapter"
      local bashdb_adapter = bashdb_adapter_dir .. "/bash-debug-adapter"
      local bashdb_dir = bashdb_adapter_dir .. "/extension/bashdb_dir"
      local bashdb = bashdb_dir .. "/bashdb"
      dap.adapters.bashdb = {
        type = "executable",
        command = bashdb_adapter,
        name = "bashdb",
      }
      dap.configurations.sh = {
        {
          type = "bashdb",
          request = "launch",
          name = "Launch file",
          showDebugOutput = true,
          pathBashdb = bashdb,
          pathBashdbLib = bashdb_dir,
          trace = true,
          file = "${file}",
          program = "${file}",
          cwd = "${workspaceFolder}",
          pathCat = "cat",
          pathBash = "/bin/bash",
          pathMkfifo = "mkfifo",
          pathPkill = "pkill",
          args = {},
          env = {},
          terminalKind = "integrated",
        },
      }
    end,
  },
}
