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

syn region GitUnmergedRegion   start=/^# Unmerged paths:/ end=/^\%(# \w\)\@=\|^#\@!/ contains=GitStatusHeader,GitStatusComment,GitUnmergedFile fold
syn match  GitUnmergedFile     "^#\s\+\zs[[:alnum:][:space:]]\+:\s.\+" contained

syn match  GitStatusHeader     "^# \zs.\+:$"        contained
syn match  GitStatusComment    "^#\s\+\zs([^)]*)$"  contained

syn region GitDiffRegion       start=/^diff / end=/^\%(diff \)\@=/ contains=GitDiffHeader,GitDiffLines,GitMergeLines fold
syn region GitDiffLines        start=/^@@ /   end=/^\%(@@ \)\@=\|^\%(diff \)\@=/ contains=GitDiffRange,GitDiffLineP,GitDiffLineM fold
syn region GitMergeLines       start=/^@@@ /  end=/^\%(@@@ \)\@=\|^\%(diff \)\@=/ contains=GitMergeRange,GitMergeLineP,GitMergeLineM,GitMergeConflict fold

syn match  GitDiffHeader       "^\w.*$"    contained
syn match  GitDiffHeader       "^--- .*$"  contained
syn match  GitDiffHeader       "^+++ .*$"  contained

syn match  GitDiffRange        "^@@[^@]\+@@"  contained
syn match  GitDiffLineP        "^+.*$"        contained
syn match  GitDiffLineM        "^-.*$"        contained

syn match  GitMergeRange       "^@@@[^@]\+@@@"   contained
syn match  GitMergeLineP       "^+ .*$"          contained
syn match  GitMergeLineP       "^ +.*$"          contained
syn match  GitMergeLineM       "^- .*$"          contained
syn match  GitMergeLineM       "^ -.*$"          contained
syn match  GitMergeConflict    "^++<<<<<<< .\+"  contained
syn match  GitMergeConflict    "^++======="      contained
syn match  GitMergeConflict    "^++>>>>>>> .\+"  contained

"-------------------------------------------------------------------------------
" Highlight
"-------------------------------------------------------------------------------

highlight default      GitStatusHeader   cterm=bold       gui=bold
highlight default      GitStatusComment  ctermfg=Blue     guifg=Blue
highlight default      GitStagedFile     ctermfg=Green    guifg=SeaGreen
highlight default      GitModifiedFile   ctermfg=Red      guifg=Red
highlight default link GitUntrackedFile  GitModifiedFile
highlight default link GitIgnoredFile    GitModifiedFile
highlight default link GitUnmergedFile   GitModifiedFile

highlight default      GitDiffHeader  cterm=bold                 gui=bold
highlight default      GitDiffRange   cterm=bold  ctermfg=Cyan   gui=bold  guifg=DarkCyan
highlight default      GitDiffLineP               ctermfg=Green            guifg=SeaGreen
highlight default      GitDiffLineM               ctermfg=Red              guifg=Red
highlight default link GitMergeRange GitDiffRange
highlight default link GitMergeLineP GitDiffLineP
highlight default link GitMergeLineM GitDiffLineM
highlight default      GitMergeConflict  cterm=bold  ctermfg=White  ctermbg=Red  gui=bold  guifg=White  guibg=Red

let b:current_syntax = "gitsstatus"
