return {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  dependencies = { "nvim-lua/plenary.nvim" },
  keys = {
    {
      "<Leader>hh",
      function()
        local harpoon = require("harpoon")
        harpoon.ui:toggle_quick_menu(harpoon:list(), { border = "rounded" })
      end,
      desc = "toggle harpoon menu",
    },
    -- stylua: ignore start
    { "<Leader>ha", function() require("harpoon"):list():add() end, desc = "Harpoon: Add", },
    -- Toggle previous & next buffers stored within Harpoon list
    { "<C-A-P>", mode = { "n", "x" }, function() require("harpoon"):list():prev() end, desc = "harpoon previous", },
    { "<C-A-N>", mode = { "n", "x" }, function() require("harpoon"):list():next() end, desc = "harpoon next",     },
    -- stylua: ignore end
    {
      "<C-A-P>",
      mode = "i",
      function()
        vim.cmd("stopinsert")
        require("harpoon"):list():prev()
      end,
      desc = "harpoon previous",
    },
    {
      "<C-A-N>",
      mode = "i",
      function()
        vim.cmd("stopinsert")
        require("harpoon"):list():next()
      end,
      desc = "harpoon next",
    },
    -- { "<C-h>", function() require("harpoon"):list():select(1) end, desc = "Harpoon: Select 1" },
    -- { "<C-k>", function() require("harpoon"):list():select(2) end, desc = "Harpoon: Select 2" },
    -- { "<C-n>", function() require("harpoon"):list():select(3) end, desc = "Harpoon: Select 3" },
    -- { "<C-s>", function() require("harpoon"):list():select(4) end, desc = "Harpoon: Select 4" },
  },
  config = function()
    local harpoon = require("harpoon")

    harpoon:setup({
      -- global settings
      settings = {
        save_on_toggle = true,
        sync_on_ui_close = false,
        -- border_chars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
      },
    })

    -- The extend functionality can be used to add keymaps for opening files in splits & tabs.
    harpoon:extend({
      UI_CREATE = function(cx)
        local keymap = vim.keymap.set
        keymap("n", "<C-v>", function()
          harpoon.ui:select_menu_item({ vsplit = true })
        end, { buffer = cx.bufnr })

        keymap("n", "<C-x>", function()
          harpoon.ui:select_menu_item({ split = true })
        end, { buffer = cx.bufnr })

        keymap("n", "<C-t>", function()
          harpoon.ui:select_menu_item({ tabedit = true })
        end, { buffer = cx.bufnr })
      end,
    })
  end,
}
