-- {{{ Setup mini.nvim's dep manager

-- Clone 'mini.nvim' manually in a way that it gets managed by 'mini.deps'
local path_package = vim.fn.stdpath('data') .. '/site/'
local mini_path = path_package .. 'pack/deps/start/mini.nvim'
if not vim.loop.fs_stat(mini_path) then
  vim.cmd('echo "Installing `mini.nvim`" | redraw')
  local clone_cmd = {
    'git', 'clone', '--filter=blob:none',
    'https://github.com/echasnovski/mini.nvim', mini_path
  }
  vim.fn.system(clone_cmd)
  vim.cmd('packadd mini.nvim | helptags ALL')
  vim.cmd('echo "Installed `mini.nvim`" | redraw')
end

-- Set up 'mini.deps' (customize to your liking)
require('mini.deps').setup({
    path = {
        package = path_package,
    },
})
-- }}}

-- {{{ helper functions
-- Use 'mini.deps'. `now()` and `later()` are helpers for a safe two-stage
-- startup and are optional.
local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later

local function colorscheme_exists(colorscheme)
    local success, _ = pcall(vim.cmd, 'colorscheme ' .. colorscheme)
    return success
end
-- }}}

-- {{{ vim options
now(function()
    local opts = {
        -- tabs look like 4 spaces {
        expandtab = true,
        tabstop = 4,
        shiftwidth = 4,
        softtabstop = 4,
        -- }
        cursorline = true, -- show active line
        number = true, -- show line numbers
        mouse = 'c', -- disable mouse
        laststatus = 2, -- always show the status line
        autoindent = true, -- turn on autoindent
        smarttab = true, -- turn on smart tabs
        incsearch = true, -- turn on incremental search
        ruler = true, -- show ruler on page
        lazyredraw = true, -- make large file bearable
        regexpengine = 1, -- make searching large files bearable
        foldmethod = 'marker', -- fold by using the parenthesis tags
    }

    for opt, val in pairs(opts) do
            vim.o[opt] = val
    end
end)
-- }}} vim options

-- {{{ color themes
now(function()
    -- {{{ gruvbox
    add({
        source = 'ellisonleao/gruvbox.nvim',
    })

    require('gruvbox').setup({
        contrast = 'hard'
    })
    vim.api.nvim_create_user_command(
        'GruvboxDark',
        function(opts)
            vim.o.background = 'dark'
            vim.cmd.colorscheme('gruvbox')
        end,
        {}
    )

    vim.api.nvim_create_user_command(
        'GruvboxLight',
        function(opts)
            vim.o.background = 'light'
            vim.cmd.colorscheme('gruvbox')
        end,
        {}
    )
    -- }}}

    -- {{{ dracula
    add({
        source = 'ssh://git@git.0xdad.com/tblyler/dracula-pro.vim.git',
    })
    vim.api.nvim_create_user_command(
        'DraculaDark',
        function(opts)
            vim.o.background = 'dark'
            vim.cmd.colorscheme('dracula_pro_morbius')
        end,
        {}
    )

    vim.api.nvim_create_user_command(
        'DraculaLight',
        function(opts)
            vim.o.background = 'light'
            vim.cmd.colorscheme('alucard')
        end,
        {}
    )
    -- }}}

    vim.o.background = 'dark'
    vim.o.termguicolors = true -- enable 24 bit colors

    local color_priorities = {
        'dracula_pro_morbius',
        'gruvbox',
        'default',
    }
    for _, colorscheme in pairs(color_priorities) do
        if colorscheme_exists(colorscheme) then
            vim.cmd.colorscheme(colorscheme)
            break
        end
    end
end)
-- }}}

-- {{{ mini.nvim plugins
-- {{{ mini.nvim notify
now(function()
    require('mini.notify').setup()
    vim.notify = require('mini.notify').make_notify()
end)
-- }}}

-- {{{ eager
now(function()
    local setups = {
        icons = {},
        tabline = {},
        statusline = {},
    }

    for plugin, setup in pairs(setups) do
        require('mini.' .. plugin).setup(setup)
    end
end)
-- }}}

-- {{{ lazy
later(function()
    local setups = {
        bufremove = {},
        comment = {},
        completion = {},
        cursorword = {},
        jump = {},
        jump2d = {},
        pairs = {},
        pick = {},
        surround = {},
        trailspace = {},
    }

    for plugin, setup in pairs(setups) do
        require('mini.' .. plugin).setup(setup)
    end

    -- {{{ jump key mapping
    local function jumpbefore()
        MiniJump2d.start({
            allowed_lines = {
                cursor_after = false
            }
        })
    end

    local function jumpafter()
        MiniJump2d.start({
            allowed_lines = {
                cursor_before = false
            }
        })
    end

    vim.keymap.set('n', '<leader><leader>k', jumpbefore, { noremap = true, silent = true })
    vim.keymap.set('n', '<leader><leader>j', jumpafter, { noremap = true, silent = true })
    -- }}}

    -- {{{ buffer delete command
    vim.api.nvim_create_user_command(
       'Bd',
        function(opts)
            MiniBufremove.delete()
        end,
        {}
    )
    -- }}}

    -- {{{ whitespace fix command
    vim.api.nvim_create_user_command(
	'FixWhitespace',
        function(opts)
            MiniTrailspace.trim()
        end,
        {}
    )
    -- }}}

    -- {{{ fzf-like control-P binding
    vim.keymap.set('n', '<c-P>', MiniPick.builtin.files, {})
    -- }}}

end)
-- }}}

-- }}}

-- {{{ Git
later(function()
    add({
        source = 'lewis6991/gitsigns.nvim',
    })

    require('gitsigns').setup({
        current_line_blame = true,
        current_line_blame_opts = {
            virt_text = true,
            delay = 0,
        }
    })

    add({
        source = 'tpope/vim-fugitive',
    })
end)
-- }}}

-- {{{ which key
later(function()
    add({
        source = 'folke/which-key.nvim'
    })
end)
-- }}}which key {

-- {{{ surround -- old keybindings diehard, maybe migrate to mini.nvim surround some day
now(function()
    add({
        source = 'tpope/vim-surround'
    })
end)
-- }}}

-- {{{ LSP jazz
later(function()
    add({
        -- needed for LSP configuration setup using the builtin LSP implementation
        source = 'neovim/nvim-lspconfig',
    })
    add({
        -- super convenient tool for installing/updating LSPs, use :Mason* commands
        source = 'williamboman/mason.nvim',
    })
    add({
        -- bridges mason & lspconfig automatically
        source = 'williamboman/mason-lspconfig.nvim',
    })
    add({
        -- adds some nice :Lsp* commands
        source = 'nanotee/nvim-lsp-basics',
    })
    add({
        -- provides nice "diagnostics" output
        source = 'folke/trouble.nvim'
    })

    -- only perform these mappings if an LSP is attached
    local on_attach = function(client, buffnr)
        local lsp_key = function(lhs, rhs, desc)
            vim.keymap.set('n', lhs, rhs, { silent = true, buffer = buffnr, desc = desc })
        end

        lsp_key('<leader>lr', vim.lsp.buf.rename, 'Rename symbol')
        lsp_key('<leader>la', vim.lsp.buf.code_action, 'Code action')
        lsp_key('<leader>ld', vim.lsp.buf.type_definition, 'Type definition')

        lsp_key('gd', vim.lsp.buf.definition, 'Goto Definition')
        lsp_key('gr', vim.lsp.buf.references, 'Goto References')
        lsp_key('gI', vim.lsp.buf.implementation, 'Goto Implementation')
        lsp_key('gD', vim.lsp.buf.declaration, 'Goto Declaration')

        -- setup :Lsp* commands
        local basics = require('lsp_basics')
        basics.make_lsp_commands(client, buffnr)
        basics.make_lsp_mappings(client, buffnr)
    end

    require('mason').setup()
    require('mason-lspconfig').setup({
        -- automatically register LSPs as they're installed with their defaults
        -- read documentation for one-off configurations if an LSP needs/wants non-default configuration
        handlers = {
            function (server_name)
                require('lspconfig')[server_name].setup({
                    on_attach = on_attach
                })
            end
        }
    })

    -- make sure LSPs are autostarted if already installed at neovim start
    for _, server_name in pairs(require('mason-lspconfig').get_installed_servers()) do
        require('lspconfig')[server_name].setup({
            on_attach = on_attach
        })
    end


    require('trouble').setup()
    vim.keymap.set('n', '<leader>xx', '<cmd>Trouble diagnostics toggle<cr>', { noremap = true, silent = true })
    vim.keymap.set('n', '<leader>xd', '<cmd>Trouble diagnostics toggle filter.buf=0<cr>', { noremap = true, silent = true })
end)
-- }}}

-- {{{ treesitter
later(function()
  add({
    source = 'nvim-treesitter/nvim-treesitter',
    -- Use 'master' while monitoring updates in 'main'
    checkout = 'master',
    monitor = 'main',
    -- Perform action after every checkout
    hooks = { post_checkout = function() vim.cmd('TSUpdate') end },
  })

  -- Possible to immediately execute code which depends on the added plugin
  require('nvim-treesitter.configs').setup({
    ensure_installed = {
        'bash',
        'c',
        'c_sharp',
        'comment',
        'cpp',
        'cpp',
        'css',
        'diff',
        'dockerfile',
        'earthfile',
        'fish',
        'git_config',
        'git_rebase',
        'gitattributes',
        'gitcommit',
        'gitignore',
        'go',
        'gomod',
        'gosum',
        'gpg',
        'html',
        'http',
        'ini',
        'java',
        'javascript',
        'jq',
        'jsdoc',
        'json',
        'kotlin',
        'lua',
        'luadoc',
        'make',
        'markdown',
        'markdown_inline',
        'nginx',
        'php',
        'proto',
        'python',
        'regex',
        'robots',
        'rust',
        'scss',
        'sql',
        'ssh_config',
        'terraform',
        'tmux',
        'toml',
        'tsv',
        'tsx',
        'typescript',
        'vimdoc',
        'xml',
        'yaml',
    },
    sync_install = false,
    auto_install = true,
    highlight = { enable = true },
    indent = { enable = true },
    incremental_selection = { enable = true },
  })

  -- show indentations how I like them, each layer of indentation etc
  add({
      source = 'lukas-reineke/indent-blankline.nvim'
  })

  require('ibl').setup({
      indent = {
          char = '▏',
          highlight = { 'Label' },
      },
      scope = {
          highlight = { 'Function' },
      }
  })
end)
-- }}}
