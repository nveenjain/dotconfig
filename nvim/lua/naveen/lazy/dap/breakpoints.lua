---@file dap/breakpoints.lua
---@description Breakpoint persistence across sessions
---@requires naveen.core.git

local M = {}

local git = require("naveen.core.git")
local constants = require("naveen.core.constants")

-- Path to store breakpoint files
local breakpoints_path = vim.fn.stdpath("data") .. "/dap_breakpoints/"

--- Get the breakpoints file path for the current project
---@return string # Path to the breakpoints JSON file
local function get_breakpoints_file()
    local project_dir = git.get_project_root()
    -- Create a safe filename from the path
    local safe_name = project_dir:gsub("[/\\:]", "_"):gsub("^_+", "")
    return breakpoints_path .. safe_name .. ".json"
end

--- Save all current breakpoints to file
function M.save()
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

--- Load breakpoints from file
function M.load()
    local bp_file = get_breakpoints_file()
    local file = io.open(bp_file, "r")
    if not file then
        return
    end

    local content = file:read("*a")
    file:close()

    if content == "" then
        return
    end

    local ok, breakpoints_data = pcall(vim.fn.json_decode, content)
    if not ok or not breakpoints_data then
        return
    end

    for bufname, buf_bps in pairs(breakpoints_data) do
        for _, bp in ipairs(buf_bps) do
            local bufnr = vim.fn.bufadd(bufname)
            if bufnr > 0 then
                require("dap.breakpoints").set(bp, bufnr, bp.line)
            end
        end
    end
end

--- Clear all breakpoints and save
function M.clear_all()
    require("dap.breakpoints").clear()
    M.save()
    vim.notify("All breakpoints cleared", vim.log.levels.INFO)
end

--- Set up breakpoint persistence autocommands
---@param dap table The DAP module
function M.setup(dap)
    -- Load breakpoints on startup (deferred to ensure DAP is ready)
    vim.defer_fn(M.load, constants.DAP_LOAD_DELAY)

    -- Save breakpoints when they change
    vim.api.nvim_create_autocmd("User", {
        pattern = "DapBreakpointChanged",
        callback = M.save,
        desc = "Save DAP breakpoints on change",
    })

    -- Auto-close DAP UI on exit and save breakpoints
    vim.api.nvim_create_autocmd("ExitPre", {
        callback = function()
            M.save()
            pcall(function()
                dap.terminate()
                require("dapui").close()
            end)
        end,
        desc = "Save breakpoints and close DAP UI before exit",
    })
end

return M
