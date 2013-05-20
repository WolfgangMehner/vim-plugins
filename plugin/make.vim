"===============================================================================
"
"          File:  make.vim
" 
"   Description:  
" 
"   VIM Version:  7.0+
"        Author:  Dr. Fritz Mehner (fgm), mehner.fritz@fh-swf.de
"  Organization:  FH Südwestfalen, Iserlohn
"       Version:  1.0
"       Created:  02.04.2013 15:56
"      Revision:  ---
"       License:  Copyright (c) 2013, Dr. Fritz Mehner
"===============================================================================
"
" only do this when not done yet for this buffer
if exists("b:did_Make_ftplugin")
  finish
endif
let b:did_Make_ftplugin = 1
let s:MSWIN = has("win16") || has("win32")   || has("win64")    || has("win95")
"
let g:Make_Version      = "1.0"                 " version number of this script; do not change
let g:Make_Makefile			= ''
let g:Make_CmdLineArgs  = ''                    " command-line arguments for make
"
"------------------------------------------------------------------------------
"  Make_Input : input from the command-line       {{{1
"------------------------------------------------------------------------------
function! Make_Input ( prompt, text, ... )
	echohl Search																					" highlight prompt
	call inputsave()																			" preserve typeahead
	if a:0 == 0 || empty(a:1)
		let retval	=input( a:prompt, a:text )
	else
		let retval	=input( a:prompt, a:text, a:1 )
	endif
	call inputrestore()																		" restore typeahead
	echohl None																						" reset highlighting
	let retval  = substitute( retval, '^\s\+', "", "" )		" remove leading whitespaces
	let retval  = substitute( retval, '\s\+$', "", "" )		" remove trailing whitespaces
	return retval
endfunction    " ----------  end of function Make_Input ----------
"
"------------------------------------------------------------------------------
"  Make_MakeArguments : read command-line arguments       {{{1
"------------------------------------------------------------------------------
function! Make_MakeArguments ()
	let	g:Make_CmdLineArgs= Make_Input("make command-line arguments : ",g:Make_CmdLineArgs, 'file' )
endfunction    " ----------  end of function Make_MakeArguments ----------
"
"------------------------------------------------------------------------------
"  Make_RunMake : run make       {{{1
"------------------------------------------------------------------------------
function! Make_RunMake( target )
	exe	":cclose"
	" update : write source file if necessary
	exe	":update"
	"
	let cmdlinearg	= g:Make_CmdLineArgs
	if a:target != ''
		let cmdlinearg	= a:target
	endif
	" run make
	if g:Make_Makefile == ''
		exe	":make ".cmdlinearg
	else
		exe	':lchdir  '.fnamemodify( g:Make_Makefile, ":p:h" )
		if  s:MSWIN
			exe	':make -f "'.g:Make_Makefile.'" '.cmdlinearg
		else
			exe	':make -f '.g:Make_Makefile.' '.cmdlinearg
		endif
		exe	":lchdir -"
	endif
	exe	":botright cwindow"
	"
endfunction    " ----------  end of function Make_RunMake ----------

"------------------------------------------------------------------------------
"   s:CreateAdditionalMaps          {{{1
"------------------------------------------------------------------------------
function! s:CreateAdditionalMaps ()
	 noremap    <buffer>  <silent>  <LocalLeader>rm         :call Make_RunMake('')<CR>
	inoremap    <buffer>  <silent>  <LocalLeader>rm    <C-C>:call Make_RunMake('')<CR>
	 noremap    <buffer>  <silent>  <LocalLeader>rmc        :call Make_RunMake('clean')<CR>
	inoremap    <buffer>  <silent>  <LocalLeader>rmc   <C-C>:call Make_RunMake('clean')<CR>
	 noremap    <buffer>  <silent>  <LocalLeader>rma        :call Make_MakeArguments()<CR>
	inoremap    <buffer>  <silent>  <LocalLeader>rma   <C-C>:call Make_MakeArguments()<CR>
endfunction    " ----------  end of function CreateAdditionalMaps  ----------

if has("autocmd")
	autocmd FileType *
				\ if  &filetype == 'make'          |
				\ 	call s:CreateAdditionalMaps()  |
				\	endif
endif
"
"=====================================================================================
" vim: tabstop=2 shiftwidth=2 foldmethod=marker
