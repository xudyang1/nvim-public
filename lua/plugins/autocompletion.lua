return {
  {
    "hrsh7th/nvim-cmp",
    -- event = "VeryLazy",
    event = { "InsertEnter", "CmdlineEnter" },
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-nvim-lsp-signature-help",
      "hrsh7th/cmp-cmdline",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-emoji",
      "saadparwaiz1/cmp_luasnip",
      "L3MON4D3/LuaSnip",
      {
        "L3MON4D3/cmp-luasnip-choice",
        config = function()
          require("cmp_luasnip_choice").setup({ auto_open = true })
        end,
      },
    },
    config = function()
      local cmp = require("cmp")
      cmp.setup({
        formatting = {
          fields = { "abbr", "kind", "menu" },
          format = function(entry, item)
            local source_name = entry.source.name
            -- set the additional menu text
            local menu_icon = {
              nvim_lsp = "[LSP]",
              luasnip = "[Snip]",
              buffer = "[Buf]",
              path = "[Path]",
            }
            item.menu = menu_icon[source_name]

            if item.kind == "Color" then
              local color_item = require("nvim-highlight-colors").format(entry, item)
              item = {
                abbr = color_item.kind,
                dup = color_item.dup,
                -- kind = "■■■■",
                kind = "󰝤󰝤󰝤󰝤",
                kind_hl_group = color_item.abbr_hl_group,
                menu = menu_icon[source_name],
                word = color_item.word,
              }
            end

            local content = item.abbr

            local win_width = vim.api.nvim_win_get_width(0)
            local max_width = math.floor(win_width * 0.25)
            local width_threshold = 16
            max_width = max_width < width_threshold and width_threshold or max_width

            local ELLIPSIS_CHAR = "…"
            if #content > max_width then
              item.abbr = string.sub(content, 1, max_width - 1) .. ELLIPSIS_CHAR
            end
            return item
          end,
        },
        experimental = {
          ghost_text = true, -- this feature conflict with copilot.vim's preview.
        },
        window = {
          completion = cmp.config.window.bordered(),
          -- align the abbr and word on cursor
          -- completion = cmp.config.window.bordered({ col_offset = -1 }),
          documentation = cmp.config.window.bordered(),
        },
        sources = cmp.config.sources(
          { { name = "path" } },
          { { name = "nvim_lsp" }, { name = "luasnip" }, { name = "luasnip_choice" } },
          { { name = "nvim_lsp_signature_help" } },
          { { name = "buffer" } },
          { { name = "emoji" } }
        ),
        mapping = {
          ["<C-y>"] = {
            i = cmp.mapping.confirm({ select = true }),
            c = cmp.mapping.confirm({ select = true }),
          },
          ["<C-e>"] = {
            i = cmp.mapping.abort(),
            c = cmp.mapping.abort(),
          },
          ["<C-p>"] = {
            i = function()
              if cmp.visible() then
                cmp.select_prev_item({ behavior = "insert" })
                -- cmp.select_prev_item({ behavior = 'select' })
              else
                cmp.complete()
              end
            end,
          },
          ["<C-n>"] = {
            i = function()
              if cmp.visible() then
                cmp.select_next_item({ behavior = "insert" })
                -- cmp.select_next_item({ behavior = 'select' })
              else
                cmp.complete()
              end
            end,
          },
          ["<C-j>"] = {
            c = function(fallback)
              if cmp.visible() then
                cmp.select_next_item()
              else
                fallback()
              end
            end,
          },
          ["<C-k>"] = {
            c = function(fallback)
              if cmp.visible() then
                cmp.select_prev_item()
              else
                fallback()
              end
            end,
          },
          ["<C-u>"] = {
            i = cmp.mapping.scroll_docs(-4),
            c = cmp.mapping.scroll_docs(-4),
          },
          ["<C-d>"] = {
            i = cmp.mapping.scroll_docs(4),
            c = cmp.mapping.scroll_docs(4),
          },
          ["<Tab>"] = {
            c = function()
              if cmp.visible() then
                cmp.select_next_item({ behavior = "insert" })
                -- cmp.select_next_item({ behavior = 'select' })
              else
                cmp.complete()
              end
            end,
          },
          ["<S-Tab>"] = {
            c = function()
              if cmp.visible() then
                cmp.select_prev_item({ behavior = "insert" })
                -- cmp.select_next_item({ behavior = 'select' })
              else
                cmp.complete()
              end
            end,
          },
        },
        snippet = {
          expand = function(args)
            require("luasnip").lsp_expand(args.body)
          end,
        },
      })

      -- cmp-cmdline setup
      local cmdline_formatting = {
        fields = { "abbr", "kind" },
        -- selene: allow(unused_variable)
        ---@diagnostic disable-next-line: unused-local
        format = function(entry, item)
          -- set menu icons
          local menu_icon = {
            File = "[File]",
            Folder = "[Directory]",
          }
          item.kind = menu_icon[item.kind]

          return item
        end,
      }

      cmp.setup.cmdline({ "/", "?" }, {
        -- use custom mapping instead
        -- mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = "buffer" },
        },
        formatting = cmdline_formatting,
      })

      cmp.setup.cmdline(":", {
        -- use custom mapping instead
        -- mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({ { name = "path" } }, {
          {
            name = "cmdline",
            option = {
              ignore_cmds = { "Man", "!" },
            },
          },
        }),
        formatting = cmdline_formatting,
      })
    end,
  },
}
