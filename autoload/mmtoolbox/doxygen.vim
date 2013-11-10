"===============================================================================
"
"          File:  doxygen.vim
" 
"   Description:  Part of the C-Support toolbox.
"
"                 Vim/gVim integration of Doxygen.
"
"                 See help file toolboxdoxygen.txt .
" 
"   VIM Version:  7.0+
"        Author:  Wolfgang Mehner, wolfgang-mehner@web.de
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
"
"-------------------------------------------------------------------------------
" s:UserInput : Input using a highlighting prompt.   {{{2
"-------------------------------------------------------------------------------
function! s:UserInput ( promp, text, ... )
	echohl Search                                        " highlight prompt
	call inputsave()                                     " preserve typeahead
	if a:0 == 0 || a:1 == ''
		let retval = input( a:promp, a:text )              " read input
	else
		let retval = input( a:promp, a:text, a:1 )         " read input (with completion)
	end
	call inputrestore()                                  " restore typeahead
	echohl None                                          " reset highlighting
	let retval = substitute( retval, '^\s\+', '', '' )   " remove leading whitespaces
	let retval = substitute( retval, '\s\+$', '', '' )   " remove trailing whitespaces
	return retval
endfunction    " ----------  end of function s:UserInput  ----------
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
if s:MSWIN
	"
	"-------------------------------------------------------------------------------
	" MS Windows
	"-------------------------------------------------------------------------------
	"
	let s:plugin_dir = substitute( expand('<sfile>:p:h:h:h'), '\\', '/', 'g' )
	"
else
	"
	"-------------------------------------------------------------------------------
	" Linux/Unix
	"-------------------------------------------------------------------------------
	"
	let s:plugin_dir = expand('<sfile>:p:h:h:h')
	"
endif
"
" settings   {{{2
"
let s:ConfigFile = 'Doxyfile' 	 				" doxygen configuration file
let s:LogFile    = '.doxygen.log'
let s:ErrorFile  = '.doxygen.log'
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
	command! -bang -nargs=? -complete=file DoxygenConfigFile     :call mmtoolbox#doxygen#Property('<bang>'=='!'?'echo':'set','config-file',<q-args>)
	command! -bang -nargs=? -complete=file DoxygenErrorFile      :call mmtoolbox#doxygen#Property('<bang>'=='!'?'echo':'set','error-file',<q-args>)
	command! -bang -nargs=? -complete=file DoxygenLogFile        :call mmtoolbox#doxygen#Property('<bang>'=='!'?'echo':'set','log-file',<q-args>)
	command!       -nargs=* -complete=file Doxygen               :call mmtoolbox#doxygen#Run(<q-args>)
	command!       -nargs=0 -complete=file DoxygenGenerateConfig :call mmtoolbox#doxygen#GenerateConfig()
	command!       -nargs=0 -complete=file DoxygenEditConfig     :call mmtoolbox#doxygen#EditConfig()
	command!       -nargs=0 -complete=file DoxygenViewLog        :call mmtoolbox#doxygen#ViewLog()
	command!       -nargs=0                DoxygenErrors         :call mmtoolbox#doxygen#Errors()
	command!       -nargs=0                DoxygenHelp           :call mmtoolbox#doxygen#Help()
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
function! mmtoolbox#doxygen#Property ( mode, key, ... )
	"
	" check the mode
	if a:mode !~ 'echo\|get\|set'
		return s:ErrorMsg ( 'Doxygen : Unknown mode: '.a:mode )
	endif
	"
	" check 3rd argument for 'set'
	if a:mode == 'set'
		if a:0 == 0
			return s:ErrorMsg ( 'Doxygen : Not enough arguments for mode "set".' )
		endif
		let val = a:1
	endif
	"
	" check the key
	if a:key == 'config-file'
		let var = 's:ConfigFile'
	elseif a:key == 'error-file'
		let var = 's:ErrorFile'
	elseif a:key == 'log-file'
		let var = 's:LogFile'
	else
		return s:ErrorMsg ( 'Doxygen : Unknown option: '.a:key )
	endif
	"
	" perform the action
	if a:mode == 'echo'
		exe 'echo '.var
		return
	elseif a:mode == 'get'
		exe 'return '.var
	elseif a:key == 'config-file'
		" expand replaces the escape sequences from the cmdline
		if val == '' | let s:ConfigFile = ''
		else         | let s:ConfigFile = fnamemodify( expand( val ), ":p" )
		endif
	elseif a:key == 'error-file'
		" expand replaces the escape sequences from the cmdline
		if val == '' | let s:ErrorFile = ''
		else         | let s:ErrorFile = fnamemodify( expand( val ), ":p" )
		endif
	elseif a:key == 'log-file'
		" expand replaces the escape sequences from the cmdline
		if val == '' | let s:LogFile = ''
		else         | let s:LogFile = fnamemodify( expand( val ), ":p" )
		endif
	endif
	"
endfunction    " ----------  end of function mmtoolbox#doxygen#Property  ----------
"
"-------------------------------------------------------------------------------
" Modul setup (abort early?).   {{{1
"-------------------------------------------------------------------------------
if s:Enabled == 0
	finish
endif
"
"-------------------------------------------------------------------------------
" Run : Run Doxygen.   {{{1
"-------------------------------------------------------------------------------
function! mmtoolbox#doxygen#Run ( args )
	"
	silent exe 'update'   | " write source file if necessary
	cclose
	"
	" arguments
	if a:args == ''
		if ! filereadable( s:ConfigFile )
			" :TODO:27.10.2013 19:09:WM: file not readable?
			return s:ErrorMsg ( 'Doxygen : File not readable: '.s:ConfigFile )
		endif
		"
		let cmdlinearg = shellescape ( s:ConfigFile )
	else
		let cmdlinearg = a:args
	endif
	" :TODO:27.10.2013 19:28:WM: 'cmdlinearg' is not correctly escaped for use under Windows
	"
	exe	'lchdir '.fnameescape( fnamemodify( s:ConfigFile, ':p:h' ) )
	"
	"echomsg ' ... doxygen running ... '
	silent exe ':!'.s:Doxygen_Executable.' '.cmdlinearg.' &> '.s:LogFile
	"
	lchdir -
	"
	" process the errors
	call mmtoolbox#doxygen#Errors ()
	"
endfunction    " ----------  end of function mmtoolbox#doxygen#Run  ----------
"
"-------------------------------------------------------------------------------
" GenerateConfig : Generate a Doxygen configuration file.   {{{1
"-------------------------------------------------------------------------------
function! mmtoolbox#doxygen#GenerateConfig ()
	" pick a location
	if 0   " has('browse')
		let doxyfile = browse ( 1, 'generate a doxygen configuration file', '.', 'Doxyfile' )
	else
		let doxyfile = s:UserInput ( 'generate a doxygen configuration file ', 'Doxyfile', 'file' )
	endif
	"
	" check the result
	if doxyfile == ''
		return
	endif
	"
	" file already exists
	if filereadable ( doxyfile )
		if s:UserInput ( 'Config file "'.doxyfile.'" already exists. Overwrite [y/n] : ', 'n' ) != 'y'
			return
		endif
	endif
	"
	" generate the file and save it name
	exe ":!".s:Doxygen_Executable.' -g '.shellescape( doxyfile )
	if ! v:shell_error
		call mmtoolbox#doxygen#Property ( 'set', 'config-file', doxyfile )
	endif
endfunction    " ----------  end of function mmtoolbox#doxygen#GenerateConfig  ----------
"
"-------------------------------------------------------------------------------
" EditConfig : Edit the Doxygen configuration file.   {{{1
"-------------------------------------------------------------------------------
function! mmtoolbox#doxygen#EditConfig ()
	if ! filereadable ( s:ConfigFile )
		" :TODO:27.10.2013 18:49:WM: call mmtoolbox#doxygen#GenerateConfig
		return s:ErrorMsg ( 'Doxygen : File not readable: '.s:ConfigFile )
	endif
	"
	exe 'edit '.fnameescape( s:ConfigFile )
endfunction    " ----------  end of function mmtoolbox#doxygen#EditConfig  ----------
"
"-------------------------------------------------------------------------------
" ViewLog : Edit the Doxygen configuration file.   {{{1
"-------------------------------------------------------------------------------
function! mmtoolbox#doxygen#ViewLog ()
	"
	" go to the directory of 's:ConfigFile', so that the standard for 's:LogFile' works
	exe	'lchdir '.fnameescape( fnamemodify( s:ConfigFile, ':p:h' ) )
	"
	if ! filereadable ( s:LogFile )
		return s:ErrorMsg ( 'Doxygen : File not readable: '.s:LogFile )
	endif
	"
	let logfile = fnamemodify( s:LogFile, ":p" )
	"
	lchdir -
	"
	exe 'sview '.fnameescape( logfile )
endfunction    " ----------  end of function mmtoolbox#doxygen#ViewLog  ----------
"
"-------------------------------------------------------------------------------
" Errors : Send error file through QuickFix.   {{{1
"-------------------------------------------------------------------------------
function! mmtoolbox#doxygen#Errors ()
	"
	silent exe 'update'   | " write source file if necessary
	cclose
	"
	" go to the directory of 's:ConfigFile', so that the standard for 's:ErrorFile' works
	exe	'lchdir '.fnameescape( fnamemodify( s:ConfigFile, ':p:h' ) )
	"
	" any errors?
	if getfsize( s:ErrorFile ) > 0
		"
		" save the current settings
		let errorf_saved = &l:errorformat
		"
		" read the file and process the errors
		exe 'setlocal errorformat='.s:ErrorFormat
		"
		exe 'cfile '.fnameescape( s:ErrorFile )
		"
		" restore the old settings
		exe 'setlocal errorformat='.escape( errorf_saved, s:SettingsEscChar )
		"
		botright cwindow
	else
		echo "Doxygen : no warnings/errors"
	endif
	"
	lchdir -
	"
endfunction    " ----------  end of function mmtoolbox#doxygen#Errors  ----------
"
"-------------------------------------------------------------------------------
" Help : Plugin help.   {{{1
"-------------------------------------------------------------------------------
function! mmtoolbox#doxygen#Help ()
	try
		echo 'Help dir: '.s:plugin_dir.'/doc'
		help doxygen-tool
	catch
		exe 'helptags '.s:plugin_dir.'/doc'
		help doxygen-tool
	endtry
endfunction    " ----------  end of function mmtoolbox#doxygen#Help  ----------
" }}}1
"-------------------------------------------------------------------------------
"
" =====================================================================================
"  vim: foldmethod=marker
