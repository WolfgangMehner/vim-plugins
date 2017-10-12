" ------------------------------------------------------------------------------
"
" Vim filetype plugin file
"
"   Language :  VimL / VimScript
"     Plugin :  vim-support.vim
"   Revision :  12.10.2017
" Maintainer :  Wolfgang Mehner <wolfgang-mehner@web.de>
"
" ------------------------------------------------------------------------------

" Only do this when not done yet for this buffer
if exists("b:did_vim_support_ftplugin")
	finish
endif
let b:did_vim_support_ftplugin = 1

" ---------- Set "maplocalleader" as configured using "g:Vim_MapLeader" -----
call Vim_SetMapLeader ()

" maps defined here will use "g:Vim_MapLeader" as <LocalLeader>
" example:
"map  <buffer>  <LocalLeader>eg  :echo "Example Map :)"<CR>

" ---------- Keyword help ----------------------------------------------------

if has( 'gui_running' )
	nmap  <buffer>  <S-F1>  <Plug>VimSupportKeywordHelp
	imap  <buffer>  <S-F1>  <Plug>VimSupportKeywordHelp
else
	" <SHIFT-F1> is problematic in the terminal
	nmap  <buffer>  <F1>  <Plug>VimSupportKeywordHelp
	imap  <buffer>  <F1>  <Plug>VimSupportKeywordHelp
endif
" these maps have to remap

" ---------- Reset "maplocalleader" ------------------------------------------
call Vim_ResetMapLeader ()

