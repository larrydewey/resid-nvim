" Vim indent file
" Language: Resid

if exists('b:did_indent')
  finish
endif
let b:did_indent = 1

setlocal indentexpr=GetResidIndent(v:lnum)
setlocal indentkeys=0{,0},0),0],!^F,o,O,0=///
setlocal nolisp nosmartindent nocindent autoindent

let b:undo_indent = 'setlocal indentexpr< indentkeys< lisp< smartindent< cindent< autoindent<'

if exists('*GetResidIndent')
  finish
endif

let s:skip = 'synIDattr(synID(line("."), col("."), 0), "name") =~? "string\\|comment\\|char\\|quote"'

" The innermost unclosed bracket before the cursor: [line, col], or [0, 0].
function! s:Opener(lnum) abort
  " A line starting in column 0 is top level, so no opener lies above it.
  let stop = a:lnum - 1
  while stop > 1 && getline(stop) !~# '^[^ \t/*]'
    let stop -= 1
  endwhile
  call cursor(a:lnum, 1)
  return searchpairpos('[{([]', '', '[})\]]', 'bnW', s:skip, max([1, stop]))
endfunction

" Strip a trailing // comment and whitespace (strings may hold `//`, so
" only when the comment is outside one).
function! s:Code(lnum) abort
  let line = getline(a:lnum)
  let c = match(line, '//')
  while c >= 0
    if synIDattr(synID(a:lnum, c + 1, 0), 'name') !~? 'string\|quote'
      let line = strpart(line, 0, c)
      break
    endif
    let c = match(line, '//', c + 2)
  endwhile
  return substitute(line, '\s\+$', '', '')
endfunction

" Whether a line ends a statement or an item, rather than continuing an
" expression onto the next line.
function! s:Complete(lnum) abort
  let code = s:Code(a:lnum)
  return code ==# '' || code =~# '[;{}(\[,]$' || code =~# '^\s*@' || code =~# '=>$'
        \ || synIDattr(synID(a:lnum, max([1, indent(a:lnum)]) + 1, 0), 'name') =~? 'comment'
endfunction

" The previous code line in the same bracket as lnum (0 when none).
function! s:PrevSibling(lnum, open) abort
  let p = prevnonblank(a:lnum - 1)
  while p > a:open[0]
    if synIDattr(synID(p, max([1, indent(p)]) + 1, 0), 'name') !~? 'comment'
      return p
    endif
    let p = prevnonblank(p - 1)
  endwhile
  return 0
endfunction

function! GetResidIndent(lnum) abort
  let cur = getline(a:lnum)
  " Inside a block comment: keep the comment's own alignment.
  if cur =~# '^\s*\*' && synIDattr(synID(a:lnum, indent(a:lnum) + 1, 0), 'name') =~? 'comment'
    return cindent(a:lnum)
  endif
  let save = getcurpos()
  let open = s:Opener(a:lnum)
  if open[0] == 0
    let base = 0
  elseif cur =~# '^\s*[})\]]'
    let base = indent(open[0])
  else
    let rest = strpart(getline(open[0]), open[1])
    let first = match(rest, '\S')
    if first >= 0 && rest !~# '^\s*//'
      " Content after the bracket: align with it.
      let base = open[1] + first
    else
      let base = indent(open[0]) + shiftwidth()
    endif
  endif
  " A line continuing an unfinished expression is indented once more.
  let p = s:PrevSibling(a:lnum, open)
  if p > 0 && cur !~# '^\s*[})\]]' && !s:Complete(p)
    let q = s:PrevSibling(p, open)
    let base = (q > 0 && !s:Complete(q)) ? indent(p) : base + shiftwidth()
  endif
  call setpos('.', save)
  return max([0, base])
endfunction
