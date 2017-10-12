" ------------------------------------------------------------------------------
"
" Vim filetype plugin file
"
"   Language :  LaTeX
"     Plugin :  latex-support.vim
"   Revision :  29.07.2017
" Maintainer :  Wolfgang Mehner <wolfgang-mehner@web.de>
"
" ------------------------------------------------------------------------------

" Only do this when not done yet for this buffer
if exists("b:did_latex_support_ftplugin")
	finish
endif
let b:did_latex_support_ftplugin = 1

" ---------- Add to the keyword characters -----------------------------------
"  useful for searching labels which use special characters
"setlocal iskeyword+=_
"setlocal iskeyword+=:

" ---------- Key mappings  ---------------------------------------------------
"  double '$', surround marked expression with '$ ... $'
"inoremap <buffer> $ $$<Left>
"vnoremap <buffer> $ s$$<Esc>P<Right>

" ---------- Set "maplocalleader" as configured using "g:Latex_MapLeader" ----
call Latex_SetMapLeader ()

" ---------- Maps for running Latex et al. -----------------------------------
nnoremap  <buffer>            <F9>                   :Latex<CR>
inoremap  <buffer>            <F9>              <Esc>:Latex<CR>
vnoremap  <buffer>            <F9>              <Esc>:Latex<CR>
nnoremap  <buffer>            <C-F9>                 :LatexView<CR>
inoremap  <buffer>            <C-F9>            <Esc>:LatexView<CR>
vnoremap  <buffer>            <C-F9>            <Esc>:LatexView<CR>

" ---------- Maps for the Make tool ------------------------------------------
 noremap  <buffer>  <silent>  <LocalLeader>rm        :Make<CR>
inoremap  <buffer>  <silent>  <LocalLeader>rm   <C-C>:Make<CR>
 noremap  <buffer>  <silent>  <LocalLeader>rmc       :Make clean<CR>
inoremap  <buffer>  <silent>  <LocalLeader>rmc  <C-C>:Make clean<CR>
 noremap  <buffer>  <silent>  <LocalLeader>rmd       :Make doc<CR>
inoremap  <buffer>  <silent>  <LocalLeader>rmd  <C-C>:Make doc<CR>
 noremap  <buffer>            <LocalLeader>rma       :MakeCmdlineArgs<space>
inoremap  <buffer>            <LocalLeader>rma  <C-C>:MakeCmdlineArgs<space>
 noremap  <buffer>            <LocalLeader>rcm       :MakeFile<space>
inoremap  <buffer>            <LocalLeader>rcm  <C-C>:MakeFile<space>

" ---------- Reset "maplocalleader" ------------------------------------------
call Latex_ResetMapLeader ()

