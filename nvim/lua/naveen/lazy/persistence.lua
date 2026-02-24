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

      -- Save only the active buffer: keep window/buffer info but drop hidden
      -- buffers and extra tabs so only what's in the current window is persisted.
      vim.opt.sessionoptions = { "curdir", "folds", "winsize" }

      local initial_cwd = vim.fn.getcwd()

      -- Before saving, collapse to a single window with just the current buffer
      vim.api.nvim_create_autocmd("User", {
        pattern = "PersistenceSavePre",
        callback = function()
          -- Close all splits
          pcall(vim.cmd, "silent! tabonly | silent! only")

          -- If current buffer is special, try to find a real file buffer
          local cur = vim.api.nvim_get_current_buf()
          local cur_name = vim.api.nvim_buf_get_name(cur)
          local cur_bt = vim.bo[cur].buftype
          if cur_bt ~= "" or cur_name:match("^fugitive://") or cur_name:match("^diffview://") or cur_name:match("^neo%-tree") then
            -- Switch to the most recent real file buffer
            for _, buf in ipairs(vim.api.nvim_list_bufs()) do
              if buf ~= cur and vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_buf_is_loaded(buf) then
                local name = vim.api.nvim_buf_get_name(buf)
                local bt = vim.bo[buf].buftype
                if bt == "" and name ~= "" and not name:match("^fugitive://") and not name:match("^diffview://") then
                  vim.api.nvim_set_current_buf(buf)
                  cur = buf
                  break
                end
              end
            end
          end

          -- Wipe all other buffers so they don't leak into the session
          for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            if buf ~= cur and vim.api.nvim_buf_is_valid(buf) then
              pcall(vim.api.nvim_buf_delete, buf, { force = true })
            end
          end
        end,
      })

      -- Don't restore sessions for git commit/rebase (prevents freeze)
      vim.api.nvim_create_autocmd("VimEnter", {
        nested = true,
        callback = function()
          -- Check filetype and filename patterns for git operations
          local ft = vim.bo.filetype
          if ft == "gitcommit" or ft == "gitrebase" then
            require("persistence").stop()
            return
          end
          -- Also check by filename (filetype may not be set yet for some edge cases)
          local bufname = vim.api.nvim_buf_get_name(0)
          if bufname:match("COMMIT_EDITMSG") or bufname:match("git%-rebase%-todo") then
            require("persistence").stop()
            return
          end

          local argc = vim.fn.argc()

          local function restore_session()
            local persistence = require("persistence")
            local file = persistence.current()
            if vim.fn.filereadable(file) ~= 0 then
              persistence.fire("LoadPre")
              vim.cmd("silent! source " .. vim.fn.fnameescape(file))
              persistence.fire("LoadPost")
            end

            -- Fire BufReadPost so LSP/treesitter attach to the restored buffer
            vim.schedule(function()
              local buf = vim.api.nvim_get_current_buf()
              if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buftype == "" then
                vim.cmd("silent! doautocmd BufReadPost")
              end
            end)
          end

          if argc == 0 then
            restore_session()
          elseif argc == 1 then
            local arg = vim.fn.argv(0)
            if vim.fn.isdirectory(arg) == 1 then
              restore_session()
            else
              local abs_arg = vim.fn.fnamemodify(arg, ":p")
              if not vim.startswith(abs_arg, initial_cwd) then
                require("persistence").stop()
              end
            end
          else
            local all_external = true
            for i = 0, argc - 1 do
              local abs_arg = vim.fn.fnamemodify(vim.fn.argv(i), ":p")
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

      vim.api.nvim_create_autocmd("VimLeavePre", {
        callback = function()
          if vim.fn.getcwd() ~= initial_cwd then
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
