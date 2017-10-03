" ------------------------------------------------------------------------------
"
" Vim filetype plugin file
"
"   Language :  C
"     Plugin :  c.vim 
"   Revision :  03.10.2017
" Maintainer :  Wolfgang Mehner <wolfgang-mehner@web.de>
"               (formerly Fritz Mehner <mehner.fritz@web.de>)
"
" ------------------------------------------------------------------------------

" Only do this when not done yet for this buffer
if exists("b:did_c_support_ftplugin")
	finish
endif
let b:did_c_support_ftplugin = 1

" ---------- complete a classical C comment ----------------------------------
"  '/*' => '/* | */' (and surround selected area in visual mode)
"inoremap  <buffer>  /*       /*<Space><Space>*/<Left><Left><Left>
"vnoremap  <buffer>  /*      s/*<Space><Space>*/<Left><Left><Left><Esc>p

" ---------- complete a classical C multi-line comment -----------------------
"  '/*<CR>' =>  /*
"                * |
"                */
"inoremap  <buffer>  /*<CR>  /*<CR><CR>/<Esc>kA<Space>

" ---------- {<CR> always opens a block --------------------------------------
"inoremap  <buffer>  {<CR>    {<CR>}<Esc>O
"vnoremap  <buffer>  {<CR>   S{<CR>}<Esc>Pk=iB

" ---------- Set "maplocalleader" as configured using "g:C_MapLeader" --------
call C_SetMapLeader ()

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
call C_ResetMapLeader ()

