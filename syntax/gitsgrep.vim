" Vim syntax file
" Language: git output : grep
" Maintainer: Wolfgang Mehner <wolfgang-mehner@web.de>
" Last Change: 07.07.2013

if exists("b:current_syntax")
	finish
endif

syn sync fromstart
syn case match

"-------------------------------------------------------------------------------
" Syntax
"-------------------------------------------------------------------------------

" top-level categories:
" - GitGrepFileLines

syn region GitGrepFileLines     start=/^\z([^:]\+:\)/ end=/^\%(\z1\)\@!/ contains=GitGrepPath fold keepend

syn match  GitGrepPath          "^[^:]\+"     contained nextgroup=GitGrepSep1
syn match  GitGrepSep1          ":"           contained nextgroup=GitGrepLineNr
syn match  GitGrepLineNr        "\d\+"        contained nextgroup=GitGrepSep2
syn match  GitGrepSep2          ":"           contained

"-------------------------------------------------------------------------------
" Highlight
"-------------------------------------------------------------------------------

highlight default link GitGrepPath    Directory
highlight default link GitGrepLineNr  LineNr

let b:current_syntax = "gitsgrep"
