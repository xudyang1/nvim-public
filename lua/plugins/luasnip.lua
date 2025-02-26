return {
  "L3MON4D3/LuaSnip",
  dependencies = { "rafamadriz/friendly-snippets" },
  -- install jsregexp (optional!).
  build = vim.g.IN_WINDOWS and "make install_jsregexp CC=gcc" or "make install_jsregexp",
  keys = {
    { "<Leader>lse", desc = "Luasnip: Edit Snippet Files (Buf)" },
    { "<Leader>lsa", desc = "Luasnip: Edit Snippet Files (All)" },
  },
  config = function()
    local luasnip = require("luasnip")

    -- local types = require("luasnip.util.types")
    luasnip.config.setup({
      -- deprecated, if not nil, keep_roots, link_roots, link_children will be set to the value of history
      -- history = true,
      keep_roots = true,
      link_roots = true,
      link_children = true,
      -- so that <C-k> works at last field
      exit_roots = false,
      -- default
      update_events = "InsertLeave",
      -- update_events = {"TextChanged", "TextChangedI"},
      -- region_check_events = "InsertEnter" -- disabled by default
      -- delete_check_events = "InsertLeave" -- disabled by default
      enable_autosnippets = true,
    })

    local ft_extends = {
      all = { "loremipsum" },
      lua = { "luadoc" },
      c = { "cdoc" },
      cpp = { "cppdoc" },
      rust = { "rustdoc" },
      python = { "pydoc" },
      sh = { "shelldoc" },
      javascript = { "jsdoc" },
      typescript = { "javascript", "tsdoc" },
      javascriptreact = { "javascript", "jsdoc" },
      typescriptreact = { "javascript", "tsdoc" },
    }
    for ft, extends in pairs(ft_extends) do
      luasnip.filetype_extend(ft, extends)
    end

    -- use .nvim.lua and set exrc=true for project local config
    -- local ft_add_frameworks = {
    --   javascriptreact = { "angular" },
    --   typescriptreact = { "angular" },
    -- }
    -- for ft, frameworks in pairs(ft_add_frameworks) do
    --   luasnip.filetype_extend(ft, frameworks)
    -- end

    -- lazy load custom snippets
    require("luasnip.loaders.from_vscode").lazy_load({
      paths = { "~/.config/nvim/snippets/vscode/" },
      default_priority = 2000,
    })
    require("luasnip.loaders.from_lua").lazy_load({
      paths = { "~/.config/nvim/snippets/luasnip" },
      default_priority = 2000,
    })
    -- lazy load friendly-snippets
    -- require("luasnip.loaders.from_vscode").lazy_load()
    -- prevent mistakenly loading firenvim package.json
    require("luasnip.loaders.from_vscode").lazy_load({
      paths = { vim.fn.stdpath("data") .. "/lazy/friendly-snippets" },
    })

    local map = vim.keymap.set

    map({ "i", "s" }, "<C-j>", function()
      if luasnip.jumpable(-1) then
        luasnip.jump(-1)
      end
    end, { silent = true })

    map({ "i", "s" }, "<C-k>", function()
      if luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      end
    end, { silent = true })

    map({ "i", "s" }, "<C-l>", function()
      if luasnip.choice_active() then
        luasnip.change_choice(1)
      end
    end, { silent = true })

    local loader = require("luasnip.loaders")

    -- escape lua magic characters ( ) . % + - * ? [ ^ $
    local plugin_snip_path =
      string.format("^%s/", vim.pesc(vim.fn.stdpath("data") .. "/lazy/friendly-snippets/snippets"))
    local user_snip_path = string.format("^%s/", vim.pesc(vim.fs.normalize("~/.config/nvim/snippets")))

    ---Get edit_snippet_files option
    ---@param all boolean?
    ---@return table
    local get_edit_option = function(all)
      return {
        ft_filter = function(ft)
          if all then
            return ft ~= "" and ft ~= "man" and ft ~= "help"
          end
          return ft ~= "" and ft == vim.bo.filetype and ft ~= "man" and ft ~= "help"
        end,
        edit = function(file)
          vim.cmd("split " .. file)
        end,
        -- selene: allow(unused_variable)
        ---@diagnostic disable-next-line: unused-local
        extend = function(ft, files)
          local extended_items = {}
          local snippet_collections = {
            -- luasnip
            {
              dir = vim.fs.normalize("~/.config/nvim/snippets/luasnip"),
              source = "lua",
              file_ext = "lua",
            },
            -- vscode
            {
              dir = vim.fs.normalize("~/.config/nvim/snippets/vscode"),
              source = "vscode",
              file_ext = "json",
            },
          }
          for _, collection in ipairs(snippet_collections) do
            local file = string.format("%s.%s", ft, collection.file_ext)
            if not vim.fs.find(file, { path = collection.dir })[1] then
              local path = string.format("%s/%s", collection.dir, file)
              table.insert(extended_items, {
                string.gsub(path, user_snip_path, string.format("Create (%s): ", collection.source)),
                path,
              })
            end
          end
          return extended_items
        end,
        format = function(path, source)
          path = string.gsub(path, plugin_snip_path, string.format("Plugin (%s): ", source))
          path = string.gsub(path, user_snip_path, string.format("Custom (%s): ", source))
          return path
        end,
      }
    end
    map("n", "<Leader>lse", function()
      loader.edit_snippet_files(get_edit_option())
    end, { desc = "Luasnip: Edit Snippet Files (Buf)" })
    map("n", "<Leader>lsa", function()
      require("luasnip.loaders").edit_snippet_files(get_edit_option(true))
    end, { desc = "Luasnip: Edit Snippet Files (All)" })
  end,
}
