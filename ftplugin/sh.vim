" Vim filetype plugin file
"
"   Language :  bash
"     Plugin :  bash-support.vim
" Maintainer :  Fritz Mehner <mehner@fh-swf.de>
"               - suggested revision by Wolfgang Mehner, 29.07.2013
"
" -----------------------------------------------------------------
"
" Only do this when not done yet for this buffer
" 
if exists("b:did_BASH_ftplugin")
  finish
endif
let b:did_BASH_ftplugin = 1
"
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
