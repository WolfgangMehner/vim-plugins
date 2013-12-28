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
let s:WorldAvailable = 1
"
let s:Enabled = 1
"
if ! s:WorldAvailable
	let s:Enabled = 0
endif
"
" custom commands {{{2
"
if s:Enabled == 1
	command! -bang -nargs=* -complete=file Hello              :echo "Hello world (<bang>): ".<q-args>
	command!       -nargs=0                HelloHelp          :call mmtoolbox#helloworld#HelpPlugin()
else
	"
	" Disabled : Print why the script is disabled.   {{{3
	function! mmtoolbox#helloworld#Disabled ()
		let txt = "HelloWorld tool not working:\n"
		if ! s:WorldAvailable
			let txt .= "world not available (say what!?)"
		else
			let txt .= "unknown reason"
		endif
		call s:ImportantMsg ( txt )
		return
	endfunction    " ----------  end of function mmtoolbox#helloworld#Disabled  ----------
	" }}}3
	"
	command! -nargs=* HelloHelp :call mmtoolbox#helloworld#Disabled()
	"
endif
"
" }}}2
"
"-------------------------------------------------------------------------------
" GetInfo : Initialize the script.   {{{1
"-------------------------------------------------------------------------------
function! mmtoolbox#helloworld#GetInfo ()
	"
	" returns [ <prettyname>, <version>, <flag1>, <flag2>, ... ]
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
"
"-------------------------------------------------------------------------------
" Property : Various settings.   {{{1
"-------------------------------------------------------------------------------
function! mmtoolbox#helloworld#Property ( mode, key, ... )
	"
	" check the mode
	if a:mode !~ 'echo\|get\|set'
		return s:ErrorMsg ( 'HelloWorld : Unknown mode: '.a:mode )
	endif
	"
	" check 3rd argument for 'set'
	if a:mode == 'set'
		if a:0 == 0
			return s:ErrorMsg ( 'HelloWorld : Not enough arguments for mode "set".' )
		endif
		let val = a:1
	endif
	"
	" check the key
	if a:key == 'enabled'
		let var = 's:Enabled'
	else
		return s:ErrorMsg ( 'HelloWorld : Unknown option: '.a:key )
	endif
	"
	" perform the action
	if a:mode == 'echo'
		exe 'echo '.var
		return
	elseif a:mode == 'get'
		exe 'return '.var
	else
		" action is 'set', but key is non of the above
		return s:ErrorMsg ( 'HelloWorld : Option is read-only, can not set: '.a:key )
	endif
	"
endfunction    " ----------  end of function mmtoolbox#helloworld#Property  ----------
"
"-------------------------------------------------------------------------------
" HelpPlugin : Plugin help.   {{{1
"-------------------------------------------------------------------------------
function! mmtoolbox#helloworld#HelpPlugin ()
	" TODO: choose a topic other than 'toolbox'
	try
		help toolbox
	catch
		exe 'helptags '.s:plugin_dir.'/doc'
		help toolbox
	endtry
endfunction    " ----------  end of function mmtoolbox#helloworld#HelpPlugin  ----------
"
"-------------------------------------------------------------------------------
" Modul setup (abort early?).   {{{1
"-------------------------------------------------------------------------------
if s:Enabled == 0
	finish
endif
"
"-------------------------------------------------------------------------------
" Implement : Implement the tool.   {{{1
"-------------------------------------------------------------------------------
function! mmtoolbox#helloworld#Implement ()
	"
	" TODO
	"
	return
endfunction    " ----------  end of function mmtoolbox#helloworld#Implement  ----------
" }}}1
"-------------------------------------------------------------------------------
"
" =====================================================================================
"  vim: foldmethod=marker
