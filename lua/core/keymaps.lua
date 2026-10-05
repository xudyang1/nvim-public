local map = vim.keymap.set

-- leader key
map({ "n", "x" }, "<Space>", "<Nop>")
-- clear highlight
map("n", "<Esc>", "<C-l>", { remap = true })
map("n", "<Leader>is", "<Cmd>Inspect<Cr>")
map("n", "<Leader>it", "<Cmd>InspectTree<Cr>")

--- Clipboard
-- copy only, paste via terminal shortcut: <C-S-v>
map({ "n", "x" }, "<Leader>y", [["+zy]])
map("n", "<Leader>Y", [["+yg_]])
-- map({ "n", "x" }, "<Leader>pc", [["+gP]])
--- Registers
-- ""     unnamed, last yank/delete
-- "0     last yank
-- "-     last small delete
-- "1     last line delete
-- "#     alternate filename
-- "/     last search
-- "*, "+ last clipboard copy
-- "-     expression
-- readonly
--   ":   last executed command-line
--   ".   last inserted text
--   "%   current filename
-- enter visual mode and delete into black hole register, then p or P
-- "_     black hole register
map("x", "x", [["_x]])
-- map({ "n", "x" }, "<Leader>P", [["0p]]) -- paste last yank

--- Save
map("n", "<Leader>w", "<Cmd>update<CR>")
map("n", "<Leader>nw", "<Cmd>noautocmd update<CR>")

--- Exit
map({ "n", "x", "i", "t", "c" }, "<C-q>", "<Cmd>confirm q<CR>")
map("n", "<Leader>q", "<Cmd>confirm q<CR>")
map("n", "<Leader>Q", "<Cmd>confirm qall<CR>")

--- Keep cursor in center of window
map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")
map({ "n", "x" }, "<C-d>", "<C-d>zz")
map({ "n", "x" }, "<C-u>", "<C-u>zz")
map("n", "J", "<Cmd>normal! m`J``<CR>")

--- Navigations
map("n", "<C-p>", "<Cmd>bprev<Cr>") -- [b
map("n", "<C-n>", "<Cmd>bnext<Cr>") -- ]b
map({ "n", "i", "t" }, "<C-;>", "<Cmd>wincmd w<CR>")
map({ "n", "i", "t" }, "<A-;>", "<Cmd>wincmd p<CR>")
map({ "n", "t" }, "<A-h>", "<Cmd>wincmd h<CR>")
map({ "n", "t" }, "<A-j>", "<Cmd>wincmd j<CR>")
map({ "n", "t" }, "<A-k>", "<Cmd>wincmd k<CR>")
map({ "n", "t" }, "<A-l>", "<Cmd>wincmd l<CR>")

--- Adjust window sizes
map("n", "<C-Up>", "<C-w>+")
map("n", "<C-Down>", "<C-w>-")
map("n", "<C-Left>", "<C-w><")
map("n", "<C-Right>", "<C-w>>")

--- Motions
map({ "n", "x" }, "<C-b>", "^")
map({ "n", "x" }, "<C-e>", "<End>")

-- Insert mode
map("i", "<C-d>", "<Del>")
map("i", "<C-b>", "<Esc>I")
map("i", "<C-e>", function()
  return vim.fn.pumvisible() == 0 and "<End>" or "<C-e>"
end, { expr = true })
--- Cmdline mode
map("c", "<C-d>", "<Del>")
map("c", "<C-a>", "<Home>")
map("c", "<C-b>", "<Left>")
map("c", "<C-f>", "<Right>")
--- Select mode
map("s", "<C-h>", "<BS>i", { desc = "Select mode: delect" })
map("s", "<BS>", "<BS>i", { desc = "Select mode: delect" })
map("s", "<C-e>", "<C-o>o<Esc>a", { desc = "Select mode: insert at the end" })
--- Terminal mode
map("t", "<Esc>", [[<C-\><C-n>]])

--- Helpers
-- select previously changed text or yanked text
map("n", "<Leader>vi", "`[v`]")
-- capitalize current word
map("n", "<Leader>U", "gUiw")
-- map("i", "<A-u>", "<C-g>u<Esc>gUiwgi")

-- auto indent
map("n", "a", function()
  return not vim.api.nvim_get_current_line():match("%g") and vim.v.count <= 1 and "cc" or "a"
end, { expr = true })

-- toggle spell: zg to add good word, zw to add wrong word
map("n", "<Leader>sp", "<Cmd>setlocal spell! spelllang=en_us spelloptions=camel<CR>", { desc = "Toggle Spell" })

-- quick replace: replace word under cursor
-- map("n", "<Leader>rw", [[:s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], { desc = "Replace: word" })
map("n", "<Leader>re", [[:s/<C-r><C-w>/<C-r><C-w>/gI<Left><Left><Left>]], { desc = "Replace: word" })

--- User commands
local create_user_cmd = vim.api.nvim_create_user_command
create_user_cmd("Wrap", function(opts)
  local function set_wrap(enable)
    vim.wo.wrap = enable
    vim.wo.linebreak = enable
    vim.wo.breakindent = enable
    vim.wo.showbreak = enable and "> " or ""
  end

  local arg = opts.args

  if opts.bang then
    set_wrap(not vim.wo.wrap)
  elseif arg == "" or arg == "on" then
    set_wrap(true)
  elseif arg == "off" then
    set_wrap(false)
  else
    vim.api.nvim_echo({ { "Wrap: expected 'on' or 'off'" } }, false, { err = true, id = "Wrap" })
    return
  end

  if vim.wo.wrap then
    vim.keymap.set({ "n", "x" }, "j", function()
      return (vim.wo.wrap and vim.v.count == 0) and "gj" or "j"
    end, { expr = true, silent = true })
    vim.keymap.set({ "n", "x" }, "k", function()
      return (vim.wo.wrap and vim.v.count == 0) and "gk" or "k"
    end, { expr = true, silent = true })
    vim.keymap.set({ "n", "x" }, "g<C-b>", "g^")
    vim.keymap.set({ "n", "x" }, "g<C-e>", "g<End>")
  else
    pcall(vim.keymap.del, { "n", "x" }, "j")
    pcall(vim.keymap.del, { "n", "x" }, "k")
    pcall(vim.keymap.del, { "n", "x" }, "g<C-b>")
    pcall(vim.keymap.del, { "n", "x" }, "g<C-e>")
  end
end, {
  desc = "Toggle wrap",
  nargs = "?",
  bang = true,
  complete = function()
    return { "on", "off" }
  end,
})
create_user_cmd("Float", function()
  if vim.api.nvim_win_get_config(0).zindex then
    return
  end
  local function get_size(max_val, val)
    return val > 1 and math.min(max_val, val) or math.floor(max_val * val)
  end
  local ratio = 0.8
  local width = get_size(vim.o.columns, ratio)
  local height = get_size(vim.o.lines, ratio)
  local top = math.floor(((vim.o.lines - height) / 2))
  local left = math.floor(((vim.o.columns - width) / 2))

  vim.api.nvim_open_win(0, true, {
    relative = "editor",
    style = "minimal",
    width = width,
    height = height,
    row = top,
    col = left,
    border = vim.o.winborder,
  })
  vim.cmd.Wrap("on")
end, {
  desc = "Open buffer in a floating window",
})
map("n", "<Leader>tw", "<Cmd>Wrap!<CR>", { desc = "Toggle Wrap: Buffer" })
map("n", "<Leader>tf", "<Cmd>Float<CR>", { desc = "Toggle Float: buffer" })

--- LSP
-- toggle inlay_hint
map("n", "<Leader>li", "<Cmd>checkhealth vim.lsp<Cr>", { desc = "LSP: show info" })
map("n", "<Leader>ls", function()
  local names = vim.tbl_map(function(client)
    return client.name
  end, vim.lsp.get_clients({ bufnr = 0 }))
  vim.print(names)
end, { desc = "LSP: list clients" })
map("n", "<Leader>tih", function()
  vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
end, { desc = "LSP: toggle inlay hint" })
--- Treesitter
map({ "n", "x", "o" }, "<C-j>", function()
  if vim.treesitter.get_parser(nil, nil, { error = false }) then
    require("vim.treesitter._select").select_parent(vim.v.count1)
  else
    vim.lsp.buf.selection_range(vim.v.count1)
  end
end, { desc = "Select parent (outer) node" })
map("x", "<C-k>", function()
  if vim.treesitter.get_parser(nil, nil, { error = false }) then
    require("vim.treesitter._select").select_child(vim.v.count1)
  else
    vim.lsp.buf.selection_range(-vim.v.count1)
  end
end, { desc = "Select child (inner) node" })
map("x", "<C-p>", function()
  require("vim.treesitter._select").select_prev(vim.v.count1)
end, { desc = "Select previous node" })
map("x", "<C-n>", function()
  require("vim.treesitter._select").select_next(vim.v.count1)
end, { desc = "Select next node" })

--- Diagnostics
local signs = {
  [vim.diagnostic.severity.ERROR] = "󰅚",
  [vim.diagnostic.severity.WARN] = "󰀪",
  [vim.diagnostic.severity.INFO] = "󰋽",
  [vim.diagnostic.severity.HINT] = "󰌶",
}
local hl_map = {
  [vim.diagnostic.severity.ERROR] = "DiagnosticError",
  [vim.diagnostic.severity.WARN] = "DiagnosticWARN",
  [vim.diagnostic.severity.INFO] = "DiagnosticInfo",
  [vim.diagnostic.severity.HINT] = "DiagnosticHint",
}
vim.diagnostic.config({
  -- underline = true,
  -- virtual_text = false,
  -- virtual_lines = { current_line = true },
  -- signs = true,
  -- update_in_insert = false,
  severity_sort = true,
  jump = {
    on_jump = function(_, bufnr)
      vim.diagnostic.open_float({ bufnr = bufnr, scope = "cursor", focus = false })
    end,
  },
  float = { source = true },
  status = {
    format = function(severity_counts)
      local items = {}
      for severity in ipairs(vim.diagnostic.severity) do
        local count = severity_counts[severity] or 0
        if count > 0 then
          table.insert(items, ("%%#%s#%s %s"):format(hl_map[severity], signs[severity], count))
        end
      end
      return table.concat(items, " ")
    end,
  },
})
map("n", "[e", function()
  vim.diagnostic.jump({ severity = vim.diagnostic.severity.ERROR, count = -1 })
end, { desc = "Diagnostics: Previous" })
map("n", "]e", function()
  vim.diagnostic.jump({ severity = vim.diagnostic.severity.ERROR, count = 1 })
end, { desc = "Diagnostics: Next" })
map("n", "[E", function()
  vim.diagnostic.jump({ severity = vim.diagnostic.severity.ERROR, count = -math.huge, wrap = false })
end, { desc = "Diagnostics: First" })
map("n", "]E", function()
  vim.diagnostic.jump({ severity = vim.diagnostic.severity.ERROR, count = math.huge, wrap = false })
end, { desc = "Diagnostics: Last" })
