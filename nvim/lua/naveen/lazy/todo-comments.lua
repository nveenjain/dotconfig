return {
  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "nvim-telescope/telescope.nvim" },
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      keywords = {
        TODO = {
          icon = " ",
          color = "info",
        },
      },
      highlight = {
        pattern = [[.*<(TODO|todo)\([Nn]aveen\)]],
        keyword = "bg",
      },
      search = {
        command = "rg",
        args = {
          "--color=never",
          "--no-heading",
          "--with-filename",
          "--line-number",
          "--column",
          "-i",
        },
        pattern = [[\bTODO\(naveen\)]],
      },
    },
    config = function(_, opts)
      require("todo-comments").setup(opts)
      vim.keymap.set("n", "<leader>st", "<cmd>TodoTelescope<cr>", { desc = "Search TODOs" })
      vim.keymap.set("n", "]t", function() require("todo-comments").jump_next() end, { desc = "Next TODO" })
      vim.keymap.set("n", "[t", function() require("todo-comments").jump_prev() end, { desc = "Previous TODO" })
    end,
  }
}
