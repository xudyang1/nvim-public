return {
  "ellisonleao/gruvbox.nvim",
  priority = 1000,
  keys = {
    {
      "<Leader>TT",
      function()
        local gruvbox = require("gruvbox")
        gruvbox.config.transparent_mode = not gruvbox.config.transparent_mode
        vim.cmd.colorscheme("gruvbox")
      end,
      desc = "Color scheme(gruvbox): toggle transparent",
    },
  },
  init = function()
    require("gruvbox").setup({
      contrast = "hard", -- "hard", "soft", or ""
      invert_signs = true,
      terminal_colors = false,
      transparent_mode = not vim.g.started_by_firenvim,
      italic = {
        strings = false,
        comments = false,
        folds = false,
        -- operators = false,
        -- emphasis = true,
      },
      overrides = {
        IncSearch = { fg = "#d3869b", bg = "#1d2021" },
        NormalFloat = { link = "Normal" },
        FloatBorder = { link = "WinSeparator" },
        MsgSeparator = { link = "WinSeparator" },
        SignColumn = { bg = "NONE" },
        FoldColumn = { bg = "NONE" },
        WinBar = { fg = "#ebdbb2", bg = "NONE", bold = true },
        WinBarNC = { fg = "#928374", bg = "NONE" },
        StatusLine = { bg = "NONE" },
        StatusLineNC = { bg = "NONE" },
        StatusLineTime = { fg = "#1d2021", bg = "#ebdbb2", bold = true },

        Pmenu = { link = "Normal" },
        PmenuBorder = { link = "FloatBorder" },
        PmenuMatch = { link = "GruvboxOrangeBold" },
        PmenuMatchSel = { link = "PmenuMatch" },
        PmenuSel = { fg = "NONE", bg = "#504945", bold = false },

        LspSignatureActiveParameter = { link = "PmenuSel" },
        FlashLabel = { link = "IncSearch" },
        LazyBackdrop = { link = "Normal" },
        MasonBackdrop = { link = "Normal" },

        FzfLuaBorder = { link = "FloatBorder" },
        DapUIFloatBorder = { link = "FloatBorder" },

        BlinkCmpMenuBorder = { link = "PmenuBorder" },
        BlinkCmpDocBorder = { link = "PmenuBorder" },
        BlinkCmpDocSeparator = { link = "PmenuBorder" },
        BlinkCmpSignatureHelpBorder = { link = "PmenuBorder" },
        BlinkCmpLabelMatch = { link = "PmenuMatch" },
        BlinkCmpLabelDeprecated = { fg = "NONE", strikethrough = true },

        -- === Markdown ===
        ["@markup.heading.1.markdown"] = { link = "GruvboxOrangeBold" },
        ["@markup.heading.2.markdown"] = { link = "GruvboxYellowBold" },
        ["@markup.heading.3.markdown"] = { link = "GruvboxAquaBold" },
        ["@markup.heading.4.markdown"] = { link = "GruvboxBlueBold" },
        ["@markup.heading.5.markdown"] = { link = "GruvboxYellowBold" },
        ["@markup.heading.6.markdown"] = { link = "GruvboxOrangeBold" },
        -- render-markdown.nvim
        RenderMarkdownCode = { bg = "#282828" },
        RenderMarkdownSuccess = { link = "DiagnosticHint" },

        -- === Semantic Highlights ===
        -- TODO: add more highlights
        -- ["@lsp.typemod.variable.global"] = {
        --   link = "GruvboxPurple",
        -- },
        -- LspReferenceTarget = {},
      },
      -- undercurl = true,
      -- underline = true,
      -- bold = true,
      -- strikethrough = true,
      -- invert_selection = false,
      -- invert_tabline = false,
      -- invert_intend_guides = false,
      -- inverse = true, -- invert background for search, diffs, statuslines and errors
      -- palette_overrides = {},
      -- dim_inactive = false,
    })

    -- vim.o.background="dark" -- default
    vim.cmd.colorscheme("gruvbox")
  end,
}
