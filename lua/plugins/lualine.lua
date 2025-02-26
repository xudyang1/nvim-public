return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  event = "VeryLazy", -- "VimEnter"
  config = function()
    -- stylua: ignore start
    local colors = {
      -- black = "#282828",     -- GruvboxBg0
      black = "#1d2021",        -- GruvboxBg0 (hard contrast)
      white = "#ebdbb2",        -- GruvboxFg1
      red = "#fb4934",          -- GruvboxRed
      green = "#8ec07c",        -- GruvboxAqua
      blue = "#83a598",         -- GruvboxBlue
      yellow = "#fabd2f",       -- GruvboxYellow
      orange = "#fe8019",       -- GruvboxOrange
      gray = "#928374",         -- GruvboxGray
      darkgray = "#3c3836",     -- GruvboxBg1
      lightgray = "#7c6f64",    -- GruvboxBg4
      inactivegray = "#504945", -- GruvboxBg2
    }
    -- stylua: ignore end

    local gruvbox_theme = {
      normal = {
        a = { bg = colors.white, fg = colors.black, gui = "bold" },
        b = { bg = nil, fg = colors.white },
        c = { bg = nil, fg = colors.white, gui = "bold" },
        x = {},
      },
      insert = {
        a = { bg = colors.orange, fg = colors.black, gui = "bold" },
        b = { bg = nil, fg = colors.white },
        c = { bg = nil, fg = colors.white },
      },
      visual = {
        a = { bg = colors.blue, fg = colors.black, gui = "bold" },
        b = { bg = nil, fg = colors.white },
        c = { bg = nil, fg = colors.white },
      },
      replace = {
        a = { bg = colors.red, fg = colors.black, gui = "bold" },
        b = { bg = nil, fg = colors.white },
        c = { bg = nil, fg = colors.white },
      },
      command = {
        a = { bg = colors.yellow, fg = colors.black, gui = "bold" },
        b = { bg = nil, fg = colors.white },
        c = { bg = nil, fg = colors.white },
      },
      inactive = {
        -- a = { bg = colors.darkgray, fg = colors.gray, gui = "bold" },
        b = { bg = nil, fg = colors.gray },
        c = { bg = nil, fg = colors.gray },
      },
    }

    local function lint_progress()
      local lint = require("lint")
      local running_linters = lint.get_running()
      local all_linters = lint.linters_by_ft[vim.bo.filetype]
      if
        vim.bo.filetype == "yaml" and string.find(vim.fs.normalize(vim.api.nvim_buf_get_name(0)), ".github/workflows/")
      then
        all_linters = lint.linters_by_ft.github_action
        -- BUG: do not return running because get_running always return actionlint instances
        return table.concat(all_linters, ",")
      end
      if #running_linters == 0 then
        -- return "󰦕 " .. table.concat(all_linters, ",")
        return table.concat(all_linters, ",")
      end
      -- return "󱉶 " .. table.concat(linters, ",")
      return "󰲽 " .. table.concat(running_linters, ",")
    end

    local function has_multi_file_buffers()
      -- always show filename when in diff mode
      if vim.wo.diff then
        return true
      end

      local windows = vim.api.nvim_tabpage_list_wins(0)

      local buf_count = 0

      for _, win_id in ipairs(windows) do
        local filetype = vim.api.nvim_get_option_value("filetype", { buf = vim.api.nvim_win_get_buf(win_id) })
        local buftype = vim.api.nvim_get_option_value("buftype", { buf = vim.api.nvim_win_get_buf(win_id) })

        if buftype ~= "nofile" and buftype ~= "prompt" and buftype ~= "terminal" or filetype == "dap-repl" then
          buf_count = buf_count + 1
        end
      end

      return buf_count > 1
    end

    require("lualine").setup({
      options = {
        theme = gruvbox_theme,
        -- theme = "gruvbox",
        component_separators = { left = "", right = "" },
        -- component_separators = { left = "|", right = "|" },
        section_separators = { left = "", right = "" },
        globalstatus = true,
      },
      sections = {
        lualine_a = {
          { "datetime", style = "%H:%M" },
        },
        lualine_c = {
          {
            "windows",
            -- component_separators = { left = "", right = "" },
            filetype_names = {
              lspinfo = "LspInfo",
              mason = "Mason",
              harpoon = "harpoon",
            },
            -- icons_enabled = false
          },
        },
        lualine_x = { lint_progress, "encoding", "fileformat" },
      },
      winbar = {
        lualine_c = { { "filename", path = 1, cond = has_multi_file_buffers } },
      },
      inactive_winbar = {
        lualine_c = { { "filename", path = 1, cond = has_multi_file_buffers } },
      },
    })
  end,
}
