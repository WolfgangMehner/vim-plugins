" Vim syntax file
" Language: git output : grep
" Maintainer: Wolfgang Mehner <wolfgang-mehner@web.de>
" Last Change: 13.10.2017

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

if has( 'conceal' )
	syn region GitGrepFileLines     start=/^\z(\p\+\%x00\)/ end=/^\%(\z1\)\@!/ contains=GitGrepPath fold keepend

	syn match  GitGrepPath          "^\p\+"     contained nextgroup=GitGrepSep1
	syn match  GitGrepSep1          "\%x00"     contained nextgroup=GitGrepLineNr conceal cchar=:
	syn match  GitGrepLineNr        "\d\+"      contained nextgroup=GitGrepSep2
	syn match  GitGrepSep2          "\%x00"     contained                         conceal cchar=:
else
	syn region GitGrepFileLines     start=/^\z([^:]\+:\)/ end=/^\%(\z1\)\@!/ contains=GitGrepPath fold keepend

	syn match  GitGrepPath          "^[^:]\+"     contained nextgroup=GitGrepSep1
	syn match  GitGrepSep1          ":"           contained nextgroup=GitGrepLineNr
	syn match  GitGrepLineNr        "\d\+"        contained nextgroup=GitGrepSep2
	syn match  GitGrepSep2          ":"           contained
endif

"-------------------------------------------------------------------------------
" Highlight
"-------------------------------------------------------------------------------

highlight default link GitGrepPath    Directory
highlight default link GitGrepLineNr  LineNr

let b:current_syntax = "gitsgrep"
