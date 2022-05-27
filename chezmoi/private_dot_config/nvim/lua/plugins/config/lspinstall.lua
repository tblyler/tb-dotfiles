require("nvim-lsp-installer").setup({})
local lsp_installer_servers = require'nvim-lsp-installer.servers'
local cmp_lsp = require('cmp_nvim_lsp')
local null_ls = require("null-ls")
local lspconfig = require("lspconfig")

null_ls.setup({
    sources = {
        null_ls.builtins.diagnostics.vale,
    },
})

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
    local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
    local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

    -- Enable completion triggered by <c-x><c-o>
    buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

    -- Mappings.
    local opts = { noremap=true, silent=true }

    -- See `:help vim.lsp.*` for documentation on any of the below functions
    buf_set_keymap('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
    --buf_set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
    buf_set_keymap('n', 'gd', "<cmd>lua require('telescope.builtin').lsp_definitions()<CR>", opts)
    buf_set_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
    --buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
    buf_set_keymap('n', 'gi', "<cmd>lua require('telescope.builtin').lsp_implementations()<CR>", opts)
    buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
    buf_set_keymap('n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
    buf_set_keymap('n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
    buf_set_keymap('n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
    --buf_set_keymap('n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
    buf_set_keymap('n', '<space>D', "<cmd>lua require('telescope.builtin').lsp_type_definitions()<CR>", opts)
    buf_set_keymap('n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
    --buf_set_keymap('n', '<space>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
    buf_set_keymap('n', '<space>ca', "<cmd>lua require('telescope.builtin').lsp_code_actions()<CR>", opts)
    --buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
    buf_set_keymap('', 'gr', "<cmd>lua require('telescope.builtin').lsp_references()<CR>", opts)
    buf_set_keymap('n', '<space>e', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)
    buf_set_keymap('n', '[d', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
    buf_set_keymap('n', ']d', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
    buf_set_keymap('n', '<space>q', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)
    buf_set_keymap('n', '<space>f', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)

    require("lsp-status").on_attach(client) -- required for LSP status to function
    local basics = require("lsp_basics") -- adds nice human accessible LSP commands
    basics.make_lsp_commands(client, bufnr)
    basics.make_lsp_mappings(client, bufnr)

    local sources = {
        null_ls.builtins.formatting.gofumpt,
        null_ls.builtins.formatting.goimports,
        null_ls.builtins.formatting.isort,
        null_ls.builtins.formatting.black.with({
            extra_args = { "-l 120" }
        }),
        null_ls.builtins.diagnostics.flake8.with({
            extra_args =  { "--max-line-length=120" }
        }),
        null_ls.builtins.formatting.rubocop,
        null_ls.builtins.formatting.rustfmt,
        null_ls.builtins.diagnostics.shellcheck,
        null_ls.builtins.formatting.stylua,
    }

    null_ls.setup({sources = sources })
end

local lspServers = {
    bashls = {},
    cssls = {},
    dockerls = {},
    eslint = {},
    gopls = {
        cmd = {"gopls", "serve"},
        settings = {
          gopls = {
            analyses = {
              unusedparams = true,
            },
            staticcheck = true,
          },
        },
    },
    html = {},
    jsonls = {},
    sumneko_lua = {},
    jedi_language_server = {},
    rust_analyzer = {},
    terraformls = {},
    tsserver = {},
    lemminx = {},
    yamlls = {}
}

for lspServer, opts in pairs(lspServers) do
    local server_available, requested_server = lsp_installer_servers.get_server(lspServer)
    if server_available then
        opts["capabilities"] = cmp_lsp.update_capabilities(vim.lsp.protocol.make_client_capabilities())
        opts["on_attach"] = on_attach
        lspconfig[lspServer].setup(opts)
        if not requested_server:is_installed() then
            requested_server:install()
        end
    end
end
