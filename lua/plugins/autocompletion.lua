return {
  "saghen/blink.cmp",
  event = { "InsertEnter", "CmdlineEnter" },
  dependencies = { "saghen/blink.lib", "L3MON4D3/LuaSnip", "becknik/blink-cmp-luasnip-choice" },
  build = function()
    if vim.g.IN_WINDOWS then
      require("blink.cmp").download({ match = "v*" }):pwait(5000)
    else
      require("blink.cmp").build():pwait(30000)
    end
  end,
  opts = {
    snippets = { preset = "luasnip" },
    sources = {
      providers = {
        choice = {
          name = "LuaSnip Choice Nodes",
          module = "blink-cmp-luasnip-choice",
          opts = {},
        },
      },
      default = { "choice", "lsp", "path", "snippets", "buffer" },
    },
    -- fuzzy = { sorts = { "score", "sort_text" } },
    -- signature = { enabled = true, trigger = { enabled = true, show_on_insert = true } },
    keymap = {
      preset = "none",
      ["<C-n>"] = { "show", "select_next", "fallback_to_mappings" },
      ["<C-p>"] = { "show", "select_prev", "fallback_to_mappings" },
      ["<C-e>"] = { "cancel", "fallback" }, -- { "hide", "fallback" },
      ["<C-y>"] = { "select_and_accept", "fallback" },
      ["<C-u>"] = {
        function(cmp)
          if cmp.is_documentation_visible() then
            cmp.scroll_documentation_up(4)
            return true
          end
          return false
        end,
        "fallback",
      },
      ["<C-d>"] = {
        function(cmp)
          if cmp.is_documentation_visible() then
            cmp.scroll_documentation_down(4)
            return true
          end
          return false
        end,
        "fallback",
      },
      ["<C-i>"] = {
        -- "snippet_forward",
        function(cmp)
          if cmp.is_menu_visible() then
            if cmp.is_documentation_visible() then
              cmp.hide_documentation()
            else
              cmp.show_documentation()
            end
            return true
          end
          return false
        end,
        "fallback",
      },
      -- ["<S-Tab>"] = { "snippet_backward", "fallback" },
    },
    completion = {
      ghost_text = { enabled = true, show_with_menu = true, show_without_selection = true },
      documentation = { auto_show = true },
      list = { selection = { preselect = false, auto_insert = true } },
      menu = {
        auto_show = false,
        draw = {
          columns = { { "label", "label_description", gap = 1 }, { "kind" } },
          -- components = {
          --   label = { width = { fill = true, max = 60 } },
          --   kind = {
          --     text = function(ctx) return ctx.kind end,
          --     highlight = "BlinkCmpKind",
          --   },
          -- },
        },
      },
    },
    -- cmdline = { completion = { menu = { auto_show = true } } },
  },
}
