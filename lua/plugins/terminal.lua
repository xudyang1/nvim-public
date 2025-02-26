return {
  "akinsho/toggleterm.nvim",
  keys = {
    { mode = { "n", "i" }, "<C-'>", desc = "ToggleTerm" },
  },
  opts = {
    open_mapping = "<C-'>",
    size = function(term)
      if term.direction == "horizontal" then
        return 15
      elseif term.direction == "vertical" then
        return vim.o.columns * 0.4
      end
    end,
    highlights = {
      FloatBorder = {
        link = "FloatBorder",
      },
    },
    on_open = function(t)
      local map = vim.keymap.set
      local direction = t.direction
      if direction ~= "float" then
        map(
          { "n", "t" },
          "<A-t>",
          "<Cmd>q | ToggleTerm direction=float<CR>",
          { buffer = 0, desc = "ToggleTerm: Float" }
        )
      end
      if direction ~= "horizontal" then
        map(
          { "n", "t" },
          "<A-x>",
          "<Cmd>q | ToggleTerm direction=horizontal<CR>",
          { buffer = 0, desc = "ToggleTerm: Horizontal" }
        )
      end
      if direction ~= "vertical" then
        map(
          { "n", "t" },
          "<A-v>",
          "<Cmd>q | ToggleTerm direction=vertical<CR>",
          { buffer = 0, desc = "ToggleTerm: Vertical" }
        )
      end
    end,
    float_opts = {
      border = "rounded",
    },
    direction = "float", -- 'vertical' | 'horizontal' | 'tab' | 'float',
  },
}
