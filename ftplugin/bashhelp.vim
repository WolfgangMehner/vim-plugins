"===============================================================================
"
"          File:  bashhelp.vim
"
"   Description:  Filetype plugin for Bash's built-in help.
"
"                 Some settings have been taken from Neovim's filetype plug-in
"                 for 'man'.
"
"   VIM Version:  7.0+
"        Author:  Wolfgang Mehner, wolfgang-mehner@web.de
"  Organization:  
"       Version:  1.0
"       Created:  16.11.2017
"      Revision:  ---
"===============================================================================

" only do this when not done yet for this buffer
if exists("b:did_BashHelp_ftplugin")
  finish
endif
let b:did_BashHelp_ftplugin = 1

setlocal noexpandtab
setlocal tabstop=8
setlocal softtabstop=8
setlocal shiftwidth=8

setlocal nonumber
setlocal norelativenumber
setlocal foldcolumn=0
setlocal colorcolumn=0
setlocal nolist
setlocal nofoldenable
