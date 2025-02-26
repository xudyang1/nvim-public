local opt = vim.opt

-- enable project local config
opt.exrc = true

opt.spelllang = "en_us"

-- TODO: custom foldtext
-- opt.fillchars = {
--   eob = " ",
--   fold = " ",
--   foldopen = " ",
--   foldsep = " ",
--   foldclose = " ",
-- }
-- opt.foldcolumn = "1"
opt.foldmethod = "expr"
opt.foldexpr = "v:lua.vim.treesitter.foldexpr()" -- "nvim_treesitter#foldexpr()"
vim.opt.foldtext = ""
opt.foldenable = false
opt.foldnestmax = 4

local space = "·"
opt.listchars:append({
  tab = "▏ ",
  multispace = space,
  lead = space,
  trail = space, -- default "-"
  precedes = "«",
  extends = "»",
  -- nbsp = "␣", -- defualt "+"
  -- space = space,
})

opt.title = true
opt.titlestring = [[%t%( %m%)%( (%<%{(&ft=='help' || &ft=='man')? &ft : expand("%:~:.:h")})%)]]
opt.titlelen = 24

-- TODO: more on rg and fdfind and wildcards...
opt.grepprg =
  [[rg --smart-case --vimgrep --hidden --glob '!{**/.git/*,**/node_modules/*,**/package-lock.json,**/yarn.lock}']]
opt.wildignore = {
  "*/.git/*",
  "*/cache/*",
  "*/tmp/*",
  "*/node_modules/*",
  "*/bin/*",
  "*/build/*",
  "*/target/*",
  "*/out/*",
}
-- for :find *file or :b *file
opt.path:append("**")

-- no welcome message (+="I")
opt.shortmess = "filnxtToOFI"

-- no insert mode mouse
opt.mouse = "nv"

-- opt.guicursor = "n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20"
opt.guicursor = "n-v-c-sm:block,i-ci-ve:block,r-cr-o:hor20"

-- single statusline
-- opt.laststatus = 3
-- NOTE: disabled then enabled by lualine for better lazyloading
opt.laststatus = 0
-- do not show ruler before loading lualine
opt.ruler = false

opt.number = true
-- opt.relativenumber = true

opt.termguicolors = true

-- linewrap
opt.wrap = false
-- if opt.wrap == true, enable more visual effects
-- opt.linebreak = true
-- opt.breakindent = true
-- opt.showbreak = "> "

opt.completeopt = "menu,menuone,preview"

opt.virtualedit = "block"

opt.scrolloff = 8

opt.splitbelow = true
opt.splitright = true

opt.signcolumn = "yes"

opt.formatoptions = "jcroqlnt"

opt.updatetime = 750

opt.undofile = true
-- opt.swapfile = false
-- opt.undodir = ...

-- use default: backup current file, deleted afterwards
-- @see 'backup-table'
-- opt.backup = false
-- opt.writebackup = true

opt.ignorecase = true
opt.smartcase = true

-- opt.cursorline = true

-- default values
-- -- opt.autoindent = true
-- -- opt.smarttab = true

-- @source https://stackoverflow.com/questions/1878974/redefine-tab-as-4-spaces
-- @source https://arisweedler.medium.com/tab-settings-in-vim-1ea0863c5990
-- -- use tab indentation
-- opt.tabstop = 2
-- -- opt.shiftwidth = 0 => set to value of 'tabstop'
-- opt.shiftwidth = 2
-- -- may want to set them defensively
-- -- opt.softtabstop = 0
-- -- opt.expandtab = false

-- @see 'indentexpr' and 'autoindent'
-- opt.smartindent = true

-- use space indentation
opt.expandtab = true
opt.shiftwidth = 2
-- opt.softtabstop < 0 => set to value of 'shiftwidth'
opt.softtabstop = 2
-- default values
-- opt.tabstop = 8 -- make <Tab> char looks different than <Space> indent
