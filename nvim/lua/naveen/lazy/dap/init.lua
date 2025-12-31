---@file dap/init.lua
---@description Debug Adapter Protocol configuration
---@requires nvim-dap, nvim-dap-ui, dap-go, dap-python

local constants = require("naveen.core.constants")
local keymaps = require("naveen.lazy.dap.keymaps")

return {
    {
        "mfussenegger/nvim-dap",
        dependencies = {
            "rcarriga/nvim-dap-ui",
            "nvim-neotest/nvim-nio",
            "theHamsta/nvim-dap-virtual-text",
            "leoluz/nvim-dap-go",
            "mfussenegger/nvim-dap-python",
        },
        cmd = { "DapContinue", "DapToggleBreakpoint", "DapShowLog" },
        keys = keymaps.lazy_keys(),
        config = function()
            local dap = require("dap")
            local dapui = require("dapui")
            local breakpoints = require("naveen.lazy.dap.breakpoints")

            -- Increase timeout for slow adapters
            dap.defaults.fallback.connect_timeout_fn = function()
                return constants.DAP_TIMEOUT
            end

            -- DAP UI setup
            dapui.setup({
                icons = { expanded = "▾", collapsed = "▸" },
                mappings = {
                    expand = { "<CR>", "<2-LeftMouse>" },
                    open = "o",
                    remove = "d",
                    edit = "e",
                    repl = "r",
                    toggle = "t",
                },
                layouts = {
                    {
                        elements = {
                            { id = "scopes", size = 0.25 },
                            { id = "breakpoints", size = 0.25 },
                            { id = "stacks", size = 0.25 },
                            { id = "watches", size = 0.25 },
                        },
                        size = 40,
                        position = "left",
                    },
                },
            })

            -- Virtual text for debugging
            require("nvim-dap-virtual-text").setup({
                enabled = true,
                enabled_commands = true,
                highlight_changed_variables = true,
                highlight_new_as_changed = false,
                show_stop_reason = true,
                commented = false,
                only_first_definition = true,
                all_references = false,
                filter_references_pattern = "<module",
                virt_text_pos = "eol",
                all_frames = false,
                virt_lines = false,
                virt_text_win_col = nil,
            })

            -- Set up language-specific configurations
            require("naveen.lazy.dap.languages.go").setup(dap)
            require("naveen.lazy.dap.languages.python").setup(dap)

            -- Load project-specific DAP config
            local function load_project_dap_config()
                local dap_config = vim.fn.getcwd() .. "/.nvim-dap.lua"
                if vim.fn.filereadable(dap_config) == 1 then
                    local ok, err = pcall(dofile, dap_config)
                    if not ok then
                        vim.notify("DAP config error: " .. tostring(err), vim.log.levels.ERROR)
                    end
                end
            end
            load_project_dap_config()

            -- DAP UI listeners (use proper DAP signature: session, body)
            dap.listeners.after.event_initialized["dapui_config"] = function(session, body)
                -- Close first to avoid invalid window errors on restart
                pcall(dapui.close)

                -- Clear console and repl buffers only if this is the first/only session
                -- (don't wipe logs from other running sessions)
                local session_count = vim.tbl_count(dap.sessions())
                if session_count <= 1 then
                    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
                        if vim.api.nvim_buf_is_valid(buf) then
                            local ft = vim.bo[buf].filetype
                            if ft == "dapui_console" or ft == "dap-repl" then
                                local was_modifiable = vim.bo[buf].modifiable
                                vim.bo[buf].modifiable = true
                                pcall(vim.api.nvim_buf_set_lines, buf, 0, -1, false, {})
                                vim.bo[buf].modifiable = was_modifiable
                            end
                        end
                    end
                end

                pcall(dapui.open, { reset = true })

                -- Re-enable Copilot in code buffers when debugging starts
                vim.api.nvim_create_autocmd("BufEnter", {
                    group = vim.api.nvim_create_augroup("NavDapCopilot", { clear = true }),
                    callback = function()
                        local ft = vim.bo.filetype
                        if not constants.DAP_FILETYPES[ft] and ft ~= "" then
                            pcall(function()
                                require("copilot.command").enable()
                            end)
                        end
                    end,
                })
            end

            -- Only close DAP UI when the last session ends (multi-session aware)
            local function close_dap_ui_if_last(session, body)
                local remaining = vim.tbl_count(dap.sessions())
                if remaining <= 1 then
                    dapui.close()
                    pcall(vim.api.nvim_del_augroup_by_name, "NavDapCopilot")
                end
            end

            dap.listeners.before.event_terminated["dapui_config"] = close_dap_ui_if_last
            dap.listeners.before.event_exited["dapui_config"] = close_dap_ui_if_last

            -- Auto-scroll REPL to bottom when new output arrives
            local repl = require("dap.repl")
            local orig_append = repl.append
            repl.append = function(...)
                orig_append(...)
                local repl_buf = repl.buf
                if repl_buf and vim.api.nvim_buf_is_valid(repl_buf) then
                    for _, win in ipairs(vim.api.nvim_list_wins()) do
                        if vim.api.nvim_win_get_buf(win) == repl_buf then
                            local line_count = vim.api.nvim_buf_line_count(repl_buf)
                            vim.api.nvim_win_set_cursor(win, { line_count, 0 })
                        end
                    end
                end
            end

            -- Handle cursor position errors
            local orig_jump_to_frame = dap.jump_to_frame
            dap.jump_to_frame = function(frame, preserve_focus_target)
                if frame and frame.line then
                    vim.schedule(function()
                        local bufnr = vim.fn.bufnr(frame.source.path, true)
                        if bufnr ~= -1 then
                            vim.fn.bufload(bufnr)
                            local line_count = vim.api.nvim_buf_line_count(bufnr)
                            if frame.line > line_count then
                                vim.notify(
                                    string.format("Debug frame line %d exceeds buffer lines %d", frame.line, line_count),
                                    vim.log.levels.WARN
                                )
                                frame.line = line_count
                            end
                            if frame.column and frame.line <= line_count then
                                local line = vim.api.nvim_buf_get_lines(bufnr, frame.line - 1, frame.line, false)[1]
                                if line and frame.column > #line + 1 then
                                    frame.column = #line + 1
                                end
                            end
                        end
                        orig_jump_to_frame(frame, preserve_focus_target)
                    end)
                else
                    orig_jump_to_frame(frame, preserve_focus_target)
                end
            end

            -- Breakpoint signs
            vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DapBreakpoint", linehl = "", numhl = "" })
            vim.fn.sign_define("DapBreakpointCondition", { text = "◆", texthl = "DapBreakpointCondition", linehl = "", numhl = "" })
            vim.fn.sign_define("DapLogPoint", { text = "◆", texthl = "DapLogPoint", linehl = "", numhl = "" })
            vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DapStopped", linehl = "DapStopped", numhl = "DapStopped" })
            vim.fn.sign_define("DapBreakpointRejected", { text = "✗", texthl = "DapBreakpointRejected", linehl = "", numhl = "" })

            -- DAP logging
            dap.set_log_level("WARN")

            -- Set up keymaps, breakpoint persistence, and per-session output
            keymaps.setup(dap, dapui, breakpoints)
            breakpoints.setup(dap)
            require("naveen.lazy.dap.output").setup(dap)
        end,
    },
}
