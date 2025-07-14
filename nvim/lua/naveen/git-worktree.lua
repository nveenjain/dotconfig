local M = {}

-- Default worktree directory
local default_worktree_dir = "~/repos/eventual-branches"

-- Get the worktree directory for current repository
-- First checks git config, then falls back to default
local function get_worktree_directory()
    local handle = io.popen("git config --get worktree.directory 2>/dev/null")
    if handle then
        local result = handle:read("*a")
        handle:close()
        result = result:gsub("%s+", "")
        if result ~= "" then
            return result
        end
    end
    return vim.fn.expand(default_worktree_dir)
end

-- Create a new worktree
function M.create_worktree()
    local worktree_dir = get_worktree_directory()
    
    -- Get branch name from user
    vim.ui.input({
        prompt = "Enter branch name: ",
    }, function(branch_name)
        if not branch_name or branch_name == "" then
            vim.notify("Branch name cannot be empty", vim.log.levels.ERROR)
            return
        end
        
        -- Sanitize branch name
        branch_name = branch_name:gsub("%s+", "-")
        
        -- Construct full path
        local full_path = worktree_dir .. "/" .. branch_name
        
        -- Ask if user wants to create from existing branch or new branch
        vim.ui.select(
            { "Create new branch", "Use existing branch" },
            { prompt = "Select worktree type: " },
            function(choice)
                if not choice then return end
                
                local cmd
                if choice == "Create new branch" then
                    cmd = string.format("git worktree add -b %s %s", branch_name, vim.fn.shellescape(full_path))
                else
                    cmd = string.format("git worktree add %s %s", vim.fn.shellescape(full_path), branch_name)
                end
                
                -- Execute the command
                local result = vim.fn.system(cmd)
                if vim.v.shell_error ~= 0 then
                    vim.notify("Failed to create worktree: " .. result, vim.log.levels.ERROR)
                else
                    vim.notify("Worktree created at: " .. full_path, vim.log.levels.INFO)
                    
                    -- Ask if user wants to switch to the new worktree
                    vim.ui.select(
                        { "Yes", "No" },
                        { prompt = "Switch to new worktree? " },
                        function(switch_choice)
                            if switch_choice == "Yes" then
                                -- Use tcd (tab-local cd) instead of cd to avoid issues
                vim.cmd("tcd " .. vim.fn.fnameescape(full_path))
                                vim.notify("Switched to worktree: " .. branch_name, vim.log.levels.INFO)
                            end
                        end
                    )
                end
            end
        )
    end)
end

-- List and remove worktrees
function M.remove_worktree()
    -- Get list of worktrees
    local worktrees_output = vim.fn.system("git worktree list")
    if vim.v.shell_error ~= 0 then
        vim.notify("Failed to list worktrees", vim.log.levels.ERROR)
        return
    end
    
    -- Parse worktrees
    local worktrees = {}
    local current_dir = vim.fn.getcwd()
    
    for line in worktrees_output:gmatch("[^\r\n]+") do
        -- Parse git worktree list output format: /path/to/worktree SHA [branch]
        local path = line:match("^([^%s]+)")
        local branch = line:match("%[(.-)%]")
        
        if path and branch then
            -- Skip bare repositories
            if not line:match("%(bare%)") then
                local display = branch .. " (" .. path .. ")"
                if path == current_dir then
                    display = display .. " [CURRENT]"
                end
                table.insert(worktrees, {
                    display = display,
                    path = path,
                    branch = branch,
                    is_current = path == current_dir
                })
            end
        end
    end
    
    if #worktrees == 0 then
        vim.notify("No worktrees found", vim.log.levels.INFO)
        return
    end
    
    -- Show selection menu
    local items = {}
    for _, wt in ipairs(worktrees) do
        table.insert(items, wt.display)
    end
    
    vim.ui.select(items, {
        prompt = "Select worktree to remove: ",
    }, function(choice, idx)
        if not choice then return end
        
        local selected = worktrees[idx]
        if selected.is_current then
            vim.notify("Cannot remove current worktree! Switch to a different worktree first.", vim.log.levels.ERROR)
            return
        end
        
        -- Confirm removal
        vim.ui.select(
            { "Yes", "No" },
            { prompt = "Remove worktree '" .. selected.branch .. "'? This will delete the directory!" },
            function(confirm)
                if confirm == "Yes" then
                    local cmd = "git worktree remove " .. vim.fn.shellescape(selected.path)
                    local result = vim.fn.system(cmd)
                    if vim.v.shell_error ~= 0 then
                        -- Try with --force if regular removal fails
                        vim.ui.select(
                            { "Force remove", "Cancel" },
                            { prompt = "Regular removal failed. Force remove? " },
                            function(force_choice)
                                if force_choice == "Force remove" then
                                    cmd = "git worktree remove --force " .. vim.fn.shellescape(selected.path)
                                    result = vim.fn.system(cmd)
                                    if vim.v.shell_error ~= 0 then
                                        vim.notify("Failed to remove worktree: " .. result, vim.log.levels.ERROR)
                                    else
                                        vim.notify("Worktree removed: " .. selected.branch, vim.log.levels.INFO)
                                    end
                                end
                            end
                        )
                    else
                        vim.notify("Worktree removed: " .. selected.branch, vim.log.levels.INFO)
                    end
                end
            end
        )
    end)
end

-- Set worktree directory for current repository
function M.set_worktree_directory()
    local current_dir = get_worktree_directory()
    vim.ui.input({
        prompt = "Set worktree directory for this repository: ",
        default = current_dir,
    }, function(new_dir)
        if not new_dir or new_dir == "" then return end
        
        -- Expand the path
        new_dir = vim.fn.expand(new_dir)
        
        -- Set in git config
        local cmd = "git config worktree.directory " .. vim.fn.shellescape(new_dir)
        local result = vim.fn.system(cmd)
        if vim.v.shell_error ~= 0 then
            vim.notify("Failed to set worktree directory: " .. result, vim.log.levels.ERROR)
        else
            vim.notify("Worktree directory set to: " .. new_dir, vim.log.levels.INFO)
        end
    end)
end

-- List all worktrees
function M.list_worktrees()
    local worktrees_output = vim.fn.system("git worktree list")
    if vim.v.shell_error ~= 0 then
        vim.notify("Failed to list worktrees", vim.log.levels.ERROR)
        return
    end
    
    local worktrees = {}
    local current_dir = vim.fn.getcwd()
    
    for line in worktrees_output:gmatch("[^\r\n]+") do
        -- Parse git worktree list output format: /path/to/worktree SHA [branch]
        local path = line:match("^([^%s]+)")
        local branch = line:match("%[(.-)%]")
        
        if path and branch then
            table.insert(worktrees, {
                path = path,
                branch = branch,
                is_current = path == current_dir
            })
        end
    end
    
    if #worktrees == 0 then
        vim.notify("No worktrees found", vim.log.levels.INFO)
        return
    end
    
    -- Display worktrees
    local items = {}
    for _, wt in ipairs(worktrees) do
        local display = wt.branch .. " - " .. wt.path
        if wt.is_current then
            display = "→ " .. display .. " (current)"
        else
            display = "  " .. display
        end
        table.insert(items, display)
    end
    
    vim.ui.select(items, {
        prompt = "Worktrees (select to switch): ",
    }, function(choice, idx)
        if not choice then return end
        
        local selected = worktrees[idx]
        if not selected.is_current then
            -- Ensure the path exists before changing directory
            if vim.fn.isdirectory(selected.path) == 1 then
                vim.cmd("tcd " .. vim.fn.fnameescape(selected.path))
                vim.notify("Switched to worktree: " .. selected.branch, vim.log.levels.INFO)
            else
                vim.notify("Directory not found: " .. selected.path, vim.log.levels.ERROR)
                -- Show debug info
                vim.notify("Debug - Path tried: '" .. selected.path .. "'", vim.log.levels.WARN)
            end
        end
    end)
end

return M