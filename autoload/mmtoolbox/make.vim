"===============================================================================
"
"          File:  make.vim
" 
"   Description:  Part of the C-Support toolbox.
"
"                 Vim/gVim integration of Make.
"
"                 See help file csupport_make.txt .
" 
"   VIM Version:  7.0+
"        Author:  Dr.-Ing. Fritz Mehner, mehner.fritz@fh-swf.de
"                 Wolfgang Mehner, wolfgang-mehner@web.de
"  Organization:  
"       Version:  see variable g:Make_Version below
"       Created:  06.05.2013
"      Revision:  ---
"       License:  Copyright (c) 2013, Fritz Mehner
"                 This program is free software; you can redistribute it and/or
"                 modify it under the terms of the GNU General Public License as
"                 published by the Free Software Foundation, version 2 of the
"                 License.
"                 This program is distributed in the hope that it will be
"                 useful, but WITHOUT ANY WARRANTY; without even the implied
"                 warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
"                 PURPOSE.
"                 See the GNU General Public License version 2 for more details.
"===============================================================================
"
"-------------------------------------------------------------------------------
" Basic checks.   {{{1
"-------------------------------------------------------------------------------
"
" need at least 7.0
if v:version < 700
	echohl WarningMsg
	echo 'The plugin mmtoolbox/make.vim needs Vim version >= 7.'
	echohl None
	finish
endif
"
" prevent duplicate loading
" need compatible
if &cp || ( exists('g:Make_Version') && ! exists('g:Make_DevelopmentOverwrite') )
	finish
endif
let g:Make_Version= '0.9'     " version number of this script; do not change
"
"-------------------------------------------------------------------------------
" Auxiliary functions   {{{1
"-------------------------------------------------------------------------------
"
"-------------------------------------------------------------------------------
" s:ErrorMsg : Print an error message.   {{{2
"-------------------------------------------------------------------------------
function! s:ErrorMsg ( ... )
	echohl WarningMsg
	for line in a:000
		echomsg line
	endfor
	echohl None
endfunction    " ----------  end of function s:ErrorMsg  ----------
"
"-------------------------------------------------------------------------------
" s:GetGlobalSetting : Get a setting from a global variable.   {{{2
"-------------------------------------------------------------------------------
function! s:GetGlobalSetting ( varname )
	if exists ( 'g:'.a:varname )
		exe 'let s:'.a:varname.' = g:'.a:varname
	endif
endfunction    " ----------  end of function s:GetGlobalSetting  ----------
" }}}2
"-------------------------------------------------------------------------------
"
"-------------------------------------------------------------------------------
" Modul setup.   {{{1
"-------------------------------------------------------------------------------
"
" platform specifics   {{{2
"
let s:MSWIN = has("win16") || has("win32")   || has("win64")     || has("win95")
let s:UNIX	= has("unix")  || has("macunix") || has("win32unix")
"
let s:SettingsEscChar = ' |"\'
"
" settings   {{{2
"
let s:Makefile    = ''
let s:CmdLineArgs = ''
"
let s:Make_Executable = 'make'
"
call s:GetGlobalSetting ( 'Make_Executable' )
"
let s:Enabled = 1
"
" check make executable   {{{2
"
if ! executable ( s:Make_Executable )
	let s:Enabled = 0
endif
"
" custom commands {{{2
"
if s:Enabled == 1
	command! -bang -nargs=? -complete=file MakeFile          :call mmtoolbox#make#Property('makefile<bang>',<q-args>)
	command! -bang -nargs=* -complete=file MakeCmdlineArgs   :call mmtoolbox#make#Property('cmdline-args<bang>',<q-args>)
	command!       -nargs=* -complete=file Make              :call mmtoolbox#make#Run(<q-args>)
else
	"
	" Disabled : Print why the script is disabled.   {{{3
	function! mmtoolbox#make#Disabled ()
		let txt = "Make tool not working:\n"
		if ! executable ( s:Make_Executable )
			let txt .= "make not executable (".s:Make_Executable.")"
		else
			let txt .= "unknown reason"
		endif
		echohl Search
		echo txt
		echohl None
		return
	endfunction    " ----------  end of function mmtoolbox#make#Disabled  ----------
	" }}}3
	"
	command! -nargs=* MakeHelp :call mmtoolbox#make#Disabled()
	"
endif
"
" }}}2
"
"-------------------------------------------------------------------------------
" Init : Initialize the script.   {{{1
"-------------------------------------------------------------------------------
function! mmtoolbox#make#Init ()
	if s:Enabled
		return [ 'Make', g:Make_Version ]
	else
		return [ 'Make', g:Make_Version, 'disabled' ]
	endif
endfunction    " ----------  end of function mmtoolbox#make#Init  ----------
"
"-------------------------------------------------------------------------------
" AddMaps : Add maps.   {{{1
"-------------------------------------------------------------------------------
function! mmtoolbox#make#AddMaps ()
	"
	 noremap  <buffer>  <silent>  <LocalLeader>rm       :Make<CR>
	inoremap  <buffer>  <silent>  <LocalLeader>rm  <C-C>:Make<CR>
	"
endfunction    " ----------  end of function mmtoolbox#make#AddMaps  ----------
"
"-------------------------------------------------------------------------------
" AddMenu : Add menus.   {{{1
"-------------------------------------------------------------------------------
function! mmtoolbox#make#AddMenu ( root, esc_mapl )
	"
	exe 'amenu '.a:root.'.run\ &make<Tab>:Make           :Make '
	exe 'amenu '.a:root.'.make\ &clean<Tab>:Make\ clean  :Make clean<CR>'
	exe 'amenu '.a:root.'.make\ &doc<Tab>:Make\ doc      :Make doc<CR>'
	"
	exe 'amenu '.a:root.'.-Sep01- <Nop>'
	"
	exe 'amenu '.a:root.'.make&file<Tab>:MakeFile  :MakeFile '
	"
endfunction    " ----------  end of function mmtoolbox#make#AddMenu  ----------
"
"-------------------------------------------------------------------------------
" Property : Various settings.   {{{1
"-------------------------------------------------------------------------------
function! mmtoolbox#make#Property ( key, val )
	"
	" check argument
	if a:key == 'makefile!'
		echo s:Makefile
	elseif a:key == 'makefile'
		" expand replaces the escape sequences from the cmdline
		if a:val == '' | let s:Makefile = ''
		else           | let s:Makefile = fnamemodify( expand( a:val ), ":p" )
		endif
	elseif a:key == 'cmdline-args!'
		echo s:CmdLineArgs
	elseif a:key == 'cmdline-args'
		let s:CmdLineArgs = a:val
	else
		call s:ErrorMsg ( 'Make : Unknown option: '.a:key )
		return
	endif
	"
endfunction    " ----------  end of function mmtoolbox#make#Property  ----------
"
"-------------------------------------------------------------------------------
" Modul setup.   {{{1
"-------------------------------------------------------------------------------
if s:Enabled == 0
	finish
endif
"
"-------------------------------------------------------------------------------
" Run : Run make.   {{{1
"-------------------------------------------------------------------------------
function! mmtoolbox#make#Run ( args )
	"
	silent exe 'update'   | " write source file if necessary
	cclose
	"
	" arguments
	if a:args == '' | let cmdlinearg = s:CmdLineArgs
	else            | let cmdlinearg = a:args
	endif
	" :TODO:18.08.2013 21:45:WM: 's:CmdLineArgs' is not correctly escaped for use under Windows
	"
	" run make
	if s:Makefile == ''
		exe 'make '.cmdlinearg
	else
		exe 'lchdir '.fnameescape( fnamemodify( s:Makefile, ':p:h' ) )
		"
		exe 'make -f '.shellescape( s:Makefile ).' '.cmdlinearg
		"
		lchdir -
	endif
	"
	botright cwindow
	"
endfunction    " ----------  end of function mmtoolbox#make#Run  ----------
" }}}1
"-------------------------------------------------------------------------------
"
" :TODO:19.08.2013 09:01:WM: menus and maps (escaped mapleader!)
" :TODO:19.08.2013 09:01:WM: maps for filetype 'make'
"
" =====================================================================================
"  vim: foldmethod=marker
