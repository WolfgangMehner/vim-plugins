"===============================================================================
"
"          File:  latex-support.vim
" 
"   Description:  LaTeX support     (VIM Version 7.0+)
"
"                  Write LaTeX scripts by inserting comments, statements,
"                  variables and builtins.
" 
"   VIM Version:  7.0+
"        Author:  Dr. Fritz Mehner (fgm), mehner.fritz@fh-swf.de
"  Organization:  FH Südwestfalen, Iserlohn
"       Version:  1.0
"       Created:  27.12.2012
"      Revision:  0.1
"       License:  Copyright (c) 2012, Dr. Fritz Mehner
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
  echohl WarningMsg | echo 'plugin latex-support.vim needs Vim version >= 7'| echohl None
  finish
endif
"
" Prevent duplicate loading:
"
if exists("g:LatexSupportVersion") || &cp
 finish
endif
"
let g:LatexSupportVersion= "1.0"                  " version number of this script; do not change
"
"===  FUNCTION  ================================================================
"          NAME:  latex_SetGlobalVariable     {{{1
"   DESCRIPTION:  Define a global variable and assign a default value if nor
"                 already defined
"    PARAMETERS:  name - global variable
"                 default - default value
"===============================================================================
function! s:latex_SetGlobalVariable ( name, default )
  if !exists('g:'.a:name)
    exe 'let g:'.a:name."  = '".a:default."'"
	else
		" check for an empty initialization
		exe 'let	val	= g:'.a:name
		if empty(val)
			exe 'let g:'.a:name."  = '".a:default."'"
		endif
  endif
endfunction   " ---------- end of function  s:latex_SetGlobalVariable  ----------
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
let s:MSWIN = has("win16") || has("win32")   || has("win64") || has("win95")
let s:UNIX	= has("unix")  || has("macunix") || has("win32unix")
"
let s:installation							= '*undefined*'
let s:Latex_GlobalTemplateFile	= ''
let s:Latex_GlobalTemplateDir		= ''
let s:Latex_LocalTemplateFile		= ''
let s:Latex_LocalTemplateDir		= ''
let s:Latex_FilenameEscChar 		= ''

let s:Latex_Typesetter 			= 'pdflatex'
let s:Latex_TypesetterCall	= {
			\ 'latex' 		: 'latex    -src-specials -file-line-error -interaction=nonstopmode',
			\ 'tex' 			: 'tex      -src-specials -file-line-error -interaction=nonstopmode',
			\ 'pdflatex' 	: 'pdflatex -src-specials -file-line-error -interaction=nonstopmode',
			\ 'pdftex' 		: 'pdftex   -src-specials -file-line-error -interaction=nonstopmode',
			\ }

let s:Latex_ConverterCall	= {
			\ 'dvi-pdf' 	: 'dvipdft',
			\ 'dvi-png'		: 'dvipng',
			\ 'dvi-ps'		: 'dvips',
			\ 'pdf-png'		: 'convert',
			\ 'ps-pdf'		: 'ps2pdf',
			\ }


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
		let s:Latex_LocalTemplateFile	= s:plugin_dir.'/latex-support/templates/Templates'
		let s:Latex_LocalTemplateDir	= fnamemodify( s:Latex_LocalTemplateFile, ":p:h" ).'/'
	else
		"
		" SYSTEM WIDE INSTALLATION
		let s:installation					= 'system'
		let s:plugin_dir						= $VIM.'/vimfiles'
		let s:Latex_GlobalTemplateDir	= s:plugin_dir.'/latex-support/templates'
		let s:Latex_GlobalTemplateFile= s:Latex_GlobalTemplateDir.'/Templates'
		let s:Latex_LocalTemplateFile	= $HOME.'/vimfiles/latex-support/templates/Templates'
		let s:Latex_LocalTemplateDir	= fnamemodify( s:Latex_LocalTemplateFile, ":p:h" ).'/'
	endif
	"
  let s:Latex_FilenameEscChar 		= ''
	"
else
  " ==========  Linux/Unix  ======================================================
	"
	if match( expand("<sfile>"), expand("$HOME") ) == 0
		"
		" USER INSTALLATION ASSUMED
		let s:installation					= 'local'
		let s:plugin_dir 						= expand('<sfile>:p:h:h')
		let s:Latex_LocalTemplateFile	= s:plugin_dir.'/latex-support/templates/Templates'
		let s:Latex_LocalTemplateDir	= fnamemodify( s:Latex_LocalTemplateFile, ":p:h" ).'/'
	else
		"
		" SYSTEM WIDE INSTALLATION
		let s:installation					= 'system'
		let s:plugin_dir						= $VIM.'/vimfiles'
		let s:Latex_GlobalTemplateDir	= s:plugin_dir.'/latex-support/templates'
		let s:Latex_GlobalTemplateFile= s:Latex_GlobalTemplateDir.'/Templates'
		let s:Latex_LocalTemplateFile	= $HOME.'/.vim/latex-support/templates/Templates'
		let s:Latex_LocalTemplateDir	= fnamemodify( s:Latex_LocalTemplateFile, ":p:h" ).'/'
	endif
	"
  let s:Latex_FilenameEscChar 		= ' \%#[]'
	"
endif
"
let s:Latex_CodeSnippets  				= s:plugin_dir.'/latex-support/codesnippets/'
call s:latex_SetGlobalVariable( 'Latex_CodeSnippets', s:Latex_CodeSnippets )
"
"
"  g:Latex_Dictionary_File  must be global
"
if !exists("g:Latex_Dictionary_File")
	let g:Latex_Dictionary_File     = s:plugin_dir.'/latex-support/wordlists/latex-keywords.list'
endif
"
"----------------------------------------------------------------------
"  *** MODUL GLOBAL VARIABLES *** {{{1
"----------------------------------------------------------------------
"
let s:escfilename 								= ' \%#[]'
let s:Latex_CreateMenusDelayed		= 'yes'
let s:Latex_MenuVisible						= 'no'
let s:Latex_GuiSnippetBrowser 		= 'gui'             " gui / commandline
let s:Latex_LoadMenus         		= 'yes'             " load the menus?
let s:Latex_RootMenu          		= 'LaTe&X'          " name of the root menu
"
let s:Latex_DviViewer         		= "xdvi"
let s:Latex_PsViewer          		= "gv"
let s:Latex_PdfViewer         		= "acroread"
let s:Latex_Bibtex  		          = "bibtex"

let s:Latex_MapLeader             = '´'    
let s:Latex_LineEndCommColDefault = 49
let s:Latex_Printheader   				= "%<%f%h%m%<  %=%{strftime('%x %X')}     Page %N"
let s:Latex_TemplateJumpTarget 		= ''
let s:Latex_Errorformat    				= 'latex:\ %f:%l:\ %m'
let s:Latex_Wrapper               = s:plugin_dir.'/latex-support/scripts/wrapper.sh'
let s:Latex_InsertFileHeader			= 'yes'
"
call s:GetGlobalSetting ( 'Latex_CreateMenusDelayed' )
call s:GetGlobalSetting ( 'Latex_DviViewer' )
call s:GetGlobalSetting ( 'Latex_GlobalTemplateFile' )
call s:GetGlobalSetting ( 'Latex_GuiSnippetBrowser' )
call s:GetGlobalSetting ( 'Latex_InsertFileHeader ')
call s:GetGlobalSetting ( 'Latex_LineEndCommColDefault' )
call s:GetGlobalSetting ( 'Latex_LoadMenus' )
call s:GetGlobalSetting ( 'Latex_LocalTemplateFile' )
call s:GetGlobalSetting ( 'Latex_PdfViewer' )
call s:GetGlobalSetting ( 'Latex_Printheader' )
call s:GetGlobalSetting ( 'Latex_PsViewer' )
call s:GetGlobalSetting ( 'Latex_RootMenu' )
call s:GetGlobalSetting ( 'Latex_Typesetter' )

call s:ApplyDefaultSetting ( 'Latex_MapLeader'    )

let s:Latex_Viewer = {
	\ 'dvi': s:Latex_DviViewer,
	\ 'pdf': s:Latex_PdfViewer,
	\ 'ps': s:Latex_PsViewer,
	\ }
"
let s:Latex_Printheader  					= escape( s:Latex_Printheader, ' %' )
let s:Latex_saved_global_option		= {}
"------------------------------------------------------------------------------
"  Latex_SaveGlobalOption    {{{1
"  param 1 : option name
"  param 2 : characters to be escaped (optional)
"------------------------------------------------------------------------------
function! s:Latex_SaveGlobalOption ( option, ... )
	exe 'let escaped =&'.a:option
	if a:0 == 0
		let escaped	= escape( escaped, ' |"\' )
	else
		let escaped	= escape( escaped, ' |"\'.a:1 )
	endif
	let s:Latex_saved_global_option[a:option]	= escaped
endfunction    " ----------  end of function Latex_SaveGlobalOption  ----------
"
"------------------------------------------------------------------------------
"  Latex_RestoreGlobalOption    {{{1
"------------------------------------------------------------------------------
function! s:Latex_RestoreGlobalOption ( option )
	exe ':set '.a:option.'='.s:Latex_saved_global_option[a:option]
endfunction    " ----------  end of function Latex_RestoreGlobalOption  ----------
"
"===  FUNCTION  ================================================================
"          NAME:  Latex_Input     {{{1
"   DESCRIPTION:  Input after a highlighted prompt
"    PARAMETERS:  prompt       - prompt string
"                 defaultreply - default reply
"                 ...          - completion
"       RETURNS:  reply
"===============================================================================
function! Latex_Input ( prompt, defaultreply, ... )
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
endfunction    " ----------  end of function Latex_Input ----------
"
"===  FUNCTION  ================================================================
"          NAME:  Latex_AdjustLineEndComm     {{{1
"   DESCRIPTION:  adjust end-of-line comments
"    PARAMETERS:  -
"       RETURNS:  
"===============================================================================
function! Latex_AdjustLineEndComm ( ) range
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

		let idx1	= 1 + match( line, '\s*#.*$', 0 )
		let idx2	= 1 + match( line,    '#.*$', 0 )

		" comment with leading whitespaces left unchanged
		if     match( line, '^\s*#' ) == 0
			let idx1	= 0
			let idx2	= 0
		endif

		for regex in s:AlignRegex
			if match( line, regex ) > -1
				let start	= matchend( line, regex )
				let idx1	= 1 + match( line, '\s*#.*$', start )
				let idx2	= 1 + match( line,    '#.*$', start )
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
				exe 'normal	'.diff.'P'
			end

			" remove some spaces
			if vpos1 < b:Latex_LineEndCommentColumn && vpos2 > b:Latex_LineEndCommentColumn
				let	diff	= vpos2 - b:Latex_LineEndCommentColumn
				call setpos('.', [ 0, ln, b:Latex_LineEndCommentColumn, 0 ] )
				exe 'normal	'.diff.'x'
			end

		end
		let linenumber=linenumber+1
		normal j
	endwhile
	" restore tab expansion settings and cursor position
	let &expandtab	= save_expandtab
	call setpos('.', save_cursor)

endfunction		" ---------- end of function  Latex_AdjustLineEndComm  ----------
"
"===  FUNCTION  ================================================================
"          NAME:  Latex_GetLineEndCommCol     {{{1
"   DESCRIPTION:  get end-of-line comment position
"    PARAMETERS:  -
"       RETURNS:  
"===============================================================================
function! Latex_GetLineEndCommCol ()
	let actcol	= virtcol(".")
	if actcol+1 == virtcol("$")
		let	b:Latex_LineEndCommentColumn	= ''
		while match( b:Latex_LineEndCommentColumn, '^\s*\d\+\s*$' ) < 0
			let b:Latex_LineEndCommentColumn = Latex_Input( 'start line-end comment at virtual column : ', actcol, '' )
		endwhile
	else
		let	b:Latex_LineEndCommentColumn	= virtcol(".")
	endif
  echomsg "line end comments will start at column  ".b:Latex_LineEndCommentColumn
endfunction		" ---------- end of function  Latex_GetLineEndCommCol  ----------
"
"===  FUNCTION  ================================================================
"          NAME:  Latex_EndOfLineComment     {{{1
"   DESCRIPTION:  end-of-line comment
"    PARAMETERS:  -
"       RETURNS:  
"===============================================================================
function! Latex_EndOfLineComment ( ) range
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
			exe "normal	".diff."A "
			call mmtemplates#core#InsertTemplate(g:Latex_Templates, 'Comments.end-of-line-comment')
		endif
	endfor
endfunction		" ---------- end of function  Latex_EndOfLineComment  ----------
"
"===  FUNCTION  ================================================================
"          NAME:  Latex_CodeComment     {{{1
"   DESCRIPTION:  Code -> Comment
"    PARAMETERS:  -
"       RETURNS:  
"===============================================================================
function! Latex_CodeComment() range
	" add '% ' at the beginning of the lines
	for line in range( a:firstline, a:lastline )
		exe line.'s/^/% /'
	endfor
endfunction    " ----------  end of function Latex_CodeComment  ----------
"
"===  FUNCTION  ================================================================
"          NAME:  Latex_CommentCode     {{{1
"   DESCRIPTION:  Comment -> Code
"    PARAMETERS:  toggle - 0 : uncomment, 1 : toggle comment
"       RETURNS:  
"===============================================================================
function! Latex_CommentCode( toggle ) range
	for i in range( a:firstline, a:lastline )
		if getline( i ) =~ '^% '
			silent exe i.'s/^% //'
		elseif getline( i ) =~ '^%'
			silent exe i.'s/^%//'
		elseif a:toggle
			silent exe i.'s/^/% /'
		endif
	endfor
	"
endfunction    " ----------  end of function Latex_CommentCode  ----------
"
"===  FUNCTION  ================================================================
"          NAME:  Latex_RereadTemplates     {{{1
"   DESCRIPTION:  Reread the templates. Also set the character which starts
"                 the comments in the template files.
"    PARAMETERS:  -
"       RETURNS:  
"===============================================================================
function! g:Latex_RereadTemplates ( displaymsg )
	let g:Latex_Templates = mmtemplates#core#NewLibrary ()
	call mmtemplates#core#ChangeSyntax  ( g:Latex_Templates, 'comment', '§', '§' )
	let s:Latex_TemplateJumpTarget 		=  mmtemplates#core#Resource ( g:Latex_Templates, "jumptag" )[0]
	let	messsage							= ''
	"
	if s:installation == 'system'
		"-------------------------------------------------------------------------------
		" SYSTEM INSTALLATION
		"-------------------------------------------------------------------------------
		if filereadable( s:Latex_GlobalTemplateFile )
			call mmtemplates#core#ReadTemplates ( g:Latex_Templates, 'load', s:Latex_GlobalTemplateFile )
		else
			echomsg "Global template file '".s:Latex_GlobalTemplateFile."' not readable."
			return
		endif
		let	messsage	= "Templates read from '".s:Latex_GlobalTemplateFile."'"
		"
		"-------------------------------------------------------------------------------
		" handle local template files
		"-------------------------------------------------------------------------------
		if finddir( s:Latex_LocalTemplateDir ) == ''
			" try to create a local template directory
			if exists("*mkdir")
				try 
					call mkdir( s:Latex_LocalTemplateDir, "p" )
				catch /.*/
				endtry
			endif
		endif

		if isdirectory( s:Latex_LocalTemplateDir ) && !filereadable( s:Latex_LocalTemplateFile )
			" write a default local template file
			let template	= [	]
			let sample_template_file	= fnamemodify( s:Latex_GlobalTemplateDir, ':h' ).'/rc/sample_template_file'
			if filereadable( sample_template_file )
				for line in readfile( sample_template_file )
					call add( template, line )
				endfor
				call writefile( template, s:Latex_LocalTemplateFile )
			endif
		endif
		"
		if filereadable( s:Latex_LocalTemplateFile )
			call mmtemplates#core#ReadTemplates ( g:Latex_Templates, 'load', s:Latex_LocalTemplateFile )
			let messsage	= messsage." and '".s:Latex_LocalTemplateFile."'"
			if mmtemplates#core#ExpandText( g:Latex_Templates, '|AUTHOR|' ) == 'YOUR NAME'
				echomsg "Please set your personal details in file '".s:Latex_LocalTemplateFile."'."
			endif
		endif
		"
	else
		"-------------------------------------------------------------------------------
		" LOCAL INSTALLATION
		"-------------------------------------------------------------------------------
		if filereadable( s:Latex_LocalTemplateFile )
			call mmtemplates#core#ReadTemplates ( g:Latex_Templates, 'load', s:Latex_LocalTemplateFile )
			let	messsage	= "Templates read from '".s:Latex_LocalTemplateFile."'"
		else
			echomsg "Local template file '".s:Latex_LocalTemplateFile."' not readable." 
			return
		endif
		"
	endif
	if a:displaymsg == 'yes'
		echomsg messsage.'.'
	endif

endfunction    " ----------  end of function Latex_RereadTemplates  ----------
"
"===  FUNCTION  ================================================================
"          NAME:  InitMenus     {{{1
"   DESCRIPTION:  Initialize menus.
"    PARAMETERS:  -
"       RETURNS:  
"===============================================================================
function! s:InitMenus()
	"
	" TODO: mapleader configurable
	"
	if ! has ( 'menu' )
		return
	endif
	"
	" Preparation
	call mmtemplates#core#CreateMenus ( 'g:Latex_Templates', s:Latex_RootMenu, 'do_reset' )
	"
	exe 'amenu '.s:Latex_RootMenu.'.LaTe&X  <Nop>'
	exe 'amenu '.s:Latex_RootMenu.'.-Sep00- <Nop>'
	"
	"-------------------------------------------------------------------------------
	" Comments
	"-------------------------------------------------------------------------------
	call mmtemplates#core#CreateMenus ( 'g:Latex_Templates', s:Latex_RootMenu, 'sub_menu', '&Comments' )
	"
	let  head =  'noremenu <silent> '.s:Latex_RootMenu.'.Comments.'
	let ahead = 'anoremenu <silent> '.s:Latex_RootMenu.'.Comments.'
	let ihead = 'inoremenu <silent> '.s:Latex_RootMenu.'.Comments.'
	let vhead = 'vnoremenu <silent> '.s:Latex_RootMenu.'.Comments.'
	"
 	exe ahead.'end-of-&line\ comment<Tab>cl                    :call Latex_EndOfLineComment()<CR>'
 	exe vhead.'end-of-&line\ comment<Tab>cl                    :call Latex_EndOfLineComment()<CR>'

	exe ahead.'ad&just\ end-of-line\ com\.<Tab>cj              :call Latex_AdjustLineEndComm()<CR>'
	exe ihead.'ad&just\ end-of-line\ com\.<Tab>cj         <Esc>:call Latex_AdjustLineEndComm()<CR>'
	exe vhead.'ad&just\ end-of-line\ com\.<Tab>cj              :call Latex_AdjustLineEndComm()<CR>'
	exe  head.'&set\ end-of-line\ com\.\ col\.<Tab>cs     <Esc>:call Latex_GetLineEndCommCol()<CR>'
	"
	exe ahead.'&comment<TAB>cc		:call Latex_CodeComment()<CR>'
	exe vhead.'&comment<TAB>cc		:call Latex_CodeComment()<CR>'
	exe ahead.'&uncomment<TAB>cu	:call Latex_CommentCode(0)<CR>'
	exe vhead.'&uncomment<TAB>cu	:call Latex_CommentCode(0)<CR>'
	exe ahead.'-Sep02-												             <Nop>'
	"
	"-------------------------------------------------------------------------------
	" generate menues from the templates
	"-------------------------------------------------------------------------------
	call mmtemplates#core#CreateMenus ( 'g:Latex_Templates', s:Latex_RootMenu, 'do_templates' )
	"
	"-------------------------------------------------------------------------------
	" snippets
	"-------------------------------------------------------------------------------
	let ahead = 'anoremenu <silent> '.s:Latex_RootMenu.'.S&nippets.'
	let ihead = 'inoremenu <silent> '.s:Latex_RootMenu.'.S&nippets.'
	let vhead = 'vnoremenu <silent> '.s:Latex_RootMenu.'.S&nippets.'
	"
	call mmtemplates#core#CreateMenus ( 'g:Latex_Templates', s:Latex_RootMenu, 'sub_menu', 'S&nippets' )
	exe ahead.'&read\ code\ snippet<Tab>\\nr       :call Latex_CodeSnippet("read")<CR>'
	exe ihead.'&read\ code\ snippet<Tab>\\nr  <C-C>:call Latex_CodeSnippet("read")<CR>'
	exe ahead.'&view\ code\ snippet<Tab>\\nv       :call Latex_CodeSnippet("view")<CR>'
	exe ihead.'&view\ code\ snippet<Tab>\\nv  <C-C>:call Latex_CodeSnippet("view")<CR>'
	exe ahead.'&write\ code\ snippet<Tab>\\nw      :call Latex_CodeSnippet("write")<CR>'
	exe ihead.'&write\ code\ snippet<Tab>\\nw <C-C>:call Latex_CodeSnippet("write")<CR>'
	exe vhead.'&write\ code\ snippet<Tab>\\nw <C-C>:call Latex_CodeSnippet("writemarked")<CR>'
	exe ahead.'&edit\ code\ snippet<Tab>\\ne       :call Latex_CodeSnippet("edit")<CR>'
	exe ihead.'&edit\ code\ snippet<Tab>\\ne  <C-C>:call Latex_CodeSnippet("edit")<CR>'
	exe ahead.'-SepSnippets-                       :'
	"
	exe ahead.'edit\ &local\ templates<Tab>\\ntl       :call mmtemplates#core#EditTemplateFiles(g:Latex_Templates,-1)<CR>'
	exe ihead.'edit\ &local\ templates<Tab>\\ntl  <C-C>:call mmtemplates#core#EditTemplateFiles(g:Latex_Templates,-1)<CR>'
	if s:installation == 'system'
		exe ahead.'edit\ &local\ templates<Tab>\\ntg       :call mmtemplates#core#EditTemplateFiles(g:Latex_Templates,1)<CR>'
		exe ihead.'edit\ &local\ templates<Tab>\\ntg  <C-C>:call mmtemplates#core#EditTemplateFiles(g:Latex_Templates,1)<CR>'
	endif
	"
	exe ahead.'reread\ &templates<Tab>\\ntr       :call mmtemplates#core#ReadTemplates(g:Latex_Templates,"reload","all")<CR>'
	exe ihead.'reread\ &templates<Tab>\\ntr  <C-C>:call mmtemplates#core#ReadTemplates(g:Latex_Templates,"reload","all")<CR>'
	"
	"-------------------------------------------------------------------------------
	" wizard
	"-------------------------------------------------------------------------------
	" 
	call mmtemplates#core#CreateMenus ( 'g:Latex_Templates', s:Latex_RootMenu, 'sub_menu', '&Wizard' )
	"
	let ahead = 'anoremenu <silent> '.s:Latex_RootMenu.'.&Wizard.'
	let ihead = 'inoremenu <silent> '.s:Latex_RootMenu.'.&Wizard.'
	let vhead = 'vnoremenu <silent> '.s:Latex_RootMenu.'.&Wizard.'
	"
 	exe ahead.'tables.tabbing<Tab>\\wtg                     :call Latex_Tabbing()<CR>k0a'
 	exe ihead.'tables.tabbing<Tab>\\wtg                <C-C>:call Latex_Tabbing()<CR>k0a'
 	exe ahead.'tables.tabular<Tab>\\wtr                     :call Latex_Tabular()<CR>3k0a'
 	exe ihead.'tables.tabular<Tab>\\wtr                <C-C>:call Latex_Tabular()<CR>3k0a'
	"
	exe ahead.'li&gatures.find\ double       <C-C>:/f[filt]<CR>'
	exe ahead.'li&gatures.find\ triple       <C-C>:/ff[filt]<CR>'
	exe ahead.'li&gatures.split\ with\ \\\/  <C-C>a\/<Esc>'
	exe ahead.'li&gatures.highlight\ off     <C-C>:nohlsearch<CR>'
	"
	call mmtemplates#core#CreateMenus ( 'g:Latex_Templates', s:Latex_RootMenu, 'do_styles', 
				\ 'specials_menu', 'Snippets'	)
	"
	"-------------------------------------------------------------------------------
	" run
	"-------------------------------------------------------------------------------
	" 
	call mmtemplates#core#CreateMenus ( 'g:Latex_Templates', s:Latex_RootMenu, 'sub_menu', '&Run' )
	"
	let ahead = 'amenu <silent> '.s:Latex_RootMenu.'.&Run.'
	let ihead = 'imenu <silent> '.s:Latex_RootMenu.'.&Run.'
	let vhead = 'vmenu <silent> '.s:Latex_RootMenu.'.&Run.'
	"
 	exe ahead.'save\ +\ &run\ typesetter<Tab>\\rr\ <C-F9>       :call Latex_Compile()<CR><CR>'
	exe ihead.'save\ +\ &run\ typesetter<Tab>\\rr\ <C-F9>  <C-C>:call Latex_Compile()<CR><CR>'
	"
 	exe ahead.'save\ +\ &run\ lacheck<Tab>\\rla       :call Latex_Lacheck()<CR><CR>'
	exe ihead.'save\ +\ &run\ lacheck<Tab>\\rla  <C-C>:call Latex_Lacheck()<CR><CR>'
	"
 	exe ahead.'view\ +\ &DVI<Tab>\\rdvi       :call Latex_View("dvi")<CR>'
	exe ihead.'view\ +\ &DVI<Tab>\\rdvi  <C-C>:call Latex_View("dvi")<CR>'
 	exe ahead.'view\ +\ &PDF<Tab>\\rpdf       :call Latex_View("pdf")<CR>'
	exe ihead.'view\ +\ &PDF<Tab>\\rpdf  <C-C>:call Latex_View("pdf")<CR>'
 	exe ahead.'view\ +\ &PS<Tab>\\rps         :call Latex_View("ps" )<CR>'
	exe ihead.'view\ +\ &PS<Tab>\\rps    <C-C>:call Latex_View("ps" )<CR>'
	"
	exe ahead.'-SEP0-                            :'
	exe ahead.'&make<Tab>\\rm                                    :call Latex_Make()<CR>'
	exe ihead.'&make<Tab>\\rm                               <C-C>:call Latex_Make()<CR>'
	exe ahead.'&choose\ makefile<Tab>\\rcm                       :call Latex_ChooseMakefile()<CR>'
	exe ihead.'&choose\ makefile<Tab>\\rcm                  <C-C>:call Latex_ChooseMakefile()<CR>'
	exe ahead.'&make\ clean<Tab>\\rmc                            :call Latex_MakeClean()<CR>'
	exe ihead.'&make\ clean<Tab>\\rmc                       <C-C>:call Latex_MakeClean()<CR>'
	exe 'amenu '.s:Latex_RootMenu.'.&Run.cmd\.\ line\ ar&g\.\ for\ make<Tab>\\rma          :LatexMakeCmdlineArgs<Space>'
	exe 'imenu '.s:Latex_RootMenu.'.&Run.cmd\.\ line\ ar&g\.\ for\ make<Tab>\\rma     <C-C>:LatexMakeCmdlineArgs<Space>'
  "
	exe ahead.'-SEP1-                            :'
	exe ahead.'run\ make&index<Tab>\\rmi                       :call Latex_Makeindex()<CR>'
	exe ihead.'run\ make&index<Tab>\\rmi                  <C-C>:call Latex_Makeindex()<CR>'
	exe ahead.'run\ &bibtex<Tab>\\rbi                          :call Latex_RunBibtex()<CR>'
	exe ihead.'run\ &bibtex<Tab>\\rbi                     <C-C>:call Latex_RunBibtex()<CR>'
	exe ahead.'-SEP2-                            :'

	exe ahead.'Convert.DVI->PDF<Tab>                     :call Latex_Conversions( "dvi-pdf", "no" )<CR>'
	exe ahead.'Convert.DVI->PS<Tab>                      :call Latex_Conversions( "dvi-ps" , "no" )<CR>'
	exe ahead.'Convert.DVI->PNG<Tab>                     :call Latex_Conversions( "dvi-png", "no" )<CR>'
	exe ahead.'Convert.PDF->PNG<Tab>                     :call Latex_Conversions( "pdf-png", "yes" )<CR>'
	exe ahead.'Convert.PS->PDF<Tab>                      :call Latex_Conversions( "ps-pdf" , "no" )<CR>'

	exe ahead.'-SEP3-                            :'
	exe ahead.'plugin\ &settings<Tab>rse                 :call Latex_Settings()<CR>'
	"
	"-------------------------------------------------------------------------------
	" help
	"-------------------------------------------------------------------------------
	"
	exe " menu  <silent>  ".s:Latex_RootMenu.'.Help.&texdoc<Tab>\\ht        :call Latex_texdoc()<CR>'
	exe "imenu  <silent>  ".s:Latex_RootMenu.'.Help.&texdoc<Tab>\\ht   <C-C>:call Latex_texdoc()<CR>'
	exe " menu  <silent>  ".s:Latex_RootMenu.'.Help.-SEP2-                  :'
	exe " menu  <silent>  ".s:Latex_RootMenu.'.Help.&help\ (Latex-Support)<Tab>\\hp        :call Latex_HelpLatexSupport()<CR>'
	exe "imenu  <silent>  ".s:Latex_RootMenu.'.Help.&help\ (Latex-Support)<Tab>\\hp   <C-C>:call Latex_HelpLatexSupport()<CR>'

endfunction    " ----------  end of function s:InitMenus  ----------
"
"===  FUNCTION  ================================================================
"          NAME:  Latex_AddMenus     {{{1
"   DESCRIPTION:  Add menus.
"    PARAMETERS:  -
"       RETURNS:  
"===============================================================================
function! g:Latex_AddMenus()
	" initialize if not existing
	if s:Latex_MenuVisible == 'no'
		call s:InitMenus ()
	endif
	" the menu is now visible
	let s:Latex_MenuVisible = 'yes'
endfunction    " ----------  end of function g:Latex_AddMenus  ----------
"
"===  FUNCTION  ================================================================
"          NAME:  Latex_RemoveMenus     {{{1
"   DESCRIPTION:  Remove menus.
"    PARAMETERS:  -
"       RETURNS:  
"===============================================================================
function! g:Latex_RemoveMenus()
	" destroy if visible
	if s:Latex_MenuVisible == 'yes' && has ( 'menu' )
		aunmenu <silent> latex
	endif
	" the menu is now invisible
	let s:Latex_MenuVisible = 'no'
endfunction    " ----------  end of function g:Latex_RemoveMenus  ----------

"===  FUNCTION  ================================================================
"          NAME:  Latex_JumpForward     {{{1
"   DESCRIPTION:  Jump to the next target, otherwise behind the current string.
"    PARAMETERS:  -
"       RETURNS:  empty string
"===============================================================================
function! Latex_JumpForward ()
  let match	= search( s:Latex_TemplateJumpTarget, 'c' )
	if match > 0
		" remove the target
		call setline( match, substitute( getline('.'), s:Latex_TemplateJumpTarget, '', '' ) )
	else
		" try to jump behind parenthesis or strings
		call search( "[\]})\"'`]", 'W' )
		normal l
	endif
	return ''
endfunction    " ----------  end of function Latex_JumpForward  ----------
"
"===  FUNCTION  ================================================================
"          NAME:  Latex_CodeSnippet     {{{1
"   DESCRIPTION:  read / write / edit code sni
"    PARAMETERS:  mode - edit, read, write, writemarked, view
"===============================================================================
function! Latex_CodeSnippet(mode)
  if isdirectory(g:Latex_CodeSnippets)
    "
    " read snippet file, put content below current line
    "
    if a:mode == "read"
			if has("gui_running") && s:Latex_GuiSnippetBrowser == 'gui'
				let l:snippetfile=browse(0,"read a code snippet",g:Latex_CodeSnippets,"")
			else
				let	l:snippetfile=input("read snippet ", g:Latex_CodeSnippets, "file" )
			endif
      if filereadable(l:snippetfile)
        let linesread= line("$")
        let l:old_cpoptions = &cpoptions " Prevent the alternate buffer from being set to this files
        setlocal cpoptions-=a
        :execute "read ".l:snippetfile
        let &cpoptions  = l:old_cpoptions   " restore previous options
        "
        let linesread= line("$")-linesread-1
        if linesread>=0 && match( l:snippetfile, '\.\(ni\|noindent\)$' ) < 0
          silent exe "normal =".linesread."+"
        endif
      endif
    endif
    "
    " update current buffer / split window / edit snippet file
    "
    if a:mode == "edit"
			if has("gui_running") && s:Latex_GuiSnippetBrowser == 'gui'
				let l:snippetfile=browse(0,"edit a code snippet",g:Latex_CodeSnippets,"")
			else
				let	l:snippetfile=input("edit snippet ", g:Latex_CodeSnippets, "file" )
			endif
      if !empty(l:snippetfile)
        :execute "update! | split | edit ".l:snippetfile
      endif
    endif
    "
    " update current buffer / split window / view snippet file
    "
    if a:mode == "view"
			if has("gui_running") && s:Latex_GuiSnippetBrowser == 'gui'
				let l:snippetfile=browse(0,"view a code snippet",g:Latex_CodeSnippets,"")
			else
				let	l:snippetfile=input("view snippet ", g:Latex_CodeSnippets, "file" )
			endif
      if !empty(l:snippetfile)
        :execute "update! | split | view ".l:snippetfile
      endif
    endif
    "
    " write whole buffer or marked area into snippet file
    "
    if a:mode == "write" || a:mode == "writemarked"
			if has("gui_running") && s:Latex_GuiSnippetBrowser == 'gui'
				let l:snippetfile=browse(0,"write a code snippet",g:Latex_CodeSnippets,"")
			else
				let	l:snippetfile=input("write snippet ", g:Latex_CodeSnippets, "file" )
			endif
      if !empty(l:snippetfile)
        if filereadable(l:snippetfile)
          if confirm("File ".l:snippetfile." exists ! Overwrite ? ", "&Cancel\n&No\n&Yes") != 3
            return
          endif
        endif
				if a:mode == "write"
					:execute ":write! ".l:snippetfile
				else
					:execute ":*write! ".l:snippetfile
				endif
      endif
    endif

  else
    redraw!
    echohl ErrorMsg
    echo "code snippet directory ".g:Latex_CodeSnippets." does not exist"
    echohl None
  endif
endfunction   " ---------- end of function  Latex_CodeSnippet  ----------
"
"===  FUNCTION  ================================================================
"          NAME:  CreateAdditionalMaps     {{{1
"   DESCRIPTION:  create additional maps
"    PARAMETERS:  -
"       RETURNS:  
"===============================================================================
function! s:CreateAdditionalMaps ()
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
	" USER DEFINED COMMANDS
	"-------------------------------------------------------------------------------
	"
  command! -nargs=* -complete=file LatexMakeCmdlineArgs call Latex_MakeArguments(<q-args>)
	"
	" setup maplocalleader
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
	nnoremap    <buffer>  <silent>  <LocalLeader>cl         :call Latex_EndOfLineComment()<CR>
	inoremap    <buffer>  <silent>  <LocalLeader>cl    <C-C>:call Latex_EndOfLineComment()<CR>
	vnoremap    <buffer>  <silent>  <LocalLeader>cl         :call Latex_EndOfLineComment()<CR>
	"
	nnoremap    <buffer>  <silent>  <LocalLeader>cj         :call Latex_AdjustLineEndComm()<CR>
	inoremap    <buffer>  <silent>  <LocalLeader>cj    <C-C>:call Latex_AdjustLineEndComm()<CR>
	vnoremap    <buffer>  <silent>  <LocalLeader>cj         :call Latex_AdjustLineEndComm()<CR>
	"
	nnoremap    <buffer>  <silent>  <LocalLeader>cs         :call Latex_GetLineEndCommCol()<CR>
	inoremap    <buffer>  <silent>  <LocalLeader>cs    <C-C>:call Latex_GetLineEndCommCol()<CR>
	vnoremap    <buffer>  <silent>  <LocalLeader>cs    <C-C>:call Latex_GetLineEndCommCol()<CR>
	"
	nnoremap    <buffer>  <silent>  <LocalLeader>cc         :call Latex_CodeComment()<CR>
	inoremap    <buffer>  <silent>  <LocalLeader>cc    <C-C>:call Latex_CodeComment()<CR>
	vnoremap    <buffer>  <silent>  <LocalLeader>cc         :call Latex_CodeComment()<CR>
	"
	nnoremap    <buffer>  <silent>  <LocalLeader>cu         :call Latex_CommentCode(0)<CR>
	inoremap    <buffer>  <silent>  <LocalLeader>cu    <C-C>:call Latex_CommentCode(0)<CR>
	vnoremap    <buffer>  <silent>  <LocalLeader>cu         :call Latex_CommentCode(0)<CR>
	"
	"-------------------------------------------------------------------------------
	" snippets
	"-------------------------------------------------------------------------------
	"
	nnoremap  <buffer>  <silent>  <LocalLeader>nr         :call Latex_CodeSnippet("read")<CR>
	inoremap  <buffer>  <silent>  <LocalLeader>nr    <Esc>:call Latex_CodeSnippet("read")<CR>
	nnoremap  <buffer>  <silent>  <LocalLeader>nw         :call Latex_CodeSnippet("write")<CR>
	inoremap  <buffer>  <silent>  <LocalLeader>nw    <Esc>:call Latex_CodeSnippet("write")<CR>
	vnoremap  <buffer>  <silent>  <LocalLeader>nw    <Esc>:call Latex_CodeSnippet("writemarked")<CR>
	nnoremap  <buffer>  <silent>  <LocalLeader>ne         :call Latex_CodeSnippet("edit")<CR>
	inoremap  <buffer>  <silent>  <LocalLeader>ne    <Esc>:call Latex_CodeSnippet("edit")<CR>
	nnoremap  <buffer>  <silent>  <LocalLeader>nv         :call Latex_CodeSnippet("view")<CR>
	inoremap  <buffer>  <silent>  <LocalLeader>nv    <Esc>:call Latex_CodeSnippet("view")<CR>
	"
	" ---------- snippet menu : templates ----------------------------------------
	"
	nnoremap    <buffer>  <silent> <LocalLeader>ntl       :call mmtemplates#core#EditTemplateFiles(g:Latex_Templates,-1)<CR>
	inoremap    <buffer>  <silent> <LocalLeader>ntl  <C-C>:call mmtemplates#core#EditTemplateFiles(g:Latex_Templates,-1)<CR>
	if s:installation == 'system'
		nnoremap  <buffer>  <silent> <LocalLeader>ntg       :call mmtemplates#core#EditTemplateFiles(g:Latex_Templates,1)<CR>
		inoremap  <buffer>  <silent> <LocalLeader>ntg  <C-C>:call mmtemplates#core#EditTemplateFiles(g:Latex_Templates,1)<CR>
	endif
	nnoremap    <buffer>  <silent> <LocalLeader>ntr       :call mmtemplates#core#ReadTemplates(g:Latex_Templates,"reload","all")<CR>
	inoremap    <buffer>  <silent> <LocalLeader>ntr  <C-C>:call mmtemplates#core#ReadTemplates(g:Latex_Templates,"reload","all")<CR>
	nnoremap    <buffer>  <silent> <LocalLeader>nts       :call mmtemplates#core#ChooseStyle(g:Latex_Templates,"!pick")<CR>
	inoremap    <buffer>  <silent> <LocalLeader>nts  <C-C>:call mmtemplates#core#ChooseStyle(g:Latex_Templates,"!pick")<CR>
	"
	"-------------------------------------------------------------------------------
	"  wizard
	"-------------------------------------------------------------------------------
	"
 	nnoremap    <buffer>  <silent> <LocalLeader>wtg       :call Latex_Tabbing()<CR>k0a'
 	inoremap    <buffer>  <silent> <LocalLeader>wtg  <C-C>:call Latex_Tabbing()<CR>k0a'
 	nnoremap    <buffer>  <silent> <LocalLeader>wtr       :call Latex_Tabular()<CR>3k0a'
 	inoremap    <buffer>  <silent> <LocalLeader>wtr  <C-C>:call Latex_Tabular()<CR>3k0a'
	"
	"-------------------------------------------------------------------------------
	"   run
	"-------------------------------------------------------------------------------
	"
   noremap  <buffer>            <C-F9>                  :call Latex_Compile()<CR><CR>
  inoremap  <buffer>            <C-F9>             <Esc>:call Latex_Compile()<CR><CR>
   noremap  <buffer>  <silent>  <LocalLeader>rr         :call Latex_Compile()<CR><CR>
  inoremap  <buffer>  <silent>  <LocalLeader>rr    <C-C>:call Latex_Compile()<CR><CR>
   noremap  <buffer>  <silent>  <LocalLeader>rla        :call Latex_Lacheck()<CR>
  inoremap  <buffer>  <silent>  <LocalLeader>rla   <C-C>:call Latex_Lacheck()<CR>

  inoremap  <buffer>  <silent>  <LocalLeader>rr    <C-C>:call Latex_Compile()<CR><CR>
   noremap  <buffer>  <silent>  <LocalLeader>rdvi       :call Latex_View("dvi")<CR>
  inoremap  <buffer>  <silent>  <LocalLeader>rdvi  <C-C>:call Latex_View("dvi")<CR>
   noremap  <buffer>  <silent>  <LocalLeader>rpdf       :call Latex_View("pdf")<CR>
  inoremap  <buffer>  <silent>  <LocalLeader>rpdf  <C-C>:call Latex_View("pdf")<CR>
   noremap  <buffer>  <silent>  <LocalLeader>rps        :call Latex_View("ps" )<CR>
  inoremap  <buffer>  <silent>  <LocalLeader>rps   <C-C>:call Latex_View("ps" )<CR>
	"
   noremap  <buffer>  <silent>  <LocalLeader>rm         :call Latex_Make()<CR>
  inoremap  <buffer>  <silent>  <LocalLeader>rm    <C-C>:call Latex_Make()<CR>
   noremap  <buffer>  <silent>  <LocalLeader>rcm        :call Latex_ChooseMakefile()<CR>
  inoremap  <buffer>  <silent>  <LocalLeader>rcm   <C-C>:call Latex_ChooseMakefile()<CR>
   noremap  <buffer>  <silent>  <LocalLeader>rmc        :call Latex_MakeClean()<CR>
  inoremap  <buffer>  <silent>  <LocalLeader>rmc   <C-C>:call Latex_MakeClean()<CR>
	 noremap  <buffer>            <LocalLeader>rma        :LatexMakeCmdlineArgs<Space>
	inoremap  <buffer>            <LocalLeader>rma   <C-C>:LatexMakeCmdlineArgs<Space>
	"
   noremap  <buffer>  <silent>  <LocalLeader>rmi        :call Latex_Makeindex()<CR>
  inoremap  <buffer>  <silent>  <LocalLeader>rmi   <C-C>:call Latex_Makeindex()<CR>
   noremap  <buffer>  <silent>  <LocalLeader>rbi        :call Latex_RunBibtex()<CR>
  inoremap  <buffer>  <silent>  <LocalLeader>rbi   <C-C>:call Latex_RunBibtex()<CR>
	"
	"-------------------------------------------------------------------------------
	"   help
	"-------------------------------------------------------------------------------
	nnoremap  <buffer>  <silent>  <LocalLeader>rse         :call Latex_Settings()<CR>
  "
	 noremap  <buffer>  <silent>  <LocalLeader>hp         :call Latex_HelpLatexSupport()<CR>
	inoremap  <buffer>  <silent>  <LocalLeader>hp    <C-C>:call Latex_HelpLatexSupport()<CR>
  "
	 noremap  <buffer>  <silent>  <LocalLeader>ht         :call Latex_texdoc()<CR>
	inoremap  <buffer>  <silent>  <LocalLeader>ht    <C-C>:call Latex_texdoc()<CR>
	"
	nmap    <buffer>  <silent>  <C-j>    i<C-R>=Latex_JumpForward()<CR>
	imap    <buffer>  <silent>  <C-j>     <C-R>=Latex_JumpForward()<CR>
	"
	if ! empty ( g:Latex_MapLeader )
		if exists ( 'll_save' )
			let g:maplocalleader = ll_save
		else
			unlet g:maplocalleader
		endif
	endif
	"
endfunction    " ----------  end of function s:CreateAdditionalMaps  ----------
"
"------------------------------------------------------------------------------
"  Latex_HelpLatexSupport : help latexsupport     {{{1
"------------------------------------------------------------------------------
function! Latex_HelpLatexSupport ()
	try
		:help latexsupport
	catch
		exe ':helptags '.s:plugin_dir.'/doc'
		:help latexsupport
	endtry
endfunction    " ----------  end of function Latex_HelpLatexSupport ----------
"
"===  FUNCTION  ================================================================
"          NAME:  Latex_Settings     {{{1
"   DESCRIPTION:  Display plugin settings
"    PARAMETERS:  -
"       RETURNS:  
"===============================================================================
function! Latex_Settings ()
	let	txt =     " latex-Support settings\n\n"
	let txt = txt.'                   author :  "'.mmtemplates#core#ExpandText( g:Latex_Templates, '|AUTHOR|'      )."\"\n"
	let txt = txt.'                authorref :  "'.mmtemplates#core#ExpandText( g:Latex_Templates, '|AUTHORREF|'   )."\"\n"
	let txt = txt.'                  company :  "'.mmtemplates#core#ExpandText( g:Latex_Templates, '|COMPANY|'     )."\"\n"
	let txt = txt.'         copyright holder :  "'.mmtemplates#core#ExpandText( g:Latex_Templates, '|COPYRIGHT|'   )."\"\n"
	let txt = txt.'                    email :  "'.mmtemplates#core#ExpandText( g:Latex_Templates, '|EMAIL|'       )."\"\n"
  let txt = txt.'                  licence :  "'.mmtemplates#core#ExpandText( g:Latex_Templates, '|LICENSE|'     )."\"\n"
	let txt = txt.'             organization :  "'.mmtemplates#core#ExpandText( g:Latex_Templates, '|ORGANIZATION|')."\"\n"
	let txt = txt.'                  project :  "'.mmtemplates#core#ExpandText( g:Latex_Templates, '|PROJECT|'     )."\"\n"
	let txt = txt.'               typesetter :  '.s:Latex_TypesetterCall[s:Latex_Typesetter]."\n"
	let txt = txt.'      plugin installation :  "'.s:installation."\"\n"
 	let txt = txt.'   code snippet directory :  "'.s:Latex_CodeSnippets."\"\n"
	if s:installation == 'system'
		let txt = txt.'global template directory :  '.s:Latex_GlobalTemplateDir."\n"
		if filereadable( s:Latex_LocalTemplateFile )
			let txt = txt.' local template directory :  '.s:Latex_LocalTemplateDir."\n"
		endif
	else
		let txt = txt.' local template directory :  '.s:Latex_LocalTemplateDir."\n"
	endif
	" ----- dictionaries ------------------------
  if !empty(g:Latex_Dictionary_File)
		let ausgabe= &dictionary
		let ausgabe= substitute( ausgabe, ",", ",\n                            + ", "g" )
		let txt = txt."        dictionary file(s) :  ".ausgabe."\n"
	endif
	let txt = txt."\n"
	let	txt = txt."__________________________________________________________________________\n"
	let	txt = txt." latex-Support, Version ".g:LatexSupportVersion." / Dr.-Ing. Fritz Mehner / mehner@fh-swf.de\n\n"
	echo txt
endfunction    " ----------  end of function Latex_Settings ----------
"
"------------------------------------------------------------------------------
"  Latex_CreateMenusDelayed     {{{1
"------------------------------------------------------------------------------
function! Latex_CreateMenusDelayed ()
	if s:Latex_CreateMenusDelayed == 'yes' && s:Latex_MenuVisible == 'no'
		call Latex_CreateGuiMenus()
	endif
endfunction    " ----------  end of function Latex_CreateMenusDelayed  ----------
"
"------------------------------------------------------------------------------
"  Latex_CreateGuiMenus     {{{1
"------------------------------------------------------------------------------
function! Latex_CreateGuiMenus ()
  if s:Latex_MenuVisible != 'yes'
		aunmenu <silent> &Tools.Load\ Latex\ Support
    amenu   <silent> 40.1000 &Tools.-SEP100- :
    amenu   <silent> 40.1170 &Tools.Unload\ Latex\ Support :call Latex_RemoveGuiMenus()<CR>
		call g:Latex_RereadTemplates('no')
		call s:InitMenus () 
    let s:Latex_MenuVisible = 'yes'
  endif
endfunction    " ----------  end of function Latex_CreateGuiMenus  ----------
"
"------------------------------------------------------------------------------
"  Latex_ToolMenu     {{{1
"------------------------------------------------------------------------------
function! Latex_ToolMenu ()
    amenu   <silent> 40.1000 &Tools.-SEP100- :
    amenu   <silent> 40.1170 &Tools.Load\ Latex\ Support :call Latex_CreateGuiMenus()<CR>
endfunction    " ----------  end of function Latex_ToolMenu  ----------

"------------------------------------------------------------------------------
"  Latex_RemoveGuiMenus     {{{1
"------------------------------------------------------------------------------
function! Latex_RemoveGuiMenus ()
  if s:Latex_MenuVisible == 'yes'
		exe "aunmenu <silent> ".s:Latex_RootMenu
    "
    aunmenu <silent> &Tools.Unload\ Latex\ Support
		call Latex_ToolMenu()
    "
    let s:Latex_MenuVisible = 'no'
  endif
endfunction    " ----------  end of function Latex_RemoveGuiMenus  ----------
"
"------------------------------------------------------------------------------
"  Latex_SaveOption    {{{1
"  param 1 : option name
"  param 2 : characters to be escaped (optional)
"------------------------------------------------------------------------------
function! Latex_SaveOption ( option, ... )
	exe 'let escaped =&'.a:option
	if a:0 == 0
		let escaped	= escape( escaped, ' |"\' )
	else
		let escaped	= escape( escaped, ' |"\'.a:1 )
	endif
	let s:Latex_saved_option[a:option]	= escaped
endfunction    " ----------  end of function Latex_SaveOption  ----------
"
let s:Latex_saved_option					= {}
"
"------------------------------------------------------------------------------
"  Latex_RestoreOption    {{{1
"------------------------------------------------------------------------------
function! Latex_RestoreOption ( option )
	exe ':setlocal '.a:option.'='.s:Latex_saved_option[a:option]
endfunction    " ----------  end of function Latex_RestoreOption  ----------
"
"------------------------------------------------------------------------------
"  Run : compile buffer			{{{1
"------------------------------------------------------------------------------
function! Latex_Compile ()
	if &filetype != 'tex'
		echomsg	'The filetype of this buffer is not "tex".'
		return
	endif

	let	typesettercall	= s:Latex_TypesetterCall[s:Latex_Typesetter]
	let	typesetter			= split( s:Latex_TypesetterCall[s:Latex_Typesetter] )[0]
	if !executable( typesetter )
		echomsg 'Typesetter "'.typesetter.'" does not exist or its name is not unique.'
		return
	endif

	let	l:currentbuffer	= bufname("%")
	exe	":cclose"
	let	Sou		= expand("%")											" name of the file in the current buffer
	let SouEsc= escape( Sou, s:escfilename )

	exe	":update"

	setlocal errorformat=%f:%l:\ %m
	exe		":setlocal makeprg=".escape( typesettercall, s:escfilename )
	" 
	exe		"make ".SouEsc
	exe		"set makeprg=make"
	"
	" open error window if necessary 
	exe	":botright cwindow"
	
endfunction    " ----------  end of function Latex_Compile ----------
"
"------------------------------------------------------------------------------
"  view PDF 
"------------------------------------------------------------------------------
function! Latex_View ( format )
	if &filetype != 'tex'
		echomsg	'The filetype of this buffer is not "tex".'
		return
	endif
	let	viewer	= s:Latex_Viewer[a:format]
	if !executable( split(viewer)[0] )
		echomsg 'Viewer "'.viewer.'" does not exist or its name is not unique.'
		return
	endif
  let file   = expand("%:r").'.'.a:format
	if !filereadable( file )
		echomsg 'File "'.file.'" does not exist or is not readable.'
	endif
  silent exe   '!'.viewer.' '.file.' &'
endfunction    " ----------  end of function Latex_View ----------
"
"------------------------------------------------------------------------------
"  run make(1)       {{{1
"------------------------------------------------------------------------------
let s:Latex_Makefile				= ''
let s:Latex_MakeCmdLineArgs = ''   " command line arguments for Run-make; initially empty
"
"------------------------------------------------------------------------------
"  Latex_ChooseMakefile : choose a makefile       {{{1
"------------------------------------------------------------------------------
function! Latex_ChooseMakefile ()
	let s:Latex_Makefile	= ''
	let mkfile	= findfile( "Makefile", ".;" )    " try to find a Makefile
	if mkfile == ''
    let mkfile  = findfile( "makefile", ".;" )  " try to find a makefile
	endif
	if mkfile == ''
		let mkfile	= getcwd()
	endif
	let	s:Latex_Makefile	= Latex_Input ( "choose a Makefile: ", mkfile, "file" )
	if  s:MSWIN
		let	s:Latex_Makefile	= substitute( s:Latex_Makefile, '\\ ', ' ', 'g' )
	endif
endfunction    " ----------  end of function Latex_ChooseMakefile  ----------
"
"------------------------------------------------------------------------------
"  Latex_Make : run make       {{{1
"------------------------------------------------------------------------------
function! Latex_Make()
	exe	":cclose"
	" update : write source file if necessary
	exe	":update"
	" run make
	if s:Latex_Makefile == ''
		exe	":make ".s:Latex_MakeCmdLineArgs
	else
		exe	':lchdir  '.fnamemodify( s:Latex_Makefile, ":p:h" )
		if  s:MSWIN
			exe	':make -f "'.s:Latex_Makefile.'" '.s:Latex_MakeCmdLineArgs
		else
			exe	':make -f '.s:Latex_Makefile.' '.s:Latex_MakeCmdLineArgs
		endif
		exe	":lchdir -"
	endif
	exe	":botright cwindow"
	"
endfunction    " ----------  end of function Latex_Make ----------
"
"------------------------------------------------------------------------------
"  Latex_MakeClean : run 'make clean'       {{{1
"------------------------------------------------------------------------------
function! Latex_MakeClean()
	" run make clean
	if s:Latex_Makefile == ''
		exe	":!make clean"
	else
		exe	':lchdir  '.fnamemodify( s:Latex_Makefile, ":p:h" )
		if  s:MSWIN
			exe	':!make -f "'.s:Latex_Makefile.'" clean'
		else
			exe	':!make -f '.s:Latex_Makefile.' clean'
		endif
		exe	":lchdir -"
	endif
endfunction    " ----------  end of function Latex_MakeClean ----------

"------------------------------------------------------------------------------
"  Latex_MakeArguments : get make command line arguments       {{{1
"------------------------------------------------------------------------------
function! Latex_MakeArguments ( ... )
	let	s:Latex_MakeCmdLineArgs	= join( a:000 )
endfunction    " ----------  end of function Latex_MakeArguments ----------
"
"----------------------------------------------------------------------
"  run lacheck
"----------------------------------------------------------------------
function! Latex_Lacheck ()
	if !executable("lacheck")
		echohl WarningMsg
		echo 'lacheck does not exist or is not executable!'
		echohl None
	endif
	if &filetype != 'tex'
		echomsg	'The filetype of this buffer is not "tex".'
		return
	endif
	let	l:currentbuffer	= bufname("%")
	exe	":cclose"
	let	Sou		= expand("%")											" name of the file in the current buffer
	let SouEsc= escape( Sou, s:escfilename )

	" update : write source file if necessary
	exe	":update"
	
	:setlocal errorformat="%f",\ line\ %l:%m
	
	:set makeprg=lacheck
	" 
	exe		"make ".SouEsc
	exe		"set makeprg=make"
	" 
	" open error window if necessary 
	exe	":botright cwindow"
	
endfunction    " ----------  end of function Latex_Lacheck ----------
"
"------------------------------------------------------------------------------
"  makeindex 
"------------------------------------------------------------------------------
function! Latex_Makeindex()
	if &filetype != 'tex'
		echomsg	'The filetype of this buffer is not "tex".'
		return
	endif
  let Idx   = expand("%:r").'.idx'
  if filereadable(Idx) 
    exe   '!makeindex '.Idx
		if v:shell_error 
			echohl WarningMsg
			echo 'makeindex reported errors !'
			echohl None
		endif
  endif
endfunction
"
"------------------------------------------------------------------------------
"  run bibtex
"------------------------------------------------------------------------------
function! Latex_RunBibtex ()
	if &filetype != 'tex'
		echomsg	'The filetype of this buffer is not "tex".'
		return
	endif

	let	l:currentbuffer	= bufname("%")
	exe	":cclose"
	let	Sou		= expand("%:r")											" name of the file in the current buffer
	let SouEsc= escape( Sou, s:escfilename )

	" update : write source file if necessary
	exe	":update"
	
	exe		"set makeprg=".s:Latex_Bibtex
	exe		"make ".SouEsc
	exe		"set makeprg=make"
	" 
	" open error window if necessary 
	exe	":botright cwindow"
	
endfunction    " ----------  end of function Latex_RunBibtex ----------
"
"------------------------------------------------------------------------------
"  Convert DVI
"------------------------------------------------------------------------------
function! Latex_Conversions ( format, target )
	if &filetype != 'tex'
		echomsg	'The filetype of this buffer is not "tex".'
		return
	endif

	let	convertercall	= s:Latex_ConverterCall[a:format]
	let	converter			= split( convertercall )[0]
	if !executable( converter )
		echomsg 'Converter "'.converter.'" does not exist or its name is not unique.'
		return
	endif

	let	l:currentbuffer	= bufname("%")
	exe	":cclose"
	let	Sou		= expand("%")											" name of the file in the current buffer
	let SouEsc= escape( Sou, s:escfilename )

  let source   = expand("%:r").'.'.split( a:format, '-' )[0]
  let logfile  = expand("%:r").'.conversion.log'
	let target   = ''
	if a:target == 'yes'
		let target   = expand("%:r").'.'.split( a:format, '-' )[1]
	endif
  silent exe '!'.s:Latex_ConverterCall[a:format].' '.source.' '.target.' > '.logfile
	if v:shell_error 
		echohl WarningMsg
		echo 'Conversion '.a:format.' reported errors. Please see file "'.logfile.'" !'
		echohl None
	else
		echo 'Conversion '.a:format.' done.'
	endif
endfunction    " ----------  end of function Latex_Conversions  ----------

"------------------------------------------------------------------------------
"  build new string from repetition of a given string
"  1. parameter : given string
"  2. parameter : repetition count
"  3. parameter : head (optional)
"  4. parameter : tail (optional)
"------------------------------------------------------------------------------
function! s:repeat_string ( string, n, ... )
	let result	= ''
	if a:0 >= 1
		let result	= a:1                           " start with the head
	endif
	for n in range( 1, a:n )
		let result	.= a:string
	endfor
	if a:0 == 2
		let result	.= a:2                          " append the tail
	endif
	return result
endfunction    " ----------  end of function repeat_string  ----------
"
"------------------------------------------------------------------------------
"  Wizard : tabbing
"------------------------------------------------------------------------------
function! Latex_Tabbing()
	let TextWidth   = 120                         " unit [mm]
	let RowInput    = '1'                         " default number of rows
	let ColInput    = '2'                         " default number of columns
	let param 			= Latex_Input("rows columns [width [mm]]: ", RowInput." ".ColInput )
	if param == ""
		return
	endif
	if match( param, '^\s*\d\+\(\s\+\d\+\)\{0,2}\s*$' ) < 0
		echomsg " Wrong input format."
		return
	endif

	let paramlist		= split( param )
	if len( paramlist ) >= 1
		let	RowInput	= paramlist[0]
	endif
	if len( paramlist ) >= 2
		let	ColInput	= paramlist[1]
	endif
	if len( paramlist ) >= 3
		let	TextWidth	= paramlist[2]
	endif

	let Rows  = str2nr(RowInput)
	let Rows  = max( [ Rows, 1 ] )              " at least 1 row
	let Cols  = str2nr(ColInput)
	let Cols  = max( [ Cols, 2 ] )              " at least 2 columns

	let zz		=  "\%\%----- TABBING : begin ----------\n\\begin{tabbing}\n"
	let colwidth		= TextWidth/Cols
	let colwidth		= max( [ colwidth, 10 ] )
	"
	" build head line
	let	zz	=	s:repeat_string( "\\hspace{".colwidth."mm} \\= ", Cols, zz, "\\kill\n" )
	"
	" build a single row
	let	row	=	s:repeat_string( " \\> ", Cols-1, " ", " \\\\\n" )
	"
	" generate all rows
	let zz	= s:repeat_string( row, Rows, zz )
	let zz	.= "\\end{tabbing}\n\%\%----- TABBING :  end  ----------\n"
	put =zz
	silent exe "normal ".Rows."k"
endfunction    " ----------  end of function Latex_Tabbing  ----------
"
"------------------------------------------------------------------------------
"  Wizard : tabular
"------------------------------------------------------------------------------
function! Latex_Tabular()
	let TextWidth   = 120   " [mm]
	let RowInput    = "2"
	let ColInput    = "2"
	let param 			= Latex_Input("rows columns [width [mm]]: ", RowInput." ".ColInput )
	if param == ""
		return
	endif
	if match( param, '^\s*\d\+\(\s\+\d\+\)\{0,2}\s*$' ) < 0
		echomsg " Wrong input format."
		return
	endif

	let paramlist		= split( param )
	if len( paramlist ) >= 1
		let	RowInput	= paramlist[0]
	endif
	if len( paramlist ) >= 2
		let	ColInput	= paramlist[1]
	endif
	if len( paramlist ) >= 3
		let	TextWidth	= paramlist[2]
	endif

	let Rows  		= str2nr(RowInput)
	let Rows  		= max( [ Rows, 1 ] )  " at least 1 row
	let Cols  		= str2nr(ColInput)
	let Cols  		= max( [ Cols, 2 ] )  " at least 2 columns

	let colwidth	= TextWidth/Cols
	let colwidth	= max( [ colwidth, 10 ] )

	let zz	= "\%\%----- TABULAR : begin ----------\n\\begin{tabular}[]{"
	let	zz = s:repeat_string( "p{".colwidth."mm}", Cols, zz, "}\n" )
	"
	" build a single row
	let	row	=	s:repeat_string( ' & ', Cols-1, ' ', " \\\\\n" )

	let zz	.= "\\hline\n".row."\\hline\n"
	"
	" generate all rows
	let	zz	= s:repeat_string( row, Rows-1, zz )
	let zz	.= "\\hline\n"
	let zz	.= "\\end{tabular}\\\\\n"
	let zz	.= "\%\%----- TABULAR :  end  ----------\n"
	put =zz
	silent exe "normal ".Rows."k"
endfunction    " ----------  end of function Latex_Tabular  ----------
"
"------------------------------------------------------------------------------
"  Latex_texdoc : lookup package documentation for word under the cursor or ask    {{{1
"------------------------------------------------------------------------------
function! Latex_texdoc( )
	let cuc		= getline(".")[col(".") - 1]		" character under the cursor
	let	item	= expand("<cword>")							" word under the cursor
	if empty(cuc) || empty(item) || match( item, cuc ) == -1
		let	item=Latex_Input('Name of the package : ', '' )
	endif

	if !empty(item)
		let cmd	= 'texdoc '.item.' &'
 		call system( cmd )
		if v:shell_error
			echomsg	"Shell command '".cmd."' failed."
		endif
	endif
endfunction		" ---------- end of function  Latex_texdoc  ----------
"
"----------------------------------------------------------------------
"  *** SETUP PLUGIN ***  {{{1
"----------------------------------------------------------------------

call Latex_ToolMenu()

if s:Latex_LoadMenus == 'yes' && s:Latex_CreateMenusDelayed == 'no'
	call Latex_CreateGuiMenus()
endif
"
if has( 'autocmd' )
  autocmd BufNewFile,BufRead *.tex
        \ if ! exists( 'g:Latex_Templates' ) |
        \   call g:Latex_RereadTemplates ('no') |
        \   if s:Latex_LoadMenus == 'yes' | call g:Latex_AddMenus () | endif |
        \ endif |
        \ call s:CreateAdditionalMaps() |
        \ call mmtemplates#core#CreateMaps ( 'g:Latex_Templates', g:Latex_MapLeader )
  if s:Latex_InsertFileHeader == 'yes'
    autocmd BufNewFile  *.tex  call mmtemplates#core#InsertTemplate(g:Latex_Templates, 'Comments.file prolog')
  endif

endif
" }}}1
"
" =====================================================================================
" vim: tabstop=2 shiftwidth=2 foldmethod=marker
