local g = vim.g

-- disable providers
g.loaded_python3_provider = 0
-- g.python3_host_prog = vim.fs.normalize(vim.env.VIRTUAL_ENV) .. (vim.g.IN_WINDOWS and "/Scripts/python.exe" or "/bin/python")
g.loaded_node_provider = 0
g.loaded_ruby_provider = 0
g.loaded_perl_provider = 0

-- NOTE: Must happen before plugins are required (otherwise wrong leader may be used)
g.mapleader = " "
-- g.maplocalleader = " "

-- 1. global keymaps/opts and configs
require("config.keymaps")
require("config.options")
require("config.autocmds")

-- 2. plugin specific keymaps/opts and configs
require("config.lazyloader")

-- 3. os/env specific keymaps/opts and configs
require("config.os")
