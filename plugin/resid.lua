if vim.g.loaded_resid then
  return
end
vim.g.loaded_resid = true

vim.filetype.add({
  extension = { resid = 'resid' },
  filename = { ['resid.toml'] = 'toml' },
})

-- Enabled by default; require('resid').setup({ lsp = false }) or
-- vim.g.resid_lsp = false turns it off.
if vim.lsp.enable and vim.g.resid_lsp ~= false then
  vim.lsp.enable('resid')
end
