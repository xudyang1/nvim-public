return {
  -- init_options = { settings = {} },
  on_attach = function(client)
    -- disable hover in favor of (based)pyright
    client.server_capabilities.hoverProvider = false
  end,
}
