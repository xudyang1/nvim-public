return {
  "glacambre/firenvim",
  enabled = not vim.g.IN_WINDOWS,
  lazy = not vim.g.started_by_firenvim,
  -- build = [[:call firenvim#install(0,'export PATH="$PATH"')]],
  build = ":call firenvim#install(0)",
  config = function()
    if vim.g.started_by_firenvim then
      local opt = vim.opt
      opt.number = true
      opt.relativenumber = false
      opt.shadafile = string.format("%s/shada/firenvim.shada", vim.fn.stdpath("state"))
      opt.signcolumn = "number"
      opt.cmdheight = 0
      opt.title = false

      vim.cmd.Wrap("on")

      local font = "FiraCode Nerd Font Mono"
      local font_size = 24
      local function update_fontsize(delta)
        if delta then
          font_size = math.min(math.max(font_size + delta, 5), 40)
        end
        opt.guifont = string.format("%s:h%s", font, font_size)
      end
      update_fontsize()

      local autocmd = vim.api.nvim_create_autocmd
      local firenvim_augroup = vim.api.nvim_create_augroup("Firenvim", { clear = true })
      autocmd("WinResized", {
        group = firenvim_augroup,
        callback = function()
          if vim.o.lines < 5 then
            opt.number = false
            opt.laststatus = 0
          else
            opt.number = true
            opt.laststatus = 3
          end
        end,
      })
      autocmd("BufEnter", {
        pattern = "*typescriptlang.org*",
        group = firenvim_augroup,
        callback = function()
          vim.fn.timer_start(500, function()
            vim.o.lines = math.floor(vim.o.lines * 0.9)
            vim.o.columns = math.floor(vim.o.columns * 0.85)
          end)
        end,
      })

      --- Clipboard
      if vim.fn.has("wsl") == 1 then
        local powershell = "/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe"
        local wsl_copy = {
          powershell,
          "-NonInteractive",
          "-NoProfile",
          "-Command",
          [[
        [Console]::InputEncoding=[System.Text.Encoding]::UTF8;
        Set-Clipboard -Value ([Console]::In.ReadToEnd() -replace "`r", "")
      ]],
        }
        local wsl_paste = {
          powershell,
          "-NonInteractive",
          "-NoProfile",
          "-Command",
          [[
        [Console]::OutputEncoding=[System.Text.Encoding]::UTF8;
        [Console]::Out.Write((Get-Clipboard -Raw) -replace "`r", "")
      ]],
        }
        vim.g.clipboard = {
          name = "wsl_clipboard",
          copy = { ["+"] = wsl_copy, ["*"] = wsl_copy },
          paste = { ["+"] = wsl_paste, ["*"] = wsl_paste },
          cache_enabled = false,
        }
      end

      -- selene: allow(multiple_statements)
      -- stylua: ignore start
      local firenvim_keys = {
        -- Hide frame, use browser keybinding to manually trigger frame
        { { "n", "i", "x", "c", "t" }, "<C-z>", "<Cmd>call firenvim#hide_frame()<CR>", { desc = "Firenvim: Hide Frame" }, },
        -- Keep frame open, focus on page
        { { "n", "i", "x", "c", "t" }, "<C-S-z>", "<Cmd>call firenvim#focus_page()<CR>", { desc = "Firenvim: Focus Page" }, },
        --- Font size
        { { "n", "i", "x", "c", "t" }, "<C-->", function() update_fontsize(-1) end, { desc = "Firenvim: decrease font size" }, },
        { { "n", "i", "x", "c", "t" }, "<C-=>", function() update_fontsize(1) end, { desc = "Firenvim: increase font size" }, },
        --- Viewport size
        { { "n", "i", "x", "c", "t" }, "<C-S-j>", function() opt.lines = opt.lines + 1 end, { desc = "Firenvim: lines+1" }, },
        { { "n", "i", "x", "c", "t" }, "<C-S-k>", function() opt.lines = opt.lines - 1 end, { desc = "Firenvim: lines-1" }, },
        { { "n", "i", "x", "c", "t" }, "<C-S-h>", function() opt.columns = opt.columns + 1 end, { desc = "Firenvim: columns+1" }, },
        { { "n", "i", "x", "c", "t" }, "<C-S-l>", function() opt.columns = opt.columns - 1 end, { desc = "Firenvim: columns-1" }, },
        { { "n", "i", "x", "c", "t" }, "<C-0>", function() opt.columns = 80 opt.lines = 18 end, { desc = "Firenvim: adjust size" }, },
        --- Clipboard paste
        { { "n", "x" }, "<C-S-v>", [["+gp]], { desc = "Firenvim: Paste" } },
        { "i", "<C-S-v>", "<C-g>u<C-r><C-p>+", { desc = "Firenvim: Paste" } },
        { "c", "<C-S-v>", "<C-r>+", { desc = "Firenvim: Paste" } },
        { "t", "<C-S-v>", "<Cmd>put +<CR>", { desc = "Firenvim: Paste" } },
      }
      -- stylua: ignore end
      local map = vim.keymap.set
      for _, key in ipairs(firenvim_keys) do
        map(unpack(key))
      end

      vim.g.firenvim_config = {
        globalSettings = { alt = "all", cmdlineTimeout = 3000 },
        localSettings = {
          [".*"] = {
            cmdline = "neovim",
            content = "text",
            priority = 0,
            selector = 'textarea:not([readonly], [aria-readonly]), div[role="textbox"]',
            takeover = "never",
          },
          ["^https://(www\\.)?leetcode\\.com/problems/.*"] = {
            filename = "{pathname%32}_{timestamp%32}.cpp",
          },
          ["^https://(www\\.)?github\\.com/[^/]+/[^/]+/(pull|issues|discussions)/\\d+"] = {
            filename = "{pathname%32}_{timestamp%32}.md",
          },
          ["^https://(www\\.)?reddit\\.com/.*"] = {
            filename = "{hostname%32}_{pathname%32}_{timestamp%32}.md",
          },
          ["^https://(www\\.)?typescriptlang\\.org/play/.*"] = {
            filename = "{hostname%32}_{pathname%4}_{timestamp%32}.ts",
          },
        },
      }
    end
  end,
}
