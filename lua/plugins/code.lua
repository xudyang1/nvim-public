return {
  {
    vim.g.IN_LINUX and nil or "xudyang1/redir.nvim",
    name = "redir.nvim",
    cmd = "Redir",
    dir = vim.g.IN_LINUX and "~/dev/redir.nvim" or nil,
    keys = {
      { "<Leader>ms", "<Cmd>lua require('redir').open()<Cr>", desc = "Open Message" },
    },
    opts = {},
  },
  -- {
  --   "jackMort/ChatGPT.nvim",
  --   enabled = false,
  -- },
  -- {
  --   "ThePrimeagen/refactoring.nvim",
  --   dependencies = {
  --     "nvim-lua/plenary.nvim",
  --     "nvim-treesitter/nvim-treesitter",
  --   },
  --   opts = {},
  --   config = function()
  --     require("refactoring").setup()
  --   end,
  -- },
}
