if vim.g.IN_WINDOWS then
  local opt = vim.opt
  opt.shellslash = true
  -- defaults to cmd.exe
  opt.shell = vim.fs.normalize("~/scoop/apps/git/current/bin/bash.exe")

  opt.shellcmdflag = "-c"
  opt.shellpipe = "2>&1| tee"
  opt.shellquote = ""
  opt.shellxquote = ""
  opt.shellredir = ">%s 2>&1"
  opt.shellxescape = ""
elseif vim.g.IN_WSL then
  if not vim.env.USERPROFILE then
    vim.notify("Please pass USERPROFILE to WSL", vim.log.levels.ERROR)
    return
  end
  local win32yank = vim.env.USERPROFILE .. "/scoop/apps/neovim/current/bin/win32yank.exe"
  local copy = {
    win32yank,
    "-i",
    "--crlf",
  }
  local paste = {
    win32yank,
    "-o",
    "--lf",
  }
  vim.g.clipboard = {
    name = "WslClipboard",
    -- use win32yank.exe from windows neovim
    copy = {
      ["+"] = copy,
      ["*"] = copy,
    },
    paste = {
      ["+"] = paste,
      ["*"] = paste,
    },
    cache_enabled = false,
  }
end
