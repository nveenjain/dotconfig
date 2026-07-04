---@file go.lua
---@description Go power-tools (struct tags, test gen, if-err, fill-struct).
---  Scoped to COMMANDS ONLY — gopls (lsp.lua), formatting (conform.lua) and
---  debugging (dap/) stay owned by their existing modules to avoid conflicts.
---  Backing binaries: gomodifytags, gotests, iferr, fillstruct (run :GoInstallDeps
---  once, or install via `go install` — see commit notes).

return {
    "ray-x/go.nvim",
    dependencies = { "ray-x/guihua.lua" },
    ft = { "go", "gomod", "gowork", "gotmpl" },
    cmd = { "GoAddTag", "GoRmTag", "GoTests", "GoTestFunc", "GoIfErr", "GoFillStruct", "GoImpl", "GoInstallDeps" },
    opts = {
        -- Hand off everything we already own elsewhere.
        lsp_cfg = false,                     -- gopls configured in lsp.lua
        lsp_keymaps = false,
        lsp_inlay_hints = { enable = false },
        lsp_document_formatting = false,     -- formatting via conform.lua
        dap_debug = false,                   -- debugging via dap/
        dap_debug_keymap = false,
        luasnip = false,
        trouble = true,                      -- reuse existing trouble.nvim
        gofmt = "gofumpt",                   -- only used by go.nvim's own cmds
        tag_transform = "camelcase",         -- :GoAddTag json => camelCase keys
    },
    keys = {
        { "<leader>Gj", "<cmd>GoAddTag json<CR>",   desc = "Go: add json tags",   ft = "go" },
        { "<leader>Gd", "<cmd>GoAddTag db<CR>",     desc = "Go: add db tags",     ft = "go" },
        { "<leader>Gr", "<cmd>GoRmTag<CR>",         desc = "Go: remove tags",     ft = "go" },
        { "<leader>Ge", "<cmd>GoIfErr<CR>",         desc = "Go: insert if err",   ft = "go" },
        { "<leader>Gf", "<cmd>GoFillStruct<CR>",    desc = "Go: fill struct",     ft = "go" },
        { "<leader>Gt", "<cmd>GoTestFunc<CR>",      desc = "Go: test func",       ft = "go" },
        { "<leader>GT", "<cmd>GoTests<CR>",         desc = "Go: gen tests",       ft = "go" },
        { "<leader>Gi", "<cmd>GoImpl<CR>",          desc = "Go: impl interface",  ft = "go" },
    },
    config = function(_, opts)
        require("go").setup(opts)
    end,
}
