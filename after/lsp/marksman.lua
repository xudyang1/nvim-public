return {
  -- prevent adding `[ERROR]: Starting Marksman LSP server` to lsp.log
  cmd = { "marksman", "server", "-v=1" },
  root_markers = { { ".marksman.toml", ".git" }, "." },
}
