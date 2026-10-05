-- vim.filetype.add({ extension = { mdx = "markdown" } })

local map = vim.keymap.set

---@type fun(evt: { buf: integer })
local markdown_cb = function(evt)
  local buf = evt.buf
  if vim.bo[buf].buftype == "nofile" then
    return
  end

  local extension = vim.g.IN_WINDOWS and ".cmd" or ""
  local prettier = string.format("%s/mason/bin/prettier%s", vim.fn.stdpath("data"), extension)
  local keymaps = {
    {
      { "n", "x" },
      "<Leader>F",
      function()
        if vim.fn.mode() == "n" then
          require("nvim-treesitter-textobjects.select").select_textobject("@table")
        end
        vim.cmd.execute(string.format([["normal! :!%s --parser markdown\<CR>"]], prettier))
      end,
      { desc = "Markdown: format with prettier" },
    },

    { { "x", "o" }, "it", "i`", { desc = "@code_span.inner" } },
    { { "x", "o" }, "at", "a`", { desc = "@code_span.outer" } },
  }
  for _, map_entry in ipairs(keymaps) do
    local opts = map_entry[4] or {}
    opts.buf = buf
    map(map_entry[1], map_entry[2], map_entry[3], opts)
  end

  --- select textobjects
  local select_maps = {
    { "iH", "@header.inner" },
    { "aH", "@header.outer" },
    { "iC", "@code_block.inner" },
    { "aC", "@code_block.outer" },
  }
  for _, select_entry in ipairs(select_maps) do
    map({ "x", "o" }, select_entry[1], function()
      require("nvim-treesitter-textobjects.select").select_textobject(select_entry[2])
    end, { buf = buf, desc = select_entry[2] })
  end

  --- move to textobjects
  local move_maps = {
    { "H", "@header.outer" },
    { "C", "@code_block.outer" },
  }
  for _, move_entry in ipairs(move_maps) do
    local lhs, textobject = move_entry[1], move_entry[2]
    local scope = "textobjects"
    map({ "n", "x", "o" }, "[" .. lhs, function()
      require("nvim-treesitter-textobjects.move").goto_previous_start(textobject, scope)
    end, { buf = buf, desc = textobject .. ": prev start" })
    map({ "n", "x", "o" }, "]" .. lhs, function()
      require("nvim-treesitter-textobjects.move").goto_next_start(textobject, scope)
    end, { buf = buf, desc = textobject .. ": next start" })
  end

  --- toggle delimiters
  local delimiters = {
    strong_emphasis = { "**", "__" },
    emphasis = { "*", "_" },
    strikethrough = { "~" },
    code_span = { "`" },
    latex_block = { "$" },
  }
  local function unwrap(node_type)
    local node = vim.treesitter.get_node({ ignore_injections = false })
    while node and node:type() ~= node_type do
      node = node:parent()
    end
    if not node then
      return
    end
    local text = vim.treesitter.get_node_text(node, 0)

    local delimiter = delimiters[node_type] or {}
    for _, delim in ipairs(delimiter) do
      if vim.startswith(text, delim) and text:sub(-#delim) == delim then
        text = text:sub(#delim + 1, -#delim - 1)
        break
      end
    end

    local replacement = vim.split(text, vim.g.IN_WINDOWS and "\r?\n" or "\n")
    local sr, sc, er, ec = node:range()
    vim.api.nvim_buf_set_text(0, sr, sc, er, ec, replacement)
  end
  local function wrap(node_type)
    local delimiter = delimiters[node_type][1] or ""
    local mode = vim.fn.mode(true)

    vim.cmd.execute([["normal! \<Esc>"]])

    local sr = vim.fn.line("'<") - 1
    local er = vim.fn.line("'>") - 1
    local sc = vim.fn.col("'<") - 1
    local ec = vim.fn.col("'>")

    local text = vim.api.nvim_buf_get_text(0, sr, sc, er, ec, {})
    text[1] = delimiter .. text[1]
    text[#text] = text[#text] .. delimiter

    if mode == "V" then
      ec = ec - 1
    end
    vim.api.nvim_buf_set_text(0, sr, sc, er, ec, text)
  end

  local toggle_maps = {
    { "strong_emphasis", "<Leader>B" },
    { "emphasis", "<Leader>I" },
    { "strikethrough", "<Leader>S" },
    { "code_span", "<Leader>C" },
    { "latex_block", "<Leader>M" },
  }
  for _, toggle_entry in ipairs(toggle_maps) do
    map("n", toggle_entry[2], function()
      unwrap(toggle_entry[1])
    end, { buf = buf, desc = "Markdown: unwrap " .. toggle_entry[1] })
    map("x", toggle_entry[2], function()
      wrap(toggle_entry[1])
    end, { buf = buf, desc = "Markdown: wrap " .. toggle_entry[1] })
  end
end

---@type fun(evt: { buf: integer })
local cpp_cb = function(evt)
  vim.keymap.set("n", "<Leader>cr", function()
    local cpp_executable = require("utils.cpp").new(evt.buf, { debug = true })
    if not cpp_executable then
      vim.notify("No way to build the executable", vim.log.levels.ERROR)
      return
    end
    vim.cmd(string.format("belowright terminal %s && %s", cpp_executable.build_command, cpp_executable.target_path))
  end, { buf = evt.buf, desc = "Cpp: build and run" })
end

---@type fun(evt: { buf: integer })
local man_cb = function(evt)
  local buf = evt.buf
  if vim.bo[buf].modifiable or not vim.bo[buf].readonly then
    return
  end
  map({ "n", "x" }, "d", "<C-d>", { buf = buf, desc = "man: Page down" })
  map({ "n", "x" }, "u", "<C-u>", { buf = buf, desc = "man: Page up" })
end

---@type fun(evt: { buf: integer })
local help_cb = function(evt)
  local buf = evt.buf
  if vim.bo[buf].modifiable or not vim.bo[buf].readonly then
    return
  end
  map({ "n", "x" }, "q", "<Cmd>quit<Cr>", { buf = buf, desc = "help: Quit" })
  map({ "n", "x" }, "d", "<C-d>", { buf = buf, desc = "help: Page down" })
  map({ "n", "x" }, "u", "<C-u>", { buf = buf, desc = "help: Page up" })
end

---@type fun(evt: { buf: integer })
local qf_cb = function(evt)
  map("n", "q", "<Cmd>quit<Cr>", { buf = evt.buf, desc = "qf: quit" })
  map("n", "o", "<Enter>", { buf = evt.buf, desc = "qf: open" })
  map("n", "<C-s>", "<C-w><Enter>", { buf = evt.buf, desc = "qf: horizontal split" })
  map("n", "<C-v>", "<C-w><Enter><C-w>L", { buf = evt.buf, desc = "qf: vertical split" })
  map("n", "<C-t>", "<C-w>gF", { buf = evt.buf, desc = "qf: new tab" })
end

local autocmds = {
  markdown = markdown_cb,
  cpp = cpp_cb,
  man = man_cb,
  help = help_cb,
  qf = qf_cb,
}

local api = vim.api
local augroup = api.nvim_create_augroup("CustomAutocmd", { clear = true })
for filetype, cb in pairs(autocmds) do
  api.nvim_create_autocmd("FileType", {
    pattern = filetype,
    group = augroup,
    callback = cb,
  })
end
local buf = api.nvim_get_current_buf()
api.nvim_exec_autocmds("FileType", { buf = buf, group = augroup })
