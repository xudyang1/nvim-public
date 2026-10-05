return {
  "neovim/nvim-lspconfig",
  -- event = vim.fn.argc(-1) > 0 and { "BufReadPost", "BufNewFile" } or "VeryLazy",
  event = "VeryLazy",
  dependencies = { "williamboman/mason.nvim", "b0o/schemastore.nvim" },
  opts = {
    ensure_enabled = {
      "lua_ls",
      "bashls",
      -- "rust_analyzer", -- use rustaceanvim
      "clangd",
      "neocmake",
      "cssls",
      "cssmodule_ls",
      "emmet_language_server",
      "eslint",
      -- "gh_actions_ls",
      "html",
      "jsonls",
      "lua_ls",
      "marksman",
      "pyright",
      "ruff",
      "tailwindcss",
      "taplo",
      vim.g.IN_LINUX and "terraformls" or nil,
      "tsc",
      "typos_lsp",
      "yamlls",
    },
  },
  config = function(_, opts)
    -- prepend mason.nvim path if remove mason.nvim in dependency
    -- local path_sep = vim.g.IN_WINDOWS and ";" or ":"
    -- vim.env.PATH = string.format("%s/mason/bin%s%s", vim.fn.stdpath("data"), path_sep, vim.env.PATH)

    local lsp = vim.lsp
    lsp.log.set_level(vim.log.levels.OFF)

    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("CustomLspConfig", { clear = true }),
      desc = "Custom LspAttach Autocmd",
      callback = function(event)
        local buf = event.buf
        local max_line_count = 5000
        if vim.api.nvim_buf_line_count(buf) > max_line_count then
          vim.schedule(function()
            vim.lsp.buf_detach_client(buf, event.data.client_id)
            vim.notify("LSP disabled: file exceeds 5000 lines limit.", vim.log.levels.WARN)
          end)
          return
        end
        local client = lsp.get_client_by_id(event.data.client_id)
        if not client then
          return
        end
        -- disable lsp semantic token highlight
        if client.server_capabilities then
          client.server_capabilities.semanticTokensProvider = nil
        end
        if vim.b[buf].lsp_keymaps_attached then
          return
        end
        vim.b[buf].lsp_keymaps_attached = true

        -- vim.o.omnifunc = "v:lua.vim.lsp.omnifunc"

        local lsp_buf = lsp.buf

        -- TODO: quickfix vs loclist
        -- stylua: ignore start
        local keymaps = {
          -- { "n",          "K",          function() lsp_buf.hover({ border = "single" }) end,                 "LSP: hover" },
          { "n",          "gd",         function() lsp_buf.definition({ loclist = true }) end,               "LSP: jump to definition" },
          { "n",          "gD",         function() lsp_buf.declaration({ loclist = true }) end,              "LSP: jump to declaration" },
          { "n",          "gI",         function() lsp_buf.implementation({ loclist = true }) end,           "LSP: list implementations" },
          { "n",          "<C-k>",      function() lsp_buf.type_definition({ loclist = true }) end,          "LSP: jump to type definition" },
          { "n",          "gR",         function() lsp_buf.references() end,                                 "LSP: list references" },
          { "n",          "gs",         function() lsp_buf.signature_help() end,                             "LSP: signature help" },
          { "n",          "<leader>rn", function() lsp_buf.rename() end,                                     "LSP: rename" },
          { "n",          "<leader>cl", function() vim.lsp.codelens.run() end,                               "LSP: codelens run" },
          { { "n", "x" }, "<leader>ca", function() lsp_buf.code_action() end,                                "LSP: code action" },
          { { "n", "x" }, "<leader>F",  function() lsp_buf.format({ async = true }) end,                     "LSP: format" },
          { "n",          "<Leader>ci", function() lsp_buf.incoming_calls() end,                             "LSP: list incoming calls" },
          { "n",          "<Leader>co", function() lsp_buf.outgoing_calls() end,                             "LSP: list outgoing calls" },
          { "n",          "<Leader>gH", function() lsp_buf.typehierarchy("supertypes") end,                  "LSP: list supertypes" },
          { "n",          "<Leader>gh", function() lsp_buf.typehierarchy("subtypes") end,                    "LSP: list subtypes" },
          { "n",          "<leader>lw", function() print(vim.inspect(lsp_buf.list_workspace_folders())) end, "LSP: list workspace folders" },
          -- { "n",          "<leader>wa", function() lsp_buf.add_workspace_folder() end,                       "LSP: add workspace folder" },
          -- { "n",          "<leader>wr", function() lsp_buf.remove_workspace_folder() end,                    "LSP: remove workspace folder" },
          -- { "n",          "gO",         function() lsp_buf.document_symbol() end,                            "LSP: list document symbols" },
          -- { "n",          "<leader>ws", function() lsp_buf.workspace_symbol() end,                           "LSP: list workspace symbols" },
          -- { "i",          "<C-Space>",  function() vim.lsp.completion.get() end,                             "LSP: trigger completion" },
          -- { "n",          "",           function() Client:execute_command(cmd, context, handler) end,        "LSP: execute command"},
          -- { "n",          "",           function() lsp_buf.document_highlight() end,                         "LSP: resolve highlight" },
          -- { "n",          "",           function() lsp_buf.clear_references() end,                           "LSP: clear highlight" },
        }
        -- stylua: ignore end
        local map = vim.keymap.set
        for _, args in ipairs(keymaps) do
          map(args[1], args[2], args[3], { buf = buf, desc = args[4] })
        end
      end,
    })

    local lsp_capabilities = lsp.protocol.make_client_capabilities()
    -- local lsp_capabilities = require("blink.cmp").get_lsp_capabilities({})
    lsp.config("*", { capabilities = lsp_capabilities })
    lsp.enable(opts.ensure_enabled)
  end,
}
