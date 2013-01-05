"===============================================================================
"
"          File:  help.vim
" 
"   Description:  Filetype plugin for Help.
" 
"   VIM Version:  7.0+
"        Author:  Wolfgang Mehner (WM), wolfgang-mehner@web.de
"       Company:  
"       Version:  1.0
"       Created:  07.11.2011 13:09
"      Revision:  ---
"===============================================================================
"
" Only do this when not done yet for this buffer
if exists("b:did_Help_ftplugin")
  "finish
endif
let b:did_Help_ftplugin = 1
"
"----------------------------------------------------------------------
"  tags
"----------------------------------------------------------------------
inoremap <buffer> \|\| \|\|<Left>
"
