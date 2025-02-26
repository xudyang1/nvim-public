return {
  "mrcjkb/rustaceanvim",
  event = { "BufRead *.rs", "BufNewFile *.rs" },
  -- ft = "rust",
  version = "^5", -- Recommended
  -- lazy = false, -- This plugin is already lazy
  enabled = vim.g.IN_LINUX,
  dependencies = { "williamboman/mason.nvim" },
  config = function()
    -- Update this path
    local extension_path = vim.fn.stdpath("data") .. "/mason/packages/codelldb/extension"
    local codelldb_path = extension_path .. "/adapter/codelldb"
    local liblldb_path = extension_path .. "/lldb/lib/liblldb"

    -- The path is different on Windows
    if vim.g.IN_WINDOWS then
      -- codelldb_path = extension_path .. "\\adapter\\codelldb.exe"
      -- liblldb_path = extension_path .. "\\lldb\\bin\\liblldb.dll"
      codelldb_path = codelldb_path .. ".exe"
      liblldb_path = extension_path .. "/lldb/bin/liblldb.dll"
    else
      -- The liblldb extension is .so for Linux and .dylib for MacOS
      liblldb_path = liblldb_path .. (vim.g.IN_LINUX and ".so" or ".dylib")
    end

    local cfg = require("rustaceanvim.config")

    vim.g.rustaceanvim = {
      -- Plugin configuration
      tools = {
        float_win_config = {
          border = "rounded",
        },
      },
      -- LSP configuration
      server = {
        -- auto_attach = bool | fun(bufnr: integer): bool,
        standalone = vim.g.started_by_firenvim,
        cmd = { "rust-analyzer" },
        -- TODO: more keymaps
        on_attach = function(_, bufnr)
          local map = vim.keymap.set
          map("n", "<leader>ca", function()
            -- vim.schedule(function()
            vim.cmd.RustLsp("codeAction")
            -- end)
          end, { desc = "RustLsp: Code Action", buffer = bufnr })
          -- slightly different than dap continue
          map("n", "<leader>gd", function()
            -- vim.schedule(function()
            vim.cmd.RustLsp("debuggables")
            -- end)
          end, { desc = "RustLsp: Debuggables", buffer = bufnr })
        end,
        default_settings = {
          -- rust-analyzer language server configuration
          ["rust-analyzer"] = {
            imports = {
              granularity = {
                -- enabled = true, -- default
                group = "module", -- "crate"(default),"module","item","preserve","one"
              },
              prefix = "self", -- "crate","self","plain"(default)
            },
            cargo = {
              -- pass `--all-features` to cargo
              features = "all",
              -- buildScripts = {
              --   enable = true, -- default
              -- },
            },
            check = {
              command = "clippy",
              -- extra check
              extraArgs = {
                "--",
                "-W",
                "clippy::pedantic",
              },
              -- defaults to `rust-analyzer.cargo.features`
              -- features = "all"
            },
            -- checkOnSave = true, -- default
            diagnostics = {
              -- default
              enable = true,
              -- experimental = {
              --   enable = true, -- default false
              -- },
            },
            -- procMacro = {
            --   enable = true, -- default
            --   ignored = {
            --     ["async-trait"] = { "async_trait" },
            --     ["napi-derive"] = { "napi" },
            --     ["async-recursion"] = { "async_recursion" },
            --   },
            -- },
          },
        },
      },
      -- DAP configuration
      dap = {
        adapter = cfg.get_codelldb_adapter(codelldb_path, liblldb_path),
      },
    }
  end,
}
