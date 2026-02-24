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

    -- Resolve Python path: prefer uv project venv, fall back to system python3
    local python_path = "python3"
    local venv_python = vim.fn.getcwd() .. "/.venv/bin/python"
    if vim.fn.executable(venv_python) == 1 then
        python_path = venv_python
    else
        -- Try uv to find the python path
        local uv_result = vim.fn.system("uv python find 2>/dev/null")
        uv_result = vim.trim(uv_result)
        if vim.v.shell_error == 0 and uv_result ~= "" then
            python_path = uv_result
        end
    end

    -- Set up dap-python
    require("dap-python").setup(python_path)

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
