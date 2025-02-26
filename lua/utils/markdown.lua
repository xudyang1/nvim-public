local format = string.format

---Get a normal mode keymap function to toggle syntax wrapping
---@param syntaxes string | string[] all valid syntaxes
---@param wrap? string if nil, first one in syntaxes is used
local function toggle_syntax_normal(syntaxes, wrap)
  if type(syntaxes) == "string" then
    syntaxes = { syntaxes }
  end
  wrap = wrap or syntaxes[1]
  local len = wrap:len()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  row = row - 1
  if vim.api.nvim_buf_get_text(0, row, col, row, col + 1, {})[1]:match("^%s*$") then
    vim.cmd(format([[execute "normal! a%s%s\<Esc>%s"]], wrap, wrap, string.rep("h", len - 1)))
    vim.cmd("startinsert")
    return
  end

  local old_reg = vim.fn.getreginfo('"')
  vim.cmd([[execute "normal! yiW"]])
  local s = vim.fn.getreg('"')
  local captures = {}
  for _, syntax in ipairs(syntaxes) do
    local escaped_syntax = vim.pesc(syntax)
    captures = { s:match(format("^%s(%%S-)%s$", escaped_syntax, escaped_syntax)) }
    if #captures > 0 then
      break
    end
  end
  local paste_str = #captures > 0 and captures[1] or format("%s%s%s", wrap, s, wrap)
  vim.fn.setreg('"', paste_str)
  vim.cmd([[execute "normal! \"_diW"]])
  local paste = (vim.fn.col(".") == vim.fn.col("$") - 1) and "p" or "P"
  vim.cmd(format([[execute "normal! %s"]], paste))
  vim.fn.setreg('"', old_reg)
end

---Get a visual mode keymap function to toggle syntax wrapping
---@param syntaxes string | string[] all valid syntaxes
---@param wrap? string if nil, first one in syntaxes is used
local function toggle_syntax_visual(syntaxes, wrap)
  local old_reg = vim.fn.getreginfo('"')
  vim.cmd([[execute "normal! ygv"]])
  local s = vim.fn.getreg('"')

  if type(syntaxes) == "string" then
    syntaxes = { syntaxes }
  end
  wrap = wrap or syntaxes[1]

  local captures = {}
  for _, syntax in ipairs(syntaxes) do
    local escaped_syntax = vim.pesc(syntax)
    captures = { s:match(format("^(%%s*)%s(.-)%s(%%s*)$", escaped_syntax, escaped_syntax)) }
    if #captures > 0 then
      break
    end
  end
  local paste_str
  if #captures > 0 then
    paste_str = table.concat(captures, "")
  else
    captures = { s:match("^(%s*)(.-)(%s*)$") }
    paste_str = format("%s%s%s%s%s", captures[1], wrap, captures[2], wrap, captures[3])
  end
  vim.print("paste_str", '"' .. paste_str .. '"')
  vim.fn.setreg('"', paste_str)
  vim.cmd([[execute "normal! gp"]])
  vim.fn.setreg('"', old_reg)
end

---Get a normal mode keymap function to enter block insert
---@param syntax string block wrapping syntax
local function insert_block(syntax)
  local api = vim.api
  local linenr = api.nvim_win_get_cursor(0)[1]
  local previous_line = linenr > 1 and api.nvim_buf_get_lines(0, linenr - 2, linenr - 1, true)[1] or nil
  local current_line = api.nvim_get_current_line()
  local next_line = linenr < api.nvim_buf_line_count(0) and api.nvim_buf_get_lines(0, linenr, linenr + 1, true)[1]
    or nil

  ---Check line is empty
  ---@param line? string optional line
  ---@return boolean? return true if empty, false otherwise, nil if line does not exist
  local function is_empty(line)
    if line then
      return line:match("^%s*$") and true or false
    end
    return nil
  end

  local is_pre_emp, is_cur_emp, is_next_emp = is_empty(previous_line), is_empty(current_line), is_empty(next_line)
  local old_reg = vim.fn.getreginfo('"')
  local paste_str, paste_cmd
  -- when current line is empty, P always appends current line at the end; otherwise use p with new line
  if is_cur_emp then
    paste_str =
      format("%s%s\n%s%s", is_pre_emp == false and "\n" or "", syntax, syntax, is_next_emp == false and "\n" or "")
    paste_cmd = format("normal! P%s$", is_pre_emp == false and "j")
  else
    paste_str = format("\n%s\n%s\n%s", syntax, syntax, is_next_emp == false and "\n" or "")
    paste_cmd = "normal! pj$"
  end
  vim.fn.setreg('"', paste_str)
  vim.cmd(paste_cmd)
  vim.cmd("startinsert!")
  vim.fn.setreg('"', old_reg)
end

---Get a visual mode keymap function to toggle block wrapping
---@param syntax string block wrapping syntax
local function toggle_block_visual(syntax)
  local old_reg = vim.fn.getreginfo('"')
  vim.cmd([[execute "normal! ygv"]])
  local s = vim.fn.getreg('"')

  local escaped_syntax = vim.pesc(syntax)

  -- strict syntax
  local captures = { s:match(format("^(%%s*)%s[^\n]*\n(.-)\n%s(%%s*)$", escaped_syntax, escaped_syntax)) }
  -- all in one line
  if #captures == 0 then
    captures = { s:match(format("^(%%s*)%s(.-)%s(%%s*)$", escaped_syntax, escaped_syntax)) }
  end

  local paste_str
  if #captures > 0 then
    paste_str = table.concat(captures, "")
  else
    captures = { s:match("^(\n*)(.-)\n?(%s*)$") }
    paste_str = format("%s%s%s%s%s", captures[1], syntax .. "\n", captures[2], "\n" .. syntax, captures[3])
  end
  vim.fn.setreg('"', paste_str)
  vim.cmd([[execute "normal! gp"]])
  vim.fn.setreg('"', old_reg)
end

return {
  toggle_syntax_normal = toggle_syntax_normal,
  toggle_syntax_visual = toggle_syntax_visual,
  toggle_block_visual = toggle_block_visual,
  insert_block = insert_block,
}
