-- Fix for gopls file watching ENOENT errors
local M = {}

-- Override the default file watcher to handle missing directories
M.setup = function()
    -- Wrap the internal _watch.watch function to handle ENOENT errors
    local ok, watch = pcall(require, "vim._watch")
    if not ok then
        return
    end
    
    local original_watch = watch.watch
    if original_watch then
        watch.watch = function(path, opts, callback)
            -- Check if the path exists before watching
            local stat = vim.loop.fs_stat(path)
            if not stat then
                -- Path doesn't exist, return a no-op cancel function
                return function() end
            end
            
            -- Wrap the callback to handle errors
            local wrapped_callback = function(...)
                local ok, err = pcall(callback, ...)
                if not ok and err:match("ENOENT") then
                    -- Silently ignore ENOENT errors
                    return
                elseif not ok then
                    -- Re-throw other errors
                    error(err)
                end
            end
            
            -- Path exists, use the original watcher with wrapped callback
            return original_watch(path, opts, wrapped_callback)
        end
    end
    
    -- Also wrap watchdirs if it exists
    local original_watchdirs = watch.watchdirs
    if original_watchdirs then
        watch.watchdirs = function(path, opts, callback)
            -- Check if the path exists before watching
            local stat = vim.loop.fs_stat(path)
            if not stat then
                -- Path doesn't exist, return a no-op cancel function
                return function() end
            end
            -- Path exists, use the original watcher
            return original_watchdirs(path, opts, callback)
        end
    end
end

return M