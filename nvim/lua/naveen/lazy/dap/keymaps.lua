---@file dap/keymaps.lua
---@description DAP keybindings with consistent descriptions
---@requires dap, dapui, naveen.lazy.dap.breakpoints

local M = {}

--- Set up all DAP keybindings
---@param dap table The DAP module
---@param dapui table The DAP UI module
---@param breakpoints table The breakpoints module
function M.setup(dap, dapui, breakpoints)
    local set = vim.keymap.set

    -- Execution control
    set("n", "<leader>dc", function() dap.continue() end, { desc = "Debug: Start/Continue" })
    set("n", "<leader>dn", function() dap.step_over() end, { desc = "Debug: Step Over (Next)" })
    set("n", "<leader>di", function() dap.step_into() end, { desc = "Debug: Step Into" })
    set("n", "<leader>do", function() dap.step_out() end, { desc = "Debug: Step Out" })

    -- Breakpoints
    set("n", "<leader>db", function() dap.toggle_breakpoint() end, { desc = "Debug: Toggle Breakpoint" })
    set("n", "<leader>dbc", function()
        dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
    end, { desc = "Debug: Set Conditional Breakpoint" })
    set("n", "<leader>dbl", function()
        dap.set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
    end, { desc = "Debug: Set Log Point" })

    -- UI and inspection
    set("n", "<leader>du", function() dapui.toggle() end, { desc = "Debug: Toggle UI" })
    set("n", "<leader>dr", function() dap.repl.open() end, { desc = "Debug: Open REPL" })
    set("n", "<leader>de", function() dapui.eval() end, { desc = "Debug: Evaluate Expression" })
    set("v", "<leader>de", function() dapui.eval() end, { desc = "Debug: Evaluate Expression" })

    set("n", "<leader>dv", function()
        require("dap.ui.widgets").hover()
        vim.defer_fn(function()
            local buf = vim.api.nvim_get_current_buf()
            vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = buf, noremap = true, silent = true })
        end, 50)
    end, { desc = "Debug: View/Hover Variables" })

    set("n", "<leader>ds", function()
        require("dap.ui.widgets").scopes()
    end, { desc = "Debug: Scopes" })

    set("n", "<leader>df", function()
        local widgets = require("dap.ui.widgets")
        widgets.centered_float(widgets.frames)
    end, { desc = "Debug: Stack Frames" })

    set("n", "<leader>dt", function()
        local widgets = require("dap.ui.widgets")
        widgets.centered_float(widgets.threads)
    end, { desc = "Debug: Threads" })

    -- Stack navigation
    set("n", "<leader>dk", function() dap.up() end, { desc = "Debug: Go Up Stack Frame" })
    set("n", "<leader>dj", function() dap.down() end, { desc = "Debug: Go Down Stack Frame" })

    -- Session control
    set("n", "<leader>dL", function() dap.run_last() end, { desc = "Debug: Run Last" })
    set("n", "<leader>dx", function() dap.terminate() end, { desc = "Debug: Terminate" })
    set("n", "<leader>dq", function() dap.disconnect() end, { desc = "Debug: Quit/Disconnect" })
    set("n", "<leader>dl", "<cmd>DapShowLog<CR>", { desc = "Debug: Show Log" })

    -- Multi-session management
    local sessions = require("naveen.lazy.dap.sessions")
    set("n", "<leader>dN", sessions.run_new, { desc = "Debug: Start New Session" })
    set("n", "<leader>dss", sessions.switch_picker, { desc = "Debug: Switch Session" })
    set("n", "<leader>dsx", sessions.terminate_picker, { desc = "Debug: Terminate Session (pick)" })
    set("n", "<leader>dso", function()
        require("naveen.lazy.dap.output").show_output()
    end, { desc = "Debug: Show Session Output" })
    set("n", "<leader>dA", sessions.terminate_all, { desc = "Debug: Terminate All Sessions" })

    -- Breakpoint management
    set("n", "<leader>dS", breakpoints.save, { desc = "Debug: Save Breakpoints" })
    set("n", "<leader>dR", breakpoints.load, { desc = "Debug: Restore Breakpoints" })
    set("n", "<leader>dX", breakpoints.clear_all, { desc = "Debug: Clear All Breakpoints" })
end

--- Get lazy.nvim keys spec for lazy loading
---@return table[] # Keys table for lazy.nvim
function M.lazy_keys()
    return {
        { "<leader>dc", function() require("dap").continue() end, desc = "Debug: Start/Continue" },
        { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Debug: Toggle Breakpoint" },
        { "<leader>du", function() require("dapui").toggle() end, desc = "Debug: Toggle UI" },
    }
end

return M
