"===============================================================================
"
"          File:  helloworld.vim
" 
"   Description:  Part of the C-Support toolbox.
"
"                 Small example for a tool, which may serve as a template for
"                 your own tool.
"
"                 See help file TODO.txt .
" 
"   VIM Version:  7.0+
"        Author:  TODO
"  Organization:  
"       Version:  see variable g:HelloWorld_Version below
"       Created:  TO.DO.TODO
"      Revision:  ---
"       License:  Copyright (c) TODO, TODO
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
	echo 'The plugin mmtoolbox/helloworld.vim needs Vim version >= 7.'
	echohl None
	finish
endif
"
" prevent duplicate loading
" need compatible
if &cp || exists('g:HelloWorld_Version')
	finish
endif
let g:HelloWorld_Version= '1.0'     " version number of this script; do not change
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
let s:MSWIN = has("win16") || has("win32")   || has("win64")     || has("win95")
let s:UNIX	= has("unix")  || has("macunix") || has("win32unix")
"
let s:WorldAvailable = 1
"
"-------------------------------------------------------------------------------
" Init : Initialize the script.   {{{1
"-------------------------------------------------------------------------------
function! mmtoolbox#helloworld#GetInfo ()
	"
	" returns [ <prettyname>, <version>, <flag1>, ... ]
	"
	if s:WorldAvailable
		return [ 'Hello World', g:HelloWorld_Version ]
		" if you do not want to create a menu:
		" return [ 'Hello World', g:HelloWorld_Version, 'nomenu' ]
	else
		return [ 'Hello World', g:HelloWorld_Version, 'disabled' ]
	endif
endfunction    " ----------  end of function mmtoolbox#helloworld#GetInfo  ----------
"
"-------------------------------------------------------------------------------
" AddMaps : Add maps.   {{{1
"-------------------------------------------------------------------------------
function! mmtoolbox#helloworld#AddMaps ()
	"
	" create maps for the current buffer only
	"
	nmap <buffer> hi   :echo "Hello world!"<CR>'
	"
	" TODO
	"
endfunction    " ----------  end of function mmtoolbox#helloworld#AddMaps  ----------
"
"-------------------------------------------------------------------------------
" AddMenu : Add menus.   {{{1
"-------------------------------------------------------------------------------
function! mmtoolbox#helloworld#AddMenu ( root, esc_mapl )
	"
	" create menus using the given 'root'
	"
	exe 'amenu '.a:root.'.&hello\ world<TAB>'.a:esc_mapl.'hi   :echo "Hello world!"<CR>'
	"
	" TODO
	"
endfunction    " ----------  end of function mmtoolbox#helloworld#AddMenu  ----------
" }}}1
"-------------------------------------------------------------------------------
"
" =====================================================================================
"  vim: foldmethod=marker
