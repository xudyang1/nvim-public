return {
  -- TODO: add markdown preview (live pdf/html) with tools
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = {
      -- "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    event = { "BufRead *.md", "BufNewFile *.md" }, -- if "VeryLazy", need to call RenderMarkdown enable manually
    -- ft = "markdown",
    cmd = "RenderMarkdown",
    opts = {
      overrides = { buftype = { nofile = { enabled = false } } },
      win_options = { conceallevel = { rendered = 2 } },
      completions = { lsp = { enabled = true } },
      latex = { enabled = false },
      heading = {
        backgrounds = {
          "@none",
          "@none",
          "@none",
          "@none",
          "@none",
          "@none",
        },
      },
      code = {
        width = "block",
        min_width = 50,
        border = "thick",
      },
    },
  },
}
