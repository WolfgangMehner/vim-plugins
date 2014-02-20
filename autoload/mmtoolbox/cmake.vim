"===============================================================================
"
"          File:  cmake.vim
" 
"   Description:  Part of the C-Support toolbox.
"
"                 Vim/gVim integration of CMake.
"
"                 See help file toolboxcmake.txt .
" 
"   VIM Version:  7.0+
"        Author:  Wolfgang Mehner, wolfgang-mehner@web.de
"  Organization:  
"       Version:  see variable g:CMake_Version below
"       Created:  28.12.2011
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
	echo 'The plugin mmtoolbox/cmake.vim needs Vim version >= 7.'
	echohl None
	finish
endif
"
" prevent duplicate loading
" need compatible
if &cp || ( exists('g:CMake_Version') && ! exists('g:CMake_DevelopmentOverwrite') )
	finish
endif
let g:CMake_Version= '0.9.1'     " version number of this script; do not change
"
"-------------------------------------------------------------------------------
" Auxiliary functions   {{{1
"-------------------------------------------------------------------------------
"
"-------------------------------------------------------------------------------
" s:ApplyDefaultSetting : Write default setting to a global variable.   {{{2
"
" Parameters:
"   varname - name of the variable (string)
"   value   - default value (string)
" Returns:
"   -
"
" If g:<varname> does not exists, assign:
"   g:<varname> = value
"-------------------------------------------------------------------------------
"
function! s:ApplyDefaultSetting ( varname, value )
	if ! exists ( 'g:'.a:varname )
		exe 'let g:'.a:varname.' = '.string( a:value )
	endif
endfunction    " ----------  end of function s:ApplyDefaultSetting  ----------
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
" s:Question : Ask the user a question.   {{{2
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
let s:ProjectDir    = '.'
let s:BuildLocation = '.'
"
if s:MSWIN
	let s:CMake_Executable = 'C:\Program Files\CMake\bin\cmake.exe'
else
	let s:CMake_Executable = 'cmake'
endif
let s:CMake_MakeTool   = 'make'
"
call s:GetGlobalSetting ( 'CMake_Executable' )
call s:GetGlobalSetting ( 'CMake_MakeTool' )
call s:ApplyDefaultSetting ( 'CMake_JumpToError', 'cmake' )
"
let s:Enabled = 1
"
" check executables   {{{2
"
if ! executable ( s:CMake_Executable ) || ! executable ( s:CMake_MakeTool )
	let s:Enabled = 0
endif
"
" error formats {{{2
"
" error format for CMake
let s:ErrorFormat_CMake = escape(
			\  '%-DDIR : %f,%-XENDDIR : %f,'
			\ .'%-G,'
			\ .'%+G-- %.%#,'
			\ .'%E%>CMake Error at %f:%l (%[%^)]%#):,'
			\ .'%Z  %m,'
			\ .'%E%>CMake Error: Error in cmake code at,'
			\ .'%C%>%f:%l:,'
			\ .'%Z%m,'
			\ .'%E%>CMake Error in %.%#:,'
			\ .'%C%>  %m,'
			\ .'%C%>,'
			\ .'%C%>    %f:%l (if),'
			\ .'%C%>,'
			\ .'%Z  %m,'
			\ , s:SettingsEscChar )
"
" error format for make, additional errors
let s:ErrorFormat_MakeAdditions = escape(
			\  '%-GIn file included from %f:%l:%.%#,'
			\ .'%-G%\s%\+from %f:%l:%.%#,'
			\ , s:SettingsEscChar )
"
" policy list {{{2
"
let s:Policies_Version = '2.8.12'
let s:Policies_List = [
			\ [ 'CMP0000', 'A minimum required CMake version must be specified.', '2.6.0' ],
			\ [ 'CMP0001', 'CMAKE_BACKWARDS_COMPATIBILITY should no longer be used.', '2.6.0' ],
			\ [ 'CMP0002', 'Logical target names must be globally unique.', '2.6.0' ],
			\ [ 'CMP0003', 'Libraries linked via full path no longer produce linker search paths.', '2.6.0' ],
			\ [ 'CMP0004', 'Libraries linked may not have leading or trailing whitespace.', '2.6.0' ],
			\ [ 'CMP0005', 'Preprocessor definition values are now escaped automatically.', '2.6.0' ],
			\ [ 'CMP0006', 'Installing MACOSX_BUNDLE targets requires a BUNDLE DESTINATION.', '2.6.0' ],
			\ [ 'CMP0007', 'list command no longer ignores empty elements.', '2.6.0' ],
			\ [ 'CMP0008', 'Libraries linked by full-path must have a valid library file name.', '2.6.1' ],
			\ [ 'CMP0009', 'FILE GLOB_RECURSE calls should not follow symlinks by default.', '2.6.2' ],
			\ [ 'CMP0010', 'Bad variable reference syntax is an error.', '2.6.3' ],
			\ [ 'CMP0011', 'Included scripts do automatic cmake_policy PUSH and POP.', '2.6.3' ],
			\ [ 'CMP0012', 'if() recognizes numbers and boolean constants.', '2.8.0' ],
			\ [ 'CMP0013', 'Duplicate binary directories are not allowed.', '2.8.0' ],
			\ [ 'CMP0014', 'Input directories must have CMakeLists.txt.', '2.8.0' ],
			\ [ 'CMP0015', 'link_directories() treats paths relative to the source dir.', '2.8.1' ],
			\ [ 'CMP0016', 'target_link_libraries() reports error if only argument is not a target.', '2.8.3' ],
			\ [ 'CMP0017', 'Prefer files from the CMake module directory when including from there.', '2.8.4' ],
			\ [ 'CMP0018', 'Ignore CMAKE_SHARED_LIBRARY_<Lang>_FLAGS variable.', '2.8.9' ],
			\ [ 'CMP0019', 'Do not re-expand variables in include and link information.', '2.8.11' ],
			\ [ 'CMP0020', 'Automatically link Qt executables to qtmain target on Windows.', '2.8.11' ],
			\ [ 'CMP0021', 'Fatal error on relative paths in INCLUDE_DIRECTORIES target property.', '2.8.12' ],
			\ [ 'CMP0022', 'INTERFACE_LINK_LIBRARIES defines the link interface.', '2.8.12' ],
			\ [ 'CMP0023', 'Plain and keyword target_link_libraries signatures cannot be mixed.', '2.8.12' ],
			\ [ 'CMP????', 'There might be more policies not mentioned here, since this list is not maintained automatically.', '?.?.?' ],
			\ ]
"
" custom commands {{{2
"
if s:Enabled == 1
	command! -bang -nargs=? -complete=file CMakeProjectDir    :call mmtoolbox#cmake#Property('<bang>'=='!'?'echo':'set','project-dir',<q-args>)
	command! -bang -nargs=? -complete=file CMakeBuildLocation :call mmtoolbox#cmake#Property('<bang>'=='!'?'echo':'set','build-dir',<q-args>)
	command! -bang -nargs=* -complete=file CMake              :call mmtoolbox#cmake#Run(<q-args>,'<bang>'=='!')
	command!       -nargs=? -complete=file CMakeHelpCommand   :call mmtoolbox#cmake#Help('command',<q-args>)
	command!       -nargs=? -complete=file CMakeHelpModule    :call mmtoolbox#cmake#Help('module',<q-args>)
	command!       -nargs=? -complete=file CMakeHelpPolicy    :call mmtoolbox#cmake#Help('policy',<q-args>)
	command!       -nargs=? -complete=file CMakeHelpProperty  :call mmtoolbox#cmake#Help('property',<q-args>)
	command!       -nargs=? -complete=file CMakeHelpVariable  :call mmtoolbox#cmake#Help('variable',<q-args>)
	command!       -nargs=0                CMakeHelp          :call mmtoolbox#cmake#HelpPlugin()
	command! -bang -nargs=0                CMakeSettings      :call mmtoolbox#cmake#Settings('<bang>'=='!')
else
	"
	" Disabled : Print why the script is disabled.   {{{3
	function! mmtoolbox#cmake#Disabled ()
		let txt = "CMake tool not working:\n"
		if ! executable ( s:CMake_Executable )
			let txt .= "CMake not executable (".s:CMake_Executable.")\n"
			let txt .= "see :help toolbox-cmake-config"
		elseif ! executable ( s:CMake_MakeTool )
			let txt .= "make tool not executable (".s:CMake_MakeTool.")\n"
			let txt .= "see :help toolbox-cmake-config"
		else
			let txt .= "unknown reason\n"
			let txt .= "see :help toolbox-cmake"
		endif
		call s:ImportantMsg ( txt )
		return
	endfunction    " ----------  end of function mmtoolbox#cmake#Disabled  ----------
	" }}}3
	"
	command! -bang -nargs=* CMake          :call mmtoolbox#cmake#Disabled()
	command!       -nargs=0 CMakeHelp      :call mmtoolbox#cmake#HelpPlugin()
	command! -bang -nargs=0 CMakeSettings  :call mmtoolbox#cmake#Settings('<bang>'=='!')
	"
endif
"
" }}}2
"
"-------------------------------------------------------------------------------
" GetInfo : Initialize the script.   {{{1
"-------------------------------------------------------------------------------
function! mmtoolbox#cmake#GetInfo ()
	if s:Enabled
		return [ 'CMake', g:CMake_Version ]
	else
		return [ 'CMake', g:CMake_Version, 'disabled' ]
	endif
endfunction    " ----------  end of function mmtoolbox#cmake#GetInfo  ----------
"
"-------------------------------------------------------------------------------
" AddMaps : Add maps.   {{{1
"-------------------------------------------------------------------------------
function! mmtoolbox#cmake#AddMaps ()
endfunction    " ----------  end of function mmtoolbox#cmake#AddMaps  ----------
"
"-------------------------------------------------------------------------------
" AddMenu : Add menus.   {{{1
"-------------------------------------------------------------------------------
function! mmtoolbox#cmake#AddMenu ( root, esc_mapl )
	"
	exe 'amenu '.a:root.'.run\ CMake<Tab>:CMake!   :CMake! '
	exe 'amenu '.a:root.'.&run\ make<Tab>:CMake    :CMake '
	"
	exe 'amenu '.a:root.'.-Sep01- <Nop>'
	"
	exe 'amenu '.a:root.'.project\ &directory<Tab>:CMakeProjectDir     :CMakeProjectDir '
	exe 'amenu '.a:root.'.build\ &location<Tab>:CMakeBuildLocation     :CMakeBuildLocation '
	"
	exe 'amenu '.a:root.'.-Sep02- <Nop>'
	"
	exe 'amenu '.a:root.'.help\ &commands<Tab>:CMakeHelpCommand    :CMakeHelpCommand<CR>'
	exe 'amenu '.a:root.'.help\ &modules<Tab>:CMakeHelpModule      :CMakeHelpModule<CR>'
	exe 'amenu '.a:root.'.help\ &policies<Tab>:CMakeHelpPolicy     :CMakeHelpPolicy<CR>'
	exe 'amenu '.a:root.'.help\ &property<Tab>:CMakeHelpProperty   :CMakeHelpProperty<CR>'
	exe 'amenu '.a:root.'.help\ &variables<Tab>:CMakeHelpVariable  :CMakeHelpVariable<CR>'
	"
	exe 'amenu '.a:root.'.-SEP03- <Nop>'
	"
	exe 'amenu '.a:root.'.&help<Tab>:CMakeHelp          :CMakeHelp<CR>'
	exe 'amenu '.a:root.'.&settings<Tab>:CMakeSettings  :CMakeSettings<CR>'
	"
endfunction    " ----------  end of function mmtoolbox#cmake#AddMenu  ----------
"
"-------------------------------------------------------------------------------
" Property : Various settings.   {{{1
"-------------------------------------------------------------------------------
function! mmtoolbox#cmake#Property ( mode, key, ... )
	"
	" check the mode
	if a:mode !~ 'echo\|get\|set'
		return s:ErrorMsg ( 'CMake : Unknown mode: '.a:mode )
	endif
	"
	" check 3rd argument for 'set'
	if a:mode == 'set'
		if a:0 == 0
			return s:ErrorMsg ( 'CMake : Not enough arguments for mode "set".' )
		endif
		let val = a:1
	endif
	"
	" check the key
	if a:key == 'enabled'
		let var = 's:Enabled'
	elseif a:key == 'project-dir'
		let var = 's:ProjectDir'
	elseif a:key == 'build-dir'
		let var = 's:BuildLocation'
	else
		return s:ErrorMsg ( 'CMake : Unknown option: '.a:key )
	endif
	"
	" perform the action
	if a:mode == 'echo'
		exe 'echo '.var
		return
	elseif a:mode == 'get'
		exe 'return '.var
	elseif a:key == 'project-dir'
		" expand replaces the escape sequences from the cmdline
		if val =~ '\S'
			let s:ProjectDir = fnamemodify( expand( val ), ":p" )
		elseif s:Question ( 'set project directory to an empty string?' ) == 1
			let s:ProjectDir = ''
		endif
	elseif a:key == 'build-dir'
		" expand replaces the escape sequences from the cmdline
		if val =~ '\S'
			let s:BuildLocation = fnamemodify( expand( val ), ":p" )
		elseif s:Question ( 'set build location to an empty string?' ) == 1
			let s:BuildLocation = ''
		endif
	else
		" action is 'set', but key is non of the above
		return s:ErrorMsg ( 'CMake : Option is read-only, can not set: '.a:key )
	endif
	"
endfunction    " ----------  end of function mmtoolbox#cmake#Property  ----------
"
"-------------------------------------------------------------------------------
" HelpPlugin : Plugin help.   {{{1
"-------------------------------------------------------------------------------
function! mmtoolbox#cmake#HelpPlugin ()
	try
		help toolbox-cmake
	catch
		exe 'helptags '.s:plugin_dir.'/doc'
		help toolbox-cmake
	endtry
endfunction    " ----------  end of function mmtoolbox#cmake#HelpPlugin  ----------
"
"-------------------------------------------------------------------------------
" Settings : Plugin settings.   {{{1
"-------------------------------------------------------------------------------
function! mmtoolbox#cmake#Settings ( verbose )
	"
	if     s:MSWIN | let sys_name = 'Windows'
	elseif s:UNIX  | let sys_name = 'UNIX'
	else           | let sys_name = 'unknown' | endif
	"
	let cmake_status = executable( s:CMake_Executable ) ? '<yes>' : '<no>'
	let make_status  = executable( s:CMake_MakeTool   ) ? '<yes>' : '<no>'
	"
	let	txt = " CMake-Support settings\n\n"
				\ .'     plug-in installation :  toolbox on '.sys_name."\n"
				\ .'         cmake executable :  '.s:CMake_Executable."\n"
				\ .'                > enabled :  '.cmake_status."\n"
				\ .'                make tool :  '.s:CMake_MakeTool."\n"
				\ .'                > enabled :  '.make_status."\n"
				\ .'            using toolbox :  version '.g:Toolbox_Version." by Wolfgang Mehner\n"
	if a:verbose
		let	txt .= "\n"
					\ .'            jump to error :  '.g:CMake_JumpToError."\n"
					\ ."\n"
					\ .'        project directory :  '.s:ProjectDir."\n"
					\ .'           build location :  '.s:BuildLocation."\n"
	endif
	let txt .=
				\  "________________________________________________________________________________\n"
				\ ." CMake-Tool, Version ".g:CMake_Version." / Wolfgang Mehner / wolfgang-mehner@web.de\n\n"
	"
	echo txt
endfunction    " ----------  end of function mmtoolbox#cmake#Settings  ----------
"
"-------------------------------------------------------------------------------
" Modul setup (abort early?).   {{{1
"-------------------------------------------------------------------------------
if s:Enabled == 0
	finish
endif
"
"-------------------------------------------------------------------------------
" Run : Run CMake or make.   {{{1
"-------------------------------------------------------------------------------
function! mmtoolbox#cmake#Run ( args, cmake_only )
	"
	let g:CMakeDebugStr = 'cmake#run: '   " debug
	"
	silent exe 'update'   | " write source file if necessary
	cclose
	"
	exe	'lchdir '.fnameescape( s:BuildLocation )
	"
	if a:cmake_only == 1
		"
		let g:CMakeDebugStr .= 'CMake only, '   " debug
		"
		" save the current settings
		let errorf_saved = &g:errorformat
		"
		" run CMake and process the errors
		exe	'setglobal errorformat='.s:ErrorFormat_CMake
		"
		if a:args == '' | let args = shellescape ( s:ProjectDir )
		else            | let args = a:args
		endif
		"
		let errors = 'DIR : '.s:ProjectDir."\n"
					\ .system ( shellescape( s:CMake_Executable ).' '.args )
					\ .'ENDDIR : '.s:ProjectDir
		"
		if g:CMake_JumpToError == 'cmake' || g:CMake_JumpToError == 'both'
			silent exe 'cexpr errors'
		else
			silent exe 'cgetexpr errors'
		endif
		"
		" restore the old settings
		exe 'setglobal errorformat='.escape( errorf_saved, s:SettingsEscChar )
		"
		let g:CMakeDebugStr .= 'success: '.( v:shell_error == 0 ).', '   " debug
		"
		" errors occurred?
		if v:shell_error == 0 | echo 'CMake : CMake finished successfully.'
		else                  | botright cwindow
		endif
		"
	else
		"
		let g:CMakeDebugStr .= 'CMake & make, '   " debug
		"
		" CMake, run by make, in case of failure: "-- Configuring incomplete, errors occurred!"
		"
		" run make
		let errors = system ( shellescape( s:CMake_MakeTool ).' '.a:args )
		"
		" error was produced by CMake?
		if v:shell_error != 0
						\ && errors =~ '--\s\+Configuring incomplete, errors occurred!'
			" error was produced by CMake
			"
			let g:CMakeDebugStr .= 'handling CMake error, '   " debug
			"
			" save the current settings
			let errorf_saved = &g:errorformat
			"
			" process the errors
			exe	'setglobal errorformat='.s:ErrorFormat_CMake
			"
			let errors = 'DIR : '.s:ProjectDir."\n"
						\ .errors
						\ .'ENDDIR : '.s:ProjectDir
			"
			if g:CMake_JumpToError == 'cmake' || g:CMake_JumpToError == 'both'
				silent exe 'cexpr errors'
			else
				silent exe 'cgetexpr errors'
			endif
			"
			" restore the old settings
			exe 'setglobal errorformat='.escape( errorf_saved, s:SettingsEscChar )
			"
		else
			" no error or error was produced by make, gcc, ...
			"
			let g:CMakeDebugStr .= 'handling make error, '   " debug
			"
			" save the current settings
			let errorf_saved = &g:errorformat
			"
			" process the errors
			exe	'setglobal errorformat='
						\ .s:ErrorFormat_MakeAdditions
						\ .escape( errorf_saved, s:SettingsEscChar )
			"
			if g:CMake_JumpToError == 'make' || g:CMake_JumpToError == 'both'
				silent exe 'cexpr errors'
			else
				silent exe 'cgetexpr errors'
			endif
			"
			" restore the old settings
			exe 'setglobal errorformat='.escape( errorf_saved, s:SettingsEscChar )
			"
		endif
		"
		let g:CMakeDebugStr .= 'success: '.( v:shell_error == 0 ).', '   " debug
		"
		" errors occurred?
		if v:shell_error == 0 | echo 'CMake : make finished successfully.'
		else                  | botright cwindow
		endif
		"
	endif
	"
	lchdir -
	"
	let g:CMakeDebugStr .= 'done'   " debug
	"
endfunction    " ----------  end of function mmtoolbox#cmake#Run  ----------
"
"-------------------------------------------------------------------------------
" s:TextFromSystem : Get text from a system command.   {{{1
"-------------------------------------------------------------------------------
function! s:TextFromSystem ( cmd )
	"
	let text = system ( a:cmd )
	"
	if v:shell_error != 0
		return [ 0, '' ]
	endif
	"
	return [ 1, text ]
endfunction    " ----------  end of function s:TextFromSystem  ----------
"
"-------------------------------------------------------------------------------
" s:PolicyListText : Get text for policy list.   {{{1
"-------------------------------------------------------------------------------
function! s:PolicyListText ()
	"
	let text = "policy list taken from cmake version ".s:Policies_Version
	"
	for [ nr, dsc, vrs ] in s:Policies_List
		let text .= "\n\n".nr."\n\t".dsc." (".vrs.")"
	endfor
	"
	return [ 1, text ]
endfunction    " ----------  end of function s:PolicyListText  ----------
"
"-------------------------------------------------------------------------------
" s:OpenManBuffer : Print help for commands.   {{{1
"-------------------------------------------------------------------------------
function! s:OpenManBuffer ( text_cmd, buf_name, jump_reaction )
	"
	" a buffer like this already existing?
	if bufnr ( a:buf_name ) != -1
		" yes -> go to the window containing the buffer
		exe bufwinnr( a:buf_name ).'wincmd w'
		return
	endif
	"
	" no -> open a buffer and insert the text
	exe 'let [ success, text ] = '.a:text_cmd
	"
	if success == 0
		return 0
	endif
	"
	aboveleft new
	silent exe 'put! = text'
	:1
	"
	" settings of the new buffer
	silent exe 'file '.escape( a:buf_name, ' ' )
	setlocal ro
	setlocal nomodified
	setlocal nomodifiable
	setlocal bufhidden=wipe
"	setlocal filetype=man
	"
	silent exe 'nmap <silent> <buffer> <C-]>         '.a:jump_reaction
	silent exe 'nmap <silent> <buffer> <Enter>       '.a:jump_reaction
	silent exe 'nmap <silent> <buffer> <2-Leftmouse> '.a:jump_reaction
	silent exe 'nmap <silent> <buffer> q             :close<CR>'
  "
	return 1
endfunction    " ----------  end of function s:OpenManBuffer  ----------
"
"-------------------------------------------------------------------------------
" Help : Print help for commands, modules and variables.   {{{1
"-------------------------------------------------------------------------------
function! mmtoolbox#cmake#Help ( type, topic )
	"
	" help for which type of object?
	if a:type == 'command'
		let switch = '--help-command'
	elseif a:type == 'module'
    let switch = '--help-module'
	elseif a:type == 'policy'
    let switch = '--help-policy'
	elseif a:type == 'property'
    let switch = '--help-property'
	elseif a:type == 'variable'
    let switch = '--help-variable'
	else
		call s:ErrorMsg ( 'CMake : Unknown type for help: '.type )
		return
	endif
	"
	let esc_exe = shellescape( s:CMake_Executable )
	let esc_exe = substitute( esc_exe, "'", "''", "g" )
	"
	" overview or concrete topic?
	if a:topic == '' && a:type == 'policy'
		"
		" get the policy list (requires special treatment)
		let cmd  = 's:PolicyListText ()'
		"
		let topic    = a:type
		let category = 'list'
		"
		let jump = ':call mmtoolbox#cmake#HelpJump("'.a:type.'")<CR>'
	elseif a:topic == ''
		"
		" get the list of topics
		let cmd  = "s:TextFromSystem ( '".esc_exe." ".switch."-list ".a:topic."' )"
		"
		let topic    = a:type
		let category = 'list'
		"
		let jump = ':call mmtoolbox#cmake#HelpJump("'.a:type.'")<CR>'
	else
		"
		" get help for a topic
		let cmd = "s:TextFromSystem ( '".esc_exe." ".switch." ".escape( a:topic, '<>[] ' )."' )"
		"
		if s:MSWIN
			" :TODO:18.02.2014 15:09:WM: which characters can we use under Windows?
			let topic = substitute( a:topic, '[<>[\]]', '-', 'g' )
		else
			let topic = a:topic
		endif
		let category = a:type
		"
		let jump = ':call mmtoolbox#cmake#Help("'.a:type.'","")<CR>'
	endif
	"
	" get the help
	" :TODO:18.02.2014 15:09:WM: can we use brackets under Windows?
	let buf  = 'CMake help - '.topic.' ('.category.')'
	"
	if ! s:OpenManBuffer ( cmd, buf, jump )
		echo 'CMake : No help for "'.topic.'".'
	endif
  "
endfunction    " ----------  end of function mmtoolbox#cmake#Help  ----------
"
"-------------------------------------------------------------------------------
" HelpJump : Jump to help for commands, modules and variables.   {{{1
"-------------------------------------------------------------------------------
function! mmtoolbox#cmake#HelpJump ( type )
	"
	" get help for the word in the line
	"
	" the name under the cursor can consist of these characters:
	"   <letters> <numbers> _ < > [ ] <space>
	" but never end with a space
	"
	let line = getline('.')
	let line = matchstr( line, '^[[:alnum:]_<>[\] ]*[[:alnum:]_<>[\]]\ze\s*$' )
	"
	" for type "policy": maybe the line above matches (can use simpler regex)
	if empty( line ) && a:type == 'policy' && line('.')-1 > 0
		let line = getline( line('.')-1 )
		let line = matchstr( line, '^\w\+\ze\s*$' )
	endif
	"
	if empty( line )
		echo 'CMake : No '.a:type.' under the cursor.'
		return
	endif
	"
	call mmtoolbox#cmake#Help ( a:type, line )
  "
endfunction    " ----------  end of function mmtoolbox#cmake#HelpJump  ----------
" }}}1
"-------------------------------------------------------------------------------
"
" =====================================================================================
"  vim: foldmethod=marker
