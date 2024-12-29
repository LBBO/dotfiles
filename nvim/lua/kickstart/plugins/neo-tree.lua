-- Neo-tree is a Neovim plugin to browse the file system
-- https://github.com/nvim-neo-tree/neo-tree.nvim

return {
    "nvim-neo-tree/neo-tree.nvim",
    version = "*",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
        "MunifTanjim/nui.nvim",
        "3rd/image.nvim",
    },
    cmd = "Neotree",
    keys = {
        { "\\", ":Neotree float reveal<CR>", desc = "NeoTree reveal" },
    },
    opts = {
        filesystem = {
            restore_state = false,
            filtered_items = {
                visible = true,
                hide_dotfiles = false,
                hide_gitignored = false,
            },
            window = {
                auto_close = true,
                -- This will close all open directories when Neotree is closed
                close_if_last_window = true,
                mappings = {
                    -- ["<CR>"] = function(state)
                    --     local node = state.tree:get_node()
                    --     state.commands["open"](state)
                    --     require("neo-tree.window").close() -- close NeoTree after opening a file
                    -- end,
                    ["\\"] = "close_window",
                },
            },
        },
        event_handlers = {
            {
                event = "neo_tree_buffer_enter",
                handler = function(arg)
                    -- Collapse all directories except the current file's path
                    vim.cmd("Neotree reveal")
                end
            }
        }
    },
}
