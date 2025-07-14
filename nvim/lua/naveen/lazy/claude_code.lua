return {
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    config = function()
      require("snacks").setup({
        notifier = {
          enabled = true,
          timeout = 3000,
          style = "compact",
          top_down = false,
        },
      })
    end,
  },
  {
    "coder/claudecode.nvim",
    dependencies = {
      "folke/snacks.nvim"
    }
  }
}
