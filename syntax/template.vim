" Vim syntax file
" Language: mm template engine : template library
" Maintainer: Wolfgang Mehner <wolfgang-mehner@web.de>
" Last Change: 27.03.2016
" Version: 1.0

if version < 600
	syntax clear
elseif exists("b:current_syntax")
	finish
endif

"-------------------------------------------------------------------------------
" Syntax
"-------------------------------------------------------------------------------

" comment
syn match Comment   "^§.*$"
syn match Comment   "\%(==\)\@<=[^=]*$"

" templates, lists, ...
syn match Structure "^==\s*\%(TEMPLATE:\)\?[a-zA-Z0-9\-+.,_ ]\+==\%(.\+==\)\?"
syn match Structure "^==\s*ENDTEMPLATE\s*=="

syn match Structure "^==\s*HELP:[a-zA-Z0-9\-+.,_ ]\+==\%(.\+==\)\?"

syn match Structure "^==\s*SEP:[a-zA-Z0-9\-+.,_ ]\+=="

syn match Structure "^==\s*LIST:\s*[a-zA-Z0-9_]\+\s*==\%(.\+==\)\?"
syn match Structure "^==\s*ENDLIST\s*=="

" style sections
syn match Statement "^==\s*IF\s\+|STYLE|\s\+IS\s\+[a-zA-Z0-9_]\+\s*=="
syn match Statement "^==\s*ENDIF\s*=="

syn match Statement "^==\s*USE\s\+STYLES\s*:[a-zA-Z0-9_, ]\+=="
syn match Statement "^==\s*ENDSTYLES\s*=="

syn match Statement "^==\s*USE\s\+FILETYPES\s*:[a-zA-Z0-9_, ]\+=="
syn match Statement "^==\s*ENDFILETYPES\s*=="

" functions: command mode
syn match Function  "InterfaceVersion\ze\s*("

syn match Function  "IncludeFile\ze\s*("
syn match Function  "SetFormat\ze\s*("
syn match Function  "SetMacro\ze\s*("
syn match Function  "SetStyle\ze\s*("
syn match Function  "SetSyntax\ze\s*("
syn match Function  "SetPath\ze\s*("

syn match Function  "MenuShortcut\ze\s*("
syn match Function  "SetProperty\ze\s*("
syn match Function  "SetMap\ze\s*("
syn match Function  "SetShortcut\ze\s*("
syn match Function  "SetMenuEntry\ze\s*("
syn match Function  "SetExpansion\ze\s*("

" functions: standard template
syn match Function  "|\zsDefaultMacro\ze("
syn match Function  "|\zsPrompt\ze("
syn match Function  "|\zsPickFile\ze("
syn match Function  "|\zsPickList\ze("
syn match Function  "|\zsSurroundWith\ze("
syn match Function  "|\zsInsert\ze("
syn match Function  "|\zsInsertLine\ze("

syn match Comment   "|C(.\{-})|"
syn match Comment   "|Comment(.\{-})|"

" functions: help
syn match Function  "|\zsWord\ze("
syn match Function  "|\zsPattern\ze("
syn match Function  "|\zsDefault\ze("
syn match Function  "|\zsSubstitute\ze("
syn match Function  "|\zsLiteralSub\ze("
syn match Function  "|\zsBrowser\ze("
syn match Function  "|\zsSystem\ze("
syn match Function  "|\zsVim\ze("

" strings, macros, tags, jump targets
syn match TemplString  "'\%([^']\|''\)*'" contains=TemplMacro,TemplTag,TemplJump
syn match TemplString  "\"\%([^"\\]\|\\.\)*\"" contains=TemplMacro,TemplTag,TemplJump

syn match TemplMacro   "|?\?[a-zA-Z][a-zA-Z0-9_]*\%(:\a\)\?\%(%\%([-+*]\+\|[-+*]\?\d\+\)[lrc]\?\)\?|"
syn match TemplTag     "|<\+>\+|"
syn match TemplTag     "<CURSOR>\|{CURSOR}"
syn match TemplTag     "<RCURSOR>\|{RCURSOR}"
syn match TemplTag     "<SPLIT>"
syn match TemplTag     "<CONTENT>"

syn match TemplJump    "<\([+-]\)\w*\1>"
syn match TemplJump    "{\([+-]\)\w*\1}"
syn match TemplJump    "\[\([+-]\)\w*\1]"

"-------------------------------------------------------------------------------
" Highlight
"-------------------------------------------------------------------------------

highlight default link TemplString  String
highlight default link TemplMacro   Tag
highlight default link TemplTag     Tag
highlight default link TemplJump    Search

let b:current_syntax = "template"
