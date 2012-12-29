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
	echo 'The plugin tools/c/doxygen.vim needs Vim version >= 7.'
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
"
"-------------------------------------------------------------------------------
" Modul setup.   {{{1
"-------------------------------------------------------------------------------
"
let s:MSWIN = has("win16") || has("win32")   || has("win64")     || has("win95")
let s:UNIX	= has("unix")  || has("macunix") || has("win32unix")
"
let s:SettingsEscChar = ' |"\'
if s:MSWIN
	let s:FilenameEscChar = ''
else
	let s:FilenameEscChar = ' \%#[]'
endif
"
let s:ConfigFile = 'Doxyfile' 	 				" doxygen configuration file
let s:LogFile    = '.doxygen.log'
let s:ErrorFile  = '.doxygen.errors'
"
let s:Doxygen_Executable = 'doxygen'
"
call s:GetGlobalSetting ( 'Doxygen_Executable' )
"
let s:Enabled = 1
"
if ! executable ( s:Doxygen_Executable )
	let s:Enabled = 0
endif
"
let s:ErrorFormat = escape( '%f:%l: %m', s:SettingsEscChar )
"
" custom commands {{{2
"
if s:Enabled == 1
	command!       -nargs=? -complete=file DoxygenConfigFile :call mmtoolbox#common#doxygen#Property('config-file','<args>')
	command!       -nargs=? -complete=file DoxygenLogFile    :call mmtoolbox#common#doxygen#Property('log-file','<args>')
	command!       -nargs=? -complete=file DoxygenErrorFile  :call mmtoolbox#common#doxygen#Property('error-file','<args>')
	command!       -nargs=? -complete=file DoxygenEditConfig :call mmtoolbox#common#doxygen#EditConfig()
	command!       -nargs=0                DoxygenErrors     :call mmtoolbox#common#doxygen#Errors()
else
	"
	" Disabled : Print why the script is disabled.   {{{3
	function! mmtoolbox#common#doxygen#Disabled ()
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
	endfunction    " ----------  end of function mmtoolbox#common#doxygen#Disabled  ----------
	" }}}3
	"
	command! -nargs=* DoxygenHelp :call mmtoolbox#common#doxygen#Disabled()
	"
endif
"
" }}}2
"
"-------------------------------------------------------------------------------
" Init : Initialize the script.   {{{1
"-------------------------------------------------------------------------------
function! mmtoolbox#common#doxygen#Init ()
	if s:Enabled
		return [ 'Doxygen', g:Doxygen_Version ]
	else
		return [ 'Doxygen', g:Doxygen_Version, 'disabled' ]
	endif
endfunction    " ----------  end of function mmtoolbox#common#doxygen#Init  ----------
"
"-------------------------------------------------------------------------------
" AddMaps : Add maps.   {{{1
"-------------------------------------------------------------------------------
function! mmtoolbox#common#doxygen#AddMaps ()
endfunction    " ----------  end of function mmtoolbox#common#doxygen#AddMaps  ----------
"
"-------------------------------------------------------------------------------
" AddMenu : Add menus.   {{{1
"-------------------------------------------------------------------------------
function! mmtoolbox#common#doxygen#AddMenu ( root, mapleader )
	"
	" TODO
	"
	exe 'amenu '.a:root.'.&error\ file<Tab>:DoxygenErrorFile  :DoxygenErrorFile '
	"
endfunction    " ----------  end of function mmtoolbox#common#doxygen#AddMenu  ----------
"
"-------------------------------------------------------------------------------
" Property : Various settings.   {{{1
"-------------------------------------------------------------------------------
function! mmtoolbox#common#doxygen#Property ( key, val )
	"
	" check argument
	if a:key == 'config-file'    | let var = 's:ConfigFile'
	elseif a:key == 'log-file'   | let var = 's:LogFile'
	elseif a:key == 'error-file' | let var = 's:ErrorFile'
	else
		call s:ErrorMsg ( 'Doxygen : Unknown option: '.a:key )
		return
	endif
	"
	" get or set
	if a:val == '' | exe 'echo '.var
	else           | exe 'let '.var.' = fnamemodify( expand( a:val ), ":p" )'
	endif
	"
endfunction    " ----------  end of function mmtoolbox#common#doxygen#Property  ----------
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
function! mmtoolbox#common#doxygen#GenerateConfig ()
	" TODO
endfunction    " ----------  end of function mmtoolbox#common#doxygen#GenerateConfig  ----------
"
"-------------------------------------------------------------------------------
" EditConfig : Edit the Doxygen configuration file.   {{{1
"-------------------------------------------------------------------------------
function! mmtoolbox#common#doxygen#EditConfig ()
	" TODO: do some checks first?
	exe 'e '.escape( s:ConfigFile, s:FilenameEscChar )
endfunction    " ----------  end of function mmtoolbox#common#doxygen#EditConfig  ----------
"
"-------------------------------------------------------------------------------
" Run : Run Doxygen.   {{{1
"-------------------------------------------------------------------------------
function! mmtoolbox#common#doxygen#Run ( args, cmake_only )
	" TODO
endfunction    " ----------  end of function mmtoolbox#common#doxygen#Run  ----------
"
"-------------------------------------------------------------------------------
" Errors : Send error file through QuickFix.   {{{1
"-------------------------------------------------------------------------------
function! mmtoolbox#common#doxygen#Errors ()
	"
	silent exe 'update'   | " write source file if necessary
	cclose
	"
	" any errors?
	if getfsize( escape ( s:ErrorFile, s:FilenameEscChar ) ) > 0
		"
		" save the current settings
		let errorf_saved = &l:errorformat
		"
		" read the file and process the errors
		exe	'setlocal errorformat='.s:ErrorFormat
		"
		exe	':cfile '.escape( s:ErrorFile, s:FilenameEscChar )
		"
		" restore the old settings
		exe 'setlocal errorformat='.escape( errorf_saved, s:SettingsEscChar )
		"
		botright cwindow
	else
		echo "Doxygen : no warnings/errors"
	endif
	"
endfunction    " ----------  end of function mmtoolbox#common#doxygen#Errors  ----------
" }}}1
"
" =====================================================================================
"  vim: foldmethod=marker
