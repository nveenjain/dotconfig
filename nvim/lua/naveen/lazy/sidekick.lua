return {
  {
    "folke/sidekick.nvim",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = {
      "folke/snacks.nvim",
      "zbirenbaum/copilot.lua",
    },
    opts = {
      -- Next Edit Suggestions configuration
      nes = {
        enabled = function(buf)
          return not vim.b[buf].large_file
        end,
        debounce = 0,
        trigger = {
          events = { "InsertLeave", "User SidekickNesDone" }
        },
        clear = {
          events = { "InsertEnter" },
          esc = true
        },
        diff = {
          inline = "words"
        }
      },
      -- AI CLI tools configuration
      cli = {
        watch = true,
        tools = {
          claude = {
            cmd = { "claude", "code" },
            url = "https://github.com/anthropics/claude-code"
          },
          codex = {
            cmd = { "codex" },
            url = "https://github.com/openai/codex"
          }
        },
        win = {
          layout = "right",
          keys = {
            hide_n = { "q", "hide", mode = "n" },
            hide_t = { "<c-q>", "hide" },
            prompt = { "<c-p>", "prompt" }
          }
        }
      }
    },
    keys = {
      -- Tab to accept/jump through NES suggestions (works in normal and insert mode)
      {
        "<Tab>",
        function()
          local sidekick = require("sidekick")
          local result = sidekick.nes_jump_or_apply()
          if result then
            return ""
          else
            return "<Tab>"
          end
        end,
        expr = true,
        mode = { "n", "i" },
        desc = "Goto/Apply Next Edit Suggestion"
      },
      -- AI CLI tools
      {
        "<leader>aa",
        function() require("sidekick.cli").toggle() end,
        desc = "Toggle AI CLI"
      },
      {
        "<leader>as",
        function() require("sidekick.cli").select_tool() end,
        desc = "Select AI CLI Tool"
      },
      {
        "<leader>at",
        function() require("sidekick.cli").send() end,
        desc = "Send Context to AI"
      },
      {
        "<leader>av",
        function() require("sidekick.cli").send() end,
        mode = "v",
        desc = "Send Visual Selection to AI"
      },
      {
        "<leader>ap",
        function() require("sidekick.cli").prompt() end,
        desc = "Select AI Prompt"
      }
    }
  }
}
