---@file dap/languages/go.lua
---@description Go/Delve debug adapter configuration
---@requires naveen.core.env

local M = {}

local env = require("naveen.core.env")
local constants = require("naveen.core.constants")

--- Set up Go debugging with Delve
---@param dap table The DAP module
function M.setup(dap)
    -- Initialize Go configurations table
    dap.configurations.go = dap.configurations.go or {}

    -- Set up dap-go with outputMode baked in
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
            -- Key fix: set output_mode here so dap-go uses it
            output_mode = "remote",
        },
    })

    -- Ensure ALL go configurations have outputMode = "remote"
    for _, config in ipairs(dap.configurations.go) do
        config.outputMode = "remote"
        -- Also ensure type is delve for consistency
        if config.type == "go" then
            config.type = "delve"
        end
    end

    -- Configure delve adapter with dynamic port allocation
    dap.adapters.delve = function(callback, config)
        local port = config.port or "${port}"
        if port == "${port}" then
            port = constants.DAP_PORT_BASE + math.random(constants.DAP_PORT_RANGE)
        end

        callback({
            type = "server",
            port = port,
            executable = {
                command = "dlv",
                args = { "dap", "-l", "127.0.0.1:" .. port },
            },
            options = {
                initialize_timeout_sec = 30,
            },
        })
    end

    -- Go configuration with environment variables prompt
    table.insert(dap.configurations.go, {
        type = "delve",
        name = "Debug with env vars",
        request = "launch",
        program = "${file}",
        outputMode = "remote",
        env = function()
            return env.prompt_additional_env_vars()
        end,
    })

    -- Go with single .env file
    table.insert(dap.configurations.go, {
        type = "delve",
        name = "Debug with .env file",
        request = "launch",
        program = "${file}",
        outputMode = "remote",
        envFile = "${workspaceFolder}/.env",
    })

    -- Go with local.env file
    table.insert(dap.configurations.go, {
        type = "delve",
        name = "Debug with local.env file",
        request = "launch",
        program = "${file}",
        outputMode = "remote",
        envFile = "${workspaceFolder}/local.env",
    })

    -- Go with multiple env files
    table.insert(dap.configurations.go, {
        type = "delve",
        name = "Debug with multiple env files",
        request = "launch",
        program = "${file}",
        outputMode = "remote",
        env = function()
            return env.prompt_and_load_env_files()
        end,
    })
end

return M
