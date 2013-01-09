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

" The expressions are designed to distinguish between stated, modified and
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

highlight default      GitStagedFile     ctermfg=Green    guifg=SeaGreen
highlight default      GitModifiedFile   ctermfg=Red      guifg=Red
highlight default link GitUntrackedFile  GitModifiedFile
highlight default link GitIgnoredFile    GitModifiedFile
highlight default link GitUnmergedFile   GitModifiedFile

let b:current_syntax = "gitssshort"
