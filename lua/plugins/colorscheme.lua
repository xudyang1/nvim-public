return {
  {
    "ellisonleao/gruvbox.nvim",
    -- event = "VeryLazy",
    priority = 1000,
    keys = {
      {
        "<Leader>TT",
        function()
          local gruvbox = require("gruvbox")
          gruvbox.setup({ transparent_mode = not gruvbox.config.transparent_mode })
          vim.cmd([[colorscheme gruvbox]])
        end,
        desc = "ColorScheme(gruvbox): Toggle Transparent",
      },
    },
    -- config = function()
    init = function()
      require("gruvbox").setup({
        contrast = "hard", -- can be "hard", "soft" or empty string
        invert_signs = true,
        terminal_colors = false,
        transparent_mode = true,
        italic = {
          strings = false,
          comments = false,
          folds = false,
          -- operators = false,
          -- emphasis = true,
        },
        overrides = {
          FloatBorder = {
            link = "GruvboxBg3",
          },
          SignColumn = { bg = "NONE" },
          TelescopeResultsBorder = {
            link = "FloatBorder",
          },
          TelescopePreviewBorder = {
            link = "FloatBorder",
          },
          TelescopePromptBorder = {
            link = "FloatBorder",
          },
          TelescopeMatching = {
            link = "GruvboxOrangeBold",
          },
          -- CmpItemAbbr = { bg = "NONE", },
          CmpItemAbbrMatch = {
            -- bg = "NONE",
            link = "GruvboxOrangeBold",
          },
          CmpItemAbbrMatchFuzzy = {
            -- bg = "NONE",
            link = "GruvboxOrangeBold",
          },
          CmpItemAbbrDeprecated = {
            strikethrough = true,
          },
          LspInfoBorder = {
            link = "FloatBorder",
          },
          -- === Markdown ===
          ["@markup.heading.1.markdown"] = {
            link = "GruvboxOrangeBold",
          },
          ["@markup.heading.2.markdown"] = {
            link = "GruvboxYellowBold",
          },
          ["@markup.heading.3.markdown"] = {
            link = "GruvboxAquaBold",
          },
          ["@markup.heading.4.markdown"] = {
            link = "GruvboxBlueBold",
          },
          ["@markup.heading.5.markdown"] = {
            link = "GruvboxYellowBold",
          },
          ["@markup.heading.6.markdown"] = {
            link = "GruvboxOrangeBold",
          },
          -- render-markdown.nvim
          RenderMarkdownCode = {
            bg = "#282828",
          },
          RenderMarkdownSuccess = {
            link = "DiagnosticHint",
          },
        },
      })

      -- vim.o.background="dark" -- system default
      vim.cmd([[colorscheme gruvbox]])
    end,
  },
}
