return {
  "ibhagwan/fzf-lua",
  cmd = "FzfLua",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  keys = {
    {
      "<C-f>",
      mode = { "n", "i" },
      function()
        local fzf = require("fzf-lua")
        if vim.fs.find(".git", { upward = true, stop = vim.fs.normalize("~") })[1] then
          fzf.git_files()
        else
          fzf.files()
        end
      end,
      desc = "FzfLua git/files",
    },
    -- stylua: ignore start
    { "<Leader>ff", function() require("fzf-lua").files() end,     desc = "Files"     },
    { "<Leader>fs", function() require("fzf-lua").live_grep() end, desc = "Live grep" },
    { "<Leader>fb", function() require("fzf-lua").buffers() end,   desc = "Buffers"   },
    { "<Leader>fr", function() require("fzf-lua").resume() end,    desc = "Resume"    },
    { "<Leader>fk", function() require("fzf-lua").keymaps() end,   desc = "Keymaps"   },
    { "<Leader>fh", function() require("fzf-lua").helptags() end,  desc = "Help"      },
    { "<Leader>fo", function() require("fzf-lua").oldfiles() end,  desc = "Oldfiles"  },
    { "<Leader>fc", function() require("fzf-lua").commands() end,  desc = "Commands"  },
    { "<Leader>fm", function() require("fzf-lua").manpages() end,  desc = "Manpages"  },
    { "<Leader>fa", function() require("fzf-lua").builtin() end,   desc = "Builtin"   },
    { "<Leader>fv", function() require("fzf-lua").files({ cwd = "~/.config/nvim" }) end, desc = "Nvim config" },
    -- stylua: ignore end
  },
  config = function()
    local fzf = require("fzf-lua")
    local actions = fzf.actions

    if vim.g.IN_WINDOWS then
      vim.env.FZF_DEFAULT_OPTS = nil
    end

    fzf.setup({
      fzf_opts = {
        ["--layout"] = "reverse",
        ["--height"] = "100%",
        ["--cycle"] = true,
        ["--info"] = "inline-right",
        ["--no-separator"] = true,
        ["--tiebreak"] = "length,index",
      },
      fzf_colors = {
        true,
        ["hl"] = { "fg", "PmenuMatch", "bold" },
        ["hl+"] = { "fg", "PmenuMatch", "bold" },
      },
      winopts = {
        backdrop = 100,
        width = 0.5,
        height = 0.5,
        row = 0.5,
        col = 0.5,
        border = vim.o.winborder,
        preview = {
          border = vim.o.winborder,
          hidden = true,
          layout = "vertical",
        },
      },
      keymap = {
        builtin = {
          ["<A-p>"] = "toggle-preview",
          ["<A-/>"] = "toggle-help",
          ["<A-j>"] = "preview-page-down",
          ["<A-k>"] = "preview-page-up",
        },
        fzf = {
          ["ctrl-b"] = "backward-char",
          ["ctrl-f"] = "forward-char",
          ["alt-a"] = "toggle-all",
          ["alt-s"] = "toggle-sort",
          ["alt-g"] = "first",
          ["alt-G"] = "last",
          ["ctrl-y"] = vim.g.IN_WINDOWS
              and table.concat({
                [[execute-silent(echo {} | powershell -NonInteractive -NoProfile -Command]],
                [["[Console]::InputEncoding=[System.Text.Encoding]::UTF8; Set-Clipboard ([Console]::In.ReadToEnd())"]],
                [[)+change-header(Copied to clipboard!)]],
              }, " ")
            or [[execute-silent(printf "\e]52;c;$(echo {} | base64 | tr -d "\n")\a" > /dev/tty;)+change-header(Copied to clipboard!)]],
        },
      },
      buffers = { ignore_current_buffer = true },
      files = {
        hidden = true,
        cwd_prompt = false,
        fd_opts = "--color=never --type f --type l -E .git -E node_modules -E .dotfiles -E .cache -E .local"
          .. (vim.g.IN_WINDOWS and " -E AppData -E scoop" or ""),
        actions = { ["ctrl-g"] = actions.toggle_ignore },
      },
      git = { files = { file_icon_padding = " " } },
      grep = {
        hidden = true,
        rg_opts = string.format(
          [[--column --line-number --no-heading --color=always --smart-case --max-columns=4096 --glob "!{.git,node_modules,.dotfiles,.cache,.local%s}"]],
          vim.g.IN_WINDOWS and ",AppData,scoop" or ""
        ),
        fzf_opts = { ["--history"] = vim.fn.stdpath("data") .. "/fzf-lua-history" },
        keymap = {
          fzf = {
            ["ctrl-p"] = "up",
            ["ctrl-n"] = "down",
            ["ctrl-k"] = "previous-history",
            ["ctrl-j"] = "next-history",
          },
        },
      },
    })
  end,
}
