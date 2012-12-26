" Vim syntax file
" Language: git output : log
" Maintainer: Wolfgang Mehner <wolfgang-mehner@web.de>
" Last Change: 23.12.2012

if exists("b:current_syntax")
	finish
endif

syn sync fromstart
syn case match

"-------------------------------------------------------------------------------
" Syntax
"-------------------------------------------------------------------------------

syn region GitLogCommit  start=/^commit\s/ end=/^\%(commit\s\)\@=/ contains=GitLogHash,GitLogInfo fold
syn match  GitLogHash    "^commit\s.\+$" contained
syn match  GitLogInfo    "^\w\+:\s.\+$"  contained

"-------------------------------------------------------------------------------
" Highlight
"-------------------------------------------------------------------------------

highlight default GitLogHash  ctermfg=DarkYellow  guifg=DarkYellow
highlight default GitLogInfo  ctermfg=Green       guifg=DarkGreen

let b:current_syntax = "gitslog"
