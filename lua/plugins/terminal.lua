return {
  "akinsho/toggleterm.nvim",
  cmd = {
    "TermExec",
    "TermNew",
    "TermSelect",
    "ToggleTerm",
    "ToggleTermToggleAll",
    "ToggleTermSetName",
    "ToggleTermSendCurrentLine",
    "ToggleTermSendVisualLines",
    "ToggleTermSendVisualSelection",
  },
  keys = {
    { mode = { "n", "i" }, "<C-'>", desc = "ToggleTerm" },
  },
  opts = {
    open_mapping = "<C-'>",
    size = function(term)
      if term.direction == "horizontal" then
        return 15
      elseif term.direction == "vertical" then
        return math.floor(vim.o.columns * 0.4)
      end
    end,
    float_opts = {
      width = math.floor(vim.o.columns * 0.7),
      height = math.floor(vim.o.lines * 0.7),
    },
    highlights = {
      FloatBorder = {
        link = "FloatBorder",
      },
    },
    on_open = function(term)
      local horizontal_height = 15
      local vertical_width = vim.o.columns * 0.4

      local function bufMap(lhs, rhs, desc)
        vim.keymap.set({ "n", "t" }, lhs, rhs, { buf = 0, desc = desc })
      end
      bufMap("<A-a>", function()
        vim.cmd.ToggleTerm()
        vim.cmd.ToggleTerm("direction=float")
      end, "ToggleTerm: Float")
      bufMap("<A-s>", function()
        vim.cmd.ToggleTerm()
        vim.cmd.ToggleTerm("direction=horizontal size=" .. horizontal_height)
      end, "ToggleTerm: Horizontal")
      bufMap("<A-v>", function()
        vim.cmd.ToggleTerm()
        vim.cmd.ToggleTerm("direction=vertical size=" .. vertical_width)
      end, "ToggleTerm: Vertical")
      bufMap("<A-t>", function()
        vim.cmd.ToggleTerm()
        vim.cmd.ToggleTerm("direction=tab")
      end, "ToggleTerm: Tab")

      bufMap("<A-'>", function()
        local direction = term.direction
        if direction == "float" then
          vim.cmd.ToggleTerm()
          vim.cmd.ToggleTerm("direction=horizontal size=" .. horizontal_height)
          vim.cmd.TermNew("direction=horizontal size=" .. horizontal_height)
        elseif direction == "horizontal" then
          vim.cmd.TermNew("direction=horizontal size=" .. horizontal_height)
        elseif direction == "vertical" then
          vim.cmd.TermNew("direction=vertical size=" .. vertical_width)
        else
          vim.cmd.TermNew("direction=tab")
        end
      end, "TermNew")
    end,
    persist_mode = true, -- false: always insert mode when enter
    shade_terminals = false, -- keep normal background
    direction = "horizontal", -- 'vertical' | 'horizontal' | 'tab' | 'float',
  },
}
