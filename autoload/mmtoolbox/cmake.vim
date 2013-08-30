"===============================================================================
"
"          File:  cmake.vim
" 
"   Description:  Part of the C-Support toolbox.
"
"                 Vim/gVim integration of CMake.
"
"                 See help file csupport_cmake.txt .
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
let g:CMake_Version= '0.9'     " version number of this script; do not change
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
let s:ProjectDir    = '.'
let s:BuildLocation = '.'
"
let s:CMake_Executable = 'cmake'
let s:CMake_MakeTool   = 'make'
"
call s:GetGlobalSetting ( 'CMake_Executable' )
call s:GetGlobalSetting ( 'CMake_MakeTool' )
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
let s:Policies_Version = '2.8.7'
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
else
	"
	" Disabled : Print why the script is disabled.   {{{3
	function! mmtoolbox#cmake#Disabled ()
		let txt = "CMake tool not working:\n"
		if ! executable ( s:CMake_Executable )
			let txt .= "CMake not executable (".s:CMake_Executable.")"
		elseif ! executable ( s:CMake_MakeTool )
			let txt .= "make tool not executable (".s:CMake_MakeTool.")"
		else
			let txt .= "unknown reason"
		endif
		echohl Search
		echo txt
		echohl None
		return
	endfunction    " ----------  end of function mmtoolbox#cmake#Disabled  ----------
	" }}}3
	"
	command! -nargs=* CMakeHelp :call mmtoolbox#cmake#Disabled()
	"
endif
"
" }}}2
"
"-------------------------------------------------------------------------------
" Init : Initialize the script.   {{{1
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
	if a:key == 'project-dir'
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
		if val == '' | let s:ProjectDir = ''
		else         | let s:ProjectDir = fnamemodify( expand( val ), ":p" )
		endif
	elseif a:key == 'build-dir'
		" expand replaces the escape sequences from the cmdline
		if val == '' | let s:BuildLocation = ''
		else         | let s:BuildLocation = fnamemodify( expand( val ), ":p" )
		endif
	endif
	"
endfunction    " ----------  end of function mmtoolbox#cmake#Property  ----------
"
"-------------------------------------------------------------------------------
" Modul setup.   {{{1
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
					\ .system ( s:CMake_Executable.' '.args )
					\ .'ENDDIR : '.s:ProjectDir
		cexpr errors
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
		let errors = system ( s:CMake_MakeTool.' '.a:args )
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
			cexpr errors
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
			cexpr errors
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
	let text = "cmake version ".s:Policies_Version
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
		let cmd  = 's:TextFromSystem ( "'.s:CMake_Executable.' '.switch.'-list '.a:topic.'" )'
		"
		let topic    = a:type
		let category = 'list'
		"
		let jump = ':call mmtoolbox#cmake#HelpJump("'.a:type.'")<CR>'
	else
		"
		" get help for a topic
		let cmd  = 's:TextFromSystem ( "'.s:CMake_Executable.' '.switch.' '.a:topic.'" )'
		"
		let topic    = a:topic
		let category = a:type
		"
		let jump = ':call mmtoolbox#cmake#Help("'.a:type.'","")<CR>'
	endif
	"
	" get the help
	let buf  = 'CMake help : '.topic.' ('.category.')'
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
	let line = getline('.')
	let line = matchstr(line,'^\w\+\ze\s*$')
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
