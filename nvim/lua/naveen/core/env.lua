---@module naveen.core.env
---@description Environment file loading utilities
---@author Naveen

local M = {}

--- Parse a single line from an env file
---@param line string The line to parse
---@return string|nil, string|nil # key, value pair or nil if not parseable
function M.parse_env_line(line)
    -- Skip comments (lines starting with #) and empty lines
    if line:match("^%s*#") or not line:match("%S") then
        return nil, nil
    end

    local key, value = line:match("^([^=]+)=(.*)$")
    if key and value then
        -- Trim whitespace from key
        key = key:match("^%s*(.-)%s*$")
        -- Remove surrounding quotes if present
        value = value:gsub("^[\"'](.-)[\"\']$", "%1")
        return key, value
    end
    return nil, nil
end

--- Load environment variables from a single file
---@param filepath string The path to the env file
---@return table<string, string> # Table of environment variables
function M.load_env_file(filepath)
    local env_vars = {}
    local file = io.open(filepath, "r")

    if not file then
        return env_vars
    end

    for line in file:lines() do
        local key, value = M.parse_env_line(line)
        if key and value then
            env_vars[key] = value
        end
    end

    file:close()
    return env_vars
end

--- Load environment variables from multiple files
--- Later files override earlier ones
---@param files string[] List of file paths
---@return table<string, string> # Merged environment variables
function M.load_env_files(files)
    local env_vars = {}

    for _, filepath in ipairs(files) do
        local file_vars = M.load_env_file(filepath)
        for key, value in pairs(file_vars) do
            env_vars[key] = value
        end
    end

    return env_vars
end

--- Get merged environment (current env + env files)
---@param env_files string[] List of env file paths
---@return table<string, string> # Merged environment
function M.get_merged_env(env_files)
    local variables = {}

    -- Start with current environment
    for k, v in pairs(vim.fn.environ()) do
        variables[k] = v
    end

    -- Overlay env files
    local file_vars = M.load_env_files(env_files)
    for k, v in pairs(file_vars) do
        variables[k] = v
    end

    return variables
end

--- Prompt user for env files and load them
--- Returns merged environment with current env + file contents
---@return table<string, string> # Merged environment variables
function M.prompt_and_load_env_files()
    local env_vars = {}

    -- Start with current environment
    for k, v in pairs(vim.fn.environ()) do
        env_vars[k] = v
    end

    -- Get list of env files from user
    local files_input = vim.fn.input("Env files (comma-separated, e.g., .env,local.env): ")
    if files_input == "" then
        return env_vars
    end

    local cwd = vim.fn.getcwd()
    for file in files_input:gmatch("[^,]+") do
        local filename = file:match("^%s*(.-)%s*$")  -- trim whitespace
        local filepath = cwd .. "/" .. filename
        local file_vars = M.load_env_file(filepath)

        if next(file_vars) == nil and not vim.fn.filereadable(filepath) then
            vim.notify("Could not open env file: " .. filepath, vim.log.levels.WARN)
        end

        for k, v in pairs(file_vars) do
            env_vars[k] = v
        end
    end

    return env_vars
end

--- Prompt user for additional env vars (KEY=VALUE format)
---@param base_env table<string, string>|nil Base environment to extend
---@return table<string, string> # Extended environment
function M.prompt_additional_env_vars(base_env)
    local variables = base_env or {}

    -- Start with current environment if no base provided
    if not base_env then
        for k, v in pairs(vim.fn.environ()) do
            variables[k] = v
        end
    end

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
end

return M
