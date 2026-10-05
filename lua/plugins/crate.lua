return {
  "saecki/crates.nvim",
  event = { "BufRead Cargo.toml" },
  enabled = vim.g.IN_LINUX,
  config = function()
    local crates = require("crates")
    crates.setup({
      thousands_separator = ",",
      --   keys = {
      --     hide = { "q", "<esc>" },
      --     open_url = { "<cr>" },
      --     select = { "<cr>" },
      --     select_alt = { "s" },
      --     toggle_feature = { "<cr>" },
      --     copy_value = { "yy" },
      --     goto_item = { "gd", "K", "<C-LeftMouse>" },
      --     jump_forward = { "<c-i>" },
      --     jump_back = { "<c-o>", "<C-RightMouse>" },
      --   },
      -- },
      completion = {
        crates = {
          enabled = true,
        },
      },
      lsp = {
        enabled = true,
        hover = true,
        actions = true,
        completion = true,
        on_attach = function(_, bufnr)
          local keymaps = {
            { "<Leader>ct", crates.toggle, "toggle" },
            { "<Leader>cr", crates.reload, "reload" },

            { "<Leader>cv", crates.show_versions_popup, "show versions" },
            { "<Leader>cf", crates.show_features_popup, "show features" },
            { "<Leader>cd", crates.show_dependencies_popup, "show dependencies" },

            { "<Leader>cu", crates.update_crate, "update" },
            { mode = "x", "<Leader>cu", crates.update_crates, "update" },
            { "<Leader>cAu", crates.update_all_crates, "update all" },
            { "<Leader>cU", crates.upgrade_crate, "upgrade" },
            { mode = "x", "<Leader>cU", crates.upgrade_crates, "upgrade" },
            { "<Leader>cAU", crates.upgrade_all_crates, "upgrade all" },

            { "<Leader>cx", crates.expand_plain_crate_to_inline_table, "expand to inline table" },
            { "<Leader>cX", crates.extract_crate_into_table, "extract to table" },

            { "<Leader>cH", crates.open_homepage, "open homepage" },
            { "<Leader>cR", crates.open_repository, "open repository" },
            { "<Leader>cD", crates.open_documentation, "open documentation" },
            { "<Leader>cC", crates.open_crates_io, "open crates.io" },
            { "<Leader>cL", crates.open_lib_rs, "open lib.rs" },
          }
          local map = vim.keymap.set
          for _, keymap in ipairs(keymaps) do
            map(keymap.mode or "n", keymap[1], keymap[2], { desc = "Crate: " .. keymap[3], buf = bufnr })
          end
        end,
      },
    })
  end,
}
