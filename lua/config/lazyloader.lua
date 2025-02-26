local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
---@diagnostic disable-next-line: undefined-field
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

local options = {
  rocks = {
    hererocks = false,
    enabled = false,
  },
  defaults = {
    lazy = true, -- should plugins be lazy-loaded?
  },
  ui = { -- The border to use for the UI window. Accepts same border values as |nvim_open_win()|.
    border = "rounded",
  },
  install = {
    colorscheme = { "gruvbox" },
  },
  performance = {
    rtp = {
      disabled_plugins = {
        "tarPlugin",
        "gzip",
        "zipPlugin",
        "netrwPlugin",
        "tutor",
        "osc52",
        "rplugin",
        -- needed
        -- "matchit",
        -- "matchparen",
        -- "spellfile", -- [s or ]s for spelling check
        -- "tohtml", -- :TOhtml out_file_without_extension
        -- nil value should be placed at the end
        vim.g.IN_WINDOWS and "man" or nil,
      },
    },
  },
}

vim.keymap.set("n", "<Leader>la", "<Cmd>Lazy<CR>", { desc = "Lazy.nvim" })

require("lazy").setup("plugins", options)
