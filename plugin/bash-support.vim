"===============================================================================
"
"          File:  bash-support.vim
"
"   Description:  Bash support
"
"                  Write Bash scripts by inserting comments, statements,
"                  variables and builtins.
"
"   VIM Version:  7.0+
"        Author:  Wolfgang Mehner <wolfgang-mehner@web.de>
"                 Fritz Mehner <mehner.fritz@web.de>
"       Version:  see g:BASH_Version below
"       Created:  26.02.2001
"      Revision:  22.06.2017
"       License:  Copyright (c) 2001-2015, Dr. Fritz Mehner
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
	echo 'The plugin bash-support.vim needs Vim version >= 7.'
	echohl None
	finish
endif

" prevent duplicate loading
" need compatible
if exists("g:BASH_Version") || &cp
	finish
endif

let g:BASH_Version= "4.4pre"                  " version number of this script; do not change

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
	let cs_dir    = s:BASH_CodeSnippets
	let cs_browse = s:BASH_GuiSnippetBrowser

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

	let &g:printheader = g:BASH_Printheader

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

let s:installation            = '*undefined*'
let s:plugin_dir              = ''
let s:BASH_GlobalTemplateFile = ''
let s:BASH_LocalTemplateFile  = ''
let s:BASH_CustomTemplateFile = ''                " the custom templates
let s:BASH_FilenameEscChar    = ''
let s:BASH_XtermDefaults      = '-fa courier -fs 12 -geometry 80x24'

if s:MSWIN
	" ==========  MS Windows  ======================================================

	let s:plugin_dir = substitute( expand('<sfile>:p:h:h'), '\', '/', 'g' )

	" change '\' to '/' to avoid interpretation as escape character
	if match(	substitute( expand("<sfile>"), '\', '/', 'g' ),
				\		substitute( expand("$HOME"),   '\', '/', 'g' ) ) == 0
		"
		" USER INSTALLATION ASSUMED
		let s:installation            = 'local'
		let s:BASH_LocalTemplateFile  = s:plugin_dir.'/bash-support/templates/Templates'
		let s:BASH_CustomTemplateFile = $HOME.'/vimfiles/templates/bash.templates'
	else
		"
		" SYSTEM WIDE INSTALLATION
		let s:installation            = 'system'
		let s:BASH_GlobalTemplateFile = s:plugin_dir.'/bash-support/templates/Templates'
		let s:BASH_LocalTemplateFile  = $HOME.'/vimfiles/bash-support/templates/Templates'
		let s:BASH_CustomTemplateFile = $HOME.'/vimfiles/templates/bash.templates'
	endif

	let s:BASH_FilenameEscChar    = ''
	let s:BASH_Display            = ''
	let s:BASH_ManualReader       = 'man.exe'
	let s:BASH_Executable         = 'bash.exe'
	let s:BASH_OutputGvim         = 'xterm'
else
	" ==========  Linux/Unix  ======================================================

	let s:plugin_dir = expand('<sfile>:p:h:h')

	if match( expand("<sfile>"), resolve( expand("$HOME") ) ) == 0
		"
		" USER INSTALLATION ASSUMED
		let s:installation            = 'local'
		let s:BASH_LocalTemplateFile  = s:plugin_dir.'/bash-support/templates/Templates'
		let s:BASH_CustomTemplateFile = $HOME.'/.vim/templates/bash.templates'
	else
		"
		" SYSTEM WIDE INSTALLATION
		let s:installation            = 'system'
		let s:BASH_GlobalTemplateFile = s:plugin_dir.'/bash-support/templates/Templates'
		let s:BASH_LocalTemplateFile  = $HOME.'/.vim/bash-support/templates/Templates'
		let s:BASH_CustomTemplateFile = $HOME.'/.vim/templates/bash.templates'
	endif

	let s:BASH_Executable         = $SHELL
	let s:BASH_FilenameEscChar    = ' \%#[]'
	let s:BASH_Display            = $DISPLAY
	let s:BASH_ManualReader       = '/usr/bin/man'
	let s:BASH_OutputGvim         = 'vim'
endif

let s:BASH_AdditionalTemplates = mmtemplates#config#GetFt ( 'bash' )
let s:BASH_CodeSnippets        = s:plugin_dir.'/bash-support/codesnippets/'

"-------------------------------------------------------------------------------
" == Various settings ==   {{{2
"-------------------------------------------------------------------------------

"-------------------------------------------------------------------------------
" Use of dictionaries   {{{3
"
" - keyword completion is enabled by the function 's:CreateAdditionalMaps' below
"-------------------------------------------------------------------------------

if !exists("g:BASH_Dictionary_File")
	let g:BASH_Dictionary_File = s:plugin_dir.'/bash-support/wordlists/bash-keywords.list'
endif

"-------------------------------------------------------------------------------
" User configurable options   {{{3
"-------------------------------------------------------------------------------

let s:BASH_CreateMenusDelayed	= 'yes'
let s:BASH_GuiSnippetBrowser 	= 'gui'             " gui / commandline
let s:BASH_LoadMenus         	= 'yes'             " load the menus?
let s:BASH_RootMenu          	= '&Bash'           " name of the root menu
let s:BASH_Debugger           = 'term'
let s:BASH_bashdb             = 'bashdb'
"
let s:BASH_LineEndCommColDefault	= 49
let s:BASH_TemplateJumpTarget 		= ''
let s:BASH_Errorformat            = '%f: %[%^0-9]%# %l:%m,%f: %l:%m,%f:%l:%m,%f[%l]:%m'
let s:BASH_Wrapper                = s:plugin_dir.'/bash-support/scripts/wrapper.sh'
let s:BASH_InsertFileHeader       = 'yes'
let s:BASH_Ctrl_j                 = 'yes'
let s:BASH_Ctrl_d                 = 'yes'
let s:BASH_SyntaxCheckOptionsGlob = ''

if ! exists ( 's:MenuVisible' )
	let s:MenuVisible = 0                         " menus are not visible at the moment
endif

"-------------------------------------------------------------------------------
" Get user configuration   {{{3
"-------------------------------------------------------------------------------

call s:GetGlobalSetting ( 'BASH_Debugger' )
call s:GetGlobalSetting ( 'BASH_bashdb' )
call s:GetGlobalSetting ( 'BASH_SyntaxCheckOptionsGlob' )
call s:GetGlobalSetting ( 'BASH_Executable' )
call s:GetGlobalSetting ( 'BASH_InsertFileHeader' )
call s:GetGlobalSetting ( 'BASH_Ctrl_j' )
call s:GetGlobalSetting ( 'BASH_Ctrl_d' )
call s:GetGlobalSetting ( 'BASH_CodeSnippets' )
call s:GetGlobalSetting ( 'BASH_GuiSnippetBrowser' )
call s:GetGlobalSetting ( 'BASH_LoadMenus' )
call s:GetGlobalSetting ( 'BASH_RootMenu' )
call s:GetGlobalSetting ( 'BASH_ManualReader' )
call s:GetGlobalSetting ( 'BASH_OutputGvim' )
call s:GetGlobalSetting ( 'BASH_XtermDefaults' )
call s:GetGlobalSetting ( 'BASH_GlobalTemplateFile' )
call s:GetGlobalSetting ( 'BASH_LocalTemplateFile' )
call s:GetGlobalSetting ( 'BASH_CustomTemplateFile' )
call s:GetGlobalSetting ( 'BASH_CreateMenusDelayed' )
call s:GetGlobalSetting ( 'BASH_LineEndCommColDefault' )

call s:ApplyDefaultSetting ( 'BASH_MapLeader', '' )       " default: do not overwrite 'maplocalleader'
call s:ApplyDefaultSetting ( 'BASH_Printheader', "%<%f%h%m%<  %=%{strftime('%x %X')}     Page %N" )

"-------------------------------------------------------------------------------
" Xterm   {{{3
"-------------------------------------------------------------------------------

" set default geometry if not specified
if match( s:BASH_XtermDefaults, "-geometry\\s\\+\\d\\+x\\d\\+" ) < 0
	let s:BASH_XtermDefaults	= s:BASH_XtermDefaults." -geometry 80x24"
endif

" }}}3
"-------------------------------------------------------------------------------

" }}}2
"-------------------------------------------------------------------------------

"-------------------------------------------------------------------------------
" s:AdjustLineEndComm : Adjust end-of-line comments.   {{{1
"-------------------------------------------------------------------------------

" patterns to ignore when adjusting line-end comments (incomplete):
let s:AlignRegex = [
	\	'\$#' ,
	\	'\${.*}'  ,
	\	"'\\%(\\\\'\\|[^']\\)*'"  ,
	\	'"\%(\\.\|[^"]\)*"'  ,
	\	'`[^`]\+`' ,
	\	]

function! s:AdjustLineEndComm ( ) range

	" comment character (for use in regular expression)
	let cc = '#'                       " start of a Perl comment
	"
	" patterns to ignore when adjusting line-end comments (maybe incomplete):
	let align_regex = join( s:AlignRegex, '\|' )
	"
	" local position
	if !exists( 'b:BASH_LineEndCommentColumn' )
		let b:BASH_LineEndCommentColumn = s:BASH_LineEndCommColDefault
	endif
	let correct_idx = b:BASH_LineEndCommentColumn
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
		let b:BASH_LineEndCommentColumn = ''
		while match( b:BASH_LineEndCommentColumn, '^\s*\d\+\s*$' ) < 0
			let b:BASH_LineEndCommentColumn = s:UserInput( 'start line-end comment at virtual column : ', actcol, '' )
		endwhile
	else
		let b:BASH_LineEndCommentColumn = virtcol(".")
	endif
	echomsg "line end comments will start at column  ".b:BASH_LineEndCommentColumn
endfunction   " ---------- end of function s:GetLineEndCommCol  ----------

"-------------------------------------------------------------------------------
" s:EndOfLineComment : Append end-of-line comments.   {{{1
"-------------------------------------------------------------------------------
function! s:EndOfLineComment ( ) range
	if !exists("b:BASH_LineEndCommentColumn")
		let b:BASH_LineEndCommentColumn = s:BASH_LineEndCommColDefault
	endif
	" ----- trim whitespaces -----
	exe a:firstline.','.a:lastline.'s/\s*$//'

	for line in range( a:lastline, a:firstline, -1 )
		silent exe ":".line
		if getline(line) !~ '^\s*$'
			let linelength = virtcol( [line, "$"] ) - 1
			let diff = 1
			if linelength < b:BASH_LineEndCommentColumn
				let diff = b:BASH_LineEndCommentColumn -1 -linelength
			endif
			exe "normal! ".diff."A "
			call mmtemplates#core#InsertTemplate(g:BASH_Templates, 'Comments.end-of-line comment')
		endif
	endfor
endfunction   " ---------- end of function s:EndOfLineComment  ----------

"-------------------------------------------------------------------------------
" s:CodeComment : Code -> Comment   {{{1
"-------------------------------------------------------------------------------
function! s:CodeComment() range
	" add '#' at the beginning of the lines
	for line in range( a:firstline, a:lastline )
		exe line.'s/^/#/'
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
		if getline( i ) =~ '^# \t'
			silent exe i.'s/^# //'
		elseif getline( i ) =~ '^#'
			silent exe i.'s/^#//'
		elseif a:toggle
			silent exe i.'s/^/#/'
		endif
	endfor
endfunction    " ----------  end of function s:CommentCode  ----------

"-------------------------------------------------------------------------------
" s:EchoComment : Put statement in an echo.   {{{1
"-------------------------------------------------------------------------------
function! s:EchoComment ()
	let	line	= escape( getline("."), '"' )
	let	line	= substitute( line, '^\s*', '', '' )
	call setline( line("."), 'echo "'.line.'"' )
	silent exe "normal! =="
	return
endfunction   " ---------- end of function s:EchoComment  ----------

"-------------------------------------------------------------------------------
" s:RemoveEcho : Remove echo from statement.   {{{1
"-------------------------------------------------------------------------------
function! s:RemoveEcho ()
	let	line	= substitute( getline("."), '\\"', '"', 'g' )
	let	line	= substitute( line, '^\s*echo\s\+"', '', '' )
	let	line	= substitute( line, '"$', '', '' )
	call setline( line("."), line )
	silent exe "normal! =="
	return
endfunction   " ---------- end of function s:RemoveEcho  ----------

"-------------------------------------------------------------------------------
" s:HelpPlugin : Plug-in help.   {{{1
"-------------------------------------------------------------------------------
function! s:HelpPlugin ()
	try
		help bashsupport
	catch
		exe 'helptags '.s:plugin_dir.'/doc'
		help bashsupport
	endtry
endfunction   " ----------  end of function s:HelpPlugin ----------

"------------------------------------------------------------------------------
"  === Templates API ===   {{{1
"------------------------------------------------------------------------------
"
"------------------------------------------------------------------------------
"  Bash_SetMapLeader   {{{2
"------------------------------------------------------------------------------
function! Bash_SetMapLeader ()
	if exists ( 'g:BASH_MapLeader' )
		call mmtemplates#core#SetMapleader ( g:BASH_MapLeader )
	endif
endfunction    " ----------  end of function Bash_SetMapLeader  ----------
"
"------------------------------------------------------------------------------
"  Bash_ResetMapLeader   {{{2
"------------------------------------------------------------------------------
function! Bash_ResetMapLeader ()
	if exists ( 'g:BASH_MapLeader' )
		call mmtemplates#core#ResetMapleader ()
	endif
endfunction    " ----------  end of function Bash_ResetMapLeader  ----------
" }}}2

"-------------------------------------------------------------------------------
" s:RereadTemplates : Initial loading of the templates.   {{{1
"-------------------------------------------------------------------------------
function! s:RereadTemplates ()

	"-------------------------------------------------------------------------------
	" setup template library
	"-------------------------------------------------------------------------------
	let g:BASH_Templates = mmtemplates#core#NewLibrary ( 'api_version', '1.0' )

	" mapleader
	if empty ( g:BASH_MapLeader )
		call mmtemplates#core#Resource ( g:BASH_Templates, 'set', 'property', 'Templates::Mapleader', '\' )
	else
		call mmtemplates#core#Resource ( g:BASH_Templates, 'set', 'property', 'Templates::Mapleader', g:BASH_MapLeader )
	endif

	" some metainfo
	call mmtemplates#core#Resource ( g:BASH_Templates, 'set', 'property', 'Templates::Wizard::PluginName',   'Bash' )
	call mmtemplates#core#Resource ( g:BASH_Templates, 'set', 'property', 'Templates::Wizard::FiletypeName', 'Bash' )
	call mmtemplates#core#Resource ( g:BASH_Templates, 'set', 'property', 'Templates::Wizard::FileCustomNoPersonal',   s:plugin_dir.'/bash-support/rc/custom.templates' )
	call mmtemplates#core#Resource ( g:BASH_Templates, 'set', 'property', 'Templates::Wizard::FileCustomWithPersonal', s:plugin_dir.'/bash-support/rc/custom_with_personal.templates' )
	call mmtemplates#core#Resource ( g:BASH_Templates, 'set', 'property', 'Templates::Wizard::FilePersonal',           s:plugin_dir.'/bash-support/rc/personal.templates' )
	call mmtemplates#core#Resource ( g:BASH_Templates, 'set', 'property', 'Templates::Wizard::CustomFileVariable',     'g:BASH_CustomTemplateFile' )

	" maps: special operations
	call mmtemplates#core#Resource ( g:BASH_Templates, 'set', 'property', 'Templates::RereadTemplates::Map', 'ntr' )
	call mmtemplates#core#Resource ( g:BASH_Templates, 'set', 'property', 'Templates::ChooseStyle::Map',     'nts' )
	call mmtemplates#core#Resource ( g:BASH_Templates, 'set', 'property', 'Templates::SetupWizard::Map',     'ntw' )

	" syntax: comments
	call mmtemplates#core#ChangeSyntax ( g:BASH_Templates, 'comment', '§' )

	" property: file skeletons
	call mmtemplates#core#Resource ( g:BASH_Templates, 'add', 'property', 'Bash::FileSkeleton::Script', 'Comments.shebang;Comments.file header; ;Skeleton.script-set' )

	"-------------------------------------------------------------------------------
	" load template library
	"-------------------------------------------------------------------------------

	" global templates (global installation only)
	if s:installation == 'system'
		call mmtemplates#core#ReadTemplates ( g:BASH_Templates, 'load', s:BASH_GlobalTemplateFile,
					\ 'name', 'global', 'map', 'ntg' )
	endif

	" local templates (optional for global installation)
	if s:installation == 'system'
		call mmtemplates#core#ReadTemplates ( g:BASH_Templates, 'load', s:BASH_LocalTemplateFile,
					\ 'name', 'local', 'map', 'ntl', 'optional', 'hidden' )
	else
		call mmtemplates#core#ReadTemplates ( g:BASH_Templates, 'load', s:BASH_LocalTemplateFile,
					\ 'name', 'local', 'map', 'ntl' )
	endif

	" additional templates (optional)
	if ! empty ( s:BASH_AdditionalTemplates )
		call mmtemplates#core#AddCustomTemplateFiles ( g:BASH_Templates, s:BASH_AdditionalTemplates, "Bash's additional templates" )
	endif

	" personal templates (shared across template libraries) (optional, existence of file checked by template engine)
	call mmtemplates#core#ReadTemplates ( g:BASH_Templates, 'personalization',
				\ 'name', 'personal', 'map', 'ntp' )

	" custom templates (optional, existence of file checked by template engine)
	call mmtemplates#core#ReadTemplates ( g:BASH_Templates, 'load', s:BASH_CustomTemplateFile,
				\ 'name', 'custom', 'map', 'ntc', 'optional' )

	"-------------------------------------------------------------------------------
	" further setup
	"-------------------------------------------------------------------------------

	" get the jump tags
	let s:BASH_TemplateJumpTarget = mmtemplates#core#Resource ( g:BASH_Templates, "jumptag" )[0]

	" get the builtin list
	let l = mmtemplates#core#Resource ( g:BASH_Templates, 'get', 'list', 'builtins' )

	if l[1] == ''
		let s:BuiltinList = l[0]
	else
		call s:ErrorMsg ( l[1] )
	endif

endfunction    " ----------  end of function s:RereadTemplates  ----------

"-------------------------------------------------------------------------------
" s:CheckTemplatePersonalization : Check whether the name, .. has been set.   {{{1
"-------------------------------------------------------------------------------

let s:DoneCheckTemplatePersonalization = 0

function! s:CheckTemplatePersonalization ()

	" check whether the templates are personalized
	if s:DoneCheckTemplatePersonalization
				\ || mmtemplates#core#ExpandText ( g:BASH_Templates, '|AUTHOR|' ) != 'YOUR NAME'
				\ || s:BASH_InsertFileHeader != 'yes'
		return
	endif

	let s:DoneCheckTemplatePersonalization = 1

	let maplead = mmtemplates#core#Resource ( g:BASH_Templates, 'get', 'property', 'Templates::Mapleader' )[0]

	redraw
	call s:ImportantMsg ( 'The personal details are not set in the template library. Use the map "'.maplead.'ntw".' )

endfunction    " ----------  end of function s:CheckTemplatePersonalization  ----------

"-------------------------------------------------------------------------------
" s:CheckAndRereadTemplates : Make sure the templates are loaded.   {{{1
"-------------------------------------------------------------------------------
function! s:CheckAndRereadTemplates ()
	if ! exists ( 'g:BASH_Templates' )
		call s:RereadTemplates()
	endif
endfunction    " ----------  end of function s:CheckAndRereadTemplates  ----------

"-------------------------------------------------------------------------------
" s:InsertFileHeader : Insert a file header.   {{{1
"-------------------------------------------------------------------------------
function! s:InsertFileHeader ()
	call s:CheckAndRereadTemplates()

	" prevent insertion for a file generated from a some error
	if isdirectory(expand('%:p:h')) && s:BASH_InsertFileHeader == 'yes'
		let templ_s = mmtemplates#core#Resource ( g:BASH_Templates, 'get', 'property', 'Bash::FileSkeleton::Script' )[0]

		" insert templates in reverse order, always above the first line
		" the last one to insert (the first in the list), will determine the
		" placement of the cursor
		let templ_l = split ( templ_s, ';' )
		for i in range ( len(templ_l)-1, 0, -1 )
			exe 1
			if -1 != match ( templ_l[i], '^\s\+$' )
				put! =''
			else
				call mmtemplates#core#InsertTemplate ( g:BASH_Templates, templ_l[i], 'placement', 'above' )
			endif
		endfor
		if len(templ_l) > 0
			set modified
		endif
	endif
endfunction    " ----------  end of function s:InsertFileHeader  ----------

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
	let match = search( s:BASH_TemplateJumpTarget, 'c' )
	if match > 0
		" remove the target
		call setline( match, substitute( getline('.'), s:BASH_TemplateJumpTarget, '', '' ) )
	else
		" try to jump behind parenthesis or strings
		call search( "[\]})\"'`]", 'W' )
		normal! l
	endif
	return ''
endfunction    " ----------  end of function s:JumpForward  ----------

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
 	"-------------------------------------------------------------------------------
	" preparation      {{{2
	"-------------------------------------------------------------------------------
	call mmtemplates#core#CreateMenus ( 'g:BASH_Templates', s:BASH_RootMenu, 'do_reset' )
	"
	" get the mapleader (correctly escaped)
	let [ esc_mapl, err ] = mmtemplates#core#Resource ( g:BASH_Templates, 'escaped_mapleader' )
	"
	exe 'amenu '.s:BASH_RootMenu.'.Bash  <Nop>'
	exe 'amenu '.s:BASH_RootMenu.'.-Sep00- <Nop>'
	"
 	"-------------------------------------------------------------------------------
	" menu headers     {{{2
	"-------------------------------------------------------------------------------
	"
	call mmtemplates#core#CreateMenus ( 'g:BASH_Templates', s:BASH_RootMenu, 'sub_menu', '&Comments', 'priority', 500 )
	" the other, automatically created menus go here; their priority is the standard priority 500
	call mmtemplates#core#CreateMenus ( 'g:BASH_Templates', s:BASH_RootMenu, 'sub_menu', 'S&nippets', 'priority', 600 )
	call mmtemplates#core#CreateMenus ( 'g:BASH_Templates', s:BASH_RootMenu, 'sub_menu', '&Run'     , 'priority', 700 )
	call mmtemplates#core#CreateMenus ( 'g:BASH_Templates', s:BASH_RootMenu, 'sub_menu', '&Help'    , 'priority', 800 )
	"
	"-------------------------------------------------------------------------------
	" comments     {{{2
 	"-------------------------------------------------------------------------------
	"
	let  head =  'noremenu <silent> '.s:BASH_RootMenu.'.Comments.'
	let ahead = 'anoremenu <silent> '.s:BASH_RootMenu.'.Comments.'
	let vhead = 'vnoremenu <silent> '.s:BASH_RootMenu.'.Comments.'
	let ihead = 'inoremenu <silent> '.s:BASH_RootMenu.'.Comments.'
	"
	exe ahead.'end-of-&line\ comment<Tab>'.esc_mapl.'cl                 :call <SID>EndOfLineComment()<CR>'
	exe vhead.'end-of-&line\ comment<Tab>'.esc_mapl.'cl                 :call <SID>EndOfLineComment()<CR>'

	exe ahead.'ad&just\ end-of-line\ com\.<Tab>'.esc_mapl.'cj           :call <SID>AdjustLineEndComm()<CR>'
	exe ihead.'ad&just\ end-of-line\ com\.<Tab>'.esc_mapl.'cj      <Esc>:call <SID>AdjustLineEndComm()<CR>'
	exe vhead.'ad&just\ end-of-line\ com\.<Tab>'.esc_mapl.'cj           :call <SID>AdjustLineEndComm()<CR>'
	exe  head.'&set\ end-of-line\ com\.\ col\.<Tab>'.esc_mapl.'cs  <Esc>:call <SID>GetLineEndCommCol()<CR>'
	"
	exe ahead.'-Sep01-						<Nop>'
	exe ahead.'&comment<TAB>'.esc_mapl.'cc															:call <SID>CodeComment()<CR>'
	exe vhead.'&comment<TAB>'.esc_mapl.'cc															:call <SID>CodeComment()<CR>'
	exe ahead.'&uncomment<TAB>'.esc_mapl.'co														:call <SID>CommentCode(0)<CR>'
	exe vhead.'&uncomment<TAB>'.esc_mapl.'co														:call <SID>CommentCode(0)<CR>'
	exe ahead.'-Sep02-						<Nop>'
	"
	"-------------------------------------------------------------------------------
	" generate menus from the templates
 	"-------------------------------------------------------------------------------
	"
	call mmtemplates#core#CreateMenus ( 'g:BASH_Templates', s:BASH_RootMenu, 'do_templates' )
	"
	"-------------------------------------------------------------------------------
	" snippets     {{{2
	"-------------------------------------------------------------------------------

	if !empty(s:BASH_CodeSnippets)
		exe "amenu  <silent> ".s:BASH_RootMenu.'.S&nippets.&read\ code\ snippet<Tab>'.esc_mapl.'nr       :call <SID>CodeSnippet("insert")<CR>'
		exe "imenu  <silent> ".s:BASH_RootMenu.'.S&nippets.&read\ code\ snippet<Tab>'.esc_mapl.'nr  <C-C>:call <SID>CodeSnippet("insert")<CR>'
		exe "amenu  <silent> ".s:BASH_RootMenu.'.S&nippets.&view\ code\ snippet<Tab>'.esc_mapl.'nv       :call <SID>CodeSnippet("view")<CR>'
		exe "imenu  <silent> ".s:BASH_RootMenu.'.S&nippets.&view\ code\ snippet<Tab>'.esc_mapl.'nv  <C-C>:call <SID>CodeSnippet("view")<CR>'
		exe "amenu  <silent> ".s:BASH_RootMenu.'.S&nippets.&write\ code\ snippet<Tab>'.esc_mapl.'nw      :call <SID>CodeSnippet("create")<CR>'
		exe "imenu  <silent> ".s:BASH_RootMenu.'.S&nippets.&write\ code\ snippet<Tab>'.esc_mapl.'nw <C-C>:call <SID>CodeSnippet("create")<CR>'
		exe "vmenu  <silent> ".s:BASH_RootMenu.'.S&nippets.&write\ code\ snippet<Tab>'.esc_mapl.'nw <C-C>:call <SID>CodeSnippet("vcreate")<CR>'
		exe "amenu  <silent> ".s:BASH_RootMenu.'.S&nippets.&edit\ code\ snippet<Tab>'.esc_mapl.'ne       :call <SID>CodeSnippet("edit")<CR>'
		exe "imenu  <silent> ".s:BASH_RootMenu.'.S&nippets.&edit\ code\ snippet<Tab>'.esc_mapl.'ne  <C-C>:call <SID>CodeSnippet("edit")<CR>'
		exe "amenu  <silent> ".s:BASH_RootMenu.'.S&nippets.-SepSnippets-                       :'
	endif

	"-------------------------------------------------------------------------------
	" templates
	"-------------------------------------------------------------------------------

	call mmtemplates#core#CreateMenus ( 'g:BASH_Templates', s:BASH_RootMenu, 'do_specials', 'specials_menu', 'S&nippets' )

	"-------------------------------------------------------------------------------
	" run     {{{2
	"-------------------------------------------------------------------------------
	"
	exe " menu <silent> ".s:BASH_RootMenu.'.&Run.save\ +\ &run\ script<Tab><C-F9>\ \ '.esc_mapl.'rr            :call BASH_Run("n")<CR>'
	exe "imenu <silent> ".s:BASH_RootMenu.'.&Run.save\ +\ &run\ script<Tab><C-F9>\ \ '.esc_mapl.'rr       <C-C>:call BASH_Run("n")<CR>'
	exe "vmenu <silent> ".s:BASH_RootMenu.'.&Run.save\ +\ &run\ script<Tab><C-F9>\ \ '.esc_mapl.'rr       <C-C>:call BASH_Run("v")<CR>'
	"
	exe " menu          ".s:BASH_RootMenu.'.&Run.script\ cmd\.\ line\ &arg\.<Tab><S-F9>\ \ '.esc_mapl.'ra      :BashScriptArguments<Space>'
	exe "imenu          ".s:BASH_RootMenu.'.&Run.script\ cmd\.\ line\ &arg\.<Tab><S-F9>\ \ '.esc_mapl.'ra <C-C>:BashScriptArguments<Space>'
	"
	exe " menu          ".s:BASH_RootMenu.'.&Run.Bash\ cmd\.\ line\ &arg\.<Tab>'.esc_mapl.'rba                  :BashArguments<Space>'
	exe "imenu          ".s:BASH_RootMenu.'.&Run.Bash\ cmd\.\ line\ &arg\.<Tab>'.esc_mapl.'rba             <C-C>:BashArguments<Space>'
	"
  exe " menu <silent> ".s:BASH_RootMenu.'.&Run.update,\ check\ &syntax<Tab><A-F9>\ \ '.esc_mapl.'rc          :call BASH_SyntaxCheck()<CR>'
  exe "imenu <silent> ".s:BASH_RootMenu.'.&Run.update,\ check\ &syntax<Tab><A-F9>\ \ '.esc_mapl.'rc     <C-C>:call BASH_SyntaxCheck()<CR>'
	exe " menu <silent> ".s:BASH_RootMenu.'.&Run.syntax\ check\ o&ptions<Tab>'.esc_mapl.'rco               :call BASH_SyntaxCheckOptionsLocal()<CR>'
	exe "imenu <silent> ".s:BASH_RootMenu.'.&Run.syntax\ check\ o&ptions<Tab>'.esc_mapl.'rco          <C-C>:call BASH_SyntaxCheckOptionsLocal()<CR>'
	"
	let ahead = 'amenu <silent> '.s:BASH_RootMenu.'.Run.'
	let vhead = 'vmenu <silent> '.s:BASH_RootMenu.'.Run.'
  "
	"
	if	!s:MSWIN
		exe "amenu <silent> ".s:BASH_RootMenu.'.&Run.start\ &debugger<Tab><F9>\ \ '.esc_mapl.'rd           :call BASH_Debugger()<CR>'
		exe "amenu <silent> ".s:BASH_RootMenu.'.&Run.make\ script\ &exec\./not\ exec\.<Tab>'.esc_mapl.'re          :call <SID>MakeExecutable()<CR>'
	endif

	exe ahead.'-SEP1-   :'
	if	s:MSWIN
		exe ahead.'&hardcopy\ to\ printer<Tab>'.esc_mapl.'rh        <C-C>:call <SID>Hardcopy("n")<CR>'
		exe vhead.'&hardcopy\ to\ printer<Tab>'.esc_mapl.'rh        <C-C>:call <SID>Hardcopy("v")<CR>'
	else
		exe ahead.'&hardcopy\ to\ FILENAME\.ps<Tab>'.esc_mapl.'rh   <C-C>:call <SID>Hardcopy("n")<CR>'
		exe vhead.'&hardcopy\ to\ FILENAME\.ps<Tab>'.esc_mapl.'rh   <C-C>:call <SID>Hardcopy("v")<CR>'
	endif

	exe ahead.'-SEP2-                                                 :'
	exe ahead.'plugin\ &settings<Tab>'.esc_mapl.'rs                   :call BASH_Settings(0)<CR>'
	"
	if	!s:MSWIN
		exe " menu  <silent>  ".s:BASH_RootMenu.'.&Run.x&term\ size<Tab>'.esc_mapl.'rx                       :call BASH_XtermSize()<CR>'
		exe "imenu  <silent>  ".s:BASH_RootMenu.'.&Run.x&term\ size<Tab>'.esc_mapl.'rx                  <C-C>:call BASH_XtermSize()<CR>'
	endif
	"
	if	s:MSWIN
		if s:BASH_OutputGvim == "buffer"
			exe " menu  <silent>  ".s:BASH_RootMenu.'.&Run.&output:\ BUFFER->term<Tab>'.esc_mapl.'ro          :call BASH_Toggle_Gvim_Xterm_MS()<CR>'
			exe "imenu  <silent>  ".s:BASH_RootMenu.'.&Run.&output:\ BUFFER->term<Tab>'.esc_mapl.'ro     <C-C>:call BASH_Toggle_Gvim_Xterm_MS()<CR>'
		else
			exe " menu  <silent>  ".s:BASH_RootMenu.'.&Run.&output:\ TERM->buffer<Tab>'.esc_mapl.'ro          :call BASH_Toggle_Gvim_Xterm_MS()<CR>'
			exe "imenu  <silent>  ".s:BASH_RootMenu.'.&Run.&output:\ TERM->buffer<Tab>'.esc_mapl.'ro     <C-C>:call BASH_Toggle_Gvim_Xterm_MS()<CR>'
		endif
	else
		if s:BASH_OutputGvim == "vim"
			exe " menu  <silent>  ".s:BASH_RootMenu.'.&Run.&output:\ VIM->buffer->xterm<Tab>'.esc_mapl.'ro          :call BASH_Toggle_Gvim_Xterm()<CR>'
			exe "imenu  <silent>  ".s:BASH_RootMenu.'.&Run.&output:\ VIM->buffer->xterm<Tab>'.esc_mapl.'ro     <C-C>:call BASH_Toggle_Gvim_Xterm()<CR>'
		else
			if s:BASH_OutputGvim == "buffer"
				exe " menu  <silent>  ".s:BASH_RootMenu.'.&Run.&output:\ BUFFER->xterm->vim<Tab>'.esc_mapl.'ro        :call BASH_Toggle_Gvim_Xterm()<CR>'
				exe "imenu  <silent>  ".s:BASH_RootMenu.'.&Run.&output:\ BUFFER->xterm->vim<Tab>'.esc_mapl.'ro   <C-C>:call BASH_Toggle_Gvim_Xterm()<CR>'
			else
				exe " menu  <silent>  ".s:BASH_RootMenu.'.&Run.&output:\ XTERM->vim->buffer<Tab>'.esc_mapl.'ro        :call BASH_Toggle_Gvim_Xterm()<CR>'
				exe "imenu  <silent>  ".s:BASH_RootMenu.'.&Run.&output:\ XTERM->vim->buffer<Tab>'.esc_mapl.'ro   <C-C>:call BASH_Toggle_Gvim_Xterm()<CR>'
			endif
		endif
	endif
	"
 	"-------------------------------------------------------------------------------
 	" comments     {{{2
 	"-------------------------------------------------------------------------------
	exe " noremenu ".s:BASH_RootMenu.'.&Comments.&echo\ "<line>"<Tab>'.esc_mapl.'ce       :call <SID>EchoComment()<CR>j'
	exe "inoremenu ".s:BASH_RootMenu.'.&Comments.&echo\ "<line>"<Tab>'.esc_mapl.'ce  <C-C>:call <SID>EchoComment()<CR>j'
	exe " noremenu ".s:BASH_RootMenu.'.&Comments.&remove\ echo<Tab>'.esc_mapl.'cr         :call <SID>RemoveEcho()<CR>j'
	exe "inoremenu ".s:BASH_RootMenu.'.&Comments.&remove\ echo<Tab>'.esc_mapl.'cr    <C-C>:call <SID>RemoveEcho()<CR>j'
	"
 	"-------------------------------------------------------------------------------
 	" help     {{{2
 	"-------------------------------------------------------------------------------
	"
	exe " menu  <silent>  ".s:BASH_RootMenu.'.&Help.&Bash\ manual<Tab>'.esc_mapl.'hb                    :call BASH_help("bash")<CR>'
	exe "imenu  <silent>  ".s:BASH_RootMenu.'.&Help.&Bash\ manual<Tab>'.esc_mapl.'hb               <C-C>:call BASH_help("bash")<CR>'
	"
	exe " menu  <silent>  ".s:BASH_RootMenu.'.&Help.&help\ (Bash\ builtins)<Tab>'.esc_mapl.'hh          :call BASH_help("help")<CR>'
	exe "imenu  <silent>  ".s:BASH_RootMenu.'.&Help.&help\ (Bash\ builtins)<Tab>'.esc_mapl.'hh     <C-C>:call BASH_help("help")<CR>'
	"
	exe " menu  <silent>  ".s:BASH_RootMenu.'.&Help.&manual\ (utilities)<Tab>'.esc_mapl.'hm             :call BASH_help("man")<CR>'
	exe "imenu  <silent>  ".s:BASH_RootMenu.'.&Help.&manual\ (utilities)<Tab>'.esc_mapl.'hm        <C-C>:call BASH_help("man")<CR>'
	"
	exe " menu  <silent>  ".s:BASH_RootMenu.'.&Help.-SEP1-                                              :'
	exe " menu  <silent>  ".s:BASH_RootMenu.'.&Help.help\ (Bash-&Support)<Tab>'.esc_mapl.'hbs           :call <SID>HelpPlugin()<CR>'
	exe "imenu  <silent>  ".s:BASH_RootMenu.'.&Help.help\ (Bash-&Support)<Tab>'.esc_mapl.'hbs      <C-C>:call <SID>HelpPlugin()<CR>'
	" }}}2
	"-------------------------------------------------------------------------------

endfunction    " ----------  end of function s:InitMenus  ----------

"===  FUNCTION  ================================================================
"          NAME:  CreateAdditionalMaps     {{{1
"   DESCRIPTION:  create additional maps
"    PARAMETERS:  -
"       RETURNS:
"===============================================================================
function! s:CreateAdditionalMaps ()
	"
	" ---------- Bash dictionary -------------------------------------------------
	" This will enable keyword completion for Bash
	" using Vim's dictionary feature |i_CTRL-X_CTRL-K|.
	"
	if exists("g:BASH_Dictionary_File")
		silent! exe 'setlocal dictionary+='.g:BASH_Dictionary_File
	endif
	"
	"-------------------------------------------------------------------------------
	" USER DEFINED COMMANDS
	"-------------------------------------------------------------------------------
	command! -buffer -nargs=* -complete=file BashScriptArguments  call BASH_ScriptCmdLineArguments(<q-args>)
	command! -buffer -nargs=* -complete=file BashArguments        call BASH_BashCmdLineArguments(<q-args>)
	"
	"-------------------------------------------------------------------------------
	" settings - local leader
	"-------------------------------------------------------------------------------
	if ! empty ( g:BASH_MapLeader )
		if exists ( 'g:maplocalleader' )
			let ll_save = g:maplocalleader
		endif
		let g:maplocalleader = g:BASH_MapLeader
	endif
	"
	"-------------------------------------------------------------------------------
	" comments
	"-------------------------------------------------------------------------------
	nnoremap  <buffer>  <silent>  <LocalLeader>cl         :call <SID>EndOfLineComment()<CR>
	inoremap  <buffer>  <silent>  <LocalLeader>cl    <C-C>:call <SID>EndOfLineComment()<CR>
	vnoremap  <buffer>  <silent>  <LocalLeader>cl         :call <SID>EndOfLineComment()<CR>
	"
	nnoremap  <buffer>  <silent>  <LocalLeader>cj         :call <SID>AdjustLineEndComm()<CR>
	inoremap  <buffer>  <silent>  <LocalLeader>cj    <C-C>:call <SID>AdjustLineEndComm()<CR>
	vnoremap  <buffer>  <silent>  <LocalLeader>cj         :call <SID>AdjustLineEndComm()<CR>
	"
	nnoremap  <buffer>  <silent>  <LocalLeader>cs         :call <SID>GetLineEndCommCol()<CR>
	inoremap  <buffer>  <silent>  <LocalLeader>cs    <C-C>:call <SID>GetLineEndCommCol()<CR>
	vnoremap  <buffer>  <silent>  <LocalLeader>cs    <C-C>:call <SID>GetLineEndCommCol()<CR>

	nnoremap  <buffer>  <silent>  <LocalLeader>cc         :call <SID>CodeComment()<CR>
	inoremap  <buffer>  <silent>  <LocalLeader>cc    <C-C>:call <SID>CodeComment()<CR>
	vnoremap  <buffer>  <silent>  <LocalLeader>cc         :call <SID>CodeComment()<CR>

	nnoremap  <buffer>  <silent>  <LocalLeader>co         :call <SID>CommentCode(0)<CR>
	inoremap  <buffer>  <silent>  <LocalLeader>co    <C-C>:call <SID>CommentCode(0)<CR>
	vnoremap  <buffer>  <silent>  <LocalLeader>co         :call <SID>CommentCode(0)<CR>

	" :TODO:17.03.2016 12:16:WM: old maps '\cu' for backwards compatibility,
	" deprecate this eventually
	nnoremap  <buffer>  <silent>  <LocalLeader>cu         :call <SID>CommentCode(0)<CR>
	inoremap  <buffer>  <silent>  <LocalLeader>cu    <C-C>:call <SID>CommentCode(0)<CR>
	vnoremap  <buffer>  <silent>  <LocalLeader>cu         :call <SID>CommentCode(0)<CR>

   noremap  <buffer>  <silent>  <LocalLeader>ce         :call <SID>EchoComment()<CR>j'
  inoremap  <buffer>  <silent>  <LocalLeader>ce    <C-C>:call <SID>EchoComment()<CR>j'
   noremap  <buffer>  <silent>  <LocalLeader>cr         :call <SID>RemoveEcho()<CR>j'
  inoremap  <buffer>  <silent>  <LocalLeader>cr    <C-C>:call <SID>RemoveEcho()<CR>j'

	"-------------------------------------------------------------------------------
	" snippets
	"-------------------------------------------------------------------------------

	nnoremap    <buffer>  <silent>  <LocalLeader>nr         :call <SID>CodeSnippet("insert")<CR>
	inoremap    <buffer>  <silent>  <LocalLeader>nr    <Esc>:call <SID>CodeSnippet("insert")<CR>
	nnoremap    <buffer>  <silent>  <LocalLeader>nw         :call <SID>CodeSnippet("create")<CR>
	inoremap    <buffer>  <silent>  <LocalLeader>nw    <Esc>:call <SID>CodeSnippet("create")<CR>
	vnoremap    <buffer>  <silent>  <LocalLeader>nw    <Esc>:call <SID>CodeSnippet("vcreate")<CR>
	nnoremap    <buffer>  <silent>  <LocalLeader>ne         :call <SID>CodeSnippet("edit")<CR>
	inoremap    <buffer>  <silent>  <LocalLeader>ne    <Esc>:call <SID>CodeSnippet("edit")<CR>
	nnoremap    <buffer>  <silent>  <LocalLeader>nv         :call <SID>CodeSnippet("view")<CR>
	inoremap    <buffer>  <silent>  <LocalLeader>nv    <Esc>:call <SID>CodeSnippet("view")<CR>

	"-------------------------------------------------------------------------------
	"   run
	"-------------------------------------------------------------------------------
	"
	 noremap    <buffer>  <silent>  <LocalLeader>rr        :call BASH_Run("n")<CR>
	inoremap    <buffer>  <silent>  <LocalLeader>rr   <Esc>:call BASH_Run("n")<CR>
	vnoremap    <buffer>  <silent>  <LocalLeader>rr   <Esc>:call BASH_Run("v")<CR>
	 noremap    <buffer>  <silent>  <LocalLeader>rc        :call BASH_SyntaxCheck()<CR>
	inoremap    <buffer>  <silent>  <LocalLeader>rc   <C-C>:call BASH_SyntaxCheck()<CR>
	 noremap    <buffer>  <silent>  <LocalLeader>rco       :call BASH_SyntaxCheckOptionsLocal()<CR>
	inoremap    <buffer>  <silent>  <LocalLeader>rco  <C-C>:call BASH_SyntaxCheckOptionsLocal()<CR>
	 noremap    <buffer>            <LocalLeader>ra        :BashScriptArguments<Space>
	inoremap    <buffer>            <LocalLeader>ra   <Esc>:BashScriptArguments<Space>
   noremap    <buffer>            <LocalLeader>rba       :BashArguments<Space>
 	inoremap    <buffer>            <LocalLeader>rba  <Esc>:BashArguments<Space>

	if s:UNIX
		nnoremap    <buffer>  <silent>  <LocalLeader>re        :call <SID>MakeExecutable()<CR>
		inoremap    <buffer>  <silent>  <LocalLeader>re   <C-C>:call <SID>MakeExecutable()<CR>
		vnoremap    <buffer>  <silent>  <LocalLeader>re   <C-C>:call <SID>MakeExecutable()<CR>
	endif
	nnoremap    <buffer>  <silent>  <LocalLeader>rh        :call <SID>Hardcopy("n")<CR>
	vnoremap    <buffer>  <silent>  <LocalLeader>rh   <C-C>:call <SID>Hardcopy("v")<CR>

   noremap  <buffer>  <silent>  <C-F9>        :call BASH_Run("n")<CR>
  inoremap  <buffer>  <silent>  <C-F9>   <C-C>:call BASH_Run("n")<CR>
  vnoremap  <buffer>  <silent>  <C-F9>   <C-C>:call BASH_Run("v")<CR>
		"
   noremap  <buffer>  <silent>  <A-F9>        :call BASH_SyntaxCheck()<CR>
  inoremap  <buffer>  <silent>  <A-F9>   <C-C>:call BASH_SyntaxCheck()<CR>
  "
  noremap   <buffer>            <S-F9>        :BashScriptArguments<Space>
  inoremap  <buffer>            <S-F9>   <C-C>:BashScriptArguments<Space>

	if s:MSWIN
 		 noremap  <buffer>  <silent>  <LocalLeader>ro           :call BASH_Toggle_Gvim_Xterm_MS()<CR>
		inoremap  <buffer>  <silent>  <LocalLeader>ro      <Esc>:call BASH_Toggle_Gvim_Xterm_MS()<CR>
	else
		 noremap  <buffer>  <silent>  <LocalLeader>ro           :call BASH_Toggle_Gvim_Xterm()<CR>
		inoremap  <buffer>  <silent>  <LocalLeader>ro      <Esc>:call BASH_Toggle_Gvim_Xterm()<CR>
		 noremap  <buffer>  <silent>  <LocalLeader>rd           :call BASH_Debugger()<CR>
		inoremap  <buffer>  <silent>  <LocalLeader>rd      <Esc>:call BASH_Debugger()<CR>
     noremap  <buffer>  <silent>    <F9>                    :call BASH_Debugger()<CR>
    inoremap  <buffer>  <silent>    <F9>               <C-C>:call BASH_Debugger()<CR>
		if has("gui_running")
			 noremap  <buffer>  <silent>  <LocalLeader>rx         :call BASH_XtermSize()<CR>
			inoremap  <buffer>  <silent>  <LocalLeader>rx    <Esc>:call BASH_XtermSize()<CR>
		endif
	endif
	"
	"-------------------------------------------------------------------------------
	"   help
	"-------------------------------------------------------------------------------
	nnoremap  <buffer>  <silent>  <LocalLeader>rs         :call BASH_Settings(0)<CR>
  "
   noremap  <buffer>  <silent>  <LocalLeader>hb         :call BASH_help('bash')<CR>
  inoremap  <buffer>  <silent>  <LocalLeader>hb    <Esc>:call BASH_help('bash')<CR>
   noremap  <buffer>  <silent>  <LocalLeader>hh         :call BASH_help('help')<CR>
  inoremap  <buffer>  <silent>  <LocalLeader>hh    <Esc>:call BASH_help('help')<CR>
   noremap  <buffer>  <silent>  <LocalLeader>hm         :call BASH_help('man')<CR>
  inoremap  <buffer>  <silent>  <LocalLeader>hm    <Esc>:call BASH_help('man')<CR>
	 noremap  <buffer>  <silent>  <LocalLeader>hbs        :call <SID>HelpPlugin()<CR>
	inoremap  <buffer>  <silent>  <LocalLeader>hbs   <C-C>:call <SID>HelpPlugin()<CR>

	"-------------------------------------------------------------------------------
	" settings - reset local leader
	"-------------------------------------------------------------------------------
	if ! empty ( g:BASH_MapLeader )
		if exists ( 'll_save' )
			let g:maplocalleader = ll_save
		else
			unlet g:maplocalleader
		endif
	endif

	"-------------------------------------------------------------------------------
	" templates
	"-------------------------------------------------------------------------------
	if s:BASH_Ctrl_j == 'yes'
		nnoremap  <buffer>  <silent>  <C-j>       i<C-R>=<SID>JumpForward()<CR>
		inoremap  <buffer>  <silent>  <C-j>  <C-g>u<C-R>=<SID>JumpForward()<CR>
	endif

	if s:BASH_Ctrl_d == 'yes'
		call mmtemplates#core#CreateMaps ( 'g:BASH_Templates', g:BASH_MapLeader, 'do_special_maps', 'do_del_opt_map' )
	else
		call mmtemplates#core#CreateMaps ( 'g:BASH_Templates', g:BASH_MapLeader, 'do_special_maps' )
	endif

endfunction    " ----------  end of function s:CreateAdditionalMaps  ----------

"===  FUNCTION  ================================================================
"          NAME:  BASH_help     {{{1
"   DESCRIPTION:  lookup word under the cursor or ask
"    PARAMETERS:  -
"       RETURNS:
"===============================================================================
let s:BASH_DocBufferName       = "BASH_HELP"
let s:BASH_DocHelpBufferNumber = -1

let s:BuiltinList = []

function! BASH_help( type )

	let cuc		= getline(".")[col(".") - 1]		" character under the cursor
	let	item	= expand("<cword>")							" word under the cursor
	if empty(item) || match( item, cuc ) == -1
		if a:type == 'man'
			let item = s:UserInput('[tab compl. on] name of command line utility : ', '', 'shellcmd' )
		endif
		if a:type == 'help'
			let item = s:UserInput('[tab compl. on] name of bash builtin : ', '', 'customlist', s:BuiltinList )
		endif
	endif

	if empty(item) &&  a:type != 'bash'
		return
	endif
	"------------------------------------------------------------------------------
	"  replace buffer content with bash help text
	"------------------------------------------------------------------------------
	"
	" jump to an already open bash help window or create one
	"
	if bufloaded(s:BASH_DocBufferName) != 0 && bufwinnr(s:BASH_DocHelpBufferNumber) != -1
		exe bufwinnr(s:BASH_DocHelpBufferNumber) . "wincmd w"
		" buffer number may have changed, e.g. after a 'save as'
		if bufnr("%") != s:BASH_DocHelpBufferNumber
			let s:BASH_DocHelpBufferNumber=bufnr(s:BASH_OutputBufferName)
			exe ":bn ".s:BASH_DocHelpBufferNumber
		endif
	else
		exe ":new ".s:BASH_DocBufferName
		let s:BASH_DocHelpBufferNumber=bufnr("%")
		setlocal buftype=nofile
		setlocal noswapfile
		setlocal bufhidden=delete
		setlocal syntax=OFF
	endif
	setlocal	modifiable

	" :WORKAROUND:05.04.2016 21:05:WM: setting the filetype changes the global tabstop,
	" handle this manually
	let ts_save = &g:tabstop

	setlocal filetype=man

	let &g:tabstop = ts_save

	"-------------------------------------------------------------------------------
	" read Bash help
	"-------------------------------------------------------------------------------
	if a:type == 'help'
		setlocal wrap
		if s:UNIX 
			silent exe ":%!help -m ".item
		else
			silent exe ":%!".s:BASH_Executable." -c 'help -m ".item."'"
		endif
		setlocal nomodifiable
		return
	endif
	"
	"-------------------------------------------------------------------------------
	" open a manual (utilities)
	"-------------------------------------------------------------------------------
	if a:type == 'man'
		"
		" Is there more than one manual ?
		"
		let manpages	= system( s:BASH_ManualReader.' -k '.item )
		if v:shell_error
			echomsg	"shell command '".s:BASH_ManualReader." -k ".item."' failed"
			:close
			return
		endif
		let	catalogs	= split( manpages, '\n', )
		let	manual		= {}
		"
		" Select manuals where the name exactly matches
		"
		for line in catalogs
			if line =~ '^'.item.'\s\+('
				let	itempart	= split( line, '\s\+' )
				let	catalog		= itempart[1][1:-2]
				let	manual[catalog]	= catalog
			endif
		endfor
		"
		" Build a selection list if there are more than one manual
		"
		let	catalog	= ""
		if len(keys(manual)) > 1
			for key in keys(manual)
				echo ' '.item.'  '.key
			endfor
			let defaultcatalog	= ''
			if has_key( manual, '1' )
				let defaultcatalog	= '1'
			else
				if has_key( manual, '8' )
					let defaultcatalog	= '8'
				endif
			endif
			let	catalog	= input( 'select manual section (<Enter> cancels) : ', defaultcatalog )
			if ! has_key( manual, catalog )
				:close
				:redraw
				echomsg	"no appropriate manual section '".catalog."'"
				return
			endif
		endif
	endif

	"-------------------------------------------------------------------------------
	" open the bash manual
	"-------------------------------------------------------------------------------
	if a:type == 'bash'
		let	catalog	= 1
		let	item		= 'bash'
	endif

	let win_w = winwidth( winnr() )
	if s:UNIX && win_w > 0
			silent exe ":%! MANWIDTH=".win_w." ".s:BASH_ManualReader." ".catalog." ".item
		else
			silent exe ":%!".s:BASH_ManualReader." ".catalog." ".item
		endif

	if s:MSWIN
		call s:bash_RemoveSpecialCharacters()
	endif

	setlocal nomodifiable
endfunction		" ---------- end of function  BASH_help  ----------
"
"===  FUNCTION  ================================================================
"          NAME:  Bash_RemoveSpecialCharacters     {{{1
"   DESCRIPTION:  remove <backspace><any character> in CYGWIN man(1) output
"    PARAMETERS:  -
"       RETURNS:
"===============================================================================
function! s:bash_RemoveSpecialCharacters ( )
	let	patternunderline	= '_\%x08'
	let	patternbold				= '\%x08.'
	setlocal modifiable
	if search(patternunderline) != 0
		silent exe ':%s/'.patternunderline.'//g'
	endif
	if search(patternbold) != 0
		silent exe ':%s/'.patternbold.'//g'
	endif
	setlocal nomodifiable
	silent normal! gg
endfunction		" ---------- end of function  s:bash_RemoveSpecialCharacters   ----------
"
"------------------------------------------------------------------------------
"  Bash shopt options
"------------------------------------------------------------------------------
"
"===  FUNCTION  ================================================================
"          NAME:  Bash_find_option     {{{1
"   DESCRIPTION:  check if local options does exist
"    PARAMETERS:  -
"       RETURNS:
"===============================================================================
function! s:bash_find_option ( list, option )
	for item in a:list
		if item == a:option
			return 0
		endif
	endfor
	return -1
endfunction    " ----------  end of function s:bash_find_option  ----------
"
"===  FUNCTION  ================================================================
"          NAME:  BASH_SyntaxCheckOptions     {{{1
"   DESCRIPTION:  Syntax Check, options
"    PARAMETERS:  -
"       RETURNS:
"===============================================================================
function! BASH_SyntaxCheckOptions( options )
	let startpos=0
	while startpos < strlen( a:options )
		" match option switch ' -O ' or ' +O '
		let startpos		= matchend ( a:options, '\s*[+-]O\s\+', startpos )
		" match option name
		let optionname	= matchstr ( a:options, '\h\w*\s*', startpos )
		" remove trailing whitespaces
		let optionname  = substitute ( optionname, '\s\+$', "", "" )
		" check name
		" increment start position for next search
		let startpos		=  matchend  ( a:options, '\h\w*\s*', startpos )
	endwhile
	return 0
endfunction		" ---------- end of function  BASH_SyntaxCheckOptions----------
"
"===  FUNCTION  ================================================================
"          NAME:  BASH_SyntaxCheckOptionsLocal     {{{1
"   DESCRIPTION:  Syntax Check, local options
"    PARAMETERS:  -
"       RETURNS:
"===============================================================================
function! BASH_SyntaxCheckOptionsLocal ()
	let filename = expand("%")
  if empty(filename)
		redraw
		echohl WarningMsg | echo " no file name or not a shell file " | echohl None
		return
  endif
	let	prompt	= 'syntax check options for "'.filename.'" : '

	if exists("b:BASH_SyntaxCheckOptionsLocal")
		let b:BASH_SyntaxCheckOptionsLocal = s:UserInput( prompt, b:BASH_SyntaxCheckOptionsLocal, '' )
	else
		let b:BASH_SyntaxCheckOptionsLocal = s:UserInput( prompt , "", '' )
	endif

	if BASH_SyntaxCheckOptions( b:BASH_SyntaxCheckOptionsLocal ) != 0
		let b:BASH_SyntaxCheckOptionsLocal	= ""
	endif
endfunction		" ---------- end of function  BASH_SyntaxCheckOptionsLocal  ----------
"
"===  FUNCTION  ================================================================
"          NAME:  BASH_Settings     {{{1
"   DESCRIPTION:  Display plugin settings
"    PARAMETERS:  -
"       RETURNS:
"===============================================================================
function! BASH_Settings ( verbose )

	if     s:MSWIN | let sys_name = 'Windows'
	elseif s:UNIX  | let sys_name = 'UN*X'
	else           | let sys_name = 'unknown' | endif

	let	txt = " Bash-Support settings\n\n"
	" template settings: macros, style, ...
	if exists ( 'g:BASH_Templates' )
		let txt .= '                   author :  "'.mmtemplates#core#ExpandText( g:BASH_Templates, '|AUTHOR|'       )."\"\n"
		let txt .= '                authorref :  "'.mmtemplates#core#ExpandText( g:BASH_Templates, '|AUTHORREF|'    )."\"\n"
		let txt .= '                    email :  "'.mmtemplates#core#ExpandText( g:BASH_Templates, '|EMAIL|'        )."\"\n"
		let txt .= '             organization :  "'.mmtemplates#core#ExpandText( g:BASH_Templates, '|ORGANIZATION|' )."\"\n"
		let txt .= '         copyright holder :  "'.mmtemplates#core#ExpandText( g:BASH_Templates, '|COPYRIGHT|'    )."\"\n"
		let txt .= '                  license :  "'.mmtemplates#core#ExpandText( g:BASH_Templates, '|LICENSE|'      )."\"\n"
		let txt .= '                  project :  "'.mmtemplates#core#ExpandText( g:BASH_Templates, '|PROJECT|'     )."\"\n"
		let txt .= '           template style :  "'.mmtemplates#core#Resource ( g:BASH_Templates, "style" )[0]."\"\n\n"
	else
		let txt .= "                templates :  -not loaded-\n\n"
	endif
	" plug-in installation
	let txt .= '      plugin installation :  '.s:installation.' on '.sys_name."\n"
	let txt .= "\n"
	" templates, snippets
	if exists ( 'g:BASH_Templates' )
		let [ templist, msg ] = mmtemplates#core#Resource ( g:BASH_Templates, 'template_list' )
		let sep  = "\n"."                             "
		let txt .=      "           template files :  "
					\ .join ( templist, sep )."\n"
	else
		let txt .= "           template files :  -not loaded-\n"
	endif
	let txt .=
				\  '       code snippets dir. :  '.s:BASH_CodeSnippets."\n"
	" ----- dictionaries ------------------------
	if !empty(g:BASH_Dictionary_File)
		let ausgabe= &dictionary
		let ausgabe= substitute( ausgabe, ",", ",\n                             ", "g" )
		let txt = txt."       dictionary file(s) :  ".ausgabe."\n"
	endif
	" ----- map leader, menus, file headers -----
	if a:verbose >= 1
		let	txt .= "\n"
					\ .'                mapleader :  "'.g:BASH_MapLeader."\"\n"
					\ .'     load menus / delayed :  "'.s:BASH_LoadMenus.'" / "'.s:BASH_CreateMenusDelayed."\"\n"
					\ .'       insert file header :  "'.s:BASH_InsertFileHeader."\"\n"
	endif
	let txt .= "\n"
	" ----- executables, cmd.-line args, ... -------
	if exists( "b:BASH_BashCmdLineArgs" )
		let cmd_line_args = b:BASH_BashCmdLineArgs
	else
		let cmd_line_args = ''
	endif
	if exists("b:BASH_SyntaxCheckOptionsLocal")
		let syn_check_args = b:BASH_SyntaxCheckOptionsLocal
	else
		let syn_check_args = ''
	endif
	let txt .= '          Bash executable :  "'.s:BASH_Executable."\"\n"
	let txt .= ' Bash cmd. line arguments :  "'.cmd_line_args."\"\n"
	let txt .= 'glb. syntax check options :  "'.s:BASH_SyntaxCheckOptionsGlob."\"\n"
	let txt .= 'buf. syntax check options :  "'.syn_check_args."\"\n"
	let txt = txt."\n"
	" ----- output ------------------------------
	let txt = txt.'     current output dest. :  '.s:BASH_OutputGvim."\n"
	if !s:MSWIN
		let txt = txt.'           xterm defaults :  '.s:BASH_XtermDefaults."\n"
	endif
	let	txt = txt."__________________________________________________________________________\n"
	let	txt = txt." Bash-Support, Version ".g:BASH_Version." / Wolfgang Mehner / wolfgang-mehner@web.de\n\n"

	if a:verbose == 2
		split BashSupport_Settings.txt
		put = txt
	else
		echo txt
	endif
endfunction    " ----------  end of function BASH_Settings ----------

"===  FUNCTION  ================================================================
"          NAME:  BASH_Toggle_Gvim_Xterm     {{{1
"   DESCRIPTION:  toggle output destination (Linux/Unix)
"    PARAMETERS:  -
"       RETURNS:
"===============================================================================
function! BASH_Toggle_Gvim_Xterm ()

	if has("gui_running")
		let [ esc_mapl, err ] = mmtemplates#core#Resource ( g:BASH_Templates, 'escaped_mapleader' )
		if s:BASH_OutputGvim == "vim"
			exe "aunmenu  <silent>  ".s:BASH_RootMenu.'.&Run.&output:\ VIM->buffer->xterm'
			exe " menu    <silent>  ".s:BASH_RootMenu.'.&Run.&output:\ BUFFER->xterm->vim<Tab>'.esc_mapl.'ro          :call BASH_Toggle_Gvim_Xterm()<CR>'
			exe "imenu    <silent>  ".s:BASH_RootMenu.'.&Run.&output:\ BUFFER->xterm->vim<Tab>'.esc_mapl.'ro     <C-C>:call BASH_Toggle_Gvim_Xterm()<CR>'
			let	s:BASH_OutputGvim	= "buffer"
		else
			if s:BASH_OutputGvim == "buffer"
				exe "aunmenu  <silent>  ".s:BASH_RootMenu.'.&Run.&output:\ BUFFER->xterm->vim'
				exe " menu    <silent>  ".s:BASH_RootMenu.'.&Run.&output:\ XTERM->vim->buffer<Tab>'.esc_mapl.'ro        :call BASH_Toggle_Gvim_Xterm()<CR>'
				exe "imenu    <silent>  ".s:BASH_RootMenu.'.&Run.&output:\ XTERM->vim->buffer<Tab>'.esc_mapl.'ro   <C-C>:call BASH_Toggle_Gvim_Xterm()<CR>'
				let	s:BASH_OutputGvim	= "xterm"
			else
				" ---------- output : xterm -> gvim
				exe "aunmenu  <silent>  ".s:BASH_RootMenu.'.&Run.&output:\ XTERM->vim->buffer'
				exe " menu    <silent>  ".s:BASH_RootMenu.'.&Run.&output:\ VIM->buffer->xterm<Tab>'.esc_mapl.'ro        :call BASH_Toggle_Gvim_Xterm()<CR>'
				exe "imenu    <silent>  ".s:BASH_RootMenu.'.&Run.&output:\ VIM->buffer->xterm<Tab>'.esc_mapl.'ro   <C-C>:call BASH_Toggle_Gvim_Xterm()<CR>'
				let	s:BASH_OutputGvim	= "vim"
			endif
		endif
	else
		if s:BASH_OutputGvim == "vim"
			let	s:BASH_OutputGvim	= "buffer"
		else
			let	s:BASH_OutputGvim	= "vim"
		endif
	endif
	echomsg "output destination is '".s:BASH_OutputGvim."'"

endfunction    " ----------  end of function BASH_Toggle_Gvim_Xterm ----------
"
"===  FUNCTION  ================================================================
"          NAME:  BASH_Toggle_Gvim_Xterm_MS     {{{1
"   DESCRIPTION:  toggle output destination (Windows)
"    PARAMETERS:  -
"       RETURNS:
"===============================================================================
function! BASH_Toggle_Gvim_Xterm_MS ()
	if has("gui_running")
		let [ esc_mapl, err ] = mmtemplates#core#Resource ( g:BASH_Templates, 'escaped_mapleader' )
		if s:BASH_OutputGvim == "buffer"
			exe "aunmenu  <silent>  ".s:BASH_RootMenu.'.&Run.&output:\ BUFFER->term'
			exe " menu    <silent>  ".s:BASH_RootMenu.'.&Run.&output:\ TERM->buffer<Tab>'.esc_mapl.'ro         :call BASH_Toggle_Gvim_Xterm_MS()<CR>'
			exe "imenu    <silent>  ".s:BASH_RootMenu.'.&Run.&output:\ TERM->buffer<Tab>'.esc_mapl.'ro    <C-C>:call BASH_Toggle_Gvim_Xterm_MS()<CR>'
			let	s:BASH_OutputGvim	= "xterm"
		else
			exe "aunmenu  <silent>  ".s:BASH_RootMenu.'.&Run.&output:\ TERM->buffer'
			exe " menu    <silent>  ".s:BASH_RootMenu.'.&Run.&output:\ BUFFER->term<Tab>'.esc_mapl.'ro         :call BASH_Toggle_Gvim_Xterm_MS()<CR>'
			exe "imenu    <silent>  ".s:BASH_RootMenu.'.&Run.&output:\ BUFFER->term<Tab>'.esc_mapl.'ro    <C-C>:call BASH_Toggle_Gvim_Xterm_MS()<CR>'
			let	s:BASH_OutputGvim	= "buffer"
		endif
	endif
endfunction    " ----------  end of function BASH_Toggle_Gvim_Xterm_MS ----------
"
"===  FUNCTION  ================================================================
"          NAME:  BASH_XtermSize     {{{1
"   DESCRIPTION:  set xterm size
"    PARAMETERS:  -
"       RETURNS:
"===============================================================================
function! BASH_XtermSize ()
	let regex	= '-geometry\s\+\d\+x\d\+'
	let geom	= matchstr( s:BASH_XtermDefaults, regex )
	let geom	= matchstr( geom, '\d\+x\d\+' )
	let geom	= substitute( geom, 'x', ' ', "" )
	let answer = s:UserInput("   xterm size (COLUMNS LINES) : ", geom, '' )
	while match(answer, '^\s*\d\+\s\+\d\+\s*$' ) < 0
		let answer = s:UserInput(" + xterm size (COLUMNS LINES) : ", geom, '' )
	endwhile
	let answer  = substitute( answer, '^\s\+', "", "" )		 				" remove leading whitespaces
	let answer  = substitute( answer, '\s\+$', "", "" )						" remove trailing whitespaces
	let answer  = substitute( answer, '\s\+', "x", "" )						" replace inner whitespaces
	let s:BASH_XtermDefaults	= substitute( s:BASH_XtermDefaults, regex, "-geometry ".answer , "" )
endfunction		" ---------- end of function  BASH_XtermSize  ----------

"===  FUNCTION  ================================================================
"          NAME:  BASH_ScriptCmdLineArguments     {{{1
"   DESCRIPTION:  stringify script command line arguments
"    PARAMETERS:  -
"       RETURNS:
"===============================================================================
function! BASH_ScriptCmdLineArguments ( ... )
	let	b:BASH_ScriptCmdLineArgs	= join( a:000 )
endfunction		" ---------- end of function  BASH_ScriptCmdLineArguments  ----------
"
"===  FUNCTION  ================================================================
"          NAME:  BASH_BashCmdLineArguments     {{{1
"   DESCRIPTION:  stringify Bash command line arguments
"    PARAMETERS:  -
"       RETURNS:
"===============================================================================
function! BASH_BashCmdLineArguments ( ... )
	let	b:BASH_BashCmdLineArgs	= join( a:000 )
endfunction    " ----------  end of function BASH_BashCmdLineArguments ----------
"
"===  FUNCTION  ================================================================
"          NAME:  BASH_Run     {{{1
"   DESCRIPTION:
"    PARAMETERS:  -
"       RETURNS:
"===============================================================================
"
let s:BASH_OutputBufferName   = "Bash-Output"
let s:BASH_OutputBufferNumber = -1
"
function! BASH_Run ( mode ) range

	silent exe ':cclose'
"
	let	l:arguments				= exists("b:BASH_ScriptCmdLineArgs") ? " ".b:BASH_ScriptCmdLineArgs : ""
	let	l:currentbuffer   = bufname("%")
	let l:fullname				= expand("%:p")
	let l:fullnameesc			= fnameescape( l:fullname )
	"
	silent exe ":update"
	"
 	if a:firstline != a:lastline
		let tmpfile	= tempname()
		silent exe ':'.a:firstline.','.a:lastline.'write '.tmpfile
	endif
	"
	if a:mode=="v"
		let tmpfile	= tempname()
		silent exe ":'<,'>write ".tmpfile
	endif

	let l:bashCmdLineArgs	= exists("b:BASH_BashCmdLineArgs") ? ' '.b:BASH_BashCmdLineArgs.' ' : ''
	"
	"------------------------------------------------------------------------------
	"  Run : run from the vim command line (Linux only)     {{{2
	"------------------------------------------------------------------------------
	"
	if s:BASH_OutputGvim == 'vim'
		"
		" ----- visual mode ----------
		"
		if ( a:mode=="v" ) || ( a:firstline != a:lastline )
			exe ":!".s:BASH_Executable.l:bashCmdLineArgs." < ".tmpfile." -s ".l:arguments
			call delete(tmpfile)
			return
		endif
		"
		" ----- normal mode ----------
		"
		" save current settings
		let makeprg_saved = &l:makeprg
		let errorf_saved  = &l:errorformat

		let &l:makeprg     = s:BASH_Executable
		let &l:errorformat = s:BASH_Errorformat

		if a:mode=="n"
			exe ":make ".l:bashCmdLineArgs.l:fullnameesc.l:arguments
		endif
		if &term == 'xterm'
			redraw!
		endif

		" restore current settings
		let &l:makeprg     = makeprg_saved
		let &l:errorformat = errorf_saved

		botright cwindow

		if l:currentbuffer != bufname("%") && a:mode=="n"
			let	pattern	= '^||.*\n\?'
			setlocal modifiable
			" remove the regular script output (appears as comment)
			if search(pattern) != 0
				silent exe ':%s/'.pattern.'//'
			endif
			" read the buffer back to have it parsed and used as the new error list
			silent exe ':cgetbuffer'
			setlocal nomodifiable
			setlocal nomodified
			silent exe	':cc'
		endif
	endif
	"
	"------------------------------------------------------------------------------
	"  Run : redirect output to an output buffer     {{{2
	"------------------------------------------------------------------------------
	if s:BASH_OutputGvim == 'buffer'

		let	l:currentbuffernr = bufnr("%")

		if l:currentbuffer ==  bufname("%")
			"
			if bufloaded(s:BASH_OutputBufferName) != 0 && bufwinnr(s:BASH_OutputBufferNumber)!=-1
				exe bufwinnr(s:BASH_OutputBufferNumber) . "wincmd w"
				" buffer number may have changed, e.g. after a 'save as'
				if bufnr("%") != s:BASH_OutputBufferNumber
					let s:BASH_OutputBufferNumber	= bufnr(s:BASH_OutputBufferName)
					exe ":bn ".s:BASH_OutputBufferNumber
				endif
			else
				silent exe ":new ".s:BASH_OutputBufferName
				let s:BASH_OutputBufferNumber=bufnr("%")
				setlocal noswapfile
				setlocal buftype=nofile
				setlocal syntax=none
				setlocal bufhidden=delete
				setlocal tabstop=8
			endif
			"
			" run script
			"
			setlocal	modifiable
			if a:mode=="n"
				if	s:MSWIN
					silent exe ":%!".s:BASH_Executable.l:bashCmdLineArgs.' "'.l:fullname.'" '.l:arguments
				else
					silent exe ":%!".s:BASH_Executable.l:bashCmdLineArgs." ".l:fullnameesc.l:arguments
				endif
			endif
			"
			if ( a:mode=="v" ) || ( a:firstline != a:lastline )
				silent exe ":%!".s:BASH_Executable.l:bashCmdLineArgs." < ".tmpfile." -s ".l:arguments
			endif
			setlocal	nomodifiable
			"
			" stdout is empty / not empty
			"
			if line("$")==1 && col("$")==1
				silent	exe ":bdelete"
			else
				if winheight(winnr()) >= line("$")
					exe bufwinnr(l:currentbuffernr) . "wincmd w"
				endif
			endif
			"
		endif
	endif
	"
	"------------------------------------------------------------------------------
	"  Run : run in a detached xterm     {{{2
	"------------------------------------------------------------------------------
	if s:BASH_OutputGvim == 'xterm'
		"
		if	s:MSWIN
			exe ':!'.s:BASH_Executable.l:bashCmdLineArgs.' "'.l:fullname.'" '.l:arguments
		else
			if a:mode=='n'
				if a:firstline != a:lastline
					let titlestring	= l:fullnameesc.'\ lines\ \ '.a:firstline.'\ -\ '.a:lastline
					silent exe ':!xterm -title '.titlestring.' '.s:BASH_XtermDefaults
								\			.' -e '.s:BASH_Wrapper.' '.l:bashCmdLineArgs.tmpfile.l:arguments.' &'
				else
					silent exe '!xterm -title '.l:fullnameesc.' '.s:BASH_XtermDefaults
								\			.' -e '.s:BASH_Wrapper.' '.l:bashCmdLineArgs.l:fullnameesc.l:arguments.' &'
				endif
			elseif a:mode=="v"
				let titlestring	= l:fullnameesc.'\ lines\ \ '.line("'<").'\ -\ '.line("'>")
				silent exe ':!xterm -title '.titlestring.' '.s:BASH_XtermDefaults
							\			.' -e '.s:BASH_Wrapper.' '.l:bashCmdLineArgs.tmpfile.l:arguments.' &'
			endif
		endif
		"
	endif
	" }}}2
	"------------------------------------------------------------------------------

	if !has("gui_running") &&  v:progname != 'vim'
		redraw!
	endif
endfunction    " ----------  end of function BASH_Run  ----------
"
"===  FUNCTION  ================================================================
"          NAME:  BASH_SyntaxCheck     {{{1
"   DESCRIPTION:  run syntax check
"    PARAMETERS:  -
"       RETURNS:
"===============================================================================
function! BASH_SyntaxCheck ()

	silent exe 'update'   | " write source file if necessary
	cclose

	" save current settings
	let	makeprg_saved	= &l:makeprg
	let errorf_saved  = &l:errorformat

	let	l:currentbuffer=bufname("%")
	let l:fullname				= expand("%:p")
	"
	" check global syntax check options / reset in case of an error
	if BASH_SyntaxCheckOptions( s:BASH_SyntaxCheckOptionsGlob ) != 0
		let s:BASH_SyntaxCheckOptionsGlob	= ""
	endif
	"
	let	options=s:BASH_SyntaxCheckOptionsGlob
	if exists("b:BASH_SyntaxCheckOptionsLocal")
		let	options=options." ".b:BASH_SyntaxCheckOptionsLocal
	endif
	"
	" match the Bash error messages (quickfix commands)
	" errorformat will be reset by function BASH_Handle()
	" ignore any lines that didn't match one of the patterns

	let &l:makeprg     = s:BASH_Executable
	let &l:errorformat = s:BASH_Errorformat

	silent exe ":make! -n ".options.' -- "'.l:fullname.'"'

	" restore current settings
	let &l:makeprg     = makeprg_saved
	let &l:errorformat = errorf_saved

	botright cwindow

	" message in case of success
	redraw!
	if l:currentbuffer ==  bufname("%")
		echohl Search | echo l:currentbuffer." : Syntax is OK" | echohl None
		nohlsearch						" delete unwanted highlighting (Vim bug?)
	endif
endfunction		" ---------- end of function  BASH_SyntaxCheck  ----------
"
"===  FUNCTION  ================================================================
"          NAME:  BASH_Debugger     {{{1
"   DESCRIPTION:  run debugger
"    PARAMETERS:  -
"       RETURNS:
"===============================================================================
function! BASH_Debugger ()
	if !executable(s:BASH_bashdb)
		echohl Search
		echo   s:BASH_bashdb.' is not executable or not installed! '
		echohl None
		return
	endif
	"
	silent exe	":update"
	let	l:arguments	= exists("b:BASH_ScriptCmdLineArgs") ? " ".b:BASH_ScriptCmdLineArgs : ""
	let	Sou					= fnameescape( expand("%:p") )
	"
	"
	if has("gui_running") || &term == "xterm"
		"
		" debugger is ' bashdb'
		"
		if s:BASH_Debugger == "term"
			let dbcommand	= "!xterm ".s:BASH_XtermDefaults.' -e '.s:BASH_bashdb.' -- '.Sou.l:arguments.' &'
			silent exe dbcommand
		endif
		"
		" debugger is 'ddd'
		"
		if s:BASH_Debugger == "ddd"
			if !executable("ddd")
				echohl WarningMsg
				echo "The debugger 'ddd' does not exist or is not executable!"
				echohl None
				return
			else
				silent exe '!ddd --debugger '.s:BASH_bashdb.' '.Sou.l:arguments.' &'
			endif
		endif
	else
		" no GUI : debugger is ' bashdb'
		silent exe '!'.s:BASH_bashdb.' -- '.Sou.l:arguments
	endif
endfunction		" ---------- end of function  BASH_Debugger  ----------

"-------------------------------------------------------------------------------
" s:ToolMenu : Add or remove tool menu entries.   {{{1
"-------------------------------------------------------------------------------
function! s:ToolMenu( action )

	if ! has ( 'menu' )
		return
	endif

	if a:action == 'setup'
		anoremenu <silent> 40.1000 &Tools.-SEP100- :
		anoremenu <silent> 40.1020 &Tools.Load\ Bash\ Support   :call <SID>AddMenus()<CR>
	elseif a:action == 'load'
		aunmenu   <silent> &Tools.Load\ Bash\ Support
		anoremenu <silent> 40.1020 &Tools.Unload\ Bash\ Support :call <SID>RemoveMenus()<CR>
	elseif a:action == 'unload'
		aunmenu   <silent> &Tools.Unload\ Bash\ Support
		anoremenu <silent> 40.1020 &Tools.Load\ Bash\ Support   :call <SID>AddMenus()<CR>
		exe 'aunmenu <silent> '.s:BASH_RootMenu
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

"----------------------------------------------------------------------
" === Setup: Templates and menus ===   {{{1
"----------------------------------------------------------------------

" tool menu entry
call s:ToolMenu ( 'setup' )

if s:BASH_LoadMenus == 'yes' && s:BASH_CreateMenusDelayed == 'no'
	call s:AddMenus ()
endif

if has( 'autocmd' )
	"
	"-------------------------------------------------------------------------------
	" shell files with extensions other than 'sh'
	"-------------------------------------------------------------------------------
	if exists( 'g:BASH_AlsoBash' )
		for item in g:BASH_AlsoBash
			exe "autocmd BufNewFile,BufRead  ".item." set filetype=sh"
		endfor
	endif
	"
	"-------------------------------------------------------------------------------
	" create menues and maps
	"-------------------------------------------------------------------------------
  autocmd FileType *
        \ if &filetype == 'sh' |
        \   if ! exists( 'g:BASH_Templates' ) |
        \     if s:BASH_LoadMenus == 'yes' | call s:AddMenus ()  |
        \     else                         | call s:RereadTemplates () |
        \     endif |
        \   endif |
        \   call s:CreateAdditionalMaps () |
				\		call s:CheckTemplatePersonalization() |
        \ endif

	"-------------------------------------------------------------------------------
	" insert file header
	"-------------------------------------------------------------------------------
	if s:BASH_InsertFileHeader == 'yes'
		autocmd BufNewFile  *.sh  call s:InsertFileHeader()
		if exists( 'g:BASH_AlsoBash' )
			for item in g:BASH_AlsoBash
				exe "autocmd BufNewFile ".item." call s:InsertFileHeader()"
			endfor
		endif
	endif

endif
" }}}1
"-------------------------------------------------------------------------------

" =====================================================================================
" vim: tabstop=2 shiftwidth=2 foldmethod=marker
