return {
  "nvim-tree/nvim-tree.lua",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  keys = {
    {
      "<C-,>",
      mode = "i",
      [[<Esc>:lua require("nvim-tree.api").tree.toggle({ find_file = true })<CR>]],
      desc = "Toggle Explorer",
    },
    {
      "<C-,>",
      mode = "n",
      function()
        require("nvim-tree.api").tree.toggle({ find_file = true })
      end,
      desc = "Toggle Explorer",
    },
  },
  opts = {
    actions = {
      file_popup = {
        open_win_config = {
          border = "rounded",
        },
      },
    },
    diagnostics = {
      enable = true,
    },
    filters = {
      -- git_ignored = false,
      custom = { "^.git$" },
      -- exclude = { ".github", ".vscode" },
    },
    view = {
      -- for non-float side bar
      -- side = "right",
      float = {
        enable = true,
        quit_on_focus_loss = true,
        open_win_config = function()
          local width = math.floor(40)
          local height = vim.o.lines - 4
          width = math.min(vim.o.columns, width)
          height = math.min(vim.o.lines, height)

          local row = math.floor(((vim.o.lines - height) / 2))
          local col = math.floor(((vim.o.columns - width) / 2))

          return {
            relative = "editor",
            border = "rounded",
            width = width,
            height = height,
            row = row,
            col = col,
          }
        end,
      },
    },
    renderer = {
      -- Display node whose name length is wider than the width of nvim-tree window in floating window.
      full_name = true,
      add_trailing = true,
      group_empty = true,
      root_folder_label = false,
      indent_markers = {
        enable = true,
      },
      icons = {
        glyphs = {
          -- default = "",
          -- symlink = "",
          folder = {
            --   arrow_open = "",
            --   arrow_closed = "",
            default = " ",
            open = " ",
            --   empty = "",
            --   empty_open = "",
            --   symlink = "",
            --   symlink_open = "",
          },
          git = {
            unstaged = "●",
            staged = "S",
            unmerged = "",
            renamed = "➜",
            untracked = "U",
            deleted = "",
            ignored = "◌",
          },
        },
      },
    },
    on_attach = function(bufnr)
      local api = require("nvim-tree.api")
      local map = vim.keymap.set
      local function opts_with_desc(desc)
        return { desc = "NvimTree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
      end

      -- default mappings
      api.config.mappings.default_on_attach(bufnr)

      -- custom mappings
      -- toggle hidden filter: H
      -- toggle ignored filter: I
      -- toggle custom filter: U
      -- first/last sibling: K/J
      -- show info popup: <C-k>
      -- delete: d
      -- copy:
      --   basename: ge
      --   fullname: gy
      --   relative: Y
      --   name: y
      -- rename:
      --   omit filename: <C-r>
      --   full path: u
      --   base name: e
      --   rename: r
      -- prev/next Git: [c / ]c
      -- prev/next diagnostics: [e / ]e
      -- live filter: f / F to clear
      -- expand all: E
      -- collapse: W
      map("n", "<Leader>k", api.tree.change_root_to_parent, opts_with_desc("Up"))
      map("n", "<Leader>j", api.tree.change_root_to_node, opts_with_desc("CD to node"))
      map("n", "?", api.tree.toggle_help, opts_with_desc("Help"))
      map("n", "l", api.node.open.edit, opts_with_desc("Open"))
      map("n", "h", api.node.navigate.parent_close, opts_with_desc("Close Directory"))
      map("n", "<Esc>", api.tree.close, opts_with_desc("Close"))
    end,
  },
}
