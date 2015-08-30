"===============================================================================
"
"          File:  worldview.vim
" 
"   Description:  Part of the C-Support toolbox.
" 
"                 Use Vim/gVim to see the world.
"
"                 OK, ...
"
"                 Use Vim to open external viewers for URLs, PDFs, images, ...
"                 Use internal viewers to read manpages, preview websites, ...
"                 If you should own books, you still will have to pick them up
"                 by hand though, sorry.
"
"                 See help file toolboxworldview.txt .
" 
"   VIM Version:  7.0+
"        Author:  Wolfgang Mehner, wolfgang-mehner@web.de
"  Organization:  
"       Version:  1.0
"       Created:  06.10.2014
"      Revision:  ---
"       License:  Copyright (c) 2014-2015, Wolfgang Mehner
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
	echo 'The plugin mmtoolbox/worldview.vim needs Vim version >= 7.'
	echohl None
	finish
endif
"
" prevent duplicate loading
" need compatible
if &cp || ( exists('g:WorldView_Version') && ! exists('g:WorldView_DevelopmentOverwrite') )
	finish
endif
let g:WorldView_Version= '0.9.0'     " version number of this script; do not change
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
	return 0
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
" s:GetVisualArea : Get the visual area.   {{{2
"
" Get the visual area using the register " and reset the register afterwards.
"
" Parameters:
"   -
" Returns:
"   selection - the visual selection (string)
"
" Credits:
"   The solution is take from Jeremy Cantrell, vim-opener, which is distributed
"   under the same licence as Vim itself.
"-------------------------------------------------------------------------------
function! s:GetVisualArea ()
	" windows:  register @* does not work
	" solution: recover area of the visual mode and yank,
	"           puts the selected area into the register @"
	"
	" save contents of register " and the 'clipboard' setting
	" set clipboard to it default value
	let reg_save     = getreg('"')
	let regtype_save = getregtype('"')
	let cb_save      = &clipboard
	set clipboard&
	"
	" get the register
	normal! gv""y
	let res = @"
	"
	" reset register " and 'clipboard'
	call setreg ( '"', reg_save, regtype_save )
	let &clipboard = cb_save
	"
	return res
endfunction    " ----------  end of function s:GetVisualArea  ----------
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
"----------------------------------------------------------------------
" s:UserInput : Input using a highlighting prompt.   {{{2
"
" Parameters:
"   prompt - prompt, shown to the user (string)
"   text   - default reply (string)
"   compl  - type of completion (string, optional)
"   list   - list for completion, if 'compl' is 'customlist' (list, optional)
" Returns:
"   retval - the user input (string)
"
" Returns an empty string if the input procedure was aborted by the user.
"
" For the different types of completion, see :help command-completion
"----------------------------------------------------------------------
"
" s:UserInputEx : ex-command for s:UserInput   {{{3
function! s:UserInputEx ( ArgLead, CmdLine, CursorPos )
	if empty( a:ArgLead )
		return copy( s:UserInputList )
	endif
	return filter( copy( s:UserInputList ), 'v:val =~ ''\V\<'.escape(a:ArgLead,'\').'\w\*''' )
endfunction    " ----------  end of function s:UserInputEx  ----------
"
" s:UserInputList : list for s:UserInput   {{{3
let s:UserInputList = []
" }}}3
"
function! s:UserInput ( prompt, text, ... )
	"
	echohl Search																					" highlight prompt
	call inputsave()																			" preserve typeahead
	if a:0 == 0 || a:1 == ''
		let retval = input( a:prompt, a:text )
	elseif a:1 == 'customlist'
		let s:UserInputList = a:2
		let retval = input( a:prompt, a:text, 'customlist,<SNR>'.s:SID().'_UserInputEx' )
		let s:UserInputList = []
	else
		let retval = input( a:prompt, a:text, a:1 )
	endif
	call inputrestore()																		" restore typeahead
	echohl None																						" reset highlighting
	"
	let retval  = substitute( retval, '^\s\+', "", "" )		" remove leading whitespaces
	let retval  = substitute( retval, '\s\+$', "", "" )		" remove trailing whitespaces
	"
	return retval
endfunction    " ----------  end of function s:UserInput ----------
"
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
	return 0
endfunction    " ----------  end of function s:WarningMsg  ----------
" }}}2
"-------------------------------------------------------------------------------
"
"-------------------------------------------------------------------------------
" s:CheckViewers : Check the viewers.   {{{1
"-------------------------------------------------------------------------------
function! s:CheckViewers ()
	"
	for val in s:Filetypes
		let val.enabled = 1
	endfor
	"
	return
endfunction    " ----------  end of function s:CheckViewers  ----------
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
"-------------------------------------------------------------------------------
" List of filetypes.
"
" Serves two purposes:
" - Keeps track of all filetypes. Ex-commands are created for every filetype:
"     :ViewPDF <file>     " for type PDF  
"     :ViewImage <file>   " for type Image
"     ...
" - Filetype recognition from filenames. Is used by the ex-command
"     :View <file>
"
" Each entry describes a filetype using a dictionary with the fields:
" - typename : name of the viewed objects, their filetype
"              (but might by more abstract, such as Image instead of JPG)
" - typehint : regexp to recognize files by their extension, name
" - enabled  : at least one view has been found
" - fallback : if true, this type a fallback and will not create an ex-command
" - preview  : generates a preview and not a view command
"-------------------------------------------------------------------------------
let s:Filetypes = [
			\	{	'typename' : 'Image',
			\		'typehint' : '\%(\.gif\|\.jpe\?g\|\.png\)$' },
			\	{	'typename' : 'Web',
			\		'typehint' : '\_^https\?://\|\_^www\.\|\.http\_$' },
			\	{	'typename' : 'Web-P',
			\		'typehint' : '',
			\		'preview'  : 1 },
			\	{	'typename' : 'Fallback',
			\		'typehint' : '.',
			\		'fallback' : 1 },
			\	]
"
"-------------------------------------------------------------------------------
" List of viewers.
"
" Each entry represents a viewer, using a dictionary with the fields:
" - viewername    : symbolic name of the viewer, for easier user configuration
" - enabled       : whether the viewer is usable (installed, executable, ...)
" - mode          : how to open the viewer
"                     SYSTEM - run a system command, process will be detached
"                     BUFFER - run a system command and paste the output into a
"                              buffer
"                     VIM    - run an ex-command
"                     HELP   - shorthand for Vim's ":help"
"                     MAN    - special treatment for manpages, user can choose
"                              a section
" - exec          : the executable (SYSTEM, BUFFER, MAN), ex-command (VIM)
" - exec1, exec2, : alternative, if the command relies on more than one exe.
" - os            : which OS, "MAC", "UNIX", or "WIN"
" - flags         : additional flags
" - cmd_line      : specifies the whole command line instead
" - bufname       : the buffer name (BUFFER, MAN)
" - typename      : name of the viewed objects, their filetype
"                   (but might by more abstract, such as Image instead of JPG)
"-------------------------------------------------------------------------------
let s:Viewers = [
			\	{
			\		'typename' : 'Web', }
			\	]
"
let s:WorldView_ManCommand   = 'no'             " generate ex-command :Man ...
let s:WorldView_ManGlobalMap = ''               " names a global map to call man
let s:WorldView_ManLang      = ''               " language to use with man -L ...
"
call s:GetGlobalSetting ( 'WorldView_ManCommand' )
call s:GetGlobalSetting ( 'WorldView_ManGlobalMap' )
call s:GetGlobalSetting ( 'WorldView_ManLang' )
"call s:ApplyDefaultSetting ( 'CMake_JumpToError', 'cmake' )
"
call s:CheckViewers ()
"
let s:Enabled = 1
"
" custom commands {{{2
"
if s:Enabled == 1
	command! -bang -nargs=* -complete=file     View               :call mmtoolbox#worldview#Run(<q-args>,'<bang>'=='!')
	command!       -nargs=* -complete=shellcmd ViewMan            :call <SID>Man('cmd-line',<q-args>)
	command!       -nargs=* -complete=shellcmd ViewManApropos     :call <SID>Man('cmd-line','-k '.<q-args>)
	command!       -nargs=* -complete=shellcmd ViewManWhatis      :call <SID>Man('cmd-line','-f '.<q-args>)
	if s:WorldView_ManCommand == 'yes'
		command!     -nargs=* -complete=shellcmd Man                :call <SID>Man('cmd-line',<q-args>)
		command!     -nargs=* -complete=shellcmd ManApropos         :call <SID>Man('cmd-line','-k '.<q-args>)
		command!     -nargs=* -complete=shellcmd ManWhatis          :call <SID>Man('cmd-line','-f '.<q-args>)
	endif
	command!       -nargs=0                    WorldviewHelp      :call <SID>HelpPlugin()
	command! -bang -nargs=?                    WorldviewSettings  :call <SID>Settings(('<bang>'=='!')+str2nr(<q-args>))
else
	"
	" s:Disabled : Print why the script is disabled.   {{{3
	function! s:Disabled ()
		let txt = "WorldView tool not working:\n"
		if true
			let txt .= "unknown reason\n"
			let txt .= "see :help toolbox-worldview"
		endif
		call s:ImportantMsg ( txt )
		return
	endfunction    " ----------  end of function s:Disabled  ----------
	" }}}3
	"
	command! -bang -nargs=* View               :call <SID>Disabled()
	command!       -nargs=0 WorldviewHelp      :call <SID>HelpPlugin()
	command! -bang -nargs=? WorldviewSettings  :call <SID>Settings(('<bang>'=='!')+str2nr(<q-args>))
	"
endif
"
" maps {{{2
if s:WorldView_ManGlobalMap != ''
	silent exe 'nnoremap <silent> '.s:WorldView_ManGlobalMap.'      :call <SID>Man("cursor","")<CR>'
	silent exe 'vnoremap <silent> '.s:WorldView_ManGlobalMap.' <ESC>:call <SID>Man("visual","")<CR>'
endif
"
" }}}2
"
"-------------------------------------------------------------------------------
" GetInfo : Initialize the script.   {{{1
"-------------------------------------------------------------------------------
function! mmtoolbox#worldview#GetInfo ()
	if s:Enabled
		return [ 'WorldView', g:WorldView_Version ]
	else
		return [ 'WorldView', g:WorldView_Version, 'disabled' ]
	endif
endfunction    " ----------  end of function mmtoolbox#worldview#GetInfo  ----------
"
"-------------------------------------------------------------------------------
" AddMaps : Add maps.   {{{1
"-------------------------------------------------------------------------------
function! mmtoolbox#worldview#AddMaps ()
endfunction    " ----------  end of function mmtoolbox#worldview#AddMaps  ----------
"
"-------------------------------------------------------------------------------
" AddMenu : Add menus.   {{{1
"-------------------------------------------------------------------------------
function! mmtoolbox#worldview#AddMenu ( root, esc_mapl )
	"
"	exe 'amenu '.a:root.'.&view\ a\ file<Tab>:View  :View '
"	"
"	for val in s:Filetypes
"		if has_key ( val, 'fallback' ) || val.enabled == 0
"			continue
"		endif
"		"
"		let typename = substitute( val.typename, '-P$', '', '' )
"		let menuname = substitute( typename, '^\u', '\l&', '' )
"		let menuname = substitute( menuname, '\u',  '\\ \l&', '' )
"		"
"		if has_key ( val, 'preview' )
"			let cmd = ':Preview'.typename
"			exe 'amenu '.a:root.'.preview\ &'.menuname.'<Tab>'.cmd.'  '.cmd.' '
"		else
"			let cmd = ':View'.typename
"			exe 'amenu '.a:root.'.view\ &'.menuname.'<Tab>'.cmd.'  '.cmd.' '
"		endif
"	endfor
"	"
"	exe 'amenu '.a:root.'.-SEP-MAN- <Nop>'
	"
	if s:WorldView_ManCommand == 'yes'
		exe 'amenu '.a:root.'.view\ &manpage<Tab>:Man         :Man '
		exe 'amenu '.a:root.'.view\ &apropos<Tab>:ManApropos  :ManApropos '
		exe 'amenu '.a:root.'.view\ &whatis<Tab>:ManWhatis    :ManWhatis '
	else
		exe 'amenu '.a:root.'.view\ &manpage<Tab>:ViewMan         :ViewMan '
		exe 'amenu '.a:root.'.view\ &apropos<Tab>:ViewManApropos  :ViewManApropos '
		exe 'amenu '.a:root.'.view\ &whatis<Tab>:ViewManWhatis    :ViewManWhatis '
	endif
	exe 'amenu '.a:root.'.&manpage\ buffer.Manpage<TAB>WorldView  :echo "This is a menu header."<CR>'
	exe 'amenu '.a:root.'.&manpage\ buffer.-SEP00-                :'
	"
	exe 'amenu <silent> '.a:root.'.manpage\ buffer.jump\ to\ page\ under\ cursor<TAB><CTRL-]>  :call <SID>Man("man-jump","")<CR>'
	exe 'amenu <silent> '.a:root.'.manpage\ buffer.jump\ to\ section<TAB>\\s                   :call <SID>TagJump(<SID>TagJumpParam("man-section"))<CR>'
	exe 'amenu <silent> '.a:root.'.manpage\ buffer.jump\ to\ option<TAB>\\o                    :call <SID>TagJump(<SID>TagJumpParam("man-option"))<CR>'
	"
	exe 'amenu '.a:root.'.-SEP-PLUGIN- <Nop>'
	"
	exe 'amenu '.a:root.'.&help<Tab>:WorldviewHelp          :WorldviewHelp<CR>'
	exe 'amenu '.a:root.'.&settings<Tab>:WorldviewSettings  :WorldviewSettings<CR>'
	"
endfunction    " ----------  end of function mmtoolbox#worldview#AddMenu  ----------
"
"-------------------------------------------------------------------------------
" Property : Various settings.   {{{1
"-------------------------------------------------------------------------------
function! mmtoolbox#worldview#Property ( mode, key, ... )
	"
	" check the mode
	if a:mode !~ 'echo\|get\|set'
		return s:ErrorMsg ( 'WorldView : Unknown mode: '.a:mode )
	endif
	"
	" check 3rd argument for 'set'
	if a:mode == 'set'
		if a:0 == 0
			return s:ErrorMsg ( 'WorldView : Not enough arguments for mode "set".' )
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
		return s:ErrorMsg ( 'WorldView : Unknown option: '.a:key )
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
		return s:ErrorMsg ( 'WorldView : Option is read-only, can not set: '.a:key )
	endif
	"
endfunction    " ----------  end of function mmtoolbox#worldview#Property  ----------
"
"-------------------------------------------------------------------------------
" s:HelpPlugin : Plugin help.   {{{1
"-------------------------------------------------------------------------------
function! s:HelpPlugin ()
	try
		help toolbox-worldview
	catch
		exe 'helptags '.s:plugin_dir.'/doc'
		help toolbox-worldview
	endtry
endfunction    " ----------  end of function s:HelpPlugin  ----------
"
"-------------------------------------------------------------------------------
" s:Settings : Plugin settings.   {{{1
"-------------------------------------------------------------------------------
function! s:Settings ( verbose )
	"
	if     s:MSWIN | let sys_name = 'Windows'
	elseif s:UNIX  | let sys_name = 'UNIX'
	else           | let sys_name = 'unknown' | endif
	"
	let	txt = " WorldView-Support settings\n\n"
				\ .'     plug-in installation :  toolbox on '.sys_name."\n"
				\ .'            using toolbox :  version '.g:Toolbox_Version." by Wolfgang Mehner\n"
	if a:verbose
		let	txt .= "\n"
"					\ .'            jump to error :  '.g:CMake_JumpToError."\n"
	endif
	let txt .=
				\  "________________________________________________________________________________\n"
				\ ." WorldView-Tool, Version ".g:WorldView_Version." / Wolfgang Mehner / wolfgang-mehner@web.de\n\n"
	"
	if a:verbose == 2
		split WorldView_Settings.txt
		put = txt
	else
		echo txt
	endif
endfunction    " ----------  end of function s:Settings  ----------
"
"-------------------------------------------------------------------------------
" Modul setup (abort early?).   {{{1
"-------------------------------------------------------------------------------
if s:Enabled == 0
	finish
endif
"
"-------------------------------------------------------------------------------
" s:OpenBuffer : Put output in a read-only buffer.   {{{1
"
" Parameters:
"   buf_name - name of the buffer (string)
" Returns:
"   opened -  true, if a new buffer was opened (integer)
"
" If a buffer called 'buf_name' already exists, jump to that buffer. Otherwise,
" open a buffer of the given name an set it up as a "temporary" buffer. It is
" deleted after the window is closed.
"
" Settings:
" - noswapfile
" - bufhidden=wipe
" - tabstop=8
"-------------------------------------------------------------------------------
function! s:OpenBuffer ( buf_name )
	"
	" a buffer like this already opened on the current tab page?
	if bufwinnr ( a:buf_name ) != -1
		" yes -> go to the window containing the buffer
		exe bufwinnr( a:buf_name ).'wincmd w'
		return 0
	endif
	"
	" no -> open a new window
	aboveleft new
	"
	" buffer exists elsewhere?
	if bufnr ( a:buf_name ) != -1
		" yes -> settings of the new buffer
		silent exe 'edit #'.bufnr( a:buf_name )
		return 0
	else
		" no -> settings of the new buffer
		silent exe 'file '.escape( a:buf_name, ' ' )
		setlocal noswapfile
		setlocal bufhidden=wipe
		setlocal tabstop=8
	endif
	"
	return 1
endfunction    " ----------  end of function s:OpenBuffer  ----------
"
"-------------------------------------------------------------------------------
" s:UpdateBuffer : Put output in a read-only buffer.   {{{1
"
" Parameters:
"   command - the command to run (string)
" Returns:
"   -
"
" The output of the command is used to replace the text in the current buffer.
" After updating, 'modified' is cleared.
"-------------------------------------------------------------------------------
function! s:UpdateBuffer ( command )
	"
	" delete the previous contents
	setlocal modifiable
	setlocal noro
	silent exe '1,$delete _'
	"
	" pause syntax highlighting (for speed)
	if &syntax != ''
		setlocal syntax=OFF
	endif
	"
	" insert the output of the command
	silent exe a:command
	"
	" delete the first line (empty)
	normal! gg"_dd
	"
	" restart syntax highlighting
	if &syntax != ''
		setlocal syntax=ON
	endif
	"
	" read-only again
	setlocal ro
	setlocal nomodified
	setlocal nomodifiable
endfunction    " ----------  end of function s:UpdateBuffer  ----------
"
"-------------------------------------------------------------------------------
" s:TagJumpParam : Parameters for tags in manpages.   {{{1
"
" Parameters:
"   mode - the mode (string)
" Returns:
"   param - the parameters (table)
"-------------------------------------------------------------------------------
function! s:TagJumpParam ( mode )
	"
	let param = {}
	"
	if a:mode == 'man-section'
		"
		let param.regexp  = '^\u.*'
		let param.pattern = '\s\s.*'
		let param.replace = ''
		let param.category_name = 'section'
		let param.show_overview = 1
		"
	elseif a:mode == 'man-option'
		"
		let param.regexp  = '^\s\+--\?.\+'
		let param.pattern = '^\s\+'
		let param.replace = ''
		let param.category_name = 'option'
		let param.show_overview = 0
		"
	endif
	"
	return param
endfunction    " ----------  end of function s:TagJumpParam  ----------
"
"-------------------------------------------------------------------------------
" s:TagJump : Jumps to a tag in a buffer.   {{{1
"
" Parameters:
"   param  - parameters (dict, optional)
" Returns:
"   -
"
" The options are given as a dictionary 'param' with the fields:
"   tag_regexp  - regexp matching tag (string, optional)
"   tag_pattern - pattern for cleaning up tags (string, optional)
"   tag_replace - replacement for cleaning up tags (string, optional)
"
"   category_name - name of the category of tags, used for user interaction
"                   (string, optional)
"   show_overview - if true, show an overview/a ToC before starting the
"                   selection (integer, optional)
"
" If both 'tag_pattern' and 'tag_replace' are given, each found tag is cleaned
" up using:
"   let tag = substitute ( tag, tag_pattern, tag_replace, 'g' )
"-------------------------------------------------------------------------------
function! s:TagJump ( ... )
	"
	if a:0 == 0
		let param = s:TagJumpParam ( 'man-section' )
	else
		let param = a:1
	endif
	"
	let tag_regexp  = get ( param, 'regexp' , '^\S.*' )
	let tag_pattern = get ( param, 'pattern', '' )
	let tag_replace = get ( param, 'replace', '' )
	"
	let cat_name      = get ( param, 'category_name', 'section' )
	let show_overview = get ( param, 'show_overview', 1 )
	"
	let toc_topics = []
	let toc_lines  = []
	let last_line  = line ( '$' )
	let cursorpos  = getpos ( '.' )
	"
	call cursor ( 1, 1 )
	while 1
		let line_no = search ( tag_regexp, 'W' )    " don't wrap around
		"
		if line_no == 0
			break
		elseif line_no == 1 || line_no == last_line
			continue
		endif
		"
		let line_str = matchstr ( getline( line_no ), tag_regexp )
		let line_str = substitute ( line_str, tag_pattern, tag_replace, 'g' )
		"
		if line_str !~ '^\s*$'
			call add ( toc_topics, line_str )
			call add ( toc_lines,  line_no )
		endif
	endwhile
	"
	if len ( toc_topics ) == 0
		call s:WarningMsg ( 'no '.cat_name.' found' )
	else
		if show_overview
			echo cat_name.':'
			for val in toc_topics
				echo val
			endfor
		endif
		"
		let item_str = s:UserInput ( cat_name.' (tab-compl.): ', '', 'customlist', toc_topics )
		"
		let item_idx = index ( toc_topics, item_str )
		"
		if item_idx != -1
			let cursorpos[1] = toc_lines[item_idx]
			let cursorpos[2] = 1
		endif
	endif
	"
	call setpos ( '.', cursorpos )
endfunction    " ----------  end of function s:TagJump  ----------
"
"-------------------------------------------------------------------------------
" s:Man : View a manpage.   {{{1
"
" Parameters:
"   mode    - the mode, "cmd-line", "man-jump", "cursor", or "visual" (string)
"   cmdline - the command-line (string)
"   default - comma-separated list of default sections (string, optional)
"     or
"   section - the section (string or integer)
"   page    - the page (string)
"   default - comma-separated list of default sections (string, optional)
" Returns:
"   opened - 1, if a man-buffer has been opened (integer)
"
" The function can be called in different ways:
"   mmtoolbox#worldview#Man ( "cmd-line", cmdline [, default] )
"     'cmdline' are the command-line arguments provided by the user, e.g.
"     ":Man print" or ":Man 3 printf"
"   mmtoolbox#worldview#Man ( "man-jump", "" [, default] )
"     pick up the word under the cursor, using the format "page(1)",
"     "printf(3)", ...
"   mmtoolbox#worldview#Man ( "cursor", "" [, default] )
"   mmtoolbox#worldview#Man ( "visual", "" [, default] )
"     use the word under the cursor or the visual selection as the name of the
"     page
"   mmtoolbox#worldview#Man ( section, page [, default] )
"     give a section and page directly
"
" Default sections can be specified using 'default'. For Shell commands:
"   "1,7"
" For C/C++:
"   "3,2"
" The first section which is mentioned here and for which a page exists will
" be suggested to the user.
"-------------------------------------------------------------------------------
function! s:Man ( mode, cmdline, ... )
	"
	" :TODO:19.10.2014 21:01:WM: configuration
	let manview = 'man'
	"
	let skip_section = 0
	let use_cmd_line = ''
	let section = ''
	let page    = ''
	"
	if a:0 >= 1
		let defaultcatalogs = split ( a:1, ',' )
	else
		let defaultcatalogs = [ '1' ]
	endif
	"
	"-------------------------------------------------------------------------------
	" get the section and page according to the mode
	"
	" - for "cmd-line" get them from the Vim command-line
	" - for "man-jump", "cursor", and "visual" the word under the cursor is used
	"
	" All the regexps use \f (file name character) for characters making up the
	" name of manpages. This follows the example of the 'man' syntax highlighting.
	"-------------------------------------------------------------------------------
	"
	if a:mode == 'cmd-line'
		" get page (and section?) from the cmdline
		let mlist = matchlist ( a:cmdline, '^\s*\%(\(\d\+\a*\|-k\|-f\)\s\+\)\?\(\f\+\)' )
		"
		if ! empty ( mlist )
			let section = mlist[1]
			let page    = mlist[2]
		endif
		"
	elseif a:mode == 'man-jump'
		" get page from the word under the cursor
		" or get line in output of 'apropos' or 'whatis'
		"
		let pat = [
					\ '^\(\f\+\)\s(\(\d\+\a*\))\s\+-\s',
					\ '\S*\%'.getpos('.')[2].'c\S\&\(\f\+\)\%((\(\d\+\a*\))\)\?',
					\ ]
		"
		for val in pat
			let mlist = matchlist ( getline('.'), val )
			"
			if ! empty ( mlist )
				let page    = mlist[1]
				let section = mlist[2]
				break
			endif
		endfor
		"
	elseif a:mode == 'cursor'
		" get page from the word under the cursor
		let page = matchstr ( getline('.'), '\f*\%'.getpos('.')[2].'c\f\+' )
	elseif a:mode == 'visual'
		" get page from selection
		let page = s:GetVisualArea ()
	else
		" 'mode' names the section (as a number or string)
		let section = ''.a:mode
		let page    = a:cmdline
	endif
	"
	" no page found in the cmd-line or under the cursor
	if page =~ '^\s*$'
		return 0
	endif
	"
	"-------------------------------------------------------------------------------
	" prompt for a section, if necessary
	"-------------------------------------------------------------------------------
	"
	if section == '' && ! skip_section
		" may need to select section, use 'apropos'
		"
		let cmd = shellescape( manview )
		"
		if s:WorldView_ManLang != ''
			let cmd .= ' -L '.shellescape( s:WorldView_ManLang, 1 )
		endif
		"
		" get a list of topics
		let manpages = system( cmd.' -k '.page )
		if v:shell_error
			return s:WarningMsg ( "shell command '".manview." -k ".page."' failed" )
		endif
		"
		" select manuals where the name exactly matches
		let whatis   = []
		let catalogs = []
		"
		for line in split ( manpages, '\n', )
			if line =~ '\V\^'.page.'\s\+(' 
				let c = matchstr ( line, '\S\+\s\+(\zs\d\+\a*\ze)' )
				call add ( whatis, line )
				call add ( catalogs, c )
			endif
		endfor
		"
		call sort ( catalogs )
		"
		" build a selection list if there are more than one manual
		if len ( catalogs ) > 1
			"
			let defaultcatalog = ''
			for c in defaultcatalogs
				if index ( catalogs, c ) != -1
					let defaultcatalog = c
					break
				endif
			endfor
			"
			for line in whatis
				echo ' '.line
			endfor
			"
			let section = s:UserInput ( 'select manual section (tab-compl.): ', defaultcatalog, 'customlist', catalogs )
			"
			if section =~ '^\s*$'
				return 0
			elseif index ( catalogs, section ) == -1
				return s:WarningMsg ( "", "no appropriate manual section '".section."'" )
			endif
		endif
	endif
	"
	"-------------------------------------------------------------------------------
	" open the buffer
	"-------------------------------------------------------------------------------
	"
	if s:OpenBuffer ( 'Manpage' )
		"
		set filetype=man
		"
		" :TODO:14.10.2014 23:04:WM: maps CTRL-O, CTRL-I ?
		silent exe 'nnoremap <silent> <buffer> <C-]>            :call <SID>Man("man-jump","")<CR>'
		silent exe 'nnoremap <silent> <buffer> <2-Leftmouse>    :call <SID>Man("man-jump","")<CR>'
		silent exe 'nnoremap <silent> <buffer> <LocalLeader>s   :call <SID>TagJump(<SID>TagJumpParam("man-section"))<CR>'
		silent exe 'nnoremap <silent> <buffer> <LocalLeader>o   :call <SID>TagJump(<SID>TagJumpParam("man-option"))<CR>'
		"
	endif
	"
	"-------------------------------------------------------------------------------
	" assemble and run the command
	"-------------------------------------------------------------------------------
	"
	let cmd = ''
	"
	" get the width of the newly opened window
	" and set the width of man's output accordingly
	let win_w = winwidth( winnr() )
	if s:UNIX && win_w > 0
		let cmd .= 'MANWIDTH='.win_w.' '
	endif
	"
	" the 'man' command
	let cmd .= shellescape( manview )
	"
	" the language
	if s:WorldView_ManLang != ''
		let cmd .= ' -L '.shellescape( s:WorldView_ManLang, 1 )
	endif
	"
	" update the buffer
	call s:UpdateBuffer ( ':r! '.cmd.' '.use_cmd_line.' '.section.' '.shellescape( page, 1 ) )
	"
	return 1
endfunction    " ----------  end of function s:Man  ----------
"
"-------------------------------------------------------------------------------
" mmtoolbox#worldview#Interface : Get the interface.   {{{1
"
" Parameters:
"   -
" Returns:
"   interface - the interface (dict: name -> func.-ref)
"-------------------------------------------------------------------------------
function! mmtoolbox#worldview#Interface ()
	"
	let namelist = [
				\ 'OpenBuffer' ,  'UpdateBuffer' ,
				\ 'TagJump'    ,  'Man'          ,
				\ ]
	"
	let interface = {}
	let sid = s:SID()
	"
	for name in namelist
		let interface[name] = function ( '<SNR>'.sid.'_'.name )
	endfor
	"
	return interface
endfunction    " ----------  end of function mmtoolbox#worldview#Interface  ----------
" }}}1
"-------------------------------------------------------------------------------
"
" =====================================================================================
"  vim: foldmethod=marker
