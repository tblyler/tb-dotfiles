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
require('mini.deps').setup({ path = { package = path_package } })

-- Use 'mini.deps'. `now()` and `later()` are helpers for a safe two-stage
-- startup and are optional.
local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later

-- vim options
now(function()
    local opts = {
        termguicolors = true, -- enable 24 bit colors
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
        background = 'dark' -- use dark theme
    }

    for opt, val in pairs(opts) do
            vim.o[opt] = val
    end
end)

-- color themes
now(function()
    -- gruvbox {
    add({
        source = 'ellisonleao/gruvbox.nvim',
    })

    require('gruvbox').setup({
        contrast = 'hard'
    })
    -- } gruvbox

    -- dracula {
    add({
        source = 'maxmx03/dracula.nvim',
        checkout = '2f396b6ba988ad4b3961c2e40d1b9ae436b8c26c',
        depends = {
            'ssh://git@git.0xdad.com/tblyler/dracula-pro.nvim.git'
        }
    })

    local dracula = require('dracula')
    local draculapro = require('draculapro')

    draculapro.setup({
        theme = 'morbius'
    })

    dracula.setup({
        dracula_pro = draculapro,
        colors = draculapro.colors
    })

    -- } dracula

    vim.cmd.colorscheme('gruvbox')
end)

-- mini.nvim plugins {
-- safely execute immediately
now(function()
    local animate = require('mini.animate')
    local timing = animate.gen_timing.linear({ duration = duration, unit = 'total' })
    animate.setup({
        cursor = {
            timing = timing
        },
        scroll = {
            timing = timing
        },
        resize = {
            timing = timing
        },
        open = {
            timing = timing
        },
        close = {
            timing = timing
        }
    })
end)

now(function()
    require('mini.notify').setup()
    vim.notify = require('mini.notify').make_notify()
end)

now(function()
    local setups = {
        bufremove = {},
        comment = {}, -- maybe later?
        completion = {},
        cursorword = {},
        icons = {}, -- vet me
        jump = {},
        jump2d = {},
        pairs = {},
        pick = {}, -- vet and maybe later?
        tabline = {},
        statusline = {},
        surround = {}, -- maybe later?
        trailspace = {},
    }

    for plugin, setup in pairs(setups) do
        require('mini.' .. plugin).setup(setup)
    end

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

    vim.api.nvim_create_user_command(
       'Bd',
        function(opts)
            MiniBufremove.delete()
        end,
        {}
    )

    vim.api.nvim_create_user_command(
	'FixWhitespace',
        function(opts)
            MiniTrailspace.trim()
        end,
        {}
    )
end)

later(function()
    local setups = {
    }

    for plugin, setup in pairs(setups) do
        require('mini.' .. plugin).setup(setup)
    end
end)

-- } mini.nvim plugins

-- non mini.nvim plugins {
-- Git {
now(function()
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
        source = "tpope/vim-fugitive",
    })
end)
-- } Git

-- fzf {
later(function()
    add({
        source = 'ibhagwan/fzf-lua'
    })

    require("fzf-lua").setup({})

    vim.keymap.set("n", "<c-P>", require('fzf-lua').files, { desc = "Fzf Files" })

end)
-- }

-- which key {
later(function()
    add({
        source = 'folke/which-key.nvim'
    })
end)
-- }

-- legacy stuff {
now(function()
    add({
        source = 'tpope/vim-surround'
    })
end)
-- } surround

-- LSP {
later(function()
    add({
        source = 'neovim/nvim-lspconfig',
    })
    add({
        source = 'williamboman/mason.nvim',
    })
    add({
        source = 'williamboman/mason-lspconfig.nvim'
    })

    local on_attach = function(client, buffnr)
        local lsp_key = function(lhs, rhs, desc)
            vim.keymap.set('n', lhs, rhs, { silent = true, buffer = buffnr, desc = desc })
        end

        lsp_key("<leader>lr", vim.lsp.buf.rename, "Rename symbol")
        lsp_key("<leader>la", vim.lsp.buf.code_action, "Code action")
        lsp_key("<leader>ld", vim.lsp.buf.type_definition, "Type definition")

        lsp_key("gd", vim.lsp.buf.definition, "Goto Definition")
        lsp_key("gr", vim.lsp.buf.references, "Goto References")
        lsp_key("gI", vim.lsp.buf.implementation, "Goto Implementation")
        lsp_key("gD", vim.lsp.buf.declaration, "Goto Declaration")
    end

    require("mason").setup()
    require("mason-lspconfig").setup({
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

    add({
        source = 'folke/trouble.nvim'
    })

    require('trouble').setup()
    vim.keymap.set('n', '<leader>xx', '<cmd>Trouble diagnostics toggle<cr>', { noremap = true, silent = true })
    vim.keymap.set('n', '<leader>xd', '<cmd>Trouble diagnostics toggle filter.buf=0<cr>', { noremap = true, silent = true })
end)
-- } LSP

-- treesitter {
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

  -- show indentations
  add({
      source = 'lukas-reineke/indent-blankline.nvim'
  })

  require("ibl").setup({
      indent = {
          char = "▏",
          highlight = { "Label" },
      },
      scope = {
          highlight = { "Function" },
      }
  })
end)
-- } treesitter
-- } non mini.nvim plugins
