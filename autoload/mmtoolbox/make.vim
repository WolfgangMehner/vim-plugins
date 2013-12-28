"===============================================================================
"
"          File:  make.vim
" 
"   Description:  Part of the C-Support toolbox.
"
"                 Vim/gVim integration of Make.
"
"                 See help file toolboxmake.txt .
" 
"   VIM Version:  7.0+
"        Author:  Wolfgang Mehner, wolfgang-mehner@web.de
"  Organization:  
"       Version:  see variable g:Make_Version below
"       Created:  06.05.2013
"      Revision:  10.11.2013
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
let g:Make_Version= '1.0.1'     " version number of this script; do not change
"
"-------------------------------------------------------------------------------
" Auxiliary functions   {{{1
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
	command! -bang -nargs=* -complete=file MakeCmdlineArgs   :call mmtoolbox#make#Property('<bang>'=='!'?'echo':'set','cmdline-args',<q-args>)
	command! -bang -nargs=? -complete=file MakeFile          :call mmtoolbox#make#Property('<bang>'=='!'?'echo':'set','makefile',<q-args>)
	command!       -nargs=* -complete=file Make              :call mmtoolbox#make#Run(<q-args>)
	command!       -nargs=0                MakeHelp          :call mmtoolbox#make#Help()
	command! -bang -nargs=0                MakeSettings      :call mmtoolbox#make#Settings('<bang>'=='!')
else
	"
	" Disabled : Print why the script is disabled.   {{{3
	function! mmtoolbox#make#Disabled ()
		let txt = "Make tool not working:\n"
		if ! executable ( s:Make_Executable )
			let txt .= "make not executable (".s:Make_Executable.")\n"
			let txt .= "see :help toolbox-make-config"
		else
			let txt .= "unknown reason\n"
			let txt .= "see :help toolbox-make"
		endif
		echohl Search
		echo txt
		echohl None
		return
	endfunction    " ----------  end of function mmtoolbox#make#Disabled  ----------
	" }}}3
	"
	command! -bang -nargs=* Make          :call mmtoolbox#make#Disabled()
	command!       -nargs=0 MakeHelp      :call mmtoolbox#make#Help()
	command! -bang -nargs=0 MakeSettings  :call mmtoolbox#make#Settings('<bang>'=='!')
	"
endif
"
" }}}2
"
"-------------------------------------------------------------------------------
" GetInfo : Initialize the script.   {{{1
"-------------------------------------------------------------------------------
function! mmtoolbox#make#GetInfo ()
	if s:Enabled
		return [ 'Make', g:Make_Version ]
	else
		return [ 'Make', g:Make_Version, 'disabled' ]
	endif
endfunction    " ----------  end of function mmtoolbox#make#GetInfo  ----------
"
"-------------------------------------------------------------------------------
" AddMaps : Add maps.   {{{1
"-------------------------------------------------------------------------------
function! mmtoolbox#make#AddMaps ()
endfunction    " ----------  end of function mmtoolbox#make#AddMaps  ----------
"
"-------------------------------------------------------------------------------
" AddMenu : Add menus.   {{{1
"-------------------------------------------------------------------------------
function! mmtoolbox#make#AddMenu ( root, esc_mapl )
	"
	exe 'amenu '.a:root.'.run\ &make<Tab>:Make            :Make<CR>'
	exe 'amenu '.a:root.'.make\ &clean<Tab>:Make\ clean   :Make clean<CR>'
	exe 'amenu '.a:root.'.make\ &doc<Tab>:Make\ doc       :Make doc<CR>'
	"
	exe 'amenu '.a:root.'.-Sep01- <Nop>'
	"
	exe 'amenu '.a:root.'.&choose\ make&file<Tab>:MakeFile                      :MakeFile<space>'
	exe 'amenu '.a:root.'.cmd\.\ line\ ar&g\.\ for\ make<Tab>:MakeCmdlineArgs   :MakeCmdlineArgs<space>'
	"
	exe 'amenu '.a:root.'.-Sep02- <Nop>'
	"
	exe 'amenu '.a:root.'.&help<Tab>:MakeHelp          :MakeHelp<CR>'
	exe 'amenu '.a:root.'.&settings<Tab>:MakeSettings  :MakeSettings<CR>'
	"
endfunction    " ----------  end of function mmtoolbox#make#AddMenu  ----------
"
"-------------------------------------------------------------------------------
" Property : Various settings.   {{{1
"-------------------------------------------------------------------------------
function! mmtoolbox#make#Property ( mode, key, ... )
	"
	" check the mode
	if a:mode !~ 'echo\|get\|set'
		return s:ErrorMsg ( 'Make : Unknown mode: '.a:mode )
	endif
	"
	" check 3rd argument for 'set'
	if a:mode == 'set'
		if a:0 == 0
			return s:ErrorMsg ( 'Make : Not enough arguments for mode "set".' )
		endif
		let val = a:1
	endif
	"
	" check the key
	if a:key == 'enabled'
		let var = 's:Enabled'
	elseif a:key == 'cmdline-args'
		let var = 's:CmdLineArgs'
	elseif a:key == 'makefile'
		let var = 's:Makefile'
	else
		return s:ErrorMsg ( 'Make : Unknown option: '.a:key )
	endif
	"
	" perform the action
	if a:mode == 'echo'
		exe 'echo '.var
		return
	elseif a:mode == 'get'
		exe 'return '.var
	elseif a:key == 'cmdline-args'
		let s:CmdLineArgs = val
	elseif a:key == 'makefile'
		" expand replaces the escape sequences from the cmdline
		if val == '' | let s:Makefile = ''
		else         | let s:Makefile = fnamemodify( expand( val ), ":p" )
		endif
	else
		" action is 'set', but key is non of the above
		return s:ErrorMsg ( 'Make : Option is read-only, can not set: '.a:key )
	endif
	"
endfunction    " ----------  end of function mmtoolbox#make#Property  ----------
"
"-------------------------------------------------------------------------------
" Help : Plugin help.   {{{1
"-------------------------------------------------------------------------------
function! mmtoolbox#make#Help ()
	try
		help toolbox-make
	catch
		exe 'helptags '.s:plugin_dir.'/doc'
		help toolbox-make
	endtry
endfunction    " ----------  end of function mmtoolbox#make#Help  ----------
"
"-------------------------------------------------------------------------------
" Settings : Plugin settings.   {{{1
"-------------------------------------------------------------------------------
function! mmtoolbox#make#Settings ( verbose )
	"
	if     s:MSWIN | let sys_name = 'Windows'
	elseif s:UNIX  | let sys_name = 'UNIX'
	else           | let sys_name = 'unknown' | endif
	"
	let make_status = executable( s:Make_Executable ) ? '<yes>' : '<no>'
	let make_file   = s:Makefile != '' ? s:Makefile : '(default) local Makefile'
	"
	let	txt = " Make-Support settings\n\n"
				\ .'     plug-in installation :  toolbox on '.sys_name."\n"
				\ .'          make executable :  '.s:Make_Executable."\n"
				\ .'                > enabled :  '.make_status."\n"
				\ .'            using toolbox :  version '.g:Toolbox_Version." by Wolfgang Mehner\n"
	if a:verbose
		let	txt .= "\n"
					\ .'                make file :  '.make_file."\n"
					\ .'           memorized args :  "'.s:CmdLineArgs."\"\n"
	endif
	let txt .=
				\  "________________________________________________________________________________\n"
				\ ." Make-Tool, Version ".g:Make_Version." / Wolfgang Mehner / wolfgang-mehner@web.de\n\n"
	"
	echo txt
endfunction    " ----------  end of function mmtoolbox#make#Settings  ----------
"
"-------------------------------------------------------------------------------
" Modul setup (abort early?).   {{{1
"-------------------------------------------------------------------------------
if s:Enabled == 0
	finish
endif
"
"-------------------------------------------------------------------------------
"
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
	" :TODO:18.08.2013 21:45:WM: 'cmdlinearg' is not correctly escaped for use under Windows
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
" =====================================================================================
"  vim: foldmethod=marker
