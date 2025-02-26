return {
  -- TODO: more fine-tune modifications
  "saecki/crates.nvim",
  event = { "BufRead Cargo.toml" },
  enabled = vim.g.IN_LINUX,
  -- keys = {
  --   { "<leader>ct", desc = "Crates: toggle" },
  --   { "<leader>cr", desc = "Crates: reload" },
  --
  --   { "<leader>cv", desc = "Crates: show versions popup" },
  --   { "<leader>cf", desc = "Crates: show features popup" },
  --   { "<leader>cd", desc = "Crates: show dependencies popup" },
  --
  --   { "<leader>cu", desc = "Crates: update crate" },
  --   { mode = "x", "<leader>cu", desc = "Crates: update crates" },
  --   { "<leader>ca", desc = "Crates: update all crates" },
  --   { "<leader>cU", desc = "Crates: upgrade crate" },
  --   { mode = "x", "<leader>cU", desc = "Crates: upgrade crates" },
  --   { "<leader>cA", desc = "Crates: upgrade all crates" },
  --
  --   { "<leader>cx", desc = "Crates: expand plain crate to inline table" },
  --   { "<leader>cX", desc = "Crates: extract crate into table" },
  --
  --   { "<leader>cH", desc = "Crates: open homepage" },
  --   { "<leader>cR", desc = "Crates: open repository" },
  --   { "<leader>cD", desc = "Crates: open documentation" },
  --   { "<leader>cC", desc = "Crates: open crates io" },
  -- },
  config = function()
    vim.api.nvim_create_autocmd("BufRead", {
      group = vim.api.nvim_create_augroup("CmpSourceCargo", { clear = true }),
      pattern = "Cargo.toml",
      callback = function()
        local cmp = require("cmp")
        cmp.setup.buffer({
          sources = cmp.config.sources(
            { { name = "path" } },
            { { name = "nvim_lsp" }, { name = "luasnip" } },
            { { name = "nvim_lsp_signature_help" } },
            { { name = "buffer" } },
            { { name = "emoji" } },
            { { name = "crates" } }
          ),
        })
      end,
    })
    local crates = require("crates")
    crates.setup({
      thousands_separator = ",",
      on_attach = function(bufnr)
        vim.keymap.set("n", "K", function()
          if vim.fn.expand("%:t") == "Cargo.toml" and require("crates").popup_available() then
            require("crates").show_popup()
          else
            vim.lsp.buf.hover()
          end
        end, { desc = "Show Crate Documentation", buffer = bufnr })
      end,
      popup = {
        border = "rounded",
      },
      completion = {
        insert_closing_quote = true,
        text = {
          prerelease = "  pre-release ",
          yanked = "  yanked ",
        },
        cmp = {
          enabled = true,
        },
        crates = {
          enabled = true, -- disabled by default
        },
      },
      lsp = {
        enabled = true,
        ---@diagnostic disable-next-line: unused-local
        on_attach = function(_client, bufnr)
          local map = vim.keymap.set
          local opts = { silent = true, buffer = bufnr }

          map("n", "<leader>ct", crates.toggle, opts)
          map("n", "<leader>cr", crates.reload, opts)

          map("n", "<leader>cv", crates.show_versions_popup, opts)
          map("n", "<leader>cf", crates.show_features_popup, opts)
          map("n", "<leader>cd", crates.show_dependencies_popup, opts)

          map("n", "<leader>cu", crates.update_crate, opts)
          map("x", "<leader>cu", crates.update_crates, opts)
          map("n", "<leader>ca", crates.update_all_crates, opts)
          map("n", "<leader>cU", crates.upgrade_crate, opts)
          map("x", "<leader>cU", crates.upgrade_crates, opts)
          map("n", "<leader>cA", crates.upgrade_all_crates, opts)

          map("n", "<leader>cx", crates.expand_plain_crate_to_inline_table, opts)
          map("n", "<leader>cX", crates.extract_crate_into_table, opts)

          map("n", "<leader>cH", crates.open_homepage, opts)
          map("n", "<leader>cR", crates.open_repository, opts)
          map("n", "<leader>cD", crates.open_documentation, opts)
          map("n", "<leader>cC", crates.open_crates_io, opts)
          map("n", "<leader>cL", crates.open_lib_rs, opts)
        end,
        actions = true,
        completion = true,
        hover = true,
      },
    })
  end,
}
