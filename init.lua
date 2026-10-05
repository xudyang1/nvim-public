vim.loader.enable(true)
require("vim._core.ui2").enable({
  enable = true,
  msg = { pager = { height = 0.5 } },
})

local g = vim.g
g.IN_WINDOWS = false
g.IN_LINUX = false

local has = vim.fn.has
if has("win64") == 1 or has("win32") == 1 then
  g.IN_WINDOWS = true
elseif has("linux") == 1 then
  g.IN_LINUX = true
end

-- === disabled runtime plugins (but will still source the files) ===
g.loaded_nvim_dir_plugin = 1
g.loaded_nvim_zip_plugin = 1
g.loaded_zipPlugin = 1 -- old-zip
g.loaded_gzip = 1
g.loaded_tarPlugin = 1
g.loaded_netrw = 1
g.loaded_netrwPlugin = 1
g.loaded_tutor_mode_plugin = 1
g.loaded_shada_plugin = 1
g.loaded_spellfile_plugin = 1
g.loaded_remote_plugins = 1

-- === enabled runtime plugins (loaded at startup) ===
g.loaded_man = g.IN_WINDOWS or nil
-- g.loaded_matchit = 1
-- g.loaded_matchparen = 1
-- g.editorconfig = false
-- g.loaded_nvim_net_plugin = true

-- 'g:termfeatures', disable OSC52 runtime plugin
local termfeatures = g.termfeatures or {}
termfeatures.osc52 = false
g.termfeatures = termfeatures
local function osc_copy(reg)
  local clipboard = reg == "+" and "c" or "p"
  return function(lines)
    local s = table.concat(lines, "\n")
    local base64 = vim.base64.encode(s)
    local content = string.format("\027]52;%s;%s\027\\", clipboard, base64)
    vim.api.nvim_ui_send(content)
  end
end
g.clipboard = vim.env.TMUX and "tmux"
  or {
    name = "OSC52 Copy Only",
    copy = { ["+"] = osc_copy("+"), ["*"] = osc_copy("*") },
    paste = { ["+"] = function() end, ["*"] = function() end },
  }

-- === runtime/autoload (lazy loaded on function call) ===
-- g.loaded_tar = 1
-- g.loaded_zip = 1

-- === misc ===
-- === runtime/ftplugin (loaded when filetype matches) ===
-- g.loaded_lua = 1
-- === runtime/pack/dist/opt (optional, loaded via :packadd plugname) ===
-- :packadd nvim.difftool nvim.tohtml nvim.undotree

-- === disable providers ===
g.loaded_python3_provider = 0
-- g.python3_host_prog = nil
g.loaded_node_provider = 0
g.loaded_ruby_provider = 0
g.loaded_perl_provider = 0

--- setup '<Leader>' and '<LocalLeader>' before loading plugins
g.mapleader = " "
-- g.maplocalleader = "\\"

-- 1. global keymaps/opts
require("core.options")
require("core.keymaps")
-- require("core.autocmds")

-- 2. plugins specific
require("core.lazyloader")
