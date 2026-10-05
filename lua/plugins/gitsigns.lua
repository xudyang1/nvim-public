return {
  "lewis6991/gitsigns.nvim",
  event = "VeryLazy",
  opts = {
    -- stylua: ignore start
    signs = {
      add          = { text = "▎" }, -- add          = { text = '┃' }, 
      change       = { text = "▎" }, -- change       = { text = '┃' }, 
      delete       = { text = "" }, -- delete       = { text = '_' }, 
      topdelete    = { text = "" }, -- topdelete    = { text = '‾' }, 
      changedelete = { text = "▎" }, -- changedelete = { text = '~' }, 
      untracked    = { text = "▎" }, -- untracked    = { text = '┆' }, 
    },
    signs_staged = {
      add          = { text = "▎" }, -- add          = { text = '┃' },
      change       = { text = "▎" }, -- change       = { text = '┃' },
      delete       = { text = "" }, -- delete       = { text = '_' },
      topdelete    = { text = "" }, -- topdelete    = { text = '‾' },
      changedelete = { text = "▎" }, -- changedelete = { text = '~' },
      untracked    = { text = "▎" }, -- untracked    = { text = '┆' },
    },
    -- stylua: ignore end
    attach_to_untracked = true,
    on_attach = function(bufnr)
      local gs = require("gitsigns")

      -- TODO: reset_base, change_base, reset_buffer_index
      -- stylua: ignore start
      local mappings = {
        { { "o", "x" }, "ah", ":<C-U>Gitsigns select_hunk<CR>", "select hunk" },
        { { "n", "x" }, "]h", function() gs.nav_hunk("next") end, "next hunk" },
        { { "n", "x" }, "[h", function() gs.nav_hunk("prev") end, "prev hunk" },

        { "n", "<Leader>hs", gs.stage_hunk, "toggle stage hunk" },
        { "x", "<Leader>hs", function() gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "toggle stage hunk" },
        { "n", "<Leader>hS", gs.stage_buffer, "stage buffer" },

        { "n", "<Leader>hu", gs.stage_hunk, "toggle stage hunk" },
        { "x", "<Leader>hu", function() gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "toggle stage hunk" },
        { "n", "<Leader>hU", gs.reset_buffer_index, "unstage buffer" },

        { "n", "<Leader>hr", gs.reset_hunk, "reset hunk" },
        { "x", "<Leader>hr", function() gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "reset hunk" },
        { "n", "<Leader>hR", gs.reset_buffer, "reset buffer" },

        { "n", "<Leader>hd", gs.diffthis, "diff index" },
        { "n", "<Leader>hD", function() gs.diffthis("~") end, "diff last commit" },

        { "n", "<Leader>hb", function() gs.blame_line({ full = true }) end, "blame line" },
        { "n", "<Leader>hB", gs.blame, "toggle blame" },

        { "n", "<Leader>hp", gs.preview_hunk, "preview hunk" },
        { "n", "<Leader>hi", gs.preview_hunk_inline, "preview hunk inline" },
        { "n", "<Leader>hI", function()
            gs.toggle_numhl()
            gs.toggle_linehl()
            gs.toggle_word_diff()
            gs.toggle_deleted()
          end,
          "toggle buffer preview inline"
        },

        { "n", "<leader>hq", function() gs.setqflist() end, "quickfix buffer" },
        { "n", "<leader>hQ", function() gs.setqflist("all") end, "quickfix workspace" },
        { "n", "<leader>hl", function() gs.setqflist(0, { use_location_list = true }) end, "loclist buffer" },
        { "n", "<leader>hL", function() gs.setqflist("all", { use_location_list = true }) end, "loclist workspace" },
      }
      -- stylua: ignore end

      local map = vim.keymap.set
      for _, mapping in ipairs(mappings) do
        map(mapping[1], mapping[2], mapping[3], { buf = bufnr, desc = string.format("GitSigns: %s", mapping[4]) })
      end
    end,
  },
}
