"===============================================================================
"
"          File:  bashdb.vim
" 
"   Description:  Part of the Bash-Support toolbox.
"
"                 Vim/gVim integration of BashDB.
"
"                 See help file bashdbintegration.txt .
" 
"   VIM Version:  7.0+
"        Author:  Wolfgang Mehner, wolfgang-mehner@web.de
"  Organization:  
"       Version:  see variable g:BashDB_Version below
"       Created:  28.09.2017
"      Revision:  -
"       License:  Copyright (c) 2017-2017, Wolfgang Mehner
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

"-------------------------------------------------------------------------------
" === Basic checks ===   {{{1
"-------------------------------------------------------------------------------

" need at least 7.3
if v:version < 703
	echohl WarningMsg
	echo 'The plugin mmtoolbox/bashdb.vim needs Vim version >= 7.3.'
	echohl None
	finish
endif

" prevent duplicate loading
" need compatible
if &cp || ( exists('g:BashDB_Version') && ! exists('g:BashDB_DevelopmentOverwrite') )
	finish
endif

let g:BashDB_Version= '0.5'                  " version number of this script; do not change

"-------------------------------------------------------------------------------
" === Auxiliary functions ===   {{{1
"-------------------------------------------------------------------------------

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

function! s:ApplyDefaultSetting ( varname, value )
	if ! exists ( 'g:'.a:varname )
		let { 'g:'.a:varname } = a:value
	endif
endfunction    " ----------  end of function s:ApplyDefaultSetting  ----------

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

"-------------------------------------------------------------------------------
" s:GetGlobalSetting : Get a setting from a global variable.   {{{2
"
" Parameters:
"   varname - name of the variable (string)
"   glbname - name of the global variable (string, optional)
" Returns:
"   -
"
" If 'glbname' is given, it is used as the name of the global variable.
" Otherwise the global variable will also be named 'varname'.
"
" If g:<glbname> exists, assign:
"   s:<varname> = g:<glbname>
"-------------------------------------------------------------------------------

function! s:GetGlobalSetting ( varname, ... )
	let lname = a:varname
	let gname = a:0 >= 1 ? a:1 : lname
	if exists ( 'g:'.gname )
		let { 's:'.lname } = { 'g:'.gname }
	endif
endfunction    " ----------  end of function s:GetGlobalSetting  ----------

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

	let ret = -2

	" highlight prompt
	if a:0 == 0 || a:1 == 'normal'
		echohl Search
	elseif a:1 == 'warning'
		echohl Error
	else
		echoerr 'Unknown option : "'.a:1.'"'
		return
	end

	" question
	echo a:prompt.' [y/n]: '

	" answer: "y", "n", "ESC" or "CTRL-C"
	while ret == -2
		let c = nr2char( getchar() )

		if c == "y"
			let ret = 1
		elseif c == "n"
			let ret = 0
		elseif c == "\<ESC>" || c == "\<C-C>"
			let ret = -1
		endif
	endwhile

	" reset highlighting
	echohl None

	return ret
endfunction    " ----------  end of function s:Question  ----------

"-------------------------------------------------------------------------------
" s:Redraw : Redraw depending on whether a GUI is running.   {{{2
"
" Example:
"   call s:Redraw ( 'r!', '' )
" Clear the screen and redraw in a terminal, do nothing when a GUI is running.
"
" Parameters:
"   cmd_term - redraw command in terminal mode (string)
"   cmd_gui -  redraw command in GUI mode (string)
" Returns:
"   -
"-------------------------------------------------------------------------------

function! s:Redraw ( cmd_term, cmd_gui )
	if has('gui_running')
		let cmd = a:cmd_gui
	else
		let cmd = a:cmd_term
	endif

	let cmd = substitute ( cmd, 'r\%[edraw]', 'redraw', '' )
	if cmd != ''
		silent exe cmd
	endif
endfunction    " ----------  end of function s:Redraw  ----------

"-------------------------------------------------------------------------------
" s:ShellParseArgs : Turn cmd.-line arguments into a list.   {{{2
"
" Parameters:
"   line - the command-line arguments to parse (string)
" Returns:
"   list - the arguments as a list (list)
"-------------------------------------------------------------------------------

function! s:ShellParseArgs ( line )

	let list = []
	let curr = ''

	let line = a:line

	while line != ''

		if match ( line, '^\s' ) != -1
			" non-escaped space -> finishes current argument
			let line = matchstr ( line, '^\s\+\zs.*' )
			if curr != ''
				call add ( list, curr )
				let curr = ''
			endif
		elseif match ( line, "^'" ) != -1
			" start of a single-quoted string, parse past next single quote
			let mlist = matchlist ( line, "^'\\([^']*\\)'\\(.*\\)" )
			if empty ( mlist )
				throw "ShellParseArgs:Syntax:no matching quote '"
			endif
			let curr .= mlist[1]
			let line  = mlist[2]
		elseif match ( line, '^"' ) != -1
			" start of a double-quoted string, parse past next double quote
			let mlist = matchlist ( line, '^"\(\%([^\"]\|\\.\)*\)"\(.*\)' )
			if empty ( mlist )
				throw 'ShellParseArgs:Syntax:no matching quote "'
			endif
			let curr .= substitute ( mlist[1], '\\\([\"]\)', '\1', 'g' )
			let line  = mlist[2]
		elseif match ( line, '^\\' ) != -1
			" escape sequence outside of a string, parse one additional character
			let mlist = matchlist ( line, '^\\\(.\)\(.*\)' )
			if empty ( mlist )
				throw 'ShellParseArgs:Syntax:single backspace \'
			endif
			let curr .= mlist[1]
			let line  = mlist[2]
		else
			" otherwise parse up to next space
			let mlist = matchlist ( line, '^\(\S\+\)\(.*\)' )
			let curr .= mlist[1]
			let line  = mlist[2]
		endif
	endwhile

	" add last argument
	if curr != ''
		call add ( list, curr )
	endif

	return list
endfunction    " ----------  end of function s:ShellParseArgs  ----------

"-------------------------------------------------------------------------------
" s:SID : Return the <SID>.   {{{2
"
" Parameters:
"   -
" Returns:
"   SID - the SID of the script (string)
"-------------------------------------------------------------------------------

function! s:SID ()
	return matchstr ( expand('<sfile>'), '<SNR>\zs\d\+\ze_SID$' )
endfunction    " ----------  end of function s:SID  ----------

"-------------------------------------------------------------------------------
" s:UserInput : Input after a highlighted prompt.   {{{2
"
" Parameters:
"   prompt - the prompt (string)
"   text - the default input (string)
"   compl - completion (string, optional)
"   clist - list, if 'compl' is "customlist" (list, optional)
" Returns:
"   input - the user input, an empty sting if the user hit <ESC> (string)
"-------------------------------------------------------------------------------

function! s:UserInput ( prompt, text, ... )

	echohl Search                                         " highlight prompt
	call inputsave()                                      " preserve typeahead
	if a:0 == 0 || a:1 == ''
		let retval = input( a:prompt, a:text )
	elseif a:1 == 'customlist'
		let s:UserInputList = a:2
		let retval = input( a:prompt, a:text, 'customlist,<SNR>'.s:SID().'_UserInputEx' )
		let s:UserInputList = []
	else
		let retval = input( a:prompt, a:text, a:1 )
	endif
	call inputrestore()                                   " restore typeahead
	echohl None                                           " reset highlighting

	let retval  = substitute( retval, '^\s\+', "", "" )   " remove leading whitespaces
	let retval  = substitute( retval, '\s\+$', "", "" )   " remove trailing whitespaces

	return retval

endfunction    " ----------  end of function s:UserInput ----------

"-------------------------------------------------------------------------------
" s:UserInputEx : ex-command for s:UserInput.   {{{3
"-------------------------------------------------------------------------------
function! s:UserInputEx ( ArgLead, CmdLine, CursorPos )
	if empty( a:ArgLead )
		return copy( s:UserInputList )
	endif
	return filter( copy( s:UserInputList ), 'v:val =~ ''\V\<'.escape(a:ArgLead,'\').'\w\*''' )
endfunction    " ----------  end of function s:UserInputEx  ----------
" }}}3
"-------------------------------------------------------------------------------

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

"-------------------------------------------------------------------------------
" === Module setup ===   {{{1
"-------------------------------------------------------------------------------

"-------------------------------------------------------------------------------
" == Platform specific items ==   {{{2
"-------------------------------------------------------------------------------

let s:MSWIN = has("win16") || has("win32")   || has("win64")     || has("win95")
let s:UNIX  = has("unix")  || has("macunix") || has("win32unix")

let s:installation = 'standalone'
if exists ( 'g:Toolbox_Version' )
	let s:installation = 'toolbox'
endif

if s:MSWIN
	" MS Windows

	let s:plugin_dir = substitute( expand('<sfile>:p:h:h:h:h'), '\\', '/', 'g' )
else
	" Linux/Unix

	let s:plugin_dir = expand('<sfile>:p:h:h:h:h')
endif

"-------------------------------------------------------------------------------
" == Various settings ==   {{{2
"-------------------------------------------------------------------------------

let s:BashDB_DDD_Exec   = 'ddd'
let s:BashDB_Executable = 'bashdb'

call s:GetGlobalSetting ( 'BashDB_DDD_Exec' )
call s:GetGlobalSetting ( 'BashDB_Executable', 'BASH_bashdb' )
call s:GetGlobalSetting ( 'BashDB_Executable' )

let s:BashDB_Debugger     = 'xterm'             " one of s:BashDB_DebuggerList
let s:BashDB_DebuggerList = [ 'xterm' ]
if executable ( s:BashDB_DDD_Exec )
	let s:BashDB_DebuggerList += [ 'ddd' ]
endif
if has ( 'terminal' )
	let s:BashDB_DebuggerList += [ 'terminal', 'integrated' ]
endif
call sort ( s:BashDB_DebuggerList )

call s:GetGlobalSetting ( 'BashDB_Debugger', 'BASH_Debugger' )
call s:GetGlobalSetting ( 'BashDB_Debugger' )

if s:BashDB_Debugger == 'term'
	let s:BashDB_Debugger   = 'xterm'             " downwards compatibility with Bash-Support
endif

let s:Xterm_Executable = 'xterm'

call s:GetGlobalSetting ( 'Xterm_Executable' )
call s:ApplyDefaultSetting ( 'Xterm_Options', '-fa courier -fs 12 -geometry 80x24' )

"-------------------------------------------------------------------------------
" == Checks ==   {{{2
"-------------------------------------------------------------------------------

let s:Enabled = 1

if s:MSWIN || ! executable( s:BashDB_Executable )
	let s:Enabled = 0
endif

"-------------------------------------------------------------------------------
" == Custom commands ==   {{{2
"-------------------------------------------------------------------------------

" Cmd.-line completion   {{{3

"-------------------------------------------------------------------------------
" s:GetDebuggerList : For cmd.-line completion.
"-------------------------------------------------------------------------------
function! s:DebuggerList (...)
	return join ( s:BashDB_DebuggerList, "\n" )
endfunction    " ----------  end of function s:DebuggerList  ----------

" }}}3

if s:Enabled == 1
	command!       -nargs=* -complete=file                      BashDB            :call <SID>Run(<q-args>)
	command!       -nargs=*                                     BashDBCommand     :call <SID>SendCmd(<q-args>)
	command! -bang -nargs=? -complete=custom,<SID>DebuggerList  BashDBDebugger    :call mmtoolbox#bash#bashdb#Property('<bang>'=='!'?'echo':'set','debugger',<q-args>)
	command! -bang -nargs=? -complete=shellcmd                  BashDBExecutable  :call mmtoolbox#bash#bashdb#Property('<bang>'=='!'?'echo':'set','executable',<q-args>)

	command!       -nargs=0                BashDBHelp          :call <SID>HelpPlugin()
	command! -bang -nargs=?                BashDBSettings      :call <SID>Settings(('<bang>'=='!')+str2nr(<q-args>))
else

	" s:Disabled : Print why the script is disabled.   {{{3
	function! s:Disabled ()
		let txt = "BashDB tool not working:\n"
		if s:MSWIN
			let txt .= "BashDB currently not supported under Windows"
		elseif ! executable( s:BashDB_Executable )
			let txt .= "BashDB not executable"
		else
			let txt .= "unknown reason\n"
			let txt .= "see :help toolbox-bashdb"
		endif
		call s:ImportantMsg ( txt )
		return
	endfunction    " ----------  end of function s:Disabled  ----------
	" }}}3

	command! -bang -nargs=* BashDB          :call <SID>Disabled()
	command!       -nargs=0 BashDBHelp      :call <SID>HelpPlugin()
	command! -bang -nargs=? BashDBSettings  :call <SID>Settings(('<bang>'=='!')+str2nr(<q-args>))

endif
" }}}2
"-------------------------------------------------------------------------------

"-------------------------------------------------------------------------------
" GetInfo : Initialize the script.   {{{1
"-------------------------------------------------------------------------------
function! mmtoolbox#bash#bashdb#GetInfo ()
	if s:Enabled
		return [ 'BashDB', g:BashDB_Version ]
	else
		return [ 'BashDB', g:BashDB_Version, 'disabled' ]
	endif
endfunction    " ----------  end of function mmtoolbox#bash#bashdb#GetInfo  ----------
"
"-------------------------------------------------------------------------------
" AddMaps : Add maps.   {{{1
"-------------------------------------------------------------------------------
function! mmtoolbox#bash#bashdb#AddMaps ()
endfunction    " ----------  end of function mmtoolbox#bash#bashdb#AddMaps  ----------
"
"-------------------------------------------------------------------------------
" AddMenu : Add menus.   {{{1
"-------------------------------------------------------------------------------
function! mmtoolbox#bash#bashdb#AddMenu ( root, esc_mapl )

	exe 'amenu <silent> '.a:root.'.&run\ debugger<Tab>:BashDB   :BashDB<CR>'

	exe 'amenu '.a:root.'.-Sep01- <Nop>'

	exe 'amenu '.a:root.'.set\ &debugger<Tab>:BashDBDebugger      :BashDBDebugger '
	exe 'amenu '.a:root.'.set\ &executable<Tab>:BashDBExecutable  :BashDBExecutable '

	exe 'amenu '.a:root.'.-Sep02- <Nop>'

	exe 'amenu <silent> '.a:root.'.&settings<Tab>:BashDBSettings      :BashDBSettings<CR>'
	exe 'amenu <silent> '.a:root.'.tool\ &help<Tab>:BashDBHelp        :BashDBHelp<CR>'

endfunction    " ----------  end of function mmtoolbox#bash#bashdb#AddMenu  ----------
"
"-------------------------------------------------------------------------------
" Property : Various settings.   {{{1
"-------------------------------------------------------------------------------
function! mmtoolbox#bash#bashdb#Property ( mode, key, ... )

	" check the mode
	if a:mode !~ 'echo\|get\|set'
		return s:ErrorMsg ( 'BashDB : Unknown mode: '.a:mode )
	endif

	" check 3rd argument for 'set'
	if a:mode == 'set'
		if a:0 == 0
			return s:ErrorMsg ( 'BashDB : Not enough arguments for mode "set".' )
		endif
		let val = a:1
	endif

	" check the key
	if a:key == 'enabled'
		let var = 's:Enabled'
	elseif a:key == 'debugger'
		let var = 's:BashDB_Debugger'
	elseif a:key == 'executable'
		let var = 's:BashDB_Executable'
	else
		return s:ErrorMsg ( 'BashDB : Unknown option: '.a:key )
	endif

	" perform the action
	if a:mode == 'echo'
		echo {var}
		return
	elseif a:mode == 'get'
		return {var}
	elseif a:key == 'debugger'
		" check against the list of debuggers
		if index ( s:BashDB_DebuggerList, val ) > -1
			let s:BashDB_Debugger = val
		else
			return s:ErrorMsg ( 'BashDB : Debugger unknown or not not enabled: '.val )
		endif
	elseif a:key == 'executable'
		" check against the list of debuggers
		if executable ( val )
			let s:BashDB_Executable = val
		else
			return s:ErrorMsg ( 'BashDB : Not executable: '.val )
		endif
	else
		" action is 'set', but key is non of the above
		return s:ErrorMsg ( 'BashDB : Option is read-only, can not set: '.a:key )
	endif

endfunction    " ----------  end of function mmtoolbox#bash#bashdb#Property  ----------
"
"-------------------------------------------------------------------------------
" s:HelpPlugin : Plugin help.   {{{1
"-------------------------------------------------------------------------------
function! s:HelpPlugin ()
	try
		help bashdb-integration
	catch
		exe 'helptags '.s:plugin_dir.'/doc'
		help bashdb-integration
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

	let bashdb_status = executable( s:BashDB_Executable ) ? '' : ' (not executable)'
	let ddd_status    = executable( s:BashDB_DDD_Exec   ) ? '' : ' (not executable)'

	let	txt = " BashDB-Tool settings\n\n"
				\ .'     plug-in installation :  '.s:installation.' on '.sys_name."\n"
				\ .'        BashDB executable :  '.s:BashDB_Executable.bashdb_status."\n"
	if a:verbose
		let txt .=
					\  '           DDD executable :  '.s:BashDB_DDD_Exec.ddd_status."\n"
	endif
	if s:installation == 'toolbox'
		let txt .=
					\  '            using toolbox :  version '.g:Toolbox_Version."\n"
	endif
	if a:verbose
		let	txt .= "\n"
					\ .'                 debugger :  '.s:BashDB_Debugger."\n"
	endif
	let txt .=
				\  "________________________________________________________________________________\n"
				\ ." BashDB-Tool, Version ".g:BashDB_Version." / Wolfgang Mehner / wolfgang-mehner@web.de\n\n"

	if a:verbose == 2
		split BashDB_Settings.txt
		put = txt
	else
		echo txt
	endif
endfunction    " ----------  end of function s:Settings  ----------

"-------------------------------------------------------------------------------
" s:Run : Run the debugger.   {{{1
"-------------------------------------------------------------------------------
function! s:Run ( args )

	if &filetype == 'sh' || &filetype == 'bash'
		silent exe 'update'
	endif

	let	script_name	= shellescape( expand('%:p') )

	if a:args != ''
		let script_args = ' '.a:args
	elseif exists( 'b:BASH_ScriptCmdLineArgs' )
		let script_args = ' '.b:BASH_ScriptCmdLineArgs
	else
		let script_args = ''
	endif

	if s:BashDB_Debugger == 'xterm'
		" debugger is 'bashdb' in xterm
		if ! executable( s:BashDB_Executable )
			return s:WarningMsg ( s:BashDB_Executable.' is not executable or not installed! ' )
		endif

		silent exe  '!xterm '.g:Xterm_Options
					\ .' -title '.shellescape( 'BashDB - '.expand('%:t') )
					\ .' -e '.s:BashDB_Executable.' -- '.script_name.script_args.' &'
	elseif s:BashDB_Debugger == 'ddd'
		" debugger is 'ddd'
		if ! executable( s:BashDB_DDD_Exec )
			return s:WarningMsg ( s:BashDB_DDD_Exec.' is not executable or not installed! ' )
		endif

		silent exe '!ddd --debugger '.s:BashDB_Executable.' '.script_name.script_args.' &'
	elseif s:BashDB_Debugger == 'terminal'
		call s:ImportantMsg ( 'not implemented yet' )
	elseif s:BashDB_Debugger == 'integrated'
		call s:StartInternal ( script_name.script_args )
	endif
endfunction    " ----------  end of function s:Run  ----------

"-------------------------------------------------------------------------------
" === Internal BashDB execution ===   {{{1
"-------------------------------------------------------------------------------

"-------------------------------------------------------------------------------
" == Debugger state ==   {{{2
"
" State of the internal debugger:
"-------------------------------------------------------------------------------

let s:debug_status   = ''
let s:debug_buf_ctrl = -1
let s:debug_buf_io   = -1

let s:debug_buf_script = -1
let s:debug_win_script = -1

"-------------------------------------------------------------------------------
" s:StartInternal : Start the internal debugger.   {{{2
"
" Parameters:
"   args - cmd.-line arguments, script and its arguments (string)
" Returns:
"   -
"-------------------------------------------------------------------------------
function! s:StartInternal ( args )

	if s:debug_status != ''
		return s:WarningMsg ( 'debugger already running' )
	endif

	" bashdb: uses --tty the other way around
	let is_bashdb = 0
	let name_pty = 'BashDB - I/O'
	let name_job = 'BashDB - CTRL'
	if s:BashDB_Executable =~? '\cbashdb'
		let is_bashdb = 1
		let name_pty = 'BashDB - CTRL'
		let name_job = 'BashDB - I/O'
	endif

	" script buffer/window
	let s:debug_buf_script = bufnr( '%' )
	let s:debug_win_script = win_getid( winnr() )

	" only the script I/O appears here
	let s:debug_buf_io = term_start ( 'NONE', {
				\ 'term_name' : name_pty,
				\ } )

	let tty = term_gettty ( s:debug_buf_io )

	" start in another terminal, the control commands are run through this terminal
	let arg_list  = [ s:BashDB_Executable ]
	let arg_list += [ '--tty', tty, '-x', tty ]
	let arg_list += s:ShellParseArgs ( a:args )

	" bashdb: switch order of windows (also see 'curwin' below)
	if is_bashdb
		belowright new
	endif

	let s:debug_buf_ctrl = term_start ( arg_list, {
				\ 'term_name' : name_job,
				\ 'curwin'    : is_bashdb,
				\ 'exit_cb'   : function ( 's:EndInternal' ),
				\ } )

	" bashdb: switch the buffers
	if is_bashdb
		let [ s:debug_buf_io, s:debug_buf_ctrl ] = [ s:debug_buf_ctrl, s:debug_buf_io ]
	endif

	" now we're cooking
	let s:debug_status = 'running'

	" set up script buffer
  call win_gotoid( s:debug_win_script )

	command! -buffer -nargs=0  Continue  :call <SID>SendCmd('continue')
	command! -buffer -nargs=0  Step      :call <SID>SendCmd('step')

	command! -buffer -bang -nargs=0  Break    :call <SID>Breakpoint('<bang>'=='!')
	command! -buffer       -nargs=0  Display  :call <SID>DisplayVariable()

	if has( 'menu' )
		anoremenu <silent> WinBar.Run    :BashDBCommand run<CR>
		anoremenu <silent> WinBar.Cont   :Continue<CR>
		anoremenu <silent> WinBar.Step   :Step<CR>
		anoremenu <silent> WinBar.Quit   :BashDBCommand quit<CR>

		anoremenu <silent> WinBar.Breakpoint   :Break<CR>
		anoremenu <silent> WinBar.Break\ Once  :Break!<CR>
		anoremenu <silent> WinBar.Display      :Display<CR>
	endif
endfunction    " ----------  end of function s:StartInternal  ----------

"-------------------------------------------------------------------------------
" s:EndInternal : Callback for BashDB exiting.   {{{2
"
" Parameters:
"   job - the job (job)
"   status - the status (number)
" Returns:
"   -
"-------------------------------------------------------------------------------
function! s:EndInternal ( job, status )

	" remove the debugger buffers
	exe 'bwipe! '.s:debug_buf_io
	if a:status == 0
		exe 'bwipe! '.s:debug_buf_ctrl
	endif

	let s:debug_status = ''

  call win_gotoid( s:debug_win_script )

	" remove the menus and commands
	if has( 'menu' )
		aunmenu WinBar.Run
		aunmenu WinBar.Cont
		aunmenu WinBar.Step
		aunmenu WinBar.Quit

		aunmenu WinBar.Breakpoint
		aunmenu WinBar.Break\ Once
		aunmenu WinBar.Display
	endif

	delcommand Continue
	delcommand Step

	delcommand Break
	delcommand Display

	call s:Redraw ( 'r!', 'r' )

	if a:status == 0
		call s:ImportantMsg ( s:BashDB_Executable.' done' )
	else
		call s:ImportantMsg ( s:BashDB_Executable.' returned with error code '.a:status, '  use :bwipe! in the debugger buffer to properly close it' )
	endif

endfunction    " ----------  end of function s:EndInternal  ----------

"-------------------------------------------------------------------------------
" s:SendCmd : Send a command to the debugger.   {{{2
"
" Parameters:
"   cmd - the command (string)
" Returns:
"   -
"-------------------------------------------------------------------------------
function! s:SendCmd ( cmd )
	if s:debug_status == ''
		return s:WarningMsg ( 'debugger not running' )
	endif

	call term_sendkeys ( s:debug_buf_ctrl, a:cmd."\r" )
endfunction    " ----------  end of function s:SendCmd  ----------

"-------------------------------------------------------------------------------
" s:Breakpoint : Send a break commands   {{{2
"
" Send a 'break' or 'tbreak' command.
"
" Parameters:
"   once - if true, send tbreak, otherwise send break (integer)
" Returns:
"   -
"-------------------------------------------------------------------------------
function! s:Breakpoint ( once )

	let filename = expand ( '%:p' )
	let fileline = line ( '.' )

	if a:once
		call s:SendCmd ( 'tbreak '.filename.':'.fileline )
	else
		call s:SendCmd ( 'break  '.filename.':'.fileline )
	endif
endfunction    " ----------  end of function s:Breakpoint  ----------

"-------------------------------------------------------------------------------
" s:DisplayVariable : Send a display command.   {{{2
"
" Send a 'display' command for the variable under the cursor.
"
" Parameters:
"   -
" Returns:
"   -
"-------------------------------------------------------------------------------
function! s:DisplayVariable ()

	let buf_line = getline('.')
	let buf_pos  = col('.') - 1
	let pattern  = '$\?\k\+\|${.}\|$.'
	let cnt      = 1
	let pick     = ''

	while 1
		let m_end = matchend ( buf_line, pattern, 0, cnt ) - 1
		if m_end < 0
			let pick = ''
			break
		elseif m_end >= buf_pos
			let m_start = match ( buf_line, pattern, 0, cnt )
			if m_start <= buf_pos | let pick = buf_line[ m_start : m_end ]
			else                  | let pick = ''                          | endif
			break
		endif
		let cnt += 1
	endwhile

	if pick == ''
		return s:ImportantMsg ( 'no variable under the cursor' )
	endif

	let pick = substitute ( pick, '^[^$]', '$&', '' )

	call s:SendCmd ( 'display '.pick )
endfunction    " ----------  end of function s:DisplayVariable  ----------

" }}}2
"-------------------------------------------------------------------------------

" }}}1
"-------------------------------------------------------------------------------

" =====================================================================================
"  vim: foldmethod=marker shiftwidth=2 tabstop=2
