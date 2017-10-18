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
"      Revision:  23.07.2015
"       License:  Copyright (c) 2012-2016, Wolfgang Mehner
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
let g:CMake_Version= '0.9.3'     " version number of this script; do not change
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
"
"-------------------------------------------------------------------------------
" s:WarningMsg : Print a warning/error message.   {{{2
"
" Parameters:
"   line1 - a line (string)
"   line2 - a line (string)
"   ...   - ...
" Returns:
"   -
"-------------------------------------------------------------------------------
function! s:WarningMsg ( ... )
	echohl WarningMsg
	echo join ( a:000, "\n" )
	echohl None
endfunction    " ----------  end of function s:WarningMsg  ----------
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

let s:makelib = mmtoolbox#make#Interface ()

let s:ProjectDir    = '.'
let s:BuildLocation = '.'

if s:MSWIN
	let s:CMake_BinPath = ''
else
	let s:CMake_BinPath = ''
endif

call s:GetGlobalSetting ( 'CMake_BinPath' )

if s:MSWIN
	let s:CMake_BinPath = substitute ( s:CMake_BinPath, '[^\\/]$', '&\\', '' )

	let s:CMake_Executable = s:CMake_BinPath.'cmake.exe'
	let s:CMake_GuiExec    = s:CMake_BinPath.'cmake-gui.exe'
else
	let s:CMake_BinPath = substitute ( s:CMake_BinPath, '[^\\/]$', '&/', '' )

	let s:CMake_Executable = s:CMake_BinPath.'cmake'
	let s:CMake_CCMakeExec = s:CMake_BinPath.'ccmake'
	let s:CMake_GuiExec    = s:CMake_BinPath.'cmake-gui'
endif
let s:CMake_MakeTool   = 'make'

let s:Xterm_Executable = 'xterm'

call s:GetGlobalSetting ( 'CMake_Executable' )
call s:GetGlobalSetting ( 'CMake_MakeTool' )
call s:GetGlobalSetting ( 'CMake_GuiExec' )
call s:GetGlobalSetting ( 'CMake_CCMakeExec' )
call s:GetGlobalSetting ( 'Xterm_Executable' )
call s:ApplyDefaultSetting ( 'CMake_JumpToError',       'cmake' )
call s:ApplyDefaultSetting ( 'CMake_FilterFastTargets', 'no' )
call s:ApplyDefaultSetting ( 'Xterm_Options', '-fa courier -fs 12 -geometry 80x24' )

let s:Enabled = 1

" check executables   {{{2

if ! executable ( s:CMake_Executable ) || ! executable ( s:CMake_MakeTool )
	let s:Enabled = 0
endif

let s:EnabledCCMake   = s:UNIX && executable ( s:CMake_CCMakeExec )
let s:EnabledCMakeGui = executable ( s:CMake_GuiExec )

" error formats {{{2
"
" error format for CMake
let s:ErrorFormat_CMake =
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
"
" error format for make, additional errors
let s:ErrorFormat_MakeAdditions =
			\  '%-GIn file included from %f:%l:%.%#,'
			\ .'%-G%\s%\+from %f:%l:%.%#,'
"
" policy list {{{2
"
let s:Policies_Version = '3.10'
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
			\ [ 'CMP0016', 'target_link_libraries() reports error if its only argument is not a target.', '2.8.3' ],
			\ [ 'CMP0017', 'Prefer files from the CMake module directory when including from there.', '2.8.4' ],
			\ [ 'CMP0018', 'Ignore CMAKE_SHARED_LIBRARY_<Lang>_FLAGS variable.', '2.8.9' ],
			\ [ 'CMP0019', 'Do not re-expand variables in include and link information.', '2.8.11' ],
			\ [ 'CMP0020', 'Automatically link Qt executables to qtmain target on Windows.', '2.8.11' ],
			\ [ 'CMP0021', 'Fatal error on relative paths in INCLUDE_DIRECTORIES target property.', '2.8.12' ],
			\ [ 'CMP0022', 'INTERFACE_LINK_LIBRARIES defines the link interface.', '2.8.12' ],
			\ [ 'CMP0023', 'Plain and keyword target_link_libraries signatures cannot be mixed.', '2.8.12' ],
			\ [ 'CMP0024', 'Disallow include export result.', '3.0' ],
			\ [ 'CMP0025', 'Compiler id for Apple Clang is now AppleClang.', '3.0' ],
			\ [ 'CMP0026', 'Disallow use of the LOCATION property for build targets.', '3.0' ],
			\ [ 'CMP0027', 'Conditionally linked imported targets with missing include directories.', '3.0' ],
			\ [ 'CMP0028', 'Double colon in target name means ALIAS or IMPORTED target.', '3.0' ],
			\ [ 'CMP0029', 'The subdir_depends() command should not be called.', '3.0.' ],
			\ [ 'CMP0030', 'The use_mangled_mesa() command should not be called.', '3.0' ],
			\ [ 'CMP0031', 'The load_command() command should not be called.', '3.0' ],
			\ [ 'CMP0032', 'The output_required_files() command should not be called.', '3.0' ],
			\ [ 'CMP0033', 'The export_library_dependencies()command should not be called.', '3.0' ],
			\ [ 'CMP0034', 'The utility_source() command should not be called.', '3.0' ],
			\ [ 'CMP0035', 'The variable_requires() command should not be called.', '3.0' ],
			\ [ 'CMP0036', 'The build_name() command should not be called.', '3.0' ],
			\ [ 'CMP0037', 'Target names should not be reserved and should match a validity pattern.', '3.0' ],
			\ [ 'CMP0038', 'Targets may not link directly to themselves.', '3.0' ],
			\ [ 'CMP0039', 'Utility targets may not have link dependencies.', '3.0' ],
			\ [ 'CMP0040', 'The target in the TARGET signature of add_custom_command() must exist and must be defined in current directory.', '3.0' ],
			\ [ 'CMP0041', 'Error on relative include with generator expression.', '3.0' ],
			\ [ 'CMP0042', 'MACOSX_RPATH is enabled by default.', '3.0' ],
			\ [ 'CMP0043', 'Ignore COMPILE_DEFINITIONS_<Config> properties', '3.0' ],
			\ [ 'CMP0044', 'Case sensitive <LANG>_COMPILER_ID generator expressions', '3.0' ],
			\ [ 'CMP0045', 'Error on non-existent target in get_target_property.', '3.0' ],
			\ [ 'CMP0046', 'Error on non-existent dependency in add_dependencies.', '3.0' ],
			\ [ 'CMP0047', 'Use QCC compiler id for the qcc drivers on QNX.', '3.0' ],
			\ [ 'CMP0048', 'The project() command manages VERSION variables.', '3.0' ],
			\ [ 'CMP0049', 'Do not expand variables in target source entries.', '3.0' ],
			\ [ 'CMP0050', 'Disallow add_custom_command SOURCE signatures.', '3.0' ],
			\ [ 'CMP0051', 'List TARGET_OBJECTS in SOURCES target property.', '3.1' ],
			\ [ 'CMP0052', 'Reject source and build dirs in installed INTERFACE_INCLUDE_DIRECTORIES.', '3.1' ],
			\ [ 'CMP0053', 'Simplify variable reference and escape sequence evaluation.', '3.1' ],
			\ [ 'CMP0054', 'Only interpret if() arguments as variables or keywords when unquoted.', '3.1' ],
			\ [ 'CMP0055', 'Strict checking for the break() command.', '3.2' ],
			\ [ 'CMP0056', 'Honor link flags in try_compile() source-file signature.', '3.2' ],
			\ [ 'CMP0057', 'Support new if() IN_LIST operator.', '3.3' ],
			\ [ 'CMP0058', 'Ninja requires custom command byproducts to be explicit.', '3.3' ],
			\ [ 'CMP0059', 'Do not treat DEFINITIONS as a built-in directory property.', '3.3' ],
			\ [ 'CMP0060', 'Link libraries by full path even in implicit directories.', '3.3' ],
			\ [ 'CMP0061', 'CTest does not by default tell make to ignore errors (-i).', '3.3' ],
			\ [ 'CMP0062', 'Disallow install() of export() result.', '3.3' ],
			\ [ 'CMP0063', 'Honor visibility properties for all target types.', '3.3' ],
			\ [ 'CMP0064', 'Recognize TEST as a operator for the if() command.', '3.4' ],
			\ [ 'CMP0065', 'Do not add flags to export symbols from executables without the ENABLE_EXPORTS target property.', '3.4' ],
			\ [ 'CMP0066', 'Honor per-config flags in try_compile() source-file signature.', '3.7' ],
			\ [ 'CMP0067', 'Honor language standard in try_compile() source-file signature.', '3.8' ],
			\ [ 'CMP0068', 'RPATH settings on macOS do not affect install_name.', '3.9' ],
			\ [ 'CMP0069', 'INTERPROCEDURAL_OPTIMIZATION is enforced when enabled.', '3.9' ],
			\ [ 'CMP0070', 'Define file(GENERATE) behavior for relative paths.', '3.10' ],
			\ [ 'CMP0071', 'Let AUTOMOC and AUTOUIC process GENERATED files.', '3.10' ],
			\ [ 'CMP????', 'There might be more policies not mentioned here, since this list is not maintained automatically.', '?.?.?' ],
			\ ]
"
" Make target complete {{{2
"
function! s:MakeTargetComplete ( ArgLead, CmdLine, CursorPos )
	"
	" targets
	let target_list = filter( copy( s:makelib.GetMakeTargets( s:BuildLocation.'/Makefile' ) ), 'v:val =~ "\\V\\<'.escape(a:ArgLead,'\').'\\w\\*"' )
	"
	" filter fast targets?
	if g:CMake_FilterFastTargets == 'yes'
		let target_list = filter( target_list, 'v:val !~ "/fast$"' )
	endif
	"
	" files
	let filelist = split ( glob ( a:ArgLead.'*' ), "\n" )
	"
	for i in range ( 0, len(filelist)-1 )
		if isdirectory ( filelist[i] )
			let filelist[i] .= '/'
		endif
	endfor
	"
	return target_list + filelist
endfunction    " ----------  end of function s:MakeTargetComplete  ----------

" CMake cache complete {{{2

function! s:CacheOptions (...)
	return "-L\n-LA\n-LH\n-LAH"
endfunction    " ----------  end of function s:CacheOptions  ----------

" custom commands {{{2

if s:Enabled == 1
	command! -bang -nargs=* -complete=customlist,<SID>MakeTargetComplete  CMake       :call <SID>Run(<q-args>,'<bang>'=='!')
	command! -bang -nargs=? -complete=custom,<SID>CacheOptions            CMakeCache  :call <SID>ShowCache(<q-args>)

	command! -bang -nargs=? -complete=file CMakeProjectDir    :call mmtoolbox#cmake#Property('<bang>'=='!'?'echo':'set','project-dir',<q-args>)
	command! -bang -nargs=? -complete=file CMakeBuildLocation :call mmtoolbox#cmake#Property('<bang>'=='!'?'echo':'set','build-dir',<q-args>)
	command!       -nargs=? -complete=file CMakeHelpCommand   :call <SID>Help('command',<q-args>)
	command!       -nargs=? -complete=file CMakeHelpModule    :call <SID>Help('module',<q-args>)
	command!       -nargs=? -complete=file CMakeHelpPolicy    :call <SID>Help('policy',<q-args>)
	command!       -nargs=? -complete=file CMakeHelpProperty  :call <SID>Help('property',<q-args>)
	command!       -nargs=? -complete=file CMakeHelpVariable  :call <SID>Help('variable',<q-args>)
	command!       -nargs=0                CMakeHelp          :call <SID>HelpPlugin()
	command! -bang -nargs=?                CMakeSettings      :call <SID>Settings(('<bang>'=='!')+str2nr(<q-args>))
	command!       -nargs=0                CMakeRuntime       :call <SID>RuntimeInfo()

	if s:EnabledCCMake
		command!       -nargs=* -complete=file CMakeCurses      :call <SID>StartCCMake(<q-args>)
	endif
	if s:EnabledCMakeGui
		command!       -nargs=* -complete=file CMakeGui         :call <SID>StartGui(<q-args>)
	endif
else

	" s:Disabled : Print why the script is disabled.   {{{3
	function! s:Disabled ()
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
	endfunction    " ----------  end of function s:Disabled  ----------
	" }}}3

	command! -bang -nargs=* CMake          :call <SID>Disabled()
	command!       -nargs=0 CMakeHelp      :call <SID>HelpPlugin()
	command! -bang -nargs=? CMakeSettings  :call <SID>Settings(('<bang>'=='!')+str2nr(<q-args>))
	command! -bang -nargs=? CMakeRuntime   :call <SID>Settings(('<bang>'=='!')+str2nr(<q-args>))

endif

" }}}2

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

	exe 'amenu '.a:root.'.run\ CMake<Tab>:CMake!   :CMake! '
	exe 'amenu '.a:root.'.&run\ make<Tab>:CMake    :CMake '

	exe 'amenu '.a:root.'.&list\ variables<Tab>:CMakeCache    :CMakeCache '

	if s:EnabledCCMake
		exe 'amenu '.a:root.'.run\ &ccmake<Tab>:CMakeCurses    :CMakeCurses '
	endif
	if s:EnabledCMakeGui
		exe 'amenu '.a:root.'.run\ cmake-&gui<Tab>:CMakeGui    :CMakeGui '
	endif

	exe 'amenu '.a:root.'.-Sep01- <Nop>'

	exe 'amenu '.a:root.'.project\ &directory<Tab>:CMakeProjectDir     :CMakeProjectDir '
	exe 'amenu '.a:root.'.build\ &location<Tab>:CMakeBuildLocation     :CMakeBuildLocation '

	exe 'amenu '.a:root.'.-Sep02- <Nop>'

	exe 'amenu '.a:root.'.help\ &commands<Tab>:CMakeHelpCommand    :CMakeHelpCommand<CR>'
	exe 'amenu '.a:root.'.help\ &modules<Tab>:CMakeHelpModule      :CMakeHelpModule<CR>'
	exe 'amenu '.a:root.'.help\ &policies<Tab>:CMakeHelpPolicy     :CMakeHelpPolicy<CR>'
	exe 'amenu '.a:root.'.help\ &property<Tab>:CMakeHelpProperty   :CMakeHelpProperty<CR>'
	exe 'amenu '.a:root.'.help\ &variables<Tab>:CMakeHelpVariable  :CMakeHelpVariable<CR>'

	exe 'amenu '.a:root.'.-SEP03- <Nop>'

	exe 'amenu '.a:root.'.runtime\ &info<Tab>:CMakeRuntime  :CMakeRuntime<CR>'
	exe 'amenu '.a:root.'.&settings<Tab>:CMakeSettings      :CMakeSettings<CR>'
	exe 'amenu '.a:root.'.&help<Tab>:CMakeHelp              :CMakeHelp<CR>'

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
		echo {var}
		return
	elseif a:mode == 'get'
		return {var}
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
" s:HelpPlugin : Plugin help.   {{{1
"-------------------------------------------------------------------------------
function! s:HelpPlugin ()
	try
		help toolbox-cmake
	catch
		exe 'helptags '.s:plugin_dir.'/doc'
		help toolbox-cmake
	endtry
endfunction    " ----------  end of function s:HelpPlugin  ----------
"
"-------------------------------------------------------------------------------
" s:Settings : Plugin settings.   {{{1
"-------------------------------------------------------------------------------
function! s:Settings ( verbose )

	if     s:MSWIN | let sys_name = 'Windows'
	elseif s:UNIX  | let sys_name = 'UNIX'
	else           | let sys_name = 'unknown' | endif

	let cmake_status = executable( s:CMake_Executable ) ? '' : ' (not executable)'
	let make_status  = executable( s:CMake_MakeTool   ) ? '' : ' (not executable)'

	if s:UNIX
		let ccmake_status = executable( s:CMake_CCMakeExec ) ? '' : ' (not executable)'
	endif
	let gui_status    = executable( s:CMake_GuiExec    ) ? '' : ' (not executable)'

	let	txt = " CMake-Support settings\n\n"
				\ .'     plug-in installation :  toolbox on '.sys_name."\n"
				\ .'         cmake executable :  '.s:CMake_Executable.cmake_status."\n"
				\ .'                make tool :  '.s:CMake_MakeTool.make_status."\n"
	if s:UNIX
		let txt .=
					\  '        ccmake executable :  '.s:CMake_CCMakeExec.ccmake_status."\n"
	endif
	let txt .=
				\  '     cmake-gui executable :  '.s:CMake_GuiExec.gui_status."\n"
				\ .'            using toolbox :  version '.g:Toolbox_Version." by Wolfgang Mehner\n"
	if a:verbose
		let	txt .= "\n"
					\ .'            jump to error :  '.g:CMake_JumpToError."\n"
					\ .'      filter fast targets :  '.g:CMake_FilterFastTargets."\n"
					\ ."\n"
					\ .'        project directory :  '.s:ProjectDir."\n"
					\ .'           build location :  '.s:BuildLocation."\n"
	endif
	let txt .=
				\  "________________________________________________________________________________\n"
				\ ." CMake-Tool, Version ".g:CMake_Version." / Wolfgang Mehner / wolfgang-mehner@web.de\n\n"

	if a:verbose == 2
		split CMake_Settings.txt
		put = txt
	else
		echo txt
	endif
endfunction    " ----------  end of function s:Settings  ----------

"-------------------------------------------------------------------------------
" s:RuntimeInfo : Display everything that's important during work.   {{{1
"-------------------------------------------------------------------------------
function! s:RuntimeInfo ()
	let jump_cmake = g:CMake_JumpToError == 'cmake' || g:CMake_JumpToError == 'both' ? 'x' : ' '
	let jump_make  = g:CMake_JumpToError == 'make'  || g:CMake_JumpToError == 'both' ? 'x' : ' '

	let	txt = " CMake-Support runtime information\n\n"
				\ .'            jump to error :  cmake ('.jump_cmake.') , make ('.jump_make.")\n"
				\ .'      filter fast targets :  '.g:CMake_FilterFastTargets."\n"
				\ ."\n"
				\ .'        project directory :  '.s:ProjectDir."\n"
				\ .'           build location :  '.s:BuildLocation."\n"
	echo txt
endfunction    " ----------  end of function s:RuntimeInfo  ----------

"-------------------------------------------------------------------------------
" Modul setup (abort early?).   {{{1
"-------------------------------------------------------------------------------
if s:Enabled == 0
	finish
endif
"
"-------------------------------------------------------------------------------
" s:Run : Run CMake or make.   {{{1
"-------------------------------------------------------------------------------
function! s:Run ( args, cmake_only )
	"
	let g:CMakeDebugStr = 'cmake#run: '   " debug
	"
	silent exe 'update'   | " write source file if necessary
	cclose

	exe	'cd '.fnameescape( s:BuildLocation )

	if a:cmake_only == 1
		"
		let g:CMakeDebugStr .= 'CMake only, '   " debug
		"
		" save the current settings
		let errorf_saved = &g:errorformat
		"
		" run CMake and process the errors
		let &g:errorformat = s:ErrorFormat_CMake
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
		let &g:errorformat = errorf_saved
		"
		let g:CMakeDebugStr .= 'success: '.( v:shell_error == 0 ).', '   " debug

		cd -

		" errors occurred?
		if v:shell_error != 0
			botright cwindow
		else
			redraw                                    " redraw after cclose, before echoing
			call s:ImportantMsg ( 'CMake : CMake finished successfully.' )
		endif
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
			let &g:errorformat = s:ErrorFormat_CMake
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
			let &g:errorformat = errorf_saved
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
			let &g:errorformat =
						\  s:ErrorFormat_MakeAdditions
						\ .errorf_saved
			"
			if g:CMake_JumpToError == 'make' || g:CMake_JumpToError == 'both'
				silent exe 'cexpr errors'
			else
				silent exe 'cgetexpr errors'
			endif
			"
			" restore the old settings
			let &g:errorformat = errorf_saved
			"
		endif
		"
		let g:CMakeDebugStr .= 'success: '.( v:shell_error == 0 ).', '   " debug

		cd -

		" errors occurred?
		if v:shell_error != 0
			botright cwindow
		else
			redraw                                    " redraw after cclose, before echoing
			"
			let warnings = 0
			"
			for entry in getqflist ()
				if entry.valid
					let warnings = 1
					break
				endif
			endfor
			"
			if warnings
				call s:ImportantMsg ( 'CMake : make finished successfully, but warnings present' )
			else
				call s:ImportantMsg ( 'CMake : make finished successfully.' )
			endif
		endif
	endif

	let g:CMakeDebugStr .= 'done'   " debug

endfunction    " ----------  end of function s:Run  ----------
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

"-------------------------------------------------------------------------------
" s:OpenBuffer : Open a scratch buffer.   {{{1
"
" If a buffer called 'buf_name' already exists, jump to that buffer. Otherwise,
" open a buffer of the given name an set it up as a scratch buffer. It is
" deleted after the window is closed.
"
" Options:
" - showdir: the directory will be shown in the buffer list (set buf=nowrite)
"
" Settings:
" - buftype=nofile/nowrite (depending on the option 'showdir')
" - bufhidden=wipe
" - swapfile=0
" - tabstop=8
"
" Parameters:
"   buf_name - name of the buffer (string)
"   ... - options (string)
" Returns:
"   opened -  true, if a new buffer was opened (integer)
"-------------------------------------------------------------------------------
function! s:OpenBuffer ( buf_name, ... )

	" options
	let btype = 'nofile'

	for val in a:000
		if val == 'showdir'
			let btype = 'nowrite'                     " like 'nofile', but the directory is shown in the buffer list
		else
			call s:ErrorMsg ( 'CMake : Unknown buffer option: '.val )
		endif
	endfor

	" a buffer like this already opened on the current tab page?
	if bufwinnr ( a:buf_name ) != -1
		" yes -> go to the window containing the buffer
		exe bufwinnr( a:buf_name ).'wincmd w'
		return 0
	endif

	" no -> open a new window
	aboveleft new

	" buffer exists elsewhere?
	if bufnr ( a:buf_name ) != -1
		" yes -> reuse it
		silent exe 'edit #'.bufnr( a:buf_name )
		return 0
	else
		" no -> settings of the new buffer
		let &l:buftype   = btype
		let &l:bufhidden = 'wipe'
		let &l:swapfile  = 0
		let &l:tabstop   = 8
		call s:RenameBuffer( a:buf_name )
	endif

	return 1
endfunction    " ----------  end of function s:OpenBuffer  ----------

"-------------------------------------------------------------------------------
" s:RenameBuffer : Rename a scratch buffer.   {{{1
"
" Parameters:
"   name - the new name (string)
" Returns:
"   -
"-------------------------------------------------------------------------------
function! s:RenameBuffer ( name )

	silent exe 'keepalt file '.fnameescape( a:name )

endfunction    " ----------  end of function s:RenameBuffer  ----------

"-------------------------------------------------------------------------------
" s:UpdateBuffer : Update a scratch buffer.   {{{1
"
" Replace the text in the buffer with 'text'.
"
" Parameters:
"   text - the text to place in the buffer (string)
" Returns:
"   -
"-------------------------------------------------------------------------------
function! s:UpdateBuffer ( text )

	" delete the previous contents
	setlocal modifiable
	setlocal noro
	silent exe '1,$delete _'

	" pause syntax highlighting (for speed)
	if &syntax != ''
		setlocal syntax=OFF
	endif

	" insert the text
	silent exe 'put = a:text'

	" delete the first line (empty)
	normal! gg"_dd

	" restart syntax highlighting
	if &syntax != ''
		setlocal syntax=ON
	endif

	" read-only again
	setlocal ro
	setlocal nomodified
	setlocal nomodifiable
endfunction    " ----------  end of function s:UpdateBuffer  ----------

"-------------------------------------------------------------------------------
" s:Help : Print help for commands, modules and variables.   {{{1
"-------------------------------------------------------------------------------
function! s:Help ( type, topic )
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

	let esc_exe = shellescape( s:CMake_Executable )

	" overview or concrete topic?
	if a:topic == '' && a:type == 'policy'
		"
		" get the policy list (requires special treatment)
		let [ success, text ] = s:PolicyListText ()
		"
		let topic    = a:type
		let category = 'list'
		"
		let jump = ':call <SID>HelpJump("'.a:type.'")<CR>'
	elseif a:topic == ''
		"
		" get the list of topics
		let [ success, text ] = s:TextFromSystem ( esc_exe." ".switch."-list ".a:topic )
		"
		let topic    = a:type
		let category = 'list'
		"
		let jump = ':call <SID>HelpJump("'.a:type.'")<CR>'
	else

		" get help for a topic
		let arg_name = a:topic

		if s:MSWIN
			let arg_name = substitute( a:topic, '[<>]', '', 'g' )
		endif

		let [ success, text ] = s:TextFromSystem ( esc_exe." ".switch." ".escape( arg_name, '<>[] ' ) )

		let topic    = a:topic
		let category = a:type

		let jump = ':call <SID>Help("'.a:type.'","")<CR>'
	endif

	" get the help
	if success == 0
		call s:WarningMsg ( 'CMake : No help for "'.topic.'".' )
		return
	endif

	if s:MSWIN
		let topic_display = substitute( topic, '[<>]', '-', 'g' )
		let buf = 'CMake help - '.topic_display.' ('.category.')'
	else
		let buf = 'CMake help - '.topic.' ('.category.')'
	endif

	if s:OpenBuffer ( buf )
		silent exe 'nmap <silent> <buffer> <C-]>         '.jump
		silent exe 'nmap <silent> <buffer> <Enter>       '.jump
		silent exe 'nmap <silent> <buffer> <2-Leftmouse> '.jump
		silent exe 'nmap <silent> <buffer> q             :close<CR>'
	else
		return
	endif

	call s:UpdateBuffer ( text )

endfunction    " ----------  end of function s:Help  ----------
"
"-------------------------------------------------------------------------------
" s:HelpJump : Jump to help for commands, modules and variables.   {{{1
"-------------------------------------------------------------------------------
function! s:HelpJump ( type )
	"
	" get help for the word in the line
	"
	" the name under the cursor can consist of these characters:
	"   <letters> <numbers> _ < > [ ] <space>
	" but never end with a space
	"
	let line = getline('.')
	let line = matchstr( line, '^[[:alnum:]_<>[\] -]*[[:alnum:]_<>[\]-]\ze\s*$' )
	"
	" for type "policy": maybe the line above matches (can use simpler regex)
	if empty( line ) && a:type == 'policy' && line('.')-1 > 0
		let line = getline( line('.')-1 )
		let line = matchstr( line, '^\w\+\ze\s*$' )
	endif
	"
	if empty( line )
		call s:WarningMsg ( 'CMake : No '.a:type.' under the cursor.' )
		return
	endif
	"
	call s:Help ( a:type, line )
  "
endfunction    " ----------  end of function s:HelpJump  ----------

"-------------------------------------------------------------------------------
" s:ShowCache : Show the cache.   {{{1
"-------------------------------------------------------------------------------
function! s:ShowCache ( args )

	" correct flags?
	if a:args =~ '^\s*$'
		let args = '-L'
	elseif 1
		let args = a:args
	else
		call s:ErrorMsg ( 'CMake : Unknown option for cache: '.a:args )
		return
	endif

	if s:OpenBuffer ( 'CMake - cache', 'showdir' )
		silent exe 'nmap <silent> <buffer> q             :close<CR>'
	endif

	" get the cache
	exe	'cd '.fnameescape( s:BuildLocation )

	let [ success, text ] = s:TextFromSystem ( shellescape( s:CMake_Executable ).' -N '.args )
	let location = fnamemodify ( s:BuildLocation, ':p' )

	cd -

	if success == 0
		close
		redraw                                      " redraw after cclose, before echoing
		call s:WarningMsg ( 'CMake : Could not obtain the cache.' )
		return
	endif

	call s:RenameBuffer ( location.'/CMake - cache' )
	call s:UpdateBuffer ( text )

endfunction    " ----------  end of function s:ShowCache  ----------

"-------------------------------------------------------------------------------
" s:StartCCMake : Start 'ccmake' in using xterm in the background.   {{{1
"-------------------------------------------------------------------------------
function! s:StartCCMake ( args )

	if ! s:EnabledCCMake || ! executable ( s:Xterm_Executable )
		return
	endif

	let title = 'CCMake'

	if a:args == '' && isdirectory ( s:BuildLocation )
		let title .= ' : '.fnamemodify( s:BuildLocation, ':p' )
		let param = shellescape ( s:BuildLocation )
	elseif a:args == '' && isdirectory ( s:ProjectDir )
		let title .= ' : '.fnamemodify( s:ProjectDir, ':p' )
		let param = shellescape ( s:ProjectDir )
	else
		let title .= ' : "'.a:args.'"'
		let param = escape ( a:args, '%#' )
	endif

	silent exe '!'.s:Xterm_Executable.' '.g:Xterm_Options
				\ .' -title '.shellescape( title )
				\ .' -e '.shellescape( s:CMake_CCMakeExec.' '.param ).' &'

endfunction    " ----------  end of function s:StartCCMake  ----------

"-------------------------------------------------------------------------------
" s:StartGui : Start 'cmake-gui' in the background.   {{{1
"-------------------------------------------------------------------------------
function! s:StartGui ( args )

	if ! s:EnabledCMakeGui
		return
	endif

	if s:MSWIN
		let param = ''   " cmake-gui under Windows does not seem to support cmd.-line args
	elseif a:args == '' && isdirectory ( s:BuildLocation )
		let param = shellescape ( s:BuildLocation )
	elseif a:args == '' && isdirectory ( s:ProjectDir )
		let param = shellescape ( s:ProjectDir )
	else
		let param = escape ( a:args, '%#' )
	endif

	if s:MSWIN
		silent exe '!start '.shellescape( s:CMake_GuiExec ).' '.param
	else
		silent exe '!'.shellescape( s:CMake_GuiExec ).' '.param.' &'
	endif

endfunction    " ----------  end of function s:StartGui  ----------

" }}}1
"-------------------------------------------------------------------------------

" =====================================================================================
"  vim: foldmethod=marker
