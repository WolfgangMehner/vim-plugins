" ------------------------------------------------------------------------------
"
" Vim filetype plugin file
"
"   Language :  C++
"     Plugin :  c.vim 
" Maintainer :  Wolfgang Mehner <wolfgang-mehner@web.de>
"
" ------------------------------------------------------------------------------
"
" Only do this when not done yet for this buffer
" 
if exists("b:did_CPP_ftplugin")
  finish
endif
let b:did_CPP_ftplugin = 1
"
"-------------------------------------------------------------------------------
" additional mapping : C++ I/O
"-------------------------------------------------------------------------------
"
inoremap	<buffer>	>> <Space>>><Space>
inoremap	<buffer>	<< <Space><<<Space>
inoremap	<buffer>	<<" <Space><< ""<Space><Left><Left>
inoremap	<buffer>	<<; <Space><< "\n";<Left><Left><Left><Left>
"
"-------------------------------------------------------------------------------
" set "maplocalleader" as configured using "g:C_MapLeader"
"-------------------------------------------------------------------------------
call C_SetMapLeader ()
"
"-------------------------------------------------------------------------------
" additional mapping : Make tool
"-------------------------------------------------------------------------------
 noremap  <buffer>  <silent>  <LocalLeader>rm        :Make<CR>
inoremap  <buffer>  <silent>  <LocalLeader>rm   <C-C>:Make<CR>
 noremap  <buffer>  <silent>  <LocalLeader>rmc       :Make clean<CR>
inoremap  <buffer>  <silent>  <LocalLeader>rmc  <C-C>:Make clean<CR>
 noremap  <buffer>            <LocalLeader>rma       :MakeCmdlineArgs<space>
inoremap  <buffer>            <LocalLeader>rma  <C-C>:MakeCmdlineArgs<space>
 noremap  <buffer>            <LocalLeader>rcm       :MakeFile<space>
inoremap  <buffer>            <LocalLeader>rcm  <C-C>:MakeFile<space>
"
"-------------------------------------------------------------------------------
" reset "maplocalleader"
"-------------------------------------------------------------------------------
call C_ResetMapLeader ()
"
