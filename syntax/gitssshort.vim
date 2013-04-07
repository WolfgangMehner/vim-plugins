" Vim syntax file
" Language: git output : status --short
" Maintainer: Wolfgang Mehner <wolfgang-mehner@web.de>
" Last Change: 30.12.2012

if exists("b:current_syntax")
	finish
endif

syn sync fromstart
syn case match

"-------------------------------------------------------------------------------
" Syntax
"-------------------------------------------------------------------------------

" top-level categories:
" - GitStagedFile
" - GitModifiedFile
" - GitUntrackedFile
" - GitIgnoredFile
" - GitUnmergedFile

" The expressions are designed to distinguish between staged, modified and
" unmerged files. This should work, since a modified file is never prefixed
" by 'AA' or 'DD'.

syn match  GitStagedFile       "^[MARC] \s.\+"
syn match  GitStagedFile       "^D \s.\+"
syn match  GitModifiedFile     "^[ MARC][MD]\s.\+"
syn match  GitModifiedFile     "^DM\s.\+"
syn match  GitUntrackedFile    "^??"
syn match  GitIgnoredFile      "^!!"
syn match  GitUnmergedFile     "^\%(AA\|DD\)\s.\+"
syn match  GitUnmergedFile     "^\%([AD]U\|U[ADU]\)\s.\+"

"-------------------------------------------------------------------------------
" Highlight
"-------------------------------------------------------------------------------

highlight default link GitStagedFile     GitAdd
highlight default link GitModifiedFile   GitRemove
highlight default link GitUntrackedFile  GitRemove
highlight default link GitIgnoredFile    GitRemove
highlight default link GitUnmergedFile   GitRemove

let b:current_syntax = "gitssshort"
