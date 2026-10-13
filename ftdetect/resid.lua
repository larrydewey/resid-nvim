-- Sourced at startup even when the plugin itself is lazy-loaded on ft.
vim.filetype.add({
  extension = { resid = 'resid' },
  filename = { ['resid.toml'] = 'toml' },
})
