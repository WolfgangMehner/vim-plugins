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
"      Revision:  ---
"       License:  Copyright (c) 2012-2014, Wolfgang Mehner
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
	echo 'The plugin lua-support.vim needs Vim version >= 7.'
	echohl None
	finish
endif
"
" prevent duplicate loading
" need compatible
if &cp || ( exists('g:Lua_Version') && ! exists('g:Lua_DevelopmentOverwrite') )
	finish
endif
let g:Lua_Version= '0.8beta'     " version number of this script; do not change
"
"-------------------------------------------------------------------------------
" Auxiliary functions.   {{{1
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
"
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
"
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
"
function! s:ImportantMsg ( ... )
	echohl Search
	echo join ( a:000, "\n" )
	echohl None
endfunction    " ----------  end of function s:ImportantMsg  ----------
" }}}2
"-------------------------------------------------------------------------------
"
"-------------------------------------------------------------------------------
" Modul setup.   {{{1
"-------------------------------------------------------------------------------
"
"-------------------------------------------------------------------------------
" Installation.   {{{2
"-------------------------------------------------------------------------------
"
let s:MSWIN = has("win16") || has("win32")   || has("win64")    || has("win95")
let s:UNIX	= has("unix")  || has("macunix") || has("win32unix")
"
let s:installation        = '*undefined*'      " 'local' or 'system'
let s:plugin_dir          = ''                 " the directory hosting ftplugin/ plugin/ lua-support/ ...
let s:Lua_GlbTemplateFile = ''                 " the global templates, undefined for s:installation == 'local'
let s:Lua_LclTemplateFile = ''                 " the local templates
"
if s:MSWIN
	"
	"-------------------------------------------------------------------------------
	" MS Windows
	"-------------------------------------------------------------------------------
	"
	if match(      substitute( expand('<sfile>'), '\\', '/', 'g' ),
				\   '\V'.substitute( expand('$HOME'),   '\\', '/', 'g' ) ) == 0
		"
		" user installation assumed
		let s:installation        = 'local'
		let s:plugin_dir          = substitute( expand('<sfile>:p:h:h'), '\\', '/', 'g' )
		let s:Lua_LclTemplateDir  = s:plugin_dir.'/lua-support/templates'
		let s:Lua_LclTemplateFile = s:Lua_LclTemplateDir.'/Templates'
	else
		"
		" system wide installation
		let s:installation        = 'system'
		let s:plugin_dir          = $VIM.'/vimfiles'
		let s:Lua_GlbTemplateDir  = s:plugin_dir.'/lua-support/templates'
		let s:Lua_LclTemplateDir  = $HOME.'/vimfiles/lua-support/templates'
		let s:Lua_GlbTemplateFile = s:Lua_GlbTemplateDir.'/Templates'
		let s:Lua_LclTemplateFile = s:Lua_LclTemplateDir.'/Templates'
	endif
	"
else
	"
	"-------------------------------------------------------------------------------
	" Linux/Unix
	"-------------------------------------------------------------------------------
	"
	if match( expand('<sfile>'), '\V'.resolve(expand('$HOME')) ) == 0
		"
		" user installation assumed
		let s:installation        = 'local'
		let s:plugin_dir          = expand('<sfile>:p:h:h')
		let s:Lua_LclTemplateDir  = s:plugin_dir.'/lua-support/templates'
		let s:Lua_LclTemplateFile = s:Lua_LclTemplateDir.'/Templates'
	else
		"
		" system wide installation
		let s:installation        = 'system'
		let s:plugin_dir          = $VIM.'/vimfiles'
		let s:Lua_GlbTemplateDir  = s:plugin_dir.'/lua-support/templates'
		let s:Lua_LclTemplateDir  = $HOME.'/.vim/lua-support/templates'
		let s:Lua_GlbTemplateFile = s:Lua_GlbTemplateDir.'/Templates'
		let s:Lua_LclTemplateFile = s:Lua_LclTemplateDir.'/Templates'
	endif
	"
endif
"
"-------------------------------------------------------------------------------
" Various setting.   {{{2
"-------------------------------------------------------------------------------
"
let s:CmdLineEscChar = ' |"\'
"
let s:Lua_LoadMenus             = 'auto'       " load the menus?
let s:Lua_RootMenu              = '&Lua'       " name of the root menu
"
let s:Lua_Executable            = 'lua'        " default: lua on system path
let s:Lua_CompilerExec          = 'luac'       " default: luac on system path
"
let s:Lua_LineEndCommColDefault = 49
let s:Lua_SnippetDir            = s:plugin_dir.'/lua-support/codesnippets/'
let s:Lua_SnippetBrowser        = 'gui'
"
if ! exists ( 's:MenuVisible' )
	let s:MenuVisible = 0                        " menus are not visible at the moment
endif
"
call s:GetGlobalSetting ( 'Lua_GlbTemplateFile' )
call s:GetGlobalSetting ( 'Lua_LclTemplateFile' )
call s:GetGlobalSetting ( 'Lua_LoadMenus' )
call s:GetGlobalSetting ( 'Lua_RootMenu' )
call s:GetGlobalSetting ( 'Lua_Executable' )
call s:GetGlobalSetting ( 'Lua_CompilerExec' )
call s:GetGlobalSetting ( 'Lua_LineEndCommColDefault' )
call s:GetGlobalSetting ( 'Lua_SnippetDir' )
call s:GetGlobalSetting ( 'Lua_SnippetBrowser' )
"
call s:ApplyDefaultSetting ( 'Lua_CompiledExtension', 'luac' )         " default: 'luac'
call s:ApplyDefaultSetting ( 'Lua_InsertFileHeader', 'yes' )           " default: do insert a file header
call s:ApplyDefaultSetting ( 'Lua_MapLeader', '' )                     " default: do not overwrite 'maplocalleader'
"
let s:Lua_GlbTemplateFile = expand ( s:Lua_GlbTemplateFile )
let s:Lua_LclTemplateFile = expand ( s:Lua_LclTemplateFile )
let s:Lua_SnippetDir      = expand ( s:Lua_SnippetDir )
"
" }}}2
"-------------------------------------------------------------------------------
"
"-------------------------------------------------------------------------------
" Lua_EndOfLineComment : Append end-of-line comment.   {{{1
"-------------------------------------------------------------------------------
"
function! Lua_EndOfLineComment () range
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
endfunction    " ----------  end of function Lua_EndOfLineComment  ----------
"
"-------------------------------------------------------------------------------
" Lua_AdjustEndOfLineComm : Adjust end-of-line comment.   {{{1
"-------------------------------------------------------------------------------
"
function! Lua_AdjustEndOfLineComm () range
	"
	" comment character (for use in regular expression)
	let cc = '%'
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
	"
endfunction    " ----------  end of function Lua_AdjustEndOfLineComm  ----------
"
"-------------------------------------------------------------------------------
" Lua_SetEndOfLineCommPos : Set end-of-line comment position.   {{{1
"-------------------------------------------------------------------------------
"
function! Lua_SetEndOfLineCommPos () range
	"
	let b:Lua_LineEndCommentColumn = virtcol('.')
	call s:ImportantMsg ( 'line end comments will start at column '.b:Lua_LineEndCommentColumn )
	"
endfunction    " ----------  end of function Lua_SetEndOfLineCommPos  ----------
"
"-------------------------------------------------------------------------------
" Lua_CodeComment : Code -> Comment   {{{1
"-------------------------------------------------------------------------------
"
function! Lua_CodeComment() range
	"
	" add '%' at the beginning of the lines
	silent exe ":".a:firstline.",".a:lastline."s/^/--/"
	"
endfunction    " ----------  end of function Lua_CodeComment  ----------
"
"-------------------------------------------------------------------------------
" Lua_CommentCode : Comment -> Code   {{{1
"-------------------------------------------------------------------------------
"
function! Lua_CommentCode( toggle ) range
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
endfunction    " ----------  end of function Lua_CommentCode  ----------
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
" Lua_FunctionComment : Automatically comment a function.   {{{1
"-------------------------------------------------------------------------------
"
function! Lua_FunctionComment() range
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
endfunction    " ----------  end of function Lua_FunctionComment  ----------
"
"-------------------------------------------------------------------------------
" Lua_EscSpecChar : Automatically comment a function.   {{{1
"-------------------------------------------------------------------------------
"
function! Lua_EscSpecChar()
	"
	let col  = getpos('.')[2]
	let char = getline('.')[col-1]
	"
	if char =~ '\V\[$^()%.[\]*+-?]'
		return '%'
	endif
	"
	return ''
endfunction    " ----------  end of function Lua_EscSpecChar  ----------
"
"-------------------------------------------------------------------------------
" Lua_CodeSnippet : Code snippets.   {{{1
"
" Parameters:
"   action - "insert", "create", "vcreate", "view" or "edit" (string)
"-------------------------------------------------------------------------------
"
function! Lua_CodeSnippet ( action )
	"
	"-------------------------------------------------------------------------------
	" setup
	"-------------------------------------------------------------------------------
	"
	" check directory
	if ! isdirectory( s:Lua_SnippetDir )
		return s:ErrorMsg (
					\ 'Code snippet directory '.s:Lua_SnippetDir.' does not exist.',
					\ '(Please create it.)' )
	endif
	"
	" save option 'browsefilter'
	if has( 'browsefilter' ) && exists( 'b:browsefilter' )
		let browsefilter_save = b:browsefilter
		let b:browsefilter    = '*'
	endif
	"
	"-------------------------------------------------------------------------------
	" do action
	"-------------------------------------------------------------------------------
	"
	if a:action == 'insert'
		"
		"-------------------------------------------------------------------------------
		" action "insert"
		"-------------------------------------------------------------------------------
		"
		" select file
		if has('browse') && s:Lua_SnippetBrowser == 'gui'
			let snippetfile = browse ( 0, 'insert a code snippet', s:Lua_SnippetDir, '' )
		else
			let snippetfile = input ( 'insert snippet ', s:Lua_SnippetDir, 'file' )
		endif
		"
		" insert snippet
		if filereadable(snippetfile)
			let linesread = line('$')
			"
			let old_cpoptions = &cpoptions            " prevent the alternate buffer from being set to this files
			setlocal cpoptions-=a
			"
			exe 'read '.snippetfile
			"
			let &cpoptions = old_cpoptions            " restore previous options
			"
			let linesread = line('$') - linesread - 1 " number of lines inserted
			"
			" :TODO:03.12.2013 14:29:WM: indent here?
			" indent lines
			if linesread >= 0 && match( snippetfile, '\.\(ni\|noindent\)$' ) < 0
				silent exe 'normal! ='.linesread.'+'
			endif
		endif
		"
		" delete first line if empty
		if line('.') == 2 && getline(1) =~ '^$'
			silent exe ':1,1d'
		endif
		"
	elseif a:action == 'create' || a:action == 'vcreate'
		"
		"-------------------------------------------------------------------------------
		" action "create" or "vcreate"
		"-------------------------------------------------------------------------------
		"
		" select file
		if has('browse') && s:Lua_SnippetBrowser == 'gui'
			let snippetfile = browse ( 1, 'create a code snippet', s:Lua_SnippetDir, '' )
		else
			let snippetfile = input ( 'create snippet ', s:Lua_SnippetDir, 'file' )
		endif
		"
		" create snippet
		if ! empty( snippetfile )
			" new file or overwrite?
			if ! filereadable( snippetfile ) || confirm( 'File '.snippetfile.' exists! Overwrite? ', "&Cancel\n&No\n&Yes" ) == 3
				if a:action == 'create' && confirm( 'Write whole file as a snippet? ', "&Cancel\n&No\n&Yes" ) == 3
					exe 'write! '.fnameescape( snippetfile )
				elseif a:action == 'vcreate'
					exe '*write! '.fnameescape( snippetfile )
				endif
			endif
		endif
		"
	elseif a:action == 'view' || a:action == 'edit'
		"
		"-------------------------------------------------------------------------------
		" action "view" or "edit"
		"-------------------------------------------------------------------------------
		if a:action == 'view' | let saving = 0
		else                  | let saving = 1 | endif
		"
		" select file
		if has('browse') && s:Lua_SnippetBrowser == 'gui'
			let snippetfile = browse ( saving, a:action.' a code snippet', s:Lua_SnippetDir, '' )
		else
			let snippetfile = input ( a:action.' snippet ', s:Lua_SnippetDir, 'file' )
		endif
		"
		" open file
		if ! empty( snippetfile )
			exe 'split | '.a:action.' '.fnameescape( snippetfile )
		endif
	else
		call s:ErrorMsg ( 'Unknown action "'.a:action.'".' )
	endif
	"
	"-------------------------------------------------------------------------------
	" wrap up
	"-------------------------------------------------------------------------------
	"
	" restore option 'browsefilter'
	if has( 'browsefilter' ) && exists( 'b:browsefilter' )
		let b:browsefilter = browsefilter_save
	endif
	"
endfunction    " ----------  end of function Lua_CodeSnippet  ----------
"
"-------------------------------------------------------------------------------
" Lua_Run : Run the current buffer.   {{{1
"
" Parameters:
"   args - command-line arguments (string)
"-------------------------------------------------------------------------------
"
function! Lua_Run ( args )
	"
	silent exe 'update'   | " write source file if necessary
	"
	let output = system ( shellescape( s:Lua_Executable ).' '.shellescape( bufname('%') ).' '.a:args )
	"
	echo output
	"
endfunction    " ----------  end of function Lua_Run  ----------
"
"-------------------------------------------------------------------------------
" Lua_Compile : Compile or check the code.   {{{1
"
" Parameters:
"   mode - "compile" or "check" (string)
"-------------------------------------------------------------------------------
function! Lua_Compile( mode ) range
	"
	silent exe 'update'   | " write source file if necessary
	cclose
	"
	" prepare and check the executable
	" :TODO:26.03.2014 20:54:WM: name of the help page
	if ! executable( s:Lua_CompilerExec )
		return s:ErrorMsg (
					\ 'Command "'.s:Lua_CompilerExec.'" not found. Not configured correctly?',
					\ 'Further information: :help luasupport-config-TODO' )
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
	let &l:makeprg = shellescape( s:Lua_CompilerExec )
	let &l:errorformat = substitute( s:Lua_CompilerExec, '%\\%\\', '%\', 'g' ).': %f:%l: %m,'.substitute( s:Lua_CompilerExec, '%\\%\\', '%\', 'g' ).': %m'
	"
	let v:statusmsg = ''                               " reset, so we are able to check it below
	silent exe 'make '.switch.' '.shellescape( bufname('%') )
	"
	" restore current settings
	let &l:makeprg = makeprg_saved
	let &l:errorformat = errorf_saved
	"
	" any errors?
	if a:mode == 'compile' && empty ( v:statusmsg )
		call s:ImportantMsg ( 'Compiled successfully.' )
	elseif a:mode == 'check' && empty ( v:statusmsg )
		call s:ImportantMsg ( 'No warnings.' )
	else
		botright cwindow
		cc
	endif
	"
endfunction    " ----------  end of function Lua_Compile  ----------
"
"------------------------------------------------------------------------------
"  === Templates API ===   {{{1
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
	let g:Lua_Templates = mmtemplates#core#NewLibrary ()
	"
	" mapleader
	if empty ( g:Lua_MapLeader )
		call mmtemplates#core#Resource ( g:Lua_Templates, 'set', 'property', 'Templates::Mapleader', '\' )
	else
		call mmtemplates#core#Resource ( g:Lua_Templates, 'set', 'property', 'Templates::Mapleader', g:Lua_MapLeader )
	endif
	"
	" map: choose style
	call mmtemplates#core#Resource ( g:Lua_Templates, 'set', 'property', 'Templates::ChooseStyle::Map', 'nts' )
	"
	" syntax: comments
	call mmtemplates#core#ChangeSyntax ( g:Lua_Templates, 'comment', '§' )
	"
	"-------------------------------------------------------------------------------
	" load template library
	"-------------------------------------------------------------------------------
	if s:installation == 'system'
		"-------------------------------------------------------------------------------
		" system installation
		"-------------------------------------------------------------------------------
		"
		" global templates
		if filereadable( s:Lua_GlbTemplateFile )
			call mmtemplates#core#ReadTemplates ( g:Lua_Templates, 'load', s:Lua_GlbTemplateFile )
		else
			return s:ErrorMsg ( 'Global template file "'.s:Lua_GlbTemplateFile.'" not readable.' )
		endif
		"
		let local_dir = fnamemodify ( s:Lua_LclTemplateFile, ':p:h' )
		"
		if ! isdirectory( local_dir ) && exists('*mkdir')
			try
				call mkdir ( local_dir, 'p' )
			catch /.*/
			endtry
		endif
		"
		if isdirectory( local_dir ) && ! filereadable( s:Lua_LclTemplateFile )
			let sample_template_file	= fnamemodify ( s:Lua_GlbTemplateFile, ':p:h:h' ).'/rc/sample_template_file'
			if filereadable( sample_template_file )
				call writefile ( readfile ( sample_template_file ), s:Lua_LclTemplateFile )
			endif
		endif
		"
		" local templates
		if filereadable( s:Lua_LclTemplateFile )
			call mmtemplates#core#ReadTemplates ( g:Lua_Templates, 'load', s:Lua_LclTemplateFile )
			if mmtemplates#core#ExpandText ( g:Lua_Templates, '|AUTHOR|' ) == 'YOUR NAME'
				call s:ErrorMsg ( 'Please set your personal details in the file "'.s:Lua_LclTemplateFile.'".' )
			endif
		endif
		"
	elseif s:installation == 'local'
		"-------------------------------------------------------------------------------
		" local installation
		"-------------------------------------------------------------------------------
		"
		" local templates
		if filereadable ( s:Lua_LclTemplateFile )
			call mmtemplates#core#ReadTemplates ( g:Lua_Templates, 'load', s:Lua_LclTemplateFile )
		else
			return s:ErrorMsg ( 'Local template file "'.s:Lua_LclTemplateFile.'" not readable.' )
		endif
	endif
endfunction    " ----------  end of function s:SetupTemplates  ----------
"
"-------------------------------------------------------------------------------
" s:InsertFileHeader : Insert a header for a new file.   {{{1
"-------------------------------------------------------------------------------
"
function! s:InsertFileHeader ()
	"
	if ! exists ( 'g:Lua_Templates' )
		return
	endif
	"
	if g:Lua_InsertFileHeader == 'yes'
		call mmtemplates#core#InsertTemplate ( g:Lua_Templates, 'Comments.file description' )
	endif
	"
endfunction    " ----------  end of function s:InsertFileHeader  ----------
"
"-------------------------------------------------------------------------------
" Lua_HelpPlugin : Plug-in help.   {{{1
"-------------------------------------------------------------------------------
"
function! Lua_HelpPlugin ()
	try
		help lua-support
	catch
		exe 'helptags '.s:plugin_dir.'/doc'
		help lua-support
	endtry
endfunction    " ----------  end of function Lua_HelpPlugin  ----------
"
"-------------------------------------------------------------------------------
" s:CreateMaps : Create additional maps.   {{{1
"-------------------------------------------------------------------------------
"
function! s:CreateMaps ()
	"
	"-------------------------------------------------------------------------------
	" user defined commands
	"-------------------------------------------------------------------------------
	"
  command! -nargs=* -complete=file Lua          call Lua_Run(<q-args>)
  command! -nargs=* -complete=file LuaCompile   call Lua_Compile('compile')
  command! -nargs=* -complete=file LuaCheck     call Lua_Compile('check')
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
	 noremap    <buffer>  <silent>  <LocalLeader>cl         :call Lua_EndOfLineComment()<CR>
	inoremap    <buffer>  <silent>  <LocalLeader>cl    <Esc>:call Lua_EndOfLineComment()<CR>
	 noremap    <buffer>  <silent>  <LocalLeader>cj         :call Lua_AdjustEndOfLineComm()<CR>
	inoremap    <buffer>  <silent>  <LocalLeader>cj    <Esc>:call Lua_AdjustEndOfLineComm()<CR>
	 noremap    <buffer>  <silent>  <LocalLeader>cs         :call Lua_SetEndOfLineCommPos()<CR>
	inoremap    <buffer>  <silent>  <LocalLeader>cs    <Esc>:call Lua_SetEndOfLineCommPos()<CR>
	"
	 noremap    <buffer>  <silent>  <LocalLeader>cc         :call Lua_CodeComment()<CR>
	inoremap    <buffer>  <silent>  <LocalLeader>cc    <Esc>:call Lua_CodeComment()<CR>
	 noremap    <buffer>  <silent>  <LocalLeader>co         :call Lua_CommentCode(0)<CR>
	inoremap    <buffer>  <silent>  <LocalLeader>co    <Esc>:call Lua_CommentCode(0)<CR>
	 noremap    <buffer>  <silent>  <LocalLeader>ct         :call Lua_CommentCode(1)<CR>
	inoremap    <buffer>  <silent>  <LocalLeader>ct    <Esc>:call Lua_CommentCode(1)<CR>
	"
	 noremap    <buffer>  <silent>  <LocalLeader>ca         :call Lua_FunctionComment()<CR>
	inoremap    <buffer>  <silent>  <LocalLeader>ca    <Esc>:call Lua_FunctionComment()<CR>
	"
	"-------------------------------------------------------------------------------
	" regex
	"-------------------------------------------------------------------------------
	nnoremap    <buffer>  <silent>  <LocalLeader>xe     i<C-R>=Lua_EscSpecChar()<CR><ESC><Right>
	inoremap    <buffer>  <silent>  <LocalLeader>xe      <C-R>=Lua_EscSpecChar()<CR>
	"
	"-------------------------------------------------------------------------------
	" snippets
	"-------------------------------------------------------------------------------
	nnoremap    <buffer>  <silent> <LocalLeader>ni         :call Lua_CodeSnippet('insert')<CR>
	inoremap    <buffer>  <silent> <LocalLeader>ni    <C-C>:call Lua_CodeSnippet('insert')<CR>
	vnoremap    <buffer>  <silent> <LocalLeader>ni    <C-C>:call Lua_CodeSnippet('insert')<CR>
	nnoremap    <buffer>  <silent> <LocalLeader>nc         :call Lua_CodeSnippet('create')<CR>
	inoremap    <buffer>  <silent> <LocalLeader>nc    <C-C>:call Lua_CodeSnippet('create')<CR>
	vnoremap    <buffer>  <silent> <LocalLeader>nc    <C-C>:call Lua_CodeSnippet('vcreate')<CR>
	nnoremap    <buffer>  <silent> <LocalLeader>nv         :call Lua_CodeSnippet('view')<CR>
	inoremap    <buffer>  <silent> <LocalLeader>nv    <C-C>:call Lua_CodeSnippet('view')<CR>
	vnoremap    <buffer>  <silent> <LocalLeader>nv    <C-C>:call Lua_CodeSnippet('view')<CR>
	nnoremap    <buffer>  <silent> <LocalLeader>ne         :call Lua_CodeSnippet('edit')<CR>
	inoremap    <buffer>  <silent> <LocalLeader>ne    <C-C>:call Lua_CodeSnippet('edit')<CR>
	vnoremap    <buffer>  <silent> <LocalLeader>ne    <C-C>:call Lua_CodeSnippet('edit')<CR>
	"
	"-------------------------------------------------------------------------------
	" templates - specials
	"-------------------------------------------------------------------------------
	nnoremap    <buffer>  <silent> <LocalLeader>ntl         :call mmtemplates#core#EditTemplateFiles(g:Lua_Templates,-1)<CR>
	inoremap    <buffer>  <silent> <LocalLeader>ntl    <C-C>:call mmtemplates#core#EditTemplateFiles(g:Lua_Templates,-1)<CR>
	vnoremap    <buffer>  <silent> <LocalLeader>ntl    <C-C>:call mmtemplates#core#EditTemplateFiles(g:Lua_Templates,-1)<CR>
	if s:installation == 'system'
		nnoremap  <buffer>  <silent> <LocalLeader>ntg         :call mmtemplates#core#EditTemplateFiles(g:Lua_Templates,0)<CR>
		inoremap  <buffer>  <silent> <LocalLeader>ntg    <C-C>:call mmtemplates#core#EditTemplateFiles(g:Lua_Templates,0)<CR>
		vnoremap  <buffer>  <silent> <LocalLeader>ntg    <C-C>:call mmtemplates#core#EditTemplateFiles(g:Lua_Templates,0)<CR>
	endif
	nnoremap    <buffer>  <silent> <LocalLeader>ntr         :call mmtemplates#core#ReadTemplates(g:Lua_Templates,"reload","all")<CR>
	inoremap    <buffer>  <silent> <LocalLeader>ntr    <C-C>:call mmtemplates#core#ReadTemplates(g:Lua_Templates,"reload","all")<CR>
	vnoremap    <buffer>  <silent> <LocalLeader>ntr    <C-C>:call mmtemplates#core#ReadTemplates(g:Lua_Templates,"reload","all")<CR>
	nnoremap    <buffer>  <silent> <LocalLeader>nts         :call mmtemplates#core#ChooseStyle(g:Lua_Templates,"!pick")<CR>
	inoremap    <buffer>  <silent> <LocalLeader>nts    <C-C>:call mmtemplates#core#ChooseStyle(g:Lua_Templates,"!pick")<CR>
	vnoremap    <buffer>  <silent> <LocalLeader>nts    <C-C>:call mmtemplates#core#ChooseStyle(g:Lua_Templates,"!pick")<CR>
	"
	"-------------------------------------------------------------------------------
	" code checker
	"-------------------------------------------------------------------------------
	nnoremap    <buffer>  <silent>  <LocalLeader>rr         :call Lua_Run('')<CR>
	inoremap    <buffer>  <silent>  <LocalLeader>rr    <Esc>:call Lua_Run('')<CR>
	vnoremap    <buffer>  <silent>  <LocalLeader>rr    <Esc>:call Lua_Run('')<CR>
	nnoremap    <buffer>  <silent>  <LocalLeader>rc         :call Lua_Compile('compile')<CR>
	inoremap    <buffer>  <silent>  <LocalLeader>rc    <Esc>:call Lua_Compile('compile')<CR>
	vnoremap    <buffer>  <silent>  <LocalLeader>rc    <Esc>:call Lua_Compile('compile')<CR>
	nnoremap    <buffer>  <silent>  <LocalLeader>rk         :call Lua_Compile('check')<CR>
	inoremap    <buffer>  <silent>  <LocalLeader>rk    <Esc>:call Lua_Compile('check')<CR>
	vnoremap    <buffer>  <silent>  <LocalLeader>rk    <Esc>:call Lua_Compile('check')<CR>
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
	nnoremap    <buffer>  <silent>  <LocalLeader>hs         :call Lua_HelpPlugin()<CR>
	inoremap    <buffer>  <silent>  <LocalLeader>hs    <Esc>:call Lua_HelpPlugin()<CR>
	vnoremap    <buffer>  <silent>  <LocalLeader>hs    <Esc>:call Lua_HelpPlugin()<CR>
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
	call mmtemplates#core#CreateMaps ( 'g:Lua_Templates', g:Lua_MapLeader, 'do_jump_map' )
	"
endfunction    " ----------  end of function s:CreateMaps  ----------
"
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
	" Preparation
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
	call mmtemplates#core#CreateMenus ( 'g:Lua_Templates', s:Lua_RootMenu, 'sub_menu', '&Help'    , 'priority', 800 )
	"
	"-------------------------------------------------------------------------------
	" comments
	"-------------------------------------------------------------------------------
	"
	let ahead = 'anoremenu <silent> '.s:Lua_RootMenu.'.Comments.'
	let vhead = 'vnoremenu <silent> '.s:Lua_RootMenu.'.Comments.'
	"
	exe ahead.'end-of-&line\ comment<TAB>'.esc_mapl.'cl            :call Lua_EndOfLineComment()<CR>'
	exe vhead.'end-of-&line\ comment<TAB>'.esc_mapl.'cl            :call Lua_EndOfLineComment()<CR>'
	exe ahead.'ad&just\ end-of-line\ com\.<TAB>'.esc_mapl.'cj      :call Lua_AdjustEndOfLineComm()<CR>'
	exe vhead.'ad&just\ end-of-line\ com\.<TAB>'.esc_mapl.'cj      :call Lua_AdjustEndOfLineComm()<CR>'
	exe ahead.'&set\ end-of-line\ com\.\ col\.<TAB>'.esc_mapl.'cs  :call Lua_SetEndOfLineCommPos()<CR>'
	exe vhead.'&set\ end-of-line\ com\.\ col\.<TAB>'.esc_mapl.'cs  :call Lua_SetEndOfLineCommPos()<CR>'
	exe ahead.'-Sep01-                                             :'
	"
	exe ahead.'&code\ ->\ comment<TAB>'.esc_mapl.'cc         :call Lua_CodeComment()<CR>'
	exe vhead.'&code\ ->\ comment<TAB>'.esc_mapl.'cc         :call Lua_CodeComment()<CR>'
	exe ahead.'c&omment\ ->\ code<TAB>'.esc_mapl.'co         :call Lua_CommentCode(0)<CR>'
	exe vhead.'c&omment\ ->\ code<TAB>'.esc_mapl.'co         :call Lua_CommentCode(0)<CR>'
	exe ahead.'&toggle\ code\ <->\ com\.<TAB>'.esc_mapl.'ct  :call Lua_CommentCode(1)<CR>'
	exe vhead.'&toggle\ code\ <->\ com\.<TAB>'.esc_mapl.'ct  :call Lua_CommentCode(1)<CR>'
	exe ahead.'-Sep02-                                       :'
	"
	exe ahead.'function\ description\ (&auto)<TAB>'.esc_mapl.'ca  :call Lua_FunctionComment()<CR>'
	exe vhead.'function\ description\ (&auto)<TAB>'.esc_mapl.'ca  :call Lua_FunctionComment()<CR>'
	exe ahead.'-Sep03-                                            :'
	"
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
	exe nhead.'&esc\.\ spec\.\ char\.<Tab>'.esc_mapl.'xe  i<C-R>=Lua_EscSpecChar()<CR><ESC><Right>'
	exe ihead.'&esc\.\ spec\.\ char\.<Tab>'.esc_mapl.'xe   <C-R>=Lua_EscSpecChar()<CR>'
	"
	"-------------------------------------------------------------------------------
	" snippets
	"-------------------------------------------------------------------------------
	"
	let ahead = 'anoremenu <silent> '.s:Lua_RootMenu.'.Snippets.'
	let vhead = 'vnoremenu <silent> '.s:Lua_RootMenu.'.Snippets.'
	"
	exe ahead.'&insert\ code\ snippet<Tab>'.esc_mapl.'ni       :call Lua_CodeSnippet("insert")<CR>'
	exe ahead.'&create\ code\ snippet<Tab>'.esc_mapl.'nc       :call Lua_CodeSnippet("create")<CR>'
	exe vhead.'&create\ code\ snippet<Tab>'.esc_mapl.'nc  <C-C>:call Lua_CodeSnippet("vcreate")<CR>'
	exe ahead.'&view\ code\ snippet<Tab>'.esc_mapl.'nv         :call Lua_CodeSnippet("view")<CR>'
	exe ahead.'&edit\ code\ snippet<Tab>'.esc_mapl.'ne         :call Lua_CodeSnippet("edit")<CR>'
	exe ahead.'-Sep01-                                         :'
	"
	exe ahead.'edit\ &local\ templates<Tab>'.esc_mapl.'ntl      :call mmtemplates#core#EditTemplateFiles(g:Lua_Templates,-1)<CR>'
	if s:installation == 'system'
		exe ahead.'edit\ &global\ templates<Tab>'.esc_mapl.'ntg   :call mmtemplates#core#EditTemplateFiles(g:Lua_Templates,0)<CR>'
	endif
	exe ahead.'reread\ &templates<Tab>'.esc_mapl.'ntr           :call mmtemplates#core#ReadTemplates(g:Lua_Templates,"reload","all")<CR>'
	"
	" styles
	call mmtemplates#core#CreateMenus ( 'g:Lua_Templates', s:Lua_RootMenu, 'do_styles',
				\ 'specials_menu', 'Snippets'	)
	"
	"-------------------------------------------------------------------------------
	" run
	"-------------------------------------------------------------------------------
	"
	let ahead = 'anoremenu <silent> '.s:Lua_RootMenu.'.Run.'
	let vhead = 'vnoremenu <silent> '.s:Lua_RootMenu.'.Run.'
	"
	exe ahead.'&run<TAB><F9>\ '.esc_mapl.'rr             :call Lua_Run()<CR>'
	exe ahead.'&compile<TAB><S-F9>\ '.esc_mapl.'rc       :call Lua_Compile("compile")<CR>'
	exe ahead.'chec&k\ code<TAB><A-F9>\ '.esc_mapl.'rk   :call Lua_Compile("check")<CR>'
	exe ahead.'-Sep01-                                   :'
	"
	exe ahead.'&settings<TAB>'.esc_mapl.'rs  :call Lua_Settings(0)<CR>'
	"
	"-------------------------------------------------------------------------------
	" help
	"-------------------------------------------------------------------------------
	"
	let ahead = 'anoremenu <silent> '.s:Lua_RootMenu.'.Help.'
	let vhead = 'vnoremenu <silent> '.s:Lua_RootMenu.'.Help.'
	"
	exe ahead.'-Sep01-                                  :'
	exe ahead.'&help\ (Lua-Support)<TAB>'.esc_mapl.'hs  :call Lua_HelpPlugin()<CR>'
	"
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
		anoremenu <silent> 40.1122 &Tools.Load\ Lua\ Support   :call Lua_AddMenus()<CR>
	elseif a:action == 'loading'
		aunmenu   <silent> &Tools.Load\ Lua\ Support
		anoremenu <silent> 40.1122 &Tools.Unload\ Lua\ Support :call Lua_RemoveMenus()<CR>
	elseif a:action == 'unloading'
		aunmenu   <silent> &Tools.Unload\ Lua\ Support
		anoremenu <silent> 40.1122 &Tools.Load\ Lua\ Support   :call Lua_AddMenus()<CR>
	endif
	"
endfunction    " ----------  end of function s:ToolMenu  ----------
"
"-------------------------------------------------------------------------------
" Lua_AddMenus : Add menus.   {{{1
"-------------------------------------------------------------------------------
"
function! Lua_AddMenus()
	if s:MenuVisible == 0
		" make sure the templates are loaded
		call s:SetupTemplates ()
		" initialize if not existing
		call s:ToolMenu ( 'loading' )
		call s:InitMenus ()
		" the menu is now visible
		let s:MenuVisible = 1
	endif
endfunction    " ----------  end of function Lua_AddMenus  ----------
"
"-------------------------------------------------------------------------------
" Lua_RemoveMenus : Remove menus.   {{{1
"-------------------------------------------------------------------------------
"
function! Lua_RemoveMenus()
	if s:MenuVisible == 1
		" destroy if visible
		call s:ToolMenu ( 'unloading' )
		if has ( 'menu' )
			exe 'aunmenu <silent> '.s:Lua_RootMenu
		endif
		" the menu is now invisible
		let s:MenuVisible = 0
	endif
endfunction    " ----------  end of function Lua_RemoveMenus  ----------
"
"-------------------------------------------------------------------------------
" Lua_Settings : Print the settings on the command line.   {{{1
"-------------------------------------------------------------------------------
"
function! Lua_Settings( verbose )
	"
	if     s:MSWIN | let sys_name = 'Windows'
	elseif s:UNIX  | let sys_name = 'UNIX'
	else           | let sys_name = 'unknown' | endif
	"
	let glb_t_status = filereadable ( s:Lua_GlbTemplateFile ) ? '' : ' (not readable)'
	let lcl_t_status = filereadable ( s:Lua_LclTemplateFile ) ? '' : ' (not readable)'
	let lua_exe_status = executable( s:Lua_Executable ) ? '' : ' (not executable)'
	let luac_exe_status = executable( s:Lua_CompilerExec ) ? '' : ' (not executable)'
	"
	let	txt = " Lua-Support settings\n\n"
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
					\  "                templates : -not loaded- \n"
					\ ."\n"
	endif
	let txt .=
				\  '      plugin installation :  '.s:installation.' on '.sys_name."\n"
				\ .'    using template engine :  version '.g:Templates_Version." by Wolfgang Mehner\n"
				\ ."\n"
	if s:installation == 'system'
		let txt .= '     global template file :  '.s:Lua_GlbTemplateFile.glb_t_status."\n"
	endif
	let txt .=
				\  '      local template file :  '.s:Lua_LclTemplateFile.lcl_t_status."\n"
				\ .'       code snippets dir. :  '.s:Lua_SnippetDir."\n"
				\ .'        lua (interpreter) :  '.s:Lua_Executable.lua_exe_status."\n"
				\ .'          luac (compiler) :  '.s:Lua_CompilerExec.luac_exe_status."\n"
	if a:verbose >= 1
		let	txt .= "\n"
					\ .'                mapleader :  "'.g:Lua_MapLeader."\"\n"
					\ .'               load menus :  "'.s:Lua_LoadMenus."\"\n"
					\ .'       insert file header :  "'.g:Lua_InsertFileHeader."\"\n"
					\ ."\n"
					\ .'       compiled extension :  "'.g:Lua_CompiledExtension."\"\n"
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
" Setup: Templates and menus.   {{{1
"-------------------------------------------------------------------------------
"
" tool menu entry
call s:ToolMenu ( 'setup' )
"
" load the menu right now?
if s:Lua_LoadMenus == 'startup'
	call Lua_AddMenus ()
endif
"
if has( 'autocmd' )
	autocmd FileType *
				\	if &filetype == 'lua' && ! exists( 'g:Lua_Templates' ) |
				\		if s:Lua_LoadMenus == 'auto' | call Lua_AddMenus () |
				\		else                         | call s:SetupTemplates () |
				\		endif |
				\	endif
	autocmd FileType *
				\	if &filetype == 'lua' |
				\		call s:CreateMaps() |
				\	endif
	autocmd BufNewFile  *.lua  call s:InsertFileHeader()
endif
" }}}1
"-------------------------------------------------------------------------------
"
" =====================================================================================
"  vim: foldmethod=marker
