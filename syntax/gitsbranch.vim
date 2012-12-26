" Vim syntax file
" Language: git output : branch
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

syn match  GitBranchCurrent  "^\*\s.\+$"

"-------------------------------------------------------------------------------
" Highlight
"-------------------------------------------------------------------------------

highlight default GitBranchCurrent  ctermfg=Green  guifg=SeaGreen

let b:current_syntax = "gitsbranch"
