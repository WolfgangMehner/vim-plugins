" Vim syntax file
" Language: git output : log (uses: diff)
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
" - GitLogCommit

" use 'GitDiffRegion' contained in 'GitLogCommit'
syn include <sfile>:p:h/gitsdiff.vim

syn region GitLogCommit  start=/^commit\s/ end=/^\%(commit\s\)\@=/ contains=GitLogHash,GitLogInfo,GitDiffRegion fold keepend
syn match  GitLogHash    "^commit\s.\+$" contained
syn match  GitLogInfo    "^\w\+:\s.\+$"  contained

syn region GitStash      start=/^stash@{\d\+}:\s/ end=/^\%(stash@{\d\+}:\s\)\@=/ contains=GitStashName,GitDiffRegion fold keepend
syn match  GitStashName  "^stash@{\d\+}:\s.\+$" contained

"-------------------------------------------------------------------------------
" Highlight
"-------------------------------------------------------------------------------

highlight default link GitLogHash  GitHighlight2
highlight default link GitLogInfo  GitHighlight1

let b:current_syntax = "gitslog"
