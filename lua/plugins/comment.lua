return {
  "numToStr/Comment.nvim",
  dependencies = { "JoosepAlviste/nvim-ts-context-commentstring" },
  keys = {
    { "gc", mode = { "n", "x" }, nowait = true, desc = "Comment: Block" },
    { "gb", mode = { "n", "x" }, nowait = true, desc = "Comment: Block" },
  },
  config = function()
    require("Comment").setup({
      ---@link: https://github.com/JoosepAlviste/nvim-ts-context-commentstring/blob/main/lua/ts_context_commentstring/integrations/comment_nvim.lua
      pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
    })
  end,
}
