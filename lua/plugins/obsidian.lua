local notes_path = vim.fs.normalize("~/notes")
return {
  "epwalsh/obsidian.nvim",
  version = "*", -- recommended, use latest release instead of latest commit
  -- ft = "markdown",
  -- Replace the above line with this if you only want to load obsidian.nvim for markdown files in your vault:
  -- stylua: ignore start
  event = {
    -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand'.
    -- E.g. "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/**.md"
    "BufReadPre " .. notes_path .. "/*.md",
    "BufNewFile " .. notes_path .. "/*.md",
  },
  -- stylua: ignore end
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  config = function()
    vim.schedule(function()
      require("obsidian").setup({
        workspaces = {
          {
            name = "personal",
            path = notes_path,
          },
        },
        daily_notes = {
          -- Optional, if you keep daily notes in a separate directory.
          folder = "dailies",
          -- Optional, if you want to change the date format for the ID of daily notes.
          date_format = "%Y-%m-%d",
          -- Optional, if you want to change the date format of the default alias of daily notes.
          alias_format = "%B %-d, %Y",
          -- Optional, if you want to automatically insert a template from your template directory like 'daily.md'
          template = nil,
        },

        -- Optional, completion of wiki links, local markdown links, and tags using nvim-cmp.
        completion = {
          -- Set to false to disable completion.
          nvim_cmp = true,

          -- Trigger completion at 2 chars.
          min_chars = 2,
        },

        -- Optional, configure key mappings. These are the defaults. If you don't want to set any keymappings this
        -- way then set 'mappings = {}'.
        mappings = {
          -- Overrides the 'gf' mapping to work on markdown/wiki links within your vault.
          ["gf"] = {
            action = function()
              return require("obsidian").util.gf_passthrough()
            end,
            opts = { noremap = false, expr = true, buffer = true, desc = "Obisdian: Follow Link" },
          },
          -- Toggle check-boxes.
          ["<leader>ch"] = {
            action = function()
              return require("obsidian").util.toggle_checkbox()
            end,
            opts = { buffer = true, desc = "Obsidian: Toggle Checkbox" },
          },
        },
        new_notes_location = "current_dir",
        note_id_func = function(title)
          local suffix = ""
          if title ~= nil then
            -- If title is given, transform it into valid file name.
            suffix = title:gsub(" ", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
          else
            -- If title is nil, just add 4 random uppercase letters to the suffix.
            for _ = 1, 4 do
              suffix = suffix .. string.char(math.random(65, 90))
            end
          end
          return tostring(os.time()) .. "-" .. suffix
        end,
        -- https://github.com/epwalsh/obsidian.nvim/pull/406
        -- Optional, customize how wiki links are formatted.
        ---@param opts {path: string, label: string, id: string|?}
        ---@return string
        wiki_link_func = function(opts)
          -- prepend_note_path
          if opts.label ~= opts.path then
            return string.format("[[%s#%s]]", opts.path, opts.label)
          else
            return string.format("[[%s]]", opts.path)
          end
        end,
        -- Optional, customize how markdown links are formatted.
        ---@param opts {path: string, label: string, id: string|?}
        ---@return string
        markdown_link_func = function(opts)
          return string.format("[%s](%s)", opts.label, opts.path)
        end,
        -- Either 'wiki' or 'markdown'.
        preferred_link_style = "wiki",
        -- Optional, customize the default name or prefix when pasting images via `:ObsidianPasteImg`.
        ---@return string
        image_name_func = function()
          -- Prefix image names with timestamp.
          return string.format("%s-", os.time())
        end,
        -- Optional, boolean or a function that takes a filename and returns a boolean.
        -- `true` indicates that you don't want obsidian.nvim to manage frontmatter.
        disable_frontmatter = false,
        -- Optional, alternatively you can customize the frontmatter data.
        note_frontmatter_func = function(note)
          -- This is equivalent to the default frontmatter function.
          local out = { id = note.id, aliases = note.aliases, tags = note.tags }
          -- `note.metadata` contains any manually added fields in the frontmatter.
          -- So here we just make sure those fields are kept in the frontmatter.
          if note.metadata ~= nil and not vim.tbl_isempty(note.metadata) then
            for k, v in pairs(note.metadata) do
              out[k] = v
            end
          end
          return out
        end,
        -- Optional, by default when you use `:ObsidianFollowLink` on a link to an external
        -- URL it will be ignored but you can customize this behavior here.
        --- @param url string
        follow_url_func = function(url)
          -- Open the URL in the default web browser.
          if vim.g.IN_WINDOWS then
            vim.fn.jobstart("start " .. url) -- windows
          elseif vim.g.IN_WSL then
            vim.fn.jobstart("wslview " .. url) -- wsl2
          end
          -- vim.fn.jobstart({"xdg-open", url})  -- linux
        end,
        -- Optional, set to true if you use the Obsidian Advanced URI plugin.
        -- https://github.com/Vinzent03/obsidian-advanced-uri
        use_advanced_uri = false,
        -- Optional, set to true to force ':ObsidianOpen' to bring the app to the foreground.
        open_app_foreground = false,
        -- Optional, by default commands like `:ObsidianSearch` will attempt to use
        -- telescope.nvim, fzf-lua, fzf.vim, or mini.pick (in that order), and use the
        -- first one they find. You can set this option to tell obsidian.nvim to always use this
        -- finder.
        picker = {
          -- Set your preferred picker. Can be one of 'telescope.nvim', 'fzf-lua', or 'mini.pick'.
          name = "telescope.nvim",
          -- Optional, configure key mappings for the picker. These are the defaults.
          -- Not all pickers support all mappings.
          mappings = {
            -- Create a new note from your query.
            new = "<C-x>",
            -- Insert a link to the selected note.
            insert_link = "<C-l>",
          },
        },
        -- Optional, sort search results by "path", "modified", "accessed", or "created".
        -- The recommend value is "modified" and `true` for `sort_reversed`, which means, for example,
        -- that `:ObsidianQuickSwitch` will show the notes sorted by latest modified time
        sort_by = "modified",
        sort_reversed = true,
        -- Optional, determines how certain commands open notes. The valid options are:
        -- 1. "current" (the default) - to always open in the current window
        -- 2. "vsplit" - to open in a vertical split if there's not already a vertical split
        -- 3. "hsplit" - to open in a horizontal split if there's not already a horizontal split
        open_notes_in = "current",
        -- Optional, configure additional syntax highlighting / extmarks.
        ui = {
          enable = false, -- use render-markdown.nvim ui
        },
      })
    end)
  end,
}
