return {
  "folke/todo-comments.nvim",
  event = "VeryLazy",
  cmd = { "TodoTrouble", "TodoTelescope" },
  dependencies = { "nvim-lua/plenary.nvim" },
  -- TODO:
  -- stylua: ignore start
  keys = {
    { "]t",         function() require("todo-comments").jump_next() end, desc = "Next todo comment" },
    { "[t",         function() require("todo-comments").jump_prev() end, desc = "Previous todo comment" },
    { "<leader>to", "<cmd>TodoLocList<cr>",                              desc = "Todo: LocList" },
    { "<leader>tO", "<cmd>TodoLocList keywords=TODO,FIX,FIXME<cr>",      desc = "Todo/Fix/Fixme: Loclist" },
    -- TodoLocList, TodoQuickFix, TodoTelescope, TodoTrouble
  },
  -- stylua: ignore end
  opts = {},
}
