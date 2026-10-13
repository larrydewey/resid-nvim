" Vim syntax file
" Language:    Resid
" Maintainer:  Larry Dewey
" Filenames:   *.resid

if exists('b:current_syntax')
  finish
endif

let s:cpo_save = &cpo
set cpo&vim

syn case match

" Keywords
syn keyword residConditional  if else match
syn keyword residRepeat       for while in
syn keyword residStatement    return break continue
syn keyword residKeyword      with spawn sandbox lambda rt using as
syn keyword residStorage      pub
syn keyword residInclude      import nextgroup=residString skipwhite
syn keyword residTypedef      type nextgroup=residTypeName skipwhite
syn keyword residBehavior     behavior nextgroup=residTypeName skipwhite
syn keyword residTest         test nextgroup=residString skipwhite
syn match   residTypeName     contained /\<[A-Z][A-Za-z0-9_]*\>/

syn keyword residBoolean      true false
syn keyword residConstant     null
syn keyword residVariant      Some None Ok Err

" Types
syn keyword residNumType      Int UInt Float Dec ISize USize
syn keyword residCoreType     Str Bytes Bool Option Result List Map Set
syn keyword residCoreType     StrBuf ListBuf Secret RegionError SourceLoc
syn match   residUserType     /\<[A-Z][A-Za-z0-9_]*\>/ display

" Built-in functions
syn keyword residBuiltin      assert rt_assert known rt_known comptime_print
syn keyword residBuiltin      todo unimplemented ct_hide ct_public
syn keyword residBuiltin      secret classify secret_split secret_join
syn match   residBuiltin      /\<\%(wrapping\|saturating\|checked\)_\w\+\ze\s*(/
syn match   residBuiltin      /\<str_\w\+\ze\s*(/
syn match   residConversion   /\<\%([iu]\%(8\|16\|32\|64\|128\|256\|512\|size\)\|f\%(16\|32\|64\|128\)\|d[1-9][0-9]*\)\ze\s*(/

" Function definitions: the name after a return type at the start of a line
syn match   residFuncDef      /\%(^\s*\%(pub\s\+\)\=\u\w*\%(([^()]*\%(([^()]*)[^()]*\)*)\)\=\s\+\)\@<=\h\w*\ze\s*(/

" Annotations and capabilities
syn match   residAnnotation   /@\h\w*/
syn keyword residCapability   filesystem environment git args process network random
syn keyword residCapability   terminal clock device display declassify
syn keyword residCapability   provision assume
syn match   residCapability   /\<native_\w\+\>/
syn keyword residCapMode      readonly readwrite

syn match   residLocation     /#location\>/

" Numbers
syn match   residNumber       /\<\d[0-9_]*\>/ display
syn match   residNumber       /\<0x[0-9A-Fa-f_]\+\>/ display
syn match   residNumber       /\<0o[0-7_]\+\>/ display
syn match   residNumber       /\<0b[01_]\+\>/ display
syn match   residFloat        /\<\d[0-9_]*\.\d[0-9_]*\%([eE][+-]\=\d\+\)\=\>/ display
syn match   residDecimal      /\<\d[0-9_]*\%(\.\d[0-9_]*\)\=m\>/ display

" Operators
syn match   residOperator     /[-+*/%=!<>&|^~?]/ display
syn match   residArrow        /=>/ display
syn match   residRange        /\.\.=\=/ display

" Strings
syn match   residEscape       /\\\%([ntr0\\"']\|x\x\x\)/ contained display
syn match   residEscapeError  /\\[^ntr0\\"'x]/ contained display
syn region  residString       matchgroup=residQuote start=/"/ skip=/\\\\\|\\"/ end=/"/
      \ contains=residEscape,residEscapeError,@Spell
syn region  residString       matchgroup=residQuote start=/\<b"/ skip=/\\\\\|\\"/ end=/"/
      \ contains=residEscape,residEscapeError
syn region  residString       matchgroup=residQuote start=/\<r"/ skip=/\\\\\|\\"/ end=/"/
syn region  residFString      matchgroup=residQuote start=/\<f"/ skip=/\\\\\|\\"/ end=/"/
      \ contains=residEscape,residEscapeError,residStringBraceEsc,residHole
syn match   residStringBraceEsc     /{{\|}}/ contained display
syn region  residHole         matchgroup=residHoleDelim start=/{\ze[^{]/ end=/}/ contained
      \ contains=TOP,residFormatSpec
syn match   residFormatSpec   /:[^}]*\ze}/ contained containedin=residHole
      \ contains=residFormatFlag
syn keyword residFormatFlag   contained width left right center fill zero plus
syn keyword residFormatFlag   contained space minus hex oct bin upper lower
syn keyword residFormatFlag   contained group precision auto decimal scientific
syn keyword residFormatFlag   contained percent trim
syn match   residChar         /'\%([^\\']\|\\\%([ntr0\\"']\|x\x\x\)\)'/ display

" Comments
syn keyword residCommentTodo         contained TODO FIXME XXX NOTE SAFETY
syn match   residCommentCode     /`[^`]\+`/ contained display
syn region  residComment      start=+//+ end=/$/ contains=residCommentTodo,@Spell keepend
syn region  residDocComment   start=+///+ end=/$/ contains=residCommentTodo,residCommentCode,@Spell keepend
syn region  residComment      start=+/\*+ end=+\*/+ contains=residCommentTodo,@Spell fold extend
syn region  residDocComment   start=+/\*\*\%(/\)\@!+ end=+\*/+ contains=residCommentTodo,residCommentCode,@Spell fold extend

" Folding on braces
syn region  residFold         start=/{/ end=/}/ transparent fold

syn sync minlines=200

hi def link residConditional  Conditional
hi def link residRepeat       Repeat
hi def link residStatement    Statement
hi def link residKeyword      Keyword
hi def link residStorage      StorageClass
hi def link residInclude      Include
hi def link residTypedef      Typedef
hi def link residBehavior     Typedef
hi def link residTest         Keyword
hi def link residTypeName     Type
hi def link residBoolean      Boolean
hi def link residConstant     Constant
hi def link residVariant      Constant
hi def link residNumType      Type
hi def link residCoreType     Type
hi def link residUserType     Type
hi def link residBuiltin      Function
hi def link residConversion   Function
hi def link residFuncDef      Function
hi def link residAnnotation   PreProc
hi def link residCapability   Identifier
hi def link residCapMode      Special
hi def link residLocation     Macro
hi def link residNumber       Number
hi def link residFloat        Float
hi def link residDecimal      Number
hi def link residOperator     Operator
hi def link residArrow        Operator
hi def link residRange        Operator
hi def link residEscape       SpecialChar
hi def link residEscapeError  Error
hi def link residString       String
hi def link residFString      String
hi def link residQuote        String
hi def link residStringBraceEsc     SpecialChar
hi def link residHoleDelim    Special
hi def link residFormatSpec   Special
hi def link residFormatFlag   Constant
hi def link residChar         Character
hi def link residCommentTodo         Todo
hi def link residCommentCode     SpecialComment
hi def link residComment      Comment
hi def link residDocComment   SpecialComment

let b:current_syntax = 'resid'

let &cpo = s:cpo_save
unlet s:cpo_save
