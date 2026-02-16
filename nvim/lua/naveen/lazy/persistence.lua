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

      -- Track the cwd where we started
      local initial_cwd = vim.fn.getcwd()

      vim.api.nvim_create_autocmd("VimEnter", {
        nested = true,
        callback = function()
          local argc = vim.fn.argc()

          local function restore_session()
            require("persistence").load()
            -- Session restore doesn't fire BufReadPost for restored buffers,
            -- so lazy-loaded plugins (LSP, sidekick) never load. Re-trigger events.
            vim.schedule(function()
              for _, buf in ipairs(vim.api.nvim_list_bufs()) do
                if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buftype == "" then
                  if vim.bo[buf].filetype == "" then
                    vim.api.nvim_buf_call(buf, function()
                      vim.cmd("filetype detect")
                    end)
                  end
                end
              end
              -- Re-trigger BufReadPost for the current buffer to kick off lazy plugins
              local buf = vim.api.nvim_get_current_buf()
              if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buftype == "" then
                vim.api.nvim_exec_autocmds("BufReadPost", { buffer = buf })
              end
            end)
          end

          if argc == 0 then
            -- No args: restore session
            restore_session()
          elseif argc == 1 then
            local arg = vim.fn.argv(0)
            if vim.fn.isdirectory(arg) == 1 then
              -- Directory arg (nvim .): restore session
              restore_session()
            else
              -- File arg: check if it's outside cwd
              local abs_arg = vim.fn.fnamemodify(arg, ":p")
              if not vim.startswith(abs_arg, initial_cwd) then
                -- External file: disable persistence for this session
                require("persistence").stop()
              end
            end
          else
            -- Multiple args: check if all are external
            local all_external = true
            for i = 0, argc - 1 do
              local arg = vim.fn.argv(i)
              local abs_arg = vim.fn.fnamemodify(arg, ":p")
              if vim.startswith(abs_arg, initial_cwd) then
                all_external = false
                break
              end
            end
            if all_external then
              require("persistence").stop()
            end
          end
        end,
      })

      -- Before exiting, check if cwd changed (e.g., worktree switch)
      -- If so, stop persistence to avoid saving wrong session
      vim.api.nvim_create_autocmd("VimLeavePre", {
        callback = function()
          local current_cwd = vim.fn.getcwd()
          if current_cwd ~= initial_cwd then
            require("persistence").stop()
          end
        end,
      })
    end,
    keys = {
      { "<leader>qs", function() require("persistence").load() end, desc = "Restore Session" },
    },
  }
}
