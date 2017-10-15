"===============================================================================
"
"          File:  latex-support.vim
"
"   Description:  LaTeX support     (VIM Version 7.0+)
"
"                  Write LaTeX scripts by inserting comments, statements,
"                  variables and builtins.
"
"                 See help file latexsupport.txt .
"
"   VIM Version:  7.0+
"
"        Author:  Wolfgang Mehner <wolfgang-mehner@web.de>
"                 (formerly Fritz Mehner <mehner.fritz@web.de>)
"
"       Version:  see variable g:LatexSupportVersion below.
"       Created:  27.12.2012
"      Revision:  25.09.2017
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
	echo 'The plugin latex-support.vim needs Vim version >= 7.'
	echohl None
	finish
endif

" prevent duplicate loading
" need compatible
if exists("g:LatexSupportVersion") || &cp
	finish
endif

let g:LatexSupportVersion= "1.3alpha"                  " version number of this script; do not change

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
	let cs_dir    = s:Latex_CodeSnippets
	let cs_browse = s:Latex_GuiSnippetBrowser

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

	let &g:printheader = g:Latex_Printheader

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

let s:MSWIN = has("win16") || has("win32")   || has("win64") || has("win95")
let s:UNIX	= has("unix")  || has("macunix") || has("win32unix")

let s:NEOVIM = has("nvim")

let s:installation             = '*undefined*'
let s:Latex_GlobalTemplateFile = ''
let s:Latex_LocalTemplateFile  = ''
let s:Latex_CustomTemplateFile = ''             " the custom templates

let s:Latex_Typesetter = 'pdflatex'

let s:Latex_ToolboxDir = []

if s:MSWIN
  " ==========  MS Windows  ======================================================

	" typesetter
	let s:Latex_Latex       = 'latex.exe    -src-specials -file-line-error -interaction=nonstopmode'
	let s:Latex_Tex         = 'tex.exe      -src-specials -file-line-error -interaction=nonstopmode'
	let s:Latex_Pdflatex    = 'pdflatex.exe -src-specials -file-line-error -interaction=nonstopmode'
	let s:Latex_Pdftex      = 'pdftex.exe   -src-specials -file-line-error -interaction=nonstopmode'
	let s:Latex_Lualatex    = 'lualatex.exe --file-line-error --interaction=nonstopmode'
	let s:Latex_Luatex      = 'luatex.exe   --file-line-error --interaction=nonstopmode'
	let s:Latex_Bibtex      = 'bibtex.exe'

	" viewer
	let s:Latex_DviViewer   = 'dviout.exe'
	let s:Latex_PsViewer    = ''
	let s:Latex_PdfViewer   = ''
	"
	" converter
	let s:Latex_DviPdf      = 'dvipdfm.exe'
	let s:Latex_DviPng      = 'dvipng.exe'
	let s:Latex_DviPs       = 'dvips.exe'
	let s:Latex_EpsPdf      = ''
	let s:Latex_PdfPng      = ''
	let s:Latex_PsPdf       = 'ps2pdf.exe'
	"
	let s:plugin_dir = substitute( expand('<sfile>:p:h:h'), '\', '/', 'g' )
	"
	" change '\' to '/' to avoid interpretation as escape character
	if match(	substitute( expand("<sfile>"), '\', '/', 'g' ),
				\		substitute( expand("$HOME"),   '\', '/', 'g' ) ) == 0
		"
		" USER INSTALLATION ASSUMED
		let s:installation             = 'local'
		let s:Latex_LocalTemplateFile  = s:plugin_dir.'/latex-support/templates/Templates'
		let s:Latex_CustomTemplateFile = $HOME.'/vimfiles/templates/latex.templates'
		let s:Latex_ToolboxDir        += [ s:plugin_dir.'/autoload/mmtoolbox/' ]
	else
		"
		" SYSTEM WIDE INSTALLATION
		let s:installation             = 'system'
		let s:Latex_GlobalTemplateFile = s:plugin_dir.'/latex-support/templates/Templates'
		let s:Latex_LocalTemplateFile  = $HOME.'/vimfiles/latex-support/templates/Templates'
		let s:Latex_CustomTemplateFile = $HOME.'/vimfiles/templates/latex.templates'
		let s:Latex_ToolboxDir        += [
					\	s:plugin_dir.'/autoload/mmtoolbox/',
					\	$HOME.'/vimfiles/autoload/mmtoolbox/' ]
	endif
	"
else
  " ==========  Linux/Unix  ======================================================

	" typesetter
	let s:Latex_Latex       = 'latex    -src-specials -file-line-error -interaction=nonstopmode'
	let s:Latex_Tex         = 'tex      -src-specials -file-line-error -interaction=nonstopmode'
	let s:Latex_Pdflatex    = 'pdflatex -src-specials -file-line-error -interaction=nonstopmode'
	let s:Latex_Pdftex      = 'pdftex   -src-specials -file-line-error -interaction=nonstopmode'
	let s:Latex_Lualatex    = 'lualatex --file-line-error --interaction=nonstopmode'
	let s:Latex_Luatex      = 'luatex   --file-line-error --interaction=nonstopmode'
	let s:Latex_Bibtex      = "bibtex"

	" viewer
	let s:Latex_DviViewer   = "xdvi"
	let s:Latex_PsViewer    = "gv"
	let s:Latex_PdfViewer   = "acroread"
	"
	" converter
	let s:Latex_DviPdf      = 'dvipdft'
	let s:Latex_DviPng      = 'dvipng'
	let s:Latex_DviPs       = 'dvips'
	let s:Latex_EpsPdf      = 'ps2pdf -dEPSCrop'
	let s:Latex_PdfPng      = 'convert'
	let s:Latex_PsPdf       = 'ps2pdf'
	"
	let s:plugin_dir = expand('<sfile>:p:h:h')
	"
	if match( expand("<sfile>"), resolve( expand("$HOME") ) ) == 0
		"
		" USER INSTALLATION ASSUMED
		let s:installation             = 'local'
		let s:Latex_LocalTemplateFile  = s:plugin_dir.'/latex-support/templates/Templates'
		let s:Latex_CustomTemplateFile = $HOME.'/.vim/templates/latex.templates'
		let s:Latex_ToolboxDir        += [ s:plugin_dir.'/autoload/mmtoolbox/' ]
	else
		"
		" SYSTEM WIDE INSTALLATION
		let s:installation             = 'system'
		let s:Latex_GlobalTemplateFile = s:plugin_dir.'/latex-support/templates/Templates'
		let s:Latex_LocalTemplateFile  = $HOME.'/.vim/latex-support/templates/Templates'
		let s:Latex_CustomTemplateFile = $HOME.'/.vim/templates/latex.templates'
		let s:Latex_ToolboxDir        += [
					\	s:plugin_dir.'/autoload/mmtoolbox/',
					\	$HOME.'/.vim/autoload/mmtoolbox/' ]
	endif
	"
endif

let s:Latex_AdditionalTemplates = mmtemplates#config#GetFt ( 'latex' )
let s:Latex_CodeSnippets        = s:plugin_dir.'/latex-support/codesnippets/'

"  g:Latex_Dictionary_File  must be global
"
if !exists("g:Latex_Dictionary_File")
	let g:Latex_Dictionary_File     = s:plugin_dir.'/latex-support/wordlists/latex-keywords.list'
endif

"-------------------------------------------------------------------------------
" == Various settings ==   {{{2
"-------------------------------------------------------------------------------

"-------------------------------------------------------------------------------
" User configurable options   {{{3
"-------------------------------------------------------------------------------

let s:escfilename 								= ' \%#[]'
let s:Latex_TexFlavor							= 'latex'
let s:Latex_CreateMenusDelayed		= 'yes'
let s:Latex_GuiSnippetBrowser 		= 'gui'             " gui / commandline
let s:Latex_LoadMenus         		= 'yes'             " load the menus?
let s:Latex_RootMenu          		= 'LaTe&X'          " name of the root menu
let s:Latex_Processing            = 'foreground'
let s:Latex_UseToolbox            = 'yes'
call s:ApplyDefaultSetting ( 'Latex_UseTool_make', 'yes' )

let s:Latex_MainDocument          = ''

if ! exists ( 's:MenuVisible' )
	let s:MenuVisible = 0                        " menus are not visible at the moment
endif
"
let s:Latex_LineEndCommColDefault = 49
let s:Latex_TemplateJumpTarget 		= ''
let s:Latex_Wrapper               = s:plugin_dir.'/latex-support/scripts/wrapper.sh'
let s:Latex_InsertFileProlog      = 'yes'
let s:Latex_Ctrl_j                = 'yes'
let s:Latex_Ctrl_d                = 'yes'

let s:Latex_LatexErrorf  = '%f:%l: %m'
let s:Latex_BibtexErrorf =
			\      '%+PDatabase file #%\\d%\\+: %f'
			\ .','.'%m---line %l of file %f'
			\ .','.'Warning--%m'
			\ .','.'--line %l of file %f'

"-------------------------------------------------------------------------------
" Get user configuration   {{{3
"-------------------------------------------------------------------------------

call s:GetGlobalSetting( 'Latex_CustomTemplateFile' )
call s:GetGlobalSetting( 'Latex_CreateMenusDelayed' )
call s:GetGlobalSetting( 'Latex_DviPdf' )
call s:GetGlobalSetting( 'Latex_DviPng' )
call s:GetGlobalSetting( 'Latex_DviPs' )
call s:GetGlobalSetting( 'Latex_DviViewer' )
call s:GetGlobalSetting( 'Latex_GlobalTemplateFile' )
call s:GetGlobalSetting( 'Latex_CodeSnippets' )
call s:GetGlobalSetting( 'Latex_Ctrl_j' )
call s:GetGlobalSetting( 'Latex_Ctrl_d' )
call s:GetGlobalSetting( 'Latex_EpsPdf' )
call s:GetGlobalSetting( 'Latex_GuiSnippetBrowser' )
call s:GetGlobalSetting( 'Latex_InsertFileProlog' )
call s:GetGlobalSetting( 'Latex_Latex' )
call s:GetGlobalSetting( 'Latex_LineEndCommColDefault' )
call s:GetGlobalSetting( 'Latex_LoadMenus' )
call s:GetGlobalSetting( 'Latex_LocalTemplateFile' )
call s:GetGlobalSetting( 'Latex_Lualatex' )
call s:GetGlobalSetting( 'Latex_Luatex' )
call s:GetGlobalSetting( 'Latex_PdfPng' )
call s:GetGlobalSetting( 'Latex_PdfViewer' )
call s:GetGlobalSetting( 'Latex_Pdflatex' )
call s:GetGlobalSetting( 'Latex_Pdftex' )
call s:GetGlobalSetting( 'Latex_Processing' )
call s:GetGlobalSetting( 'Latex_PsPdf' )
call s:GetGlobalSetting( 'Latex_PsViewer' )
call s:GetGlobalSetting( 'Latex_RootMenu' )
call s:GetGlobalSetting( 'Latex_Tex' )
call s:GetGlobalSetting( 'Latex_TexFlavor' )
call s:GetGlobalSetting( 'Latex_Typesetter' )
call s:GetGlobalSetting( 'Latex_UseToolbox' )

" overwrite the mapleader, we should not use use "\" in LaTeX
call s:ApplyDefaultSetting ( 'Latex_MapLeader', '´' )
call s:ApplyDefaultSetting ( 'Latex_Printheader',  "%<%f%h%m%<  %=%{strftime('%x %X')}     Page %N" )

"-------------------------------------------------------------------------------
" Internal variables   {{{3
"-------------------------------------------------------------------------------

let s:Latex_TypesetterCall = {
			\ 'latex'    : s:Latex_Latex   ,
			\ 'tex'      : s:Latex_Tex     ,
			\ 'pdflatex' : s:Latex_Pdflatex,
			\ 'pdftex'   : s:Latex_Pdftex  ,
			\ 'lualatex' : s:Latex_Lualatex,
			\ 'luatex'   : s:Latex_Luatex  ,
			\ }

let s:Latex_TypesetterList = [
			\    'tex',    'latex',
			\ 'pdftex', 'pdflatex',
			\ 'luatex', 'lualatex',
			\ ]

let s:Latex_ConverterCall = {
			\ 'dvi-pdf' 	: [ s:Latex_DviPdf , "no" ],
			\ 'dvi-png'		: [ s:Latex_DviPng , "no" ],
			\ 'dvi-ps'		: [ s:Latex_DviPs  , "no" ],
			\ 'eps-pdf'		: [ s:Latex_EpsPdf , "no" ],
			\ 'pdf-png'		: [ s:Latex_PdfPng , "yes"],
			\ 'ps-pdf'		: [ s:Latex_PsPdf  , "no" ],
			\ }

let s:Latex_ViewerCall = {
	\ 'dvi'           : s:Latex_DviViewer,
	\ 'pdf'           : s:Latex_PdfViewer,
	\ 'ps'            : s:Latex_PsViewer,
	\ }

let s:Latex_ProcessingList = [ 'foreground' ]

" :TODO:25.09.2017 17:17:WM: enable Windows, check how to start jobs with arguments under Windows
if has('job') && ! s:MSWIN || s:NEOVIM
	call add ( s:Latex_ProcessingList, 'background' )
endif

" }}}3
"-------------------------------------------------------------------------------

" }}}2
"-------------------------------------------------------------------------------

"-------------------------------------------------------------------------------
" s:AdjustLineEndComm : Adjust end-of-line comments.   {{{1
"-------------------------------------------------------------------------------
function! s:AdjustLineEndComm ( ) range
	"
	" patterns to ignore when adjusting line-end comments (maybe incomplete):
	let	s:AlignRegex	= [
				\	'\([^"]*"[^"]*"\)\+' ,
				\	]

	if !exists("b:Latex_LineEndCommentColumn")
		let	b:Latex_LineEndCommentColumn	= s:Latex_LineEndCommColDefault
	endif

	let save_cursor = getpos('.')

	let	save_expandtab	= &expandtab
	exe	':set expandtab'

	let	linenumber	= a:firstline
	exe ':'.a:firstline

	while linenumber <= a:lastline
		let	line= getline('.')

		let idx1	= 1 + match( line, '\s*%.*$', 0 )
		let idx2	= 1 + match( line,    '%.*$', 0 )

		" comment with leading whitespaces left unchanged
		if     match( line, '^\s*%' ) == 0
			let idx1	= 0
			let idx2	= 0
		endif

		for regex in s:AlignRegex
			if match( line, regex ) > -1
				let start	= matchend( line, regex )
				let idx1	= 1 + match( line, '\s*%.*$', start )
				let idx2	= 1 + match( line,    '%.*$', start )
				break
			endif
		endfor

		let	ln	= line('.')
		call setpos('.', [ 0, ln, idx1, 0 ] )
		let vpos1	= virtcol('.')
		call setpos('.', [ 0, ln, idx2, 0 ] )
		let vpos2	= virtcol('.')

		if   ! (   vpos2 == b:Latex_LineEndCommentColumn
					\	|| vpos1 > b:Latex_LineEndCommentColumn
					\	|| idx2  == 0 )

			exe ':.,.retab'
			" insert some spaces
			if vpos2 < b:Latex_LineEndCommentColumn
				let	diff	= b:Latex_LineEndCommentColumn-vpos2
				call setpos('.', [ 0, ln, vpos2, 0 ] )
				let	@"	= ' '
				exe 'normal!	'.diff.'P'
			end

			" remove some spaces
			if vpos1 < b:Latex_LineEndCommentColumn && vpos2 > b:Latex_LineEndCommentColumn
				let	diff	= vpos2 - b:Latex_LineEndCommentColumn
				call setpos('.', [ 0, ln, b:Latex_LineEndCommentColumn, 0 ] )
				exe 'normal!	'.diff.'x'
			end

		end
		let linenumber=linenumber+1
		normal! j
	endwhile
	" restore tab expansion settings and cursor position
	let &expandtab	= save_expandtab
	call setpos('.', save_cursor)

endfunction		" ---------- end of function  s:AdjustLineEndComm  ----------

"-------------------------------------------------------------------------------
" s:GetLineEndCommCol : Set end-of-line comment position.   {{{1
"-------------------------------------------------------------------------------
function! s:GetLineEndCommCol ()
	let actcol	= virtcol(".")
	if actcol+1 == virtcol("$")
		let	b:Latex_LineEndCommentColumn	= ''
		while match( b:Latex_LineEndCommentColumn, '^\s*\d\+\s*$' ) < 0
			let b:Latex_LineEndCommentColumn = s:UserInput( 'start line-end comment at virtual column : ', actcol, '' )
		endwhile
	else
		let	b:Latex_LineEndCommentColumn	= virtcol(".")
	endif
  echomsg "line end comments will start at column  ".b:Latex_LineEndCommentColumn
endfunction		" ---------- end of function  s:GetLineEndCommCol  ----------

"-------------------------------------------------------------------------------
" s:EndOfLineComment : Append end-of-line comments.   {{{1
"-------------------------------------------------------------------------------
function! s:EndOfLineComment ( ) range
	if !exists("b:Latex_LineEndCommentColumn")
		let	b:Latex_LineEndCommentColumn	= s:Latex_LineEndCommColDefault
	endif
	" ----- trim whitespaces -----
	exe a:firstline.','.a:lastline.'s/\s*$//'

	for line in range( a:lastline, a:firstline, -1 )
		silent exe ":".line
		if getline(line) !~ '^\s*$'
			let linelength	= virtcol( [line, "$"] ) - 1
			let	diff				= 1
			if linelength < b:Latex_LineEndCommentColumn
				let diff	= b:Latex_LineEndCommentColumn -1 -linelength
			endif
			exe "normal!	".diff."A "
			call mmtemplates#core#InsertTemplate(g:Latex_Templates, 'Comments.end-of-line comment')
		endif
	endfor
endfunction		" ---------- end of function  s:EndOfLineComment  ----------

"-------------------------------------------------------------------------------
" s:CommentToggle : Toggle comments.   {{{1
"-------------------------------------------------------------------------------
function! s:CommentToggle () range
	let	comment=1
	for line in range( a:firstline, a:lastline )
		if match( getline(line), '^%') == -1					" no comment
			let comment = 0
			break
		endif
	endfor

	if comment == 0
			exe a:firstline.','.a:lastline."s/^/%/"
	else
			exe a:firstline.','.a:lastline."s/^%//"
	endif

endfunction    " ----------  end of function s:CommentToggle ----------

"-------------------------------------------------------------------------------
" s:ParseBibtexEntry : Parse a BibTeX entry.   {{{1
"
" Parameters:
"   text - the text to parse (string)
" Returns:
"   data - the BibTeX record (dict)
"-------------------------------------------------------------------------------
function! s:ParseBibtexEntry ( text )
	"
	let data = { 'error' : '', 'type' : '', 'key' : '', 'fields' : {} }
	"
	" @TYPE { KEY ,
	let mlist = matchlist ( a:text, '^\_s*@\(\K\k*\)\_s*{\(\K\k*\)\_s*,\(.*\)' )
	"
	if empty ( mlist )
		let data.error = 'Could not parse the type or key.'
		return data
	endif
	"
	" metadata
	let data.type = mlist[1]
	let data.key  = mlist[2]
	"
	" is really a comment
	if tolower( data.type ) == 'comment'
		let data.error = 'Found a comment.'
		return data
	endif
	"
	" parse fields
	let sep  = '}'
	let text = mlist[3]
	"
	while 1
		"
		" :TODO:02.02.2014 19:40:WM: nested { }
		" :TODO:02.02.2014 19:40:WM: concatenated strings #
		"
		" IDENTIFIER = ( INTEGER | IDENTIFIER | { ... } | " ... " ) ( ,} | , | } )
		let mlist = matchlist ( text, '^\_s*\(\I\i*\)\_s*=\_s*\(\d\+\|\I\i*\|{[^{]*}\|"[^{]*"\)\_s*\(,\_s*}\|[,}]\)\(.*\)' )
		"
		if empty( mlist )
			break
		endif
		"
		if ! has_key ( data.fields, mlist[1] )
			let data.fields[ mlist[1] ] = mlist[2]
		endif
		let sep  = mlist[3]
		let text = mlist[4]
	endwhile
	"
	" parsed full entry?
	if sep !~ '}$'
		let data.error = 'Could not parse a full entry.'
		return data
	endif
	"
	return data
	"
endfunction    " ----------  end of function s:ParseBibtexEntry ----------

"-------------------------------------------------------------------------------
" s:BibtexBeautify : Rewrite a BibTeX record.   {{{1
"-------------------------------------------------------------------------------
function! s:BibtexBeautify () range
	"
	" get lines
	let linestring = ''
	for i in range(a:firstline,a:lastline)
		let linestring .= getline(i)."\n"
	endfor
	"
	let data = s:ParseBibtexEntry ( linestring )
	"
	if data.error != ''
		echo "Did not find an entry:\n".data.error
		return
	endif
	"
	echo data.type
	echo data.key
	"
	for [ key, val ] in items( data.fields )
		echo key.' = '.val
	endfor
	"
endfunction    " ----------  end of function s:BibtexBeautify ----------

"-------------------------------------------------------------------------------
" === Wizards ===   {{{1
"-------------------------------------------------------------------------------

"-------------------------------------------------------------------------------
" s:WizardTabbing : Wizard for inserting a tabbing.   {{{2
"-------------------------------------------------------------------------------
function! s:WizardTabbing()

	" settings
	let textwidth = 120                           " unit [mm]
	let n_rows    = 1                             " default number of rows
	let n_cols    = 2                             " default number of columns

	" user input
	let param = s:UserInput("rows columns [width [mm]]: ", n_rows." ".n_cols )
	if param == ""
		return
	elseif match( param, '^\s*\d\+\(\s\+\d\+\)\{0,2}\s*$' ) < 0
		return s:WarningMsg ( ' Wrong input format.' )
	endif

	" parse the input
	let paramlist = split( param )
	if len( paramlist ) >= 1
		let n_rows  = str2nr( paramlist[0] )
	endif
	if len( paramlist ) >= 2
		let n_cols  = str2nr( paramlist[1 ])
	endif
	if len( paramlist ) >= 3
		let textwidth = paramlist[2]
	endif

	" generate replacements for all macros and insert the template
	let n_rows = max( [ n_rows, 1 ] )  " at least 1 row
	let n_cols = max( [ n_cols, 2 ] )  " at least 2 columns

	let colwidth = textwidth/n_cols
	let colwidth = max( [ colwidth, 10 ] )

	let ROW_HEAD = repeat ( '\hspace{'.colwidth.'mm} \= ', n_cols )
	let ROW      = repeat ( ' \> ', n_cols-1 )
	let ROW_LIST = repeat ( [ ROW ], n_rows )

	call mmtemplates#core#InsertTemplate ( g:Latex_Templates, 'Wizard.tables.tabbing',
				\ '|ROW_HEAD|', ROW_HEAD, '|ROW|', ROW_LIST, 'placement', 'below' )
endfunction    " ----------  end of function s:WizardTabbing  ----------

"-------------------------------------------------------------------------------
" s:WizardTabular : Wizard for inserting a tabular.   {{{2
"-------------------------------------------------------------------------------
function! s:WizardTabular()

	" settings
	let textwidth = 120   " [mm]
	let n_rows    = 2
	let n_cols    = 2

	" user input
	let param = s:UserInput("rows columns [width [mm]]: ", n_rows." ".n_cols )
	if param == ""
		return
	elseif match( param, '^\s*\d\+\(\s\+\d\+\)\{0,2}\s*$' ) < 0
		return s:WarningMsg ( ' Wrong input format.' )
	endif

	" parse the input
	let paramlist = split( param )
	if len( paramlist ) >= 1
		let n_rows  = str2nr( paramlist[0] )
	endif
	if len( paramlist ) >= 2
		let n_cols  = str2nr( paramlist[1 ])
	endif
	if len( paramlist ) >= 3
		let textwidth = paramlist[2]
	endif

	" generate replacements for all macros and insert the template
	let n_rows = max( [ n_rows, 1 ] )  " at least 1 row
	let n_cols = max( [ n_cols, 2 ] )  " at least 2 columns

	let colwidth = textwidth/n_cols
	let colwidth = max( [ colwidth, 10 ] )

	let COLUMNS  = repeat ( 'p{'.colwidth.'mm}', n_cols )
	let ROW_HEAD = repeat ( ' & ', n_cols-1 )
	let ROW_LIST = repeat ( [ ROW_HEAD ], n_rows-1 )

	call mmtemplates#core#InsertTemplate ( g:Latex_Templates, 'Wizard.tables.tabular',
				\ '|COLUMNS|', COLUMNS, '|ROW_HEAD|', ROW_HEAD, '|ROW|', ROW_LIST, 'placement', 'below' )
endfunction    " ----------  end of function s:WizardTabular  ----------

" }}}2
"-------------------------------------------------------------------------------

"-------------------------------------------------------------------------------
" === Background processing facilities ===   {{{1
"-------------------------------------------------------------------------------

let s:BackgroundType   = ''                     " type of the job
let s:BackgroundStatus = -1                     " status of the last job
let s:BackgroundOutStd = []                     " output of the last job
let s:BackgroundOutErr = []                     " output of the last job

"-------------------------------------------------------------------------------
" Neovim   {{{2
"-------------------------------------------------------------------------------
if s:NEOVIM

"-------------------------------------------------------------------------------
" s:BackgroundStart : Start a background job.   {{{3
"
" Parameters:
"   id - the job ID (string)
"   cmd - the shell command to run (string, or list of strings)
" Returns:
"   -
"-------------------------------------------------------------------------------
function! s:BackgroundStart ( id, cmd )
	if exists ( 's:BackgroundJob' )
		return s:WarningMsg ( 'Job "'.s:BackgroundType.'" still running.' )
	endif

	let s:BackgroundType   = a:id
	let s:BackgroundStatus = -1
	let s:BackgroundOutStd = []
	let s:BackgroundOutErr = []

	let s:BackgroundJob = jobstart ( a:cmd,
				\ {
				\ 'on_stdout' : '<SNR>'.s:SID().'_BackgroundCB_IO',
				\ 'on_stderr' : '<SNR>'.s:SID().'_BackgroundCB_IO',
				\ 'on_exit'   : '<SNR>'.s:SID().'_BackgroundCB_Exit',
				\ } )

	if s:BackgroundJob <= 0
		call s:WarningMsg ( 'Starting "'.s:BackgroundType.'" failed!' )
		unlet s:BackgroundJob
	else
		call s:ImportantMsg ( 'Starting "'.s:BackgroundType.'" in background.' )
	endif

	return
endfunction    " ----------  end of function s:BackgroundStart  ----------

"-------------------------------------------------------------------------------
" s:BackgroundCB_IO : Callback for output from the background job.   {{{3
"
" Parameters:
"   chn - the channel (channel)
"   msg - the new line (string)
"-------------------------------------------------------------------------------
function! s:BackgroundCB_IO ( job_id, data, event )
	if a:event == 'stdout'
		let s:BackgroundOutStd += a:data
	elseif a:event == 'stdout'
		let s:BackgroundOutErr += a:data
	endif
endfunction    " ----------  end of function s:BackgroundCB_IO  ----------

"-------------------------------------------------------------------------------
" s:BackgroundCB_Exit : Callback for a finished background job.   {{{3
"
" Parameters:
"   job - the job (job)
"   status - the status (number)
"-------------------------------------------------------------------------------
function! s:BackgroundCB_Exit ( job_id, data, event )
	if a:data == 0
		call s:ImportantMsg ( 'Job "'.s:BackgroundType.'" finished successfully.' )
	else
		call s:ImportantMsg ( 'Job "'.s:BackgroundType.'" failed (exit status '.a:data.').' )
	endif

	let s:BackgroundStatus = a:data
	unlet s:BackgroundJob
endfunction    " ----------  end of function s:BackgroundCB_Exit  ----------

" }}}3
"-------------------------------------------------------------------------------

"-------------------------------------------------------------------------------
" Vim/gVim   {{{2
"-------------------------------------------------------------------------------
else   " ! s:NEOVIM

"-------------------------------------------------------------------------------
" s:BackgroundStart : Start a background job.   {{{3
"
" Parameters:
"   id - the job ID (string)
"   cmd - the shell command to run (string, or list of strings)
" Returns:
"   -
"-------------------------------------------------------------------------------
function! s:BackgroundStart ( id, cmd )
	if exists ( 's:BackgroundJob' )
		return s:WarningMsg ( 'Job "'.s:BackgroundType.'" still running.' )
	endif

	let s:BackgroundType   = a:id
	let s:BackgroundStatus = -1
	let s:BackgroundOutStd = []

	let s:BackgroundJob = job_start ( a:cmd,
				\ {
				\ 'callback' : '<SNR>'.s:SID().'_BackgroundCB_IO',
				\ 'exit_cb'  : '<SNR>'.s:SID().'_BackgroundCB_Exit',
				\ } )

	if job_status ( s:BackgroundJob ) == 'fail'
		call s:WarningMsg ( 'Starting "'.s:BackgroundType.'" failed!' )
		unlet s:BackgroundJob
	else
		call s:ImportantMsg ( 'Starting "'.s:BackgroundType.'" in background.' )
	endif

	return
endfunction    " ----------  end of function s:BackgroundStart  ----------

"-------------------------------------------------------------------------------
" s:BackgroundCB_IO : Callback for output from the background job.   {{{3
"
" Parameters:
"   chn - the channel (channel)
"   msg - the new line (string)
"-------------------------------------------------------------------------------
function! s:BackgroundCB_IO ( chn, msg )
	call add ( s:BackgroundOutStd, a:msg )
endfunction    " ----------  end of function s:BackgroundCB_IO  ----------

"-------------------------------------------------------------------------------
" s:BackgroundCB_Exit : Callback for a finished background job.   {{{3
"
" Parameters:
"   job - the job (job)
"   status - the status (number)
"-------------------------------------------------------------------------------
function! s:BackgroundCB_Exit ( job, status )
	if a:status == 0
		call s:ImportantMsg ( 'Job "'.s:BackgroundType.'" finished successfully.' )
	else
		call s:ImportantMsg ( 'Job "'.s:BackgroundType.'" failed (exit status '.a:status.').' )
	endif

	let s:BackgroundStatus = a:status
	unlet s:BackgroundJob
endfunction    " ----------  end of function s:BackgroundCB_Exit  ----------

" }}}3
"-------------------------------------------------------------------------------
endif

"-------------------------------------------------------------------------------
" s:BackgroundErrors : Quickfix background errors.   {{{2
"-------------------------------------------------------------------------------
function! s:BackgroundErrors ()

	if exists ( 's:BackgroundJob' )
		return s:WarningMsg ( 'Job "'.s:BackgroundType.'" still running.' )
	elseif len ( s:BackgroundOutStd ) == 0 && len ( s:BackgroundOutErr ) == 0
		return s:WarningMsg ( 'Not output for last job.' )
	endif

	cclose

	" save current settings
	let errorf_saved  = &g:errorformat

	" run typesetter
	let &g:errorformat = s:Latex_LatexErrorf

	let errors = join ( s:BackgroundOutStd + s:BackgroundOutErr, "\n" )
	silent exe 'cgetexpr errors'

	" restore current settings
	let &g:errorformat = errorf_saved

	" open error window (always, since the user asked for it)
	botright copen

	return
endfunction    " ----------  end of function s:BackgroundErrors  ----------

" }}}2
"-------------------------------------------------------------------------------

"-------------------------------------------------------------------------------
" s:SetMainDocument : Set the main document.   {{{1
"
" Passing an empty string as 'filename' resets the option, and the filenames
" are taken from the current buffer again.
"
" Parameters:
"   filename - the new main document (string)
"   echo_only - if true, only echo the current setting (integer)
" Returns:
"   -
"-------------------------------------------------------------------------------
function! s:SetMainDocument ( filename, echo_only )

	if a:echo_only
		echo s:Latex_MainDocument
		return
	endif

	let new_main = expand ( a:filename )

	if new_main == ''
		let s:Latex_MainDocument = ''
	elseif ! filereadable ( new_main )
		return s:ErrorMsg ( '"'.new_main.'" is not readable, nothing set.' )
	else
		let new_main = fnamemodify ( new_main, ':p' )
		let s:Latex_MainDocument = new_main
	endif

endfunction    " ----------  end of function s:SetMainDocument  ----------

"-------------------------------------------------------------------------------
" s:Compile : Run the typesetter.   {{{1
"
" Parameters:
"   ... - command-line arguments (string, optional)
"-------------------------------------------------------------------------------
function! s:Compile ( args )

	let typesettercall = s:Latex_TypesetterCall[s:Latex_Typesetter]
	let typesetter     = split( typesettercall )[0]
	if ! executable( typesetter )
		return s:ErrorMsg ( 'Typesetter "'.typesetter.'" does not exist or its name is not unique.' )
	endif

	let dir = ''

	" get the name of the source file
	if a:args != ''
		let source = a:args
	elseif s:Latex_MainDocument != ''
		let source = s:Latex_MainDocument           " name of the main document
		let dir    = fnamemodify ( source, ':p:h' )
		exe 'cd '.fnameescape( dir )
	else
		let source = expand("%")                    " name of the file in the current buffer
	endif

	" write source file if necessary
	if &filetype == 'tex'
		silent exe 'update'
	endif

	cclose

	try
		if s:Latex_Processing == 'background'
			let arg_list = s:ShellParseArgs ( typesettercall ) + [ source ]

			call s:BackgroundStart ( s:Latex_Typesetter, arg_list )
			return       | " continue with 'finally' below
		endif

		" save current settings
		let makeprg_saved = &l:makeprg
		let errorf_saved  = &l:errorformat

		" run typesetter
		let &l:makeprg     = typesettercall
		let &l:errorformat = s:Latex_LatexErrorf

		exe "make ".shellescape ( source )

		" restore current settings
		let &l:makeprg     = makeprg_saved
		let &l:errorformat = errorf_saved

	catch /^ShellParseArgs:Syntax:/
		let msg = v:exception[ len( 'ShellParseArgs:Syntax:') : -1 ]
		return s:WarningMsg ( 'syntax error while parsing typersetter arguments: '.msg,
					\ ' - typersetter call: '.typesettercall )
	catch /.*/
		return s:WarningMsg (
					\ "internal error (" . v:exception . ")",
					\ " - occurred at " . v:throwpoint )
	finally
		" jump back to the old working directory
		if dir != ''
			cd -
		endif
	endtry

	" open error window if necessary
	botright cwindow

endfunction    " ----------  end of function s:Compile ----------

"-------------------------------------------------------------------------------
" s:Bibtex : Run 'bibtex'.   {{{1
"
" Parameters:
"   args - command-line arguments (string)
"-------------------------------------------------------------------------------
function! s:Bibtex ( args )

	" get the root of the name of the current buffer
	if a:args == ''
		let aux_file = expand("%:r")
	else
		let aux_file = a:args
	endif

	" write source file if necessary
	if &filetype == 'tex' || &filetype == 'bib'
		silent exe 'update'
	endif

	cclose

	" save current settings
	let makeprg_saved = &l:makeprg
	let errorf_saved  = &l:errorformat

	" run bibtex
	let &l:makeprg     = s:Latex_Bibtex
	let &l:errorformat = s:Latex_BibtexErrorf

	exe "make! ".shellescape ( aux_file )       | " do not jump to the first error

	" restore current settings
	let &l:makeprg     = makeprg_saved
	let &l:errorformat = errorf_saved

	" open error window if necessary
	botright cwindow

endfunction    " ----------  end of function s:Bibtex ----------

"-------------------------------------------------------------------------------
" s:Makeglossaries : Run 'makeglossaries'.   {{{1
"
" Parameters:
"   args - command-line arguments (string)
"-------------------------------------------------------------------------------
function! s:Makeglossaries ( args )

	if ! executable ( 'makeglossaries' )
		return s:ErrorMsg ( '"makeglossaries" does not exist or is not executable.' )
	endif

	" get the root of the name of the current buffer
	if a:args == ''
		let aux_file = expand("%:r")
	else
		let aux_file = a:args
	endif

	" run the file
	exe '!makeglossaries '.shellescape( aux_file )
	if v:shell_error
		return s:WarningMsg ( 'makeglossaries reported errors' )
	endif
endfunction    " ----------  end of function s:Makeglossaries  ----------

"-------------------------------------------------------------------------------
" s:Makeindex : Run 'makeindex'.   {{{1
"
" Parameters:
"   args - command-line arguments (string)
"-------------------------------------------------------------------------------
function! s:Makeindex ( args )

	" get the name of the index file
	if a:args == ''
		let idx_file = expand("%:r").'.idx'
	else
		let idx_file = a:args
	endif

	" check the file
	if ! filereadable(idx_file)
		return s:WarningMsg ( 'Can not find the file "'.idx_file.'"' )
	endif

	" run the file
	exe '!makeindex '.shellescape( idx_file )
	if v:shell_error
		return s:WarningMsg ( 'makeindex reported errors' )
	endif
endfunction    " ----------  end of function s:Makeindex  ----------

"-------------------------------------------------------------------------------
" s:Lacheck : Run 'lacheck'.   {{{1
"
" Parameters:
"   args - command-line arguments (string)
"-------------------------------------------------------------------------------
function! s:Lacheck ( args )

	if ! executable( 'lacheck' )
		return s:ErrorMsg ( '"lacheck" does not exist or is not executable.' )
	endif

	" get the name of the index file
	if a:args == ''
		let source = expand("%")                    " name of the file in the current buffer
	else
		let source = a:args
	endif

	" write source file if necessary
	if &filetype == 'tex' || &filetype == 'bib'
		silent exe 'update'
	endif

	cclose

	" save current settings
	let makeprg_saved = &l:makeprg
	let errorf_saved  = &l:errorformat

	" run lacheck
	let &l:makeprg     = 'lacheck'
	let &l:errorformat = '"%f"\, line %l:%m'

	let v:statusmsg = ''                          " reset, so we are able to check it below
	silent exe "make ".shellescape ( source )   | " do not jump to the first error
	" :TODO:26.11.2016 22:12:WM: using make! here seems to cause v:statusmsg to
	" never be set to a none-emtpy value

	" restore current settings
	let &l:makeprg     = makeprg_saved
	let &l:errorformat = errorf_saved

	if empty ( v:statusmsg )
		call s:Redraw('r!','r')                     " redraw after cclose, before echoing
		call s:ImportantMsg ( bufname('%').': No warnings.' )
	else
		call s:Redraw('r!','')                      " redraw after cclose, before opening the new window
		botright cwindow                            " open error window
	endif

endfunction    " ----------  end of function s:Lacheck ----------

"-------------------------------------------------------------------------------
" s:View : View a document.   {{{1
"
" Views a document. The format is guessed from the filename, or specified on
" the command line. Supports the following calls:
" :LatexView fmt
" :LatexView fmt file
" :LatexView file fmt
" :LatexView file
" :LatexView
"
" - If no format is specified, it is guessed from the filename.
" - If no filename is specified, it is guessed from the name of the buffer
"   and the format.
" - If neither filename nor format are specified, they are guessed from
"   the typesetter and the name of the buffer.
"
" Parameters:
"   args - the cmd.-line arguments (string)
"-------------------------------------------------------------------------------
function! s:View ( args )

	let targetfile = ''
	let format     = ''

	" analyse the command-line arguments
	if a:args =~ '^\s*\(dvi\|pdf\|ps\)\s*$'
		" :LatexView fmt
		let format = substitute ( a:args, '\s\+', '', 'g' )
		let targetfile = expand("%:r").'.'.format
	elseif a:args =~ '^\s*\(dvi\|pdf\|ps\)\s'
		" :LatexView fmt file
		let mlist = matchlist ( a:args, '^\s*\(dvi\|pdf\|ps\)\s\+\(.*\)' )
		let format = mlist[1]
		let targetfile = mlist[2]
	elseif a:args =~ '\s\(dvi\|pdf\|ps\)\s*$'
		" :LatexView file fmt
		let mlist = matchlist ( a:args, '^\(.\{-}\)\s\+\(dvi\|pdf\|ps\)\s*$' )
		let targetfile = mlist[1]
		let format = mlist[2]
	elseif a:args !~ '^\s*$'
		" :LatexView file
		let targetfile = a:args
		let format = matchstr ( targetfile, '[^.]\+\ze\s*$' )
		let format = tolower ( format )
	else
		" :LatexView -empty-

		" guess the format from the typesetter
		if s:Latex_Typesetter =~ '^pdf' || s:Latex_Typesetter =~ '^lua'
			let format = 'pdf'
		else
			let format = 'dvi'
		endif

		" get the file
		let targetfile = expand("%:r").'.'.format
	endif

	" check the file ...
	if ! filereadable( targetfile )
		return s:ErrorMsg ( 'File "'.targetfile.'" does not exist or is not readable.' )
	endif

	" ... and the format
	if ! has_key ( s:Latex_ViewerCall, format )
		return s:ErrorMsg ( 'Filetype "'.format.'" not supported.' )
	endif

	" get the viewer command
	let viewer = s:Latex_ViewerCall[format]
	if viewer == '' || ! executable( split(viewer)[0] )
		return s:ErrorMsg ( 'Viewer '.viewer.' does not exist or its name is not unique.' )
	endif

	" run the command
	if s:MSWIN
		silent exe '!start '.viewer.' '.targetfile
	else
		silent exe '!'.viewer.' '.targetfile.' &'
	endif
endfunction    " ----------  end of function s:View ----------

"-------------------------------------------------------------------------------
" s:Conversions : Perform a conversion.   {{{1
"
" Perform the conversion s:Latex_ConverterCall[ <format> ] on the file
" <filename>.
"
" Parameters:
"   filename - the file to convert (string, can be empty)
"   format - the conversion (string, can be empty)
"-------------------------------------------------------------------------------
function! s:Conversions ( filename, format )

	let filename = a:filename
	let convert  = a:format

	" handle the conversion
	if convert == ''
		let convert = s:UserInput ( "start converter (tab exp.): ", '', 'customlist', sort( keys( s:Latex_ConverterCall ) ) )
		if convert == ''
			return
		endif
		echo ' '
	endif

	if ! has_key( s:Latex_ConverterCall, convert )
		return s:WarningMsg ( 'Converter "'.convert.'" does not exist.' )
	endif

	let convertercall = s:Latex_ConverterCall[convert][0]
	if convertercall == ''
		return s:WarningMsg ( 'Converter "'.convert.'" not properly configured.' )
	endif
	let converter = split( convertercall )[0]
	if ! executable( converter )
		return s:WarningMsg ( 'Converter "'.converter.'" does not exist or its name is not unique.' )
	endif

	let need_output_file = s:Latex_ConverterCall[convert][1] == 'yes'

	cclose

	" handle the input file
	if filename == ''
		let filename = expand("%")
	endif
	let fileroot = fnamemodify ( filename, ':r' )

	let source  = fileroot.'.'.split( convert, '-' )[0]
	let target  = ''
	let t_ext   = split( convert, '-' )[1]

	if s:Latex_Processing == 'background'
		try
			let arg_list = s:ShellParseArgs ( convertercall ) + [ source ]
		catch /^ShellParseArgs:Syntax:/
			let msg = v:exception[ len( 'ShellParseArgs:Syntax:') : -1 ]
			return s:WarningMsg ( 'syntax error while parsing converter arguments: '.msg,
						\ ' - converter call: '.convertercall )
		catch /.*/
			return s:WarningMsg (
						\ "internal error (" . v:exception . ")",
						\ " - occurred at " . v:throwpoint )
		endtry

		if need_output_file
			let arg_list += [ fileroot.'.'.t_ext ]
		endif

		call s:BackgroundStart ( convert, arg_list )
		return
	endif

	if need_output_file
		let target = shellescape ( fileroot.'.'.t_ext )
	endif
	let logfile = fileroot.'.conversion.log'

	silent exe '!'.convertercall.' '.shellescape( source ).' '.target.' > '.shellescape( logfile )

	if v:shell_error
		call s:Redraw('r!','r')                     " redraw after cclose, before echoing
		call s:WarningMsg (
					\ 'Conversion '.convert.' reported errors.',
					\ 'Please check the logfile: '.logfile )
	else
		call s:Redraw('r!','r')                     " redraw after cclose, before echoing
		call s:ImportantMsg ( 'Conversion '.convert.' done.' )
	endif
endfunction    " ----------  end of function s:Conversions  ----------

"-------------------------------------------------------------------------------
" s:GetTypesetterList : For cmd.-line completion.   {{{1
"-------------------------------------------------------------------------------
function! s:GetTypesetterList (...)
	return join ( s:Latex_TypesetterList, "\n" )
endfunction    " ----------  end of function s:GetTypesetterList  ----------

"-------------------------------------------------------------------------------
" s:SetTypesetter : Set s:Latex_Typesetter .   {{{1
"
" The new typesetter must be one of 's:Latex_TypesetterList'.
"
" Parameters:
"   typesetter - the typesetter (string, optional)
"-------------------------------------------------------------------------------
function! s:SetTypesetter ( typesetter )

	if a:typesetter == ''
		echo s:Latex_Typesetter
		return
	endif

	" 'typesetter' gives the typesetter
	if index ( s:Latex_TypesetterList, a:typesetter ) == -1
		return s:ErrorMsg ( 'Invalid option for the typesetter: "'.a:typesetter.'".' )
	endif

	let s:Latex_Typesetter = a:typesetter

	" update the menu header
	if ! has ( 'menu' ) || s:MenuVisible == 0
		return
	endif

	exe 'aunmenu '.s:Latex_RootMenu.'.Run.choose\ typesetter.Typesetter'

	let current = s:Latex_Typesetter
	exe 'anoremenu ...400 '.s:Latex_RootMenu.'.Run.choose\ typesetter.Typesetter<TAB>(current\:\ '.current.') :echo "This is a menu header."<CR>'

endfunction    " ----------  end of function s:SetTypesetter  ----------

"-------------------------------------------------------------------------------
" s:GetProcessingList : For cmd.-line completion.   {{{1
"-------------------------------------------------------------------------------
function! s:GetProcessingList (...)
	return join ( s:Latex_ProcessingList, "\n" )
endfunction    " ----------  end of function s:GetProcessingList  ----------

"-------------------------------------------------------------------------------
" s:SetProcessing : Set s:Latex_Processing .   {{{1
"
" The new processing method must be one of 's:Latex_ProcessingList'.
"
" Parameters:
"   method - the method (string, optional)
"-------------------------------------------------------------------------------
function! s:SetProcessing ( method )

	if a:method == ''
		echo s:Latex_Processing
		return
	endif

	" 'method' gives the processing method
	if index ( s:Latex_ProcessingList, a:method ) == -1
		return s:ErrorMsg ( 'Invalid option for the processing method: "'.a:method.'".' )
	endif

	let s:Latex_Processing = a:method

	" update the menu header
	if ! has ( 'menu' ) || s:MenuVisible == 0
		return
	endif

	exe 'aunmenu '.s:Latex_RootMenu.'.Run.external\ processing.Processing'

	let current = s:Latex_Processing
	exe 'anoremenu ...400 '.s:Latex_RootMenu.'.Run.external\ processing.Processing<TAB>(current\:\ '.current.') :echo "This is a menu header."<CR>'

endfunction    " ----------  end of function s:SetProcessing  ----------

"-------------------------------------------------------------------------------
" s:Texdoc : Look up package documentation.   {{{1
"
" Look up package documentation for word under the cursor or ask.
"-------------------------------------------------------------------------------
function! s:Texdoc( )
	let cuc  = getline(".")[col(".") - 1]         " character under the cursor
	let item = expand("<cword>")                  " word under the cursor
	if empty(cuc) || empty(item) || match( item, cuc ) == -1
		let item = s:UserInput('Name of the package : ', '' )
	endif

	if !empty(item)
		let cmd = 'texdoc '.item.' &'
		call system( cmd )
		if v:shell_error
			return s:ErrorMsg ( 'Shell command "'.cmd.'" failed.' )
		endif
	endif
endfunction		" ---------- end of function  s:Texdoc  ----------

"-------------------------------------------------------------------------------
" s:HelpPlugin : Plug-in help.   {{{1
"-------------------------------------------------------------------------------
function! s:HelpPlugin ()
	try
		help latex-support
	catch
		exe 'helptags '.s:plugin_dir.'/doc'
		help latex-support
	endtry
endfunction    " ----------  end of function s:HelpPlugin ----------
"
"------------------------------------------------------------------------------
" === Templates API ===   {{{1
"------------------------------------------------------------------------------
"
"------------------------------------------------------------------------------
"  Latex_SetMapLeader   {{{2
"------------------------------------------------------------------------------
function! Latex_SetMapLeader ()
	if exists ( 'g:Latex_MapLeader' )
		call mmtemplates#core#SetMapleader ( g:Latex_MapLeader )
	endif
endfunction    " ----------  end of function Latex_SetMapLeader  ----------
"
"------------------------------------------------------------------------------
"  Latex_ResetMapLeader   {{{2
"------------------------------------------------------------------------------
function! Latex_ResetMapLeader ()
	if exists ( 'g:Latex_MapLeader' )
		call mmtemplates#core#ResetMapleader ()
	endif
endfunction    " ----------  end of function Latex_ResetMapLeader  ----------
" }}}2
"------------------------------------------------------------------------------

"-------------------------------------------------------------------------------
" s:RereadTemplates : Initial loading of the templates.   {{{1
"
" Reread the templates. Also set the character which starts the comments in
" the template files.
"-------------------------------------------------------------------------------
function! s:RereadTemplates ()
	"
	"-------------------------------------------------------------------------------
	" SETUP TEMPLATE LIBRARY
	"-------------------------------------------------------------------------------
	let g:Latex_Templates = mmtemplates#core#NewLibrary ( 'api_version', '1.0' )
	"
	" mapleader
	if empty ( g:Latex_MapLeader )
		call mmtemplates#core#Resource ( g:Latex_Templates, 'set', 'property', 'Templates::Mapleader', '\' )
	else
		call mmtemplates#core#Resource ( g:Latex_Templates, 'set', 'property', 'Templates::Mapleader', g:Latex_MapLeader )
	endif
	"
	" some metainfo
	call mmtemplates#core#Resource ( g:Latex_Templates, 'set', 'property', 'Templates::Wizard::PluginName',   'LaTeX' )
	call mmtemplates#core#Resource ( g:Latex_Templates, 'set', 'property', 'Templates::Wizard::FiletypeName', 'LaTeX' )
	call mmtemplates#core#Resource ( g:Latex_Templates, 'set', 'property', 'Templates::Wizard::FileCustomNoPersonal',   s:plugin_dir.'/latex-support/rc/custom.templates' )
	call mmtemplates#core#Resource ( g:Latex_Templates, 'set', 'property', 'Templates::Wizard::FileCustomWithPersonal', s:plugin_dir.'/latex-support/rc/custom_with_personal.templates' )
	call mmtemplates#core#Resource ( g:Latex_Templates, 'set', 'property', 'Templates::Wizard::FilePersonal',           s:plugin_dir.'/latex-support/rc/personal.templates' )
	call mmtemplates#core#Resource ( g:Latex_Templates, 'set', 'property', 'Templates::Wizard::CustomFileVariable',     'g:Latex_CustomTemplateFile' )
	"
	" maps: special operations
	call mmtemplates#core#Resource ( g:Latex_Templates, 'set', 'property', 'Templates::RereadTemplates::Map', 'ntr' )
	call mmtemplates#core#Resource ( g:Latex_Templates, 'set', 'property', 'Templates::ChooseStyle::Map',     'nts' )
	call mmtemplates#core#Resource ( g:Latex_Templates, 'set', 'property', 'Templates::SetupWizard::Map',     'ntw' )
	"
	" syntax: comments
	call mmtemplates#core#ChangeSyntax ( g:Latex_Templates, 'comment', '§' )

	" property: file skeletons
	call mmtemplates#core#Resource ( g:Latex_Templates, 'add', 'property', 'Latex::FileSkeleton::Script', 'Comments.file prolog' )

	"-------------------------------------------------------------------------------
	" load template library
	"-------------------------------------------------------------------------------

	" global templates (global installation only)
	if s:installation == 'system'
		call mmtemplates#core#ReadTemplates ( g:Latex_Templates, 'load', s:Latex_GlobalTemplateFile,
					\ 'name', 'global', 'map', 'ntg' )
	endif

	" local templates (optional for global installation)
	if s:installation == 'system'
		call mmtemplates#core#ReadTemplates ( g:Latex_Templates, 'load', s:Latex_LocalTemplateFile,
					\ 'name', 'local', 'map', 'ntl', 'optional', 'hidden' )
	else
		call mmtemplates#core#ReadTemplates ( g:Latex_Templates, 'load', s:Latex_LocalTemplateFile,
					\ 'name', 'local', 'map', 'ntl' )
	endif

	" additional templates (optional)
	if ! empty ( s:Latex_AdditionalTemplates )
		call mmtemplates#core#AddCustomTemplateFiles ( g:Latex_Templates, s:Latex_AdditionalTemplates, "LaTeX's additional templates"  )
	endif

	" personal templates (shared across template libraries) (optional, existence of file checked by template engine)
	call mmtemplates#core#ReadTemplates ( g:Latex_Templates, 'personalization',
				\ 'name', 'personal', 'map', 'ntp' )

	" custom templates (optional, existence of file checked by template engine)
	call mmtemplates#core#ReadTemplates ( g:Latex_Templates, 'load', s:Latex_CustomTemplateFile,
				\ 'name', 'custom', 'map', 'ntc', 'optional' )

	"-------------------------------------------------------------------------------
	" further setup
	"-------------------------------------------------------------------------------
	"
	" get the jump tags
	let s:Latex_TemplateJumpTarget = mmtemplates#core#Resource ( g:Latex_Templates, "jumptag" )[0]
	"
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
				\ || mmtemplates#core#ExpandText ( g:Latex_Templates, '|AUTHOR|' ) != 'YOUR NAME'
				\ || s:Latex_InsertFileProlog != 'yes'
		return
	endif

	let s:DoneCheckTemplatePersonalization = 1

	let maplead = mmtemplates#core#Resource ( g:Latex_Templates, 'get', 'property', 'Templates::Mapleader' )[0]

	redraw
	call s:ImportantMsg ( 'The personal details are not set in the template library. Use the map "'.maplead.'ntw".' )

endfunction    " ----------  end of function s:CheckTemplatePersonalization  ----------

"-------------------------------------------------------------------------------
" s:CheckAndRereadTemplates : Make sure the templates are loaded.   {{{1
"-------------------------------------------------------------------------------
function! s:CheckAndRereadTemplates ()
	if ! exists ( 'g:Latex_Templates' )
		call s:RereadTemplates()
	endif
endfunction    " ----------  end of function s:CheckAndRereadTemplates  ----------

"-------------------------------------------------------------------------------
" s:InsertFileHeader : Insert a file header.   {{{1
"-------------------------------------------------------------------------------
function! s:InsertFileHeader ()
	call s:CheckAndRereadTemplates()

	" prevent insertion for a file generated from a some error
	if isdirectory(expand('%:p:h')) && s:Latex_InsertFileProlog == 'yes'
		let templ_s = mmtemplates#core#Resource ( g:Latex_Templates, 'get', 'property', 'Latex::FileSkeleton::Script' )[0]

		" insert templates in reverse order, always above the first line
		" the last one to insert (the first in the list), will determine the
		" placement of the cursor
		let templ_l = split ( templ_s, ';' )
		for i in range ( len(templ_l)-1, 0, -1 )
			exe 1
			if -1 != match ( templ_l[i], '^\s\+$' )
				put! =''
			else
				call mmtemplates#core#InsertTemplate ( g:Latex_Templates, templ_l[i], 'placement', 'above' )
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
  let match	= search( s:Latex_TemplateJumpTarget, 'c' )
	if match > 0
		" remove the target
		call setline( match, substitute( getline('.'), s:Latex_TemplateJumpTarget, '', '' ) )
	else
		" try to jump behind parenthesis or strings
		call search( "[\]})\"'`]", 'W' )
		normal! l
	endif
	return ''
endfunction    " ----------  end of function s:JumpForward  ----------

"-------------------------------------------------------------------------------
" s:CreateAdditionalLatexMaps : Create additional maps for LaTeX.   {{{1
"-------------------------------------------------------------------------------
function! s:CreateAdditionalLatexMaps ()
	"
	" ---------- Latex dictionary -------------------------------------------------
	" This will enable keyword completion for Latex
	" using Vim's dictionary feature |i_CTRL-X_CTRL-K|.
	"
	if exists("g:Latex_Dictionary_File")
		silent! exe 'setlocal dictionary+='.g:Latex_Dictionary_File
	endif
	"
	"-------------------------------------------------------------------------------
	" settings - local leader
	"-------------------------------------------------------------------------------
	if ! empty ( g:Latex_MapLeader )
		if exists ( 'g:maplocalleader' )
			let ll_save = g:maplocalleader
		endif
		let g:maplocalleader = g:Latex_MapLeader
	endif
	"
	"-------------------------------------------------------------------------------
	" comments
	"-------------------------------------------------------------------------------
	nnoremap    <buffer>  <silent>  <LocalLeader>cl         :call <SID>EndOfLineComment()<CR>
	inoremap    <buffer>  <silent>  <LocalLeader>cl    <C-C>:call <SID>EndOfLineComment()<CR>
	vnoremap    <buffer>  <silent>  <LocalLeader>cl         :call <SID>EndOfLineComment()<CR>
	"
	nnoremap    <buffer>  <silent>  <LocalLeader>cj         :call <SID>AdjustLineEndComm()<CR>
	inoremap    <buffer>  <silent>  <LocalLeader>cj    <C-C>:call <SID>AdjustLineEndComm()<CR>
	vnoremap    <buffer>  <silent>  <LocalLeader>cj         :call <SID>AdjustLineEndComm()<CR>
	"
	nnoremap    <buffer>  <silent>  <LocalLeader>cs         :call <SID>GetLineEndCommCol()<CR>
	inoremap    <buffer>  <silent>  <LocalLeader>cs    <C-C>:call <SID>GetLineEndCommCol()<CR>
	vnoremap    <buffer>  <silent>  <LocalLeader>cs    <C-C>:call <SID>GetLineEndCommCol()<CR>
	"
	nnoremap    <buffer>  <silent>  <LocalLeader>cc         :call <SID>CommentToggle()<CR>j
	inoremap    <buffer>  <silent>  <LocalLeader>cc    <C-C>:call <SID>CommentToggle()<CR>j
	vnoremap    <buffer>  <silent>  <LocalLeader>cc         :call <SID>CommentToggle()<CR>j
	"
	"-------------------------------------------------------------------------------
	" snippets
	"-------------------------------------------------------------------------------

	nnoremap  <buffer>  <silent>  <LocalLeader>nr         :call <SID>CodeSnippet("insert")<CR>
	inoremap  <buffer>  <silent>  <LocalLeader>nr    <Esc>:call <SID>CodeSnippet("insert")<CR>
	nnoremap  <buffer>  <silent>  <LocalLeader>nw         :call <SID>CodeSnippet("create")<CR>
	inoremap  <buffer>  <silent>  <LocalLeader>nw    <Esc>:call <SID>CodeSnippet("create")<CR>
	vnoremap  <buffer>  <silent>  <LocalLeader>nw    <Esc>:call <SID>CodeSnippet("vcreate")<CR>
	nnoremap  <buffer>  <silent>  <LocalLeader>ne         :call <SID>CodeSnippet("edit")<CR>
	inoremap  <buffer>  <silent>  <LocalLeader>ne    <Esc>:call <SID>CodeSnippet("edit")<CR>
	nnoremap  <buffer>  <silent>  <LocalLeader>nv         :call <SID>CodeSnippet("view")<CR>
	inoremap  <buffer>  <silent>  <LocalLeader>nv    <Esc>:call <SID>CodeSnippet("view")<CR>

	"-------------------------------------------------------------------------------
	" wizard
	"-------------------------------------------------------------------------------
	nnoremap    <buffer>  <silent> <LocalLeader>wtg       :call <SID>WizardTabbing()<CR>
	inoremap    <buffer>  <silent> <LocalLeader>wtg  <C-C>:call <SID>WizardTabbing()<CR>
	nnoremap    <buffer>  <silent> <LocalLeader>wtr       :call <SID>WizardTabular()<CR>
	inoremap    <buffer>  <silent> <LocalLeader>wtr  <C-C>:call <SID>WizardTabular()<CR>

	"-------------------------------------------------------------------------------
	" run
	"-------------------------------------------------------------------------------
   noremap  <buffer>  <silent>  <LocalLeader>rr         :call <SID>Compile("")<CR><CR>
  inoremap  <buffer>  <silent>  <LocalLeader>rr    <C-C>:call <SID>Compile("")<CR><CR>
  vnoremap  <buffer>  <silent>  <LocalLeader>rr    <C-C>:call <SID>Compile("")<CR><CR>
   noremap  <buffer>  <silent>  <LocalLeader>rla        :call <SID>Lacheck("")<CR>
  inoremap  <buffer>  <silent>  <LocalLeader>rla   <C-C>:call <SID>Lacheck("")<CR>
  vnoremap  <buffer>  <silent>  <LocalLeader>rla   <C-C>:call <SID>Lacheck("")<CR>
   noremap  <buffer>            <LocalLeader>rmd        :LatexMainDoc<SPACE>
  inoremap  <buffer>            <LocalLeader>rmd   <C-C>:LatexMainDoc<SPACE>
  vnoremap  <buffer>            <LocalLeader>rmd   <C-C>:LatexMainDoc<SPACE>
   noremap  <buffer>  <silent>  <LocalLeader>re         :call <SID>BackgroundErrors()<CR>
  inoremap  <buffer>  <silent>  <LocalLeader>re    <C-C>:call <SID>BackgroundErrors()<CR>
  vnoremap  <buffer>  <silent>  <LocalLeader>re    <C-C>:call <SID>BackgroundErrors()<CR>

   noremap  <buffer>  <silent>  <LocalLeader>rdvi       :call <SID>View("dvi")<CR>
  inoremap  <buffer>  <silent>  <LocalLeader>rdvi  <C-C>:call <SID>View("dvi")<CR>
  vnoremap  <buffer>  <silent>  <LocalLeader>rdvi  <C-C>:call <SID>View("dvi")<CR>
   noremap  <buffer>  <silent>  <LocalLeader>rpdf       :call <SID>View("pdf")<CR>
  inoremap  <buffer>  <silent>  <LocalLeader>rpdf  <C-C>:call <SID>View("pdf")<CR>
  vnoremap  <buffer>  <silent>  <LocalLeader>rpdf  <C-C>:call <SID>View("pdf")<CR>
   noremap  <buffer>  <silent>  <LocalLeader>rps        :call <SID>View("ps" )<CR>
  inoremap  <buffer>  <silent>  <LocalLeader>rps   <C-C>:call <SID>View("ps" )<CR>
  vnoremap  <buffer>  <silent>  <LocalLeader>rps   <C-C>:call <SID>View("ps" )<CR>

   noremap  <buffer>  <silent>  <LocalLeader>rmg        :call <SID>Makeglossaries("")<CR>
  inoremap  <buffer>  <silent>  <LocalLeader>rmg   <C-C>:call <SID>Makeglossaries("")<CR>
  vnoremap  <buffer>  <silent>  <LocalLeader>rmg   <C-C>:call <SID>Makeglossaries("")<CR>
   noremap  <buffer>  <silent>  <LocalLeader>rmi        :call <SID>Makeindex("")<CR>
  inoremap  <buffer>  <silent>  <LocalLeader>rmi   <C-C>:call <SID>Makeindex("")<CR>
  vnoremap  <buffer>  <silent>  <LocalLeader>rmi   <C-C>:call <SID>Makeindex("")<CR>
   noremap  <buffer>  <silent>  <LocalLeader>rbi        :call <SID>Bibtex("")<CR>
  inoremap  <buffer>  <silent>  <LocalLeader>rbi   <C-C>:call <SID>Bibtex("")<CR>
  vnoremap  <buffer>  <silent>  <LocalLeader>rbi   <C-C>:call <SID>Bibtex("")<CR>

	nnoremap  <buffer>            <LocalLeader>rt         :LatexTypesetter<SPACE>
	inoremap  <buffer>            <LocalLeader>rt    <Esc>:LatexTypesetter<SPACE>
	vnoremap  <buffer>            <LocalLeader>rt    <Esc>:LatexTypesetter<SPACE>

	nnoremap  <buffer>            <LocalLeader>rp         :LatexProcessing<SPACE>
	inoremap  <buffer>            <LocalLeader>rp    <Esc>:LatexProcessing<SPACE>
	vnoremap  <buffer>            <LocalLeader>rp    <Esc>:LatexProcessing<SPACE>

	nnoremap  <buffer>  <silent>  <LocalLeader>rs         :call Latex_Settings(0)<CR>

	 noremap  <buffer>  <silent>  <LocalLeader>rh         :call <SID>Hardcopy("n")<CR>
	vnoremap  <buffer>  <silent>  <LocalLeader>rh    <C-C>:call <SID>Hardcopy("v")<CR>
	inoremap  <buffer>  <silent>  <LocalLeader>rh    <C-C>:call <SID>Hardcopy("n")<CR>
	"
	 noremap  <buffer>  <silent>  <LocalLeader>rc        :call <SID>Conversions("","")<CR>
	inoremap  <buffer>  <silent>  <LocalLeader>rc   <C-C>:call <SID>Conversions("","")<CR>
	vnoremap  <buffer>  <silent>  <LocalLeader>rc   <C-C>:call <SID>Conversions("","")<CR>
	"
	"-------------------------------------------------------------------------------
	" tool box
	"-------------------------------------------------------------------------------
	if s:Latex_UseToolbox == 'yes'
		call mmtoolbox#tools#AddMaps ( s:Latex_Toolbox )
	endif
	"
	"-------------------------------------------------------------------------------
	" help
	"-------------------------------------------------------------------------------
	 noremap  <buffer>  <silent>  <LocalLeader>hp         :call <SID>HelpPlugin()<CR>
	inoremap  <buffer>  <silent>  <LocalLeader>hp    <C-C>:call <SID>HelpPlugin()<CR>
  "
	 noremap  <buffer>  <silent>  <LocalLeader>ht         :call <SID>Texdoc()<CR>
	inoremap  <buffer>  <silent>  <LocalLeader>ht    <C-C>:call <SID>Texdoc()<CR>
	"
	"-------------------------------------------------------------------------------
	" settings - reset local leader
	"-------------------------------------------------------------------------------
	if ! empty ( g:Latex_MapLeader )
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
	if s:Latex_Ctrl_j == 'yes'
		nnoremap  <buffer>  <silent>  <C-j>       i<C-R>=<SID>JumpForward()<CR>
		inoremap  <buffer>  <silent>  <C-j>  <C-G>u<C-R>=<SID>JumpForward()<CR>
	endif

	if s:Latex_Ctrl_d == 'yes'
		call mmtemplates#core#CreateMaps ( 'g:Latex_Templates', g:Latex_MapLeader, 'do_special_maps', 'do_del_opt_map' )
	else
		call mmtemplates#core#CreateMaps ( 'g:Latex_Templates', g:Latex_MapLeader, 'do_special_maps' )
	endif

endfunction    " ----------  end of function s:CreateAdditionalLatexMaps  ----------

"-------------------------------------------------------------------------------
" s:CreateAdditionalBibtexMaps : Create additional maps for BibTeX.   {{{1
"-------------------------------------------------------------------------------
function! s:CreateAdditionalBibtexMaps ()
	"
	"-------------------------------------------------------------------------------
	" settings - local leader
	"-------------------------------------------------------------------------------
	if ! empty ( g:Latex_MapLeader )
		if exists ( 'g:maplocalleader' )
			let ll_save = g:maplocalleader
		endif
		let g:maplocalleader = g:Latex_MapLeader
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
	"
	nnoremap  <buffer>  <silent>  <LocalLeader>cc         :call <SID>CommentToggle()<CR>j
	inoremap  <buffer>  <silent>  <LocalLeader>cc    <C-C>:call <SID>CommentToggle()<CR>j
	vnoremap  <buffer>  <silent>  <LocalLeader>cc         :call <SID>CommentToggle()<CR>j
	"
	"-------------------------------------------------------------------------------
	" BibTeX
	"-------------------------------------------------------------------------------
	nnoremap  <buffer>  <silent>  <LocalLeader>bb         :call <SID>BibtexBeautify()<CR>j
	inoremap  <buffer>  <silent>  <LocalLeader>bb    <C-C>:call <SID>BibtexBeautify()<CR>j
	vnoremap  <buffer>  <silent>  <LocalLeader>bb         :call <SID>BibtexBeautify()<CR>j
	"
	"-------------------------------------------------------------------------------
	" snippets
	"-------------------------------------------------------------------------------

	nnoremap  <buffer>  <silent>  <LocalLeader>nr         :call <SID>CodeSnippet("insert")<CR>
	inoremap  <buffer>  <silent>  <LocalLeader>nr    <Esc>:call <SID>CodeSnippet("insert")<CR>
	nnoremap  <buffer>  <silent>  <LocalLeader>nw         :call <SID>CodeSnippet("create")<CR>
	inoremap  <buffer>  <silent>  <LocalLeader>nw    <Esc>:call <SID>CodeSnippet("create")<CR>
	vnoremap  <buffer>  <silent>  <LocalLeader>nw    <Esc>:call <SID>CodeSnippet("vcreate")<CR>
	nnoremap  <buffer>  <silent>  <LocalLeader>ne         :call <SID>CodeSnippet("edit")<CR>
	inoremap  <buffer>  <silent>  <LocalLeader>ne    <Esc>:call <SID>CodeSnippet("edit")<CR>
	nnoremap  <buffer>  <silent>  <LocalLeader>nv         :call <SID>CodeSnippet("view")<CR>
	inoremap  <buffer>  <silent>  <LocalLeader>nv    <Esc>:call <SID>CodeSnippet("view")<CR>

	"-------------------------------------------------------------------------------
	" run
	"-------------------------------------------------------------------------------
   noremap  <buffer>  <silent>  <LocalLeader>re         :call <SID>BackgroundErrors()<CR>
  inoremap  <buffer>  <silent>  <LocalLeader>re    <C-C>:call <SID>BackgroundErrors()<CR>
  vnoremap  <buffer>  <silent>  <LocalLeader>re    <C-C>:call <SID>BackgroundErrors()<CR>

   noremap  <buffer>  <silent>  <LocalLeader>rmg        :call <SID>Makeglossaries("")<CR>
  inoremap  <buffer>  <silent>  <LocalLeader>rmg   <C-C>:call <SID>Makeglossaries("")<CR>
  vnoremap  <buffer>  <silent>  <LocalLeader>rmg   <C-C>:call <SID>Makeglossaries("")<CR>
   noremap  <buffer>  <silent>  <LocalLeader>rmi        :call <SID>Makeindex("")<CR>
  inoremap  <buffer>  <silent>  <LocalLeader>rmi   <C-C>:call <SID>Makeindex("")<CR>
  vnoremap  <buffer>  <silent>  <LocalLeader>rmi   <C-C>:call <SID>Makeindex("")<CR>
   noremap  <buffer>  <silent>  <LocalLeader>rbi        :call <SID>Bibtex("")<CR>
  inoremap  <buffer>  <silent>  <LocalLeader>rbi   <C-C>:call <SID>Bibtex("")<CR>
  vnoremap  <buffer>  <silent>  <LocalLeader>rbi   <C-C>:call <SID>Bibtex("")<CR>
	"
	nnoremap  <buffer>  <silent>  <LocalLeader>rs         :call Latex_Settings(0)<CR>
  "
	 noremap  <buffer>  <silent>  <LocalLeader>rh         :call <SID>Hardcopy("n")<CR>
	vnoremap  <buffer>  <silent>  <LocalLeader>rh    <C-C>:call <SID>Hardcopy("v")<CR>
	inoremap  <buffer>  <silent>  <LocalLeader>rh    <C-C>:call <SID>Hardcopy("n")<CR>
	"
	"-------------------------------------------------------------------------------
	" tool box
	"-------------------------------------------------------------------------------
	if s:Latex_UseToolbox == 'yes'
		call mmtoolbox#tools#AddMaps ( s:Latex_Toolbox )
	endif
	"
	"-------------------------------------------------------------------------------
	" help
	"-------------------------------------------------------------------------------
	 noremap  <buffer>  <silent>  <LocalLeader>hp         :call <SID>HelpPlugin()<CR>
	inoremap  <buffer>  <silent>  <LocalLeader>hp    <C-C>:call <SID>HelpPlugin()<CR>
	"
	 noremap  <buffer>  <silent>  <LocalLeader>ht         :call <SID>Texdoc()<CR>
	inoremap  <buffer>  <silent>  <LocalLeader>ht    <C-C>:call <SID>Texdoc()<CR>
	"
	"-------------------------------------------------------------------------------
	" settings - reset local leader
	"-------------------------------------------------------------------------------
	if ! empty ( g:Latex_MapLeader )
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
	nnoremap  <buffer>  <silent>  <C-j>       i<C-R>=<SID>JumpForward()<CR>
	inoremap  <buffer>  <silent>  <C-j>  <C-G>u<C-R>=<SID>JumpForward()<CR>
	"
	" ----------------------------------------------------------------------------
	"
	call mmtemplates#core#CreateMaps ( 'g:Latex_Templates', g:Latex_MapLeader, 'do_special_maps', 'do_del_opt_map', 'filetype', 'bibtex' ) |
	"
endfunction    " ----------  end of function s:CreateAdditionalBibtexMaps  ----------

"-------------------------------------------------------------------------------
" s:InitMenus : Initialize menus.   {{{1
"-------------------------------------------------------------------------------
function! s:InitMenus()

	if ! has ( 'menu' )
		return
	endif

	" Preparation
	call mmtemplates#core#CreateMenus ( 'g:Latex_Templates', s:Latex_RootMenu, 'do_reset' )

	" get the mapleader (correctly escaped)
	let [ esc_mapl, err ] = mmtemplates#core#Resource ( g:Latex_Templates, 'escaped_mapleader' )

	exe 'amenu '.s:Latex_RootMenu.'.LaTeX   <Nop>'
	exe 'amenu '.s:Latex_RootMenu.'.-Sep00- <Nop>'

	"-------------------------------------------------------------------------------
	" menu headers
	"-------------------------------------------------------------------------------

	call mmtemplates#core#CreateMenus ( 'g:Latex_Templates', s:Latex_RootMenu, 'sub_menu', '&Comments', 'priority', 500 )
	" the other, automatically created menus go here; their priority is the standard priority 500
	call mmtemplates#core#CreateMenus ( 'g:Latex_Templates', s:Latex_RootMenu, 'sub_menu', 'S&nippets', 'priority', 600 )
	call mmtemplates#core#CreateMenus ( 'g:Latex_Templates', s:Latex_RootMenu, 'sub_menu', '&Wizard'  , 'priority', 700 )
	call mmtemplates#core#CreateMenus ( 'g:Latex_Templates', s:Latex_RootMenu, 'sub_menu', '&Run'     , 'priority', 800 )
	if s:Latex_UseToolbox == 'yes' && mmtoolbox#tools#Property ( s:Latex_Toolbox, 'empty-menu' ) == 0
		call mmtemplates#core#CreateMenus ( 'g:Latex_Templates', s:Latex_RootMenu, 'sub_menu', 'Tool\ Bo&x', 'priority', 900 )
	endif
	call mmtemplates#core#CreateMenus ( 'g:Latex_Templates', s:Latex_RootMenu, 'sub_menu', '&Help'    , 'priority', 1000 )

	"-------------------------------------------------------------------------------
	" comments
	"-------------------------------------------------------------------------------

	let  head =  'noremenu <silent> '.s:Latex_RootMenu.'.Comments.'
	let ahead = 'anoremenu <silent> '.s:Latex_RootMenu.'.Comments.'
	let ihead = 'inoremenu <silent> '.s:Latex_RootMenu.'.Comments.'
	let vhead = 'vnoremenu <silent> '.s:Latex_RootMenu.'.Comments.'

	exe ahead.'end-of-&line\ comment<Tab>'.esc_mapl.'cl                    :call <SID>EndOfLineComment()<CR>'
	exe ihead.'end-of-&line\ comment<Tab>'.esc_mapl.'cl               <Esc>:call <SID>EndOfLineComment()<CR>'
	exe vhead.'end-of-&line\ comment<Tab>'.esc_mapl.'cl                    :call <SID>EndOfLineComment()<CR>'

	exe ahead.'ad&just\ end-of-line\ com\.<Tab>'.esc_mapl.'cj              :call <SID>AdjustLineEndComm()<CR>'
	exe ihead.'ad&just\ end-of-line\ com\.<Tab>'.esc_mapl.'cj         <Esc>:call <SID>AdjustLineEndComm()<CR>'
	exe vhead.'ad&just\ end-of-line\ com\.<Tab>'.esc_mapl.'cj              :call <SID>AdjustLineEndComm()<CR>'
	exe  head.'&set\ end-of-line\ com\.\ col\.<Tab>'.esc_mapl.'cs     <Esc>:call <SID>GetLineEndCommCol()<CR>'

	exe ahead.'&comment<TAB>'.esc_mapl.'cc       :call <SID>CommentToggle()<CR>j'
	exe ihead.'&comment<TAB>'.esc_mapl.'cc  <C-C>:call <SID>CommentToggle()<CR>j'
	exe vhead.'&comment<TAB>'.esc_mapl.'cc       :call <SID>CommentToggle()<CR>j'
	exe ahead.'-Sep02-                           :'

	"-------------------------------------------------------------------------------
	" generate menus from the templates
	"-------------------------------------------------------------------------------
	call mmtemplates#core#CreateMenus ( 'g:Latex_Templates', s:Latex_RootMenu, 'do_templates' )

	"-------------------------------------------------------------------------------
	" snippets
	"-------------------------------------------------------------------------------

	let ahead = 'anoremenu <silent> '.s:Latex_RootMenu.'.S&nippets.'
	let ihead = 'inoremenu <silent> '.s:Latex_RootMenu.'.S&nippets.'
	let vhead = 'vnoremenu <silent> '.s:Latex_RootMenu.'.S&nippets.'

	exe ahead.'&read\ code\ snippet<Tab>'.esc_mapl.'nr       :call <SID>CodeSnippet("insert")<CR>'
	exe ihead.'&read\ code\ snippet<Tab>'.esc_mapl.'nr  <C-C>:call <SID>CodeSnippet("insert")<CR>'
	exe ahead.'&write\ code\ snippet<Tab>'.esc_mapl.'nw      :call <SID>CodeSnippet("create")<CR>'
	exe ihead.'&write\ code\ snippet<Tab>'.esc_mapl.'nw <C-C>:call <SID>CodeSnippet("create")<CR>'
	exe vhead.'&write\ code\ snippet<Tab>'.esc_mapl.'nw <C-C>:call <SID>CodeSnippet("vcreate")<CR>'
	exe ahead.'&view\ code\ snippet<Tab>'.esc_mapl.'nv       :call <SID>CodeSnippet("view")<CR>'
	exe ihead.'&view\ code\ snippet<Tab>'.esc_mapl.'nv  <C-C>:call <SID>CodeSnippet("view")<CR>'
	exe ahead.'&edit\ code\ snippet<Tab>'.esc_mapl.'ne       :call <SID>CodeSnippet("edit")<CR>'
	exe ihead.'&edit\ code\ snippet<Tab>'.esc_mapl.'ne  <C-C>:call <SID>CodeSnippet("edit")<CR>'
	exe ahead.'-SepSnippets-                       :'

	call mmtemplates#core#CreateMenus ( 'g:Latex_Templates', s:Latex_RootMenu, 'do_specials', 'specials_menu', 'Snippets'	)

	"-------------------------------------------------------------------------------
	" wizard
	"-------------------------------------------------------------------------------

	let ahead = 'anoremenu <silent> '.s:Latex_RootMenu.'.&Wizard.'
	let ihead = 'inoremenu <silent> '.s:Latex_RootMenu.'.&Wizard.'
	let vhead = 'vnoremenu <silent> '.s:Latex_RootMenu.'.&Wizard.'

	exe ahead.'tables.tabbing<Tab>'.esc_mapl.'wtg                     :call <SID>WizardTabbing()<CR>'
	exe ihead.'tables.tabbing<Tab>'.esc_mapl.'wtg                <C-C>:call <SID>WizardTabbing()<CR>'
	exe ahead.'tables.tabular<Tab>'.esc_mapl.'wtr                     :call <SID>WizardTabular()<CR>'
	exe ihead.'tables.tabular<Tab>'.esc_mapl.'wtr                <C-C>:call <SID>WizardTabular()<CR>'

	call mmtemplates#core#CreateMenus ( 'g:Latex_Templates', s:Latex_RootMenu, 'sub_menu', 'Wizard.li&gatures', 'priority', 600 )
	exe ahead.'li&gatures.find\ double       <C-C>:/f[filt]<CR>'
	exe ahead.'li&gatures.find\ triple       <C-C>:/ff[filt]<CR>'
	exe ahead.'li&gatures.split\ with\ \\\/  <C-C>a\/<Esc>'
	exe ahead.'li&gatures.highlight\ off     <C-C>:nohlsearch<CR>'

	"-------------------------------------------------------------------------------
	" run
	"-------------------------------------------------------------------------------

	let ahead = 'anoremenu <silent> '.s:Latex_RootMenu.'.Run.'
	let ihead = 'inoremenu <silent> '.s:Latex_RootMenu.'.Run.'
	let vhead = 'vnoremenu <silent> '.s:Latex_RootMenu.'.Run.'
	let ahead_loud = 'anoremenu     '.s:Latex_RootMenu.'.Run.'
	let ihead_loud = 'inoremenu     '.s:Latex_RootMenu.'.Run.'

	exe ahead.'save\ +\ &run\ typesetter<Tab>'.esc_mapl.'rr       :call <SID>Compile("")<CR><CR>'
	exe ihead.'save\ +\ &run\ typesetter<Tab>'.esc_mapl.'rr  <C-C>:call <SID>Compile("")<CR><CR>'
	exe ahead.'save\ +\ run\ &lacheck<Tab>'.esc_mapl.'rla         :call <SID>Lacheck("")<CR>'
	exe ihead.'save\ +\ run\ &lacheck<Tab>'.esc_mapl.'rla    <C-C>:call <SID>Lacheck("")<CR>'
	exe ahead_loud.'&set\ main\ document<Tab>'.esc_mapl.'rmd      :LatexMainDoc '
	exe ihead_loud.'&set\ main\ document<Tab>'.esc_mapl.'rmd <C-C>:LatexMainDoc '
	exe ahead.'view\ last\ &errors<Tab>'.esc_mapl.'re             :call <SID>BackgroundErrors()<CR>'
	exe ihead.'view\ last\ &errors<Tab>'.esc_mapl.'re        <C-C>:call <SID>BackgroundErrors()<CR>'

	exe ahead.'-SEP-VIEW-  :'
	call mmtemplates#core#CreateMenus ( 'g:Latex_Templates', s:Latex_RootMenu, 'sub_menu', 'Run'.'.&View' )
	exe ahead.'View.&DVI<Tab>'.esc_mapl.'rdvi       :call <SID>View("dvi")<CR>'
	exe ihead.'View.&DVI<Tab>'.esc_mapl.'rdvi  <C-C>:call <SID>View("dvi")<CR>'
	exe ahead.'View.&PDF<Tab>'.esc_mapl.'rpdf       :call <SID>View("pdf")<CR>'
	exe ihead.'View.&PDF<Tab>'.esc_mapl.'rpdf  <C-C>:call <SID>View("pdf")<CR>'
	exe ahead.'View.&PS<Tab>'.esc_mapl.'rps         :call <SID>View("ps" )<CR>'
	exe ihead.'View.&PS<Tab>'.esc_mapl.'rps    <C-C>:call <SID>View("ps" )<CR>'

	call mmtemplates#core#CreateMenus ( 'g:Latex_Templates', s:Latex_RootMenu, 'sub_menu', 'Run'.'.&Convert<TAB>'.esc_mapl.'rc' )
	exe ahead.'Convert.DVI->PDF                               :call <SID>Conversions("","dvi-pdf")<CR>'
	exe ihead.'Convert.DVI->PDF                          <C-C>:call <SID>Conversions("","dvi-pdf")<CR>'
	exe ahead.'Convert.DVI->PS                                :call <SID>Conversions("","dvi-ps" )<CR>'
	exe ihead.'Convert.DVI->PS                           <C-C>:call <SID>Conversions("","dvi-ps" )<CR>'
	exe ahead.'Convert.DVI->PNG                               :call <SID>Conversions("","dvi-png")<CR>'
	exe ihead.'Convert.DVI->PNG                          <C-C>:call <SID>Conversions("","dvi-png")<CR>'
	exe ahead.'Convert.EPS->PDF                               :call <SID>Conversions("","eps-pdf")<CR>'
	exe ihead.'Convert.EPS->PDF                          <C-C>:call <SID>Conversions("","eps-pdf")<CR>'
	exe ahead.'Convert.PDF->PNG                               :call <SID>Conversions("","pdf-png")<CR>'
	exe ihead.'Convert.PDF->PNG                          <C-C>:call <SID>Conversions("","pdf-png")<CR>'
	exe ahead.'Convert.PS->PDF                                :call <SID>Conversions("","ps-pdf" )<CR>'
	exe ihead.'Convert.PS->PDF                           <C-C>:call <SID>Conversions("","ps-pdf" )<CR>'

	exe ahead.'-SEP1-                            :'
	exe ahead.'run\ make&glossaries<Tab>'.esc_mapl.'rmg                  :call <SID>Makeglossaries("")<CR>'
	exe ihead.'run\ make&glossaries<Tab>'.esc_mapl.'rmg             <C-C>:call <SID>Makeglossaries("")<CR>'
	exe ahead.'run\ make&index<Tab>'.esc_mapl.'rmi                       :call <SID>Makeindex("")<CR>'
	exe ihead.'run\ make&index<Tab>'.esc_mapl.'rmi                  <C-C>:call <SID>Makeindex("")<CR>'
	exe ahead.'run\ &bibtex<Tab>'.esc_mapl.'rbi                          :call <SID>Bibtex("")<CR>'
	exe ihead.'run\ &bibtex<Tab>'.esc_mapl.'rbi                     <C-C>:call <SID>Bibtex("")<CR>'
	exe ahead.'-SEP2-                            :'

	" create a dummy menu header for the "choose typesetter" sub-menu
	exe ahead.'choose\ &typesetter<TAB>'.esc_mapl.'rt.Typesetter   :'
	exe ahead.'choose\ &typesetter<TAB>'.esc_mapl.'rt.-SepHead-    :'

	" create a dummy menu header for the "external processing" sub-menu
	exe ahead.'external\ &processing<TAB>'.esc_mapl.'rp.Processing   :'
	exe ahead.'external\ &processing<TAB>'.esc_mapl.'rp.-SepHead-    :'

	exe ahead.'-SEP3-                            :'
	exe ahead.'&hardcopy\ to\ FILENAME\.ps<Tab>'.esc_mapl.'rh        :call <SID>Hardcopy("n")<CR>'
	exe vhead.'&hardcopy\ to\ FILENAME\.ps<Tab>'.esc_mapl.'rh   <C-C>:call <SID>Hardcopy("v")<CR>'
	exe ihead.'&hardcopy\ to\ FILENAME\.ps<Tab>'.esc_mapl.'rh   <C-C>:call <SID>Hardcopy("n")<CR>'

	exe ahead.'-SEP4-                            :'
	exe ahead.'plug-in\ &settings<Tab>'.esc_mapl.'rs                 :call Latex_Settings(0)<CR>'
	exe ihead.'plug-in\ &settings<Tab>'.esc_mapl.'rs            <C-C>:call Latex_Settings(0)<CR>'

	" run -> choose typesetter
	for ts in s:Latex_TypesetterList
		exe ahead.'choose\ typesetter.'.ts.'       :call <SID>SetTypesetter("'.ts.'")<CR>'
		exe ihead.'choose\ typesetter.'.ts.'  <C-C>:call <SID>SetTypesetter("'.ts.'")<CR>'
	endfor

	" run -> external processing
	for m in s:Latex_ProcessingList
		exe ahead.'external\ processing.'.m.'       :call <SID>SetProcessing("'.m.'")<CR>'
		exe ihead.'external\ processing.'.m.'  <C-C>:call <SID>SetProcessing("'.m.'")<CR>'
	endfor

	" deletes the dummy menu header and displays the current options
	" in the menu header of the sub-menus
	call s:SetTypesetter ( s:Latex_Typesetter )
	call s:SetProcessing ( s:Latex_Processing )

	"-------------------------------------------------------------------------------
	" toolbox
	"-------------------------------------------------------------------------------

	if s:Latex_UseToolbox == 'yes' && mmtoolbox#tools#Property ( s:Latex_Toolbox, 'empty-menu' ) == 0
		call mmtoolbox#tools#AddMenus ( s:Latex_Toolbox, s:Latex_RootMenu.'.Tool\ Box' )
	endif

	"-------------------------------------------------------------------------------
	" help
	"-------------------------------------------------------------------------------

	let ahead = 'anoremenu <silent> '.s:Latex_RootMenu.'.Help.'
	let ihead = 'inoremenu <silent> '.s:Latex_RootMenu.'.Help.'

	exe ahead.'&texdoc<Tab>'.esc_mapl.'ht        :call <SID>Texdoc()<CR>'
	exe ihead.'&texdoc<Tab>'.esc_mapl.'ht   <C-C>:call <SID>Texdoc()<CR>'
	exe ahead.'-SEP1- :'
	exe ahead.'&help\ (Latex-Support)<Tab>'.esc_mapl.'hp        :call <SID>HelpPlugin()<CR>'
	exe ihead.'&help\ (Latex-Support)<Tab>'.esc_mapl.'hp   <C-C>:call <SID>HelpPlugin()<CR>'

endfunction    " ----------  end of function s:InitMenus  ----------

"-------------------------------------------------------------------------------
" s:ToolMenu : Add or remove tool menu entries.   {{{1
"
" Parameters:
"   action - 'setup', 'load', or 'unload' (string)
"-------------------------------------------------------------------------------
function! s:ToolMenu( action )

	if ! has ( 'menu' )
		return
	endif

	if a:action == 'setup'
		anoremenu <silent> 40.1000 &Tools.-SEP100- :
		anoremenu <silent> 40.1110 &Tools.Load\ LaTeX\ Support   :call <SID>AddMenus()<CR>
	elseif a:action == 'load'
		aunmenu   <silent> &Tools.Load\ LaTeX\ Support
		anoremenu <silent> 40.1110 &Tools.Unload\ LaTeX\ Support :call <SID>RemoveMenus()<CR>
	elseif a:action == 'unload'
		aunmenu   <silent> &Tools.Unload\ LaTeX\ Support
		anoremenu <silent> 40.1110 &Tools.Load\ LaTeX\ Support   :call <SID>AddMenus()<CR>
		exe 'aunmenu <silent> '.s:Latex_RootMenu
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
" Latex_Settings : Display plug-in settings.   {{{1
"
" verbosity:
"   0 - basic settings
"   1 - all setting
"   2 - print all settings into buffer
"
" Parameters:
"   verbose - verbosity (integer)
"-------------------------------------------------------------------------------
function! Latex_Settings ( verbose )
	"
	if     s:MSWIN | let sys_name = 'Windows'
	elseif s:UNIX  | let sys_name = 'UN*X'
	else           | let sys_name = 'unknown' | endif
	if    s:NEOVIM | let vim_name = 'nvim'
	else           | let vim_name = has('gui_running') ? 'gvim' : 'vim' | endif

	let	txt = " LaTeX-Support settings\n\n"
	" template settings: macros, style, ...
	if exists ( 'g:Latex_Templates' )
		let txt = txt.'                   author :  "'.mmtemplates#core#ExpandText( g:Latex_Templates, '|AUTHOR|'      )."\"\n"
		let txt = txt.'                authorref :  "'.mmtemplates#core#ExpandText( g:Latex_Templates, '|AUTHORREF|'   )."\"\n"
		let txt = txt.'                    email :  "'.mmtemplates#core#ExpandText( g:Latex_Templates, '|EMAIL|'       )."\"\n"
		let txt = txt.'             organization :  "'.mmtemplates#core#ExpandText( g:Latex_Templates, '|ORGANIZATION|')."\"\n"
		let txt = txt.'         copyright holder :  "'.mmtemplates#core#ExpandText( g:Latex_Templates, '|COPYRIGHT|'   )."\"\n"
		let txt = txt.'                  licence :  "'.mmtemplates#core#ExpandText( g:Latex_Templates, '|LICENSE|'     )."\"\n"
		let txt = txt.'                  project :  "'.mmtemplates#core#ExpandText( g:Latex_Templates, '|PROJECT|'     )."\"\n\n"
	else
		let txt .= "                templates :  -not loaded-\n\n"
	endif
	" plug-in installation
	let txt .= '      plugin installation :  '.s:installation.' in '.vim_name.' on '.sys_name."\n"
	" toolbox
	if s:Latex_UseToolbox == 'yes'
		let toollist = mmtoolbox#tools#GetList ( s:Latex_Toolbox )
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
	if exists ( 'g:Latex_Templates' )
		let [ templist, msg ] = mmtemplates#core#Resource ( g:Latex_Templates, 'template_list' )
		let sep  = "\n"."                             "
		let txt .=      "           template files :  "
					\ .join ( templist, sep )."\n"
	else
		let txt .= "           template files :  -not loaded-\n"
	endif
	let txt = txt.'   code snippet directory :  "'.s:Latex_CodeSnippets."\"\n"
	" ----- dictionaries ------------------------
  if !empty(g:Latex_Dictionary_File)
		let ausgabe= &dictionary
		let ausgabe= substitute( ausgabe, ",", ",\n                             ", "g" )
		let txt = txt."       dictionary file(s) :  ".ausgabe."\n"
	endif
	" ----- map leader, menus, file headers -----
	if a:verbose >= 1
		let	txt .= "\n"
					\ .'                mapleader :  "'.g:Latex_MapLeader."\"\n"
					\ .'     load menus / delayed :  "'.s:Latex_LoadMenus.'" / "'.s:Latex_CreateMenusDelayed."\"\n"
					\ .'       insert file prolog :  "'.s:Latex_InsertFileProlog."\"\n"
	endif
	let txt = txt."\n"
	let txt = txt.'               typesetter :  "'.s:Latex_TypesetterCall[s:Latex_Typesetter]."\"\n"
	let txt = txt.'      external processing :  "'.s:Latex_Processing."\"\n"
	let	txt = txt."__________________________________________________________________________\n"
	let	txt = txt." LaTeX-Support, Version ".g:LatexSupportVersion." / Wolfgang Mehner / wolfgang-mehner@web.de\n\n"
	"
	if a:verbose == 2
		split LatexSupport_Settings.txt
		put = txt
	else
		echo txt
	endif
endfunction    " ----------  end of function Latex_Settings ----------

"-------------------------------------------------------------------------------
" === Setup: Templates, toolbox and menus ===   {{{1
"-------------------------------------------------------------------------------

" setup the toolbox
if s:Latex_UseToolbox == 'yes'
	"
	let s:Latex_Toolbox = mmtoolbox#tools#NewToolbox ( 'Latex' )
	call mmtoolbox#tools#Property ( s:Latex_Toolbox, 'mapleader', g:Latex_MapLeader )
	"
	call mmtoolbox#tools#Load ( s:Latex_Toolbox, s:Latex_ToolboxDir )
	"
	" debugging only:
	"call mmtoolbox#tools#Info ( s:Latex_Toolbox )
	"
endif

" tool menu entry
call s:ToolMenu ( 'setup' )

" load the menu right now?
if s:Latex_LoadMenus == 'yes' && s:Latex_CreateMenusDelayed == 'no'
	call s:AddMenus ()
endif

" user defined commands (working everywhere)
command! -nargs=? -complete=file -bang                 LatexMainDoc         call <SID>SetMainDocument(<q-args>,'<bang>'=='!')
command! -nargs=? -complete=file                       Latex                call <SID>Compile(<q-args>)
command! -nargs=? -complete=file                       LatexBibtex          call <SID>Bibtex(<q-args>)
command! -nargs=? -complete=file                       LatexCheck           call <SID>Lacheck(<q-args>)
command! -nargs=? -complete=file                       LatexMakeglossaries  call <SID>Makeglossaries(<q-args>)
command! -nargs=? -complete=file                       LatexMakeindex       call <SID>Makeindex(<q-args>)
command! -nargs=? -complete=file                       LatexConvert         call <SID>Conversions(<q-args>,'')
command! -nargs=* -complete=file                       LatexView            call <SID>View(<q-args>)

command! -nargs=0                                      LatexErrors      call <SID>BackgroundErrors()

command! -nargs=? -complete=custom,<SID>GetTypesetterList  LatexTypesetter   call <SID>SetTypesetter(<q-args>)
command! -nargs=? -complete=custom,<SID>GetProcessingList  LatexProcessing   call <SID>SetProcessing(<q-args>)

if has( 'autocmd' )

  " In the absence of any LaTeX keywords, the default filetype for *.tex files is 'plaintex'.
  " This means new files have this filetype.

  autocmd FileType *
        \ if &filetype == 'plaintex' && s:Latex_TexFlavor == 'latex' |
        \   set filetype=tex |
        \ endif |
        \ if &filetype == 'tex' |
        \   if ! exists( 'g:Latex_Templates' ) |
        \     if s:Latex_LoadMenus == 'yes' | call s:AddMenus () |
        \     else                          | call s:RereadTemplates ()    |
        \     endif |
        \   endif |
        \   call s:CreateAdditionalLatexMaps () |
				\		call s:CheckTemplatePersonalization() |
        \ endif

  autocmd FileType *
        \ if &filetype == 'bib' |
        \   if ! exists( 'g:Latex_Templates' ) |
        \     if s:Latex_LoadMenus == 'yes' | call s:AddMenus () |
        \     else                          | call s:RereadTemplates ()    |
        \     endif |
        \   endif |
        \   call s:CreateAdditionalBibtexMaps () |
				\		call s:CheckTemplatePersonalization() |
        \ endif

	if s:Latex_TexFlavor == 'latex' && s:Latex_InsertFileProlog == 'yes'
		autocmd BufNewFile  *.tex  call s:InsertFileHeader()
	endif

endif
" }}}1
"-------------------------------------------------------------------------------

" =====================================================================================
" vim: tabstop=2 shiftwidth=2 foldmethod=marker
