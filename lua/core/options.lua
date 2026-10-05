local opt = vim.opt

if vim.g.IN_WINDOWS then
  -- explicit path used to avoid collision with WSL bash
  -- ':!{cmd}' and ':te[rminal][!] [{cmd}]'
  opt.shell = vim.fs.normalize("~/scoop/apps/git/current/bin/bash.exe")
end

-- project local config
opt.exrc = false

--- UI
opt.fillchars = {
  eob = " ",
  fold = " ",
  foldsep = " ",
  foldinner = "│",
  msgsep = "-",
  -- foldopen = "",
  -- foldclose = "",
}
opt.listchars:append({
  tab = "▏ ",
  multispace = "·",
  lead = " ",
  trail = "·", -- default "-"
  precedes = "«",
  extends = "»",
  nbsp = "␣", -- default "+"
  -- eol = "↴",
  -- space = "·",
})

opt.title = true
-- opt.titlelen = 32
opt.titlestring = [[%t%( %m%r%)%( (%<%{(&ft=='help' || &ft=='man')? &ft : expand("%:~:.:h")})%)]]

-- "ltToOCFIc", I: no intro page, c: no ins-completion-menu
opt.shortmess:append("Ic")
opt.mouse = "nv" -- no insert mode mouse
opt.termguicolors = true
opt.guicursor = "n-v-c-sm:block,i-ci-ve:block,r-cr-o:hor20"
-- opt.cursorline = true
-- opt.colorcolumn = 80

opt.signcolumn = "yes"
opt.formatoptions = "tcqjronl"

opt.winborder = "single"
opt.pumborder = "single"

opt.number = true
-- opt.relativenumber = true

opt.virtualedit = "block"
opt.scrolloff = 8

opt.splitbelow = true
opt.splitright = true

--- Fold
-- opt.foldcolumn = 1
opt.foldenable = false
opt.foldnestmax = 2
opt.foldtext = ""

opt.grepprg = [[rg --smart-case --vimgrep --hidden --glob '!{.git,node_modules,.dotfiles,.cache,.local}']]
opt.wildignore = {
  "*/.git/*",
  "*/.venv/*",
  "*/node_modules/*",
  "*/bin/*",
  "*/build/*",
  "*/dist/*",
  "*/out/*",
}
-- opt.wildoptions:append("fuzzy") -- currently not supported, use wildcard expansion
opt.path:append("**") -- for :find *file or :b *file

opt.wrap = false
--- more visual effects for enabled linewrap
-- opt.linebreak = true
-- opt.breakindent = true
-- opt.showbreak = "> "

opt.complete = "o"
opt.completeopt = { "menu", "popup", "fuzzy", "noselect" }
-- opt.autocomplete = true

opt.ignorecase = true -- search
-- opt.infercase = true -- insert mode
opt.smartcase = true

opt.updatetime = 750
opt.undofile = true -- @see 'undodir'
-- opt.swapfile = false
--- default: backup current file, deleted afterwards, @see 'backup-table'
-- opt.backup = false
-- opt.writebackup = true

--- Status line
-- opt.showmode = false
-- opt.ruler = true
opt.rulerformat = "%14(%l,%c%V%= %P%)"
opt.laststatus = 3

local time_cache = { current = os.date("%H:%M") }
local time_timer = assert(vim.uv.new_timer(), "Failed to create libuv timer")
local update_clock_loop
update_clock_loop = vim.schedule_wrap(function()
  local now = os.date("%H:%M")
  if now ~= time_cache.current then
    time_cache.current = now
    vim.cmd.redrawstatus()
  end
  local tv_sec, tv_usec = vim.uv.gettimeofday()
  local sec = tv_sec % 60
  local ms = math.floor(tv_usec / 1000)
  local ms_until_next_minute = ((60 - sec) * 1000) - ms
  -- prevent negative boundaries and claimp a sane safety minimum (1s)
  if ms_until_next_minute < 1500 then
    ms_until_next_minute = ms_until_next_minute + 60000
  end
  -- queue up the next precise clock
  time_timer:start(ms_until_next_minute, 0, update_clock_loop)
end)
time_timer:start(0, 0, update_clock_loop)
-- selene: allow(global_usage)
_G.custom_statusline = function()
  --- left
  local filename = vim.bo.buftype == "terminal" and vim.bo.filetype or "%f"
  local file_status = string.format("%s%s", filename, "%m%r")

  local git_info = vim.b.gitsigns_status_dict
  local git_comps = {
    { key = "added", symbol = "+", hl = "GitSignsAdd" },
    { key = "changed", symbol = "~", hl = "GitSignsChange" },
    { key = "removed", symbol = "-", hl = "GitSignsDelete" },
  }
  local git_status
  if git_info and git_info.head ~= "" then
    local comps = { "" .. git_info.head }
    for _, v in ipairs(git_comps) do
      local count = git_info[v.key] or 0
      if count > 0 then
        table.insert(comps, string.format("%%#%s#%s%s%%#StatusLine#", v.hl, v.symbol, count))
      end
    end
    git_status = table.concat(comps, " ")
  end

  local diagnostics
  if package.loaded["vim.diagnostic"] and next(vim.diagnostic.count(0)) then
    diagnostics = vim.diagnostic.status()
  end

  local ok, core_util = pcall(require, "vim._core.util")
  local exitcode = ok and core_util.term_exitcode() or nil

  --- right
  local progress
  if package.loaded["vim.ui"] and vim.api.nvim_get_current_win() == tonumber(vim.g.actual_curwin or -1) then
    progress = vim.ui.progress_status()
  end
  local encoding = vim.bo.fileencoding ~= "utf-8" and vim.bo.fileencoding or nil
  local fileformat = vim.bo.fileformat ~= "unix" and vim.bo.fileformat or nil
  local ruler = vim.o.ruler and vim.o.rulerformat or nil
  local time = string.format("%s %s %s", "%#StatusLineTime#", time_cache.current, "%#StatusLine#")

  local left = { file_status, git_status, diagnostics, exitcode }
  local right = { progress, encoding, fileformat, ruler, time }
  local sep = "  "
  local nonempty = function(v)
    return v and v ~= ""
  end
  return string.format(
    "%%<%s%%=%s",
    vim.iter(left):filter(nonempty):join(sep),
    vim.iter(right):filter(nonempty):join(sep)
  )
end
opt.statusline = "%!v:lua.custom_statusline()"

--- winbar
local ignore_list = {
  filetype = { "pager" },
  buftype = { "terminal", "help", "prompt", "nofile", "quickfix", "acwrite" },
}
-- higher priority than ignore_list
local allow_list = {
  filetype = { "dap-repl", "dapui_scopes", "dapui_breakpoints", "dapui_stacks", "dapui_watches", "dapui_console" },
  buftype = {},
}
local tabinfo = {}
vim.api.nvim_create_autocmd({ "WinClosed", "BufWinEnter", "TabClosed" }, {
  group = vim.api.nvim_create_augroup("CustomWinbar", { clear = true }),
  callback = function(evt)
    vim.schedule(function()
      if evt.event == "TabClosed" then
        tabinfo[tonumber(evt.match)] = nil
      end
      local tab_id = vim.api.nvim_get_current_tabpage()
      if evt.event == "WinClosed" then
        if tabinfo[tab_id] and tabinfo[tab_id][evt.win] then
          tabinfo[tab_id][evt.win] = nil
          tabinfo[tab_id].count = tabinfo[tab_id].count - 1
        end
      end

      if not tabinfo[tab_id] then
        tabinfo[tab_id] = { count = 0 }
      end

      local filetype = vim.bo.filetype
      local buftype = vim.bo.buftype
      local win_id = vim.api.nvim_get_current_win()
      if
        vim.tbl_contains(allow_list.filetype, filetype)
        or vim.tbl_contains(allow_list.buftype, buftype)
        or (not vim.tbl_contains(ignore_list.filetype, filetype) and not vim.tbl_contains(ignore_list.buftype, buftype))
      then
        if not tabinfo[tab_id][win_id] then
          tabinfo[tab_id][win_id] = true
          tabinfo[tab_id].count = tabinfo[tab_id].count + 1
        end
      else
        if tabinfo[tab_id][win_id] then
          tabinfo[tab_id][win_id] = nil
          tabinfo[tab_id].count = tabinfo[tab_id].count - 1
        end
      end

      local count = tabinfo[tab_id].count
      local windows = vim.api.nvim_tabpage_list_wins(tab_id)
      for _, winid in ipairs(windows) do
        local buf = vim.api.nvim_win_get_buf(winid)
        local ft = vim.bo[buf].filetype
        local winbar = vim.wo[winid].winbar
        local win_height = vim.api.nvim_win_get_height(winid)

        if count > 1 and win_height > 2 and tabinfo[tab_id][winid] then
          if winbar == "" then
            vim.wo[winid].winbar = ft == "dapui_console" and "DAP Console" or "%f"
          end
        else
          if winbar == "%f" then
            vim.wo[winid].winbar = ""
          end
        end
      end
    end)
  end,
})

-- selene: allow(global_usage)
_G.custom_tabline = function()
  local api = vim.api
  local tabs = api.nvim_list_tabpages()
  local current_tabid = api.nvim_get_current_tabpage()
  local t = {}
  for i, tabid in ipairs(tabs) do
    local hl = tabid == current_tabid and "%#TabLineSel#" or "%#TabLine#"
    local win_id = api.nvim_tabpage_get_win(tabid)
    local bufnr = api.nvim_win_get_buf(win_id)
    local bufname = api.nvim_buf_get_name(bufnr)
    local tabname = bufname == "" and "[No Name]" or vim.fn.fnamemodify(bufname, ":~:.")
    table.insert(t, string.format("%s%%%sT %s %s", hl, i, i, tabname))
  end
  return string.format("%s%s", table.concat(t, " "), "%#TabLineFill#%T")
end
opt.tabline = "%!v:lua.custom_tabline()"

--- Indent ---
-- opt.autoindent = true
-- opt.smarttab = true
-- opt.smartindent = false -- has no effect when using 'indentexpr'

-- @see https://stackoverflow.com/questions/1878974/redefine-tab-as-4-spaces
-- @see https://arisweedler.medium.com/tab-settings-in-vim-1ea0863c5990
--- Tab Indent
-- opt.shiftwidth = 2
-- opt.tabstop = 2
--- may want to set them defensively
-- opt.expandtab = false
-- opt.softtabstop = 0
--- Space Indent
opt.expandtab = true
opt.shiftwidth = 2
opt.softtabstop = 2
-- opt.tabstop = 8 -- make <Tab> char looks different from <Space> indent
