" Vim filetype plugin file
"
" Language   :  Tex
" Plugin     :  tex.vim
" Maintainer :  Fritz Mehner <mehner@web.de>
" Last Change:  28.12.2012
"
" -----------------------------------------------------------------
"
" Only do this when not done yet for this buffer
" 
if exists("b:did_Tex_ftplugin")
  finish
endif
let b:did_Tex_ftplugin = 1
"
" ---------- Add ':' to the keyword characters -------------------------------
"  Tokens like 'FIG:xxx' are recognized as one keyword.
"  This enables completions like \ref{SEC:<C-n> .
setlocal iskeyword+=:
"setlocal iskeyword+=_
"
" ---------- Key mappings  -------------------------------------
"  double '$', surround marked expression with '$ ... $'
"inoremap <buffer> $ $$<Left>
"vnoremap <buffer> $ s$$<Esc>P<Right>
"
