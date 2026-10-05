local target_architecture = ""
if vim.g.IN_WINDOWS then
  -- "--target=x86_64-w64-mingw64" or "x86_64-w64-mingw32"("x86_64-w64-windows-gnu")
  target_architecture = "--target=x86_64-w64-mingw32"
elseif vim.g.IN_LINUX then
  target_architecture = "--target=x86_64-linux-gnu"
end

-- may resolve [fe_expected_compiler_job]
local query_driver = string.format("--query-driver=%s", vim.fn.exepath(vim.g.IN_WINDOWS and "g++.exe" or "g++"))

return {
  cmd = {
    "clangd",
    "--all-scopes-completion",
    "--header-insertion=iwyu",
    -- "--background-index=false",
    "--fallback-style=LLVM", -- set to webkit for 4-space indent
    "--completion-style=detailed",
    query_driver,
    -- "--pch-storage=memory",
    -- "--compile-commands-dir=./build",
    -- "--compile_args_from=lsp", -- or filesystem
    -- "--pretty",
    -- "--clangd-tidy", -- BUG: results in client exit with 1
  },
  init_options = {
    fallbackFlags = {
      target_architecture,
      "-Wall",
      "-Werror",
      "-Wextra",
      "-pedantic",
      "-Wshadow",
      "-Wconversion",
      "-Wfloat-equal",
      "-Wno-unused-const-variable",
      "-Wno-sign-conversion",
      "-fvisibility=hidden",
      "-fsanitize=address,undefined",
      "-fno-omit-frame-pointer",
      "-fno-sanitize-recover",
      "-O2",
      "-xc++",
      "-std=c++23",
      -- "-Wno-missing-prototypes", -- only in c or obj-c
    },
  },
}
