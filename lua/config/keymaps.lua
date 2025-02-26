local map = vim.keymap.set
local api = vim.api

-- no-ops
map({ "n", "x" }, "<Space>", "<Nop>")
-- :sus or :stop or <C-z> does not work in windows
-- https://github.com/neovim/neovim/issues/6660
if vim.g.IN_WINDOWS then
  map({ "n", "x" }, "<C-z>", "<Nop>")
end

-- <Esc> to clear highlight
-- map("n", "<Esc>", "<Cmd>nohlsearch|diffupdate<CR>")
map("s", "<C-d>", "<BS>i", { desc = "SelectMode: Delete and Insert" })
map("s", "<C-e>", "<C-o>o<Esc>a", { desc = "SelectMode: Switch to Insert" })

map("t", "<Esc>", [[<C-\><C-n>]])
map("t", "<C-q>", "<Cmd>q<CR>")
map("t", "<C-;>", "<Cmd>wincmd p<CR>")

map("n", "<C-n>", "<Cmd>bnext<Cr>")
map("n", "<C-p>", "<Cmd>bprev<Cr>")

-- numbers
map("n", "+", "<C-a>")
map("n", "-", "<C-x>")
map("x", "+", "<C-a>gv")
map("x", "-", "<C-x>gv")
map("x", "g+", "g<C-a>gv")
map("x", "g-", "g<C-x>gv")

-- system clipboard
map({ "n", "x" }, "<Leader>y", [["+zy]])
map({ "n", "x" }, "<Leader>Y", [["+yg_]])

-- select previous inserted text or yanked text
map("n", "<Leader>vi", "`[v`]")

-- paste last copy
map({ "n", "x" }, "<Leader>P", [["0p]])
-- black hole registers
map("x", "<Leader>p", [["_dgP]])
map({ "n", "x" }, "<Leader>d", [["_d]])
map({ "n", "x" }, "<Leader>D", [["_D]])
map({ "n", "x" }, "x", [["_x]])
map({ "n", "x" }, "X", [["_X]])

-- Save
map("n", "<C-s>", "<Cmd>update<CR>")
map("x", "<C-s>", ":<C-u>update<CR>gv")
map("i", "<C-s>", "<Esc><Cmd>update<CR>gi")
map("c", "<C-s>", "<Cmd>update<CR>")

-- Save without autocmd (without formatting)
map("n", "<C-A-s>", "<Cmd>noautocmd update<CR>")
map("x", "<C-A-s>", ":<C-u>noautocmd update<CR>gv")
map("i", "<C-A-s>", "<Esc><Cmd>noautocmd update<CR>gi")
map("c", "<C-A-s>", "<Cmd>noautocmd update<CR>")

-- Exit
map({ "n", "x", "i", "c" }, "<C-q>", "<Cmd>confirm q<CR>")
map({ "n", "x", "i", "c" }, "<C-A-q>", "<Cmd>confirm qall<CR>")

-- better indenting
map("x", "<", "<gv")
map("x", ">", ">gv")

-- === Text Object ===
-- whole LINE, inner LINE
map({ "x", "o" }, "al", ":<C-u>normal! 0v$h<CR>", { desc = "Whole Line", silent = true })
map({ "x", "o" }, "il", ":<C-u>normal! ^vg_<CR>", { desc = "Inner Line", silent = true })
local function text_object(symbol, around)
  return function()
    local column_byte = api.nvim_win_get_cursor(0)[2]
    local line = api.nvim_get_current_line()
    local cursor_char = string.sub(line, column_byte + 1, column_byte + 1)
    local before = string.sub(line, 1, column_byte)
    local after = string.sub(line, column_byte + 1)
    local at_left = string.find(before, symbol, 1, true)
    local at_right = string.find(after, symbol, 1, true)
    local both_at_right = string.find(after, string.format("%s.*%s", symbol, symbol))

    -- if cursor_char ~= symbol and at_left and at_right or cursor_char == symbol and at_left then
    -- [symbol_left, symbol_cursor] is selected only when [symbol_cursor, symbol_right] does not occur
    if cursor_char ~= symbol and at_left and at_right or cursor_char == symbol and at_left and not both_at_right then
      if around then
        return string.format(":<C-u>normal! F%svf%s<Cr>", symbol, symbol)
      else
        return string.format(":<C-u>normal! T%svt%s<Cr>", symbol, symbol)
      end
    elseif cursor_char == symbol and both_at_right then
      if around then
        return string.format(":<C-u>normal! vf%s<Cr>", symbol)
      else
        return string.format(":<C-u>normal! lvt%s<Cr>", symbol)
      end
    elseif cursor_char ~= symbol and both_at_right then
      if around then
        return string.format(":<C-u>normal! f%svf%s<Cr>", symbol, symbol)
      else
        return string.format(":<C-u>normal! f%slvt%s<Cr>", symbol, symbol)
      end
    end
    return "<Esc>"
  end
end
-- whole BAR, inner BAR
map({ "x", "o" }, "a|", text_object("|", true), { desc = "Whole Bar", silent = true, expr = true })
map({ "x", "o" }, "i|", text_object("|"), { desc = "Inner Bar", silent = true, expr = true })
-- whole COMMA, inner COMMA
map({ "x", "o" }, "a,", text_object(",", true), { desc = "Whole Bar", silent = true, expr = true })
map({ "x", "o" }, "i,", text_object(","), { desc = "Inner Bar", silent = true, expr = true })

-- motions
map({ "n", "x" }, "<C-b>", "^")
map({ "n", "x" }, "<C-e>", "<End>")
map({ "n", "x" }, "g<C-e>", "g<End>")
map("i", "<C-b>", "<Esc>I")
map("i", "<C-e>", "<End>")
map("c", "<C-d>", "<Del>")
map("c", "<C-j>", "<Left>")
map("c", "<C-k>", "<Right>")

-- insert mode helpers
map("i", "<C-d>", "<C-g>u<Del>")
map("i", "<A-d>", "<C-g>u<C-o>dw")
map("i", "<A-[>", "<C-g>u<C-d>")
map("i", "<A-]>", "<C-g>u<C-t>")
-- for digraphs
map("i", "<A-v>", "<C-k>")

-- capitalize current word
map("n", "<A-u>", "viwU")
map("i", "<A-u>", "<C-g>u<Esc>viwUgi")

-- === minor modifications ===
map({ "n", "x" }, "j", function()
  return vim.v.count > 0 and "j" or "gj"
end, { noremap = true, expr = true })
map({ "n", "x" }, "k", function()
  return vim.v.count > 0 and "k" or "gk"
end, { noremap = true, expr = true })
map({ "n", "x" }, "<C-d>", "<C-d>zz")
map({ "n", "x" }, "<C-u>", "<C-u>zz")
map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")
map("n", "J", "<Cmd>normal! m`J``<CR>")
map("x", "J", "<Cmd>normal! m`J``gv<CR>")

-- === quick replace ===
-- replace word/WORD under cursor
map("n", "<Leader>rw", [[:s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], { desc = "Replace: word" })
map("n", "<Leader>rW", [[:s/\<<C-r><C-a>\>/<C-r><C-a>/gI<Left><Left><Left>]], { desc = "Replace: WORD" })

-- adjust window sizes
map("n", "<C-Up>", "<C-w>+")
map("n", "<C-Down>", "<C-w>-")
map("n", "<C-Left>", "<C-w><")
map("n", "<C-Right>", "<C-w>>")
-- window navigations
map({ "n", "o", "i", "x" }, "<C-;>", "<Esc><C-w>w")
map({ "n", "o", "i", "x" }, "<A-;>", "<Esc><C-w>p")

local function autoindent(key)
  return function()
    return not api.nvim_get_current_line():match("%g") and vim.v.count <= 1 and "cc" or key
  end
end

-- auto indent
map("n", "i", autoindent("i"), { expr = true, noremap = true })
map("n", "I", autoindent("I"), { expr = true })
map("n", "a", autoindent("a"), { expr = true, noremap = true })
map("n", "A", autoindent("A"), { expr = true })

map("n", "<C-Enter>", "o<Esc>cc<Esc>")
map("n", "<S-Enter>", "O<Esc>cc<Esc>")
map("i", "<C-Enter>", "<C-g>u<Esc>o<Esc>cc")
map("i", "<S-Enter>", "<C-g>u<Esc>O<Esc>cc")

-- toggle spell
-- zg to add good word, zw to add wrong word
map("n", "<Leader>sp", "<Cmd>setlocal spell! spelllang=en_us<CR>", { desc = "Toggle Spell" })

-- quickfix
-- :vimgrep -> :copen
map("n", "]q", ":cnext<CR>")
map("n", "[q", ":cprevious<CR>")

-- NOTE: diagnostics are not exclusive to lsp servers
-- so these can be global keybindings
-- map('n', 'gl', '<cmd>lua vim.diagnostic.open_float()<cr>')
-- mapped by default since v0.10.0: vim.diagnostic.goto_prev({ float = false})
-- @see https://github.com/neovim/neovim/issues/28909
map("n", "[d", vim.diagnostic.goto_prev, { desc = "Diagnostics: Previous" })
map("n", "]d", vim.diagnostic.goto_next, { desc = "Diagnostics: Next" })
map("n", "[e", function()
  vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR })
end, { desc = "Diagnostics: Previous" })
map("n", "]e", function()
  vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR })
end, { desc = "Diagnostics: Next" })

vim.diagnostic.config({
  -- underline = true,
  -- virtual_text = true,
  -- signs = true,
  float = { border = "rounded", source = true },
  -- update_in_insert = true,
  severity_sort = true,
})

-- toggle inlay_hint
map("n", "<Leader>tih", function()
  vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({}))
end, { desc = "LSP: toggle inlay hint" })
-- set diagnostic border

local function toggle_float()
  if api.nvim_win_get_config(0).zindex then
    return
  end
  local function get_size(max_val, val)
    return val > 1 and math.min(max_val, val) or math.floor(max_val * val)
  end
  local width = 0.8
  local height = 0.7
  width = get_size(vim.o.columns, width)
  height = get_size(vim.o.lines, height)

  local top = math.floor(((vim.o.lines - height) / 2))
  local left = math.floor(((vim.o.columns - width) / 2))

  local win_opts = {
    relative = "editor",
    style = "minimal",
    width = width,
    height = height,
    row = top,
    col = left,
    border = "rounded",
  }
  api.nvim_open_win(0, true, win_opts)
  vim.cmd("setlocal wrap linebreak breakindent showbreak=>\\ ")
end
map("n", "<Leader>tf", toggle_float, { desc = "Window: Toggle Float" })

map("n", "<Leader>tw", "<Cmd>setlocal wrap! linebreak breakindent showbreak=>\\ <Cr>", { desc = "Buff: Toggle Wrap" })

map("n", "<Leader>V", "<Cmd>cd ~/.config/nvim<CR>", { desc = "CD: nvim config" })

-- buflist: [1:$LOCAL,2:$BASE,3:$REMOTE,4:$MERGED]
map(
  "n",
  "<Leader>dol",
  "<Cmd>lua if vim.wo.diff then vim.cmd('diffget 1') end<CR>",
  { desc = "MergeTool: diffget $LOCAL" }
)
map(
  "n",
  "<Leader>dob",
  "<Cmd>lua if vim.wo.diff then vim.cmd('diffget 2') end<CR>",
  { desc = "MergeTool: diffget $BASE" }
)
map(
  "n",
  "<Leader>dor",
  "<Cmd>lua if vim.wo.diff then vim.cmd('diffget 3') end<CR>",
  { desc = "MergeTool: diffget $REMOTE" }
)

-- === Delete Keymaps ===
local del = vim.keymap.del
-- correctly lazy load comment.nvim: keep "o" for gcgc and dgc in operator pending mode
del({ "n", "x" }, "gc")
