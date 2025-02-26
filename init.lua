vim.g.IN_WINDOWS = false
vim.g.IN_LINUX = false
vim.g.IN_WSL = false
vim.g.IN_MAC = false

-- local sysname = vim.uv.os_uname().sysname
-- if sysname == "Windows_NT" then
if vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1 then
  vim.g.IN_WINDOWS = true
-- elseif sysname == "Linux" then
elseif vim.fn.has("linux") == 1 then
  vim.g.IN_LINUX = true
  -- if os.getenv("WSL_DISTRO_NAME") ~= nil then
  if vim.fn.has("wsl") == 1 then
    vim.g.IN_WSL = true
  end
elseif vim.fn.has("mac") == 1 then
  vim.g.IN_MAC = true
end

require("config")
