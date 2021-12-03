local fn = vim.fn

local install_path = fn.stdpath('data') .. '/site/pack/paqs/start/paq-nvim'

if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({'git', 'clone', '--depth=1', 'https://github.com/savq/paq-nvim.git', install_path})
end

require "paq" {
    "savq/pag-nvim"; -- let Paq manage itself

    "morhetz/gruvbox"; -- gruvbox theme

    "beauwilliams/statusline.lua"; -- status & tab line

    "lewis6991/gitsigns.nvim"; -- git gutter
    "nvim-lua/plenary.nvim"; -- dependency of lewis6991/gitsigns.nvim, nvim-telescope/telescope.nvim

    "nvim-telescope/telescope.nvim"; -- fzf searching

    "phaazon/hop.nvim"; -- easymotion navigation

    "echasnovski/mini.nvim"; -- bunch of good small plugins: whitespace, buffer layout, commenting, surround, tabline, etc

    {"nvim-treesitter/nvim-treesitter", run=TSUpdate}; -- nice and quick syntax tree

    "lukas-reineke/indent-blankline.nvim"; -- pretty visualization of line indents

    "kosayoda/nvim-lightbulb"; -- shows a light bulb like vs code for code actions
    "nvim-lua/lsp-status.nvim"; -- nice statusline components for LSP servers

    "rhysd/vim-grammarous"; -- grammar checking

    -- LSP Server
    "neovim/nvim-lspconfig";
    "williamboman/nvim-lsp-installer";
    "jose-elias-alvarez/null-ls.nvim";

    -- autocomplete with nvim-cmp
    "hrsh7th/cmp-nvim-lsp";
    "hrsh7th/cmp-buffer";
    "hrsh7th/cmp-path";
    "hrsh7th/cmp-cmdline";
    "hrsh7th/nvim-cmp";
    "L3MON4D3/LuaSnip";
    "saadparwaiz1/cmp_luasnip";
}

require("plugins.config.cmp")
require("plugins.config.gitsigns")
require("plugins.config.hop")
require("plugins.config.indentblankline")
require("plugins.config.mini")
require("plugins.config.treesitter")
require("plugins.config.lspinstall")
