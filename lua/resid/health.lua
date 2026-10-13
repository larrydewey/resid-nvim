local M = {}

function M.check()
  local health = vim.health
  health.start('resid')

  if vim.fn.has('nvim-0.11') == 1 then
    health.ok('Neovim ' .. tostring(vim.version()))
  else
    health.error('Neovim 0.11 or later is needed for the language server (vim.lsp.config)')
  end

  local compiler = require('resid').compiler()
  if vim.fn.executable(compiler) == 1 then
    health.ok('compiler: ' .. vim.fn.exepath(compiler))
  else
    health.error('compiler not found: ' .. compiler, {
      'Install Resid (./install.sh puts residc in ~/.resid/bin) and add it to PATH',
      "or set require('resid').setup({ compiler = '/path/to/residc' })",
    })
  end

  local clients = vim.lsp.get_clients({ name = 'resid' })
  if #clients > 0 then
    health.ok('language server running (' .. #clients .. ' client(s))')
  elseif vim.g.resid_lsp == false or not require('resid').config.lsp then
    health.info('language server disabled')
  else
    health.info('language server not running (it starts with a .resid buffer)')
  end
end

return M
