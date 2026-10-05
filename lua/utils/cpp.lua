---@class CppExecutable
---@field bufnr integer
---@field root_dir string
---@field build_command string
---@field target_path string
local CppExecutable = {}
CppExecutable.__index = CppExecutable

---Initialize a new CppExecutable configuration based on the buffer.
---Automatically detects if it should use CMake or standard compilation.
---@param bufnr? integer Defaults to 0 (current buffer)
---@param opts? { run_all?: boolean, debug?: boolean }
---@return CppExecutable?
function CppExecutable.new(bufnr, opts)
  opts = opts or {}
  local self = setmetatable({}, CppExecutable)
  self.bufnr = bufnr or 0

  local fs = vim.fs
  local format = string.format
  local bufname = vim.api.nvim_buf_get_name(self.bufnr)

  local extension = vim.g.IN_WINDOWS and "exe" or "out"
  local cmake_root = fs.root(self.bufnr, { ".clangd", "CMakePresets.json", "PreLoad.cmake" })

  if cmake_root then
    self.root_dir = cmake_root
    local build_dir = format("%s/build", self.root_dir)
    local cmake_flags = opts.debug and "-DCMAKE_BUILD_TYPE=Debug" or "-DCMAKE_BUILD_TYPE=RelWithDebInfo"

    local target_name
    if opts.run_all then
      target_name = vim.fn.expand("%:h:t") -- dirname
      self.target_path = format("%s/%s.%s", build_dir, target_name, extension)
      cmake_flags = format("%s -DALL=ON --no-warn-unused-cli", cmake_flags)
    else
      local cmakelists_dir = fs.root(self.bufnr, { "CMakeLists.txt" })
      if not cmakelists_dir then
        vim.notify("Detected cmake project (build monolith) but unable to find CMakeLists.txt.", vim.log.levels.ERROR)
        return
      end
      local build_subdirname = vim.fn.fnamemodify(cmakelists_dir, ":t")
      target_name = vim.fn.fnamemodify(bufname, ":t:r") -- filename
      self.target_path = format("%s/%s/%s.%s", build_dir, build_subdirname, target_name, extension)
    end

    self.build_command = format(
      "cmake %s -S %s -B %s && cmake --build %s --target %s",
      cmake_flags,
      self.root_dir,
      build_dir,
      build_dir,
      target_name
    )
  else
    self.root_dir = fs.dirname(bufname)
    local compiler = "g++"
    local compile_opts = format(
      "-Wall -Wextra -Wshadow -Wfloat-equal -Wno-unused-const-variable -Wno-sign-conversion -xc++ -std=c++20 %s",
      opts.debug and "-O0 -g" or "-O2"
    )

    local build_dir = format("%s/build", self.root_dir)
    local target_name = vim.fn.fnamemodify(bufname, ":t:r")
    self.target_path = format("%s/%s.%s", build_dir, target_name, extension)

    self.build_command =
      format("mkdir -p -- %s && %s %s -o %s %s", build_dir, compiler, compile_opts, self.target_path, bufname)
  end

  return self
end

return CppExecutable
