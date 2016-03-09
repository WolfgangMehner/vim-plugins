" Vim syntax file
" Language: git output : commit
" Maintainer: Wolfgang Mehner <wolfgang-mehner@web.de>
" Last Change: 19.03.2013

if exists("b:current_syntax")
	finish
endif

syn sync fromstart
syn case match

"-------------------------------------------------------------------------------
" Syntax
"-------------------------------------------------------------------------------

" top-level categories:
" - GitCommitLineNwarn
" - GitCommitLine2warn
" - GitCommitLine1warn

syn match  GitCommitLineNwarn   "^.\{,76}\zs.*$"
syn match  GitCommitLine2warn   "^\%2l.*$"
syn match  GitCommitLine1warn   "^\%1l.\{,50}\zs.*"

syn match GitComment   "^#.*$"

"-------------------------------------------------------------------------------
" Highlight
"-------------------------------------------------------------------------------

highlight default link GitCommitLine1warn  GitWarning
highlight default link GitCommitLine2warn  GitWarning
highlight default link GitCommitLineNwarn  GitWarning

let b:current_syntax = "gitscommit"
