"===============================================================================
"
"          File:  doxygen.vim
" 
"   Description:  Part of the C-Support toolbox.
"
"                 Vim/gVim integration of Doxygen.
"
"                 See help file csupport_doxygen.txt .
" 
"   VIM Version:  7.0+
"        Author:  Dr.-Ing. Fritz Mehner, mehner@fh-swf.de
"                 Wolfgang Mehner, wolfgang-mehner@web.de
"  Organization:  
"       Version:  see variable g:Doxygen_Version below
"       Created:  10.06.2012
"      Revision:  ---
"       License:  Copyright (c) 2012, Wolfgang Mehner
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
	echo 'The plugin mmtoolbox/doxygen.vim needs Vim version >= 7.'
	echohl None
  finish
endif
"
" prevent duplicate loading
" need compatible
if &cp || ( exists('g:Doxygen_Version') && ! exists('g:Doxygen_DevelopmentOverwrite') )
	finish
endif
let g:Doxygen_Version= '0.9'     " version number of this script; do not change
"
"-------------------------------------------------------------------------------
" Auxiliary functions.   {{{1
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
let s:ConfigFile = 'Doxyfile' 	 				" doxygen configuration file
let s:LogFile    = '.doxygen.log'
let s:ErrorFile  = '.doxygen.errors'
"
let s:Doxygen_Executable = 'doxygen'
"
call s:GetGlobalSetting ( 'Doxygen_Executable' )
"
let s:ErrorFormat = escape( '%f:%l: %m', s:SettingsEscChar )
"
let s:Enabled = 1
"
" check Doxygen executable   {{{2
"
if ! executable ( s:Doxygen_Executable )
	let s:Enabled = 0
endif
"
" custom commands {{{2
"
if s:Enabled == 1
	command! -bang -nargs=? -complete=file DoxygenConfigFile :call mmtoolbox#doxygen#Property('config-file<bang>',<q-args>)
	command! -bang -nargs=? -complete=file DoxygenLogFile    :call mmtoolbox#doxygen#Property('log-file<bang>',<q-args>)
	command! -bang -nargs=? -complete=file DoxygenErrorFile  :call mmtoolbox#doxygen#Property('error-file<bang>',<q-args>)
	command!       -nargs=? -complete=file DoxygenEditConfig :call mmtoolbox#doxygen#EditConfig()
	command!       -nargs=0                DoxygenErrors     :call mmtoolbox#doxygen#Errors()
else
	"
	" Disabled : Print why the script is disabled.   {{{3
	function! mmtoolbox#doxygen#Disabled ()
		let txt = "Doxygen tool not working:\n"
		if ! executable ( s:Doxygen_Executable )
			let txt .= "Doxygen not executable (".s:Doxygen_Executable.")"
		else
			let txt .= "unknown reason"
		endif
		echohl Search
		echo txt
		echohl None
		return
	endfunction    " ----------  end of function mmtoolbox#doxygen#Disabled  ----------
	" }}}3
	"
	command! -nargs=* DoxygenHelp :call mmtoolbox#doxygen#Disabled()
	"
endif
"
" }}}2
"
"-------------------------------------------------------------------------------
" Init : Initialize the script.   {{{1
"-------------------------------------------------------------------------------
function! mmtoolbox#doxygen#GetInfo ()
	if s:Enabled
		return [ 'Doxygen', g:Doxygen_Version ]
	else
		return [ 'Doxygen', g:Doxygen_Version, 'disabled' ]
	endif
endfunction    " ----------  end of function mmtoolbox#doxygen#GetInfo  ----------
"
"-------------------------------------------------------------------------------
" AddMaps : Add maps.   {{{1
"-------------------------------------------------------------------------------
function! mmtoolbox#doxygen#AddMaps ()
endfunction    " ----------  end of function mmtoolbox#doxygen#AddMaps  ----------
"
"-------------------------------------------------------------------------------
" AddMenu : Add menus.   {{{1
"-------------------------------------------------------------------------------
function! mmtoolbox#doxygen#AddMenu ( root, esc_mapl )
	"
	" TODO
	"
	exe 'amenu '.a:root.'.&error\ file<Tab>:DoxygenErrorFile  :DoxygenErrorFile '
	"
endfunction    " ----------  end of function mmtoolbox#doxygen#AddMenu  ----------
"
"-------------------------------------------------------------------------------
" Property : Various settings.   {{{1
"-------------------------------------------------------------------------------
function! mmtoolbox#doxygen#Property ( key, val )
	"
	" check argument
	if a:key == 'config-file!'
		echo s:ConfigFile
	elseif a:key == 'config-file'
		" expand replaces the escape sequences from the cmdline
		if a:val == '' | let s:ConfigFile = ''
		else           | let s:ConfigFile = fnamemodify( expand( a:val ), ":p" )
		endif
	elseif a:key == 'log-file!'
		echo s:LogFile
	elseif a:key == 'log-file'
		" expand replaces the escape sequences from the cmdline
		if a:val == '' | let s:LogFile = ''
		else           | let s:LogFile = fnamemodify( expand( a:val ), ":p" )
		endif
	elseif a:key == 'error-file!'
		echo s:ErrorFile
	elseif a:key == 'error-file'
		" expand replaces the escape sequences from the cmdline
		if a:val == '' | let s:ErrorFile = ''
		else           | let s:ErrorFile = fnamemodify( expand( a:val ), ":p" )
		endif
	else
		call s:ErrorMsg ( 'Doxygen : Unknown option: '.a:key )
		return
	endif
	"
endfunction    " ----------  end of function mmtoolbox#doxygen#Property  ----------
"
"-------------------------------------------------------------------------------
" Modul setup.   {{{1
"-------------------------------------------------------------------------------
if s:Enabled == 0
	finish
endif
"
"-------------------------------------------------------------------------------
" GenerateConfig : Generate a Doxygen configuration file.   {{{1
"-------------------------------------------------------------------------------
function! mmtoolbox#doxygen#GenerateConfig ()
	" TODO
endfunction    " ----------  end of function mmtoolbox#doxygen#GenerateConfig  ----------
"
"-------------------------------------------------------------------------------
" EditConfig : Edit the Doxygen configuration file.   {{{1
"-------------------------------------------------------------------------------
function! mmtoolbox#doxygen#EditConfig ()
	" TODO: do some checks first?
	exe 'e '.fnameescape( s:ConfigFile )
endfunction    " ----------  end of function mmtoolbox#doxygen#EditConfig  ----------
"
"-------------------------------------------------------------------------------
" Run : Run Doxygen.   {{{1
"-------------------------------------------------------------------------------
function! mmtoolbox#doxygen#Run ( args, cmake_only )
	" TODO
endfunction    " ----------  end of function mmtoolbox#doxygen#Run  ----------
"
"-------------------------------------------------------------------------------
" Errors : Send error file through QuickFix.   {{{1
"-------------------------------------------------------------------------------
function! mmtoolbox#doxygen#Errors ()
	"
	silent exe 'update'   | " write source file if necessary
	cclose
	"
	" any errors?
	if getfsize( s:ErrorFile ) > 0
		"
		" save the current settings
		let errorf_saved = &l:errorformat
		"
		" read the file and process the errors
		exe	'setlocal errorformat='.s:ErrorFormat
		"
		exe	'cfile '.fnameescape( s:ErrorFile )
		"
		" restore the old settings
		exe 'setlocal errorformat='.escape( errorf_saved, s:SettingsEscChar )
		"
		botright cwindow
	else
		echo "Doxygen : no warnings/errors"
	endif
	"
endfunction    " ----------  end of function mmtoolbox#doxygen#Errors  ----------
" }}}1
"-------------------------------------------------------------------------------
"
" =====================================================================================
"  vim: foldmethod=marker
