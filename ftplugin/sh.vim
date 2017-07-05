" ------------------------------------------------------------------------------
"
" Vim filetype plugin file
"
"   Language :  Bash
"     Plugin :  bash-support.vim
"   Revision :  15.04.2017
" Maintainer :  Wolfgang Mehner <wolfgang-mehner@web.de>
"               (formerly Fritz Mehner <mehner.fritz@web.de>)
"
" -----------------------------------------------------------------

" Only do this when not done yet for this buffer
if exists("b:did_bash_support_ftplugin")
	finish
endif
let b:did_bash_support_ftplugin = 1

"------------------------------------------------------------------------------
"  Avoid a wrong syntax highlighting for $(..) and $((..))
"------------------------------------------------------------------------------
let b:is_bash = 1
"
"-------------------------------------------------------------------------------
" additional mapping : single quotes around a Word (non-whitespaces)
"                      masks the normal mode command '' (jump to the position
"                      before the latest jump)
" additional mapping : double quotes around a Word (non-whitespaces)
"-------------------------------------------------------------------------------
nnoremap    <buffer>   ''   ciW''<Esc>P
nnoremap    <buffer>   ""   ciW""<Esc>P
"
"-------------------------------------------------------------------------------
" set "maplocalleader" as configured using "g:BASH_MapLeader"
"-------------------------------------------------------------------------------
call Bash_SetMapLeader ()
"
" maps defined here will use "g:BASH_MapLeader" as <LocalLeader>
" example:
"map  <buffer>  <LocalLeader>eg  :echo "Example Map :)"<CR>
"
"-------------------------------------------------------------------------------
" reset "maplocalleader"
"-------------------------------------------------------------------------------
call Bash_ResetMapLeader ()
"
