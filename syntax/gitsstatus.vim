" Vim syntax file
" Language: git output : status (uses: diff)
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
" - GitStagedRegion
" - GitModifiedRegion
" - GitUntrackedRegion
" - GitIgnoredRegion
" - GitUntrackedRegion
" imported:
" - GitDiffRegion

" use 'GitDiffRegion' as a top-level category
runtime! syntax/gitsdiff.vim
unlet b:current_syntax

syn region GitStagedRegion     start=/^# Changes to be committed:/ end=/^\%(# \w\)\@=\|^#\@!/ contains=GitStatusHeader,GitStatusComment,GitStagedFile fold
syn match  GitStagedFile       "^#\s\+\zs[[:alnum:][:space:]]\+:\s.\+" contained

" the header for uncommitted changes changed somewhere along the way,
" the first alternative is the old version
syn region GitModifiedRegion   start=/^# Changed but not updated:/       end=/^\%(# \w\)\@=\|^#\@!/ contains=GitStatusHeader,GitStatusComment,GitModifiedFile fold
syn region GitModifiedRegion   start=/^# Changes not staged for commit:/ end=/^\%(# \w\)\@=\|^#\@!/ contains=GitStatusHeader,GitStatusComment,GitModifiedFile fold
syn match  GitModifiedFile     "^#\s\+\zs[[:alnum:][:space:]]\+:\s.\+" contained

syn region GitUntrackedRegion  start=/^# Untracked files:/ end=/^\%(# \w\)\@=\|^#\@!/ contains=GitStatusHeader,GitStatusComment,GitUntrackedFile fold
syn match  GitUntrackedFile    "^#\s\+\zs[^([:space:]].*$" contained

syn region GitIgnoredRegion    start=/^# Ignored files:/ end=/^\%(# \w\)\@=\|^#\@!/ contains=GitStatusHeader,GitStatusComment,GitIgnoredFile fold
syn match  GitIgnoredFile      "^#\s\+\zs[^([:space:]].*$" contained

syn region GitUnmergedRegion   start=/^# Unmerged paths:/ end=/^\%(# \w\)\@=\|^#\@!/ contains=GitStatusHeader,GitStatusComment,GitUnmergedFile fold
syn match  GitUnmergedFile     "^#\s\+\zs[[:alnum:][:space:]]\+:\s.\+" contained

syn match  GitStatusHeader     "^# \zs.\+:$"        contained
syn match  GitStatusComment    "^#\s\+\zs([^)]*)$"  contained

"-------------------------------------------------------------------------------
" Highlight
"-------------------------------------------------------------------------------

highlight default link GitStatusHeader   GitHeading
highlight default link GitStatusComment  GitComment
highlight default link GitStagedFile     GitAdd
highlight default link GitModifiedFile   GitRemove
highlight default link GitUntrackedFile  GitRemove
highlight default link GitIgnoredFile    GitRemove
highlight default link GitUnmergedFile   GitRemove

let b:current_syntax = "gitsstatus"
