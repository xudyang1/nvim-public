return {
  "numToStr/Comment.nvim",
  dependencies = {
    "JoosepAlviste/nvim-ts-context-commentstring",
    opts = { enable_autocmd = false },
  },
  keys = {
    { "gc", mode = { "n", "x" }, desc = "Comment: Block" },
    { "gb", mode = { "n", "x" }, desc = "Comment: Block" },
  },
  config = function()
    require("Comment").setup({
      pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
    })
  end,
}
--- Or, with neovim native comment
-- return {
--   "JoosepAlviste/nvim-ts-context-commentstring",
--   event = "VeryLazy",
--   opts = { enable_autocmd = false },
--   config = function(_, opts)
--     require("ts_context_commentstring").setup(opts)
--
--     local _get_option = vim.filetype.get_option
--     ---@diagnostic disable-next-line: duplicate-set-field
--     vim.filetype.get_option = function(filetype, option)
--       return option == "commentstring" and require("ts_context_commentstring.internal").calculate_commentstring()
--         or _get_option(filetype, option)
--     end
--   end,
-- }
