return {
  settings = {
    yaml = {
      keyOrdering = false,
      format = {
        enable = false, -- use prettier or other universal formatters
      },
      validate = {
        enable = true,
      },
      -- schemastore.nvim
      schemaStore = {
        -- You must disable built-in schemaStore support if you want to use
        -- this plugin and its advanced options like `ignore`.
        enable = false,
        -- Avoid TypeError: Cannot read properties of undefined (reading 'length')
        url = "",
      },
      schemas = require("schemastore").yaml.schemas({}),
      -- use yamlls
      -- @see: https://github.com/b0o/SchemaStore.nvim/issues/3
      -- @bug: https://github.com/redhat-developer/yaml-language-server/issues/807
      -- schemaStore = {
      --   enable = true,
      -- },
      -- schemas = {
      --   ["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*",
      -- },
    },
  },
}
