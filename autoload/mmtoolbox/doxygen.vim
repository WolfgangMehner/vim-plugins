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
"
" Parameters:
"   line1 - a line (string)
"   line2 - a line (string)
"   ...   - ...
" Returns:
"   -
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
"
" Parameters:
"   varname - name of the variable (string)
" Returns:
"   -
"
" If g:<varname> exists, assign:
"   s:<varname> = g:<varname>
"-------------------------------------------------------------------------------
function! s:GetGlobalSetting ( varname )
	if exists ( 'g:'.a:varname )
		exe 'let s:'.a:varname.' = g:'.a:varname
	endif
endfunction    " ----------  end of function s:GetGlobalSetting  ----------
"
"-------------------------------------------------------------------------------
" s:ImportantMsg : Print an important message.   {{{2
"
" Parameters:
"   line1 - a line (string)
"   line2 - a line (string)
"   ...   - ...
" Returns:
"   -
"-------------------------------------------------------------------------------
function! s:ImportantMsg ( ... )
	echohl Search
	echo join ( a:000, "\n" )
	echohl None
endfunction    " ----------  end of function s:ImportantMsg  ----------
"
"-------------------------------------------------------------------------------
" s:Question : Ask the user a yes/no question.   {{{2
"
" Parameters:
"   prompt    - prompt, shown to the user (string)
"   highlight - "normal" or "warning" (string, default "normal")
" Returns:
"   retval - the user input (integer)
"
" The possible values of 'retval' are:
"    1 - answer was yes ("y")
"    0 - answer was no ("n")
"   -1 - user aborted ("ESC" or "CTRL-C")
"-------------------------------------------------------------------------------
function! s:Question ( prompt, ... )
	"
	let ret = -2
	"
	" highlight prompt
	if a:0 == 0 || a:1 == 'normal'
		echohl Search
	elseif a:1 == 'warning'
		echohl Error
	else
		echoerr 'Unknown option : "'.a:1.'"'
		return
	end
	"
	" question
	echo a:prompt.' [y/n]: '
	"
	" answer: "y", "n", "ESC" or "CTRL-C"
	while ret == -2
		let c = nr2char( getchar() )
		"
		if c == "y"
			let ret = 1
		elseif c == "n"
			let ret = 0
		elseif c == "\<ESC>" || c == "\<C-C>"
			let ret = -1
		endif
	endwhile
	"
	" reset highlighting
	echohl None
	"
	return ret
endfunction    " ----------  end of function s:Question  ----------
"
"-------------------------------------------------------------------------------
" s:UserInput : Input using a highlighting prompt.   {{{2
"
" Parameters:
"   prompt - prompt, shown to the user (string)
"   text   - default reply (string)
"   compl  - type of completion, see :help command-completion (string, optional)
" Returns:
"   retval - the user input (string)
"
" Returns an empty string if the input procedure was aborted by the user.
"-------------------------------------------------------------------------------
function! s:UserInput ( prompt, text, ... )
	echohl Search                                        " highlight prompt
	call inputsave()                                     " preserve typeahead
	if a:0 == 0 || a:1 == ''
		let retval = input( a:prompt, a:text )             " read input
	else
		let retval = input( a:prompt, a:text, a:1 )        " read input (with completion)
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
let s:ConfigFile  = 'Doxyfile' 	 				" doxygen configuration file
let s:LogFile     = '.doxygen.log'
let s:WarningFile = '.doxygen.warn'
"
if s:MSWIN
	let s:Doxygen_Executable = 'C:\Program Files\Doxygen\bin\doxygen.exe'
else
	let s:Doxygen_Executable = 'doxygen'
endif
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
	command! -bang -nargs=? -complete=file DoxygenLogFile        :call mmtoolbox#doxygen#Property('<bang>'=='!'?'echo':'set','log-file',<q-args>)
	command! -bang -nargs=? -complete=file DoxygenWarningFile    :call mmtoolbox#doxygen#Property('<bang>'=='!'?'echo':'set','warning-file',<q-args>)
	command!       -nargs=* -complete=file Doxygen               :call mmtoolbox#doxygen#Run(<q-args>)
	command!       -nargs=0 -complete=file DoxygenGenerateConfig :call mmtoolbox#doxygen#GenerateConfig()
	command!       -nargs=0 -complete=file DoxygenEditConfig     :call mmtoolbox#doxygen#EditConfig()
	command!       -nargs=0 -complete=file DoxygenViewLog        :call mmtoolbox#doxygen#ViewLog()
	command!       -nargs=0                DoxygenWarnings       :call mmtoolbox#doxygen#Warnings()
	command!       -nargs=0                DoxygenHelp           :call mmtoolbox#doxygen#Help()
	command! -bang -nargs=0                DoxygenSettings       :call mmtoolbox#doxygen#Settings('<bang>'=='!')
else
	"
	" Disabled : Print why the script is disabled.   {{{3
	function! mmtoolbox#doxygen#Disabled ()
		let txt = "Doxygen tool not working:\n"
		if ! executable ( s:Doxygen_Executable )
			let txt .= "Doxygen not executable (".s:Doxygen_Executable.")\n"
			let txt .= "see :help toolbox-doxygen-config"
		else
			let txt .= "unknown reason\n"
			let txt .= "see :help toolbox-doxygen"
		endif
		call s:ImportantMsg ( txt )
		return
	endfunction    " ----------  end of function mmtoolbox#doxygen#Disabled  ----------
	" }}}3
	"
	command! -bang -nargs=* Doxygen          :call mmtoolbox#doxygen#Disabled()
	command!       -nargs=0 DoxygenHelp      :call mmtoolbox#doxygen#Help()
	command! -bang -nargs=0 DoxygenSettings  :call mmtoolbox#doxygen#Settings('<bang>'=='!')
	"
endif
"
" }}}2
"
"-------------------------------------------------------------------------------
" GetInfo : Initialize the script.   {{{1
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
	exe 'amenu '.a:root.'.&run\ Doxygen<Tab>:Doxygen            :Doxygen<CR>'
	exe 'amenu '.a:root.'.view\ &log<Tab>:DoxygenViewLog        :DoxygenViewLog<CR>'
	exe 'amenu '.a:root.'.view\ &warnings<Tab>:DoxygenWarnings  :DoxygenWarnings<CR>'
	"
	exe 'amenu '.a:root.'.-SEP01- <Nop>'
	"
	exe 'amenu '.a:root.'.&generate\ config\.<Tab>:DoxygenGenerateConfig  :DoxygenGenerateConfig<CR>'
	exe 'amenu '.a:root.'.edit\ &config\.<Tab>:DoxygenEditConfig          :DoxygenEditConfig<CR>'
	"
	exe 'amenu '.a:root.'.-SEP02- <Nop>'
	"
	exe 'amenu '.a:root.'.select\ config\.\ &file<Tab>:DoxygenConfigFile  :DoxygenConfigFile '
	exe 'amenu '.a:root.'.select\ log\ &file<Tab>:DoxygenLogFile          :DoxygenLogFile '
	exe 'amenu '.a:root.'.select\ warning\ &file<Tab>:DoxygenWarningFile  :DoxygenWarningFile '
	"
	exe 'amenu '.a:root.'.-SEP03- <Nop>'
	"
	exe 'amenu '.a:root.'.&help<Tab>:DoxygenHelp          :DoxygenHelp<CR>'
	exe 'amenu '.a:root.'.&settings<Tab>:DoxygenSettings  :DoxygenSettings<CR>'
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
	if a:key == 'enabled'
		let var = 's:Enabled'
	elseif a:key == 'config-file'
		let var = 's:ConfigFile'
	elseif a:key == 'log-file'
		let var = 's:LogFile'
	elseif a:key == 'warning-file'
		let var = 's:WarningFile'
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
		if val =~ '\S'
			let s:ConfigFile = fnamemodify( expand( val ), ":p" )
		elseif s:Question ( 'set config file to an empty string?' ) == 1
			let s:ConfigFile = ''
		endif
	elseif a:key == 'log-file'
		" expand replaces the escape sequences from the cmdline
		if val =~ '\S'
			let s:LogFile = fnamemodify( expand( val ), ":p" )
		elseif s:Question ( 'set local file to an empty string?' ) == 1
			let s:LogFile = ''
		endif
	elseif a:key == 'warning-file'
		" expand replaces the escape sequences from the cmdline
		if val =~ '\S'
			let s:WarningFile = fnamemodify( expand( val ), ":p" )
		elseif s:Question ( 'set warning file to an empty string?' ) == 1
			let s:WarningFile = ''
		endif
	else
		" action is 'set', but key is non of the above
		return s:ErrorMsg ( 'Doxygen : Option is read-only, can not set: '.a:key )
	endif
	"
endfunction    " ----------  end of function mmtoolbox#doxygen#Property  ----------
"
"-------------------------------------------------------------------------------
" Help : Plugin help.   {{{1
"-------------------------------------------------------------------------------
function! mmtoolbox#doxygen#Help ()
	try
		help toolbox-doxygen
	catch
		exe 'helptags '.s:plugin_dir.'/doc'
		help toolbox-doxygen
	endtry
endfunction    " ----------  end of function mmtoolbox#doxygen#Help  ----------
"
"-------------------------------------------------------------------------------
" Settings : Plugin settings.   {{{1
"-------------------------------------------------------------------------------
function! mmtoolbox#doxygen#Settings ( verbose )
	"
	if     s:MSWIN | let sys_name = 'Windows'
	elseif s:UNIX  | let sys_name = 'UNIX'
	else           | let sys_name = 'unknown' | endif
	"
	let doxygen_status = executable( s:Doxygen_Executable ) ? '<yes>' : '<no>'
	"
	let	txt = " Doxygen-Support settings\n\n"
				\ .'     plug-in installation :  toolbox on '.sys_name."\n"
				\ .'       doxygen executable :  '.s:Doxygen_Executable."\n"
				\ .'                > enabled :  '.doxygen_status."\n"
				\ .'            using toolbox :  version '.g:Toolbox_Version." by Wolfgang Mehner\n"
	if a:verbose
		let	txt .= "\n"
					\ .'       configuration file :  '.s:ConfigFile."\n"
					\ .'                 log file :  '.s:LogFile."\n"
					\ .'            warnings file :  '.s:WarningFile."\n"
	endif
	let txt .=
				\  "________________________________________________________________________________\n"
				\ ." Doxygen-Tool, Version ".g:Doxygen_Version." / Wolfgang Mehner / wolfgang-mehner@web.de\n\n"
	"
	echo txt
endfunction    " ----------  end of function mmtoolbox#doxygen#Settings  ----------
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
	let warn_log_file_configured = ''
	"
	if ! filereadable( s:ConfigFile )
		call s:ErrorMsg ( 'Doxygen : File not readable: '.s:ConfigFile )
	else
		let warn_log_file_configured = matchstr( readfile( s:ConfigFile ), '\s*WARN_LOGFILE\s*=\s*\S' )
		let warn_log_file_configured = matchstr( warn_log_file_configured, '\s*WARN_LOGFILE\s*=\s*\(["'']\?\)\zs.*\S\ze\1\s*$' )
	endif
	"
	if warn_log_file_configured != ''
		" use WARN_LOGFILE from now on?
		let warn_log_file_configured = fnamemodify( expand( warn_log_file_configured ), ":p" )
		if s:WarningFile != warn_log_file_configured
			if s:Question ( 'use the configured warning file from now on? ('.warn_log_file_configured.')' ) == 1
				call mmtoolbox#doxygen#Property ( 'set', 'warning-file', warn_log_file_configured )
			endif
		endif
		" the option WARN_LOGFILE is set, do not write s:WarningFile here
		silent exe ':!'.shellescape( s:Doxygen_Executable ).' '.cmdlinearg.' > '.shellescape( s:LogFile )
	else
		" write both the log and the warning file
		silent exe ':!'.shellescape( s:Doxygen_Executable ).' '.cmdlinearg.' 1> '.shellescape( s:LogFile ).' 2> '.shellescape( s:WarningFile )
	endif
	"
	lchdir -
	"
	" process the warnings
	call mmtoolbox#doxygen#Warnings ()
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
	exe ":!".shellescape( s:Doxygen_Executable ).' -g '.shellescape( doxyfile )
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
	exe 'split '.fnameescape( s:ConfigFile )
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
" Warnings : Send the warning file through QuickFix.   {{{1
"-------------------------------------------------------------------------------
function! mmtoolbox#doxygen#Warnings ()
	"
	silent exe 'update'   | " write source file if necessary
	cclose
	"
	" go to the directory of 's:ConfigFile', so that the standard for " 's:WarningFile' works
	exe	'lchdir '.fnameescape( fnamemodify( s:ConfigFile, ':p:h' ) )
	"
	" any errors?
	if getfsize( s:WarningFile ) > 0
		"
		" save the current settings
		let errorf_saved = &l:errorformat
		"
		" read the file and process the errors
		exe 'setlocal errorformat='.s:ErrorFormat
		"
		exe 'cfile '.fnameescape( s:WarningFile )
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
endfunction    " ----------  end of function mmtoolbox#doxygen#Warnings  ----------
" }}}1
"-------------------------------------------------------------------------------
"
" =====================================================================================
"  vim: foldmethod=marker
