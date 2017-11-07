"===============================================================================
"
"          File:  lua-support.vim
"
"   Description:  Lua IDE for Vim/gVim.
"
"                 See help file luasupport.txt .
"
"   VIM Version:  7.0+
"        Author:  Wolfgang Mehner, wolfgang-mehner@web.de
"  Organization:  
"       Version:  see variable g:Lua_Version below
"       Created:  26.03.2014
"      Revision:  07.11.2017
"       License:  Copyright (c) 2014-2017, Wolfgang Mehner
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

" need at least 7.0
if v:version < 700
	echohl WarningMsg
	echo 'The plugin lua-support.vim needs Vim version >= 7.'
	echohl None
	finish
endif

" prevent duplicate loading
" need compatible
if &cp || ( exists('g:Lua_Version') && ! exists('g:Lua_DevelopmentOverwrite') )
	finish
endif

let g:Lua_Version= '1.1alpha'     " version number of this script; do not change

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
" s:ShellEscExec : Escape an executable for the shell   {{{2
"
" Parameters:
"   exec - the name of the executable (string)
" Returns:
"   exec - the escaped version (string)
"
" Uses 'shellescape', except under Windows if the shell is "cmd.exe". In that
" case, all spaces are escaped with "^^".
"-------------------------------------------------------------------------------

function! s:ShellEscExec ( exec )
	if s:MSWIN && &shell =~ 'cmd.exe'
		"return substitute ( a:exec, ' ', '^^&', 'g' )
		return shellescape ( a:exec )
	else
		return shellescape ( a:exec )
	endif
endfunction    " ----------  end of function s:ShellEscExec  ----------

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
" === Common functions ===   {{{1
"-------------------------------------------------------------------------------

"-------------------------------------------------------------------------------
" s:CodeSnippet : Code snippets.   {{{2
"
" Parameters:
"   action - "insert", "create", "vcreate", "view", or "edit" (string)
" Returns:
"   -
"-------------------------------------------------------------------------------
function! s:CodeSnippet ( action )

	"-------------------------------------------------------------------------------
	" setup
	"-------------------------------------------------------------------------------

	" the snippet directory
	let cs_dir    = s:Lua_SnippetDir
	let cs_browse = s:Lua_SnippetBrowser

	" check directory
	if ! isdirectory ( cs_dir )
		return s:ErrorMsg (
					\ 'Code snippet directory '.cs_dir.' does not exist.',
					\ '(Please create it.)' )
	endif

	" save option 'browsefilter'
	if has( 'browsefilter' ) && exists( 'b:browsefilter' )
		let browsefilter_save = b:browsefilter
		let b:browsefilter    = '*'
	endif

	"-------------------------------------------------------------------------------
	" do action
	"-------------------------------------------------------------------------------

	if a:action == 'insert'

		"-------------------------------------------------------------------------------
		" action "insert"
		"-------------------------------------------------------------------------------

		" select file
		if has('browse') && cs_browse == 'gui'
			let snippetfile = browse ( 0, 'insert a code snippet', cs_dir, '' )
		else
			let snippetfile = s:UserInput ( 'insert snippet ', cs_dir, 'file' )
		endif

		" insert snippet
		if filereadable(snippetfile)
			let linesread = line('$')

			let old_cpoptions = &cpoptions            " prevent the alternate buffer from being set to this files
			setlocal cpoptions-=a

			exe 'read '.snippetfile

			let &cpoptions = old_cpoptions            " restore previous options

			let linesread = line('$') - linesread - 1 " number of lines inserted

			" :TODO:03.12.2013 14:29:WM: indent here?
			" indent lines
			if linesread >= 0 && match( snippetfile, '\.\(ni\|noindent\)$' ) < 0
				silent exe 'normal! ='.linesread.'+'
			endif
		endif

		" delete first line if empty
		if line('.') == 2 && getline(1) =~ '^$'
			silent exe ':1,1d'
		endif

	elseif a:action == 'create' || a:action == 'vcreate'

		"-------------------------------------------------------------------------------
		" action "create" or "vcreate"
		"-------------------------------------------------------------------------------

		" select file
		if has('browse') && cs_browse == 'gui'
			let snippetfile = browse ( 1, 'create a code snippet', cs_dir, '' )
		else
			let snippetfile = s:UserInput ( 'create snippet ', cs_dir, 'file' )
		endif

		" create snippet
		if ! empty( snippetfile )
			" new file or overwrite?
			if ! filereadable( snippetfile ) || confirm( 'File '.snippetfile.' exists! Overwrite? ', "&Cancel\n&No\n&Yes" ) == 3
				if a:action == 'create' && confirm( 'Write whole file as a snippet? ', "&Cancel\n&No\n&Yes" ) == 3
					exe 'write! '.fnameescape( snippetfile )
				elseif a:action == 'vcreate'
					exe "'<,'>write! ".fnameescape( snippetfile )
				endif
			endif
		endif

	elseif a:action == 'view' || a:action == 'edit'

		"-------------------------------------------------------------------------------
		" action "view" or "edit"
		"-------------------------------------------------------------------------------
		if a:action == 'view' | let saving = 0
		else                  | let saving = 1 | endif

		" select file
		if has('browse') && cs_browse == 'gui'
			let snippetfile = browse ( saving, a:action.' a code snippet', cs_dir, '' )
		else
			let snippetfile = s:UserInput ( a:action.' snippet ', cs_dir, 'file' )
		endif

		" open file
		if ! empty( snippetfile )
			exe 'split | '.a:action.' '.fnameescape( snippetfile )
		endif
	else
		call s:ErrorMsg ( 'Unknown action "'.a:action.'".' )
	endif

	"-------------------------------------------------------------------------------
	" wrap up
	"-------------------------------------------------------------------------------

	" restore option 'browsefilter'
	if has( 'browsefilter' ) && exists( 'b:browsefilter' )
		let b:browsefilter = browsefilter_save
	endif

endfunction   " ----------  end of function s:CodeSnippet  ----------

"-------------------------------------------------------------------------------
" s:Hardcopy : Generate PostScript document from current buffer.   {{{2
"
" Under windows, display the printer dialog.
"
" Parameters:
"   mode - "n" : print complete buffer, "v" : print marked area (string)
" Returns:
"   -
"-------------------------------------------------------------------------------
function! s:Hardcopy ( mode )

	let outfile = expand("%:t")

	" check the buffer
	if ! s:MSWIN && empty ( outfile )
		return s:ImportantMsg ( 'The buffer has no filename.' )
	endif

	" save current settings
	let printheader_saved = &g:printheader

	let &g:printheader = g:Lua_Printheader

	if s:MSWIN
		" we simply call hardcopy, which will open the systems printing dialog
		if a:mode == 'n'
			silent exe  'hardcopy'
		elseif a:mode == 'v'
			silent exe  "'<,'>hardcopy"
		endif
	else

		" directory to print to
		let outdir = getcwd()
		if filewritable ( outdir ) != 2
			let outdir = $HOME
		endif

		let psfile = outdir.'/'.outfile.'.ps'

		if a:mode == 'n'
			silent exe  'hardcopy > '.psfile
			call s:ImportantMsg ( 'file "'.outfile.'" printed to "'.psfile.'"' )
		elseif a:mode == 'v'
			silent exe  "'<,'>hardcopy > ".psfile
			call s:ImportantMsg ( 'file "'.outfile.'" (lines '.line("'<").'-'.line("'>").') printed to "'.psfile.'"' )
		endif
	endif

	" restore current settings
	let &g:printheader = printheader_saved

endfunction   " ----------  end of function s:Hardcopy  ----------

"-------------------------------------------------------------------------------
" s:MakeExecutable : Make the script executable.   {{{2
"-------------------------------------------------------------------------------
function! s:MakeExecutable ()

	if ! executable ( 'chmod' )
		return s:ErrorMsg ( 'Command "chmod" not executable.' )
	endif

	let filename = expand("%:p")

	if executable ( filename )
		let from_state = 'executable'
		let to_state   = 'NOT executable'
		let cmd        = 'chmod -x'
	else
		let from_state = 'NOT executable'
		let to_state   = 'executable'
		let cmd        = 'chmod u+x'
	endif

	if s:UserInput( '"'.filename.'" is '.from_state.'. Make it '.to_state.' [y/n] : ', 'y' ) == 'y'

		" run the command
		silent exe '!'.cmd.' '.shellescape(filename)

		" successful?
		if v:shell_error
			" confirmation for the user
			call s:ErrorMsg ( 'Could not make "'.filename.'" '.to_state.'!' )
		else
			" reload the file, otherwise the message will not be visible
			if &autoread && ! &l:modified
				silent exe "edit"
			endif
			" confirmation for the user
			call s:ImportantMsg ( 'Made "'.filename.'" '.to_state.'.' )
		endif
		"
	endif

endfunction   " ----------  end of function s:MakeExecutable  ----------

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

let s:NEOVIM = has("nvim")
let s:VIM8   = ! s:NEOVIM && v:version >= 800

let s:installation           = '*undefined*'    " 'local' or 'system'
let s:plugin_dir             = ''               " the directory hosting ftplugin/ plugin/ lua-support/ ...
let s:Lua_GlobalTemplateFile = ''               " the global templates, undefined for s:installation == 'local'
let s:Lua_LocalTemplateFile  = ''               " the local templates
let s:Lua_CustomTemplateFile = ''               " the custom templates
"
let s:Lua_ToolboxDir      = []
"
if s:MSWIN
	"
	"-------------------------------------------------------------------------------
	" MS Windows
	"-------------------------------------------------------------------------------
	"
	let s:plugin_dir = substitute( expand('<sfile>:p:h:h'), '\\', '/', 'g' )
	"
	if match(      substitute( expand('<sfile>'), '\\', '/', 'g' ),
				\   '\V'.substitute( expand('$HOME'),   '\\', '/', 'g' ) ) == 0
		"
		" user installation assumed
		let s:installation           = 'local'
		let s:Lua_LocalTemplateFile  = s:plugin_dir.'/lua-support/templates/Templates'
		let s:Lua_CustomTemplateFile = $HOME.'/vimfiles/templates/lua.templates'
		let s:Lua_ToolboxDir        += [ s:plugin_dir.'/autoload/mmtoolbox/' ]
	else
		"
		" system wide installation
		let s:installation           = 'system'
		let s:Lua_GlobalTemplateFile = s:plugin_dir.'/lua-support/templates/Templates'
		let s:Lua_LocalTemplateFile  = $HOME.'/vimfiles/lua-support/templates/Templates'
		let s:Lua_CustomTemplateFile = $HOME.'/vimfiles/templates/lua.templates'
		let s:Lua_ToolboxDir        += [
					\	s:plugin_dir.'/autoload/mmtoolbox/',
					\	$HOME.'/vimfiles/autoload/mmtoolbox/' ]
	endif
	"
else
	"
	"-------------------------------------------------------------------------------
	" Linux/Unix
	"-------------------------------------------------------------------------------
	"
	let s:plugin_dir = expand('<sfile>:p:h:h')
	"
	if match( expand('<sfile>'), '\V'.resolve(expand('$HOME')) ) == 0
		"
		" user installation assumed
		let s:installation           = 'local'
		let s:Lua_LocalTemplateFile  = s:plugin_dir.'/lua-support/templates/Templates'
		let s:Lua_CustomTemplateFile = $HOME.'/.vim/templates/lua.templates'
		let s:Lua_ToolboxDir        += [ s:plugin_dir.'/autoload/mmtoolbox/' ]
	else
		"
		" system wide installation
		let s:installation           = 'system'
		let s:Lua_GlobalTemplateFile = s:plugin_dir.'/lua-support/templates/Templates'
		let s:Lua_LocalTemplateFile  = $HOME.'/.vim/lua-support/templates/Templates'
		let s:Lua_CustomTemplateFile = $HOME.'/.vim/templates/lua.templates'
		let s:Lua_ToolboxDir        += [
					\	s:plugin_dir.'/autoload/mmtoolbox/',
					\	$HOME.'/.vim/autoload/mmtoolbox/' ]
	endif
	"
endif
"
"-------------------------------------------------------------------------------
" == Various settings ==   {{{2
"-------------------------------------------------------------------------------
"
let s:CmdLineEscChar = ' |"\'
"
let s:Lua_LoadMenus             = 'auto'       " load the menus?
let s:Lua_RootMenu              = '&Lua'       " name of the root menu

let s:Lua_LineEndCommColDefault = 49
let s:Lua_CommentLabel          = "BlockCommentNo_"
let s:Lua_SnippetDir            = s:plugin_dir.'/lua-support/codesnippets/'
let s:Lua_SnippetBrowser        = 'gui'
let s:Lua_UseToolbox            = 'yes'
let s:Lua_AdditionalTemplates   = mmtemplates#config#GetFt ( 'lua' )
"
let s:Xterm_Executable          = 'xterm'
"
if ! exists ( 's:MenuVisible' )
	let s:MenuVisible = 0                        " menus are not visible at the moment
endif
"
if s:MSWIN
	let s:Lua_BinPath = ''
else
	let s:Lua_BinPath = ''
endif
"
call s:GetGlobalSetting ( 'Lua_BinPath' )
"
if s:MSWIN
	let s:Lua_BinPath = substitute ( s:Lua_BinPath, '[^\\/]$', '&\\', '' )
	"
	let s:Lua_Executable   = s:Lua_BinPath.'lua'       " lua executable
	let s:Lua_CompilerExec = s:Lua_BinPath.'luac'      " luac executable
else
	let s:Lua_BinPath = substitute ( s:Lua_BinPath, '[^\\/]$', '&/', '' )
	"
	let s:Lua_Executable   = s:Lua_BinPath.'lua'       " lua executable
	let s:Lua_CompilerExec = s:Lua_BinPath.'luac'      " luac executable
endif
"
call s:GetGlobalSetting ( 'Lua_GlobalTemplateFile', 'Lua_GlbTemplateFile' )
call s:GetGlobalSetting ( 'Lua_LocalTemplateFile',  'Lua_LclTemplateFile' )
call s:GetGlobalSetting ( 'Lua_GlobalTemplateFile' )
call s:GetGlobalSetting ( 'Lua_LocalTemplateFile' )
call s:GetGlobalSetting ( 'Lua_CustomTemplateFile' )
call s:GetGlobalSetting ( 'Lua_LoadMenus' )
call s:GetGlobalSetting ( 'Lua_RootMenu' )
call s:GetGlobalSetting ( 'Lua_Executable' )
call s:GetGlobalSetting ( 'Lua_CompilerExec' )
call s:GetGlobalSetting ( 'Lua_LineEndCommColDefault' )
call s:GetGlobalSetting ( 'Lua_SnippetDir' )
call s:GetGlobalSetting ( 'Lua_SnippetBrowser' )
call s:GetGlobalSetting ( 'Lua_UseToolbox' )
call s:GetGlobalSetting ( 'Xterm_Executable' )
"
call s:ApplyDefaultSetting ( 'Lua_CompiledExtension', 'luac' )         " default: 'luac'
call s:ApplyDefaultSetting ( 'Lua_InsertFileHeader', 'yes' )           " default: do insert a file header
call s:ApplyDefaultSetting ( 'Lua_MapLeader', '' )                     " default: do not overwrite 'maplocalleader'
call s:ApplyDefaultSetting ( 'Lua_Ctrl_j', 'yes' )                     " default: generate the CTRL+J map when loading a buffer
call s:ApplyDefaultSetting ( 'Lua_Ctrl_d', 'yes' )                     " default: generate the CTRL+D map when loading a buffer
call s:ApplyDefaultSetting ( 'Lua_Printheader', "%<%f%h%m%<  %=%{strftime('%x %H:%M')}     Page %N" )
call s:ApplyDefaultSetting ( 'Lua_UseTool_make', 'yes' )
call s:ApplyDefaultSetting ( 'Xterm_Options', '-fa courier -fs 12 -geometry 80x24' )
"
let s:Lua_GlobalTemplateFile = expand ( s:Lua_GlobalTemplateFile )
let s:Lua_LocalTemplateFile  = expand ( s:Lua_LocalTemplateFile )
let s:Lua_CustomTemplateFile = expand ( s:Lua_CustomTemplateFile )
let s:Lua_SnippetDir         = expand ( s:Lua_SnippetDir )

"-------------------------------------------------------------------------------
" == Output method ==   {{{2
"-------------------------------------------------------------------------------

if s:NEOVIM
	" can not use 'cmd-line' in Neovim, since :! is not interactive
	let s:Lua_OutputMethodList = [ 'quickfix', 'buffer', 'terminal' ]
	let s:Lua_OutputMethod     = 'terminal'       " one of 's:Lua_OutputMethodList'
else
	let s:Lua_OutputMethodList = [ 'cmd-line', 'quickfix', 'buffer' ]
	let s:Lua_OutputMethod     = 'cmd-line'       " one of 's:Lua_OutputMethodList'
endif
if ! s:MSWIN
	let s:Lua_OutputMethodList += [ 'xterm' ]
endif
if has ( 'terminal' ) && ! s:MSWIN              " :TODO:25.09.2017 16:16:WM: enable Windows, check how to start jobs with arguments under Windows
	let s:Lua_OutputMethodList += [ 'terminal' ]
endif
call sort ( s:Lua_OutputMethodList )
let s:Lua_DirectRun = 'no'                      " 'yes' or 'no'

call s:GetGlobalSetting ( 'Lua_DirectRun' )
call s:GetGlobalSetting ( 'Lua_OutputMethod' )

" adapt for backwards compatibility
if s:Lua_OutputMethod == 'vim-io' && s:NEOVIM
	let s:Lua_OutputMethod = 'terminal'
elseif s:Lua_OutputMethod == 'vim-io'
	let s:Lua_OutputMethod = 'cmd-line'
elseif s:Lua_OutputMethod == 'vim-qf'
	let s:Lua_OutputMethod = 'quickfix'
endif

" }}}2
"-------------------------------------------------------------------------------

"-------------------------------------------------------------------------------
" s:EndOfLineComment : Append end-of-line comment.   {{{1
"-------------------------------------------------------------------------------
"
function! s:EndOfLineComment () range
	"
	" local position
	if !exists( 'b:Lua_LineEndCommentColumn' )
		let b:Lua_LineEndCommentColumn = s:Lua_LineEndCommColDefault
	endif
	"
	" ----- trim whitespaces -----
	exe a:firstline.','.a:lastline.'s/\s*$//'
	"
	for line in range( a:lastline, a:firstline, -1 )
		silent exe ':'.line
		if getline(line) !~ '^\s*$'
			let linelength = virtcol( [line,'$'] ) - 1
			let diff       = 1
			if linelength < b:Lua_LineEndCommentColumn
				let diff = b:Lua_LineEndCommentColumn - 1 - linelength
			endif
			exe 'normal! '.diff.'A '
			call mmtemplates#core#InsertTemplate (g:Lua_Templates, 'Comments.end-of-line comment')
		endif
	endfor
	"
endfunction    " ----------  end of function s:EndOfLineComment  ----------
"
"-------------------------------------------------------------------------------
" s:AdjustEndOfLineComm : Adjust end-of-line comment.   {{{1
"-------------------------------------------------------------------------------
"
function! s:AdjustEndOfLineComm () range
	"
	" comment character (for use in regular expression)
	let cc = '--'
	"
	" patterns to ignore when adjusting line-end comments (maybe incomplete):
	" - single-quoted strings, includes \n \' \\ ...
	" - double-quoted strings, includes \n \" \\ ...
	let align_regex = "'\\%(\\\\.\\|[^']\\)*'"
				\ .'\|'.'"\%(\\.\|[^"]\)*"'
	"
	" local position
	if !exists( 'b:Lua_LineEndCommentColumn' )
		let b:Lua_LineEndCommentColumn = s:Lua_LineEndCommColDefault
	endif
	let correct_idx = b:Lua_LineEndCommentColumn
	"
	" === plug-in specific code ends here                 ===
	" === the behavior is governed by the variables above ===
	"
	" save the cursor position
	let save_cursor = getpos('.')
	"
	for line in range( a:firstline, a:lastline )
		silent exe ':'.line
		"
		let linetxt = getline('.')
		"
		" "pure" comment line left unchanged
		if match ( linetxt, '^\s*'.cc ) == 0
			"echo 'line '.line.': "pure" comment'
			continue
		endif
		"
		let b_idx1 = 1 + match ( linetxt, '\s*'.cc.'.*$', 0 )
		let b_idx2 = 1 + match ( linetxt,       cc.'.*$', 0 )
		"
		" not found?
		if b_idx1 == 0
			"echo 'line '.line.': no end-of-line comment'
			continue
		endif
		"
		" walk through ignored patterns
		let idx_start = 0
		"
		while 1
			let this_start = match ( linetxt, align_regex, idx_start )
			"
			if this_start == -1
				break
			else
				let idx_start = matchend ( linetxt, align_regex, idx_start )
				"echo 'line '.line.': ignoring >>>'.strpart(linetxt,this_start,idx_start-this_start).'<<<'
			endif
		endwhile
		"
		let b_idx1 = 1 + match ( linetxt, '\s*'.cc.'.*$', idx_start )
		let b_idx2 = 1 + match ( linetxt,       cc.'.*$', idx_start )
		"
		" not found?
		if b_idx1 == 0
			"echo 'line '.line.': no end-of-line comment'
			continue
		endif
		"
		call cursor ( line, b_idx2 )
		let v_idx2 = virtcol('.')
		"
		" do b_idx1 last, so the cursor is in the right position for substitute below
		call cursor ( line, b_idx1 )
		let v_idx1 = virtcol('.')
		"
		" already at right position?
		if ( v_idx2 == correct_idx )
			"echo 'line '.line.': already at right position'
			continue
		endif
		" ... or line too long?
		if ( v_idx1 >  correct_idx )
			"echo 'line '.line.': line too long'
			continue
		endif
		"
		" substitute all whitespaces behind the cursor (regex '\%#') and the next character,
		" to ensure the match is at least one character long
		silent exe 'substitute/\%#\s*\(\S\)/'.repeat( ' ', correct_idx - v_idx1 ).'\1/'
		"echo 'line '.line.': adjusted'
		"
	endfor
	"
	" restore the cursor position
	call setpos ( '.', save_cursor )

endfunction   " ----------  end of function s:AdjustEndOfLineComm  ----------

"-------------------------------------------------------------------------------
" s:SetEndOfLineCommPos : Set end-of-line comment position.   {{{1
"-------------------------------------------------------------------------------
"
function! s:SetEndOfLineCommPos () range
	"
	let b:Lua_LineEndCommentColumn = virtcol('.')
	call s:ImportantMsg ( 'line end comments will start at column '.b:Lua_LineEndCommentColumn )
	"
endfunction    " ----------  end of function s:SetEndOfLineCommPos  ----------
"
"-------------------------------------------------------------------------------
" s:CodeComment : Code -> Comment   {{{1
"-------------------------------------------------------------------------------
"
function! s:CodeComment() range
	"
	" add '%' at the beginning of the lines
	silent exe ":".a:firstline.",".a:lastline."s/^/--/"
	"
endfunction    " ----------  end of function s:CodeComment  ----------
"
"-------------------------------------------------------------------------------
" s:CommentCode : Comment -> Code   {{{1
"-------------------------------------------------------------------------------
"
function! s:CommentCode( toggle ) range
	"
	" remove comments:
	" - remove '--' from the beginning of the line
	" and, in toggling mode:
	" - if the line is not a comment, comment it
	for i in range( a:firstline, a:lastline )
		if getline( i ) =~ '^--'
			silent exe i."s/^--//"
		elseif a:toggle
			silent exe i."s/^/--/"
		endif
	endfor
	"
endfunction    " ----------  end of function s:CommentCode  ----------
"
"-------------------------------------------------------------------------------
" s:InsertLongComment : Insert a --[[ --]] comment block.   {{{1
"-------------------------------------------------------------------------------
"
function! s:InsertLongComment( mode )
	"
	let cmt_counter = 0
	let save_line   = line(".")
	let actual_line = 0
	"
	" search for the maximum option number (if any)
	"
	normal! gg
	while actual_line < search ( s:Lua_CommentLabel.'\d\+' )
		let actual_line = line ('.')
		let actual_opt  = matchstr ( getline(actual_line), s:Lua_CommentLabel.'\zs\d\+' )
		if cmt_counter < actual_opt
			let cmt_counter = actual_opt
		endif
	endwhile
	"
	let cmt_counter = cmt_counter + 1
	silent exe ":".save_line
	"
	" insert the comment block
	"
	if a:mode == 'a'
		let zz  = "--[[  -- ".s:Lua_CommentLabel.cmt_counter." --\n"
		let zz .= "--]]  -- ".s:Lua_CommentLabel.cmt_counter." --"
		put =zz
	elseif a:mode == 'v'
		let zz=      "--[[  -- ".s:Lua_CommentLabel.cmt_counter." --"
		'<put! =zz
		let zz=      "--]]  -- ".s:Lua_CommentLabel.cmt_counter." --"
		'>put  =zz
	endif
endfunction    " ----------  end of function s:InsertLongComment  ----------
"
"-------------------------------------------------------------------------------
" s:RemoveLongComment : Remove a --[[ --]] comment block.   {{{1
"-------------------------------------------------------------------------------
"
function! s:RemoveLongComment()
	"
	let frstline = searchpair( '^--\[\[\s*--\s*'.s:Lua_CommentLabel.'\d\+',
				\                    '',
				\                    '^--\]\]\s*--\s*'.s:Lua_CommentLabel.'\d\+',
				\                    'bcn' )
	"
	if frstline <= 0
		return s:ImportantMsg ( 'no comment block/tag found or cursor not inside a comment block' )
	endif
	"
	let lastline = searchpair( '^--\[\[\s*--\s*'.s:Lua_CommentLabel.'\d\+',
				\                    '',
				\                    '^--\]\]\s*--\s*'.s:Lua_CommentLabel.'\d\+',
				\                    'n' )
	"
	if lastline <= 0
		return s:ImportantMsg ( 'no comment block/tag found or cursor not inside a comment block' )
	endif
	"
	let actualnumber1 = matchstr( getline(frstline), s:Lua_CommentLabel."\\d\\+" )
	let actualnumber2 = matchstr( getline(lastline), s:Lua_CommentLabel."\\d\\+" )
	"
	if actualnumber1 != actualnumber2
		return s:ImportantMsg ( 'lines '.frstline.', '.lastline.': comment tags do not match' )
	endif
	"
	silent exe ':'.lastline.'d'
	silent exe ':'.frstline.'d'
	"
	return s:ImportantMsg ( 'removed the block comment from lines '.frstline.' to '.lastline )
	"
endfunction    " ----------  end of function s:RemoveLongComment  ----------
"
"-------------------------------------------------------------------------------
" s:GetFunctionParameters : Get the name, parameters, ... of a function.   {{{1
"
" Parameters:
"   fun_line - the function definition (string)
" Returns:
"   [ <fun_name>, <params> ] - data (list: string, list)
"
" The entries are as follows:
"   file name - name of the function (string)
"   params    - the names of the parameters (list of strings)
"
" In case of an error, an empty list is returned.
"-------------------------------------------------------------------------------
function! s:GetFunctionParameters( fun_line )
	"
	" 1st expression: the syntax category
	" 2nd expression: as before, but with brackets to catch the match
	"
	let funcname     = '[a-zA-Z0-9_.:[:space:]]\+'
	let funcname_c   = '\('.funcname.'\)'
	let identifier   = '[a-zA-Z_][a-zA-Z0-9_]*'
	let identifier_c = '\('.identifier.'\)'
	"
	let name = ''
	let params = ''
	let param_list = []
	"
	" [ "local" ] "function" <func-name> "(" <param-list> ")"
	" captures: "local", <func-name>, <param-list>
	let mlist = matchlist ( a:fun_line, '^\s*\(local\s\+\)\?function\s*'.funcname_c.'(\([^)]*\))' )
	"
	if ! empty( mlist )
		"
		if mlist[1] =~ '^local' && mlist[2] =~ '[.:]'
			call s:ImportantMsg ( 'Illegal name for a local function.' )
			return []
		endif
		"
		let name   = substitute( mlist[2], '\s\+$', '', '' )
		let params = mlist[3]
		"
	endif
	"
	" [ "local" ] <func-name> "=" "function" "(" <param-list> ")"
	" captures: <func-name>, <param-list>
	if empty( mlist )
		"
		let mlist = matchlist ( a:fun_line, '^\([^=]\+\)\s*=\s*function\s*(\([^)]*\))' )
		"
		if ! empty( mlist )
			"
			let name   = substitute( mlist[1], '^\%(\s*local\)\?\s\+\|\s\+$', '', 'g' )
			let params = mlist[2]
			"
		endif
		"
	endif
	"
	" parse parameter list
	if ! empty( mlist )
		"
		while params !~ '^\s*$'
			let mlist_p = matchlist ( params, '^\s*\('.identifier.'\|\.\.\.\)\s*,\?\(.*\)$' )
			"
			if empty( mlist_p )
				call s:ImportantMsg ( 'Could not parse the parameter list.' )
				return []
			endif
			"
			call add ( param_list, mlist_p[1] )
			let params = mlist_p[2]
			"
		endwhile
		"
	else
		return []
	endif
	"
	return [ name, param_list ]
	"
endfunction    " ----------  end of function s:GetFunctionParameters  ----------
"
"-------------------------------------------------------------------------------
" s:FunctionComment : Automatically comment a function.   {{{1
"-------------------------------------------------------------------------------
"
function! s:FunctionComment() range
	"
	let	linestring = getline(a:firstline)
	for i in range(a:firstline+1,a:lastline)
		let	linestring .= ' '.getline(i)
	endfor
	"
	let res_list = s:GetFunctionParameters( linestring )
	"
	if empty( res_list )
		return s:ImportantMsg ( 'No function found.' )
	endif
	"
	" get all the parts
	let [ fun_name, param_list ] = res_list
	"
	if fun_name != ''
		call mmtemplates#core#InsertTemplate ( g:Lua_Templates, 'Comments.function description',
					\ '|FUNCTION_NAME|', fun_name, '|PARAMETERS|', param_list, 'placement', 'above' )
	else
		call mmtemplates#core#InsertTemplate ( g:Lua_Templates, 'Comments.function description',
					\ '|PARAMETERS|', param_list, 'placement', 'above' )
	endif
	"
endfunction    " ----------  end of function s:FunctionComment  ----------
"
"-------------------------------------------------------------------------------
" Lua_ModifyVariable : Modify a variable in the line.   {{{1
"-------------------------------------------------------------------------------
"
function! Lua_ModifyVariable ( mode, ... )
	"
	let col  = getpos('.')[2]-1
	let lstr = getline('.')
	let head = lstr[ 0     : col ]
	let tail = lstr[ col+1 : -1  ]
	"
	let [white,head] = matchlist ( head, '^\(\s*\)\(.*\)$' )[1:2]
	let var = matchstr ( head, '^.*\S\ze\s\{-}$' )
	"
	if var == ''
		return
	endif
	"
	let res = ''
	let setcol = -1
	"
	if a:mode == 'unary'
		let operation = a:1
		let res = var.' = '.operation.' '.var
	elseif a:mode == 'binary'
		let operation = a:1
		let operant2  = a:2
		let res = var.' = '.var.' '.operation.' '.operant2
	elseif a:mode == 'function'
		let func = a:1
		if a:0 == 1
			let res = var.' = '.func.' ( '.var.' )'
		else
			let param = a:2
			let res = var.' = '.func.' ( '.var.', '.param.' )'
		endif
		let setcol = len ( white.res ) - 2
	endif
	"
	if res != ''
		call setline ( '.', white.res )
		let curpos = getpos('.')
		if setcol == -1
			let curpos[2] = len ( white.res )
		else
			let curpos[2] = setcol
		endif
		call setpos ( '.', curpos )
	endif
	"
endfunction    " ----------  end of function Lua_ModifyVariable  ----------
"
"-------------------------------------------------------------------------------
" s:EscMagicChar : Automatically escape magic characters.   {{{1
"-------------------------------------------------------------------------------
"
function! s:EscMagicChar()
	"
	let col  = getpos('.')[2]
	let char = getline('.')[col-1]
	"
	if char =~ '\V\[$^()%.[\]*+\-?]'
		return '%'
	endif
	"
	return ''
endfunction    " ----------  end of function s:EscMagicChar  ----------

"-------------------------------------------------------------------------------
" s:OutputBufferErrors : Load the "Lua Output" buffer into quickfix.   {{{1
"
" Parameters:
"   jump - if non-zero, also jump to the first error (integer)
"-------------------------------------------------------------------------------

function! s:OutputBufferErrors ( jump )

	if bufname('%') !~ 'Lua Output$' && bufname('%') !~ 'Lua Terminal - '
		return s:ImportantMsg ( 'not inside a Lua output buffer' )
	endif

	cclose
	"
	" :TODO:26.03.2014 20:54:WM: check escaping of errorformat
	let errformat = substitute( s:Lua_Executable, '%\\%\\', '%\', 'g' ).': [string %.%\\+]:%\\d%\\+: %m,'
				\ .substitute( s:Lua_Executable, '%\\%\\', '%\', 'g' ).': %f:%l: %m,'
				\ .substitute( s:Lua_Executable, '%\\%\\', '%\', 'g' ).': %m,'
				\ .'%\\s%\\+[string %.%\\+]:%\\d%\\+: %m,'
				\ .'%f:%l: %m'
	"
	" save current settings
	let errorf_saved  = &l:errorformat
	"
	" run code checker
	let &l:errorformat = errformat
	"
	silent exe 'cgetbuffer'
	"
	" restore current settings
	let &l:errorformat = errorf_saved
	"
	botright cwindow
	"
	if a:jump != 0
		cc
	endif
	"
endfunction    " ----------  end of function s:OutputBufferErrors  ----------

"-------------------------------------------------------------------------------
" s:Run : Run the current buffer.   {{{1
"
" Parameters:
"   args - command-line arguments (string)
"-------------------------------------------------------------------------------

function! s:Run ( args )
	"
	silent exe 'update'   | " write source file if necessary
	cclose
	"
	" prepare and check the executable
	if ! executable( s:Lua_Executable )
		return s:ErrorMsg (
					\ 'Command "'.s:Lua_Executable.'" not found. Not configured correctly?',
					\ 'Further information: :help g:Lua_Executable' )
	endif
	"
	" recognized errors:
	" lua: [string ...]:line_in_string: msg
	" lua: file:line: msg
	" lua: msg
	"  [string ...]:line_in_string: msg
	" file:line: msg
	"
	" :TODO:26.03.2014 20:54:WM: check escaping of errorformat
	let errformat = substitute( s:Lua_Executable, '%\\%\\', '%\', 'g' ).': [string %.%\\+]:%\\d%\\+: %m,'
				\ .substitute( s:Lua_Executable, '%\\%\\', '%\', 'g' ).': %f:%l: %m,'
				\ .substitute( s:Lua_Executable, '%\\%\\', '%\', 'g' ).': %m,'
				\ .'%\\s%\\+[string %.%\\+]:%\\d%\\+: %m,'
				\ .'%f:%l: %m'
	"
	if s:Lua_DirectRun == 'yes' && executable ( expand ( '%:p' ) )
		let exec   = expand ( '%:p' )
		let script = ''
		let arg_list = [ exec ]
	else
		let exec   = s:Lua_Executable
		let script = shellescape ( expand ( '%' ) )
		let arg_list = [ exec, expand( '%' ) ]
	endif

	let exec = s:ShellEscExec ( exec )

	if s:Lua_OutputMethod == 'cmd-line'

		" method : "cmd.-line"

		exe '!'.exec.' '.script.' '.a:args

	elseif s:Lua_OutputMethod == 'quickfix'

		" method : "quickfix"

		" run script
		let lua_output = system ( exec.' '.script.' '.a:args )
		"
		" successful?
		if v:shell_error == 0
			" echo script output
			echo lua_output
		else
			" save current settings
			let errorf_saved = &g:errorformat

			" run code checker
			let &g:errorformat = errformat

			silent exe 'cexpr lua_output'

			" restore current settings
			let &g:errorformat = errorf_saved

			botright cwindow
			cc
		endif
	elseif s:Lua_OutputMethod == 'buffer'

		" method : "buffer"

		if bufwinnr ( 'Lua Output$' ) == -1
			" open buffer
			above new
			file Lua\ Output
			" TODO: name might exist on a different tab page

			" settings
			setlocal buftype=nofile
			setlocal noswapfile
			setlocal syntax=none
			setlocal tabstop=8

			call Lua_SetMapLeader ()

			" maps: quickfix list
			nnoremap  <buffer>  <silent>  <LocalLeader>qf       :call <SID>OutputBufferErrors(0)<CR>
			inoremap  <buffer>  <silent>  <LocalLeader>qf  <C-C>:call <SID>OutputBufferErrors(0)<CR>
			vnoremap  <buffer>  <silent>  <LocalLeader>qf  <C-C>:call <SID>OutputBufferErrors(0)<CR>
			nnoremap  <buffer>  <silent>  <LocalLeader>qj       :call <SID>OutputBufferErrors(1)<CR>
			inoremap  <buffer>  <silent>  <LocalLeader>qj  <C-C>:call <SID>OutputBufferErrors(1)<CR>
			vnoremap  <buffer>  <silent>  <LocalLeader>qj  <C-C>:call <SID>OutputBufferErrors(1)<CR>

			call Lua_ResetMapLeader ()
		else
			" jump to window
			exe bufwinnr( 'Lua Output$' ).'wincmd w'
		endif

		setlocal modifiable

		silent exe '%delete _'
		silent exe '0r!'.exec.' '.script.' '.a:args
		silent exe '$delete _'

		if v:shell_error == 0
			" jump to the first line of the output
			normal! gg

			setlocal nomodifiable
			setlocal nomodified
		else
			" jump to the last line of the output, where the error is mentioned
			normal! G

			" save current settings
			let errorf_saved  = &l:errorformat

			" run code checker
			let &l:errorformat = errformat

			silent exe 'cgetbuffer'

			" restore current settings
			let &l:errorformat = errorf_saved

			botright cwindow
			cc
		endif
	elseif s:Lua_OutputMethod == 'terminal'

		" method : "terminal"

		try
			let arg_list += s:ShellParseArgs ( a:args )      " expand to a list
		catch /^ShellParseArgs:Syntax:/
			let msg = v:exception[ len( 'ShellParseArgs:Syntax:') : -1 ]
			return s:WarningMsg ( 'syntax error while parsing arguments: '.msg )
		catch /.*/
			return s:WarningMsg (
						\ "internal error (" . v:exception . ")",
						\ " - occurred at " . v:throwpoint )
		endtry

		let title = 'Lua Terminal - '.expand( '%:t' )

		if s:NEOVIM
			" :TODO:11.10.2017 18:03:WM: better handling than using 'job_id', but ensures
			" successful operation for know
			above new
			let job_id = termopen ( arg_list, {} )

			silent exe 'file '.fnameescape( title.' -'.job_id.'-' )
		else
			call term_start ( arg_list, { 'term_name' : title, } )
		endif

		call Lua_SetMapLeader ()

		" maps: quickfix list
		if empty( maparg( '<LocalLeader>qf', 'n' ) )
			nnoremap  <buffer>  <silent>  <LocalLeader>qf       :call <SID>OutputBufferErrors(0)<CR>
			inoremap  <buffer>  <silent>  <LocalLeader>qf  <C-C>:call <SID>OutputBufferErrors(0)<CR>
			vnoremap  <buffer>  <silent>  <LocalLeader>qf  <C-C>:call <SID>OutputBufferErrors(0)<CR>
		endif
		if empty( maparg( '<LocalLeader>qj', 'n' ) )
			nnoremap  <buffer>  <silent>  <LocalLeader>qj       :call <SID>OutputBufferErrors(1)<CR>
			inoremap  <buffer>  <silent>  <LocalLeader>qj  <C-C>:call <SID>OutputBufferErrors(1)<CR>
			vnoremap  <buffer>  <silent>  <LocalLeader>qj  <C-C>:call <SID>OutputBufferErrors(1)<CR>
		endif

		call Lua_ResetMapLeader ()

	elseif s:Lua_OutputMethod == 'xterm'

		" method : "xterm"

		if s:Xterm_Executable =~ '\cxterm'
			let title = ' -title Lua'
		else
			let title = ''
		endif
		let args = a:args

		silent exe '!'.s:Xterm_Executable.' '.g:Xterm_Options.title
					\ .' -e '.shellescape( exec.' '.script.' '.args.' ; echo "" ; read -p "  ** PRESS ENTER **  " dummy ' ).' &'

		call s:Redraw ( 'r!', '' )                  " redraw in terminal
	endif
endfunction    " ----------  end of function s:Run  ----------

"-------------------------------------------------------------------------------
" s:Compile : Compile or check the code.   {{{1
"
" Parameters:
"   mode - "compile" or "check" (string)
"-------------------------------------------------------------------------------

function! s:Compile( mode ) range
	"
	silent exe 'update'   | " write source file if necessary
	cclose
	"
	" prepare and check the executable
	if ! executable( s:Lua_CompilerExec )
		return s:ErrorMsg (
					\ 'Command "'.s:Lua_CompilerExec.'" not found. Not configured correctly?',
					\ 'Further information: :help g:Lua_CompilerExec' )
	endif
	"
	if a:mode == 'compile'
		let switch = fnamemodify( bufname('%'), ':p:r' )
		if ! empty( g:Lua_CompiledExtension )
			let switch .= '.'.g:Lua_CompiledExtension
		endif
		let switch = '-o '.shellescape ( switch )
	elseif a:mode == 'check'
		let switch = '-p'
	else
		return s:ErrorMsg ( 'Unknown mode "'.a:mode.'"' )
	endif
	"
	" save current settings
	let	makeprg_saved	= &l:makeprg
	let errorf_saved  = &l:errorformat
	"
	" run code checker
	" :TODO:26.03.2014 20:54:WM: check escaping of errorformat
	let &l:makeprg = s:ShellEscExec( s:Lua_CompilerExec )
	let &l:errorformat = substitute( s:Lua_CompilerExec, '%\\%\\', '%\', 'g' ).': %f:%l: %m,'.substitute( s:Lua_CompilerExec, '%\\%\\', '%\', 'g' ).': %m'
	"
	let v:statusmsg = ''                               " reset, so we are able to check it below
	silent exe 'make '.switch.' '.shellescape( bufname('%') )
	"
	" restore current settings
	let &l:makeprg = makeprg_saved
	let &l:errorformat = errorf_saved

	" any errors?
	if a:mode == 'compile' && empty ( v:statusmsg )
		call s:Redraw('r!','r')                     " redraw after cclose, before echoing
		call s:ImportantMsg ( bufname('%').': Compiled successfully.' )
	elseif a:mode == 'check' && empty ( v:statusmsg )
		call s:Redraw('r!','r')                     " redraw after cclose, before echoing
		call s:ImportantMsg ( bufname('%').': No warnings.' )
	else
		call s:Redraw('r!','')                      " redraw after cclose, before opening the new window
		botright cwindow
		cc
	endif

endfunction    " ----------  end of function s:Compile  ----------

"-------------------------------------------------------------------------------
" === Run: Executable, arguments, output, ... ===   {{{1
"-------------------------------------------------------------------------------

"-------------------------------------------------------------------------------
" s:SetExecutable : Set s:Lua_Executable or s:Lua_CompilerExec   {{{2
"-------------------------------------------------------------------------------
function! s:SetExecutable ( exe_type, new_exec )

	if a:exe_type == 'exe'
		let var = 's:Lua_Executable'
	elseif a:exe_type == 'compile'
		let var = 's:Lua_CompilerExec'
	else
		return s:ErrorMsg ( 'Unknown type "'.a:exe_type.'".' )
	endif

	let new_exec = expand ( a:new_exec )

	if new_exec == ''
		echo {var}
	elseif ! executable ( new_exec )
		return s:ErrorMsg ( '"'.new_exec.'" is not executable, nothing set.' )
	else
		let {var} = new_exec
	endif
endfunction    " ----------  end of function s:SetExecutable  ----------

"-------------------------------------------------------------------------------
" s:GetOutputMethodList : For cmd.-line completion.   {{{2
"-------------------------------------------------------------------------------
function! s:GetOutputMethodList (...)
	return join ( s:Lua_OutputMethodList, "\n" )
endfunction    " ----------  end of function s:GetOutputMethodList  ----------

"-------------------------------------------------------------------------------
" s:SetOutputMethod : Set s:Lua_OutputMethod   {{{2
"-------------------------------------------------------------------------------
function! s:SetOutputMethod ( method )

	if a:method == ''
		echo s:Lua_OutputMethod
		return
	endif

	" 'method' gives the output method
	if index ( s:Lua_OutputMethodList, a:method ) == -1
		return s:ErrorMsg ( 'Invalid option for output method: "'.a:method.'".' )
	endif

	let s:Lua_OutputMethod = a:method

	" update the menu header
	if ! has ( 'menu' ) || s:MenuVisible == 0
		return
	endif

	exe 'aunmenu '.s:Lua_RootMenu.'.Run.output\ method.Output\ Method'

	if s:Lua_OutputMethod == 'cmd-line'
		let current = 'cmd\.-line'
	elseif s:Lua_OutputMethod == 'quickfix'
		let current = 'quickfix'
	elseif s:Lua_OutputMethod == 'buffer'
		let current = 'buffer'
	elseif s:Lua_OutputMethod == 'terminal'
		let current = 'terminal'
	elseif s:Lua_OutputMethod == 'xterm'
		let current = 'xterm'
	endif

	exe 'anoremenu ...400 '.s:Lua_RootMenu.'.Run.output\ method.Output\ Method<TAB>(current\:\ '.current.') :echo "This is a menu header."<CR>'

endfunction    " ----------  end of function s:SetOutputMethod  ----------

"-------------------------------------------------------------------------------
" s:GetDirectRunList : For cmd.-line completion.   {{{2
"-------------------------------------------------------------------------------
function! s:GetDirectRunList (...)
	return "yes\nno"
endfunction    " ----------  end of function s:GetDirectRunList  ----------

"-------------------------------------------------------------------------------
" s:SetDirectRun : Set s:Lua_DirectRun   {{{2
"-------------------------------------------------------------------------------
function! s:SetDirectRun ( option )

	if a:option == ''
		echo s:Lua_DirectRun
		return
	endif

	" 'option' gives the setting
	if a:option != 'yes' && a:option != 'no'
		return s:ErrorMsg ( 'Invalid option for direct run: "'.a:option.'".' )
	endif

	let s:Lua_DirectRun = a:option

	" update the menu header
	if ! has ( 'menu' ) || s:MenuVisible == 0
		return
	endif

	exe 'aunmenu '.s:Lua_RootMenu.'.Run.direct\ run.Direct\ Run'

	let current = s:Lua_DirectRun

	exe 'anoremenu ...400 '.s:Lua_RootMenu.'.Run.direct\ run.Direct\ Run<TAB>(currently\:\ '.current.') :echo "This is a menu header."<CR>'

endfunction    " ----------  end of function s:SetDirectRun  ----------
" }}}2
"-------------------------------------------------------------------------------

"-------------------------------------------------------------------------------
" s:HelpPlugin : Plug-in help.   {{{1
"-------------------------------------------------------------------------------
function! s:HelpPlugin ()
	try
		help lua-support
	catch
		exe 'helptags '.s:plugin_dir.'/doc'
		help lua-support
	endtry
endfunction   " ----------  end of function s:HelpPlugin  ----------

"------------------------------------------------------------------------------
" === Templates API ===   {{{1
"------------------------------------------------------------------------------
"
"------------------------------------------------------------------------------
"  Lua_SetMapLeader   {{{2
"------------------------------------------------------------------------------
function! Lua_SetMapLeader ()
	if exists ( 'g:Lua_MapLeader' )
		call mmtemplates#core#SetMapleader ( g:Lua_MapLeader )
	endif
endfunction    " ----------  end of function Lua_SetMapLeader  ----------
"
"------------------------------------------------------------------------------
"  Lua_ResetMapLeader   {{{2
"------------------------------------------------------------------------------
function! Lua_ResetMapLeader ()
	if exists ( 'g:Lua_MapLeader' )
		call mmtemplates#core#ResetMapleader ()
	endif
endfunction    " ----------  end of function Lua_ResetMapLeader  ----------
" }}}2
"
"-------------------------------------------------------------------------------
" s:SetupTemplates : Initial loading of the templates.   {{{1
"-------------------------------------------------------------------------------
"
function! s:SetupTemplates()
	"
	"-------------------------------------------------------------------------------
	" setup template library
	"-------------------------------------------------------------------------------
	let g:Lua_Templates = mmtemplates#core#NewLibrary ( 'api_version', '1.0' )
	"
	" mapleader
	if empty ( g:Lua_MapLeader )
		call mmtemplates#core#Resource ( g:Lua_Templates, 'set', 'property', 'Templates::Mapleader', '\' )
	else
		call mmtemplates#core#Resource ( g:Lua_Templates, 'set', 'property', 'Templates::Mapleader', g:Lua_MapLeader )
	endif
	"
	" some metainfo
	call mmtemplates#core#Resource ( g:Lua_Templates, 'set', 'property', 'Templates::Wizard::PluginName',   'Lua' )
	call mmtemplates#core#Resource ( g:Lua_Templates, 'set', 'property', 'Templates::Wizard::FiletypeName', 'Lua' )
	call mmtemplates#core#Resource ( g:Lua_Templates, 'set', 'property', 'Templates::Wizard::FileCustomNoPersonal',   s:plugin_dir.'/lua-support/rc/custom.templates' )
	call mmtemplates#core#Resource ( g:Lua_Templates, 'set', 'property', 'Templates::Wizard::FileCustomWithPersonal', s:plugin_dir.'/lua-support/rc/custom_with_personal.templates' )
	call mmtemplates#core#Resource ( g:Lua_Templates, 'set', 'property', 'Templates::Wizard::FilePersonal',           s:plugin_dir.'/lua-support/rc/personal.templates' )
	call mmtemplates#core#Resource ( g:Lua_Templates, 'set', 'property', 'Templates::Wizard::CustomFileVariable',     'g:Lua_CustomTemplateFile' )
	"
	" maps: special operations
	call mmtemplates#core#Resource ( g:Lua_Templates, 'set', 'property', 'Templates::RereadTemplates::Map', 'ntr' )
	call mmtemplates#core#Resource ( g:Lua_Templates, 'set', 'property', 'Templates::ChooseStyle::Map',     'nts' )
	call mmtemplates#core#Resource ( g:Lua_Templates, 'set', 'property', 'Templates::SetupWizard::Map',     'ntw' )
	"
	" syntax: comments
	call mmtemplates#core#ChangeSyntax ( g:Lua_Templates, 'comment', '§' )

	" property: file skeletons
	call mmtemplates#core#Resource ( g:Lua_Templates, 'add', 'property', 'Lua::FileSkeleton::Script', 'Comments.file description' )

	"-------------------------------------------------------------------------------
	" load template library
	"-------------------------------------------------------------------------------
	"
	" global templates (global installation only)
	if s:installation == 'system'
		call mmtemplates#core#ReadTemplates ( g:Lua_Templates, 'load', s:Lua_GlobalTemplateFile,
					\ 'name', 'global', 'map', 'ntg' )
	endif
	"
	" local templates (optional for global installation)
	if s:installation == 'system'
		call mmtemplates#core#ReadTemplates ( g:Lua_Templates, 'load', s:Lua_LocalTemplateFile,
					\ 'name', 'local', 'map', 'ntl', 'optional', 'hidden' )
	else
		call mmtemplates#core#ReadTemplates ( g:Lua_Templates, 'load', s:Lua_LocalTemplateFile,
					\ 'name', 'local', 'map', 'ntl' )
	endif
	"
	" additional templates (optional)
	if ! empty ( s:Lua_AdditionalTemplates )
		call mmtemplates#core#AddCustomTemplateFiles ( g:Lua_Templates, s:Lua_AdditionalTemplates, "Lua's additional templates" )
	endif
	"
	" personal templates (shared across template libraries) (optional, existence of file checked by template engine)
	call mmtemplates#core#ReadTemplates ( g:Lua_Templates, 'personalization',
				\ 'name', 'personal', 'map', 'ntp' )
	"
	" custom templates (optional, existence of file checked by template engine)
	call mmtemplates#core#ReadTemplates ( g:Lua_Templates, 'load', s:Lua_CustomTemplateFile,
				\ 'name', 'custom', 'map', 'ntc', 'optional' )
	"
endfunction    " ----------  end of function s:SetupTemplates  ----------
"
"-------------------------------------------------------------------------------
" s:CheckTemplatePersonalization : Check whether the name, .. has been set.   {{{1
"-------------------------------------------------------------------------------

let s:DoneCheckTemplatePersonalization = 0

function! s:CheckTemplatePersonalization ()

	" check whether the templates are personalized
	if s:DoneCheckTemplatePersonalization
				\ || mmtemplates#core#ExpandText ( g:Lua_Templates, '|AUTHOR|' ) != 'YOUR NAME'
				\ || g:Lua_InsertFileHeader != 'yes'
		return
	endif

	let s:DoneCheckTemplatePersonalization = 1

	let maplead = mmtemplates#core#Resource ( g:Lua_Templates, 'get', 'property', 'Templates::Mapleader' )[0]

	redraw
	call s:ImportantMsg ( 'The personal details are not set in the template library. Use the map "'.maplead.'ntw".' )

endfunction    " ----------  end of function s:CheckTemplatePersonalization  ----------

"-------------------------------------------------------------------------------
" s:InsertFileHeader : Insert a header for a new file.   {{{1
"-------------------------------------------------------------------------------

function! s:InsertFileHeader ()

	if ! exists ( 'g:Lua_Templates' )
		return
	endif

	if g:Lua_InsertFileHeader == 'yes'
		let templ_s = mmtemplates#core#Resource ( g:Lua_Templates, 'get', 'property', 'Lua::FileSkeleton::Script' )[0]

		" insert templates in reverse order, always above the first line
		" the last one to insert (the first in the list), will determine the
		" placement of the cursor
		let templ_l = split ( templ_s, ';' )
		for i in range ( len(templ_l)-1, 0, -1 )
			exe 1
			if -1 != match ( templ_l[i], '^\s\+$' )
				put! =''
			else
				call mmtemplates#core#InsertTemplate ( g:Lua_Templates, templ_l[i], 'placement', 'above' )
			endif
		endfor
		if len(templ_l) > 0
			set modified
		endif
	endif
endfunction    " ----------  end of function s:InsertFileHeader  ----------

"-------------------------------------------------------------------------------
" s:CreateMaps : Create additional maps.   {{{1
"-------------------------------------------------------------------------------
"
function! s:CreateMaps ()
	"
	"-------------------------------------------------------------------------------
	" user defined commands (only working in Lua buffers)
	"-------------------------------------------------------------------------------
	"
	command! -nargs=* -buffer -complete=file Lua          call <SID>Run(<q-args>)
	command! -nargs=0 -buffer -complete=file LuaCompile   call <SID>Compile('compile')
	command! -nargs=0 -buffer -complete=file LuaCheck     call <SID>Compile('check')
	"
	"-------------------------------------------------------------------------------
	" settings - local leader
	"-------------------------------------------------------------------------------
	if ! empty ( g:Lua_MapLeader )
		if exists ( 'g:maplocalleader' )
			let ll_save = g:maplocalleader
		endif
		let g:maplocalleader = g:Lua_MapLeader
	endif
	"
	"-------------------------------------------------------------------------------
	" comments
	"-------------------------------------------------------------------------------
	 noremap    <buffer>  <silent>  <LocalLeader>cl         :call <SID>EndOfLineComment()<CR>
	inoremap    <buffer>  <silent>  <LocalLeader>cl    <Esc>:call <SID>EndOfLineComment()<CR>
	 noremap    <buffer>  <silent>  <LocalLeader>cj         :call <SID>AdjustEndOfLineComm()<CR>
	inoremap    <buffer>  <silent>  <LocalLeader>cj    <Esc>:call <SID>AdjustEndOfLineComm()<CR>
	 noremap    <buffer>  <silent>  <LocalLeader>cs         :call <SID>SetEndOfLineCommPos()<CR>
	inoremap    <buffer>  <silent>  <LocalLeader>cs    <Esc>:call <SID>SetEndOfLineCommPos()<CR>
	"
	 noremap    <buffer>  <silent>  <LocalLeader>cc         :call <SID>CodeComment()<CR>
	inoremap    <buffer>  <silent>  <LocalLeader>cc    <Esc>:call <SID>CodeComment()<CR>
	 noremap    <buffer>  <silent>  <LocalLeader>co         :call <SID>CommentCode(0)<CR>
	inoremap    <buffer>  <silent>  <LocalLeader>co    <Esc>:call <SID>CommentCode(0)<CR>
	 noremap    <buffer>  <silent>  <LocalLeader>ct         :call <SID>CommentCode(1)<CR>
	inoremap    <buffer>  <silent>  <LocalLeader>ct    <Esc>:call <SID>CommentCode(1)<CR>
	"
	nnoremap    <buffer>  <silent> <LocalLeader>cil         :call <SID>InsertLongComment('a')<CR>
	inoremap    <buffer>  <silent> <LocalLeader>cil    <C-C>:call <SID>InsertLongComment('a')<CR>
	vnoremap    <buffer>  <silent> <LocalLeader>cil    <C-C>:call <SID>InsertLongComment('v')<CR>
	nnoremap    <buffer>  <silent> <LocalLeader>crl         :call <SID>RemoveLongComment()<CR>
	inoremap    <buffer>  <silent> <LocalLeader>crl    <C-C>:call <SID>RemoveLongComment()<CR>
	vnoremap    <buffer>  <silent> <LocalLeader>crl    <C-C>:call <SID>RemoveLongComment()<CR>
	"
	 noremap    <buffer>  <silent>  <LocalLeader>ca         :call <SID>FunctionComment()<CR>
	inoremap    <buffer>  <silent>  <LocalLeader>ca    <Esc>:call <SID>FunctionComment()<CR>
	"
	"-------------------------------------------------------------------------------
	" regex
	"-------------------------------------------------------------------------------
	nnoremap    <buffer>  <silent>  <LocalLeader>xe     i<C-R>=<SID>EscMagicChar()<CR><ESC><Right>
	inoremap    <buffer>  <silent>  <LocalLeader>xe      <C-R>=<SID>EscMagicChar()<CR>
	"
	"-------------------------------------------------------------------------------
	" snippets
	"-------------------------------------------------------------------------------
	nnoremap    <buffer>  <silent> <LocalLeader>ni         :call <SID>CodeSnippet('insert')<CR>
	inoremap    <buffer>  <silent> <LocalLeader>ni    <C-C>:call <SID>CodeSnippet('insert')<CR>
	vnoremap    <buffer>  <silent> <LocalLeader>ni    <C-C>:call <SID>CodeSnippet('insert')<CR>
	nnoremap    <buffer>  <silent> <LocalLeader>nc         :call <SID>CodeSnippet('create')<CR>
	inoremap    <buffer>  <silent> <LocalLeader>nc    <C-C>:call <SID>CodeSnippet('create')<CR>
	vnoremap    <buffer>  <silent> <LocalLeader>nc    <C-C>:call <SID>CodeSnippet('vcreate')<CR>
	nnoremap    <buffer>  <silent> <LocalLeader>nv         :call <SID>CodeSnippet('view')<CR>
	inoremap    <buffer>  <silent> <LocalLeader>nv    <C-C>:call <SID>CodeSnippet('view')<CR>
	vnoremap    <buffer>  <silent> <LocalLeader>nv    <C-C>:call <SID>CodeSnippet('view')<CR>
	nnoremap    <buffer>  <silent> <LocalLeader>ne         :call <SID>CodeSnippet('edit')<CR>
	inoremap    <buffer>  <silent> <LocalLeader>ne    <C-C>:call <SID>CodeSnippet('edit')<CR>
	vnoremap    <buffer>  <silent> <LocalLeader>ne    <C-C>:call <SID>CodeSnippet('edit')<CR>
	"
	"-------------------------------------------------------------------------------
	" run, compile, checker
	"-------------------------------------------------------------------------------
	nnoremap    <buffer>  <silent>  <LocalLeader>rr         :call <SID>Run('')<CR>
	inoremap    <buffer>  <silent>  <LocalLeader>rr    <Esc>:call <SID>Run('')<CR>
	vnoremap    <buffer>  <silent>  <LocalLeader>rr    <Esc>:call <SID>Run('')<CR>
	nnoremap    <buffer>  <silent>  <LocalLeader>rc         :call <SID>Compile('compile')<CR>
	inoremap    <buffer>  <silent>  <LocalLeader>rc    <Esc>:call <SID>Compile('compile')<CR>
	vnoremap    <buffer>  <silent>  <LocalLeader>rc    <Esc>:call <SID>Compile('compile')<CR>
	nnoremap    <buffer>  <silent>  <LocalLeader>rk         :call <SID>Compile('check')<CR>
	inoremap    <buffer>  <silent>  <LocalLeader>rk    <Esc>:call <SID>Compile('check')<CR>
	vnoremap    <buffer>  <silent>  <LocalLeader>rk    <Esc>:call <SID>Compile('check')<CR>
	nnoremap    <buffer>  <silent>  <LocalLeader>re         :call <SID>MakeExecutable()<CR>
	inoremap    <buffer>  <silent>  <LocalLeader>re    <Esc>:call <SID>MakeExecutable()<CR>
	vnoremap    <buffer>  <silent>  <LocalLeader>re    <Esc>:call <SID>MakeExecutable()<CR>
	"
	"-------------------------------------------------------------------------------
	" output method
	"-------------------------------------------------------------------------------
	nnoremap    <buffer>            <LocalLeader>ro         :LuaOutputMethod<SPACE>
	inoremap    <buffer>            <LocalLeader>ro    <Esc>:LuaOutputMethod<SPACE>
	vnoremap    <buffer>            <LocalLeader>ro    <Esc>:LuaOutputMethod<SPACE>
	nnoremap    <buffer>            <LocalLeader>rd         :LuaDirectRun<SPACE>
	inoremap    <buffer>            <LocalLeader>rd    <Esc>:LuaDirectRun<SPACE>
	vnoremap    <buffer>            <LocalLeader>rd    <Esc>:LuaDirectRun<SPACE>
	nnoremap    <buffer>            <LocalLeader>rse        :LuaExecutable<SPACE>
	inoremap    <buffer>            <LocalLeader>rse   <Esc>:LuaExecutable<SPACE>
	vnoremap    <buffer>            <LocalLeader>rse   <Esc>:LuaExecutable<SPACE>
	nnoremap    <buffer>            <LocalLeader>rsc        :LuaCompilerExec<SPACE>
	inoremap    <buffer>            <LocalLeader>rsc   <Esc>:LuaCompilerExec<SPACE>
	vnoremap    <buffer>            <LocalLeader>rsc   <Esc>:LuaCompilerExec<SPACE>
	"
	"-------------------------------------------------------------------------------
	" hardcopy
	"-------------------------------------------------------------------------------
	nnoremap    <buffer>  <silent> <LocalLeader>rh         :call <SID>Hardcopy('n')<CR>
	inoremap    <buffer>  <silent> <LocalLeader>rh    <C-C>:call <SID>Hardcopy('n')<CR>
	vnoremap    <buffer>  <silent> <LocalLeader>rh    <C-C>:call <SID>Hardcopy('v')<CR>
	"
	"-------------------------------------------------------------------------------
	" settings
	"-------------------------------------------------------------------------------
	nnoremap    <buffer>  <silent>  <LocalLeader>rs         :call Lua_Settings(0)<CR>
	inoremap    <buffer>  <silent>  <LocalLeader>rs    <Esc>:call Lua_Settings(0)<CR>
	vnoremap    <buffer>  <silent>  <LocalLeader>rs    <Esc>:call Lua_Settings(0)<CR>
	"
	"-------------------------------------------------------------------------------
	" help
	"-------------------------------------------------------------------------------
	nnoremap    <buffer>  <silent>  <LocalLeader>hs         :call <SID>HelpPlugin()<CR>
	inoremap    <buffer>  <silent>  <LocalLeader>hs    <Esc>:call <SID>HelpPlugin()<CR>
	vnoremap    <buffer>  <silent>  <LocalLeader>hs    <Esc>:call <SID>HelpPlugin()<CR>
	"
	"-------------------------------------------------------------------------------
	" toolbox
	"-------------------------------------------------------------------------------
	if s:Lua_UseToolbox == 'yes'
		call mmtoolbox#tools#AddMaps ( s:Lua_Toolbox )
	endif
	"
	"-------------------------------------------------------------------------------
	" settings - reset local leader
	"-------------------------------------------------------------------------------
	if ! empty ( g:Lua_MapLeader )
		if exists ( 'll_save' )
			let g:maplocalleader = ll_save
		else
			unlet g:maplocalleader
		endif
	endif
	"
	"-------------------------------------------------------------------------------
	" templates
	"-------------------------------------------------------------------------------

	let args = [ 'g:Lua_Templates', g:Lua_MapLeader, 'do_special_maps' ]
	if g:Lua_Ctrl_j == 'yes'
		call add ( args, 'do_jump_map' )
	endif
	if g:Lua_Ctrl_d == 'yes'
		call add ( args, 'do_del_opt_map' )
	endif

	call call ( function ( 'mmtemplates#core#CreateMaps' ), args )

endfunction   " ----------  end of function s:CreateMaps  ----------

"-------------------------------------------------------------------------------
" s:InitMenus : Initialize menus.   {{{1
"-------------------------------------------------------------------------------
"
function! s:InitMenus()
	"
	if ! has ( 'menu' )
		return
	endif
	"
	" preparation
	call mmtemplates#core#CreateMenus ( 'g:Lua_Templates', s:Lua_RootMenu, 'do_reset' )
	"
	" get the mapleader (correctly escaped)
	let [ esc_mapl, err ] = mmtemplates#core#Resource ( g:Lua_Templates, 'escaped_mapleader' )
	"
	exe 'anoremenu '.s:Lua_RootMenu.'.Lua     <Nop>'
	exe 'anoremenu '.s:Lua_RootMenu.'.-Sep00- <Nop>'
	"
	"-------------------------------------------------------------------------------
	" menu headers
	"-------------------------------------------------------------------------------
	"
	call mmtemplates#core#CreateMenus ( 'g:Lua_Templates', s:Lua_RootMenu, 'sub_menu', '&Comments', 'priority', 500 )
	" the other, automatically created menus go here; their priority is the standard priority 500
	call mmtemplates#core#CreateMenus ( 'g:Lua_Templates', s:Lua_RootMenu, 'sub_menu', 'S&nippets', 'priority', 600 )
	call mmtemplates#core#CreateMenus ( 'g:Lua_Templates', s:Lua_RootMenu, 'sub_menu', '&Run'     , 'priority', 700 )
	if s:Lua_UseToolbox == 'yes' && mmtoolbox#tools#Property ( s:Lua_Toolbox, 'empty-menu' ) == 0
		call mmtemplates#core#CreateMenus ( 'g:Lua_Templates', s:Lua_RootMenu, 'sub_menu', '&Tool\ Box', 'priority', 800 )
	endif
	call mmtemplates#core#CreateMenus ( 'g:Lua_Templates', s:Lua_RootMenu, 'sub_menu', '&Help'    , 'priority', 900 )
	"
	"-------------------------------------------------------------------------------
	" comments
	"-------------------------------------------------------------------------------

	let ahead = 'anoremenu <silent> '.s:Lua_RootMenu.'.Comments.'
	let vhead = 'vnoremenu <silent> '.s:Lua_RootMenu.'.Comments.'
	let ihead = 'inoremenu <silent> '.s:Lua_RootMenu.'.Comments.'

	exe ahead.'end-of-&line\ comment<TAB>'.esc_mapl.'cl                 :call <SID>EndOfLineComment()<CR>'
	exe vhead.'end-of-&line\ comment<TAB>'.esc_mapl.'cl                 :call <SID>EndOfLineComment()<CR>'
	exe ihead.'end-of-&line\ comment<TAB>'.esc_mapl.'cl            <Esc>:call <SID>EndOfLineComment()<CR>'
	exe ahead.'ad&just\ end-of-line\ com\.<TAB>'.esc_mapl.'cj           :call <SID>AdjustEndOfLineComm()<CR>'
	exe vhead.'ad&just\ end-of-line\ com\.<TAB>'.esc_mapl.'cj           :call <SID>AdjustEndOfLineComm()<CR>'
	exe ihead.'ad&just\ end-of-line\ com\.<TAB>'.esc_mapl.'cj      <Esc>:call <SID>AdjustEndOfLineComm()<CR>'
	exe ahead.'&set\ end-of-line\ com\.\ col\.<TAB>'.esc_mapl.'cs       :call <SID>SetEndOfLineCommPos()<CR>'
	exe vhead.'&set\ end-of-line\ com\.\ col\.<TAB>'.esc_mapl.'cs       :call <SID>SetEndOfLineCommPos()<CR>'
	exe ihead.'&set\ end-of-line\ com\.\ col\.<TAB>'.esc_mapl.'cs  <Esc>:call <SID>SetEndOfLineCommPos()<CR>'
	exe ahead.'-Sep01-                                             :'

	exe ahead.'&code\ ->\ comment<TAB>'.esc_mapl.'cc              :call <SID>CodeComment()<CR>'
	exe vhead.'&code\ ->\ comment<TAB>'.esc_mapl.'cc              :call <SID>CodeComment()<CR>'
	exe ihead.'&code\ ->\ comment<TAB>'.esc_mapl.'cc         <ESC>:call <SID>CodeComment()<CR>'
	exe ahead.'c&omment\ ->\ code<TAB>'.esc_mapl.'co              :call <SID>CommentCode(0)<CR>'
	exe vhead.'c&omment\ ->\ code<TAB>'.esc_mapl.'co              :call <SID>CommentCode(0)<CR>'
	exe ihead.'c&omment\ ->\ code<TAB>'.esc_mapl.'co         <ESC>:call <SID>CommentCode(0)<CR>'
	exe ahead.'&toggle\ code\ <->\ com\.<TAB>'.esc_mapl.'ct       :call <SID>CommentCode(1)<CR>'
	exe vhead.'&toggle\ code\ <->\ com\.<TAB>'.esc_mapl.'ct       :call <SID>CommentCode(1)<CR>'
	exe ihead.'&toggle\ code\ <->\ com\.<TAB>'.esc_mapl.'ct  <ESC>:call <SID>CommentCode(1)<CR>'

	exe ahead.'insert\ long\ comment<Tab>'.esc_mapl.'cil       :call <SID>InsertLongComment("a")<CR>'
	exe vhead.'insert\ long\ comment<Tab>'.esc_mapl.'cil  <C-C>:call <SID>InsertLongComment("v")<CR>'
	exe ihead.'insert\ long\ comment<Tab>'.esc_mapl.'cil  <C-C>:call <SID>InsertLongComment("a")<CR>'
	exe ahead.'remove\ long\ comment<Tab>'.esc_mapl.'crl       :call <SID>RemoveLongComment()<CR>'
	exe ihead.'remove\ long\ comment<Tab>'.esc_mapl.'crl  <C-C>:call <SID>RemoveLongComment()<CR>'
	exe ahead.'-Sep02-                                         :'

	exe ahead.'function\ description\ (&auto)<TAB>'.esc_mapl.'ca       :call <SID>FunctionComment()<CR>'
	exe vhead.'function\ description\ (&auto)<TAB>'.esc_mapl.'ca       :call <SID>FunctionComment()<CR>'
	exe ihead.'function\ description\ (&auto)<TAB>'.esc_mapl.'ca  <Esc>:call <SID>FunctionComment()<CR>'
	exe ahead.'-Sep03-                                                 :'

	"-------------------------------------------------------------------------------
	" templates
	"-------------------------------------------------------------------------------
	"
	call mmtemplates#core#CreateMenus ( 'g:Lua_Templates', s:Lua_RootMenu, 'do_templates' )
	"
	"-------------------------------------------------------------------------------
	" regex
	"-------------------------------------------------------------------------------
	"
	let ahead = 'anoremenu <silent> '.s:Lua_RootMenu.'.Regex.'
	let nhead = 'nnoremenu <silent> '.s:Lua_RootMenu.'.Regex.'
	let ihead = 'inoremenu <silent> '.s:Lua_RootMenu.'.Regex.'
	"
	exe ahead.'-Sep01-                                  :'
	exe nhead.'&esc\.\ magic\ char\.<Tab>'.esc_mapl.'xe  i<C-R>=<SID>EscMagicChar()<CR><ESC><Right>'
	exe ihead.'&esc\.\ magic\ char\.<Tab>'.esc_mapl.'xe   <C-R>=<SID>EscMagicChar()<CR>'
	"
	"-------------------------------------------------------------------------------
	" snippets
	"-------------------------------------------------------------------------------

	let ahead = 'anoremenu <silent> '.s:Lua_RootMenu.'.Snippets.'
	let vhead = 'vnoremenu <silent> '.s:Lua_RootMenu.'.Snippets.'
	let ihead = 'inoremenu <silent> '.s:Lua_RootMenu.'.Snippets.'

	exe ahead.'&insert\ code\ snippet<Tab>'.esc_mapl.'ni       :call <SID>CodeSnippet("insert")<CR>'
	exe ihead.'&insert\ code\ snippet<Tab>'.esc_mapl.'ni  <C-C>:call <SID>CodeSnippet("insert")<CR>'
	exe ahead.'&create\ code\ snippet<Tab>'.esc_mapl.'nc       :call <SID>CodeSnippet("create")<CR>'
	exe vhead.'&create\ code\ snippet<Tab>'.esc_mapl.'nc  <C-C>:call <SID>CodeSnippet("vcreate")<CR>'
	exe ihead.'&create\ code\ snippet<Tab>'.esc_mapl.'nc  <C-C>:call <SID>CodeSnippet("create")<CR>'
	exe ahead.'&view\ code\ snippet<Tab>'.esc_mapl.'nv         :call <SID>CodeSnippet("view")<CR>'
	exe ihead.'&view\ code\ snippet<Tab>'.esc_mapl.'nv    <C-C>:call <SID>CodeSnippet("view")<CR>'
	exe ahead.'&edit\ code\ snippet<Tab>'.esc_mapl.'ne         :call <SID>CodeSnippet("edit")<CR>'
	exe ihead.'&edit\ code\ snippet<Tab>'.esc_mapl.'ne    <C-C>:call <SID>CodeSnippet("edit")<CR>'
	exe ahead.'-Sep01-                                         :'

	" templates: edit and reload templates, styles
	call mmtemplates#core#CreateMenus ( 'g:Lua_Templates', s:Lua_RootMenu, 'do_specials',
				\ 'specials_menu', 'Snippets'	)
	"
	"-------------------------------------------------------------------------------
	" run
	"-------------------------------------------------------------------------------

	let ahead = 'anoremenu <silent> '.s:Lua_RootMenu.'.Run.'
	let vhead = 'vnoremenu <silent> '.s:Lua_RootMenu.'.Run.'
	let ihead = 'inoremenu <silent> '.s:Lua_RootMenu.'.Run.'
	let ahead_loud = 'anoremenu     '.s:Lua_RootMenu.'.Run.'
	let ihead_loud = 'inoremenu     '.s:Lua_RootMenu.'.Run.'

	exe ahead.'&run<TAB>'.esc_mapl.'rr                       :call <SID>Run("")<CR>'
	exe ihead.'&run<TAB>'.esc_mapl.'rr                  <Esc>:call <SID>Run("")<CR>'
	exe ahead.'&compile<TAB>'.esc_mapl.'rc                   :call <SID>Compile("compile")<CR>'
	exe ihead.'&compile<TAB>'.esc_mapl.'rc              <Esc>:call <SID>Compile("compile")<CR>'
	exe ahead.'chec&k\ code<TAB>'.esc_mapl.'rk               :call <SID>Compile("check")<CR>'
	exe ihead.'chec&k\ code<TAB>'.esc_mapl.'rk          <Esc>:call <SID>Compile("check")<CR>'

	exe ahead.'&buffer\ "Lua\ Output\/Term".buffer\ "Lua\ Output\/Term"  :echo "This is a menu header."<CR>'
	exe ahead.'&buffer\ "Lua\ Output\/Term".-SepHead-              :'
	exe ahead.'&buffer\ "Lua\ Output\/Term".load\ into\ quick&fix<TAB>'.esc_mapl.'qf                    :call <SID>OutputBufferErrors(0)<CR>'
	exe ihead.'&buffer\ "Lua\ Output\/Term".load\ into\ quick&fix<TAB>'.esc_mapl.'qf               <Esc>:call <SID>OutputBufferErrors(0)<CR>'
	exe ahead.'&buffer\ "Lua\ Output\/Term".qf\.\ and\ &jump\ to\ first\ error<TAB>'.esc_mapl.'qj       :call <SID>OutputBufferErrors(1)<CR>'
	exe ihead.'&buffer\ "Lua\ Output\/Term".qf\.\ and\ &jump\ to\ first\ error<TAB>'.esc_mapl.'qj  <Esc>:call <SID>OutputBufferErrors(1)<CR>'

	exe ahead.'-Sep01-                                   :'

	" create a dummy menu header for the "output method" sub-menu
	exe ahead.'&output\ method<TAB>'.esc_mapl.'ro.Output\ Method   :'
	exe ahead.'&output\ method<TAB>'.esc_mapl.'ro.-SepHead-        :'
	" create a dummy menu header for the "direct run" sub-menu
	exe ahead.'&direct\ run<TAB>'.esc_mapl.'rd.Direct\ Run   :'
	exe ahead.'&direct\ run<TAB>'.esc_mapl.'rd.-SepHead-     :'

	exe ahead_loud.'&set\ executable<TAB>'.esc_mapl.'rse                :LuaExecutable<SPACE>'
	exe ihead_loud.'&set\ executable<TAB>'.esc_mapl.'rse           <Esc>:LuaExecutable<SPACE>'
	exe ahead_loud.'&set\ compiler\ exec\.<TAB>'.esc_mapl.'rsc          :LuaCompilerExec<SPACE>'
	exe ihead_loud.'&set\ compiler\ exec\.<TAB>'.esc_mapl.'rsc     <Esc>:LuaCompilerExec<SPACE>'
	exe ahead.'-Sep02-                                             :'

	exe ahead.'make\ &executable<TAB>'.esc_mapl.'re                :call <SID>MakeExecutable()<CR>'
	exe ihead.'make\ &executable<TAB>'.esc_mapl.'re           <Esc>:call <SID>MakeExecutable()<CR>'
	exe ahead.'&hardcopy\ to\ filename\.ps<TAB>'.esc_mapl.'rh      :call <SID>Hardcopy("n")<CR>'
	exe vhead.'&hardcopy\ to\ filename\.ps<TAB>'.esc_mapl.'rh <C-C>:call <SID>Hardcopy("v")<CR>'
	exe ihead.'&hardcopy\ to\ filename\.ps<TAB>'.esc_mapl.'rh <C-C>:call <SID>Hardcopy("n")<CR>'
	exe ahead.'-Sep03-                                             :'

	exe ahead.'&settings<TAB>'.esc_mapl.'rs       :call Lua_Settings(0)<CR>'
	exe ihead.'&settings<TAB>'.esc_mapl.'rs  <Esc>:call Lua_Settings(0)<CR>'

	" run -> output method
	let method_menu_entries = [
				\ [ 'cmd-line', '&cmd\.-line', 'interactive', ],
				\ [ 'quickfix', '&quickfix',   'quickfix',    ],
				\ [ 'buffer',   '&buffer',     'quickfix',    ],
				\ [ 'terminal', '&terminal',   'interact+qf', ],
				\ [ 'xterm',    '&xterm',      'interactive', ],
				\ ]

	for [ method, left, right ] in method_menu_entries
		if index ( s:Lua_OutputMethodList, method ) > -1
			exe ahead.'output\ method.'.left.'<TAB>'.right.'       :call <SID>SetOutputMethod("'.method.'")<CR>'
			exe ihead.'output\ method.'.left.'<TAB>'.right.'  <Esc>:call <SID>SetOutputMethod("'.method.'")<CR>'
		endif
	endfor

	" run -> direct run
	exe ahead.'direct\ run.&yes<TAB>use\ executable\ scripts         :call <SID>SetDirectRun("yes")<CR>'
	exe ihead.'direct\ run.&yes<TAB>use\ executable\ scripts    <Esc>:call <SID>SetDirectRun("yes")<CR>'
	exe ahead.'direct\ run.&no<TAB>always\ use\ :LuaExecutable       :call <SID>SetDirectRun("no")<CR>'
	exe ihead.'direct\ run.&no<TAB>always\ use\ :LuaExecutable  <Esc>:call <SID>SetDirectRun("no")<CR>'

	" deletes the dummy menu header and displays the current options
	" in the menu header of the sub-menus
	call s:SetOutputMethod ( s:Lua_OutputMethod )
	call s:SetDirectRun ( s:Lua_DirectRun )

	"-------------------------------------------------------------------------------
	" tool box
	"-------------------------------------------------------------------------------

	if s:Lua_UseToolbox == 'yes' && mmtoolbox#tools#Property ( s:Lua_Toolbox, 'empty-menu' ) == 0
		call mmtoolbox#tools#AddMenus ( s:Lua_Toolbox, s:Lua_RootMenu.'.&Tool\ Box' )
	endif

	"-------------------------------------------------------------------------------
	" help
	"-------------------------------------------------------------------------------

	let ahead = 'anoremenu <silent> '.s:Lua_RootMenu.'.Help.'
	let ihead = 'inoremenu <silent> '.s:Lua_RootMenu.'.Help.'

	exe ahead.'-Sep01-                                       :'
	exe ahead.'&help\ (Lua-Support)<TAB>'.esc_mapl.'hs       :call <SID>HelpPlugin()<CR>'
	exe ihead.'&help\ (Lua-Support)<TAB>'.esc_mapl.'hs  <Esc>:call <SID>HelpPlugin()<CR>'

endfunction    " ----------  end of function s:InitMenus  ----------
"
"-------------------------------------------------------------------------------
" s:ToolMenu : Add or remove tool menu entries.   {{{1
"-------------------------------------------------------------------------------
"
function! s:ToolMenu( action )
	"
	if ! has ( 'menu' )
		return
	endif
	"
	if a:action == 'setup'
		anoremenu <silent> 40.1000 &Tools.-SEP100- :
		anoremenu <silent> 40.1122 &Tools.Load\ Lua\ Support   :call <SID>AddMenus()<CR>
	elseif a:action == 'load'
		aunmenu   <silent> &Tools.Load\ Lua\ Support
		anoremenu <silent> 40.1122 &Tools.Unload\ Lua\ Support :call <SID>RemoveMenus()<CR>
	elseif a:action == 'unload'
		aunmenu   <silent> &Tools.Unload\ Lua\ Support
		anoremenu <silent> 40.1122 &Tools.Load\ Lua\ Support   :call <SID>AddMenus()<CR>
		exe 'aunmenu <silent> '.s:Lua_RootMenu
	endif
	"
endfunction    " ----------  end of function s:ToolMenu  ----------
"
"-------------------------------------------------------------------------------
" s:AddMenus : Add menus.   {{{1
"-------------------------------------------------------------------------------
"
function! s:AddMenus()
	if s:MenuVisible == 0
		" the menu is becoming visible
		let s:MenuVisible = 2
		" make sure the templates are loaded
		call s:SetupTemplates ()
		" initialize if not existing
		call s:ToolMenu ( 'load' )
		call s:InitMenus ()
		" the menu is now visible
		let s:MenuVisible = 1
	endif
endfunction    " ----------  end of function s:AddMenus  ----------
"
"-------------------------------------------------------------------------------
" s:RemoveMenus : Remove menus.   {{{1
"-------------------------------------------------------------------------------
"
function! s:RemoveMenus()
	if s:MenuVisible == 1
		" destroy if visible
		call s:ToolMenu ( 'unload' )
		" the menu is now invisible
		let s:MenuVisible = 0
	endif
endfunction    " ----------  end of function s:RemoveMenus  ----------

"-------------------------------------------------------------------------------
" s:Initialize : Initialize templates, menus, and maps.   {{{1
"-------------------------------------------------------------------------------
function! s:Initialize ( ftype )
	if ! exists( 'g:Lua_Templates' )
		if s:Lua_LoadMenus == 'auto' | call s:AddMenus()
		else                         | call s:SetupTemplates()
		endif
	endif
	call s:CreateMaps()
	call s:CheckTemplatePersonalization()
endfunction    " ----------  end of function s:Initialize  ----------

"-------------------------------------------------------------------------------
" Lua_Settings : Print the settings on the command line.   {{{1
"-------------------------------------------------------------------------------
"
function! Lua_Settings( verbose )

	if     s:MSWIN | let sys_name = 'Windows'
	elseif s:UNIX  | let sys_name = 'UN*X'
	else           | let sys_name = 'unknown' | endif
	if s:NEOVIM
		let vim_name = 'nvim'
	else
		let vim_name = has('gui_running') ? 'gvim' : 'vim'
		if s:VIM8
			let vim_name .= '(v8.0)'
		endif
	endif

	let lua_exe_status = executable( s:Lua_Executable ) ? '' : ' (not executable)'
	let luac_exe_status = executable( s:Lua_CompilerExec ) ? '' : ' (not executable)'
	"
	let	txt = " Lua-Support settings\n\n"
	" template settings: macros, style, ...
	if exists ( 'g:Lua_Templates' )
		let [ templ_style, msg ] = mmtemplates#core#Resource( g:Lua_Templates, 'style' )
		"
		let txt .=
					\  '                   author :  "'.mmtemplates#core#ExpandText( g:Lua_Templates, '|AUTHOR|'       )."\"\n"
					\ .'                authorref :  "'.mmtemplates#core#ExpandText( g:Lua_Templates, '|AUTHORREF|'    )."\"\n"
					\ .'                    email :  "'.mmtemplates#core#ExpandText( g:Lua_Templates, '|EMAIL|'        )."\"\n"
					\ .'             organization :  "'.mmtemplates#core#ExpandText( g:Lua_Templates, '|ORGANIZATION|' )."\"\n"
					\ .'         copyright holder :  "'.mmtemplates#core#ExpandText( g:Lua_Templates, '|COPYRIGHT|'    )."\"\n"
					\ .'                  licence :  "'.mmtemplates#core#ExpandText( g:Lua_Templates, '|LICENSE|'      )."\"\n"
					\ .'           template style :  "'.templ_style."\"\n"
					\ ."\n"
	else
		let txt .=
					\  "                templates :  -not loaded-\n"
					\ ."\n"
	endif
	" plug-in installation, template engine
	let txt .=
				\  '      plugin installation :  '.s:installation.' in '.vim_name.' on '.sys_name."\n"
	" toolbox
	if s:Lua_UseToolbox == 'yes'
		let toollist = mmtoolbox#tools#GetList ( s:Lua_Toolbox )
		if empty ( toollist )
			let txt .= "            using toolbox :  -no tools-\n"
		else
			let sep  = "\n"."                             "
			let txt .=      "            using toolbox :  "
						\ .join ( toollist, sep )."\n"
		endif
	endif
	let txt .= "\n"
	" templates, snippets
	if exists ( 'g:Lua_Templates' )
		let [ templist, msg ] = mmtemplates#core#Resource ( g:Lua_Templates, 'template_list' )
		let sep  = "\n"."                             "
		let txt .=      "           template files :  "
					\ .join ( templist, sep )."\n"
	else
		let txt .= "           template files :  -not loaded-\n"
	endif
	let txt .=
				\  '       code snippets dir. :  '.s:Lua_SnippetDir."\n"
	if a:verbose >= 1
		let	txt .= "\n"
					\ .'                mapleader :  "'.g:Lua_MapLeader."\"\n"
					\ .'               load menus :  "'.s:Lua_LoadMenus."\"\n"
					\ .'       insert file header :  "'.g:Lua_InsertFileHeader."\"\n"
	endif
	let txt .= "\n"
	let txt .=
				\  '        lua (interpreter) :  '.s:Lua_Executable.lua_exe_status."\n"
				\ .'          luac (compiler) :  '.s:Lua_CompilerExec.luac_exe_status."\n"
	" various settings, maps, menus, running, compiling, ...
	if a:verbose >= 1
		let	txt .=
					\  '       compiled extension :  "'.g:Lua_CompiledExtension."\"\n"
					\ .'            output method :  "'.s:Lua_OutputMethod."\"\n"
					\ .'               direct run :  "'.s:Lua_DirectRun."\"\n"
	endif
	" xterm (UNIX only)
	if s:UNIX && a:verbose >= 1
		let	txt .=
					\  '         xterm executable :  "'.s:Xterm_Executable."\"\n"
					\ .'            xterm options :  "'.g:Xterm_Options."\"\n"
	endif
	let txt .=
				\  "________________________________________________________________________________\n"
				\ ." Lua-Support, Version ".g:Lua_Version." / Wolfgang Mehner / wolfgang-mehner@web.de\n\n"
	"
	if a:verbose == 2
		split LuaSupport_Settings.txt
		put = txt
	else
		echo txt
	endif
endfunction    " ----------  end of function Lua_Settings  ----------
"
"-------------------------------------------------------------------------------
" === Setup: Templates, toolbox and menus ===   {{{1
"-------------------------------------------------------------------------------
"
" setup the toolbox
"
if s:Lua_UseToolbox == 'yes'
	"
	let s:Lua_Toolbox = mmtoolbox#tools#NewToolbox ( 'Lua' )
	call mmtoolbox#tools#Property ( s:Lua_Toolbox, 'mapleader', g:Lua_MapLeader )
	"
	call mmtoolbox#tools#Load ( s:Lua_Toolbox, s:Lua_ToolboxDir )
	"
	" debugging only:
	"call mmtoolbox#tools#Info ( s:Lua_Toolbox )
	"
endif
"
" tool menu entry
call s:ToolMenu ( 'setup' )
"
" load the menu right now?
if s:Lua_LoadMenus == 'startup'
	call s:AddMenus ()
endif
"
" user defined commands (working everywhere)
command! -nargs=? -complete=custom,<SID>GetOutputMethodList LuaOutputMethod   call <SID>SetOutputMethod(<q-args>)
command! -nargs=? -complete=custom,<SID>GetDirectRunList    LuaDirectRun      call <SID>SetDirectRun(<q-args>)
command! -nargs=? -complete=shellcmd                        LuaExecutable     call <SID>SetExecutable('exe',<q-args>)
command! -nargs=? -complete=shellcmd                        LuaCompilerExec   call <SID>SetExecutable('compile',<q-args>)

if has( 'autocmd' )
	augroup LuaSupport
	autocmd FileType   lua    call s:Initialize('lua')
	autocmd BufNewFile *.lua  call s:InsertFileHeader()
	augroup END
endif
" }}}1
"-------------------------------------------------------------------------------

" =====================================================================================
"  vim: foldmethod=marker
