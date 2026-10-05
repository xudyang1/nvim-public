return {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  dependencies = { "nvim-lua/plenary.nvim" },
  keys = {
    {
      "<Leader>hh",
      function()
        local harpoon = require("harpoon")
        harpoon.ui:toggle_quick_menu(harpoon:list())
      end,
      desc = "Harpoon: toggle menu",
    },
    -- stylua: ignore start
    { "<Leader>ha", function() require("harpoon"):list():add() end, desc = "Harpoon: add", },
    -- Toggle previous & next buffers stored within Harpoon list
    { "<C-A-p>", mode = { "n", "x", "i" }, function() require("harpoon"):list():prev() end, desc = "Harpoon: prev", },
    { "<C-A-n>", mode = { "n", "x", "i" }, function() require("harpoon"):list():next() end, desc = "Harpoon: next", },
    -- stylua: ignore end
    -- { "<C-h>", function() require("harpoon"):list():select(1) end, desc = "Harpoon: select 1" },
  },
  config = function()
    local harpoon = require("harpoon")

    harpoon:setup({
      -- global settings
      settings = {
        save_on_toggle = true,
        sync_on_ui_close = false,
      },
    })

    -- The extend functionality can be used to add keymaps for opening files in splits & tabs.
    harpoon:extend({
      UI_CREATE = function(cx)
        local keymap = vim.keymap.set
        keymap("n", "<C-v>", function()
          harpoon.ui:select_menu_item({ vsplit = true })
        end, { buf = cx.bufnr })

        keymap("n", "<C-x>", function()
          harpoon.ui:select_menu_item({ split = true })
        end, { buf = cx.bufnr })

        keymap("n", "<C-t>", function()
          harpoon.ui:select_menu_item({ tabedit = true })
        end, { buf = cx.bufnr })
      end,
    })
  end,
}
