---@file dap/languages/python.lua
---@description Python debug adapter configuration
---@requires naveen.core.env

local M = {}

local env = require("naveen.core.env")

--- Set up Python debugging
---@param dap table The DAP module
function M.setup(dap)
    -- Initialize Python configurations table
    dap.configurations.python = dap.configurations.python or {}

    -- Set up dap-python
    require("dap-python").setup("python3")

    -- Python with arguments
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

    -- Python with environment variables prompt
    table.insert(dap.configurations.python, {
        type = "python",
        request = "launch",
        name = "Launch with env vars",
        program = "${file}",
        env = function()
            return env.prompt_additional_env_vars()
        end,
    })

    -- Python with single .env file
    table.insert(dap.configurations.python, {
        type = "python",
        request = "launch",
        name = "Launch with .env file",
        program = "${file}",
        envFile = "${workspaceFolder}/.env",
    })

    -- Python with local.env file
    table.insert(dap.configurations.python, {
        type = "python",
        request = "launch",
        name = "Launch with local.env file",
        program = "${file}",
        envFile = "${workspaceFolder}/local.env",
    })

    -- Python with multiple env files
    table.insert(dap.configurations.python, {
        type = "python",
        request = "launch",
        name = "Launch with multiple env files",
        program = "${file}",
        env = function()
            return env.prompt_and_load_env_files()
        end,
    })
end

return M
