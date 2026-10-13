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

let s:skip = 's:Skip(line("."), col("."))'

" A copy of line lnum with every character inside a string, char or //
" comment replaced by a space. Scanned by hand rather than read from the
" syntax: a string cut off at 'synmaxcol' would bleed into later lines.
let s:masks = {}
let s:masks_tick = -1
function! s:Mask(lnum) abort
  if s:masks_tick != b:changedtick || get(s:, 'masks_buf', -1) != bufnr('')
    let s:masks = {}
    let s:masks_tick = b:changedtick
    let s:masks_buf = bufnr('')
  endif
  if has_key(s:masks, a:lnum)
    return s:masks[a:lnum]
  endif
  let chars = split(getline(a:lnum), '\zs')
  let quote = ''
  let i = 0
  let n = len(chars)
  while i < n
    let c = chars[i]
    if quote !=# ''
      let chars[i] = ' '
      if c ==# '\' && i + 1 < n
        let i += 1
        let chars[i] = ' '
      elseif c ==# quote
        let quote = ''
      endif
    elseif c ==# '"' || c ==# "'"
      let quote = c
      let chars[i] = ' '
    elseif c ==# '/' && i + 1 < n && chars[i + 1] ==# '/'
      call map(chars, {k, v -> k >= i ? ' ' : v})
      break
    endif
    let i += 1
  endwhile
  let s:masks[a:lnum] = join(chars, '')
  return s:masks[a:lnum]
endfunction

" Whether the bracket at lnum, col is in a string, char or comment.
function! s:Skip(lnum, col) abort
  let line = getline(a:lnum)
  let idx = charidx(line, a:col - 1)
  if s:Mask(a:lnum)[byteidx(s:Mask(a:lnum), idx)] ==# ' '
    return 1
  endif
  return a:col <= &synmaxcol && synIDattr(synID(a:lnum, a:col, 0), 'name') =~? 'comment'
endfunction

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

" The indentation of the statement holding the bracket at pos: a line that
" starts inside a parenthesis or square bracket (a continued parameter
" list) counts as part of the line that opened it.
function! s:Anchor(pos) abort
  let lnum = a:pos[0]
  while 1
    let up = s:Opener(lnum)
    if up[0] == 0 || getline(up[0])[up[1] - 1] !~# '[([]'
      return indent(lnum)
    endif
    let lnum = up[0]
  endwhile
endfunction

" Strip a trailing // comment and whitespace (strings may hold `//`, so
" only when the comment is outside one).
function! s:Code(lnum) abort
  return substitute(s:Mask(a:lnum), '\s\+$', '', '')
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
    let base = s:Anchor(open)
  else
    let rest = strpart(getline(open[0]), open[1])
    let first = match(rest, '\S')
    if first >= 0 && rest !~# '^\s*//'
      " Content after the bracket: align with it.
      let base = open[1] + first
    else
      let base = s:Anchor(open) + shiftwidth()
    endif
  endif
  " A line continuing an unfinished expression is indented once more.
  let p = s:PrevSibling(a:lnum, open)
  if p > 0 && cur !~# '^\s*[})\]]' && (cur =~# '^\s*else\>' || !s:Complete(p))
    let q = s:PrevSibling(p, open)
    let base = (q > 0 && !s:Complete(q)) ? indent(p) : base + shiftwidth()
  endif
  call setpos('.', save)
  return max([0, base])
endfunction
