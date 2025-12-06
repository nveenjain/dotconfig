return {
  {
    "folke/persistence.nvim",
    lazy = false,
    opts = {
      dir = vim.fn.stdpath("state") .. "/sessions/",
      need = 1,
      branch = true,
    },
    config = function(_, opts)
      require("persistence").setup(opts)
      vim.api.nvim_create_autocmd("VimEnter", {
        nested = true,
        callback = function()
          -- Restore if no args OR if only arg is a directory (nvim .)
          local argc = vim.fn.argc()
          if argc == 0 then
            require("persistence").load()
          elseif argc == 1 then
            local arg = vim.fn.argv(0)
            if vim.fn.isdirectory(arg) == 1 then
              require("persistence").load()
            end
          end
        end,
      })
    end,
    keys = {
      { "<leader>qs", function() require("persistence").load() end, desc = "Restore Session" },
    },
  }
}
