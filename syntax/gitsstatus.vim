" Vim syntax file
" Language: git output : status (uses: diff)
" Maintainer: Wolfgang Mehner <wolfgang-mehner@web.de>
" Last Change: 19.03.2013

if exists("b:current_syntax")
	finish
endif

" use 'GitDiffRegion' as a top-level category
runtime! syntax/gitsdiff.vim
unlet b:current_syntax

syn sync fromstart
syn case match

"-------------------------------------------------------------------------------
" Syntax
"-------------------------------------------------------------------------------

" top-level categories:
" - GitStatusHashRegion
" - GitStatusBareRegion
" containing status lines starting with a hash (X = "") or without (X = "B"):
" - GitStagedRegionX
" - GitModifiedRegionX
" - GitUntrackedRegionX
" - GitIgnoredRegionX
" - GitUntrackedRegionX
" imported:
" - GitDiffRegion

syn region GitStatusHashRegion  start=/^#/ end=/^#\@!/ contains=GitStagedRegion,GitModifiedRegion,GitUntrackedRegion,GitIgnoredRegion,GitUnmergedRegion fold
syn region GitStatusBareRegion  start=/^[^#]\%1l/ end=/^\%(diff\)\@=/ contains=GitStagedRegionB,GitModifiedRegionB,GitUntrackedRegionB,GitIgnoredRegionB,GitUnmergedRegionB fold

syn region GitStagedRegion      start=/^# Changes to be committed:/ end=/^\%(# \w\)\@=\|^#\@!/ contains=GitStatusHeader,GitStatusComment,GitStagedFile fold  contained
syn match  GitStagedFile        "^#\s\+\zs[[:alnum:][:space:]]\+:\s.\+" contained

syn region GitStagedRegionB     start=/^Changes to be committed:/ end=/^\%(\w\)\@=/ contains=GitStatusHeaderB,GitStatusCommentB,GitStagedFileB fold  contained
syn match  GitStagedFileB       "^\s\+\zs[[:alnum:][:space:]]\+:\s.\+" contained

" the header for uncommitted changes changed somewhere along the way:
" - the first alternative is the old version
" - for the new, "bare" version, we only need the new one
syn region GitModifiedRegion    start=/^# Changed but not updated:/       end=/^\%(# \w\)\@=\|^#\@!/ contains=GitStatusHeader,GitStatusComment,GitModifiedFile fold  contained
syn region GitModifiedRegion    start=/^# Changes not staged for commit:/ end=/^\%(# \w\)\@=\|^#\@!/ contains=GitStatusHeader,GitStatusComment,GitModifiedFile fold  contained
syn match  GitModifiedFile      "^#\s\+\zs[[:alnum:][:space:]]\+:\s.\+" contained

syn region GitModifiedRegionB   start=/^Changes not staged for commit:/ end=/^\%(\w\)\@=/ contains=GitStatusHeaderB,GitStatusCommentB,GitModifiedFileB fold  contained
syn match  GitModifiedFileB     "^\s\+\zs[[:alnum:][:space:]]\+:\s.\+" contained

syn region GitUntrackedRegion   start=/^# Untracked files:/ end=/^\%(# \w\)\@=\|^#\@!/ contains=GitStatusHeader,GitStatusComment,GitUntrackedFile fold  contained
syn match  GitUntrackedFile     "^#\s\+\zs[^([:space:]].*$" contained

syn region GitUntrackedRegionB  start=/^Untracked files:/ end=/^\%(\w\)\@=/ contains=GitStatusHeaderB,GitStatusCommentB,GitUntrackedFileB fold  contained
syn match  GitUntrackedFileB    "^\s\+\zs[^([:space:]].*$" contained

syn region GitIgnoredRegion     start=/^# Ignored files:/ end=/^\%(# \w\)\@=\|^#\@!/ contains=GitStatusHeader,GitStatusComment,GitIgnoredFile fold  contained
syn match  GitIgnoredFile       "^#\s\+\zs[^([:space:]].*$" contained

syn region GitIgnoredRegionB    start=/^Ignored files:/ end=/^\%(\w\)\@=/ contains=GitStatusHeaderB,GitStatusCommentB,GitIgnoredFileB fold  contained
syn match  GitIgnoredFileB      "^\s\+\zs[^([:space:]].*$" contained

syn region GitUnmergedRegion    start=/^# Unmerged paths:/ end=/^\%(# \w\)\@=\|^#\@!/ contains=GitStatusHeader,GitStatusComment,GitUnmergedFile fold  contained
syn match  GitUnmergedFile      "^#\s\+\zs[[:alnum:][:space:]]\+:\s.\+" contained

syn region GitUnmergedRegionB   start=/^Unmerged paths:/ end=/^\%(\w\)\@=/ contains=GitStatusHeaderB,GitStatusCommentB,GitUnmergedFileB fold  contained
syn match  GitUnmergedFileB     "^\s\+\zs[[:alnum:][:space:]]\+:\s.\+" contained

syn match  GitStatusHeader      "^# \zs.\+:$"        contained
syn match  GitStatusComment     "^#\s\+\zs([^)]*)$"  contained

syn match  GitStatusHeaderB     "^\S.*:$"           contained
syn match  GitStatusCommentB    "^\s\+\zs([^)]*)$"  contained

"-------------------------------------------------------------------------------
" Highlight
"-------------------------------------------------------------------------------

highlight default link GitStatusHeader    GitHeading
highlight default link GitStatusComment   GitComment
highlight default link GitStagedFile      GitAdd
highlight default link GitModifiedFile    GitRemove
highlight default link GitUntrackedFile   GitRemove
highlight default link GitIgnoredFile     GitRemove
highlight default link GitUnmergedFile    GitRemove

highlight default link GitStatusHeaderB   GitHeading
highlight default link GitStatusCommentB  GitComment
highlight default link GitStagedFileB     GitAdd
highlight default link GitModifiedFileB   GitRemove
highlight default link GitUntrackedFileB  GitRemove
highlight default link GitIgnoredFileB    GitRemove
highlight default link GitUnmergedFileB   GitRemove

let b:current_syntax = "gitsstatus"
