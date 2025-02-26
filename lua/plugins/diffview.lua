return {
  "sindrets/diffview.nvim",
  cmd = "DiffviewOpen",
  keys = {
    { "<Leader>vo", ":DiffviewOpen ", desc = "Diffview: Open" },
    { "<Leader>vc", "<Cmd>DiffviewClose<Cr>", desc = "Diffview: Close" },
    { "<Leader>vh", mode = { "n", "x" }, ":DiffviewFileHistory<Cr>", desc = "Diffview: FileHistory", silent = true },
    { "<Leader>vH", "<Cmd>DiffviewFileHistory %<Cr>", desc = "Diffview: CurrentFileHistory" },
    { "<Leader>vl", "<Cmd>DiffviewLog<Cr>", desc = "Diffview: Log" },
  },
  opts = {},
}
