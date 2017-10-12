"===============================================================================
"
"          File:  vim-support.vim
"
"   Description:  Vim support     (VIM Version 7.0+)
"
"                  Write Vim-plugins by inserting comments, statements,
"                  variables and builtins.
"
"                 See help file vimsupport.txt .
"
"   VIM Version:  7.0+
"
"        Author:  Wolfgang Mehner <wolfgang-mehner@web.de>
"                 (formerly Fritz Mehner <mehner.fritz@web.de>)
"
"       Version:  see variable g:VimSupportVersion below
"       Created:  14.01.2012
"      Revision:  12.10.2017
"       License:  Copyright (c) 2012-2015, Fritz Mehner
"                 Copyright (c) 2016-2017, Wolfgang Mehner
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
	echo 'The plugin vim-support.vim needs Vim version >= 7.'
	echohl None
	finish
endif

" prevent duplicate loading
" need compatible
if exists("g:VimSupportVersion") || &cp
	finish
endif

let g:VimSupportVersion= "2.5alpha"                  " version number of this script; do not change

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
	let cs_dir    = s:Vim_CodeSnippets
	let cs_browse = s:Vim_GuiSnippetBrowser

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

	let &g:printheader = g:Vim_Printheader

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

let s:installation           = '*undefined*'
let s:plugin_dir             = ''
let s:Vim_GlobalTemplateFile = ''
let s:Vim_LocalTemplateFile  = ''
let s:Vim_CustomTemplateFile = ''                " the custom templates
let s:Vim_FilenameEscChar    = ''

if s:MSWIN
	" ==========  MS Windows  ======================================================

	let s:plugin_dir = substitute( expand('<sfile>:p:h:h'), '\', '/', 'g' )

	" change '\' to '/' to avoid interpretation as escape character
	if match(	substitute( expand("<sfile>"), '\', '/', 'g' ),
				\		substitute( expand("$HOME"),   '\', '/', 'g' ) ) == 0
		"
		" USER INSTALLATION ASSUMED
		let s:installation           = 'local'
		let s:Vim_LocalTemplateFile  = s:plugin_dir.'/vim-support/templates/Templates'
		let s:Vim_CustomTemplateFile = $HOME.'/vimfiles/templates/vim.templates'
	else
		"
		" SYSTEM WIDE INSTALLATION
		let s:installation           = 'system'
		let s:Vim_GlobalTemplateFile = s:plugin_dir.'/vim-support/templates/Templates'
		let s:Vim_LocalTemplateFile  = $HOME.'/vimfiles/vim-support/templates/Templates'
		let s:Vim_CustomTemplateFile = $HOME.'/vimfiles/templates/vim.templates'
	endif

	let s:Vim_FilenameEscChar    = ''
	let s:Vim_Display            = ''

else
	" ==========  Linux/Unix  ======================================================

	let s:plugin_dir = expand('<sfile>:p:h:h')

	if match( expand("<sfile>"), resolve( expand("$HOME") ) ) == 0
		"
		" USER INSTALLATION ASSUMED
		let s:installation           = 'local'
		let s:Vim_LocalTemplateFile  = s:plugin_dir.'/vim-support/templates/Templates'
		let s:Vim_CustomTemplateFile = $HOME.'/.vim/templates/vim.templates'
	else
		"
		" SYSTEM WIDE INSTALLATION
		let s:installation           = 'system'
		let s:Vim_GlobalTemplateFile = s:plugin_dir.'/vim-support/templates/Templates'
		let s:Vim_LocalTemplateFile  = $HOME.'/.vim/vim-support/templates/Templates'
		let s:Vim_CustomTemplateFile = $HOME.'/.vim/templates/vim.templates'
	endif

	let s:Vim_FilenameEscChar     = ' \%#[]'
	let s:Vim_Display             = $DISPLAY

endif

let s:Vim_AdditionalTemplates   = mmtemplates#config#GetFt ( 'vim' )
let s:Vim_CodeSnippets  				= s:plugin_dir.'/vim-support/codesnippets/'

"-------------------------------------------------------------------------------
" == Various settings ==   {{{2
"-------------------------------------------------------------------------------

"-------------------------------------------------------------------------------
" User configurable options   {{{3
"-------------------------------------------------------------------------------

let s:Vim_CreateMenusDelayed= 'yes'
let s:Vim_MenuVisible				= 'no'
let s:Vim_GuiSnippetBrowser = 'gui'             " gui / commandline
let s:Vim_LoadMenus         = 'yes'             " load the menus?
let s:Vim_RootMenu          = '&Vim'            " name of the root menu
let s:Vim_Ctrl_j            = 'yes'
let s:Vim_Ctrl_d            = 'yes'
let s:Vim_CreateMapsForHelp = 'no'              " create maps for modifiable help buffers as well

let s:Vim_LineEndCommColDefault = 49
let s:VimStartComment						= '"'
let s:Vim_TemplateJumpTarget 		= '<+\i\++>\|{+\i\++}\|<-\i\+->\|{-\i\+-}'

if ! exists ( 's:MenuVisible' )
	let s:MenuVisible = 0                         " menus are not visible at the moment
endif

"-------------------------------------------------------------------------------
" Get user configuration   {{{3
"-------------------------------------------------------------------------------

call s:GetGlobalSetting ( 'Vim_GuiSnippetBrowser' )
call s:GetGlobalSetting ( 'Vim_LoadMenus' )
call s:GetGlobalSetting ( 'Vim_RootMenu' )
call s:GetGlobalSetting ( 'Vim_Ctrl_j' )
call s:GetGlobalSetting ( 'Vim_Ctrl_d' )
call s:GetGlobalSetting ( 'Vim_CreateMapsForHelp' )
call s:GetGlobalSetting ( 'Vim_LocalTemplateFile' )
call s:GetGlobalSetting ( 'Vim_GlobalTemplateFile' )
call s:GetGlobalSetting ( 'Vim_CustomTemplateFile' )
call s:GetGlobalSetting ( 'Vim_CodeSnippets' )
call s:GetGlobalSetting ( 'Vim_CreateMenusDelayed' )
call s:GetGlobalSetting ( 'Vim_LineEndCommColDefault' )

call s:ApplyDefaultSetting ( 'Vim_MapLeader', '' )                " default: do not overwrite 'maplocalleader'
call s:ApplyDefaultSetting ( 'Vim_Printheader', "%<%f%h%m%<  %=%{strftime('%x %X')}     Page %N" )

" }}}3
"-------------------------------------------------------------------------------

" }}}2
"-------------------------------------------------------------------------------

"-------------------------------------------------------------------------------
" s:AdjustLineEndComm : Adjust end-of-line comments.   {{{1
"-------------------------------------------------------------------------------
function! s:AdjustLineEndComm ( ) range

	" comment character (for use in regular expression)
	let cc = '"'
	"
	" patterns to ignore when adjusting line-end comments (maybe incomplete):
	" - single-quoted strings, includes ''
	" - double-quoted strings, includes \n \" \\ ...
	let align_regex = "'\\%(''\\|[^']\\)*'"
				\ .'\|'.'"\%(\\.\|[^"]\)*"'
	"
	" local position
	if !exists( 'b:Vim_LineEndCommentColumn' )
		let b:Vim_LineEndCommentColumn = s:Vim_LineEndCommColDefault
	endif
	let correct_idx = b:Vim_LineEndCommentColumn
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

endfunction   " ---------- end of function s:AdjustLineEndComm  ----------

"-------------------------------------------------------------------------------
" s:GetLineEndCommCol : Set end-of-line comment position.   {{{1
"-------------------------------------------------------------------------------
function! s:GetLineEndCommCol ()
	let actcol = virtcol(".")
	if actcol+1 == virtcol("$")
		let b:Vim_LineEndCommentColumn = ''
		while match( b:Vim_LineEndCommentColumn, '^\s*\d\+\s*$' ) < 0
			let b:Vim_LineEndCommentColumn = s:UserInput( 'start line-end comment at virtual column : ', actcol, '' )
		endwhile
	else
		let b:Vim_LineEndCommentColumn = virtcol(".")
	endif
	echomsg "line end comments will start at column  ".b:Vim_LineEndCommentColumn
endfunction   " ---------- end of function s:GetLineEndCommCol  ----------

"-------------------------------------------------------------------------------
" s:EndOfLineComment : Append end-of-line comments.   {{{1
"-------------------------------------------------------------------------------
function! s:EndOfLineComment ( ) range
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
			normal! k
		endif
	endfor
endfunction   " ---------- end of function s:EndOfLineComment  ----------

"-------------------------------------------------------------------------------
" s:MultiLineEndComments : Append multiple end-of-line comments.   {{{1
"-------------------------------------------------------------------------------
function! s:MultiLineEndComments ( )
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
			exe 'normal!	'.diff.'A '
			exe 'normal!	A'.s:VimStartComment.' '
		endif
	endfor
	"
	" ----- back to the begin of the marked block -----
	stopinsert
	normal! '<$
	if match( getline("."), '\/\/\s*$' ) < 0
		if search( '\/\*', 'bcW', line(".") ) > 1
			normal! l
		endif
		let save_cursor = getpos(".")
		if getline(".")[save_cursor[2]+1] == ' '
			normal! l
		endif
	else
		normal! $
	endif
endfunction   " ---------- end of function s:MultiLineEndComments  ----------

"-------------------------------------------------------------------------------
" s:CodeComment : Code -> Comment   {{{1
"-------------------------------------------------------------------------------
function! s:CodeComment() range
	" add '"' at the beginning of the lines
	for line in range( a:firstline, a:lastline )
		exe line.'s/^/"/'
	endfor
endfunction    " ----------  end of function s:CodeComment  ----------

"-------------------------------------------------------------------------------
" s:CommentCode : Comment -> Code   {{{1
"
" Parameters:
"   toggle - 0 : uncomment, 1 : toggle comment (integer)
"-------------------------------------------------------------------------------
function! s:CommentCode( toggle ) range
	for i in range( a:firstline, a:lastline )
		" :TRICKY:15.08.2014 17:17:WM:
		" Older version prior to 2.3 inserted a space after the quote when turning
		" a line into a comment. In order to deal with old code commented with this
		" feature, we use a special rule to delete "hidden" spaces before tabs.
		" Every other space which was inserted after a quote will be visible.
		if getline( i ) =~ '^" \t'
			silent exe i.'s/^" //'
		elseif getline( i ) =~ '^"'
			silent exe i.'s/^"//'
		elseif a:toggle
			silent exe i.'s/^/"/'
		endif
	endfor
endfunction    " ----------  end of function s:CommentCode  ----------

"-------------------------------------------------------------------------------
" s:GetFunctionParameters : Get function name and parameters.   {{{1
"
" Parameters:
"   fun_line - function head (string)
" Returns:
"   scope     - the scope (string, 's:', 'g:' or empty)
"   fun_name  - the name of the function (string, id without the scope)
"   param_str - names of the parameters (list of strings)
"   ellipsis  - has an ellipsis? (boolean)
"   range     - has a range? (boolean)
"-------------------------------------------------------------------------------
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

"-------------------------------------------------------------------------------
" s:FunctionComment : Add a comment to a function.   {{{1
"-------------------------------------------------------------------------------
function! s:FunctionComment () range

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
				\ '|FUNCTION_NAME|', scope.fun_name, '|PARAMETERS|', param_list,
				\ 'placement', placement, 'range', a:firstline, a:lastline )

endfunction    " ----------  end of function s:FunctionComment  ----------

"-------------------------------------------------------------------------------
" s:KeywordHelp : Help for word under cursor.   {{{1
"-------------------------------------------------------------------------------
function! s:KeywordHelp ()
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
endfunction    " ----------  end of function s:KeywordHelp  ----------

"-------------------------------------------------------------------------------
" s:HelpPlugin : Plug-in help.   {{{1
"-------------------------------------------------------------------------------
function! s:HelpPlugin ()
	try
		help vimsupport
	catch
		exe 'helptags '.s:plugin_dir.'/doc'
		help vimsupport
	endtry
endfunction    " ----------  end of function s:HelpPlugin ----------

"------------------------------------------------------------------------------
"  === Templates API ===   {{{1
"------------------------------------------------------------------------------

"------------------------------------------------------------------------------
"  Vim_SetMapLeader: Set the local mapleader to 'g:Vim_MapLeader'.   {{{2
"------------------------------------------------------------------------------
function! Vim_SetMapLeader ()
	if exists ( 'g:Vim_MapLeader' )
		call mmtemplates#core#SetMapleader ( g:Vim_MapLeader )
	endif
endfunction    " ----------  end of function Vim_SetMapLeader  ----------

"------------------------------------------------------------------------------
"  Vim_ResetMapLeader: Reset the mapleader.   {{{2
"------------------------------------------------------------------------------
function! Vim_ResetMapLeader ()
	if exists ( 'g:Vim_MapLeader' )
		call mmtemplates#core#ResetMapleader ()
	endif
endfunction    " ----------  end of function Vim_ResetMapLeader  ----------
" }}}2
"------------------------------------------------------------------------------

"-------------------------------------------------------------------------------
" s:RereadTemplates : Initial loading of the templates.   {{{1
"
" Reread the templates. Also set the character which starts the comments in
" the template files.
"-------------------------------------------------------------------------------
function! s:RereadTemplates ()

	"-------------------------------------------------------------------------------
	" setup template library
	"-------------------------------------------------------------------------------
	let g:Vim_Templates = mmtemplates#core#NewLibrary ( 'api_version', '1.0' )

	" mapleader
	if empty ( g:Vim_MapLeader )
		call mmtemplates#core#Resource ( g:Vim_Templates, 'set', 'property', 'Templates::Mapleader', '\' )
	else
		call mmtemplates#core#Resource ( g:Vim_Templates, 'set', 'property', 'Templates::Mapleader', g:Vim_MapLeader )
	endif

	" some metainfo
	call mmtemplates#core#Resource ( g:Vim_Templates, 'set', 'property', 'Templates::Wizard::PluginName',   'Vim' )
	call mmtemplates#core#Resource ( g:Vim_Templates, 'set', 'property', 'Templates::Wizard::FiletypeName', 'Vim' )
	call mmtemplates#core#Resource ( g:Vim_Templates, 'set', 'property', 'Templates::Wizard::FileCustomNoPersonal',   s:plugin_dir.'/vim-support/rc/custom.templates' )
	call mmtemplates#core#Resource ( g:Vim_Templates, 'set', 'property', 'Templates::Wizard::FileCustomWithPersonal', s:plugin_dir.'/vim-support/rc/custom_with_personal.templates' )
	call mmtemplates#core#Resource ( g:Vim_Templates, 'set', 'property', 'Templates::Wizard::FilePersonal',           s:plugin_dir.'/vim-support/rc/personal.templates' )
	call mmtemplates#core#Resource ( g:Vim_Templates, 'set', 'property', 'Templates::Wizard::CustomFileVariable',     'g:Vim_CustomTemplateFile' )

	" maps: special operations
	call mmtemplates#core#Resource ( g:Vim_Templates, 'set', 'property', 'Templates::RereadTemplates::Map', 'ntr' )
	call mmtemplates#core#Resource ( g:Vim_Templates, 'set', 'property', 'Templates::ChooseStyle::Map',     'nts' )
	call mmtemplates#core#Resource ( g:Vim_Templates, 'set', 'property', 'Templates::SetupWizard::Map',     'ntw' )

	" syntax: comments
	call mmtemplates#core#ChangeSyntax ( g:Vim_Templates, 'comment', '§' )

	"-------------------------------------------------------------------------------
	" load template library
	"-------------------------------------------------------------------------------

	" global templates (global installation only)
	if s:installation == 'system'
		call mmtemplates#core#ReadTemplates ( g:Vim_Templates, 'load', s:Vim_GlobalTemplateFile,
					\ 'name', 'global', 'map', 'ntg' )
	endif

	" local templates (optional for global installation)
	if s:installation == 'system'
		call mmtemplates#core#ReadTemplates ( g:Vim_Templates, 'load', s:Vim_LocalTemplateFile,
					\ 'name', 'local', 'map', 'ntl', 'optional', 'hidden' )
	else
		call mmtemplates#core#ReadTemplates ( g:Vim_Templates, 'load', s:Vim_LocalTemplateFile,
					\ 'name', 'local', 'map', 'ntl' )
	endif

	" additional templates (optional)
	if ! empty ( s:Vim_AdditionalTemplates )
		call mmtemplates#core#AddCustomTemplateFiles ( g:Vim_Templates, s:Vim_AdditionalTemplates, "Vim's additional templates"  )
	endif

	" personal templates (shared across template libraries) (optional, existence of file checked by template engine)
	call mmtemplates#core#ReadTemplates ( g:Vim_Templates, 'personalization',
				\ 'name', 'personal', 'map', 'ntp' )

	" custom templates (optional, existence of file checked by template engine)
	call mmtemplates#core#ReadTemplates ( g:Vim_Templates, 'load', s:Vim_CustomTemplateFile,
				\ 'name', 'custom', 'map', 'ntc', 'optional' )

	"-------------------------------------------------------------------------------
	" further setup
	"-------------------------------------------------------------------------------

	" get the jump tags
	let s:Vim_TemplateJumpTarget = mmtemplates#core#Resource ( g:Vim_Templates, "jumptag" )[0]

endfunction    " ----------  end of function s:RereadTemplates  ----------

"-------------------------------------------------------------------------------
" s:CheckTemplatePersonalization : Check template personalization.   {{{1
"
" Check whether the |AUTHOR| has been set in the template library.
" If not, display help on how to set up the template personalization.
"-------------------------------------------------------------------------------
let s:DoneCheckTemplatePersonalization = 0

function! s:CheckTemplatePersonalization ()

	" check whether the templates are personalized
	if s:DoneCheckTemplatePersonalization
				\ || mmtemplates#core#ExpandText ( g:Vim_Templates, '|AUTHOR|' ) != 'YOUR NAME'
		return
	endif

	let s:DoneCheckTemplatePersonalization = 1

	let maplead = mmtemplates#core#Resource ( g:Vim_Templates, 'get', 'property', 'Templates::Mapleader' )[0]

	redraw
	call s:ImportantMsg ( 'The personal details are not set in the template library. Use the map "'.maplead.'ntw".' )

endfunction    " ----------  end of function s:CheckTemplatePersonalization  ----------

"-------------------------------------------------------------------------------
" s:JumpForward : Jump to the next target.   {{{1
"
" If no target is found, jump behind the current string
"
" Parameters:
"   -
" Returns:
"   empty sting
"-------------------------------------------------------------------------------
function! s:JumpForward ()
	let match = search( s:Vim_TemplateJumpTarget, 'c' )
	if match > 0
		" remove the target
		call setline( match, substitute( getline('.'), s:Vim_TemplateJumpTarget, '', '' ) )
	else
		" try to jump behind parenthesis or strings
		call search( "[\]})\"'`]", 'W' )
		normal! l
	endif
	return ''
endfunction    " ----------  end of function s:JumpForward  ----------

"-------------------------------------------------------------------------------
" s:InitMenus : Initialize menus.   {{{1
"-------------------------------------------------------------------------------
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
	exe 'anoremenu '.s:Vim_RootMenu.'.Vim  <Nop>'
	exe 'anoremenu '.s:Vim_RootMenu.'.-Sep00- <Nop>'
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

	let  head =  'noremenu <silent> '.s:Vim_RootMenu.'.Comments.'
	let ahead = 'anoremenu <silent> '.s:Vim_RootMenu.'.Comments.'
	let vhead = 'vnoremenu <silent> '.s:Vim_RootMenu.'.Comments.'

	exe ahead.'end-of-&line\ comment<Tab>'.esc_mapl.'cl                    :call <SID>EndOfLineComment()<CR>'
	exe vhead.'end-of-&line\ comment<Tab>'.esc_mapl.'cl               <Esc>:call <SID>MultiLineEndComments()<CR>A'
	exe ahead.'ad&just\ end-of-line\ com\.<Tab>'.esc_mapl.'cj              :call <SID>AdjustLineEndComm()<CR>'
	exe vhead.'ad&just\ end-of-line\ com\.<Tab>'.esc_mapl.'cj              :call <SID>AdjustLineEndComm()<CR>'
	exe  head.'&set\ end-of-line\ com\.\ col\.<Tab>'.esc_mapl.'cs     <Esc>:call <SID>GetLineEndCommCol()<CR>'
	exe ahead.'-Sep00-     <Nop>'

	exe ahead.'&comment<TAB>'.esc_mapl.'cc		:call <SID>CodeComment()<CR>'
	exe vhead.'&comment<TAB>'.esc_mapl.'cc		:call <SID>CodeComment()<CR>'
	exe ahead.'&uncomment<TAB>'.esc_mapl.'co	:call <SID>CommentCode(0)<CR>'
	exe vhead.'&uncomment<TAB>'.esc_mapl.'co	:call <SID>CommentCode(0)<CR>'
	exe ahead.'-Sep01-     <Nop>'

	exe ahead.'&function\ description\ (auto)<TAB>'.esc_mapl.'ca	     :call <SID>FunctionComment()<CR>'
	exe vhead.'&function\ description\ (auto)<TAB>'.esc_mapl.'ca	<Esc>:call <SID>FunctionComment()<CR>'
	exe ahead.'-Sep02-     <Nop>'

	"-------------------------------------------------------------------------------
	" generate menus from the templates
 	"-------------------------------------------------------------------------------

	call mmtemplates#core#CreateMenus ( 'g:Vim_Templates', s:Vim_RootMenu, 'do_templates' )

	"-------------------------------------------------------------------------------
	" snippets
	"-------------------------------------------------------------------------------

	if !empty(s:Vim_CodeSnippets)
		exe "anoremenu  <silent> ".s:Vim_RootMenu.'.S&nippets.&read\ code\ snippet<Tab>'.esc_mapl.'nr       :call <SID>CodeSnippet("insert")<CR>'
		exe "inoremenu  <silent> ".s:Vim_RootMenu.'.S&nippets.&read\ code\ snippet<Tab>'.esc_mapl.'nr  <C-C>:call <SID>CodeSnippet("insert")<CR>'
		exe "anoremenu  <silent> ".s:Vim_RootMenu.'.S&nippets.&write\ code\ snippet<Tab>'.esc_mapl.'nw      :call <SID>CodeSnippet("create")<CR>'
		exe "inoremenu  <silent> ".s:Vim_RootMenu.'.S&nippets.&write\ code\ snippet<Tab>'.esc_mapl.'nw <C-C>:call <SID>CodeSnippet("create")<CR>'
		exe "vnoremenu  <silent> ".s:Vim_RootMenu.'.S&nippets.&write\ code\ snippet<Tab>'.esc_mapl.'nw <C-C>:call <SID>CodeSnippet("vcreate")<CR>'
		exe "anoremenu  <silent> ".s:Vim_RootMenu.'.S&nippets.&view\ code\ snippet<Tab>'.esc_mapl.'ne       :call <SID>CodeSnippet("view")<CR>'
		exe "inoremenu  <silent> ".s:Vim_RootMenu.'.S&nippets.&view\ code\ snippet<Tab>'.esc_mapl.'ne  <C-C>:call <SID>CodeSnippet("view")<CR>'
		exe "anoremenu  <silent> ".s:Vim_RootMenu.'.S&nippets.&edit\ code\ snippet<Tab>'.esc_mapl.'ne       :call <SID>CodeSnippet("edit")<CR>'
		exe "inoremenu  <silent> ".s:Vim_RootMenu.'.S&nippets.&edit\ code\ snippet<Tab>'.esc_mapl.'ne  <C-C>:call <SID>CodeSnippet("edit")<CR>'
		exe "anoremenu  <silent> ".s:Vim_RootMenu.'.S&nippets.-SepSnippets-                       :'
	endif

	" templates: edit and reload templates, styles
	call mmtemplates#core#CreateMenus ( 'g:Vim_Templates', s:Vim_RootMenu, 'do_specials', 'specials_menu', 'S&nippets' )

	"-------------------------------------------------------------------------------
	" run
	"-------------------------------------------------------------------------------

	let ahead = 'anoremenu <silent> '.s:Vim_RootMenu.'.Run.'
	let vhead = 'vnoremenu <silent> '.s:Vim_RootMenu.'.Run.'

	if s:MSWIN
		exe ahead.'&hardcopy\ to\ printer<Tab>'.esc_mapl.'rh        <C-C>:call <SID>Hardcopy("n")<CR>'
		exe vhead.'&hardcopy\ to\ printer<Tab>'.esc_mapl.'rh        <C-C>:call <SID>Hardcopy("v")<CR>'
	else
		exe ahead.'&hardcopy\ to\ FILENAME\.ps<Tab>'.esc_mapl.'rh   <C-C>:call <SID>Hardcopy("n")<CR>'
		exe vhead.'&hardcopy\ to\ FILENAME\.ps<Tab>'.esc_mapl.'rh   <C-C>:call <SID>Hardcopy("v")<CR>'
	endif

	exe ahead.'plugin\ &settings<Tab>'.esc_mapl.'rs                 :call Vim_Settings(0)<CR>'

	"-------------------------------------------------------------------------------
	" help
	"-------------------------------------------------------------------------------

	let ahead = 'anoremenu <silent> '.s:Vim_RootMenu.'.Help.'
	let ihead = 'inoremenu <silent> '.s:Vim_RootMenu.'.Help.'

	exe ahead.'&keyword\ help<Tab>'.esc_mapl.'hk              :call <SID>KeywordHelp()<CR>'
	exe ihead.'&keyword\ help<Tab>'.esc_mapl.'hk         <C-C>:call <SID>KeywordHelp()<CR>'
	exe ahead.'-SEP1-     <Nop>'
	exe ahead.'&help\ (Vim-Support)<Tab>'.esc_mapl.'hp        :call <SID>HelpPlugin()<CR>'
	exe ihead.'&help\ (Vim-Support)<Tab>'.esc_mapl.'hp   <C-C>:call <SID>HelpPlugin()<CR>'

endfunction    " ----------  end of function s:InitMenus  ----------

"-------------------------------------------------------------------------------
" s:CreateAdditionalMaps : Create additional maps.   {{{1
"-------------------------------------------------------------------------------
function! s:CreateAdditionalMaps ()

	"-------------------------------------------------------------------------------
	" settings - local leader
	"-------------------------------------------------------------------------------
	if ! empty ( g:Vim_MapLeader )
		if exists ( 'g:maplocalleader' )
			let ll_save = g:maplocalleader
		endif
		let g:maplocalleader = g:Vim_MapLeader
	endif

	"-------------------------------------------------------------------------------
	" comments
	"-------------------------------------------------------------------------------
	nnoremap    <buffer>  <silent>  <LocalLeader>cl         :call <SID>EndOfLineComment()<CR>
	inoremap    <buffer>  <silent>  <LocalLeader>cl    <C-C>:call <SID>EndOfLineComment()<CR>
	vnoremap    <buffer>  <silent>  <LocalLeader>cl    <C-C>:call <SID>MultiLineEndComments()<CR>A

	nnoremap    <buffer>  <silent>  <LocalLeader>cj         :call <SID>AdjustLineEndComm()<CR>
	inoremap    <buffer>  <silent>  <LocalLeader>cj    <C-C>:call <SID>AdjustLineEndComm()<CR>
	vnoremap    <buffer>  <silent>  <LocalLeader>cj         :call <SID>AdjustLineEndComm()<CR>

	nnoremap    <buffer>  <silent>  <LocalLeader>cs         :call <SID>GetLineEndCommCol()<CR>
	inoremap    <buffer>  <silent>  <LocalLeader>cs    <C-C>:call <SID>GetLineEndCommCol()<CR>
	vnoremap    <buffer>  <silent>  <LocalLeader>cs    <C-C>:call <SID>GetLineEndCommCol()<CR>

	nnoremap    <buffer>  <silent>  <LocalLeader>cc         :call <SID>CodeComment()<CR>
	inoremap    <buffer>  <silent>  <LocalLeader>cc    <C-C>:call <SID>CodeComment()<CR>
	vnoremap    <buffer>  <silent>  <LocalLeader>cc         :call <SID>CodeComment()<CR>

	nnoremap    <buffer>  <silent>  <LocalLeader>co         :call <SID>CommentCode(0)<CR>
	inoremap    <buffer>  <silent>  <LocalLeader>co    <C-C>:call <SID>CommentCode(0)<CR>
	vnoremap    <buffer>  <silent>  <LocalLeader>co         :call <SID>CommentCode(0)<CR>

	" :TODO:17.03.2016 12:16:WM: old maps '\cu' for backwards compatibility,
	" deprecate this eventually
	nnoremap    <buffer>  <silent>  <LocalLeader>cu         :call <SID>CommentCode(0)<CR>
	inoremap    <buffer>  <silent>  <LocalLeader>cu    <C-C>:call <SID>CommentCode(0)<CR>
	vnoremap    <buffer>  <silent>  <LocalLeader>cu         :call <SID>CommentCode(0)<CR>

	nnoremap    <buffer>  <silent>  <LocalLeader>ca         :call <SID>FunctionComment()<CR>
	inoremap    <buffer>  <silent>  <LocalLeader>ca    <Esc>:call <SID>FunctionComment()<CR>
	vnoremap    <buffer>  <silent>  <LocalLeader>ca         :call <SID>FunctionComment()<CR>

	"-------------------------------------------------------------------------------
	" snippets
	"-------------------------------------------------------------------------------

	nnoremap    <buffer>  <silent>  <LocalLeader>nr         :call <SID>CodeSnippet("insert")<CR>
	inoremap    <buffer>  <silent>  <LocalLeader>nr    <Esc>:call <SID>CodeSnippet("insert")<CR>
	vnoremap    <buffer>  <silent>  <LocalLeader>nr    <Esc>:call <SID>CodeSnippet("insert")<CR>
	nnoremap    <buffer>  <silent>  <LocalLeader>nw         :call <SID>CodeSnippet("create")<CR>
	inoremap    <buffer>  <silent>  <LocalLeader>nw    <Esc>:call <SID>CodeSnippet("create")<CR>
	vnoremap    <buffer>  <silent>  <LocalLeader>nw    <Esc>:call <SID>CodeSnippet("vcreate")<CR>

	nnoremap    <buffer>  <silent>  <LocalLeader>nv         :call <SID>CodeSnippet("view")<CR>
	inoremap    <buffer>  <silent>  <LocalLeader>nv    <Esc>:call <SID>CodeSnippet("view")<CR>
	vnoremap    <buffer>  <silent>  <LocalLeader>nv    <Esc>:call <SID>CodeSnippet("view")<CR>
	nnoremap    <buffer>  <silent>  <LocalLeader>ne         :call <SID>CodeSnippet("edit")<CR>
	inoremap    <buffer>  <silent>  <LocalLeader>ne    <Esc>:call <SID>CodeSnippet("edit")<CR>
	vnoremap    <buffer>  <silent>  <LocalLeader>ne    <Esc>:call <SID>CodeSnippet("edit")<CR>

	"-------------------------------------------------------------------------------
	"   run
	"-------------------------------------------------------------------------------
	nnoremap    <buffer>  <silent>  <LocalLeader>rh        :call <SID>Hardcopy("n")<CR>
	inoremap    <buffer>  <silent>  <LocalLeader>rh   <C-C>:call <SID>Hardcopy("n")<CR>
	vnoremap    <buffer>  <silent>  <LocalLeader>rh   <C-C>:call <SID>Hardcopy("v")<CR>

	nnoremap    <buffer>  <silent>  <LocalLeader>rs        :call Vim_Settings(0)<CR>
	inoremap    <buffer>  <silent>  <LocalLeader>rs   <C-C>:call Vim_Settings(0)<CR>

	"-------------------------------------------------------------------------------
	"   help
	"-------------------------------------------------------------------------------
	nnoremap    <buffer>  <silent>  <LocalLeader>hk         :call <SID>KeywordHelp()<CR>
	inoremap    <buffer>  <silent>  <LocalLeader>hk    <C-C>:call <SID>KeywordHelp()<CR>
	nnoremap    <buffer>  <silent>  <LocalLeader>hp         :call <SID>HelpPlugin()<CR>
	inoremap    <buffer>  <silent>  <LocalLeader>hp    <C-C>:call <SID>HelpPlugin()<CR>

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
	"-------------------------------------------------------------------------------
	" templates
	"-------------------------------------------------------------------------------
	if s:Vim_Ctrl_j == 'yes'
		nnoremap  <buffer>  <silent>  <C-j>       i<C-R>=<SID>JumpForward()<CR>
		inoremap  <buffer>  <silent>  <C-j>  <C-G>u<C-R>=<SID>JumpForward()<CR>
	endif

	if s:Vim_Ctrl_d == 'yes'
		call mmtemplates#core#CreateMaps ( 'g:Vim_Templates', g:Vim_MapLeader, 'do_special_maps', 'do_del_opt_map' )
	else
		call mmtemplates#core#CreateMaps ( 'g:Vim_Templates', g:Vim_MapLeader, 'do_special_maps' )
	endif

endfunction    " ----------  end of function s:CreateAdditionalMaps  ----------

"-------------------------------------------------------------------------------
" Vim_Settings : Print the plug-in settings.   {{{1
"
" Parameters:
"   verbose - 0 : echo, 1 : echo verbose, 2 : write to buffer (integer)
" Returns:
"   -
"-------------------------------------------------------------------------------
function! Vim_Settings ( verbose )

	if     s:MSWIN | let sys_name = 'Windows'
	elseif s:UNIX  | let sys_name = 'UN*X'
	else           | let sys_name = 'unknown' | endif
	if    s:NEOVIM | let vim_name = 'nvim'
	else           | let vim_name = has('gui_running') ? 'gvim' : 'vim' | endif

	let	txt =     " Vim-Support settings\n\n"
	" template settings: macros, style, ...
	if exists ( 'g:Vim_Templates' )
		let txt .= '                   author :  "'.mmtemplates#core#ExpandText( g:Vim_Templates, '|AUTHOR|'       )."\"\n"
		let txt .= '                authorref :  "'.mmtemplates#core#ExpandText( g:Vim_Templates, '|AUTHORREF|'    )."\"\n"
		let txt .= '                    email :  "'.mmtemplates#core#ExpandText( g:Vim_Templates, '|EMAIL|'        )."\"\n"
		let txt .= '             organization :  "'.mmtemplates#core#ExpandText( g:Vim_Templates, '|ORGANIZATION|' )."\"\n"
		let txt .= '         copyright holder :  "'.mmtemplates#core#ExpandText( g:Vim_Templates, '|COPYRIGHT|'    )."\"\n"
		let txt .= '                  license :  "'.mmtemplates#core#ExpandText( g:Vim_Templates, '|LICENSE|'      )."\"\n"
		let txt .= '           template style :  "'.mmtemplates#core#Resource ( g:Vim_Templates, "style" )[0]."\"\n\n"
	else
		let txt .= "                templates :  -not loaded-\n\n"
	endif
	" plug-in installation
	let txt .= '      plugin installation :  '.s:installation.' in '.vim_name.' on '.sys_name."\n"
	let txt .= "\n"
	" templates, snippets
	if exists ( 'g:Vim_Templates' )
		let [ templist, msg ] = mmtemplates#core#Resource ( g:Vim_Templates, 'template_list' )
		let sep  = "\n"."                             "
		let txt .=      "           template files :  "
					\ .join ( templist, sep )."\n"
	else
		let txt .= "           template files :  -not loaded-\n"
	endif
	let txt .=
				\  '       code snippets dir. :  '.s:Vim_CodeSnippets."\n"
	if a:verbose >= 1
		let	txt .= "\n"
					\ .'                mapleader :  "'.g:Vim_MapLeader."\"\n"
					\ .'     load menus / delayed :  "'.s:Vim_LoadMenus.'" / "'.s:Vim_CreateMenusDelayed."\"\n"
	endif
	let	txt .= "__________________________________________________________________________\n"
	let	txt .= " Vim-Support, Version ".g:VimSupportVersion." / Wolfgang Mehner / wolfgang-mehner@web.de\n\n"
	"
	if a:verbose == 2
		split VimSupport_Settings.txt
		put = txt
	else
		echo txt
	endif
endfunction    " ----------  end of function Vim_Settings ----------

"-------------------------------------------------------------------------------
" s:ToolMenu : Add or remove tool menu entries.   {{{1
"-------------------------------------------------------------------------------
function! s:ToolMenu( action )

	if ! has ( 'menu' )
		return
	endif

	if a:action == 'setup'
		anoremenu <silent> 40.1000 &Tools.-SEP100- :
		anoremenu <silent> 40.1170 &Tools.Load\ Vim\ Support   :call <SID>AddMenus()<CR>
	elseif a:action == 'load'
		aunmenu   <silent> &Tools.Load\ Vim\ Support
		anoremenu <silent> 40.1170 &Tools.Unload\ Vim\ Support :call <SID>RemoveMenus()<CR>
	elseif a:action == 'unload'
		aunmenu   <silent> &Tools.Unload\ Vim\ Support
		anoremenu <silent> 40.1170 &Tools.Load\ Vim\ Support   :call <SID>AddMenus()<CR>
		exe 'aunmenu <silent> '.s:Vim_RootMenu
	endif

endfunction    " ----------  end of function s:ToolMenu  ----------

"-------------------------------------------------------------------------------
" s:AddMenus : Add menus.   {{{1
"-------------------------------------------------------------------------------
function! s:AddMenus()
	if s:MenuVisible == 0
		" the menu is becoming visible
		let s:MenuVisible = 2
		" make sure the templates are loaded
		call s:RereadTemplates ()
		" initialize if not existing
		call s:ToolMenu ( 'load' )
		call s:InitMenus ()
		" the menu is now visible
		let s:MenuVisible = 1
	endif
endfunction    " ----------  end of function s:AddMenus  ----------

"-------------------------------------------------------------------------------
" s:RemoveMenus : Remove menus.   {{{1
"-------------------------------------------------------------------------------
function! s:RemoveMenus()
	if s:MenuVisible == 1
		" destroy if visible
		call s:ToolMenu ( 'unload' )
		" the menu is now invisible
		let s:MenuVisible = 0
	endif
endfunction    " ----------  end of function s:RemoveMenus  ----------

"-------------------------------------------------------------------------------
" === Setup: Templates, toolbox and menus ===   {{{1
"-------------------------------------------------------------------------------

" tool menu entry
call s:ToolMenu ( 'setup' )

if s:Vim_LoadMenus == 'yes' && s:Vim_CreateMenusDelayed == 'no'
	call s:AddMenus ()
endif

" user interface for remapping
nnoremap  <silent>  <Plug>VimSupportKeywordHelp       :call <SID>KeywordHelp()<CR>
inoremap  <silent>  <Plug>VimSupportKeywordHelp  <C-C>:call <SID>KeywordHelp()<CR>

if has( 'autocmd' )

	" create menues and maps
  autocmd FileType *
        \ if &filetype == 'vim' || ( &filetype == 'help' && &modifiable == 1 && s:Vim_CreateMapsForHelp == 'yes' ) |
        \   if ! exists( 'g:Vim_Templates' ) |
        \     if s:Vim_LoadMenus == 'yes' | call s:AddMenus ()  |
        \     else                        | call s:RereadTemplates () |
        \     endif |
        \   endif |
        \   call s:CreateAdditionalMaps() |
				\		call s:CheckTemplatePersonalization() |
        \ endif

endif
" }}}1
"-------------------------------------------------------------------------------

" =====================================================================================
" vim: tabstop=2 shiftwidth=2 foldmethod=marker
