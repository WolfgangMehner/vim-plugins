" Vim syntax file
" Language: git output : log (uses: diff)
" Maintainer: Wolfgang Mehner <wolfgang-mehner@web.de>
" Last Change: 19.03.2013

if exists("b:current_syntax")
	finish
endif

" use 'GitDiffRegion' contained in 'GitLogCommit'
syn include <sfile>:p:h/gitsdiff.vim

"syn sync minlines=100
syn sync fromstart
syn case match

"-------------------------------------------------------------------------------
" Syntax
"-------------------------------------------------------------------------------

" top-level categories:
" - GitLogCommit
" - GitStash
" - GitAnnoTag

syn region GitLogCommit  start=/^commit\s/ end=/^\%(commit\s\)\@=/ contains=GitLogHash,GitLogInfo,GitDiffRegion fold keepend
syn match  GitLogHash    "^commit\s.\+$" contained contains=GitLogDeco
syn match  GitLogDeco    "(\zs.*\ze)" contained contains=GitLogRef
syn match  GitLogRef     "[^,%s]" contained
syn match  GitLogInfo    "^\w\+:\s.\+$"  contained
syn match  GitLogInfo    "^Notes:\s*$"  contained
syn match  GitLogInfo    "^Notes\s(.*):\s*$"  contained

syn region GitStash      start=/^stash@{\d\+}:\s/ end=/^\%(stash@{\d\+}:\s\)\@=/ contains=GitStashName,GitDiffRegion fold keepend
syn match  GitStashName  "^stash@{\d\+}:\s.\+$" contained

syn region GitAnnoTag    start=/^tag\s/ end=/^\%(commit\)\@=/ contains=GitTagName,GitLogInfo fold keepend
syn match  GitTagName    "^tag\s.\+$" contained

"-------------------------------------------------------------------------------
" Highlight
"-------------------------------------------------------------------------------

highlight default link GitLogHash  GitHighlight2
highlight default link GitLogRef   GitHighlight1
highlight default link GitLogInfo  GitHighlight1
highlight default link GitTagName  GitHighlight2

let b:current_syntax = "gitslog"
