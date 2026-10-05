return {
  "sindrets/diffview.nvim",
  cmd = "DiffviewOpen",
  keys = {
    { "<Leader>vt", "<Cmd>DiffviewToggleFiles<Cr>", desc = "Diffview: toggle file panel" },
    { "<Leader>vr", "<Cmd>DiffviewRefresh<Cr>", desc = "Diffview: refresh" },
    { "<Leader>vo", "<Cmd>DiffviewOpen<Cr>", desc = "Diffview: open" },
    { "<Leader>vO", ":DiffviewOpen ", desc = "Diffview: open with commit" },
    { "<Leader>vc", "<Cmd>DiffviewClose<Cr>", desc = "Diffview: close" },
    { "<Leader>vh", mode = { "n", "x" }, ":DiffviewFileHistory<Cr>", desc = "Diffview: file history", silent = true },
    { "<Leader>vH", "<Cmd>DiffviewFileHistory %<Cr>", desc = "Diffview: current file history" },
    { "<Leader>vl", "<Cmd>DiffviewLog<Cr>", desc = "Diffview: log" },
  },
  opts = {},
}
