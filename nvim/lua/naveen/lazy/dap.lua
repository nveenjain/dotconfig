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
        keys = {
            { "<leader>dc", function() require("dap").continue() end, desc = "Debug: Start/Continue" },
            { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Debug: Toggle Breakpoint" },
            { "<leader>du", function() require("dapui").toggle() end, desc = "Debug: Toggle UI" },
        },
        config = function()
            local dap = require("dap")
            local dapui = require("dapui")
            
            -- Increase timeout for slow adapters (default is 4000ms)
            dap.defaults.fallback.connect_timeout_fn = function()
                return 30000  -- 30 seconds timeout
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
                    {
                        elements = {
                            { id = "repl", size = 0.5 },
                            { id = "console", size = 0.5 },
                        },
                        size = 10,
                        position = "bottom",
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
                filter_references_pattern = '<module',
                virt_text_pos = 'eol',
                all_frames = false,
                virt_lines = false,
                virt_text_win_col = nil
            })

            -- Golang configuration
            require("dap-go").setup({
                dap_configurations = {
                    {
                        type = "delve",
                        name = "Attach remote",
                        mode = "remote",
                        request = "attach",
                                            },
                },
                delve = {
                    path = "dlv",
                    initialize_timeout_sec = 20,
                    port = "${port}",
                    args = {},
                },
            })
            
            -- Override default dap-go configurations to use delve
            vim.defer_fn(function()
                if dap.configurations.go then
                    for _, config in ipairs(dap.configurations.go) do
                        if config.type == "go" then
                            config.type = "delve"
                            config.outputMode = "remote"
                        end
                    end
                end
            end, 100)
            
            -- Ensure delve adapter is configured
            dap.adapters.delve = {
                type = 'server',
                port = '${port}',
                executable = {
                    command = 'dlv',
                    args = {'dap', '-l', '127.0.0.1:${port}'},
                },
                options = {
                    initialize_timeout_sec = 30,
                }
            }
            
            
            

            -- Python configuration
            require("dap-python").setup("python3")

            -- Python test configurations
            table.insert(dap.configurations.python, {
                type = "python",
                request = "launch",
                name = "Launch file with arguments",
                program = "${file}",
                args = function()
                    local args_string = vim.fn.input("Arguments: ")
                    return vim.split(args_string, " ")
                end,
            })

            -- Python configuration with environment variables
            table.insert(dap.configurations.python, {
                type = "python",
                request = "launch",
                name = "Launch with env vars",
                program = "${file}",
                env = function()
                    local variables = {}
                    for k, v in pairs(vim.fn.environ()) do
                        variables[k] = v
                    end
                    -- Add custom environment variables here or prompt for them
                    local custom_env = vim.fn.input("Additional env vars (KEY=VALUE,KEY2=VALUE2): ")
                    if custom_env ~= "" then
                        for pair in custom_env:gmatch("[^,]+") do
                            local key, value = pair:match("([^=]+)=(.+)")
                            if key and value then
                                variables[key] = value
                            end
                        end
                    end
                    return variables
                end,
            })

            -- Go configuration with environment variables
            table.insert(dap.configurations.go, {
                type = "delve",
                name = "Debug with env vars",
                request = "launch",
                program = "${file}",
                outputMode = "remote",
                env = function()
                    local variables = {}
                    for k, v in pairs(vim.fn.environ()) do
                        variables[k] = v
                    end
                    -- Add custom environment variables here or prompt for them
                    local custom_env = vim.fn.input("Additional env vars (KEY=VALUE,KEY2=VALUE2): ")
                    if custom_env ~= "" then
                        for pair in custom_env:gmatch("[^,]+") do
                            local key, value = pair:match("([^=]+)=(.+)")
                            if key and value then
                                variables[key] = value
                            end
                        end
                    end
                    return variables
                end,
            })

            -- Quick env var configurations for common cases
            table.insert(dap.configurations.python, {
                type = "python",
                request = "launch",
                name = "Launch with .env file",
                program = "${file}",
                envFile = "${workspaceFolder}/.env",
            })

            table.insert(dap.configurations.python, {
                type = "python",
                request = "launch",
                name = "Launch with local.env file",
                program = "${file}",
                envFile = "${workspaceFolder}/local.env",
            })

            table.insert(dap.configurations.go, {
                type = "delve",
                name = "Debug with .env file",
                request = "launch",
                program = "${file}",
                outputMode = "remote",
                envFile = "${workspaceFolder}/.env",
            })

            table.insert(dap.configurations.go, {
                type = "delve",
                name = "Debug with local.env file",
                request = "launch",
                program = "${file}",
                outputMode = "remote",
                envFile = "${workspaceFolder}/local.env",
            })

            -- Load multiple env files
            local function load_env_files()
                local env_vars = {}
                -- Get list of env files from user
                local files_input = vim.fn.input("Env files (comma-separated, e.g., .env,local.env,test.env): ")
                if files_input == "" then
                    return env_vars
                end
                
                local cwd = vim.fn.getcwd()
                for file in files_input:gmatch("[^,]+") do
                    local filepath = cwd .. "/" .. file:match("^%s*(.-)%s*$") -- trim whitespace
                    local f = io.open(filepath, "r")
                    if f then
                        for line in f:lines() do
                            -- Skip comments and empty lines
                            if line:match("^[^#]") and line:match("%S") then
                                local key, value = line:match("^([^=]+)=(.*)$")
                                if key and value then
                                    -- Remove quotes if present
                                    value = value:gsub("^[\"'](.-)[\"\']$", "%1")
                                    env_vars[key:match("^%s*(.-)%s*$")] = value
                                end
                            end
                        end
                        f:close()
                    else
                        vim.notify("Could not open env file: " .. filepath, vim.log.levels.WARN)
                    end
                end
                return env_vars
            end

            table.insert(dap.configurations.python, {
                type = "python",
                request = "launch",
                name = "Launch with multiple env files",
                program = "${file}",
                env = function()
                    local variables = {}
                    -- Start with current environment
                    for k, v in pairs(vim.fn.environ()) do
                        variables[k] = v
                    end
                    -- Load env files
                    local env_from_files = load_env_files()
                    for k, v in pairs(env_from_files) do
                        variables[k] = v
                    end
                    return variables
                end,
            })

            table.insert(dap.configurations.go, {
                type = "delve",
                name = "Debug with multiple env files",
                request = "launch",
                program = "${file}",
                outputMode = "remote",
                env = function()
                    local variables = {}
                    -- Start with current environment
                    for k, v in pairs(vim.fn.environ()) do
                        variables[k] = v
                    end
                    -- Load env files
                    local env_from_files = load_env_files()
                    for k, v in pairs(env_from_files) do
                        variables[k] = v
                    end
                    return variables
                end,
            })

            
            -- DAP UI listeners
            dap.listeners.after.event_initialized["dapui_config"] = function()
                dapui.open()
            end
            dap.listeners.before.event_terminated["dapui_config"] = function()
                dapui.close()
            end
            dap.listeners.before.event_exited["dapui_config"] = function()
                dapui.close()
            end
            
            
            -- Auto-scroll REPL to bottom when new output arrives
            local repl = require('dap.repl')
            local orig_append = repl.append
            repl.append = function(...)
                orig_append(...)
                -- Find REPL buffer and window
                local repl_buf = repl.buf
                if repl_buf and vim.api.nvim_buf_is_valid(repl_buf) then
                    -- Find window displaying REPL buffer
                    for _, win in ipairs(vim.api.nvim_list_wins()) do
                        if vim.api.nvim_win_get_buf(win) == repl_buf then
                            -- Scroll to bottom
                            local line_count = vim.api.nvim_buf_line_count(repl_buf)
                            vim.api.nvim_win_set_cursor(win, {line_count, 0})
                        end
                    end
                end
            end
            
            
            -- Handle cursor position errors
            local orig_jump_to_frame = dap.jump_to_frame
            dap.jump_to_frame = function(frame, preserve_focus_target)
                if frame and frame.line then
                    -- Ensure buffer is loaded and has enough lines
                    vim.schedule(function()
                        local bufnr = vim.fn.bufnr(frame.source.path, true)
                        if bufnr ~= -1 then
                            vim.fn.bufload(bufnr)
                            local line_count = vim.api.nvim_buf_line_count(bufnr)
                            if frame.line > line_count then
                                vim.notify(string.format("Debug frame line %d exceeds buffer lines %d", frame.line, line_count), vim.log.levels.WARN)
                                frame.line = line_count
                            end
                            -- Also check column bounds
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

            -- DAP logging (WARN to reduce disk I/O, change to TRACE for debugging)
            dap.set_log_level('WARN')
            
            -- Keybindings
            vim.keymap.set("n", "<leader>dc", function() dap.continue() end, { desc = "Debug: Start/Continue" })
            vim.keymap.set("n", "<leader>dn", function() dap.step_over() end, { desc = "Debug: Step Over (Next)" })
            vim.keymap.set("n", "<leader>di", function() dap.step_into() end, { desc = "Debug: Step Into" })
            vim.keymap.set("n", "<leader>do", function() dap.step_out() end, { desc = "Debug: Step Out" })
            vim.keymap.set("n", "<leader>db", function() dap.toggle_breakpoint() end, { desc = "Debug: Toggle Breakpoint" })
            vim.keymap.set("n", "<leader>dB", function()
                dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
            end, { desc = "Debug: Set Conditional Breakpoint" })
            vim.keymap.set("n", "<leader>dl", function()
                dap.set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
            end, { desc = "Debug: Set Log Point" })
            vim.keymap.set("n", "<leader>dr", function() dap.repl.open() end, { desc = "Debug: Open REPL" })
            vim.keymap.set("n", "<leader>dL", function() dap.run_last() end, { desc = "Debug: Run Last" })
            vim.keymap.set("n", "<leader>du", function() dapui.toggle() end, { desc = "Debug: Toggle UI" })
            vim.keymap.set("n", "<leader>de", function() dapui.eval() end, { desc = "Debug: Evaluate Expression" })
            vim.keymap.set("v", "<leader>de", function() dapui.eval() end, { desc = "Debug: Evaluate Expression" })
            vim.keymap.set("n", "<leader>dv", function() 
                require("dap.ui.widgets").hover()
                vim.defer_fn(function()
                    local buf = vim.api.nvim_get_current_buf()
                    vim.api.nvim_buf_set_keymap(buf, 'n', 'q', '<cmd>close<CR>', { noremap = true, silent = true })
                end, 50)
            end, { desc = "Debug: View/Hover Variables" })
            vim.keymap.set("n", "<leader>ds", function() require("dap.ui.widgets").scopes() end, { desc = "Debug: Scopes" })
            vim.keymap.set("n", "<leader>df", function()
                local widgets = require("dap.ui.widgets")
                widgets.centered_float(widgets.frames)
            end, { desc = "Debug: Stack Frames" })
            vim.keymap.set("n", "<leader>dt", function()
                local widgets = require("dap.ui.widgets")
                widgets.centered_float(widgets.threads)
            end, { desc = "Debug: Threads" })

            -- Navigation in stack
            vim.keymap.set("n", "<leader>dk", function() dap.up() end, { desc = "Debug: Go Up Stack Frame" })
            vim.keymap.set("n", "<leader>dj", function() dap.down() end, { desc = "Debug: Go Down Stack Frame" })
            
            -- Terminate and disconnect
            vim.keymap.set("n", "<leader>dx", function() dap.terminate() end, { desc = "Debug: Terminate" })
            vim.keymap.set("n", "<leader>dq", function() dap.disconnect() end, { desc = "Debug: Quit/Disconnect" })
            vim.keymap.set("n", "<leader>dl", "<cmd>DapShowLog<CR>", { desc = "Debug: Show Log" })

            -- Breakpoint persistence
            local breakpoints_path = vim.fn.stdpath("data") .. "/dap_breakpoints/"

            local function get_breakpoints_file()
                -- Use project root (git root or cwd) as key
                local cwd = vim.fn.getcwd()
                local git_root = vim.fn.systemlist("git rev-parse --show-toplevel 2>/dev/null")[1]
                local project_dir = (git_root and git_root ~= "" and not git_root:match("^fatal")) and git_root or cwd
                -- Create a safe filename from the path
                local safe_name = project_dir:gsub("[/\\:]", "_"):gsub("^_+", "")
                return breakpoints_path .. safe_name .. ".json"
            end

            local function save_breakpoints()
                local bp_file = get_breakpoints_file()
                -- Ensure directory exists
                vim.fn.mkdir(breakpoints_path, "p")

                local breakpoints_by_buf = require("dap.breakpoints").get()
                local breakpoints_data = {}

                for bufnr, buf_bps in pairs(breakpoints_by_buf) do
                    local bufname = vim.api.nvim_buf_get_name(bufnr)
                    if bufname ~= "" then
                        breakpoints_data[bufname] = buf_bps
                    end
                end

                local json = vim.fn.json_encode(breakpoints_data)
                local file = io.open(bp_file, "w")
                if file then
                    file:write(json)
                    file:close()
                end
            end

            local function load_breakpoints()
                local bp_file = get_breakpoints_file()
                local file = io.open(bp_file, "r")
                if not file then return end

                local content = file:read("*a")
                file:close()

                if content == "" then return end

                local ok, breakpoints_data = pcall(vim.fn.json_decode, content)
                if not ok or not breakpoints_data then return end

                for bufname, buf_bps in pairs(breakpoints_data) do
                    for _, bp in ipairs(buf_bps) do
                        local bufnr = vim.fn.bufadd(bufname)
                        if bufnr > 0 then
                            require("dap.breakpoints").set(bp, bufnr, bp.line)
                        end
                    end
                end
            end

            -- Load breakpoints on startup (deferred to ensure DAP is ready)
            vim.defer_fn(load_breakpoints, 100)

            -- Save breakpoints when they change
            vim.api.nvim_create_autocmd("User", {
                pattern = "DapBreakpointChanged",
                callback = save_breakpoints,
                desc = "Save DAP breakpoints on change"
            })

            -- Keymaps for manual breakpoint management
            vim.keymap.set("n", "<leader>dS", save_breakpoints, { desc = "Debug: Save Breakpoints" })
            vim.keymap.set("n", "<leader>dR", load_breakpoints, { desc = "Debug: Restore Breakpoints" })
            vim.keymap.set("n", "<leader>dX", function()
                require("dap.breakpoints").clear()
                save_breakpoints()
                vim.notify("All breakpoints cleared", vim.log.levels.INFO)
            end, { desc = "Debug: Clear All Breakpoints" })

            -- Auto-close DAP UI on exit to prevent E444 error
            vim.api.nvim_create_autocmd("ExitPre", {
                callback = function()
                    save_breakpoints()
                    local ok, _ = pcall(function()
                        dap.terminate()
                        dapui.close()
                    end)
                    if not ok then
                        -- If DAP UI is already closed or not initialized, ignore the error
                    end
                end,
                desc = "Save breakpoints and close DAP UI before exit"
            })
        end,
    },
}