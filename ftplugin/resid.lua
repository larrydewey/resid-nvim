if vim.b.did_ftplugin then
  return
end
vim.b.did_ftplugin = true

local o = vim.opt_local
o.comments = { 's1:/*', 'mb:*', 'ex:*/', ':///', '://' }
o.commentstring = '// %s'
o.formatoptions:remove('t')
o.formatoptions:append('croqnl')
o.expandtab = true
o.shiftwidth = 4
o.softtabstop = 4
o.tabstop = 4
o.suffixesadd = '.resid'
o.include = [[^\s*import\s\+"]]
o.includeexpr = [[substitute(v:fname,'"','','g')]]
o.foldmethod = 'syntax'
o.foldlevel = 99

vim.cmd.compiler('resid')

vim.b.undo_ftplugin = 'setlocal comments< commentstring< formatoptions< expandtab<'
  .. ' shiftwidth< softtabstop< tabstop< suffixesadd< include< includeexpr<'
  .. ' foldmethod< foldlevel< makeprg< errorformat<'
