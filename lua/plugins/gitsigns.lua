return {
  "lewis6991/gitsigns.nvim",
  -- event = { "BufReadPre", "BufNewFile" },
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
    preview_config = {
      border = "rounded",
    },
    attach_to_untracked = true,
    on_attach = function(bufnr)
      local gs = require("gitsigns")

      local keymap = vim.keymap.set
      local function map(mode, l, r, opts)
        opts = opts or {}
        opts.buffer = bufnr
        keymap(mode, l, r, opts)
      end

      map("n", "]c", function()
        if vim.wo.diff then
          vim.cmd.normal({ "]c", bang = true })
        else
          gs.nav_hunk(
            "next"
            -- , { target = "all" }
          )
        end
      end, { desc = "GitSigns: Next Hunk" })

      map("n", "[c", function()
        if vim.wo.diff then
          vim.cmd.normal({ "[c", bang = true })
        else
          gs.nav_hunk(
            "prev"
            --, { target = "all" }
          )
        end
      end, { desc = "GitSigns: Prev Hunk" })

      map("n", "<Leader>hs", gs.stage_hunk, { desc = "GitSigns: Stage Hunk" })
      map("x", "<Leader>hs", function()
        gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
      end, { desc = "GitSigns: Stage Hunk" })
      map("n", "<Leader>hr", gs.reset_hunk, { desc = "GitSigns: Reset Hunk" })
      map("x", "<Leader>hr", function()
        gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
      end, { desc = "GitSigns: Reset Hunk" })
      map("n", "<Leader>hu", gs.undo_stage_hunk, { desc = "GitSigns: Undo Stage Hunk" })
      map("n", "<Leader>hS", gs.stage_buffer, { desc = "GitSigns: Stage Buffer" })
      map("n", "<Leader>hR", gs.reset_buffer, { desc = "GitSigns: Reset Buffer" })

      map("n", "<Leader>hd", gs.diffthis, { desc = "GitSigns: Diff Index" })
      map("n", "<Leader>hD", function()
        gs.diffthis("~")
      end, { desc = "GitSigns: Diff Last Commit" })

      map("n", "<Leader>hb", function()
        gs.blame_line({ full = true })
      end, { desc = "GitSigns: Blame Line" })
      map("n", "<Leader>hB", gs.toggle_current_line_blame, { desc = "GitSigns: Toggle Blame" })

      map("n", "<Leader>hp", gs.preview_hunk, { desc = "GitSigns: Preview Hunk" })
      map("n", "<Leader>hi", gs.preview_hunk_inline, { desc = "GitSigns: Preview Hunk Inline" })
      map("n", "<Leader>hI", function()
        gs.toggle_numhl()
        gs.toggle_linehl()
        gs.toggle_word_diff()
        gs.toggle_deleted()
      end, { desc = "GitSigns: Toggle Buffer Inline" })
      -- Text object
      map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", { desc = "GitSigns: Select Hunk" })
      -- TODO: reset_base, change_base, blame, reset_buffer_index
    end,
  },
}
