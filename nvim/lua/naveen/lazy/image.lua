---@file image.lua
---@description Inline image rendering via Ghostty's kitty graphics protocol.
---  Renders PNG/JPG/etc. in image buffers and inside markdown. PDFs are NOT
---  native — use :Pdf [page] to rasterize a page (pdftoppm) and view it inline,
---  which fits the scanned check/statement-deposit QA workflow.
---  Requires ImageMagick (magick CLI). Works through tmux (allow-passthrough on).

return {
    "3rd/image.nvim",
    event = "VeryLazy",  -- ready to hijack image files / render markdown images
    cmd = { "Pdf" },
    opts = {
        backend = "kitty",
        processor = "magick_cli",  -- ImageMagick CLI; no luarock needed
        integrations = {
            markdown = {
                enabled = true,
                only_render_image_at_cursor = false,
                filetypes = { "markdown", "vimwiki" },
            },
        },
        max_height_window_percentage = 50,
        window_overlap_clear_enabled = true,        -- hide behind floats/splits
        editor_only_render_when_focused = false,
        tmux_show_only_in_active_window = true,
        hijack_file_patterns = { "*.png", "*.jpg", "*.jpeg", "*.gif", "*.webp", "*.avif" },
    },
    config = function(_, opts)
        require("image").setup(opts)

        -- :Pdf [page] — rasterize a page of the current (or prompted) .pdf to PNG
        -- and open it inline in a vsplit. Defaults to page 1. Uses pdftoppm (poppler).
        vim.api.nvim_create_user_command("Pdf", function(o)
            local pdf = vim.fn.expand("%:p")
            if not pdf:match("%.pdf$") then
                pdf = vim.fn.input("PDF path: ", "", "file")
            end
            if pdf == "" or vim.fn.filereadable(pdf) == 0 then
                vim.notify("Pdf: no readable PDF", vim.log.levels.ERROR)
                return
            end
            local page = tonumber(o.args) or 1
            local out = vim.fn.tempname()
            local res = vim.system({
                "pdftoppm", "-png", "-r", "150",
                "-f", tostring(page), "-l", tostring(page),
                "-singlefile", pdf, out,
            }, { text = true }):wait()
            if res.code ~= 0 then
                vim.notify("Pdf: pdftoppm failed: " .. (res.stderr or ""), vim.log.levels.ERROR)
                return
            end
            vim.cmd("vsplit " .. vim.fn.fnameescape(out .. ".png"))
        end, { nargs = "?", desc = "Render a PDF page inline (pdftoppm + image.nvim)" })
    end,
}
