" ------------------------------------------------------------------------------
"
" Vim filetype plugin file
"
"   Language :  C++
"     Plugin :  c.vim
"   Revision :  03.10.2017
" Maintainer :  Wolfgang Mehner <wolfgang-mehner@web.de>
"
" ------------------------------------------------------------------------------

" Only do this when not done yet for this buffer
if exists("b:did_c_support_ftplugin")
	finish
endif
let b:did_c_support_ftplugin = 1

" ---------- C++ I/O (speeds up typing) --------------------------------------
"inoremap	<buffer>	>> <Space>>><Space>
"inoremap	<buffer>	<< <Space><<<Space>
"inoremap	<buffer>	<<" <Space><< ""<Space><Left><Left>
"inoremap	<buffer>	<<; <Space><< "\n";<Left><Left><Left><Left>

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

