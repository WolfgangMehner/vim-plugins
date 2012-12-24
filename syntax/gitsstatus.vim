" Vim syntax file
" Language: git output : status (contains: diff)
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

syn region GitDiffRegion       start=/^diff / end=/^\%(diff \)\@=/ contains=GitDiffHeader,GitDiffLines fold
syn region GitDiffLines        start=/^@@ / end=/^\%(@@ \)\@=\|^\%(diff \)\@=/ contains=GitDiffRange,GitDiffLineP,GitDiffLineM fold

syn match  GitStatusHeader     "^# \zs.\+:$"        contained
syn match  GitStatusComment    "^#\s\+\zs([^)]*)$"  contained

syn match  GitDiffHeader       "^\w.*$"    contained
syn match  GitDiffHeader       "^--- .*$"  contained
syn match  GitDiffHeader       "^+++ .*$"  contained

syn match  GitDiffRange        "^@@[^@]\+@@"  contained
syn match  GitDiffLineP        "^+.*$"        contained
syn match  GitDiffLineM        "^-.*$"        contained

"-------------------------------------------------------------------------------
" Highlight
"-------------------------------------------------------------------------------

highlight default      GitStatusHeader   cterm=bold       gui=bold
highlight default      GitStatusComment  ctermfg=Blue     guifg=Blue
highlight default      GitStagedFile     ctermfg=Green    guifg=SeaGreen
highlight default      GitModifiedFile   ctermfg=Red      guifg=Red
highlight default link GitUntrackedFile  GitModifiedFile
highlight default link GitIgnoredFile    GitModifiedFile

highlight default GitDiffHeader  cterm=bold                 gui=bold
highlight default GitDiffRange   cterm=bold  ctermfg=Cyan   gui=bold  guifg=DarkCyan
highlight default GitDiffLineP               ctermfg=Green            guifg=SeaGreen
highlight default GitDiffLineM               ctermfg=Red              guifg=Red

let b:current_syntax = "gitsstatus"
