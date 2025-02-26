return {
  "glacambre/firenvim",
  -- Lazy load firenvim
  -- Explanation: https://github.com/folke/lazy.nvim/discussions/463#discussioncomment-4819297
  enabled = not vim.g.IN_WINDOWS,
  lazy = not vim.g.started_by_firenvim,
  build = ":call firenvim#install(0)",
  config = function()
    if vim.g.started_by_firenvim then
      -- vim.cmd.startinsert()
      local opt = vim.opt
      local map = vim.keymap.set

      opt.shadafile = vim.fn.stdpath("state") .. "/shada/firenvim.shada"
      -- window sizes & font settings
      opt.guifont = "FiraCode Nerd Font Mono:h16"
      opt.signcolumn = "number"
      opt.cmdheight = 0
      opt.wrap = true
      -- if opt.wrap == true, enable more visual effects
      opt.linebreak = true
      opt.breakindent = true
      opt.showbreak = "> "
      opt.title = false

      -- add envs to firenvim so that rustacean can work with standalone files
      vim.env.CARGO_HOME = vim.fs.normalize("~/.local/share/cargo")
      vim.env.RUSTUP_HOME = vim.fs.normalize("~/.local/share/rustup")

      -- disable transparent
      local gruvbox = require("gruvbox")
      gruvbox.setup({ transparent_mode = false })
      vim.cmd([[colorscheme gruvbox]])

      local autocmd = vim.api.nvim_create_autocmd
      local firenvim_augroup = vim.api.nvim_create_augroup("Firenvim", { clear = true })

      autocmd("WinResized", {
        group = firenvim_augroup,
        callback = function()
          if vim.o.lines < 5 then
            opt.number = false
            opt.relativenumber = false
            --   opt.laststatus = 0
            -- else
            --   opt.laststatus = 3
          end
        end,
      })

      autocmd("FileType", {
        pattern = "markdown",
        group = firenvim_augroup,
        callback = function()
          vim.cmd("RenderMarkdown enable")
        end,
      })

      autocmd({ "BufEnter" }, {
        pattern = { "*github.com*" },
        group = firenvim_augroup,
        callback = function()
          opt.lines = 20
        end,
      })

      autocmd({ "BufEnter" }, {
        pattern = { "*leetcode.com*" },
        group = firenvim_augroup,
        callback = function()
          vim.fn.timer_start(500, function()
            opt.lines = 18
          end)
        end,
      })

      autocmd({ "BufEnter" }, {
        pattern = { "*typescriptlang.org*" },
        group = firenvim_augroup,
        callback = function()
          vim.fn.timer_start(500, function()
            opt.lines = 26
            opt.columns = 104
          end)
        end,
      })

      -- keymaps that don't work in terminal may work in browsers
      -- hide frame, use browser keybinding to manually trigger frame
      map({ "n", "i", "x", "c" }, "<C-z>", "<Cmd>call firenvim#hide_frame()<CR>", { desc = "Firenvim: Hide Frame" })
      -- keep frame, but focus on page
      map({ "n", "i", "x", "c" }, "<C-A-z>", "<Cmd>call firenvim#focus_page()<CR>", { desc = "Firenvim: Focus Page" })

      -- modify viewport sizes
      map({ "n", "i" }, "<C-->", function()
        opt.lines = opt.lines + 1
      end, { desc = "Firenvim: Vertical Expand" })
      map({ "n", "i" }, "<C-=>", function()
        opt.columns = opt.columns + 1
      end, { desc = "Firenvim: Horizontal Expand" })
      map({ "n", "i" }, "<C-A-->", function()
        opt.lines = opt.lines - 1
      end, { desc = "Firenvim: Vertical Shrink" })
      map({ "n", "i" }, "<C-A-=>", function()
        opt.columns = opt.columns - 1
      end, { desc = "Firenvim: Horizontal Shrink" })

      -- system clipboard
      map({ "n", "x" }, "<C-S-v>", [["+gp]], { desc = "Firenvim: Paste" })
      map({ "i" }, "<C-S-v>", "<C-g>u<C-r><C-p>+", { desc = "Firenvim: Paste" })
      map({ "c" }, "<C-S-v>", "<C-r>+", { desc = "Firenvim: Paste" })

      -- <C-w>, <C-n>, and <C-t> not overwritable in firefox
      map({ "n", "i", "x", "c" }, "<A-w>", "<C-w>")
      map({ "n", "i", "x", "c" }, "<A-n>", "<C-n>")
      map({ "n", "i", "x", "c" }, "<A-t>", "<C-t>")

      -- general config for firenvim
      vim.g.firenvim_config = {
        globalSettings = {
          alt = "all",
          cmdlineTimeout = 3000,
        },
        localSettings = {
          [".*"] = {
            cmdline = "neovim",
            content = "text",
            priority = 0,
            -- default
            selector = 'textarea:not([readonly], [aria-readonly]), div[role="textbox"]',
            -- selector = "textarea",
            takeover = "never",
          },
          ["leetcode.com/problems/.*"] = {
            filename = "{hostname%32}_{pathname%32}_{timestamp%32}.cpp",
          },
          ["github.com/.*"] = {
            filename = "{hostname%32}_{pathname%32}_{timestamp%32}.md",
          },
          ["reddit.com/.*"] = {
            filename = "{hostname%32}_{pathname%32}_{timestamp%32}.md",
          },
          ["typescriptlang.org/play/.*"] = {
            filename = "{hostname%32}_{pathname%32}_{timestamp%32}.ts",
          },
        },
      }
    end
  end,
}
