return {
  "L3MON4D3/LuaSnip",
  event = { "InsertEnter" },
  dependencies = { "rafamadriz/friendly-snippets" },
  build = "make install_jsregexp", -- optional
  keys = {
    { "<Leader>snb", desc = "Luasnip: Edit Snippet Files (Buf)" },
    { "<Leader>sna", desc = "Luasnip: Edit Snippet Files (All)" },
  },
  config = function()
    local luasnip = require("luasnip")

    luasnip.config.setup({
      keep_roots = true,
      link_roots = true,
      link_children = true,
      exit_roots = false, -- so that <C-k> works at last field
      update_events = "InsertLeave", -- default
      enable_autosnippets = true,
    })

    -- TODO: add more snippets to a filetype
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
    -- use full path to prevent loading firenvim package.json
    require("luasnip.loaders.from_vscode").lazy_load({
      paths = { vim.fn.stdpath("data") .. "/lazy/friendly-snippets" },
    })

    local handle_fallback = function(key)
      local t = function(str)
        return vim.api.nvim_replace_termcodes(str, true, true, true)
      end
      vim.api.nvim_feedkeys(t(key), "n", true)
    end
    local map = vim.keymap.set
    local mapIS = function(lhs, rhs, opts)
      if opts and opts.fallback then
        vim.keymap.set({ "i", "s" }, lhs, function()
          local handled = rhs()
          if handled == false then
            handle_fallback(lhs)
          end
        end)
      else
        vim.keymap.set({ "i", "s" }, lhs, rhs)
      end
    end

    mapIS("<C-j>", function()
      if luasnip.jumpable(-1) then
        luasnip.jump(-1)
      end
    end)

    mapIS("<C-k>", function()
      if luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      end
    end)

    mapIS("<C-i>", function()
      if luasnip.choice_active() then
        luasnip.change_choice(1)
      else
        return false
      end
    end, { fallback = true })

    mapIS("<S-Tab>", function()
      if luasnip.choice_active() then
        luasnip.change_choice(-1)
      end
    end)

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
          vim.cmd.split(file)
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
    map("n", "<Leader>snb", function()
      loader.edit_snippet_files(get_edit_option())
    end, { desc = "Luasnip: Edit Snippet Files (Buf)" })
    map("n", "<Leader>sna", function()
      require("luasnip.loaders").edit_snippet_files(get_edit_option(true))
    end, { desc = "Luasnip: Edit Snippet Files (All)" })
  end,
}
