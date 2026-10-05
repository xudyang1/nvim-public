local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  rocks = { enabled = false, hererocks = false },
  defaults = {
    lazy = true, -- lazy-loaded
    -- version = nil, -- default for latest commit
    -- cond = nil, -- @type boolean|fun(self:LazyPlugin):boolean|nil
  },
  ui = { border = vim.o.winborder },
  spec = { { import = "plugins" } },
  -- dev = {
  --   path = "~/.config/nvim/dev",
  --   patterns = {},
  --   fallback = true,
  -- },
  install = { colorscheme = { "gruvbox" } },
  -- checker = { enabled = false },
  change_detection = { enabled = false },
  performance = {
    cache = { enabled = true },
    rtp = {
      -- reset = false, -- lazy.nvim resets rtp
      -- paths = {},
      disabled_plugins = {
        "gzip",
        "shada",
        "tutor",
        "osc52", -- osc52 paste is too slow, use OSC52 Copy Only
        "rplugin",
        "tarPlugin",
        "zip",
        "spellfile", -- [s or ]s for spelling check
        "netrwPlugin",
        "dir",
        --- enabled plugins
        -- "editorconfig",
        -- "matchit",
        -- "matchparen",
        -- "net",
        vim.g.IN_WINDOWS and "man" or nil, -- nil value should be placed at the end
      },
    },
  },
  -- for debugging lazy.nvim
  -- profiling = {
  --   loader = true, -- enable extra stats on the debug tab related to loader cache
  --   required = true, -- track each new require in the lazy profiling tab
  -- },
})

vim.keymap.set("n", "<Leader>la", "<Cmd>Lazy<CR>", { desc = "Lazy.nvim" })
