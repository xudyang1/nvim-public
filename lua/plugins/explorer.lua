return {
  {
    "stevearc/oil.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "VeryLazy",
    lazy = vim.fn.argc(-1) == 0,
    keys = {
      {
        mode = { "n", "i" },
        "<C-,>",
        function()
          local oil = require("oil")
          if vim.bo.filetype == "oil" then
            oil.close()
          else
            vim.cmd.stopinsert()
            oil.open()
          end
        end,
        desc = "Toggle oil explorer",
      },
    },
    opts = {
      view_options = { show_hidden = true },
      keymaps = { q = { "actions.close", mode = "n" } },
    },
  },
}
