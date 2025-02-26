return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    event = { "BufRead *.md", "BufNewFile *.md" }, -- if "VeryLazy", need to call RenderMarkdown enable manually
    cmd = "RenderMarkdown",
    -- ft = "markdown",
    opts = {
      latex = {
        -- Whether LaTeX should be rendered, mainly used for health check
        enabled = false,
      },
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
    dependencies = {
      -- "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
  },
}
