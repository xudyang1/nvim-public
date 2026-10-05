return {
  settings = {
    pyright = {
      -- Using Ruff's import organizer
      disableOrganizeImports = true,
    },
    python = {
      analysis = {
        exclude = {
          "**/node_modules",
          "**/__pycache__",
          "**/.venv",
          "**/venv",
          "**/dist",
          "**/build",
        },
        -- Ignore all files for analysis to exclusively use Ruff for linting
        ignore = { "*" },
        autoSearchPaths = true,
        diagnosticMode = "openFilesOnly",
        useLibraryCodeForTypes = true,
        autoImportCompletions = true,
        -- typeCheckingMode = "standard", -- "off", "basic", "standard", "strict", "recommended" (default), "all"
      },
    },
  },
  on_attach = function(client, bufnr)
    local venv_path = vim.fs.find({ ".venv", "venv" }, {
      upward = true,
      stop = vim.fs.normalize("~"),
      type = "directory",
      path = vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr)),
    })[1]
    local python_executable = venv_path
      and string.format("%s/%s", venv_path, vim.g.IN_WINDOWS and "Scripts/python.exe" or "bin/python")
    if python_executable then
      client.settings = client.settings or {}
      client.settings.python = client.settings.python or {}
      client.settings.python.pythonPath = python_executable
    end
  end,
}
-- -- after/lsp/basedpyright.lua:
-- return {
--   settings = {
--     basedpyright = {
--       -- Using Ruff's import organizer
--       disableOrganizeImports = true,
--       analysis = {
--         exclude = {
--           "**/node_modules",
--           "**/__pycache__",
--           "**/.venv",
--           "**/venv",
--           "**/dist",
--           "**/build",
--         },
--         -- Ignore all files for analysis to exclusively use Ruff for linting
--         ignore = { "*" },
--         autoSearchPaths = true,
--         diagnosticMode = "openFilesOnly",
--         useLibraryCodeForTypes = true,
--         autoImportCompletions = true,
--         -- typeCheckingMode = "standard", -- "off", "basic", "standard", "strict", "recommended" (default), "all"
--       },
--     },
--   },
--   on_attach = function(client, bufnr)
--     local venv_path = vim.fs.find({ ".venv", "venv" }, {
--       upward = true,
--       stop = vim.fs.normalize("~"),
--       type = "directory",
--       path = vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr)),
--     })[1]
--     local python_executable = venv_path
--       and string.format("%s/%s", venv_path, vim.g.IN_WINDOWS and "Scripts/python.exe" or "bin/python")
--     if python_executable then
--       client.settings = client.settings or {}
--       client.settings.python = client.settings.python or {}
--       client.settings.python.pythonPath = python_executable
--     end
--   end,
-- }
