return {
  "neovim/nvim-lspconfig",
  event = "VeryLazy",
  dependencies = {
    "williamboman/mason.nvim",
    "b0o/schemastore.nvim", -- for jsonls and yamlls
    -- "williamboman/mason-lspconfig.nvim", -- Optional
  },
  keys = {
    { "<Leader>li", "<Cmd>LspInfo<Cr>", desc = "LspInfo" },
  },
  config = function()
    local lsp = vim.lsp

    -- vim.lsp.set_log_level("ERROR")
    lsp.set_log_level("OFF")

    vim.api.nvim_create_autocmd("LspAttach", {
      -- from lspconfig
      group = vim.api.nvim_create_augroup("UserLspConfig", {}),
      desc = "LSP actions",
      callback = function(event)
        -- Enable completion triggered by <c-x><c-o>
        -- vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

        lsp.handlers["textDocument/hover"] = lsp.with(lsp.handlers.hover, { border = "rounded" })
        lsp.handlers["textDocument/signatureHelp"] = lsp.with(lsp.handlers.signature_help, { border = "rounded" })

        local opts = { buffer = event.buf }
        local map = vim.keymap.set
        local lsp_buf = lsp.buf

        -- default to vim.lsp.buf.hover, lazy loading lsp may overwrite bufread crate.nvim keymaps
        -- map("n", "K", lsp_buf.hover, opts)
        map("n", "gd", lsp_buf.definition, opts)
        map("n", "gD", lsp_buf.declaration, opts)
        map("n", "gI", lsp_buf.implementation, opts)
        map("n", "<C-k>", lsp_buf.type_definition, opts)
        map("n", "gh", lsp_buf.typehierarchy, opts)
        map("n", "<Leader>gH", function()
          lsp_buf.typehierarchy("supertypes")
        end, opts)
        map("n", "<Leader>gh", function()
          lsp_buf.typehierarchy("subtypes")
        end, opts)
        map("n", "gr", lsp_buf.references, opts)
        map("n", "gs", lsp_buf.signature_help, opts)
        map("n", "<leader>rn", lsp_buf.rename, opts)
        map({ "n", "x" }, "<leader>ca", lsp_buf.code_action, opts)
        map({ "n", "x" }, "<leader>=", function()
          lsp_buf.format({ async = true })
        end, opts)
        map("n", "<Leader>ci", lsp_buf.incoming_calls, opts)
        map("n", "<Leader>co", lsp_buf.outgoing_calls, opts)
        map("n", "<leader>wa", lsp_buf.add_workspace_folder, opts)
        map("n", "<leader>wr", lsp_buf.remove_workspace_folder, opts)
        map("n", "<leader>wl", function()
          print(vim.inspect(lsp_buf.list_workspace_folders()))
        end, opts)
        -- more handlers, but not useful
        -- map("n", "go", lsp_buf.document_symbol, opts)
        -- map("n", "<leader>ws", lsp_buf.workspace_symbol, opts)
        -- map("n", "", lsp_buf.completion, opts)
        -- map("n", "", lsp_buf.execute_command, opts)
        -- map("n", "", lsp_buf.document_highlight, opts)
        -- map("n", "", lsp_buf.clear_references, opts)
      end,
    })

    local lspconfig = require("lspconfig")

    require("lspconfig.ui.windows").default_options.border = "rounded"

    local lsp_capabilities = require("cmp_nvim_lsp").default_capabilities()

    lspconfig.lua_ls.setup({
      capabilities = lsp_capabilities,
      settings = {
        Lua = {
          hint = {
            enable = true,
          },
          runtime = {
            version = "LuaJIT",
          },
          diagnostics = {
            globals = { "vim" },
          },
          workspace = {
            library = {
              vim.fs.normalize(vim.env.VIMRUNTIME),
            },
          },
          completion = {
            callSnippet = "Replace",
          },
        },
      },
    })

    -- do not insert header in firenvim
    local header_insertion_option = vim.g.started_by_firenvim and "never" or "iwyu"

    -- in windows with gnu gcc
    -- architectures: "--target=x86_64-w64-mingw64" or "x86_64-w64-mingw32"("x86_64-w64-windows-gnu")
    local target_architecture = (function()
      if vim.g.IN_WINDOWS then
        return "--target=x86_64-w64-mingw32"
      elseif vim.g.IN_LINUX then
        return "--target=x86_64-linux-gnu"
      else
        vim.notify(
          "cpp compiler target not set, please set target architecture for current platform for lsp clangd:"
            .. "\n"
            .. debug.traceback(),
          vim.log.levels.ERROR
        )
      end
    end)()

    local with_conversion = not vim.g.started_by_firenvim and "-Wconversion" or nil

    lspconfig.clangd.setup({
      capabilities = lsp_capabilities,
      cmd = {
        "clangd",
        "--all-scopes-completion",
        "--header-insertion=" .. header_insertion_option,
        -- "--background-index=false",
        "--fallback-style=LLVM", -- set to webkit for 4-space indent
        "--completion-style=detailed",
        "--pch-storage=memory",
        "--query-driver=" .. vim.fn.exepath(vim.g.IN_WINDOWS and "g++.exe" or "g++"), -- may resolve [fe_expected_compiler_job]
        -- "--compile-commands-dir=./build",
        -- "--compile_args_from=lsp", -- or filesystem
        -- "--pretty",
        -- "--clangd-tidy", -- BUG: results in client exit with 1
      },
      init_options = {
        fallbackFlags = {
          target_architecture,
          "-Wall",
          -- "-Werror",
          "-Wextra",
          "-Wshadow",
          "-pedantic",
          "-Wfloat-equal",
          "-Wno-unused-const-variable",
          "-Wno-sign-conversion",
          "-fsanitize=address",
          "-fsanitize=undefined",
          "-fno-sanitize-recover",
          "-O2",
          "-xc++",
          "-std=c++17", -- -std=c++20 is a bit slower
          with_conversion,
          -- "-Wno-missing-prototypes", -- only in c or obj-c
        },
      },
      on_attach = function(client)
        local is_inside_project = vim.fs.root(0, { "CMakeLists.txt", ".clangd" })
        local background_index_option = "--background-index=%s" .. (is_inside_project and "true" or "false")
        table.insert(client.config.cmd, background_index_option)
      end,
      -- single_file_support = true,
    })

    -- lspconfig.cmake.setup({
    --   capabilities = lsp_capabilities,
    --   -- root_dir = lspconfig.util.root_pattern('CMakePresets.json', 'CTestConfig.cmake', '.git', 'build', 'cmake')
    -- })

    lspconfig.marksman.setup({
      capabilities = lsp_capabilities,
      -- prevent adding `[ERROR]: Starting Marksman LSP server` to lsp.log
      cmd = {
        "marksman",
        "server",
        "-v=1",
      },
      -- root_dir = lspconfig.util.root_pattern(".git", ".marksman.toml", ".")
      -- single_file_support = true,
    })

    lspconfig.taplo.setup({
      capabilities = lsp_capabilities,
      -- toml schema autocomplete?
      -- @see: https://www.reddit.com/r/neovim/comments/15xsx3t/schema_validation_for_toml_files/
    })

    lspconfig.jsonls.setup({
      capabilities = lsp_capabilities,
      settings = {
        json = {
          validate = { enable = true },
          schemas = require("schemastore").json.schemas(),
        },
      },
    })

    lspconfig.yamlls.setup({
      capabilities = lsp_capabilities,
      settings = {
        yaml = {
          -- schemastore.nvim
          schemaStore = {
            -- You must disable built-in schemaStore support if you want to use
            -- this plugin and its advanced options like `ignore`.
            enable = false,
            -- Avoid TypeError: Cannot read properties of undefined (reading 'length')
            url = "",
          },
          schemas = require("schemastore").yaml.schemas({}),
        },
      },
    })

    if vim.g.IN_LINUX then
      lspconfig.terraformls.setup({
        capabilities = lsp_capabilities,
      })
      -- lspconfig.hcl.setup({ capabilities = lsp_capabilities })
    end

    -- Work around: rename filename.postcss to filename.css or filename.postcss.css
    -- vim.filetype.add({
    --   extension = {
    --     postcss = "css",
    --   },
    -- })
    lspconfig.emmet_language_server.setup({
      capabilities = lsp_capabilities,
      -- init_options = {
      --   includeLanguages = {
      --     postcss = "css"
      --   }
      -- }
    })

    -- too much lsp used in web languages
    lspconfig.html.setup({
      capabilities = lsp_capabilities,
      -- autostart = false,
    })

    lspconfig.cssls.setup({
      capabilities = lsp_capabilities,
      -- init_options
      settings = {
        css = {
          lint = {
            unknownAtRules = "ignore",
          },
        },
        scss = {
          lint = {
            unknownAtRules = "ignore",
          },
        },
        less = {
          lint = {
            unknownAtRules = "ignore",
          },
        },
      },
    })
    lspconfig.cssmodules_ls.setup({
      capabilities = lsp_capabilities,
    })
    lspconfig.tailwindcss.setup({
      capabilities = lsp_capabilities,
      -- selene: allow(unused_variable)
      ---@diagnostic disable-next-line: unused-local
      root_dir = function(filename, bufnr)
        local patterns = {
          "tailwind.config.js",
          "tailwind.config.cjs",
          "tailwind.config.mjs",
          "tailwind.config.ts",
          "postcss.config.js",
          "postcss.config.cjs",
          "postcss.config.mjs",
          "postcss.config.ts",
        }
        return vim.fs.root(filename, patterns)
      end,
      filetypes = vim.tbl_filter(function(ft)
        return ft ~= "markdown" and ft ~= "mdx"
      end, lspconfig.tailwindcss.config_def.default_config.filetypes),
    })

    lspconfig.eslint.setup({
      capabilities = lsp_capabilities,
    })

    -- TODO: try vtsls.nvim
    lspconfig.ts_ls.setup({
      capabilities = lsp_capabilities,
      -- from https://lsp-zero.netlify.app/v3.x/language-server-configuration.html
      -- Sometimes you might want to prevent Neovim from using a language server as a formatter.
      -- For this you can use the on_init hook to modify the client instance.
      on_init = function(client)
        client.server_capabilities.documentFormattingProvider = false
        client.server_capabilities.documentFormattingRangeProvider = false
      end,
    })

    lspconfig.bashls.setup({
      capabilities = lsp_capabilities,
      settings = {
        bashIde = {
          shellcheckPath = "",
          shellcheckArguments = "",
          shfmt = {
            path = "",
            ignoreEditorconfig = false,
          },
        },
      },
    })

    lspconfig.ruff.setup({
      capabilities = lsp_capabilities,
      -- init_options = {
      --   settings = {},
      -- },
      -- If you're using Ruff alongside another LSP (like Pyright),
      -- you may want to defer to that LSP for certain capabilities, like textDocument/hover:
      -- selene: allow(unused_variable)
      ---@diagnostic disable-next-line: unused-local
      on_attach = function(client, bufnr)
        if client.name == "ruff" then
          -- Disable hover in favor of (based)pyright
          client.server_capabilities.hoverProvider = false
        end
      end,
    })

    -- If you'd like to use Ruff exclusively for linting, formatting, and import organization,
    -- you can disable those capabilities for Pyright:
    lspconfig.pyright.setup({
      capabilities = lsp_capabilities,
      settings = {
        pyright = {
          -- Using Ruff's import organizer
          disableOrganizeImports = true,
        },
        python = {
          analysis = {
            exclude = {
              "**/node_modules",
              "**/__pycache__",
              "**/.venv",
              "**/venv",
              "**/.*",
            },
            ignore = {
              -- Ignore all files for analysis to exclusively use Ruff for linting
              -- "*",
              "**/node_modules",
              "**/__pycache__",
              "**/.venv",
              "**/venv",
              -- "**/.*",
            },
            autoSearchPaths = true,
            useLibraryCodeForTypes = true,
            diagnosticMode = "openFilesOnly",
          },
        },
      },
      on_attach = function(client)
        local venv_path = vim.fs.find({ "venv", ".venv" }, {
          upward = true,
          -- stops at $HOME/.., so search includes $HOME
          stop = vim.fs.normalize("~/.."),
          path = vim.fs.dirname(vim.api.nvim_buf_get_name(0)),
        })[1]
        if venv_path then
          client.config.settings.python = client.config.settings.python or {}
          -- client.config.settings.python.venvPath = vim.fn.fnamemodify(venv_path, "%:h")
          -- client.config.settings.python.venv = vim.fn.fnamemodify(venv_path, "%:t")
          client.config.settings.python.pythonPath = venv_path .. "/bin/python"
        end
      end,
    })

    vim.cmd("LspStart")
  end,
}
