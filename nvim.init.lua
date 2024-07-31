-- Own configs
vim.cmd("set number")
vim.cmd("set expandtab")
vim.cmd("set tabstop=4")
vim.cmd("set softtabstop=4")
vim.cmd("set shiftwidth=4")


-- Bootstrap lazy.vim
local lazypath = "/home/ataf/.config/nvim/lazy/lazy.nvim"

if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

local plugins = {
    { "catppuccin/nvim", name = "catppuccin", priority = 1000 },
    { "navarasu/onedark.nvim", name = "onedark" },
    { "nvim-telescope/telescope.nvim", tag = '0.1.8', dependencies = {"nvim-lua/plenary.nvim"} },
    { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
    { "nvim-neo-tree/neo-tree.nvim", branch = "v3.x",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-tree/nvim-web-devicons",
            "MunifTanjim/nui.nvim",
        }
    },
}
local opts = {}
require("lazy").setup(plugins, opts)

-- set telescope
local builtin = require("telescope.builtin")
vim.keymap.set("n", "<C-p>", builtin.find_files, {})

-- set theme
-- require("catppuccin").setup()
require("onedark").setup({ style = "darker" })
-- vim.cmd.colorscheme "catppuccin"
vim.cmd.colorscheme "onedark"

-- set tree-sitter
local config = require("nvim-treesitter.configs")
config.setup({
    ensure_installed = {"c", "cpp", "python", "java", "javascript", "lua", "json", "toml", "yaml"},
    sync_install = false,
    highlight = { enable = true },
    indent = { enable = true },
})

-- set neotree
vim.keymap.set("n", "<C-n>", ":Neotree filesystem reveal left <CR>", {})
