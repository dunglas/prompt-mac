-- Minimalist, plugin-free Neovim config — just the options stock nvim leaves off.
-- Symlinked to ~/.config/nvim/init.lua by install.sh.

-- UI
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.scrolloff = 4

-- Editing
vim.opt.clipboard = 'unnamedplus' -- system clipboard
vim.opt.tabstop = 2

-- Search
vim.opt.ignorecase = true
vim.opt.smartcase = true          -- ...unless the query has capitals

-- Files
vim.opt.undofile = true           -- persistent undo
