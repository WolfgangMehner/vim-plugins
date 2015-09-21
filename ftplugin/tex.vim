" Vim filetype plugin file
"
"   Language :  LaTeX
"     Plugin :  latex-support.vim
" Maintainer :  Fritz Mehner <mehner@web.de>
"
" ----------------------------------------------------------------------------
"
" Only do this when not done yet for this buffer
"
if exists("b:did_LATEX_ftplugin")
  finish
endif
let b:did_LATEX_ftplugin = 1
"
" ---------- Add to the keyword characters -----------------------------------
"            Useful for searching labels which use special characters
"
"setlocal iskeyword+=_
"setlocal iskeyword+=:
"
" ---------- Set "maplocalleader" as configured using "g:Latex_MapLeader" ----
"
call Latex_SetMapLeader ()
"
" ---------- Maps for the Make tool ------------------------------------------
"
 noremap  <buffer>  <silent>  <LocalLeader>rm        :Make<CR>
inoremap  <buffer>  <silent>  <LocalLeader>rm   <C-C>:Make<CR>
 noremap  <buffer>  <silent>  <LocalLeader>rmc       :Make clean<CR>
inoremap  <buffer>  <silent>  <LocalLeader>rmc  <C-C>:Make clean<CR>
 noremap  <buffer>            <LocalLeader>rma       :MakeCmdlineArgs<space>
inoremap  <buffer>            <LocalLeader>rma  <C-C>:MakeCmdlineArgs<space>
 noremap  <buffer>            <LocalLeader>rcm       :MakeFile<space>
inoremap  <buffer>            <LocalLeader>rcm  <C-C>:MakeFile<space>
"
" ---------- Reset "maplocalleader" ------------------------------------------
"
call Latex_ResetMapLeader ()
"
