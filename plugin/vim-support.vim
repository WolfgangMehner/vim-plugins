"===============================================================================
"
"          File:  vim-support.vim
" 
"    Description:  Vim support     (VIM Version 7.0+)
"
"                  Write Vim-plugins by inserting comments, statements,
"                  variables and builtins.
" 
"   VIM Version:  7.0+
"        Author:  Dr. Fritz Mehner (fgm), mehner.fritz@fh-swf.de
"  Organization:  FH Südwestfalen, Iserlohn
"       Version:  see variable g:VimSupportVersion below
"       Created:  14.01.2012 10:49
"       License:  Copyright (c) 2012-2013, Dr. Fritz Mehner
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
if v:version < 700
  echohl WarningMsg | echo 'plugin vim-support.vim needs Vim version >= 7'| echohl None
  finish
endif
"
" Prevent duplicate loading:
"
if exists("g:VimSupportVersion") || &cp
 finish
endif
"
let g:VimSupportVersion= "2.1"                  " version number of this script; do not change
"
"===  FUNCTION  ================================================================
"          NAME:  GetGlobalSetting     {{{1
"   DESCRIPTION:  take over a global setting
"    PARAMETERS:  varname - variable to set
"       RETURNS:  
"===============================================================================
function! s:GetGlobalSetting ( varname )
	if exists ( 'g:'.a:varname )
		exe 'let s:'.a:varname.' = g:'.a:varname
	endif
endfunction    " ----------  end of function s:GetGlobalSetting  ----------
"
"===  FUNCTION  ================================================================
"          NAME:  ApplyDefaultSetting     {{{1
"   DESCRIPTION:  make a local setting global
"    PARAMETERS:  varname - variable to set
"       RETURNS:  
"===============================================================================
function! s:ApplyDefaultSetting ( varname )
	if ! exists ( 'g:'.a:varname )
		exe 'let g:'.a:varname.' = s:'.a:varname
	endif
endfunction    " ----------  end of function s:ApplyDefaultSetting  ----------
"
"------------------------------------------------------------------------------
" *** PLATFORM SPECIFIC ITEMS ***     {{{1
"------------------------------------------------------------------------------
let s:MSWIN =   has("win16") || has("win32") || has("win64") || has("win95")
"
let s:installation						= '*undefined*'
let s:Vim_GlobalTemplateFile	= ''
let s:Vim_GlobalTemplateDir		= ''
let s:Vim_LocalTemplateFile		= ''
let s:Vim_LocalTemplateDir		= ''
let s:Vim_FilenameEscChar 		= ''

if	s:MSWIN
  " ==========  MS Windows  ======================================================
	"
	" change '\' to '/' to avoid interpretation as escape character
	if match(	substitute( expand("<sfile>"), '\', '/', 'g' ), 
				\		substitute( expand("$HOME"),   '\', '/', 'g' ) ) == 0
		"
		" USER INSTALLATION ASSUMED
		let s:installation					= 'local'
		let s:plugin_dir  					= substitute( expand('<sfile>:p:h:h'), '\', '/', 'g' )
		let s:Vim_LocalTemplateFile	= s:plugin_dir.'/vim-support/templates/Templates'
		let s:Vim_LocalTemplateDir	= fnamemodify( s:Vim_LocalTemplateFile, ":p:h" ).'/'
	else
		"
		" SYSTEM WIDE INSTALLATION
		let s:installation					= 'system'
		let s:plugin_dir						= $VIM.'/vimfiles'
		let s:Vim_GlobalTemplateDir	= s:plugin_dir.'/vim-support/templates'
		let s:Vim_GlobalTemplateFile= s:Vim_GlobalTemplateDir.'/Templates'
		let s:Vim_LocalTemplateFile	= $HOME.'/vimfiles/vim-support/templates/Templates'
		let s:Vim_LocalTemplateDir	= fnamemodify( s:Vim_LocalTemplateFile, ":p:h" ).'/'
	endif
	"
  let s:Vim_FilenameEscChar 		= ''
	let s:Vim_Display    					= ''
	"
else
  " ==========  Linux/Unix  ======================================================
	"
	if match( expand("<sfile>"), resolve( expand("$HOME") ) ) == 0
		"
		" USER INSTALLATION ASSUMED
		let s:installation					= 'local'
		let s:plugin_dir 						= expand('<sfile>:p:h:h')
		let s:Vim_LocalTemplateFile	= s:plugin_dir.'/vim-support/templates/Templates'
		let s:Vim_LocalTemplateDir	= fnamemodify( s:Vim_LocalTemplateFile, ":p:h" ).'/'
	else
		"
		" SYSTEM WIDE INSTALLATION
		let s:installation					= 'system'
		let s:plugin_dir						= $VIM.'/vimfiles'
		let s:Vim_GlobalTemplateDir	= s:plugin_dir.'/vim-support/templates'
		let s:Vim_GlobalTemplateFile= s:Vim_GlobalTemplateDir.'/Templates'
		let s:Vim_LocalTemplateFile	= $HOME.'/.vim/vim-support/templates/Templates'
		let s:Vim_LocalTemplateDir	= fnamemodify( s:Vim_LocalTemplateFile, ":p:h" ).'/'
	endif
	"
  let s:Vim_FilenameEscChar 		= ' \%#[]'
	let s:Vim_Display							= $DISPLAY
	"
endif
"
let s:Vim_CodeSnippets  				= s:plugin_dir.'/vim-support/codesnippets/'
"
"----------------------------------------------------------------------
"  *** MODUL GLOBAL VARIABLES *** {{{1
"----------------------------------------------------------------------
"
let s:Vim_CreateMenusDelayed= 'yes'
let s:Vim_MenuVisible				= 'no'
let s:Vim_GuiSnippetBrowser = 'gui'             " gui / commandline
let s:Vim_LoadMenus         = 'yes'             " load the menus?
let s:Vim_RootMenu          = '&Vim'            " name of the root menu
let s:Vim_CreateMapsForHelp = 'no'              " create maps for modifiable help buffers as well
"
let s:Vim_MapLeader             = ''            " default: do not overwrite 'maplocalleader'
let s:Vim_LineEndCommColDefault = 49
let s:VimStartComment						= '"'
let s:Vim_Printheader   				= "%<%f%h%m%<  %=%{strftime('%x %X')}     Page %N"
let s:Vim_TemplateJumpTarget 		= '<+\i\++>\|{+\i\++}\|<-\i\+->\|{-\i\+-}'
"
call s:GetGlobalSetting ( 'Vim_GuiSnippetBrowser' )
call s:GetGlobalSetting ( 'Vim_LoadMenus' )
call s:GetGlobalSetting ( 'Vim_RootMenu' )
call s:GetGlobalSetting ( 'Vim_CreateMapsForHelp' )
call s:GetGlobalSetting ( 'Vim_Printheader' )
call s:GetGlobalSetting ( 'Vim_LocalTemplateFile' )
call s:GetGlobalSetting ( 'Vim_GlobalTemplateFile' )
call s:GetGlobalSetting ( 'Vim_CodeSnippets' )
call s:GetGlobalSetting ( 'Vim_CreateMenusDelayed' )
call s:GetGlobalSetting ( 'Vim_LineEndCommColDefault' )

call s:ApplyDefaultSetting ( 'Vim_MapLeader'    )
"
let s:Vim_Printheader  = escape( s:Vim_Printheader, ' %' )
"
"===  FUNCTION  ================================================================
"          NAME:  SaveOption     {{{1
"   DESCRIPTION:  save a Vim option
"    PARAMETERS:  option - option name
"                 ...    - characters to be escaped (optional)
"       RETURNS:  
"===============================================================================
function! s:SaveOption ( option, ... )
	exe 'let escaped =&'.a:option
	if a:0 > 0
		let escaped = escape( escaped, a:1 )
	endif
	exe 'let s:'.a:option.'_saved = "'.escaped.'"'
endfunction " ---------- end of function s:SaveOption ----------
"
"===  FUNCTION  ================================================================
"          NAME:  RestoreOption     {{{1
"   DESCRIPTION:  restore a Vim option
"    PARAMETERS:  option - option to be restored
"       RETURNS:  
"===============================================================================
function! s:RestoreOption ( option )
	exe 'let saved = s:'.a:option.'_saved'
	exe ':setlocal '.a:option.'="'.saved.'"'
endfunction " ---------- end of function s:RestoreOption ----------
"
"===  FUNCTION  ================================================================
"          NAME:  Vim_Input     {{{1
"   DESCRIPTION:  Input after a highlighted prompt
"    PARAMETERS:  prompt       - prompt string
"                 defaultreply - default reply
"                 ...          - completion
"       RETURNS:  reply
"===============================================================================
function! Vim_Input ( prompt, defaultreply, ... )
	echohl Search																					" highlight prompt
	call inputsave()																			" preserve typeahead
	if a:0 == 0 || empty(a:1)
		let retval	=input( a:prompt, a:defaultreply )
	else
		let retval	=input( a:prompt, a:defaultreply, a:1 )
	endif
	call inputrestore()																		" restore typeahead
	echohl None																						" reset highlighting
	let retval  = substitute( retval, '^\s\+', '', '' )		" remove leading whitespaces
	let retval  = substitute( retval, '\s\+$', '', '' )		" remove trailing whitespaces
	return retval
endfunction    " ----------  end of function Vim_Input ----------
"
"===  FUNCTION  ================================================================
"          NAME:  Vim_AdjustLineEndComm     {{{1
"   DESCRIPTION:  adjust end-of-line comments
"    PARAMETERS:  -
"       RETURNS:  
"===============================================================================
function! Vim_AdjustLineEndComm ( ) range
	"
	" patterns to ignore when adjusting line-end comments (maybe incomplete):
	let	s:AlignRegex	= [
				\	'\([^"]*"[^"]*"\)\+' ,
				\	]

	if !exists("b:Vim_LineEndCommentColumn")
		let	b:Vim_LineEndCommentColumn	= s:Vim_LineEndCommColDefault
	endif

	let save_cursor = getpos(".")

	let	save_expandtab	= &expandtab
	exe	":set expandtab"

	let	linenumber	= a:firstline
	exe ":".a:firstline

	while linenumber <= a:lastline
		let	line= getline(".")

		let idx1	= 1 + match( line, '\s*".*$', 0 )
		let idx2	= 1 + match( line,    '".*$', 0 )

		" comment with leading whitespaces left unchanged
		if     match( line, '^\s*"' ) == 0
			let idx1	= 0
			let idx2	= 0
		endif

		for regex in s:AlignRegex
			if match( line, regex ) > -1
				let start	= matchend( line, regex )
				let idx1	= 1 + match( line, '\s*".*$', start )
				let idx2	= 1 + match( line,    '".*$', start )
				break
			endif
		endfor

		let	ln	= line(".")
		call setpos(".", [ 0, ln, idx1, 0 ] )
		let vpos1	= virtcol(".")
		call setpos(".", [ 0, ln, idx2, 0 ] )
		let vpos2	= virtcol(".")

		if   ! (   vpos2 == b:Vim_LineEndCommentColumn
					\	|| vpos1 > b:Vim_LineEndCommentColumn
					\	|| idx2  == 0 )

			exe ":.,.retab"
			" insert some spaces
			if vpos2 < b:Vim_LineEndCommentColumn
				let	diff	= b:Vim_LineEndCommentColumn-vpos2
				call setpos(".", [ 0, ln, vpos2, 0 ] )
				let	@"	= ' '
				exe "normal	".diff."P"
			end

			" remove some spaces
			if vpos1 < b:Vim_LineEndCommentColumn && vpos2 > b:Vim_LineEndCommentColumn
				let	diff	= vpos2 - b:Vim_LineEndCommentColumn
				call setpos(".", [ 0, ln, b:Vim_LineEndCommentColumn, 0 ] )
				exe "normal	".diff."x"
			end

		end
		let linenumber=linenumber+1
		normal j
	endwhile
	" restore tab expansion settings and cursor position
	let &expandtab	= save_expandtab
	call setpos('.', save_cursor)

endfunction		" ---------- end of function  Vim_AdjustLineEndComm  ----------
"
"===  FUNCTION  ================================================================
"          NAME:  Vim_GetLineEndCommCol     {{{1
"   DESCRIPTION:  get end-of-line comment position
"    PARAMETERS:  -
"       RETURNS:  
"===============================================================================
function! Vim_GetLineEndCommCol ()
	let actcol	= virtcol(".")
	if actcol+1 == virtcol("$")
		let	b:Vim_LineEndCommentColumn	= ''
		while match( b:Vim_LineEndCommentColumn, '^\s*\d\+\s*$' ) < 0
			let b:Vim_LineEndCommentColumn = Vim_Input( 'start line-end comment at virtual column : ', actcol, '' )
		endwhile
	else
		let	b:Vim_LineEndCommentColumn	= virtcol(".")
	endif
  echomsg "line end comments will start at column  ".b:Vim_LineEndCommentColumn
endfunction		" ---------- end of function  Vim_GetLineEndCommCol  ----------
"
"===  FUNCTION  ================================================================
"          NAME:  Vim_EndOfLineComment     {{{1
"   DESCRIPTION:  single end-of-line comment
"    PARAMETERS:  -
"       RETURNS:  
"===============================================================================
function! Vim_EndOfLineComment ( ) range
	if !exists("b:Vim_LineEndCommentColumn")
		let	b:Vim_LineEndCommentColumn	= s:Vim_LineEndCommColDefault
	endif
	" ----- trim whitespaces -----
	exe a:firstline.','.a:lastline.'s/\s*$//'

	for line in range( a:lastline, a:firstline, -1 )
		let linelength	= virtcol( [line, "$"] ) - 1
		let	diff				= 1
		if linelength < b:Vim_LineEndCommentColumn
			let diff	= b:Vim_LineEndCommentColumn -1 -linelength
		endif
		exe 'normal!	'.diff.'A '
		exe 'normal!	A'.s:VimStartComment.' '
		startinsert!
		if line > a:firstline
			normal k
		endif
	endfor
endfunction		" ---------- end of function  Vim_EndOfLineComment  ----------
"
"===  FUNCTION  ================================================================
"          NAME:  Vim_MultiLineEndComments     {{{1
"   DESCRIPTION:  multiple end-of-line comment
"    PARAMETERS:  -
"       RETURNS:  
"===============================================================================
function! Vim_MultiLineEndComments ( )
	"
  if !exists("b:Vim_LineEndCommentColumn")
		let	b:Vim_LineEndCommentColumn	= s:Vim_LineEndCommColDefault
  endif
	"
	let pos0	= line("'<")
	let pos1	= line("'>")
	"
	" ----- trim whitespaces -----
  exe pos0.','.pos1.'s/\s*$//'
	"
	" ----- find the longest line -----
	let maxlength	= max( map( range(pos0, pos1), "virtcol([v:val, '$'])" ) )
	let	maxlength	= max( [b:Vim_LineEndCommentColumn, maxlength+1] )
	"
	" ----- fill lines with blanks -----
	for linenumber in range( pos0, pos1 )
		exe ":".linenumber
		if getline(linenumber) !~ '^\s*$'
			let diff	= maxlength - virtcol("$")
			exe 'normal	'.diff.'A '
			exe 'normal!	A'.s:VimStartComment.' '
		endif
	endfor
	"
	" ----- back to the begin of the marked block -----
	stopinsert
	normal '<$
	if match( getline("."), '\/\/\s*$' ) < 0
		if search( '\/\*', 'bcW', line(".") ) > 1
			normal l
		endif
		let save_cursor = getpos(".")
		if getline(".")[save_cursor[2]+1] == ' '
			normal l
		endif
	else
		normal $
	endif
endfunction		" ---------- end of function  Vim_MultiLineEndComments  ----------
"
"===  FUNCTION  ================================================================
"          NAME:  Vim_CodeComment     {{{1
"   DESCRIPTION:  Code -> Comment
"    PARAMETERS:  -
"       RETURNS:  
"===============================================================================
function! Vim_CodeComment() range
	" add '" ' at the beginning of the lines
	for line in range( a:firstline, a:lastline )
		exe line.'s/^/" /'
	endfor
endfunction    " ----------  end of function Vim_CodeComment  ----------
"
"===  FUNCTION  ================================================================
"          NAME:  Vim_CommentCode     {{{1
"   DESCRIPTION:  Comment -> Code
"    PARAMETERS:  toggle - 0 : uncomment, 1 : toggle comment
"       RETURNS:  
"===============================================================================
function! Vim_CommentCode( toggle ) range
	for i in range( a:firstline, a:lastline )
		if getline( i ) =~ '^" '
			silent exe i.'s/^" //'
		elseif getline( i ) =~ '^"'
			silent exe i.'s/^"//'
		elseif a:toggle
			silent exe i.'s/^/" /'
		endif
	endfor
	"
endfunction    " ----------  end of function Vim_CommentCode  ----------
"
"===  FUNCTION  ================================================================
"          NAME:  GetFunctionParameters     {{{1
"   DESCRIPTION:  get function name and parameters
"    PARAMETERS:  fun_line - function head
"       RETURNS:  scope     - The scope. (string, 's', 'g' or empty) 
"                 fun_name  - The name of the function (string, id without the scope)
"                 param_str - Names of the parameters. (list of strings)
"                 ellipsis  - Has an ellipsis? (boolean)
"                 range     - Has a range? (boolean)
"===============================================================================
function! s:GetFunctionParameters ( fun_line )
	"
	" 1. function names with '.' (dictionaries) and '#' (autoload)
	" 2. parameter list with spaces, tabs and optional ellipsis
	let fun_id       = '\([a-zA-Z][a-zA-Z0-9_\.#]*\)'
	let params       = '\s*\([a-zA-Z0-9_, \t]*\)\(\.\.\.\)\?\s*'
	"
	" apparently every prefix of 'function' is allowed,
	" as long as it is at least two characters long
	let mlist = matchlist ( a:fun_line, '^\s*:\?\s*fu\%[nction]!\?\s*\([sg]:\)\?'.fun_id.'\s*('.params.')\s*\(range\)\?' )
	"
	" no function?
	if empty( mlist )
		return []
	endif
	"
	" found a function!
	let [ scope, fun_name, param_str, ellipsis, range ] = mlist[1:5]
	"
	let param_str  = substitute ( param_str, '\s*$', '', '' )
	let param_list = split ( param_str, '\s*,\s*' )
	"
	let scope    = scope[0]
	let ellipsis = ! empty ( ellipsis )
	let range    = ! empty ( range )
	"
	if empty ( fun_name )
		return []
	else
		return [ scope, fun_name, param_list, ellipsis, range ]
	endif
	"
endfunction    " ----------  end of function s:GetFunctionParameters  ----------
"
"===  FUNCTION  ================================================================
"          NAME:  Vim_FunctionComment {{{1
"   DESCRIPTION:  Add a comment to a function.
"    PARAMETERS:  -
"       RETURNS:  
"===============================================================================
function! Vim_FunctionComment () range
	"
 " :TODO:11.08.2013 19:02:wm: multiple lines (is that possible?): remove continuation '\'
	let	linestring = getline(a:firstline)
	for i in range(a:firstline+1,a:lastline)
		let	linestring = linestring.' '.getline(i)
	endfor
	"
	let res_list = s:GetFunctionParameters( linestring )
	"
	if empty( res_list )
		echo 'No function found.'
		return
	endif
	"
	echo res_list
	"
	" get all the parts
	let [ scope, fun_name, param_list, ellipsis, range ] = res_list
	let placement = 'above'
	"
	if ellipsis
		call add ( param_list, '...' )
	endif
	"
	call mmtemplates#core#InsertTemplate ( g:Vim_Templates, 'Comments.function',
				\ '|FUNCTION_NAME|', fun_name, '|PARAMETERS|', param_list,
				\ 'placement', placement, 'range', a:firstline, a:lastline )
	"
endfunction    " ----------  end of function Vim_FunctionComment  ----------
"
"===  FUNCTION  ================================================================
"          NAME:  Vim_Help     {{{1
"   DESCRIPTION:  read help for word under cursor
"    PARAMETERS:  -
"       RETURNS:  
"===============================================================================
function! Vim_Help ()
	let  word = expand("<cword>")
	if word=='' || match(word, '^\s' )==0
			exe ':help function-list'
	else
		" do we have a function call ?
		if match( getline('.'), word.'\s*([^)]*)'  ) >= 0
			exe ':help '.word.'()'
		else
			exe ':help '.word
		endif
	endif
endfunction    " ----------  end of function Vim_Help  ----------
"
"------------------------------------------------------------------------------
"  Vim_HelpVimSupport : help vimsupport     {{{1
"------------------------------------------------------------------------------
function! Vim_HelpVimSupport ()
	try
		:help vimsupport
	catch
		exe ':helptags '.s:plugin_dir.'/doc'
		:help vimsupport
	endtry
endfunction    " ----------  end of function Vim_HelpVimSupport ----------
"
"===  FUNCTION  ================================================================
"          NAME:  Vim_RereadTemplates     {{{1
"   DESCRIPTION:  Reread the templates. Also set the character which starts
"                 the comments in the template files.
"    PARAMETERS:  -
"       RETURNS:  
"===============================================================================
function! g:Vim_RereadTemplates ( displaymsg )
	"
	"
	"-------------------------------------------------------------------------------
	" SETUP TEMPLATE LIBRARY
	"-------------------------------------------------------------------------------
 	let g:Vim_Templates = mmtemplates#core#NewLibrary ()
	"
	" mapleader
	if empty ( g:Vim_MapLeader )
		call mmtemplates#core#Resource ( g:Vim_Templates, 'set', 'property', 'Templates::Mapleader', '\' )
	else
		call mmtemplates#core#Resource ( g:Vim_Templates, 'set', 'property', 'Templates::Mapleader', g:Vim_MapLeader )
	endif
	"
	" map: choose style
	call mmtemplates#core#Resource ( g:Vim_Templates, 'set', 'property', 'Templates::EditTemplates::Map',   'ntl' )
	call mmtemplates#core#Resource ( g:Vim_Templates, 'set', 'property', 'Templates::RereadTemplates::Map', 'ntr' )
	call mmtemplates#core#Resource ( g:Vim_Templates, 'set', 'property', 'Templates::ChooseStyle::Map',     'nts' )
	"
	" syntax: comments
	call mmtemplates#core#ChangeSyntax ( g:Vim_Templates, 'comment', '§' )
	let s:Vim_TemplateJumpTarget = mmtemplates#core#Resource ( g:Vim_Templates, "jumptag" )[0]
	"
	let	messsage = ''
 	"
	if s:installation == 'system'
		"-------------------------------------------------------------------------------
		" SYSTEM INSTALLATION
		"-------------------------------------------------------------------------------
		if filereadable( s:Vim_GlobalTemplateFile )
			call mmtemplates#core#ReadTemplates ( g:Vim_Templates, 'load', s:Vim_GlobalTemplateFile )
		else
			echomsg "Global template file '".s:Vim_GlobalTemplateFile."' not readable."
			return
		endif
		let	messsage	= "Templates read from '".s:Vim_GlobalTemplateFile."'"
		"
		"-------------------------------------------------------------------------------
		" handle local template files
		"-------------------------------------------------------------------------------
		if finddir( s:Vim_LocalTemplateDir ) == ''
			" try to create a local template directory
			if exists("*mkdir")
				try 
					call mkdir( s:Vim_LocalTemplateDir, "p" )
				catch /.*/
				endtry
			endif
		endif

		if isdirectory( s:Vim_LocalTemplateDir ) && !filereadable( s:Vim_LocalTemplateFile )
			" write a default local template file
			let template	= [	]
			let sample_template_file	= fnamemodify( s:Vim_GlobalTemplateDir, ':h' ).'/rc/sample_template_file'
			if filereadable( sample_template_file )
				for line in readfile( sample_template_file )
					call add( template, line )
				endfor
				call writefile( template, s:Vim_LocalTemplateFile )
			endif
		endif
		"
		if filereadable( s:Vim_LocalTemplateFile )
			call mmtemplates#core#ReadTemplates ( g:Vim_Templates, 'load', s:Vim_LocalTemplateFile )
			let messsage	= messsage." and '".s:Vim_LocalTemplateFile."'"
			if mmtemplates#core#ExpandText( g:Vim_Templates, '|AUTHOR|' ) == 'YOUR NAME'
				echomsg "Please set your personal details in file '".s:Vim_LocalTemplateFile."'."
			endif
		endif
		"
	else
		"-------------------------------------------------------------------------------
		" LOCAL INSTALLATION
		"-------------------------------------------------------------------------------
		if filereadable( s:Vim_LocalTemplateFile )
			call mmtemplates#core#ReadTemplates ( g:Vim_Templates, 'load', s:Vim_LocalTemplateFile )
			let	messsage	= "Templates read from '".s:Vim_LocalTemplateFile."'"
		else
			echomsg "Local template file '".s:Vim_LocalTemplateFile."' not readable." 
			return
		endif
		"
	endif
	if a:displaymsg == 'yes'
		echomsg messsage.'.'
	endif

endfunction    " ----------  end of function Vim_RereadTemplates  ----------
"
"===  FUNCTION  ================================================================
"          NAME:  InitMenus     {{{1
"   DESCRIPTION:  Initialize menus.
"    PARAMETERS:  -
"       RETURNS:  
"===============================================================================
function! s:InitMenus()
	"
	if ! has ( 'menu' )
		return
	endif
	"
	" Preparation
	call mmtemplates#core#CreateMenus ( 'g:Vim_Templates', s:Vim_RootMenu, 'do_reset' )
	"
	" get the mapleader (correctly escaped)
	let [ esc_mapl, err ] = mmtemplates#core#Resource ( g:Vim_Templates, 'escaped_mapleader' )
	"
	exe 'amenu '.s:Vim_RootMenu.'.Vim  <Nop>'
	exe 'amenu '.s:Vim_RootMenu.'.-Sep00- <Nop>'
	"
	" Comments
	"
 	"-------------------------------------------------------------------------------
	" menu headers
	"-------------------------------------------------------------------------------
	"
	call mmtemplates#core#CreateMenus ( 'g:Vim_Templates', s:Vim_RootMenu, 'sub_menu', '&Comments', 'priority', 500 )
	" the other, automatically created menus go here; their priority is the standard priority 500
	call mmtemplates#core#CreateMenus ( 'g:Vim_Templates', s:Vim_RootMenu, 'sub_menu', 'S&nippets', 'priority', 600 )
	call mmtemplates#core#CreateMenus ( 'g:Vim_Templates', s:Vim_RootMenu, 'sub_menu', '&Run'     , 'priority', 800 )
	call mmtemplates#core#CreateMenus ( 'g:Vim_Templates', s:Vim_RootMenu, 'sub_menu', '&Help'    , 'priority', 900 )
	"
	"-------------------------------------------------------------------------------
	" comments
 	"-------------------------------------------------------------------------------
	"
	let  head =  'noremenu <silent> '.s:Vim_RootMenu.'.Comments.'
	let ahead = 'anoremenu <silent> '.s:Vim_RootMenu.'.Comments.'
	let vhead = 'vnoremenu <silent> '.s:Vim_RootMenu.'.Comments.'
	"
	exe ahead.'end-of-&line\ comment<Tab>'.esc_mapl.'cl                    :call Vim_EndOfLineComment()<CR>'
	exe vhead.'end-of-&line\ comment<Tab>'.esc_mapl.'cl               <Esc>:call Vim_MultiLineEndComments()<CR>A'
	exe ahead.'ad&just\ end-of-line\ com\.<Tab>'.esc_mapl.'cj              :call Vim_AdjustLineEndComm()<CR>'
	exe vhead.'ad&just\ end-of-line\ com\.<Tab>'.esc_mapl.'cj              :call Vim_AdjustLineEndComm()<CR>'
	exe  head.'&set\ end-of-line\ com\.\ col\.<Tab>'.esc_mapl.'cs     <Esc>:call Vim_GetLineEndCommCol()<CR>'
	"
	exe ahead.'&comment<TAB>'.esc_mapl.'cc		:call Vim_CodeComment()<CR>'
	exe vhead.'&comment<TAB>'.esc_mapl.'cc		:call Vim_CodeComment()<CR>'
	exe ahead.'&uncomment<TAB>'.esc_mapl.'cu	:call Vim_CommentCode(0)<CR>'
	exe vhead.'&uncomment<TAB>'.esc_mapl.'cu	:call Vim_CommentCode(0)<CR>'
	exe ahead.'-Sep00-						<Nop>'
	"
	exe ahead.'&function\ description\ (auto)<TAB>'.esc_mapl.'ca	     :call Vim_FunctionComment()<CR>'
	exe vhead.'&function\ description\ (auto)<TAB>'.esc_mapl.'ca	<Esc>:call Vim_FunctionComment()<CR>'
	exe ahead.'-Sep02-												             <Nop>'
	"
 	"-------------------------------------------------------------------------------
	" generate menus from the templates
 	"-------------------------------------------------------------------------------
	call mmtemplates#core#CreateMenus ( 'g:Vim_Templates', s:Vim_RootMenu, 'do_templates' )
	"
	"-------------------------------------------------------------------------------
	" snippets
	"-------------------------------------------------------------------------------
	"
	if !empty(s:Vim_CodeSnippets)
		"
		exe "amenu  <silent> ".s:Vim_RootMenu.'.S&nippets.&read\ code\ snippet<Tab>'.esc_mapl.'nr       :call Vim_CodeSnippet("r")<CR>'
		exe "imenu  <silent> ".s:Vim_RootMenu.'.S&nippets.&read\ code\ snippet<Tab>'.esc_mapl.'nr  <C-C>:call Vim_CodeSnippet("r")<CR>'
		exe "amenu  <silent> ".s:Vim_RootMenu.'.S&nippets.&write\ code\ snippet<Tab>'.esc_mapl.'nw      :call Vim_CodeSnippet("w")<CR>'
		exe "vmenu  <silent> ".s:Vim_RootMenu.'.S&nippets.&write\ code\ snippet<Tab>'.esc_mapl.'nw <C-C>:call Vim_CodeSnippet("wv")<CR>'
		exe "imenu  <silent> ".s:Vim_RootMenu.'.S&nippets.&write\ code\ snippet<Tab>'.esc_mapl.'nw <C-C>:call Vim_CodeSnippet("w")<CR>'
		exe "amenu  <silent> ".s:Vim_RootMenu.'.S&nippets.&edit\ code\ snippet<Tab>'.esc_mapl.'ne       :call Vim_CodeSnippet("e")<CR>'
		exe "imenu  <silent> ".s:Vim_RootMenu.'.S&nippets.&edit\ code\ snippet<Tab>'.esc_mapl.'ne  <C-C>:call Vim_CodeSnippet("e")<CR>'
		exe "amenu  <silent> ".s:Vim_RootMenu.'.S&nippets.-SepSnippets-                       :'
		"
	endif
	"
	call mmtemplates#core#CreateMenus ( 'g:Vim_Templates', s:Vim_RootMenu, 'do_specials', 'specials_menu', 'S&nippets' )
	"
	"-------------------------------------------------------------------------------
	" run
	"-------------------------------------------------------------------------------
	" 
	let ahead = 'amenu <silent> '.s:Vim_RootMenu.'.Run.'
	let vhead = 'vmenu <silent> '.s:Vim_RootMenu.'.Run.'
	"
	if	s:MSWIN
		exe ahead.'&hardcopy\ to\ printer<Tab>'.esc_mapl.'rh        <C-C>:call Vim_Hardcopy("n")<CR>'
		exe vhead.'&hardcopy\ to\ printer<Tab>'.esc_mapl.'rh        <C-C>:call Vim_Hardcopy("v")<CR>'
	else
		exe ahead.'&hardcopy\ to\ FILENAME\.ps<Tab>'.esc_mapl.'rh   <C-C>:call Vim_Hardcopy("n")<CR>'
		exe vhead.'&hardcopy\ to\ FILENAME\.ps<Tab>'.esc_mapl.'rh   <C-C>:call Vim_Hardcopy("v")<CR>'
	endif
	"
	exe ahead.'plugin\ &settings<Tab>'.esc_mapl.'rs                 :call Vim_Settings()<CR>'
	"
 	"-------------------------------------------------------------------------------
 	" help
 	"-------------------------------------------------------------------------------
 	"
	let ahead = 'amenu <silent> '.s:Vim_RootMenu.'.Help.'
	let ihead = 'imenu <silent> '.s:Vim_RootMenu.'.Help.'
	"
  exe ahead.'&keyword\ help<Tab>'.esc_mapl.'hk\ \ <S-F1>    :call Vim_Help()<CR>'
	exe ahead.'-SEP1- :'
	exe ahead.'&help\ (Vim-Support)<Tab>'.esc_mapl.'hp        :call Vim_HelpVimSupport()<CR>'
	"
endfunction    " ----------  end of function s:InitMenus  ----------
"
"===  FUNCTION  ================================================================
"          NAME:  Vim_JumpForward     {{{1
"   DESCRIPTION:  Jump to the next target, otherwise behind the current string.
"    PARAMETERS:  -
"       RETURNS:  empty string
"===============================================================================
function! Vim_JumpForward ()
  let match	= search( s:Vim_TemplateJumpTarget, 'c' )
	if match > 0
		" remove the target
		call setline( match, substitute( getline('.'), s:Vim_TemplateJumpTarget, '', '' ) )
	else
		" try to jump behind parenthesis or strings 
		call search( "[\]})\"'`]", 'W' )
		normal l
	endif
	return ''
endfunction    " ----------  end of function Vim_JumpForward  ----------

"===  FUNCTION  ================================================================
"          NAME:  Vim_CodeSnippet     {{{1
"   DESCRIPTION:  read / edit code snippet
"    PARAMETERS:  mode - r : read, e : edit, w : write file, 
"                        wv : write marked area
"       RETURNS:  
"===============================================================================
function! Vim_CodeSnippet(mode)

	if isdirectory(s:Vim_CodeSnippets)
		"
		" read snippet file, put content below current line and indent
		"
		if a:mode == "r"
			if has("browse") && s:Vim_GuiSnippetBrowser == 'gui'
				let	l:snippetfile=browse(0,"read a code snippet",s:Vim_CodeSnippets,"")
			else
				let	l:snippetfile=input("read snippet ", s:Vim_CodeSnippets, "file" )
			endif
			if filereadable(l:snippetfile)
				let	linesread= line("$")
				let l:old_cpoptions	= &cpoptions " Prevent the alternate buffer from being set to this files
				setlocal cpoptions-=a
				:execute "read ".l:snippetfile
				let &cpoptions	= l:old_cpoptions		" restore previous options
				let	linesread= line("$")-linesread-1
				if linesread>=0 && match( l:snippetfile, '\.\(ni\|noindent\)$' ) < 0
				endif
			endif
			if line(".")==2 && getline(1)=~"^$"
				silent exe ":1,1d"
			endif
		endif
		"
		" update current buffer / split window / edit snippet file
		"
		if a:mode == "e"
			if has("browse") && s:Vim_GuiSnippetBrowser == 'gui'
				let	l:snippetfile	= browse(0,"edit a code snippet",s:Vim_CodeSnippets,"")
			else
				let	l:snippetfile=input("edit snippet ", s:Vim_CodeSnippets, "file" )
			endif
			if !empty(l:snippetfile)
				:execute "update! | split | edit ".l:snippetfile
			endif
		endif
		"
		" write whole buffer into snippet file
		"
		if a:mode == "w" || a:mode == "wv"
			if has("browse") && s:Vim_GuiSnippetBrowser == 'gui'
				let	l:snippetfile	= browse(0,"write a code snippet",s:Vim_CodeSnippets,"")
			else
				let	l:snippetfile=input("write snippet ", s:Vim_CodeSnippets, "file" )
			endif
			if !empty(l:snippetfile)
				if filereadable(l:snippetfile)
					if confirm("File ".l:snippetfile." exists ! Overwrite ? ", "&Cancel\n&No\n&Yes") != 3
						return
					endif
				endif
				if a:mode == "w"
					:execute ":write! ".l:snippetfile
				else
					:execute ":*write! ".l:snippetfile
				endif
			endif
		endif

	else
		echo "code snippet directory ".s:Vim_CodeSnippets." does not exist (please create it)"
	endif
endfunction    " ----------  end of function Vim_CodeSnippets  ----------
"
"===  FUNCTION  ================================================================
"          NAME:  Vim_Hardcopy     {{{1
"   DESCRIPTION:  Make PostScript document from current buffer
"                 MSWIN : display printer dialog
"    PARAMETERS:  mode - n : print complete buffer, v : print marked area
"       RETURNS:  
"===============================================================================
function! Vim_Hardcopy (mode)
  let outfile = expand("%")
  if outfile == ""
    redraw
    echohl WarningMsg | echo " no file name " | echohl None
    return
  endif
	let outdir	= getcwd()
	if filewritable(outdir) != 2
		let outdir	= $HOME
	endif
	if  !s:MSWIN
		let outdir	= outdir.'/'
	endif
  let old_printheader=&printheader
  exe  ':set printheader='.s:Vim_Printheader
  " ----- normal mode ----------------
  if a:mode=="n"
    silent exe  'hardcopy > '.outdir.outfile.'.ps'
    if  !s:MSWIN
      echo 'file "'.outfile.'" printed to "'.outdir.outfile.'.ps"'
    endif
  endif
  " ----- visual mode ----------------
  if a:mode=="v"
    silent exe  "*hardcopy > ".outdir.outfile.".ps"
    if  !s:MSWIN
      echo 'file "'.outfile.'" (lines '.line("'<").'-'.line("'>").') printed to "'.outdir.outfile.'.ps"'
    endif
  endif
  exe  ':set printheader='.escape( old_printheader, ' %' )
endfunction   " ---------- end of function  Vim_Hardcopy  ----------
"
"===  FUNCTION  ================================================================
"          NAME:  CreateAdditionalMaps     {{{1
"   DESCRIPTION:  create additional maps
"    PARAMETERS:  -
"       RETURNS:  
"===============================================================================
function! s:CreateAdditionalMaps ()
	"
	"-------------------------------------------------------------------------------
	" settings - local leader
	"-------------------------------------------------------------------------------
	if ! empty ( g:Vim_MapLeader )
		if exists ( 'g:maplocalleader' )
			let ll_save = g:maplocalleader
		endif
		let g:maplocalleader = g:Vim_MapLeader
	endif
	"
	"-------------------------------------------------------------------------------
	" comments
	"-------------------------------------------------------------------------------
	nnoremap    <buffer>  <silent>  <LocalLeader>cl         :call Vim_EndOfLineComment()<CR>
	inoremap    <buffer>  <silent>  <LocalLeader>cl    <C-C>:call Vim_EndOfLineComment()<CR>
	vnoremap    <buffer>  <silent>  <LocalLeader>cl    <C-C>:call Vim_MultiLineEndComments()<CR>A
	"
	nnoremap    <buffer>  <silent>  <LocalLeader>cj         :call Vim_AdjustLineEndComm()<CR>
	inoremap    <buffer>  <silent>  <LocalLeader>cj    <C-C>:call Vim_AdjustLineEndComm()<CR>
	vnoremap    <buffer>  <silent>  <LocalLeader>cj    <C-C>:call Vim_AdjustLineEndComm()<CR>
	"
	nnoremap    <buffer>  <silent>  <LocalLeader>cs         :call Vim_GetLineEndCommCol()<CR>
	inoremap    <buffer>  <silent>  <LocalLeader>cs    <C-C>:call Vim_GetLineEndCommCol()<CR>
	vnoremap    <buffer>  <silent>  <LocalLeader>cs    <C-C>:call Vim_GetLineEndCommCol()<CR>
	"
	nnoremap    <buffer>  <silent>  <LocalLeader>cc         :call Vim_CodeComment()<CR>
	inoremap    <buffer>  <silent>  <LocalLeader>cc    <C-C>:call Vim_CodeComment()<CR>
	vnoremap    <buffer>  <silent>  <LocalLeader>cc         :call Vim_CodeComment()<CR>
	"
	nnoremap    <buffer>  <silent>  <LocalLeader>cu         :call Vim_CommentCode(0)<CR>
	inoremap    <buffer>  <silent>  <LocalLeader>cu    <C-C>:call Vim_CommentCode(0)<CR>
	vnoremap    <buffer>  <silent>  <LocalLeader>cu         :call Vim_CommentCode(0)<CR>
	"
  nnoremap    <buffer>  <silent>  <LocalLeader>ca         :call Vim_FunctionComment()<CR>
  inoremap    <buffer>  <silent>  <LocalLeader>ca    <Esc>:call Vim_FunctionComment()<CR>
	"
	"-------------------------------------------------------------------------------
	" snippets
	"-------------------------------------------------------------------------------
	 noremap    <buffer>  <silent>  <LocalLeader>nr         :call Vim_CodeSnippet("r")<CR>
	 noremap    <buffer>  <silent>  <LocalLeader>nw         :call Vim_CodeSnippet("w")<CR>
	vnoremap    <buffer>  <silent>  <LocalLeader>nw    <Esc>:call Vim_CodeSnippet("wv")<CR>
	 noremap    <buffer>  <silent>  <LocalLeader>ne         :call Vim_CodeSnippet("e")<CR>
	"
	inoremap    <buffer>  <silent>  <LocalLeader>nr    <Esc>:call Vim_CodeSnippet("r")<CR>
	inoremap    <buffer>  <silent>  <LocalLeader>nw    <Esc>:call Vim_CodeSnippet("w")<CR>
	inoremap    <buffer>  <silent>  <LocalLeader>ne    <Esc>:call Vim_CodeSnippet("e")<CR>
	"
	"-------------------------------------------------------------------------------
	"   run
	"-------------------------------------------------------------------------------
	nnoremap    <buffer>  <silent>  <LocalLeader>rh        :call Vim_Hardcopy("n")<CR>
	vnoremap    <buffer>  <silent>  <LocalLeader>rh   <C-C>:call Vim_Hardcopy("v")<CR>
	"
	"-------------------------------------------------------------------------------
	"   help
	"-------------------------------------------------------------------------------
	nnoremap    <buffer>  <silent>  <LocalLeader>rs         :call Vim_Settings()<CR>
	nnoremap    <buffer>  <silent>  <LocalLeader>hk          :call Vim_Help()<CR>
	inoremap    <buffer>  <silent>  <LocalLeader>hk     <C-C>:call Vim_Help()<CR>
	 noremap    <buffer>  <silent>  <LocalLeader>hp         :call Vim_HelpVimSupport()<CR>
	inoremap    <buffer>  <silent>  <LocalLeader>hp    <C-C>:call Vim_HelpVimSupport()<CR>
	" 
	if has("gui_running")
		nnoremap    <buffer>  <silent>  <S-F1>             :call Vim_Help()<CR>
		inoremap    <buffer>  <silent>  <S-F1>        <C-C>:call Vim_Help()<CR>
	endif
	"
	nmap    <buffer>  <silent>  <C-j>    i<C-R>=Vim_JumpForward()<CR>
	imap    <buffer>  <silent>  <C-j>     <C-R>=Vim_JumpForward()<CR>
	"
	"-------------------------------------------------------------------------------
	" settings - reset local leader
	"-------------------------------------------------------------------------------
	if ! empty ( g:Vim_MapLeader )
		if exists ( 'll_save' )
			let g:maplocalleader = ll_save
		else
			unlet g:maplocalleader
		endif
	endif
	"
endfunction    " ----------  end of function s:CreateAdditionalMaps  ----------
"
"===  FUNCTION  ================================================================
"          NAME:  Vim_Settings     {{{1
"   DESCRIPTION:  Display plugin settings
"    PARAMETERS:  -
"       RETURNS:  
"===============================================================================
function! Vim_Settings ()
	let	txt =     " Vim-Support settings\n\n"
	let txt = txt.'      plugin installation :  "'.s:installation."\"\n"
 	let txt = txt.'   code snippet directory :  "'.s:Vim_CodeSnippets."\"\n"
	if s:installation == 'system'
		let txt = txt.'global template directory :  '.s:Vim_GlobalTemplateDir."\n"
		if filereadable( s:Vim_LocalTemplateFile )
			let txt = txt.' local template directory :  '.s:Vim_LocalTemplateDir."\n"
		endif
	else
		let txt = txt.' local template directory :  '.s:Vim_LocalTemplateDir."\n"
	endif
	let txt = txt."\n"
	let	txt = txt."__________________________________________________________________________\n"
	let	txt = txt." Vim-Support, Version ".g:VimSupportVersion." / Dr.-Ing. Fritz Mehner / mehner@fh-swf.de\n\n"
	echo txt
endfunction    " ----------  end of function Vim_Settings ----------
"
"------------------------------------------------------------------------------
"  Vim_CreateGuiMenus     {{{1
"------------------------------------------------------------------------------
function! Vim_CreateGuiMenus ()
	if s:Vim_MenuVisible == 'no'
		aunmenu <silent> &Tools.Load\ Vim\ Support
		amenu   <silent> 40.1000 &Tools.-SEP100- :
		amenu   <silent> 40.1170 &Tools.Unload\ Vim\ Support :call Vim_RemoveGuiMenus()<CR>
		"
		call g:Vim_RereadTemplates('no')
		call s:InitMenus () 
		"
		let s:Vim_MenuVisible = 'yes'
	endif
endfunction    " ----------  end of function Vim_CreateGuiMenus  ----------
"
"------------------------------------------------------------------------------
"  Vim_ToolMenu     {{{1
"------------------------------------------------------------------------------
function! Vim_ToolMenu ()
	amenu   <silent> 40.1000 &Tools.-SEP100- :
	amenu   <silent> 40.1170 &Tools.Load\ Vim\ Support :call Vim_CreateGuiMenus()<CR>
endfunction    " ----------  end of function Vim_ToolMenu  ----------

"------------------------------------------------------------------------------
"  Vim_RemoveGuiMenus     {{{1
"------------------------------------------------------------------------------
function! Vim_RemoveGuiMenus ()
	if s:Vim_MenuVisible == 'yes'
		exe "aunmenu <silent> ".s:Vim_RootMenu
		"
		aunmenu <silent> &Tools.Unload\ Vim\ Support
		call Vim_ToolMenu()
		"
		let s:Vim_MenuVisible = 'no'
	endif
endfunction    " ----------  end of function Vim_RemoveGuiMenus  ----------

"----------------------------------------------------------------------
"  *** SETUP PLUGIN ***  {{{1
"----------------------------------------------------------------------

call Vim_ToolMenu()

if s:Vim_LoadMenus == 'yes' && s:Vim_CreateMenusDelayed == 'no'
	call Vim_CreateGuiMenus()
endif
"
if has( 'autocmd' )

  autocmd FileType *
        \ if &filetype == 'vim' || ( &filetype == 'help' && &modifiable == 1 && s:Vim_CreateMapsForHelp == 'yes' ) |
        \   if ! exists( 'g:Vim_Templates' ) |
        \     if s:Vim_LoadMenus == 'yes' | call Vim_CreateGuiMenus ()        |
        \     else                        | call g:Vim_RereadTemplates ('no') |
        \     endif |
        \   endif |
        \   call s:CreateAdditionalMaps() |
        \   call mmtemplates#core#CreateMaps ( 'g:Vim_Templates', g:Vim_MapLeader, 'do_special_maps' ) |
        \ endif

endif
" }}}1
"
" =====================================================================================
" vim: tabstop=2 shiftwidth=2 foldmethod=marker
