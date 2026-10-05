return {
  "folke/todo-comments.nvim",
  event = "VeryLazy",
  cmd = { "TodoLocList", "TodoQuickFix", "TodoFzfLua" },
  dependencies = { "nvim-lua/plenary.nvim" },
  -- stylua: ignore start
  keys = {
    { "]t",         function() require("todo-comments").jump_next() end, desc = "Todo: next" },
    { "[t",         function() require("todo-comments").jump_prev() end, desc = "Todo: prev" },
    { "<leader>to", "<cmd>TodoLocList<cr>",                              desc = "Todo: locklist" },
    { "<leader>tq", "<cmd>TodoQuickFix<cr>",                             desc = "Todo: quickfix" },
    { "<leader>ft", "<cmd>TodoFzfLua<cr>",                               desc = "TodoFzfLua" },
  },
  -- stylua: ignore end
  opts = {},
}
