" Neovim compiler file
" Compiler: residc

if exists('current_compiler')
  finish
endif
let current_compiler = 'resid'

" `residc file.resid -o file`
let &l:makeprg = escape(luaeval("require('resid').compiler()"), ' \') . ' %:S -o %:r:S'

" error[E0001]: message
"   --> path:line:col
setlocal errorformat=%Eerror[%*[^]]]:\ %m,%Wwarning[%*[^]]]:\ %m,%Z\ \ -->\ %f:%l:%c,%-G%.%#
