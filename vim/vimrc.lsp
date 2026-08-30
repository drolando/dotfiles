" Native LSP config (Neovim only). Sourced from vimrc.plugins behind an
" `if has('nvim')` guard, so this file assumes vim.lsp is available.
"
" Requires Neovim 0.11+ (uses vim.lsp.config/vim.lsp.enable rather than
" the older require('lspconfig')...setup{} pattern, which nvim-lspconfig
" has deprecated as of its 0.11 support -- see :help lspconfig-nvim-0.11).
"
" Language servers themselves are NOT installed by this script or by
" vim-plug -- install whatever you need per box, e.g.:
"   pip install pyright
"   go install golang.org/x/tools/gopls@latest

lua << EOF
-- Neovim doesn't know .gotmpl by default; gopls' filetypes list includes
-- 'gotmpl', so without this it'll never attach to those files.
vim.filetype.add({
  extension = {
    gotmpl = 'gotmpl',
  },
})

local cmp = require('cmp')
cmp.setup({
  snippet = {
    expand = function(args) require('luasnip').lsp_expand(args.body) end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-space>'] = cmp.mapping.complete(),
    ['<CR>']      = cmp.mapping.confirm({ select = true }),
    ['<Tab>']     = cmp.mapping.select_next_item(),
    ['<S-Tab>']   = cmp.mapping.select_prev_item(),
  }),
  sources = cmp.config.sources(
    { { name = 'nvim_lsp' }, { name = 'luasnip' } },
    { { name = 'buffer' },   { name = 'path' } }
  ),
})

-- Give every LSP server nvim-cmp's completion capabilities by default
vim.lsp.config('*', {
  capabilities = require('cmp_nvim_lsp').default_capabilities(),
})

-- Enable whichever servers you actually have installed on this box --
-- nvim-lspconfig ships their default cmd/root_markers/filetypes, you're
-- just turning them on. A server not present on a given devbox simply
-- won't attach -- safe to leave entries here even if not every box has
-- every server.
vim.lsp.enable({ 'pyright', 'gopls' })

vim.diagnostic.config({ virtual_text = true, signs = true, underline = true })

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(ev)
    local opts = { buffer = ev.buf, silent = true }
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'gy', vim.lsp.buf.type_definition, opts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
    vim.keymap.set('n', 'K',  vim.lsp.buf.hover, opts)
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
    vim.keymap.set({'n', 'x'}, '<leader>a', vim.lsp.buf.code_action, opts)
    vim.keymap.set('n', ']g', vim.diagnostic.goto_next, opts)
    vim.keymap.set('n', '[g', vim.diagnostic.goto_prev, opts)
  end,
})
EOF
