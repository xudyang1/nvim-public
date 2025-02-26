return {
  "nvim-telescope/telescope.nvim",
  cmd = "Telescope",
  dependencies = {
    "nvim-lua/plenary.nvim", -- required
    "nvim-tree/nvim-web-devicons", -- optional
    "nvim-telescope/telescope-ui-select.nvim", -- for vim.ui.select
  },
  keys = {
    {
      "<C-f>",
      mode = { "n", "x", "i" },
      function()
        local telescope_builtin = require("telescope.builtin")
        if vim.fn.finddir(".git", vim.fn.getcwd()) ~= "" then
          telescope_builtin.git_files()
        else
          telescope_builtin.find_files()
        end
      end,
      desc = "Telescope git/find_files",
    },
    -- stylua: ignore start
    { "<Leader>ff", function() require("telescope.builtin").find_files() end, desc = "Telescope find_files", },
    { "<Leader>fs", function() require("telescope.builtin").live_grep() end,  desc = "Telescope live_grep",  },
    { "<Leader>fb", function() require("telescope.builtin").buffers() end,    desc = "Telescope buffers",    },
    { "<Leader>fr", function() require("telescope.builtin").resume() end,     desc = "Telescope resume",     },
    { "<Leader>fp", function() require("telescope.builtin").pickers() end,    desc = "Telescope pickers",     },
    { "<Leader>fk", function() require("telescope.builtin").keymaps() end,    desc = "Telescope keymaps",    },
    { "<Leader>fh", function() require("telescope.builtin").help_tags() end,  desc = "Telescope help_tags",  },
    { "<Leader>fo", function() require("telescope.builtin").oldfiles() end,   desc = "Telescope oldfiles",    },
    { "<Leader>fc", function() require("telescope.builtin").commands() end,   desc = "Telescope commands",    },
    { "<Leader>fm", function() require("telescope.builtin").man_pages() end,  desc = "Telescope man_pages",    },
    { "<Leader>fa", function() require("telescope.builtin").builtin() end,    desc = "Telescope builtin",    },
    -- stylua: ignore end
  },
  config = function()
    local telescope = require("telescope")
    local toggle_preview = require("telescope.actions.layout").toggle_preview
    local actions = require("telescope.actions")

    local telescope_builtin = require("telescope.builtin")
    local find_files_no_ignore = function()
      local action_state = require("telescope.actions.state")
      local line = action_state.get_current_line()
      telescope_builtin.find_files({ no_ignore = true, default_text = line })
    end
    local find_files_with_hidden = function()
      local action_state = require("telescope.actions.state")
      local line = action_state.get_current_line()
      telescope_builtin.find_files({ hidden = true, default_text = line })
    end

    local home_pattern = string.format("^%s", vim.pesc(vim.fs.normalize("~")))
    telescope.setup({
      defaults = {
        -- selene: allow(unused_variable)
        ---@diagnostic disable-next-line: unused-local
        path_display = function(opts, path)
          path = string.gsub(path, home_pattern, "~")
          return path
        end,
        cache_picker = {
          ignore_empty_prompt = true,
        },
        -- dropdown theme borders
        borderchars = {
          prompt = { "─", "│", " ", "│", "╭", "╮", "│", "│" },
          results = { "─", "│", "─", "│", "├", "┤", "╯", "╰" },
          preview = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
        },
        layout_strategy = "center", -- "horizontal" (default), "vertical"
        sorting_strategy = "ascending", -- display results from top to bottom
        preview = {
          hide_on_startup = true,
        },
        layout_config = {
          -- default for center layout
          prompt_position = "top",
          horizontal = {
            -- preview width not available in vertical or center layout
            preview_width = 0.5,
          },
          -- dropdown theme
          vertical = {
            preview_cutoff = 0,
          },
          center = {
            preview_cutoff = 0,
            width = 0.5,
            height = 0.5,
          },
          -- width = 0.8,
          -- height = 0.9,
          -- preview_cutoff = 120,
        },
        mappings = {
          n = {
            ["<A-p>"] = toggle_preview,
          },
          i = {
            ["<A-p>"] = toggle_preview,
            ["<A-i>"] = find_files_no_ignore,
            ["<A-h>"] = find_files_with_hidden,
            ["<C-j>"] = actions.cycle_history_next,
            ["<C-k>"] = actions.cycle_history_prev,
            ["<C-g>"] = actions.preview_scrolling_right,
            ["<A-g>"] = actions.results_scrolling_right,
          },
        },
        vimgrep_arguments = {
          "rg",
          "--color=never",
          "--no-heading",
          "--with-filename",
          "--line-number",
          "--column",
          "--smart-case",
          -- additional args
          "--trim",
          "--hidden",
          "--glob", -- hide exclude these files and folders from your search
          "!{**/.git/*,**/node_modules/*,**/package-lock.json,**/yarn.lock}",
        },
        file_ignore_patterns = {
          ".git/",
          "node_modules/",
        },
      },
      pickers = {
        find_files = {
          hidden = true,
        },
        git_files = {
          hidden = true,
        },
        live_grep = {
          hidden = true,
          -- layout_strategy = "horizontal",
          preview = {
            hide_on_startup = false,
          },
        },
        buffers = {
          sort_mru = true,
          ignore_current_buffer = true,
        },
        keymaps = {
          layout_config = {
            width = 0.8,
          },
        },
        commands = {
          layout_config = {
            width = 0.8,
          },
        },
        oldfiles = {
          layout_config = {
            width = 0.7,
          },
        },
        builtin = {
          include_extensions = true,
        },
      },
      -- extensions = {
      --   ["ui-select"] = {
      --     -- require("telescope.themes").get_dropdown({
      --     --   -- even more opts
      --     -- }),
      --   },
      -- },
    })
    -- To get ui-select loaded and working with telescope, you need to call
    -- load_extension, somewhere after setup:
    -- require("telescope").load_extension("ui-select")
  end,
}
