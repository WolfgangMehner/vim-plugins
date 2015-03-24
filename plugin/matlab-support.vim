"===============================================================================
"
"          File:  matlab-support.vim
"
"   Description:  Matlab IDE for Vim/gVim.
"
"                 See help file matlabsupport.txt .
"
"   VIM Version:  7.0+
"        Author:  Wolfgang Mehner, wolfgang-mehner@web.de
"  Organization:  
"       Version:  see variable g:Matlab_Version below
"       Created:  11.04.2010
"      Revision:  24.11.2013
"       License:  Copyright (c) 2012-2015, Wolfgang Mehner
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
	echo 'The plugin matlab-support.vim needs Vim version >= 7.'
	echohl None
	finish
endif
"
" prevent duplicate loading
" need compatible
if &cp || ( exists('g:Matlab_Version') && ! exists('g:Matlab_DevelopmentOverwrite') )
	finish
endif
let g:Matlab_Version= '0.8rc2'     " version number of this script; do not change
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
let s:installation           = '*undefined*'  " 'local' or 'system'
let s:plugin_dir             = ''             " the directory hosting ftplugin/ plugin/ matlab-support/ ...
let s:Matlab_GlbTemplateFile = ''             " the global templates, undefined for s:installation == 'local'
let s:Matlab_LclTemplateFile = ''             " the local templates
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
		let s:Matlab_LclTemplateFile = s:plugin_dir.'/matlab-support/templates/Templates'
	else
		"
		" system wide installation
		let s:installation           = 'system'
		let s:Matlab_GlbTemplateFile = s:plugin_dir.'/matlab-support/templates/Templates'
		let s:Matlab_LclTemplateFile = $HOME.'/vimfiles/matlab-support/templates/Templates'
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
		let s:Matlab_LclTemplateFile = s:plugin_dir.'/matlab-support/templates/Templates'
	else
		"
		" system wide installation
		let s:installation           = 'system'
		let s:Matlab_GlbTemplateFile = s:plugin_dir.'/matlab-support/templates/Templates'
		let s:Matlab_LclTemplateFile = $HOME.'/.vim/matlab-support/templates/Templates'
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
let s:Matlab_LoadMenus       = 'auto'     " load the menus?
let s:Matlab_RootMenu        = '&Matlab'  " name of the root menu
"
let s:Matlab_MapLeader       = ''         " default: do not overwrite 'maplocalleader'
"
let s:Matlab_MlintExecutable = 'mlint'    " default: mlint on system path
"
let s:Matlab_LineEndCommColDefault = 49
let s:Matlab_SnippetDir            = s:plugin_dir.'/matlab-support/codesnippets/'
let s:Matlab_SnippetBrowser        = 'gui'
"
if ! exists ( 's:MenuVisible' )
	let s:MenuVisible = 0                " menus are not visible at the moment
endif
"
call s:GetGlobalSetting ( 'Matlab_GlbTemplateFile' )
call s:GetGlobalSetting ( 'Matlab_LclTemplateFile' )
call s:GetGlobalSetting ( 'Matlab_LoadMenus' )
call s:GetGlobalSetting ( 'Matlab_RootMenu' )
call s:GetGlobalSetting ( 'Matlab_MlintExecutable' )
call s:GetGlobalSetting ( 'Matlab_LineEndCommColDefault' )
call s:GetGlobalSetting ( 'Matlab_SnippetDir' )
call s:GetGlobalSetting ( 'Matlab_SnippetBrowser' )
"
call s:ApplyDefaultSetting ( 'Matlab_MapLeader', '' )
"
let s:Matlab_GlbTemplateFile = expand ( s:Matlab_GlbTemplateFile )
let s:Matlab_LclTemplateFile = expand ( s:Matlab_LclTemplateFile )
let s:Matlab_SnippetDir      = expand ( s:Matlab_SnippetDir )
"
" }}}2
"-------------------------------------------------------------------------------
"
"-------------------------------------------------------------------------------
" Matlab_EndOfLineComment : Append end-of-line comment.   {{{1
"-------------------------------------------------------------------------------
"
function! Matlab_EndOfLineComment () range
	"
	" local position
	if !exists( 'b:Matlab_LineEndCommentColumn' )
		let b:Matlab_LineEndCommentColumn = s:Matlab_LineEndCommColDefault
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
			if linelength < b:Matlab_LineEndCommentColumn
				let diff = b:Matlab_LineEndCommentColumn - 1 - linelength
			endif
			exe 'normal! '.diff.'A '
			call mmtemplates#core#InsertTemplate (g:Matlab_Templates, 'Comments.end-of-line comment')
		endif
	endfor
	"
endfunction    " ----------  end of function Matlab_EndOfLineComment  ----------
"
"-------------------------------------------------------------------------------
" Matlab_AdjustEndOfLineComm : Adjust end-of-line comment.   {{{1
"-------------------------------------------------------------------------------
"
function! Matlab_AdjustEndOfLineComm () range
	"
	" comment character (for use in regular expression)
	let cc = '%'
	"
	" patterns to ignore when adjusting line-end comments (maybe incomplete):
	" - single-quoted strings, includes '' \n \\ ...
	" :TODO:01.12.2013 14:26:WM: does Matlab support escape sequences like that?
	let align_regex = "'\\%(''\\|\\\\.\\|[^']\\)*'"
	"
	" local position
	if !exists( 'b:Matlab_LineEndCommentColumn' )
		let b:Matlab_LineEndCommentColumn = s:Matlab_LineEndCommColDefault
	endif
	let correct_idx = b:Matlab_LineEndCommentColumn
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
endfunction    " ----------  end of function Matlab_AdjustEndOfLineComm  ----------
"
"-------------------------------------------------------------------------------
" Matlab_SetEndOfLineCommPos : Set end-of-line comment position.   {{{1
"-------------------------------------------------------------------------------
"
function! Matlab_SetEndOfLineCommPos () range
	"
	let b:Matlab_LineEndCommentColumn = virtcol('.')
	call s:ImportantMsg ( 'line end comments will start at column '.b:Matlab_LineEndCommentColumn )
	"
endfunction    " ----------  end of function Matlab_SetEndOfLineCommPos  ----------
"
"-------------------------------------------------------------------------------
" Matlab_CodeComment : Code -> Comment   {{{1
"-------------------------------------------------------------------------------
"
function! Matlab_CodeComment() range
	"
	" add '%' at the beginning of the lines
	silent exe ":".a:firstline.",".a:lastline."s/^/%/"
	"
endfunction    " ----------  end of function Matlab_CodeComment  ----------
"
"-------------------------------------------------------------------------------
" Matlab_CommentCode : Comment -> Code   {{{1
"-------------------------------------------------------------------------------
"
function! Matlab_CommentCode( toggle ) range
	"
	" remove comments:
	" - remove '%' from the beginning of the line
	" and, in toggling mode:
	" - if the line is not a comment, comment it
	for i in range( a:firstline, a:lastline )
		if getline( i ) =~ '^%'
			silent exe i."s/^%//"
		elseif a:toggle
			silent exe i."s/^/%/"
		endif
	endfor
	"
endfunction    " ----------  end of function Matlab_CommentCode  ----------
"
"-------------------------------------------------------------------------------
" s:GetFunctionParameters : Get the name, parameters, ... of a function.   {{{1
"
" Parameters:
"   fun_line - the function definition (string)
" Returns:
"   [ <fun_name>, <returns>, <params> ] - data (list: string, list, list)
"
" The entries are as follows:
"   file name - name of the function (string)
"   returns   - the name of the return arguments (list of strings)
"   params    - the names of the parameters (list of strings)
"
" In case of an error, an empty list is returned.
"-------------------------------------------------------------------------------
function! s:GetFunctionParameters( fun_line )
	"
	" 1st expression: the syntax category
	" 2nd expression: as before, but with brackets to catch the match
	"
	let identifier   = '[a-zA-Z][a-zA-Z0-9_]*'
	let identifier_c = '\('.identifier.'\)'
	let in_bracket   = '[^)\]]*'
	let in_bracket_c = '\('.in_bracket.'\)'
	let spaces       = '\s*'
	let spaces_c     = '\('.spaces.'\)'
	let tail_c       = '\(.*\)$'
	"
	let mlist = matchlist ( a:fun_line, '^'.spaces_c.'function\s*'.tail_c )
	"
	" no function?
	if empty( mlist )
		return []
	endif
	"
	" found a function!
	let tail   = mlist[2]
	let fun_name   = ''
	let return_str = ''
	let param_str  = ''
	"
	" no return
	let mlist = matchlist( tail, '^'.identifier_c.'\s*(\s*'.in_bracket_c.')' )
	if ! empty( mlist )
		let fun_name   = mlist[1]
		let return_str = ''
		let param_str  = mlist[2]
	endif
	"
	" single return
	let mlist = matchlist( tail, '^'.identifier_c.'\s*=\s*'.identifier_c.'\s*(\s*'.in_bracket_c.')' )
	if ! empty( mlist )
		let fun_name   = mlist[2]
		let return_str = mlist[1]
		let param_str  = mlist[3]
	endif
	"
	" multiple returns
	let mlist = matchlist( tail, '^\[\s*'.in_bracket_c.'\]\s*=\s*'.identifier_c.'\s*(\s*'.in_bracket_c.')' )
	if ! empty( mlist )
		let fun_name   = mlist[2]
		let return_str = mlist[1]
		let param_str  = mlist[3]
	endif
	"
	let param_str  = substitute ( param_str, '\s*$', '', '' )
	let param_list = split ( param_str, '\s*,\s*' )
	"
	let return_str  = substitute ( return_str, '\s*$', '', '' )
	let return_list = split ( return_str, '\s*,\s*' )
	"
	if empty ( fun_name )
		return []
	else
		return [ fun_name, return_list, param_list ]
	endif
	"
endfunction    " ----------  end of function s:GetFunctionParameters  ----------
"
"-------------------------------------------------------------------------------
" Matlab_FunctionComment : Automatically comment a function.   {{{1
"-------------------------------------------------------------------------------
"
function! Matlab_FunctionComment() range
	"
	" TODO: varargin, varargout
	" TODO: multiple lines possible?
	" TODO: remove '...' operator
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
	let [ fun_name, return_list, param_list ] = res_list
	let base_name = mmtemplates#core#ExpandText ( g:Matlab_Templates, '|BASENAME|' )
	"
	" description of the file or another function?
	if fun_name == base_name
		call mmtemplates#core#InsertTemplate ( g:Matlab_Templates, 'Comments.file description',
					\ '|PARAMETERS|', param_list, '|RETURNS|', return_list )
	else
		call mmtemplates#core#InsertTemplate ( g:Matlab_Templates, 'Comments.function description',
					\ '|FUNCTION_NAME|', fun_name, '|PARAMETERS|', param_list, '|RETURNS|', return_list )
	endif
	"
endfunction    " ----------  end of function Matlab_FunctionComment  ----------
"
"-------------------------------------------------------------------------------
" Matlab_CodeSnippet : Code snippets.   {{{1
"
" Parameters:
"   action - "insert", "create", "vcreate", "view" or "edit" (string)
"-------------------------------------------------------------------------------
"
function! Matlab_CodeSnippet ( action )
	"
	"-------------------------------------------------------------------------------
	" setup
	"-------------------------------------------------------------------------------
	"
	" check directory
	if ! isdirectory( s:Matlab_SnippetDir )
		return s:ErrorMsg (
					\ 'Code snippet directory '.s:Matlab_SnippetDir.' does not exist.',
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
		if has('browse') && s:Matlab_SnippetBrowser == 'gui'
			let snippetfile = browse ( 0, 'insert a code snippet', s:Matlab_SnippetDir, '' )
		else
			let snippetfile = input ( 'insert snippet ', s:Matlab_SnippetDir, 'file' )
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
		if has('browse') && s:Matlab_SnippetBrowser == 'gui'
			let snippetfile = browse ( 1, 'create a code snippet', s:Matlab_SnippetDir, '' )
		else
			let snippetfile = input ( 'create snippet ', s:Matlab_SnippetDir, 'file' )
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
		if has('browse') && s:Matlab_SnippetBrowser == 'gui'
			let snippetfile = browse ( saving, a:action.' a code snippet', s:Matlab_SnippetDir, '' )
		else
			let snippetfile = input ( a:action.' snippet ', s:Matlab_SnippetDir, 'file' )
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
endfunction    " ----------  end of function Matlab_CodeSnippet  ----------
"
"-------------------------------------------------------------------------------
" Matlab_CheckCode : Use mlint to check the code.   {{{1
"-------------------------------------------------------------------------------
"
function! Matlab_CheckCode() range
	"
	silent exe 'update'   | " write source file if necessary
	cclose
	"
	" assemble all the information
	let currentdir          = getcwd()
	let currentbuffer       = bufname('%')
	let fullname            = currentdir.'/'.currentbuffer
	let fullname            = shellescape( fullname, 1 )
	"
	" prepare and check the executable
	if ! executable( s:Matlab_MlintExecutable )
		return s:ErrorMsg (
					\ 'Command "'.s:Matlab_MlintExecutable.'" not found. Not configured correctly?',
					\ 'Further information: :help matlabsupport-config-mlint' )
	endif
	"
	" call 'mlint' and process the output
	let errors_mlint = system ( shellescape( s:Matlab_MlintExecutable ).' -id '.fullname )
	"
	if empty( errors_mlint )
		let errors = ''
	else
		let errors = 'FILE '.currentbuffer."\n".errors_mlint.'FILEEND'
	endif
	"
	let errorf_saved = &g:errorformat
	"
	let &g:errorformat =
				\  '%-PFILE %f,%-QFILEEND,'
				\ .'L %l (C %c): %m,L %l (C %c-%*\d): %m'
	silent exe 'cexpr errors'
	"
	let &g:errorformat = errorf_saved
	"
	if empty ( errors_mlint )
		redraw                                      " redraw after cclose, before echoing
		call s:ImportantMsg ( bufname('%').': No warnings.' )
	else
		botright cwindow
		cc
	endif
	"
endfunction    " ----------  end of function Matlab_CheckCode  ----------
"
"-------------------------------------------------------------------------------
" Matlab_IgnoreWarning : Ignore the current mlint warning.   {{{1
"-------------------------------------------------------------------------------
"
function! Matlab_IgnoreWarning() range
	"
	" the list of errors
	let qf_list = getqflist ()
	"
	if empty ( qf_list )
		return s:ImportantMsg ( 'No warnings.' )
	endif
	"
	" assemble all the information
	let my_buf  = bufnr ( '%' )
	let my_line = line  ( '.' )
	let my_col  = col   ( '.' )
	let text    = ''
	let type    = ''
	"
	" look for the right error
	" number of errors on the line:
	" - none        : abort
	" - one         : continue with this error
	" - two or more : the column must match as well
	let err_on_line = 0
	"
	for error in qf_list
		" ignore invalid errors, errors on other lines
		if ! error.valid || error.bufnr != my_buf || error.lnum != my_line
			continue
		endif
		"
		" matches the location precisely
		if error.col == my_col
			let text = error.text
			let err_on_line = 1
			break
		endif
		"
		let text = error.text
		let err_on_line += 1
		continue
	endfor
	"
	if empty ( text )
		return s:ImportantMsg ( 'No warning for this line.' )
	elseif err_on_line > 1
		return s:ImportantMsg ( 'There is more than one warning for this line. Go to the correct location.' )
	endif
	"
	let type = matchstr ( text, '^\w\+' )
	"
	" append or add to the special comment
	let line  = getline ( '.' )
	let mlist = matchlist ( line, '%#ok\%(:\|<\)\([a-zA-Z,]\+\)>\?\s*$' )
	if ! empty ( mlist )
		" line contains %#ok, check if the error-code is contained as well
		if -1 == match ( mlist[1], type )
			exe ':.s/\(>\?\)\s*$/,'.type.'\1'
		else
			call s:ImportantMsg ( 'Error is already being ignored.' )
		endif
	else
		" append %#ok:...
		exe ':.s/\s*$/ %#ok<'.type.'>'
	endif
	"
	" reposition the cursor
	call cursor ( my_line, my_col )
	"
endfunction    " ----------  end of function Matlab_IgnoreWarning  ----------
"
"------------------------------------------------------------------------------
"  === Templates API ===   {{{1
"------------------------------------------------------------------------------
"
"------------------------------------------------------------------------------
"  Matlab_SetMapLeader   {{{2
"------------------------------------------------------------------------------
function! Matlab_SetMapLeader ()
	if exists ( 'g:Matlab_MapLeader' )
		call mmtemplates#core#SetMapleader ( g:Matlab_MapLeader )
	endif
endfunction    " ----------  end of function Matlab_SetMapLeader  ----------
"
"------------------------------------------------------------------------------
"  Matlab_ResetMapLeader   {{{2
"------------------------------------------------------------------------------
function! Matlab_ResetMapLeader ()
	if exists ( 'g:Matlab_MapLeader' )
		call mmtemplates#core#ResetMapleader ()
	endif
endfunction    " ----------  end of function Matlab_ResetMapLeader  ----------
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
	let g:Matlab_Templates = mmtemplates#core#NewLibrary ()
	"
	" mapleader
	if empty ( g:Matlab_MapLeader )
		call mmtemplates#core#Resource ( g:Matlab_Templates, 'set', 'property', 'Templates::Mapleader', '\' )
	else
		call mmtemplates#core#Resource ( g:Matlab_Templates, 'set', 'property', 'Templates::Mapleader', g:Matlab_MapLeader )
	endif
	"
	" map: choose style
	call mmtemplates#core#Resource ( g:Matlab_Templates, 'set', 'property', 'Templates::ChooseStyle::Map', 'nts' )
	"
	" syntax: comments
	call mmtemplates#core#ChangeSyntax ( g:Matlab_Templates, 'comment', '§' )
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
		if filereadable( s:Matlab_GlbTemplateFile )
			call mmtemplates#core#ReadTemplates ( g:Matlab_Templates, 'load', s:Matlab_GlbTemplateFile )
		else
			return s:ErrorMsg ( 'Global template file "'.s:Matlab_GlbTemplateFile.'" not readable.' )
		endif
		"
		let local_dir = fnamemodify ( s:Matlab_LclTemplateFile, ':p:h' )
		"
		if ! isdirectory( local_dir ) && exists('*mkdir')
			try
				call mkdir ( local_dir, 'p' )
			catch /.*/
			endtry
		endif
		"
		if isdirectory( local_dir ) && ! filereadable( s:Matlab_LclTemplateFile )
			let sample_template_file = s:plugin_dir.'/matlab-support/rc/sample_template_file'
			if filereadable( sample_template_file )
				call writefile ( readfile ( sample_template_file ), s:Matlab_LclTemplateFile )
			endif
		endif
		"
		" local templates
		if filereadable( s:Matlab_LclTemplateFile )
			call mmtemplates#core#ReadTemplates ( g:Matlab_Templates, 'load', s:Matlab_LclTemplateFile )
			if mmtemplates#core#ExpandText ( g:Matlab_Templates, '|AUTHOR|' ) == 'YOUR NAME'
				call s:ErrorMsg ( 'Please set your personal details in the file "'.s:Matlab_LclTemplateFile.'".' )
			endif
		endif
		"
	elseif s:installation == 'local'
		"-------------------------------------------------------------------------------
		" local installation
		"-------------------------------------------------------------------------------
		"
		" local templates
		if filereadable ( s:Matlab_LclTemplateFile )
			call mmtemplates#core#ReadTemplates ( g:Matlab_Templates, 'load', s:Matlab_LclTemplateFile )
		else
			return s:ErrorMsg ( 'Local template file "'.s:Matlab_LclTemplateFile.'" not readable.' )
		endif
	endif
endfunction    " ----------  end of function s:SetupTemplates  ----------
"
"-------------------------------------------------------------------------------
" Matlab_HelpPlugin : Plug-in help.   {{{1
"-------------------------------------------------------------------------------
"
function! Matlab_HelpPlugin ()
	try
		help matlab-support
	catch
		exe 'helptags '.s:plugin_dir.'/doc'
		help matlab-support
	endtry
endfunction    " ----------  end of function Matlab_HelpPlugin  ----------
"
"-------------------------------------------------------------------------------
" s:CreateMaps : Create additional maps.   {{{1
"-------------------------------------------------------------------------------
"
function! s:CreateMaps ()
	"
	"-------------------------------------------------------------------------------
	" settings - local leader
	"-------------------------------------------------------------------------------
	if ! empty ( g:Matlab_MapLeader )
		if exists ( 'g:maplocalleader' )
			let ll_save = g:maplocalleader
		endif
		let g:maplocalleader = g:Matlab_MapLeader
	endif
	"
	"-------------------------------------------------------------------------------
	" comments
	"-------------------------------------------------------------------------------
	 noremap    <buffer>  <silent>  <LocalLeader>cl         :call Matlab_EndOfLineComment()<CR>
	inoremap    <buffer>  <silent>  <LocalLeader>cl    <Esc>:call Matlab_EndOfLineComment()<CR>
	 noremap    <buffer>  <silent>  <LocalLeader>cj         :call Matlab_AdjustEndOfLineComm()<CR>
	inoremap    <buffer>  <silent>  <LocalLeader>cj    <Esc>:call Matlab_AdjustEndOfLineComm()<CR>
	 noremap    <buffer>  <silent>  <LocalLeader>cs         :call Matlab_SetEndOfLineCommPos()<CR>
	inoremap    <buffer>  <silent>  <LocalLeader>cs    <Esc>:call Matlab_SetEndOfLineCommPos()<CR>
	"
	 noremap    <buffer>  <silent>  <LocalLeader>cc         :call Matlab_CodeComment()<CR>
	inoremap    <buffer>  <silent>  <LocalLeader>cc    <Esc>:call Matlab_CodeComment()<CR>
	 noremap    <buffer>  <silent>  <LocalLeader>co         :call Matlab_CommentCode(0)<CR>
	inoremap    <buffer>  <silent>  <LocalLeader>co    <Esc>:call Matlab_CommentCode(0)<CR>
	 noremap    <buffer>  <silent>  <LocalLeader>ct         :call Matlab_CommentCode(1)<CR>
	inoremap    <buffer>  <silent>  <LocalLeader>ct    <Esc>:call Matlab_CommentCode(1)<CR>
	"
	 noremap    <buffer>  <silent>  <LocalLeader>ca         :call Matlab_FunctionComment()<CR>
	inoremap    <buffer>  <silent>  <LocalLeader>ca    <Esc>:call Matlab_FunctionComment()<CR>
	"
	"-------------------------------------------------------------------------------
	" snippets
	"-------------------------------------------------------------------------------
	nnoremap    <buffer>  <silent> <LocalLeader>ni         :call Matlab_CodeSnippet('insert')<CR>
	inoremap    <buffer>  <silent> <LocalLeader>ni    <C-C>:call Matlab_CodeSnippet('insert')<CR>
	vnoremap    <buffer>  <silent> <LocalLeader>ni    <C-C>:call Matlab_CodeSnippet('insert')<CR>
	nnoremap    <buffer>  <silent> <LocalLeader>nc         :call Matlab_CodeSnippet('create')<CR>
	inoremap    <buffer>  <silent> <LocalLeader>nc    <C-C>:call Matlab_CodeSnippet('create')<CR>
	vnoremap    <buffer>  <silent> <LocalLeader>nc    <C-C>:call Matlab_CodeSnippet('vcreate')<CR>
	nnoremap    <buffer>  <silent> <LocalLeader>nv         :call Matlab_CodeSnippet('view')<CR>
	inoremap    <buffer>  <silent> <LocalLeader>nv    <C-C>:call Matlab_CodeSnippet('view')<CR>
	vnoremap    <buffer>  <silent> <LocalLeader>nv    <C-C>:call Matlab_CodeSnippet('view')<CR>
	nnoremap    <buffer>  <silent> <LocalLeader>ne         :call Matlab_CodeSnippet('edit')<CR>
	inoremap    <buffer>  <silent> <LocalLeader>ne    <C-C>:call Matlab_CodeSnippet('edit')<CR>
	vnoremap    <buffer>  <silent> <LocalLeader>ne    <C-C>:call Matlab_CodeSnippet('edit')<CR>
	"
	"-------------------------------------------------------------------------------
	" templates - specials
	"-------------------------------------------------------------------------------
	nnoremap    <buffer>  <silent> <LocalLeader>ntl         :call mmtemplates#core#EditTemplateFiles(g:Matlab_Templates,-1)<CR>
	inoremap    <buffer>  <silent> <LocalLeader>ntl    <C-C>:call mmtemplates#core#EditTemplateFiles(g:Matlab_Templates,-1)<CR>
	vnoremap    <buffer>  <silent> <LocalLeader>ntl    <C-C>:call mmtemplates#core#EditTemplateFiles(g:Matlab_Templates,-1)<CR>
	if s:installation == 'system'
		nnoremap  <buffer>  <silent> <LocalLeader>ntg         :call mmtemplates#core#EditTemplateFiles(g:Matlab_Templates,0)<CR>
		inoremap  <buffer>  <silent> <LocalLeader>ntg    <C-C>:call mmtemplates#core#EditTemplateFiles(g:Matlab_Templates,0)<CR>
		vnoremap  <buffer>  <silent> <LocalLeader>ntg    <C-C>:call mmtemplates#core#EditTemplateFiles(g:Matlab_Templates,0)<CR>
	endif
	nnoremap    <buffer>  <silent> <LocalLeader>ntr         :call mmtemplates#core#ReadTemplates(g:Matlab_Templates,"reload","all")<CR>
	inoremap    <buffer>  <silent> <LocalLeader>ntr    <C-C>:call mmtemplates#core#ReadTemplates(g:Matlab_Templates,"reload","all")<CR>
	vnoremap    <buffer>  <silent> <LocalLeader>ntr    <C-C>:call mmtemplates#core#ReadTemplates(g:Matlab_Templates,"reload","all")<CR>
	nnoremap    <buffer>  <silent> <LocalLeader>nts         :call mmtemplates#core#ChooseStyle(g:Matlab_Templates,"!pick")<CR>
	inoremap    <buffer>  <silent> <LocalLeader>nts    <C-C>:call mmtemplates#core#ChooseStyle(g:Matlab_Templates,"!pick")<CR>
	vnoremap    <buffer>  <silent> <LocalLeader>nts    <C-C>:call mmtemplates#core#ChooseStyle(g:Matlab_Templates,"!pick")<CR>
	"
	"-------------------------------------------------------------------------------
	" code checker
	"-------------------------------------------------------------------------------
	nnoremap    <buffer>  <silent>  <LocalLeader>rk         :call Matlab_CheckCode()<CR>
	inoremap    <buffer>  <silent>  <LocalLeader>rk    <Esc>:call Matlab_CheckCode()<CR>
	vnoremap    <buffer>  <silent>  <LocalLeader>rk    <Esc>:call Matlab_CheckCode()<CR>
	nnoremap    <buffer>  <silent>  <LocalLeader>ri         :call Matlab_IgnoreWarning()<CR>
	inoremap    <buffer>  <silent>  <LocalLeader>ri    <Esc>:call Matlab_IgnoreWarning()<CR>
	vnoremap    <buffer>  <silent>  <LocalLeader>ri    <Esc>:call Matlab_IgnoreWarning()<CR>
	"
	"-------------------------------------------------------------------------------
	" settings
	"-------------------------------------------------------------------------------
	nnoremap    <buffer>  <silent>  <LocalLeader>rs         :call Matlab_Settings(0)<CR>
	inoremap    <buffer>  <silent>  <LocalLeader>rs    <Esc>:call Matlab_Settings(0)<CR>
	vnoremap    <buffer>  <silent>  <LocalLeader>rs    <Esc>:call Matlab_Settings(0)<CR>
	"
	"-------------------------------------------------------------------------------
	" help
	"-------------------------------------------------------------------------------
	nnoremap    <buffer>  <silent>  <LocalLeader>hs         :call Matlab_HelpPlugin()<CR>
	inoremap    <buffer>  <silent>  <LocalLeader>hs    <Esc>:call Matlab_HelpPlugin()<CR>
	vnoremap    <buffer>  <silent>  <LocalLeader>hs    <Esc>:call Matlab_HelpPlugin()<CR>
	"
	"-------------------------------------------------------------------------------
	" settings - reset local leader
	"-------------------------------------------------------------------------------
	if ! empty ( g:Matlab_MapLeader )
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
	call mmtemplates#core#CreateMaps ( 'g:Matlab_Templates', g:Matlab_MapLeader, 'do_jump_map' )
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
	call mmtemplates#core#CreateMenus ( 'g:Matlab_Templates', s:Matlab_RootMenu, 'do_reset' )
	"
	" get the mapleader (correctly escaped)
	let [ esc_mapl, err ] = mmtemplates#core#Resource ( g:Matlab_Templates, 'escaped_mapleader' )
	"
	exe 'anoremenu '.s:Matlab_RootMenu.'.Matlab  <Nop>'
	exe 'anoremenu '.s:Matlab_RootMenu.'.-Sep00- <Nop>'
	"
	"-------------------------------------------------------------------------------
	" menu headers
	"-------------------------------------------------------------------------------
	"
	call mmtemplates#core#CreateMenus ( 'g:Matlab_Templates', s:Matlab_RootMenu, 'sub_menu', '&Comments', 'priority', 500 )
	" the other, automatically created menus go here; their priority is the standard priority 500
	call mmtemplates#core#CreateMenus ( 'g:Matlab_Templates', s:Matlab_RootMenu, 'sub_menu', 'S&nippets', 'priority', 600 )
	call mmtemplates#core#CreateMenus ( 'g:Matlab_Templates', s:Matlab_RootMenu, 'sub_menu', '&Run'     , 'priority', 700 )
	call mmtemplates#core#CreateMenus ( 'g:Matlab_Templates', s:Matlab_RootMenu, 'sub_menu', '&Help'    , 'priority', 800 )
	"
	"-------------------------------------------------------------------------------
	" comments
	"-------------------------------------------------------------------------------
	"
	let ahead = 'anoremenu <silent> '.s:Matlab_RootMenu.'.Comments.'
	let vhead = 'vnoremenu <silent> '.s:Matlab_RootMenu.'.Comments.'
	"
	exe ahead.'end-of-&line\ comment<TAB>'.esc_mapl.'cl            :call Matlab_EndOfLineComment()<CR>'
	exe vhead.'end-of-&line\ comment<TAB>'.esc_mapl.'cl            :call Matlab_EndOfLineComment()<CR>'
	exe ahead.'ad&just\ end-of-line\ com\.<TAB>'.esc_mapl.'cj      :call Matlab_AdjustEndOfLineComm()<CR>'
	exe vhead.'ad&just\ end-of-line\ com\.<TAB>'.esc_mapl.'cj      :call Matlab_AdjustEndOfLineComm()<CR>'
	exe ahead.'&set\ end-of-line\ com\.\ col\.<TAB>'.esc_mapl.'cs  :call Matlab_SetEndOfLineCommPos()<CR>'
	exe vhead.'&set\ end-of-line\ com\.\ col\.<TAB>'.esc_mapl.'cs  :call Matlab_SetEndOfLineCommPos()<CR>'
	exe ahead.'-Sep01-                                             :'
	"
	exe ahead.'&code\ ->\ comment<TAB>'.esc_mapl.'cc         :call Matlab_CodeComment()<CR>'
	exe vhead.'&code\ ->\ comment<TAB>'.esc_mapl.'cc         :call Matlab_CodeComment()<CR>'
	exe ahead.'c&omment\ ->\ code<TAB>'.esc_mapl.'co         :call Matlab_CommentCode(0)<CR>'
	exe vhead.'c&omment\ ->\ code<TAB>'.esc_mapl.'co         :call Matlab_CommentCode(0)<CR>'
	exe ahead.'&toggle\ code\ <->\ com\.<TAB>'.esc_mapl.'ct  :call Matlab_CommentCode(1)<CR>'
	exe vhead.'&toggle\ code\ <->\ com\.<TAB>'.esc_mapl.'ct  :call Matlab_CommentCode(1)<CR>'
	exe ahead.'-Sep02-                                       :'
	"
	exe ahead.'function\ description\ (&auto)<TAB>'.esc_mapl.'ca  :call Matlab_FunctionComment()<CR>'
	exe vhead.'function\ description\ (&auto)<TAB>'.esc_mapl.'ca  :call Matlab_FunctionComment()<CR>'
	exe ahead.'-Sep03-                                            :'
	"
	"-------------------------------------------------------------------------------
	" templates
	"-------------------------------------------------------------------------------
	"
	call mmtemplates#core#CreateMenus ( 'g:Matlab_Templates', s:Matlab_RootMenu, 'do_templates' )
	"
	"-------------------------------------------------------------------------------
	" snippets
	"-------------------------------------------------------------------------------
	"
	let ahead = 'anoremenu <silent> '.s:Matlab_RootMenu.'.Snippets.'
	let vhead = 'vnoremenu <silent> '.s:Matlab_RootMenu.'.Snippets.'
	"
	exe ahead.'&insert\ code\ snippet<Tab>'.esc_mapl.'ni       :call Matlab_CodeSnippet("insert")<CR>'
	exe ahead.'&create\ code\ snippet<Tab>'.esc_mapl.'nc       :call Matlab_CodeSnippet("create")<CR>'
	exe vhead.'&create\ code\ snippet<Tab>'.esc_mapl.'nc  <C-C>:call Matlab_CodeSnippet("vcreate")<CR>'
	exe ahead.'&view\ code\ snippet<Tab>'.esc_mapl.'nv         :call Matlab_CodeSnippet("view")<CR>'
	exe ahead.'&edit\ code\ snippet<Tab>'.esc_mapl.'ne         :call Matlab_CodeSnippet("edit")<CR>'
	exe ahead.'-Sep01-                                       :'
	"
	exe ahead.'edit\ &local\ templates<Tab>'.esc_mapl.'ntl      :call mmtemplates#core#EditTemplateFiles(g:Matlab_Templates,-1)<CR>'
	if s:installation == 'system'
		exe ahead.'edit\ &global\ templates<Tab>'.esc_mapl.'ntg   :call mmtemplates#core#EditTemplateFiles(g:Matlab_Templates,0)<CR>'
	endif
	exe ahead.'reread\ &templates<Tab>'.esc_mapl.'ntr           :call mmtemplates#core#ReadTemplates(g:Matlab_Templates,"reload","all")<CR>'
	"
	" styles
	call mmtemplates#core#CreateMenus ( 'g:Matlab_Templates', s:Matlab_RootMenu, 'do_styles',
				\ 'specials_menu', 'Snippets'	)
	"
	"-------------------------------------------------------------------------------
	" run
	"-------------------------------------------------------------------------------
	"
	let ahead = 'anoremenu <silent> '.s:Matlab_RootMenu.'.Run.'
	let vhead = 'vnoremenu <silent> '.s:Matlab_RootMenu.'.Run.'
	"
	exe ahead.'&check\ code<TAB>'.esc_mapl.'rk      :call Matlab_CheckCode()<CR>'
	exe ahead.'&ignore\ warning<TAB>'.esc_mapl.'ri  :call Matlab_IgnoreWarning()<CR>'
	exe ahead.'-Sep01-                              :'
	"
	exe ahead.'&settings<TAB>'.esc_mapl.'rs  :call Matlab_Settings(0)<CR>'
	"
	"-------------------------------------------------------------------------------
	" help
	"-------------------------------------------------------------------------------
	"
	let ahead = 'anoremenu <silent> '.s:Matlab_RootMenu.'.Help.'
	let vhead = 'vnoremenu <silent> '.s:Matlab_RootMenu.'.Help.'
	"
	exe ahead.'-Sep01-                                     :'
	exe ahead.'&help\ (Matlab-Support)<TAB>'.esc_mapl.'hs  :call Matlab_HelpPlugin()<CR>'
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
		anoremenu <silent> 40.1140 &Tools.Load\ Matlab\ Support   :call Matlab_AddMenus()<CR>
	elseif a:action == 'loading'
		aunmenu   <silent> &Tools.Load\ Matlab\ Support
		anoremenu <silent> 40.1140 &Tools.Unload\ Matlab\ Support :call Matlab_RemoveMenus()<CR>
	elseif a:action == 'unloading'
		aunmenu   <silent> &Tools.Unload\ Matlab\ Support
		anoremenu <silent> 40.1140 &Tools.Load\ Matlab\ Support   :call Matlab_AddMenus()<CR>
	endif
	"
endfunction    " ----------  end of function s:ToolMenu  ----------
"
"-------------------------------------------------------------------------------
" Matlab_AddMenus : Add menus.   {{{1
"-------------------------------------------------------------------------------
"
function! Matlab_AddMenus()
	if s:MenuVisible == 0
		" make sure the templates are loaded
		call s:SetupTemplates ()
		" initialize if not existing
		call s:ToolMenu ( 'loading' )
		call s:InitMenus ()
		" the menu is now visible
		let s:MenuVisible = 1
	endif
endfunction    " ----------  end of function Matlab_AddMenus  ----------
"
"-------------------------------------------------------------------------------
" Matlab_RemoveMenus : Remove menus.   {{{1
"-------------------------------------------------------------------------------
"
function! Matlab_RemoveMenus()
	if s:MenuVisible == 1
		" destroy if visible
		call s:ToolMenu ( 'unloading' )
		if has ( 'menu' )
			exe 'aunmenu <silent> '.s:Matlab_RootMenu
		endif
		" the menu is now invisible
		let s:MenuVisible = 0
	endif
endfunction    " ----------  end of function Matlab_RemoveMenus  ----------
"
"-------------------------------------------------------------------------------
" Matlab_Settings : Print the settings on the command line.   {{{1
"-------------------------------------------------------------------------------
"
function! Matlab_Settings( verbose )
	"
	if     s:MSWIN | let sys_name = 'Windows'
	elseif s:UNIX  | let sys_name = 'UN*X'
	else           | let sys_name = 'unknown' | endif
	"
	let glb_t_status = filereadable ( s:Matlab_GlbTemplateFile ) ? '' : ' (not readable)'
	let lcl_t_status = filereadable ( s:Matlab_LclTemplateFile ) ? '' : ' (not readable)'
	let mlint_status = executable( s:Matlab_MlintExecutable ) ? '' : ' (not executable)'
	"
	let	txt = " Matlab-Support settings\n\n"
	if exists ( 'g:Matlab_Templates' )
		let [ templ_style, msg ] = mmtemplates#core#Resource( g:Matlab_Templates, 'style' )
		"
		let txt .=
					\  '                   author :  "'.mmtemplates#core#ExpandText( g:Matlab_Templates, '|AUTHOR|'       )."\"\n"
					\ .'                authorref :  "'.mmtemplates#core#ExpandText( g:Matlab_Templates, '|AUTHORREF|'    )."\"\n"
					\ .'                    email :  "'.mmtemplates#core#ExpandText( g:Matlab_Templates, '|EMAIL|'        )."\"\n"
					\ .'             organization :  "'.mmtemplates#core#ExpandText( g:Matlab_Templates, '|ORGANIZATION|' )."\"\n"
					\ .'         copyright holder :  "'.mmtemplates#core#ExpandText( g:Matlab_Templates, '|COPYRIGHT|'    )."\"\n"
					\ .'                  licence :  "'.mmtemplates#core#ExpandText( g:Matlab_Templates, '|LICENSE|'      )."\"\n"
					\ .'           template style :  "'.templ_style."\"\n"
					\ ."\n"
	else
		let txt .=
					\  "                templates :  -not loaded- \n"
					\ ."\n"
	endif
	let txt .=
				\  '      plugin installation :  '.s:installation.' on '.sys_name."\n"
				\ .'    using template engine :  version '.g:Templates_Version." by Wolfgang Mehner\n"
				\ ."\n"
	if s:installation == 'system'
		let txt .= '     global template file :  '.s:Matlab_GlbTemplateFile.glb_t_status."\n"
	endif
	let txt .=
				\  '      local template file :  '.s:Matlab_LclTemplateFile.lcl_t_status."\n"
				\ .'       code snippets dir. :  '.s:Matlab_SnippetDir."\n"
				\ .'       mlint path and exe :  '.s:Matlab_MlintExecutable.mlint_status."\n"
	if a:verbose >= 1
		let	txt .= "\n"
					\ .'                mapleader :  "'.g:Matlab_MapLeader."\"\n"
					\ .'               load menus :  "'.s:Matlab_LoadMenus."\"\n"
	endif
	let txt .=
				\  "________________________________________________________________________________\n"
				\ ." Matlab-Support, Version ".g:Matlab_Version." / Wolfgang Mehner / wolfgang-mehner@web.de\n\n"
	"
	if a:verbose == 2
		split MatlabSupport_Settings.txt
		put = txt
	else
		echo txt
	endif
endfunction    " ----------  end of function Matlab_Settings  ----------
"
"-------------------------------------------------------------------------------
" Setup: Templates and menus.   {{{1
"-------------------------------------------------------------------------------
"
" tool menu entry
call s:ToolMenu ( 'setup' )
"
" load the menu right now?
if s:Matlab_LoadMenus == 'startup'
	call Matlab_AddMenus ()
endif
"
if has( 'autocmd' )
	autocmd FileType *
				\	if &filetype == 'matlab' && ! exists( 'g:Matlab_Templates' ) |
				\		if s:Matlab_LoadMenus == 'auto' | call Matlab_AddMenus () |
				\		else                            | call s:SetupTemplates () |
				\		endif |
				\	endif
	autocmd FileType *
				\	if &filetype == 'matlab' |
				\		call s:CreateMaps() |
				\	endif
endif
" }}}1
"-------------------------------------------------------------------------------
"
" =====================================================================================
"  vim: foldmethod=marker
