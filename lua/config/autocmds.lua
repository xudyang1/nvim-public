local api = vim.api
local autocmd = api.nvim_create_autocmd
local map = vim.keymap.set

local user_augroup = api.nvim_create_augroup("UserConfigs", { clear = true })

autocmd("FileType", {
  pattern = "markdown",
  group = user_augroup,
  callback = function(evt)
    local opt_local = vim.opt_local

    -- restore original
    opt_local.tabstop = 8
    -- use two space for indent
    opt_local.expandtab = true
    opt_local.shiftwidth = 2
    opt_local.softtabstop = 2

    ---Format markdown with prettier
    ---@param opts? { normal: boolean }
    local function run_prettier(opts)
      local prettier =
        string.format("%s/mason/bin/prettier%s", vim.fn.stdpath("data"), vim.g.IN_WINDOWS and ".cmd" or "")
      return function()
        if opts and opts.normal then
          vim.cmd("normal! vip")
        end
        vim.cmd(string.format([[execute "normal! :!%s --parser markdown\<CR>"]], prettier))
      end
    end
    -- and optionally use prettier to format table or selections
    local prettier_opts = { buffer = evt.buf, desc = "Format(md): prettier" }
    map("n", "<Leader>md", run_prettier({ normal = true }), prettier_opts)
    map("x", "<Leader>md", run_prettier(), prettier_opts)

    -- bold
    map("n", "<Leader>mb", function()
      local utils = require("utils.markdown")
      utils.toggle_syntax_normal({ "**", "__" })
    end, { buffer = evt.buf, desc = "Wrap: Bold" })
    map("x", "<Leader>mb", function()
      local utils = require("utils.markdown")
      utils.toggle_syntax_visual({ "**", "__" })
    end, { buffer = evt.buf, desc = "Wrap: Bold" })

    -- italic
    map("n", "<Leader>mi", function()
      local utils = require("utils.markdown")
      utils.toggle_syntax_normal({ "*", "_" })
    end, { buffer = evt.buf, desc = "Wrap: Italic" })
    map("x", "<Leader>mi", function()
      local utils = require("utils.markdown")
      utils.toggle_syntax_visual({ "*", "_" })
    end, { buffer = evt.buf, desc = "Wrap: Italic" })

    -- strikethrough
    map("n", "<Leader>mx", function()
      local utils = require("utils.markdown")
      utils.toggle_syntax_normal("~~")
    end, { buffer = evt.buf, desc = "Wrap: Strikethrough" })
    map("x", "<Leader>mx", function()
      local utils = require("utils.markdown")
      utils.toggle_syntax_visual("~~")
    end, { buffer = evt.buf, desc = "Wrap: Strikethrough" })

    -- inline code, backtick
    map("n", "<Leader>mt", function()
      local utils = require("utils.markdown")
      utils.toggle_syntax_normal("`")
    end, { buffer = evt.buf, desc = "Wrap: Inline Code" })
    map("x", "<Leader>mt", function()
      local utils = require("utils.markdown")
      utils.toggle_syntax_visual("`")
    end, { buffer = evt.buf, desc = "Wrap: Inline Code" })
    -- code block
    map("n", "<Leader>mc", function()
      local utils = require("utils.markdown")
      utils.insert_block("```")
    end, { buffer = evt.buf, desc = "Wrap: Code Block" })
    map("x", "<Leader>mc", function()
      local utils = require("utils.markdown")
      utils.toggle_block_visual("```")
    end, { buffer = evt.buf, desc = "Wrap: Code Block" })

    -- inline math
    map("n", "<Leader>mm", function()
      local utils = require("utils.markdown")
      utils.toggle_syntax_normal("$")
    end, { buffer = evt.buf, desc = "Wrap: Inline Math" })
    map("x", "<Leader>mm", function()
      local utils = require("utils.markdown")
      utils.toggle_syntax_visual("$")
    end, { buffer = evt.buf, desc = "Wrap: Inline Math" })
    -- math block
    map("n", "<Leader>mM", function()
      local utils = require("utils.markdown")
      utils.insert_block("$$")
    end, { buffer = evt.buf, desc = "Wrap: Math Block" })
    map("x", "<Leader>mM", function()
      local utils = require("utils.markdown")
      utils.toggle_block_visual("$$")
    end, { buffer = evt.buf, desc = "Wrap: Math Block" })
  end,
})

autocmd("FileType", {
  pattern = "man",
  group = user_augroup,
  callback = function(evt)
    map("n", "d", "<C-d>", { buffer = evt.buf, desc = "PageDown(man)" })
    map("n", "u", "<C-u>", { buffer = evt.buf, desc = "PageUp(man)" })
    -- overwrite q-mapping in runtime/ftplugin/man.vim
    map("n", "q", ":lclose<CR><C-W>q", { buffer = evt.buf, desc = "Quit(man)" })
  end,
})
