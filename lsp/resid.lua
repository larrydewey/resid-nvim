-- The Resid language server: the compiler's own `lsp` subcommand
-- (diagnostics, hover, go to definition, document symbols, completion).
-- Picked up by vim.lsp.enable('resid') on Neovim 0.11+.

---@type vim.lsp.Config
return {
  cmd = function(dispatchers, config)
    local compiler = require('resid').compiler(config.root_dir)
    return vim.lsp.rpc.start({ compiler, 'lsp' }, dispatchers, { cwd = config.root_dir })
  end,
  filetypes = { 'resid' },
  root_markers = { 'resid.toml', '.git' },
}
