"===============================================================================
"
"          File:  awk-support.vim
"
"   Description:  awk support
"
"                  Write awk scripts by inserting comments, statements,
"                  variables and builtins.
"
"   VIM Version:  7.0+
"        Author:  Wolfgang Mehner <wolfgang-mehner@web.de>
"                 Fritz Mehner <mehner.fritz@web.de>
"       Version:  see variable g:AwkSupportVersion below
"       Created:  14.01.2012
"      Revision:  21.02.2016
"       License:  Copyright (c) 2001-2015, Dr. Fritz Mehner
"                 Copyright (c) 2016-2016, Wolfgang Mehner
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
  echohl WarningMsg | echo 'plugin awk-support.vim needs Vim version >= 7'| echohl None
  finish
endif
"
" Prevent duplicate loading:
"
if exists("g:AwkSupportVersion") || &cp
 finish
endif
"
let g:AwkSupportVersion= "1.3"                  " version number of this script; do not change
"
"===  FUNCTION  ================================================================
"          NAME:  SetGlobalVariable     {{{1
"   DESCRIPTION:  Define a global variable and assign a default value if nor
"                 already defined
"    PARAMETERS:  name - global variable
"                 default - default value
"===============================================================================
function! s:SetGlobalVariable ( name, default )
  if !exists('g:'.a:name)
    exe 'let g:'.a:name."  = '".a:default."'"
	else
		" check for an empty initialization
		exe 'let	val	= g:'.a:name
		if empty(val)
			exe 'let g:'.a:name."  = '".a:default."'"
		endif
  endif
endfunction   " ---------- end of function  s:SetGlobalVariable  ----------
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
let s:installation						= '*undefined*'
let g:Awk_PluginDir						= ''
let s:Awk_GlobalTemplateFile	= ''
let s:Awk_LocalTemplateFile		= ''
let s:Awk_CustomTemplateFile  = ''                " the custom templates
let s:Awk_FilenameEscChar 		= ''
let s:Awk_XtermDefaults       = '-fa courier -fs 12 -geometry 80x24'


if	s:MSWIN
  " ==========  MS Windows  ======================================================
	"
	let s:Awk_PluginDir = substitute( expand('<sfile>:p:h:h'), '\', '/', 'g' )
	"
	" change '\' to '/' to avoid interpretation as escape character
	if match(	substitute( expand("<sfile>"), '\', '/', 'g' ),
				\		substitute( expand("$HOME"),   '\', '/', 'g' ) ) == 0
		"
		" USER INSTALLATION ASSUMED
		let s:installation           = 'local'
		let s:Awk_LocalTemplateFile  = s:Awk_PluginDir.'/awk-support/templates/Templates'
		let s:Awk_CustomTemplateFile = $HOME.'/vimfiles/templates/awk.templates'
	else
		"
		" SYSTEM WIDE INSTALLATION
		let s:installation           = 'system'
		let s:Awk_GlobalTemplateFile = s:Awk_PluginDir.'/awk-support/templates/Templates'
		let s:Awk_LocalTemplateFile  = $HOME.'/vimfiles/awk-support/templates/Templates'
		let s:Awk_CustomTemplateFile = $HOME.'/vimfiles/templates/awk.templates'
	endif
	"
  let s:Awk_FilenameEscChar 		= ''
	let s:Awk_Display    					= ''
	let s:Awk_ManualReader				= 'man.exe'
	let s:Awk_Awk									= 'awk.exe'
	let s:Awk_OutputGvim					= 'xterm'
	"
else
  " ==========  Linux/Unix  ======================================================
	"
	let s:Awk_PluginDir = expand("<sfile>:p:h:h")
	"
	if match( expand("<sfile>"), resolve( expand("$HOME") ) ) == 0
		"
		" USER INSTALLATION ASSUMED
		let s:installation           = 'local'
		let s:Awk_LocalTemplateFile  = s:Awk_PluginDir.'/awk-support/templates/Templates'
		let s:Awk_CustomTemplateFile = $HOME.'/vimfiles/templates/awk.templates'
	else
		"
		" SYSTEM WIDE INSTALLATION
		let s:installation           = 'system'
		let s:Awk_PluginDir          = $VIM.'/vimfiles'
		let s:Awk_GlobalTemplateFile = s:Awk_PluginDir.'/awk-support/templates/Templates'
		let s:Awk_LocalTemplateFile  = $HOME.'/.vim/awk-support/templates/Templates'
		let s:Awk_CustomTemplateFile = $HOME.'/vimfiles/templates/awk.templates'
	endif
	"
	let s:Awk_Awk									= '/usr/bin/awk'
  let s:Awk_FilenameEscChar 		= ' \%#[]'
	let s:Awk_Display							= $DISPLAY
	let s:Awk_ManualReader				= '/usr/bin/man'
	let s:Awk_OutputGvim					= 'vim'
	"
endif

let s:Awk_AdditionalTemplates = mmtemplates#config#GetFt ( 'awk' )
let s:Awk_CodeSnippets        = s:Awk_PluginDir.'/awk-support/codesnippets/'
call s:SetGlobalVariable ( 'Awk_CodeSnippets', s:Awk_CodeSnippets )

"  g:Awk_Dictionary_File  must be global
if !exists("g:Awk_Dictionary_File")
	let g:Awk_Dictionary_File     = s:Awk_PluginDir.'/awk-support/wordlists/awk-keywords.list'
endif

"----------------------------------------------------------------------
"  *** MODUL GLOBAL VARIABLES *** {{{1
"----------------------------------------------------------------------
"
let s:Awk_CreateMenusDelayed= 'yes'
let s:Awk_MenuVisible				= 'no'
let s:Awk_GuiSnippetBrowser = 'gui'             " gui / commandline
let s:Awk_LoadMenus         = 'yes'             " load the menus?
let s:Awk_RootMenu          = '&Awk'            " name of the root menu
"
let s:Awk_MapLeader             = ''            " default: do not overwrite 'maplocalleader'
let s:Awk_LineEndCommColDefault = 49
let s:Awk_StartComment					= '#'
let s:Awk_Printheader   				= "%<%f%h%m%<  %=%{strftime('%x %X')}     Page %N"
let s:Awk_TemplateJumpTarget 		= ''
let s:Awk_Errorformat    				= 'awk:\ %f:%l:\ %m'
let s:Awk_Wrapper               = s:Awk_PluginDir.'/awk-support/scripts/wrapper.sh'
let s:Awk_InsertFileHeader			= 'yes'
"
call s:GetGlobalSetting ( 'Awk_Awk')
call s:GetGlobalSetting ( 'Awk_InsertFileHeader ')
call s:GetGlobalSetting ( 'Awk_GuiSnippetBrowser' )
call s:GetGlobalSetting ( 'Awk_LoadMenus' )
call s:GetGlobalSetting ( 'Awk_RootMenu' )
call s:GetGlobalSetting ( 'Awk_Printheader' )
call s:GetGlobalSetting ( 'Awk_ManualReader' )
call s:GetGlobalSetting ( 'Awk_OutputGvim' )
call s:GetGlobalSetting ( 'Awk_XtermDefaults' )
call s:GetGlobalSetting ( 'Awk_GlobalTemplateFile' )
call s:GetGlobalSetting ( 'Awk_LocalTemplateFile' )
call s:GetGlobalSetting ( 'Awk_CustomTemplateFile' )
call s:GetGlobalSetting ( 'Awk_CreateMenusDelayed' )
call s:GetGlobalSetting ( 'Awk_LineEndCommColDefault' )

call s:ApplyDefaultSetting ( 'Awk_MapLeader'    )
"
" set default geometry if not specified
"
if match( s:Awk_XtermDefaults, "-geometry\\s\\+\\d\\+x\\d\\+" ) < 0
	let s:Awk_XtermDefaults	= s:Awk_XtermDefaults." -geometry 80x24"
endif
"
let s:Awk_Printheader  					= escape( s:Awk_Printheader, ' %' )
let s:Awk_saved_global_option		= {}
let b:Awk_AwkCmdLineArgs				= ''
"------------------------------------------------------------------------------
"  Awk_SaveGlobalOption    {{{1
"  param 1 : option name
"  param 2 : characters to be escaped (optional)
"------------------------------------------------------------------------------
function! s:Awk_SaveGlobalOption ( option, ... )
	exe 'let escaped =&'.a:option
	if a:0 == 0
		let escaped	= escape( escaped, ' |"\' )
	else
		let escaped	= escape( escaped, ' |"\'.a:1 )
	endif
	let s:Awk_saved_global_option[a:option]	= escaped
endfunction    " ----------  end of function Awk_SaveGlobalOption  ----------
"
"------------------------------------------------------------------------------
"  Awk_RestoreGlobalOption    {{{1
"------------------------------------------------------------------------------
function! s:Awk_RestoreGlobalOption ( option )
	exe ':set '.a:option.'='.s:Awk_saved_global_option[a:option]
endfunction    " ----------  end of function Awk_RestoreGlobalOption  ----------
"
"===  FUNCTION  ================================================================
"          NAME:  Awk_Input     {{{1
"   DESCRIPTION:  Input after a highlighted prompt
"    PARAMETERS:  prompt       - prompt string
"                 defaultreply - default reply
"                 ...          - completion
"       RETURNS:  reply
"===============================================================================
function! Awk_Input ( prompt, defaultreply, ... )
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
endfunction    " ----------  end of function Awk_Input ----------
"
" patterns to ignore when adjusting line-end comments (incomplete):
let	s:AlignRegex	= [
	\	'\$#' ,
	\	"'\\%(\\\\'\\|[^']\\)*'"  ,
	\	'"\%(\\.\|[^"]\)*"'  ,
	\	'`[^`]\+`' ,
	\	]
"
"===  FUNCTION  ================================================================
"          NAME:  Awk_AdjustLineEndComm     {{{1
"   DESCRIPTION:  adjust end-of-line comments
"    PARAMETERS:  -
"       RETURNS:
"===============================================================================
function! Awk_AdjustLineEndComm ( ) range
	"
	" comment character (for use in regular expression)
	let cc = '#'                       " start of an Awk comment
	"
	" patterns to ignore when adjusting line-end comments (maybe incomplete):
 	let align_regex	= join( s:AlignRegex, '\|' )
	"
	" local position
	if !exists( 'b:Awk_LineEndCommentColumn' )
		let b:Awk_LineEndCommentColumn = s:Awk_LineEndCommColDefault
	endif
	let correct_idx = b:Awk_LineEndCommentColumn
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
endfunction		" ---------- end of function  Awk_AdjustLineEndComm  ----------
"
"===  FUNCTION  ================================================================
"          NAME:  Awk_GetLineEndCommCol     {{{1
"   DESCRIPTION:  get end-of-line comment position
"    PARAMETERS:  -
"       RETURNS:
"===============================================================================
function! Awk_GetLineEndCommCol ()
	let actcol	= virtcol(".")
	if actcol+1 == virtcol("$")
		let	b:Awk_LineEndCommentColumn	= ''
		while match( b:Awk_LineEndCommentColumn, '^\s*\d\+\s*$' ) < 0
			let b:Awk_LineEndCommentColumn = Awk_Input( 'start line-end comment at virtual column : ', actcol, '' )
		endwhile
	else
		let	b:Awk_LineEndCommentColumn	= virtcol(".")
	endif
  echomsg "line end comments will start at column  ".b:Awk_LineEndCommentColumn
endfunction		" ---------- end of function  Awk_GetLineEndCommCol  ----------
"
"===  FUNCTION  ================================================================
"          NAME:  Awk_EndOfLineComment     {{{1
"   DESCRIPTION:  single end-of-line comment
"    PARAMETERS:  -
"       RETURNS:
"===============================================================================
function! Awk_EndOfLineComment ( ) range
	if !exists("b:Awk_LineEndCommentColumn")
		let	b:Awk_LineEndCommentColumn	= s:Awk_LineEndCommColDefault
	endif
	" ----- trim whitespaces -----
	exe a:firstline.','.a:lastline.'s/\s*$//'

	for line in range( a:lastline, a:firstline, -1 )
		silent exe ":".line
		if getline(line) !~ '^\s*$'
			let linelength	= virtcol( [line, "$"] ) - 1
			let	diff				= 1
			if linelength < b:Awk_LineEndCommentColumn
				let diff	= b:Awk_LineEndCommentColumn -1 -linelength
			endif
			exe "normal!	".diff."A "
			call mmtemplates#core#InsertTemplate(g:Awk_Templates, 'Comments.end-of-line comment')
		endif
	endfor
endfunction		" ---------- end of function  Awk_EndOfLineComment  ----------
"
"===  FUNCTION  ================================================================
"          NAME:  s:CodeComment     {{{1
"   DESCRIPTION:  Code -> Comment
"    PARAMETERS:  -
"       RETURNS:
"===============================================================================
function! s:CodeComment() range
	" add '#' at the beginning of the lines
	for line in range( a:firstline, a:lastline )
		exe line.'s/^/#/'
	endfor
endfunction    " ----------  end of function s:CodeComment  ----------

"===  FUNCTION  ================================================================
"          NAME:  s:CommentCode     {{{1
"   DESCRIPTION:  Comment -> Code
"    PARAMETERS:  toggle - 0 : uncomment, 1 : toggle comment
"       RETURNS:
"===============================================================================
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

"===  FUNCTION  ================================================================
"          NAME:  Awk_RereadTemplates     {{{1
"   DESCRIPTION:  Reread the templates. Also set the character which starts
"                 the comments in the template files.
"    PARAMETERS:  -
"       RETURNS:
"===============================================================================
function! Awk_RereadTemplates ()

	"-------------------------------------------------------------------------------
	" setup template library
	"-------------------------------------------------------------------------------
	let g:Awk_Templates = mmtemplates#core#NewLibrary ( 'api_version', '1.0' )

	" mapleader
	if empty ( g:Awk_MapLeader )
		call mmtemplates#core#Resource ( g:Awk_Templates, 'set', 'property', 'Templates::Mapleader', '\' )
	else
		call mmtemplates#core#Resource ( g:Awk_Templates, 'set', 'property', 'Templates::Mapleader', g:Awk_MapLeader )
	endif

	" some metainfo
	call mmtemplates#core#Resource ( g:Awk_Templates, 'set', 'property', 'Templates::Wizard::PluginName',   'Awk' )
	call mmtemplates#core#Resource ( g:Awk_Templates, 'set', 'property', 'Templates::Wizard::FiletypeName', 'Awk' )
	call mmtemplates#core#Resource ( g:Awk_Templates, 'set', 'property', 'Templates::Wizard::FileCustomNoPersonal',   s:Awk_PluginDir.'/awk-support/rc/custom.templates' )
	call mmtemplates#core#Resource ( g:Awk_Templates, 'set', 'property', 'Templates::Wizard::FileCustomWithPersonal', s:Awk_PluginDir.'/awk-support/rc/custom_with_personal.templates' )
	call mmtemplates#core#Resource ( g:Awk_Templates, 'set', 'property', 'Templates::Wizard::FilePersonal',           s:Awk_PluginDir.'/awk-support/rc/personal.templates' )
	call mmtemplates#core#Resource ( g:Awk_Templates, 'set', 'property', 'Templates::Wizard::CustomFileVariable',     'g:Awk_CustomTemplateFile' )

	" maps: special operations
	call mmtemplates#core#Resource ( g:Awk_Templates, 'set', 'property', 'Templates::RereadTemplates::Map', 'ntr' )
	call mmtemplates#core#Resource ( g:Awk_Templates, 'set', 'property', 'Templates::ChooseStyle::Map',     'nts' )
	call mmtemplates#core#Resource ( g:Awk_Templates, 'set', 'property', 'Templates::SetupWizard::Map',     'ntw' )

	" syntax: comments
	call mmtemplates#core#ChangeSyntax ( g:Awk_Templates, 'comment', '§' )

	"-------------------------------------------------------------------------------
	" load template library
	"-------------------------------------------------------------------------------

	" global templates (global installation only)
	if s:installation == 'system'
		call mmtemplates#core#ReadTemplates ( g:Awk_Templates, 'load', s:Awk_GlobalTemplateFile,
					\ 'name', 'global', 'map', 'ntg' )
	endif

	" local templates (optional for global installation)
	if s:installation == 'system'
		call mmtemplates#core#ReadTemplates ( g:Awk_Templates, 'load', s:Awk_LocalTemplateFile,
					\ 'name', 'local', 'map', 'ntl', 'optional', 'hidden' )
	else
		call mmtemplates#core#ReadTemplates ( g:Awk_Templates, 'load', s:Awk_LocalTemplateFile,
					\ 'name', 'local', 'map', 'ntl' )
	endif

	" additional templates (optional)
	if ! empty ( s:Awk_AdditionalTemplates )
		call mmtemplates#core#AddCustomTemplateFiles ( g:Awk_Templates, s:Awk_AdditionalTemplates, "Awk's additional templates" )
	endif

	" personal templates (shared across template libraries) (optional, existence of file checked by template engine)
	call mmtemplates#core#ReadTemplates ( g:Awk_Templates, 'personalization',
				\ 'name', 'personal', 'map', 'ntp' )

	" custom templates (optional, existence of file checked by template engine)
	call mmtemplates#core#ReadTemplates ( g:Awk_Templates, 'load', s:Awk_CustomTemplateFile,
				\ 'name', 'custom', 'map', 'ntc', 'optional' )

	"-------------------------------------------------------------------------------
	" further setup
	"-------------------------------------------------------------------------------

	" get the jump tags
	let s:Awk_TemplateJumpTarget = mmtemplates#core#Resource ( g:Awk_Templates, "jumptag" )[0]

endfunction    " ----------  end of function Awk_RereadTemplates  ----------

"===  FUNCTION  ================================================================
"          NAME:  s:CheckTemplatePersonalization     {{{1
"   DESCRIPTION:  check whether the name, .. has been set
"    PARAMETERS:  -
"       RETURNS:
"===============================================================================
let s:DoneCheckTemplatePersonalization = 0

function! s:CheckTemplatePersonalization ()

	" check whether the templates are personalized
	if ! s:DoneCheckTemplatePersonalization
				\ && mmtemplates#core#ExpandText ( g:Awk_Templates, '|AUTHOR|' ) == 'YOUR NAME'
		let s:DoneCheckTemplatePersonalization = 1

		let maplead = mmtemplates#core#Resource ( g:Awk_Templates, 'get', 'property', 'Templates::Mapleader' )[0]

		redraw
		echohl Search
		echo 'The personal details (name, mail, ...) are not set in the template library.'
		echo 'They are used to generate comments, ...'
		echo 'To set them, start the setup wizard using:'
		echo '- use the menu entry "Awk -> Snippets -> template setup wizard"'
		echo '- use the map "'.maplead.'ntw" inside an Awk buffer'
		echo "\n"
		echohl None
	endif

endfunction    " ----------  end of function s:CheckTemplatePersonalization  ----------

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
	call mmtemplates#core#CreateMenus ( 'g:Awk_Templates', s:Awk_RootMenu, 'do_reset' )
	"
	" get the mapleader (correctly escaped)
	let [ esc_mapl, err ] = mmtemplates#core#Resource ( g:Awk_Templates, 'escaped_mapleader' )
	"
	exe 'amenu '.s:Awk_RootMenu.'.Awk  <Nop>'
	exe 'amenu '.s:Awk_RootMenu.'.-Sep00- <Nop>'
	"
 	"-------------------------------------------------------------------------------
	" menu headers
	"-------------------------------------------------------------------------------
	"
	call mmtemplates#core#CreateMenus ( 'g:Awk_Templates', s:Awk_RootMenu, 'sub_menu', '&Comments', 'priority', 500 )
	" the other, automatically created menus go here; their priority is the standard priority 500
	call mmtemplates#core#CreateMenus ( 'g:Awk_Templates', s:Awk_RootMenu, 'sub_menu', 'S&nippets', 'priority', 600 )
	call mmtemplates#core#CreateMenus ( 'g:Awk_Templates', s:Awk_RootMenu, 'sub_menu', '&Run'     , 'priority', 700 )
	call mmtemplates#core#CreateMenus ( 'g:Awk_Templates', s:Awk_RootMenu, 'sub_menu', '&Help'    , 'priority', 800 )
	"
	"-------------------------------------------------------------------------------
	" comments
 	"-------------------------------------------------------------------------------
	"
	let  head =  'noremenu <silent> '.s:Awk_RootMenu.'.Comments.'
	let ahead = 'anoremenu <silent> '.s:Awk_RootMenu.'.Comments.'
	let vhead = 'vnoremenu <silent> '.s:Awk_RootMenu.'.Comments.'
	let ihead = 'inoremenu <silent> '.s:Awk_RootMenu.'.Comments.'
	"
	exe ahead.'end-of-&line\ comment<Tab>'.esc_mapl.'cl                    :call Awk_EndOfLineComment()<CR>'
	exe vhead.'end-of-&line\ comment<Tab>'.esc_mapl.'cl                    :call Awk_EndOfLineComment()<CR>'

	exe ahead.'ad&just\ end-of-line\ com\.<Tab>'.esc_mapl.'cj              :call Awk_AdjustLineEndComm()<CR>'
	exe ihead.'ad&just\ end-of-line\ com\.<Tab>'.esc_mapl.'cj         <Esc>:call Awk_AdjustLineEndComm()<CR>'
	exe vhead.'ad&just\ end-of-line\ com\.<Tab>'.esc_mapl.'cj              :call Awk_AdjustLineEndComm()<CR>'
	exe  head.'&set\ end-of-line\ com\.\ col\.<Tab>'.esc_mapl.'cs     <Esc>:call Awk_GetLineEndCommCol()<CR>'
	"
	exe ahead.'-Sep01-						<Nop>'
	exe ahead.'&comment<TAB>'.esc_mapl.'cc		:call <SID>CodeComment()<CR>'
	exe vhead.'&comment<TAB>'.esc_mapl.'cc		:call <SID>CodeComment()<CR>'
	exe ahead.'&uncomment<TAB>'.esc_mapl.'co	:call <SID>CommentCode(0)<CR>'
	exe vhead.'&uncomment<TAB>'.esc_mapl.'co	:call <SID>CommentCode(0)<CR>'
	exe ahead.'-Sep02-												             <Nop>'
	"
	"-------------------------------------------------------------------------------
	" generate menus from the templates
 	"-------------------------------------------------------------------------------
	"
	call mmtemplates#core#CreateMenus ( 'g:Awk_Templates', s:Awk_RootMenu, 'do_templates' )
	"
	"-------------------------------------------------------------------------------
	" snippets
	"-------------------------------------------------------------------------------
	"
	if !empty(s:Awk_CodeSnippets)
		"
		exe "amenu  <silent> ".s:Awk_RootMenu.'.S&nippets.&read\ code\ snippet<Tab>'.esc_mapl.'nr       :call Awk_CodeSnippet("read")<CR>'
		exe "imenu  <silent> ".s:Awk_RootMenu.'.S&nippets.&read\ code\ snippet<Tab>'.esc_mapl.'nr  <C-C>:call Awk_CodeSnippet("read")<CR>'
		exe "amenu  <silent> ".s:Awk_RootMenu.'.S&nippets.&view\ code\ snippet<Tab>'.esc_mapl.'nv       :call Awk_CodeSnippet("view")<CR>'
		exe "imenu  <silent> ".s:Awk_RootMenu.'.S&nippets.&view\ code\ snippet<Tab>'.esc_mapl.'nv  <C-C>:call Awk_CodeSnippet("view")<CR>'
		exe "amenu  <silent> ".s:Awk_RootMenu.'.S&nippets.&write\ code\ snippet<Tab>'.esc_mapl.'nw      :call Awk_CodeSnippet("write")<CR>'
		exe "imenu  <silent> ".s:Awk_RootMenu.'.S&nippets.&write\ code\ snippet<Tab>'.esc_mapl.'nw <C-C>:call Awk_CodeSnippet("write")<CR>'
		exe "vmenu  <silent> ".s:Awk_RootMenu.'.S&nippets.&write\ code\ snippet<Tab>'.esc_mapl.'nw <C-C>:call Awk_CodeSnippet("writemarked")<CR>'
		exe "amenu  <silent> ".s:Awk_RootMenu.'.S&nippets.&edit\ code\ snippet<Tab>'.esc_mapl.'ne       :call Awk_CodeSnippet("edit")<CR>'
		exe "imenu  <silent> ".s:Awk_RootMenu.'.S&nippets.&edit\ code\ snippet<Tab>'.esc_mapl.'ne  <C-C>:call Awk_CodeSnippet("edit")<CR>'
		exe "amenu  <silent> ".s:Awk_RootMenu.'.S&nippets.-SepSnippets-                       :'
		"
	endif
	"
	call mmtemplates#core#CreateMenus ( 'g:Awk_Templates', s:Awk_RootMenu, 'do_specials', 'specials_menu', 'S&nippets' )
	"
	"-------------------------------------------------------------------------------
	" run
	"-------------------------------------------------------------------------------
	"
	exe " menu <silent> ".s:Awk_RootMenu.'.&Run.save\ +\ &run\ script<Tab>'.esc_mapl.'rr\ \ <C-F9>            :call Awk_Run("n")<CR>'
	exe "imenu <silent> ".s:Awk_RootMenu.'.&Run.save\ +\ &run\ script<Tab>'.esc_mapl.'rr\ \ <C-F9>       <C-C>:call Awk_Run("n")<CR>'
  exe " menu <silent> ".s:Awk_RootMenu.'.&Run.update,\ check\ &syntax<Tab>'.esc_mapl.'rs\ \ <A-F9>          :call Awk_SyntaxCheck("syntax")<CR>'
  exe "imenu <silent> ".s:Awk_RootMenu.'.&Run.update,\ check\ &syntax<Tab>'.esc_mapl.'rs\ \ <A-F9>     <C-C>:call Awk_SyntaxCheck("syntax")<CR>'
  exe " menu <silent> ".s:Awk_RootMenu.'.&Run.update,\ &lint\ check<Tab>'.esc_mapl.'rl                      :call Awk_SyntaxCheck("lint")<CR>'
  exe "imenu <silent> ".s:Awk_RootMenu.'.&Run.update,\ &lint\ check<Tab>'.esc_mapl.'rl                 <C-C>:call Awk_SyntaxCheck("lint")<CR>'
	"
	exe " menu          ".s:Awk_RootMenu.'.&Run.script\ cmd\.\ line\ &arg\.<Tab>'.esc_mapl.'ra\ \ <S-F9>      :AwkScriptArguments<Space>'
	exe "imenu          ".s:Awk_RootMenu.'.&Run.script\ cmd\.\ line\ &arg\.<Tab>'.esc_mapl.'ra\ \ <S-F9> <C-C>:AwkScriptArguments<Space>'
	"
	exe " menu          ".s:Awk_RootMenu.'.&Run.AWK\ cmd\.\ line\ &arg\.<Tab>'.esc_mapl.'raa                  :AwkArguments<Space>'
	exe "imenu          ".s:Awk_RootMenu.'.&Run.AWK\ cmd\.\ line\ &arg\.<Tab>'.esc_mapl.'raa             <C-C>:AwkArguments<Space>'
	"
	let ahead = 'amenu <silent> '.s:Awk_RootMenu.'.Run.'
	let vhead = 'vmenu <silent> '.s:Awk_RootMenu.'.Run.'
  "
  if !s:MSWIN
		exe ahead.'make\ script\ &exec\./not\ exec\.<Tab>'.esc_mapl.'re      :call Awk_MakeScriptExecutable()<CR>'
  endif
	"
	exe ahead.'-SEP1-   :'
	if	s:MSWIN
		exe ahead.'&hardcopy\ to\ printer<Tab>'.esc_mapl.'rh        <C-C>:call Awk_Hardcopy("n")<CR>'
		exe vhead.'&hardcopy\ to\ printer<Tab>'.esc_mapl.'rh        <C-C>:call Awk_Hardcopy("v")<CR>'
	else
		exe ahead.'&hardcopy\ to\ FILENAME\.ps<Tab>'.esc_mapl.'rh   <C-C>:call Awk_Hardcopy("n")<CR>'
		exe vhead.'&hardcopy\ to\ FILENAME\.ps<Tab>'.esc_mapl.'rh   <C-C>:call Awk_Hardcopy("v")<CR>'
	endif
	"
	exe ahead.'-SEP2-                                                :'
	exe ahead.'plugin\ &settings<Tab>'.esc_mapl.'rse                 :call Awk_Settings(0)<CR>'
	"
	if	!s:MSWIN
		exe " menu  <silent>  ".s:Awk_RootMenu.'.&Run.x&term\ size<Tab>'.esc_mapl.'rx                       :call Awk_XtermSize()<CR>'
		exe "imenu  <silent>  ".s:Awk_RootMenu.'.&Run.x&term\ size<Tab>'.esc_mapl.'rx                  <C-C>:call Awk_XtermSize()<CR>'
	endif
	"
	if	s:MSWIN
		if s:Awk_OutputGvim == "buffer"
			exe " menu  <silent>  ".s:Awk_RootMenu.'.&Run.&output:\ BUFFER->term<Tab>'.esc_mapl.'ro          :call Awk_Toggle_Gvim_Xterm_MS()<CR>'
			exe "imenu  <silent>  ".s:Awk_RootMenu.'.&Run.&output:\ BUFFER->term<Tab>'.esc_mapl.'ro     <C-C>:call Awk_Toggle_Gvim_Xterm_MS()<CR>'
		else
			exe " menu  <silent>  ".s:Awk_RootMenu.'.&Run.&output:\ TERM->buffer<Tab>'.esc_mapl.'ro          :call Awk_Toggle_Gvim_Xterm_MS()<CR>'
			exe "imenu  <silent>  ".s:Awk_RootMenu.'.&Run.&output:\ TERM->buffer<Tab>'.esc_mapl.'ro     <C-C>:call Awk_Toggle_Gvim_Xterm_MS()<CR>'
		endif
	else
		if s:Awk_OutputGvim == "vim"
			exe " menu  <silent>  ".s:Awk_RootMenu.'.&Run.&output:\ VIM->buffer->xterm<Tab>'.esc_mapl.'ro          :call Awk_Toggle_Gvim_Xterm()<CR>'
			exe "imenu  <silent>  ".s:Awk_RootMenu.'.&Run.&output:\ VIM->buffer->xterm<Tab>'.esc_mapl.'ro     <C-C>:call Awk_Toggle_Gvim_Xterm()<CR>'
		else
			if s:Awk_OutputGvim == "buffer"
				exe " menu  <silent>  ".s:Awk_RootMenu.'.&Run.&output:\ BUFFER->xterm->vim<Tab>'.esc_mapl.'ro        :call Awk_Toggle_Gvim_Xterm()<CR>'
				exe "imenu  <silent>  ".s:Awk_RootMenu.'.&Run.&output:\ BUFFER->xterm->vim<Tab>'.esc_mapl.'ro   <C-C>:call Awk_Toggle_Gvim_Xterm()<CR>'
			else
				exe " menu  <silent>  ".s:Awk_RootMenu.'.&Run.&output:\ XTERM->vim->buffer<Tab>'.esc_mapl.'ro        :call Awk_Toggle_Gvim_Xterm()<CR>'
				exe "imenu  <silent>  ".s:Awk_RootMenu.'.&Run.&output:\ XTERM->vim->buffer<Tab>'.esc_mapl.'ro   <C-C>:call Awk_Toggle_Gvim_Xterm()<CR>'
			endif
		endif
	endif
	"
 	"-------------------------------------------------------------------------------
 	" help
 	"-------------------------------------------------------------------------------
 	"
	let ahead = 'amenu <silent> '.s:Awk_RootMenu.'.Help.'
	let ihead = 'imenu <silent> '.s:Awk_RootMenu.'.Help.'
	"
	exe ahead.'&AWK\ manual<Tab>'.esc_mapl.'hm             :call Awk_help("awk")<CR>'
	exe ihead.'&AWK\ manual<Tab>'.esc_mapl.'hm        <C-C>:call Awk_help("awk")<CR>'
	exe ahead.'-SEP1- :'
	exe ahead.'&help\ (Awk-Support)<Tab>'.esc_mapl.'hp        :call Awk_HelpAwkSupport()<CR>'
	exe ihead.'&help\ (Awk-Support)<Tab>'.esc_mapl.'hp   <C-C>:call Awk_HelpAwkSupport()<CR>'
	"
endfunction    " ----------  end of function s:InitMenus  ----------
"
"===  FUNCTION  ================================================================
"          NAME:  Awk_JumpForward     {{{1
"   DESCRIPTION:  Jump to the next target, otherwise behind the current string.
"    PARAMETERS:  -
"       RETURNS:  empty string
"===============================================================================
function! Awk_JumpForward ()
  let match	= search( s:Awk_TemplateJumpTarget, 'c' )
	if match > 0
		" remove the target
		call setline( match, substitute( getline('.'), s:Awk_TemplateJumpTarget, '', '' ) )
	else
		" try to jump behind parenthesis or strings
		call search( "[\]})\"'`]", 'W' )
		normal! l
	endif
	return ''
endfunction    " ----------  end of function Awk_JumpForward  ----------
"
"===  FUNCTION  ================================================================
"          NAME:  Awk_CodeSnippet     {{{1
"   DESCRIPTION:  read / write / edit code sni
"    PARAMETERS:  mode - edit, read, write, writemarked, view
"===============================================================================
function! Awk_CodeSnippet(mode)
  if isdirectory(g:Awk_CodeSnippets)
    "
    " read snippet file, put content below current line
    "
    if a:mode == "read"
			if has("gui_running") && s:Awk_GuiSnippetBrowser == 'gui'
				let l:snippetfile=browse(0,"read a code snippet",g:Awk_CodeSnippets,"")
			else
				let	l:snippetfile=input("read snippet ", g:Awk_CodeSnippets, "file" )
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
          silent exe "normal! =".linesread."+"
        endif
      endif
    endif
    "
    " update current buffer / split window / edit snippet file
    "
    if a:mode == "edit"
			if has("gui_running") && s:Awk_GuiSnippetBrowser == 'gui'
				let l:snippetfile=browse(0,"edit a code snippet",g:Awk_CodeSnippets,"")
			else
				let	l:snippetfile=input("edit snippet ", g:Awk_CodeSnippets, "file" )
			endif
      if !empty(l:snippetfile)
        :execute "update! | split | edit ".l:snippetfile
      endif
    endif
    "
    " update current buffer / split window / view snippet file
    "
    if a:mode == "view"
			if has("gui_running") && s:Awk_GuiSnippetBrowser == 'gui'
				let l:snippetfile=browse(0,"view a code snippet",g:Awk_CodeSnippets,"")
			else
				let	l:snippetfile=input("view snippet ", g:Awk_CodeSnippets, "file" )
			endif
      if !empty(l:snippetfile)
        :execute "update! | split | view ".l:snippetfile
      endif
    endif
    "
    " write whole buffer or marked area into snippet file
    "
    if a:mode == "write" || a:mode == "writemarked"
			if has("gui_running") && s:Awk_GuiSnippetBrowser == 'gui'
				let l:snippetfile=browse(1,"write a code snippet",g:Awk_CodeSnippets,"")
			else
				let	l:snippetfile=input("write snippet ", g:Awk_CodeSnippets, "file" )
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
    echo "code snippet directory ".g:Awk_CodeSnippets." does not exist"
    echohl None
  endif
endfunction   " ---------- end of function  Awk_CodeSnippet  ----------
"
"===  FUNCTION  ================================================================
"          NAME:  Awk_Hardcopy     {{{1
"   DESCRIPTION:  Make PostScript document from current buffer
"                 MSWIN : display printer dialog
"    PARAMETERS:  mode - n : print complete buffer, v : print marked area
"       RETURNS:
"===============================================================================
function! Awk_Hardcopy (mode)
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
  exe  ':set printheader='.s:Awk_Printheader
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
endfunction   " ---------- end of function  Awk_Hardcopy  ----------
"
"===  FUNCTION  ================================================================
"          NAME:  s:CreateAdditionalMaps     {{{1
"   DESCRIPTION:  create additional maps
"    PARAMETERS:  -
"       RETURNS:
"===============================================================================
function! s:CreateAdditionalMaps ()
	"
	" ---------- Awk dictionary -------------------------------------------------
	" This will enable keyword completion for Awk
	" using Vim's dictionary feature |i_CTRL-X_CTRL-K|.
	"
	if exists("g:Awk_Dictionary_File")
		silent! exe 'setlocal dictionary+='.g:Awk_Dictionary_File
	endif
	"
	"-------------------------------------------------------------------------------
	" USER DEFINED COMMANDS
	"-------------------------------------------------------------------------------
	command! -buffer -nargs=* -complete=file AwkScriptArguments  call Awk_ScriptCmdLineArguments(<q-args>)
	command! -buffer -nargs=* -complete=file AwkArguments        call Awk_AwkCmdLineArguments(<q-args>)
	"
	"-------------------------------------------------------------------------------
	" settings - local leader
	"-------------------------------------------------------------------------------
	if ! empty ( g:Awk_MapLeader )
		if exists ( 'g:maplocalleader' )
			let ll_save = g:maplocalleader
		endif
		let g:maplocalleader = g:Awk_MapLeader
	endif
	"
	"-------------------------------------------------------------------------------
	" comments
	"-------------------------------------------------------------------------------
	nnoremap    <buffer>  <silent>  <LocalLeader>cl         :call Awk_EndOfLineComment()<CR>
	inoremap    <buffer>  <silent>  <LocalLeader>cl    <C-C>:call Awk_EndOfLineComment()<CR>
	vnoremap    <buffer>  <silent>  <LocalLeader>cl         :call Awk_EndOfLineComment()<CR>
	"
	nnoremap    <buffer>  <silent>  <LocalLeader>cj         :call Awk_AdjustLineEndComm()<CR>
	inoremap    <buffer>  <silent>  <LocalLeader>cj    <C-C>:call Awk_AdjustLineEndComm()<CR>
	vnoremap    <buffer>  <silent>  <LocalLeader>cj         :call Awk_AdjustLineEndComm()<CR>
	"
	nnoremap    <buffer>  <silent>  <LocalLeader>cs         :call Awk_GetLineEndCommCol()<CR>
	inoremap    <buffer>  <silent>  <LocalLeader>cs    <C-C>:call Awk_GetLineEndCommCol()<CR>
	vnoremap    <buffer>  <silent>  <LocalLeader>cs    <C-C>:call Awk_GetLineEndCommCol()<CR>

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

	"-------------------------------------------------------------------------------
	" snippets
	"-------------------------------------------------------------------------------
	"
	nnoremap    <buffer>  <silent>  <LocalLeader>nr         :call Awk_CodeSnippet("read")<CR>
	inoremap    <buffer>  <silent>  <LocalLeader>nr    <Esc>:call Awk_CodeSnippet("read")<CR>
	nnoremap    <buffer>  <silent>  <LocalLeader>nw         :call Awk_CodeSnippet("write")<CR>
	inoremap    <buffer>  <silent>  <LocalLeader>nw    <Esc>:call Awk_CodeSnippet("write")<CR>
	vnoremap    <buffer>  <silent>  <LocalLeader>nw    <Esc>:call Awk_CodeSnippet("writemarked")<CR>
	nnoremap    <buffer>  <silent>  <LocalLeader>ne         :call Awk_CodeSnippet("edit")<CR>
	inoremap    <buffer>  <silent>  <LocalLeader>ne    <Esc>:call Awk_CodeSnippet("edit")<CR>
	nnoremap    <buffer>  <silent>  <LocalLeader>nv         :call Awk_CodeSnippet("view")<CR>
	inoremap    <buffer>  <silent>  <LocalLeader>nv    <Esc>:call Awk_CodeSnippet("view")<CR>
	"
	"-------------------------------------------------------------------------------
	"   run
	"-------------------------------------------------------------------------------
	"
	 noremap    <buffer>  <silent>  <LocalLeader>rr        :call Awk_Run("n")<CR>
	inoremap    <buffer>  <silent>  <LocalLeader>rr   <Esc>:call Awk_Run("n")<CR>
	 noremap    <buffer>  <silent>  <LocalLeader>rs        :call Awk_SyntaxCheck("syntax")<CR>
	inoremap    <buffer>  <silent>  <LocalLeader>rs   <C-C>:call Awk_SyntaxCheck("syntax")<CR>
	 noremap    <buffer>  <silent>  <LocalLeader>rl        :call Awk_SyntaxCheck("lint")<CR>
	inoremap    <buffer>  <silent>  <LocalLeader>rl   <C-C>:call Awk_SyntaxCheck("lint")<CR>
	 noremap    <buffer>            <LocalLeader>ra        :AwkScriptArguments<Space>
	inoremap    <buffer>            <LocalLeader>ra   <Esc>:AwkScriptArguments<Space>
   noremap    <buffer>            <LocalLeader>raa       :AwkArguments<Space>
 	inoremap    <buffer>            <LocalLeader>raa  <Esc>:AwkArguments<Space>
	"
	if s:UNIX
		 noremap    <buffer>  <silent>  <LocalLeader>re        :call Awk_MakeScriptExecutable()<CR>
		inoremap    <buffer>  <silent>  <LocalLeader>re   <C-C>:call Awk_MakeScriptExecutable()<CR>
	endif
	nnoremap    <buffer>  <silent>  <LocalLeader>rh        :call Awk_Hardcopy("n")<CR>
	vnoremap    <buffer>  <silent>  <LocalLeader>rh   <C-C>:call Awk_Hardcopy("v")<CR>
  "
   noremap  <buffer>  <silent>  <C-F9>        :call Awk_Run("n")<CR>
  inoremap  <buffer>  <silent>  <C-F9>   <C-C>:call Awk_Run("n")<CR>
		"
   noremap  <buffer>  <silent>  <A-F9>        :call Awk_SyntaxCheck("syntax")<CR>
  inoremap  <buffer>  <silent>  <A-F9>   <C-C>:call Awk_SyntaxCheck("syntax")<CR>
  "
  noremap   <buffer>            <S-F9>        :AwkScriptArguments<Space>
  inoremap  <buffer>            <S-F9>   <C-C>:AwkScriptArguments<Space>

	if s:MSWIN
 		 noremap  <buffer>  <silent>  <LocalLeader>ro           :call Awk_Toggle_Gvim_Xterm_MS()<CR>
		inoremap  <buffer>  <silent>  <LocalLeader>ro      <Esc>:call Awk_Toggle_Gvim_Xterm_MS()<CR>
	else
		 noremap  <buffer>  <silent>  <LocalLeader>ro           :call Awk_Toggle_Gvim_Xterm()<CR>
		inoremap  <buffer>  <silent>  <LocalLeader>ro      <Esc>:call Awk_Toggle_Gvim_Xterm()<CR>
	endif
	"
	"-------------------------------------------------------------------------------
	"   help
	"-------------------------------------------------------------------------------
	nnoremap    <buffer>  <silent>  <LocalLeader>rse         :call Awk_Settings(0)<CR>
  "
   noremap  <buffer>  <silent>  <LocalLeader>hm            :call Awk_help('awk')<CR>
  inoremap  <buffer>  <silent>  <LocalLeader>hm       <Esc>:call Awk_help('awk')<CR>
	 noremap  <buffer>  <silent>  <LocalLeader>hp         :call Awk_HelpAwkSupport()<CR>
	inoremap  <buffer>  <silent>  <LocalLeader>hp    <C-C>:call Awk_HelpAwkSupport()<CR>

	"-------------------------------------------------------------------------------
	" settings - reset local leader
	"-------------------------------------------------------------------------------
	if ! empty ( g:Awk_MapLeader )
		if exists ( 'll_save' )
			let g:maplocalleader = ll_save
		else
			unlet g:maplocalleader
		endif
	endif

	"-------------------------------------------------------------------------------
	" templates
	"-------------------------------------------------------------------------------
	nnoremap  <buffer>  <silent>  <C-j>       i<C-R>=Awk_JumpForward()<CR>
	inoremap  <buffer>  <silent>  <C-j>  <C-g>u<C-R>=Awk_JumpForward()<CR>

	call mmtemplates#core#CreateMaps ( 'g:Awk_Templates', g:Awk_MapLeader, 'do_special_maps', 'do_del_opt_map' )

endfunction    " ----------  end of function s:CreateAdditionalMaps  ----------
"
"------------------------------------------------------------------------------
"  Awk_HelpAwkSupport : help awksupport     {{{1
"------------------------------------------------------------------------------
function! Awk_HelpAwkSupport ()
	try
		:help awksupport
	catch
		exe ':helptags '.s:Awk_PluginDir.'/doc'
		:help awksupport
	endtry
endfunction    " ----------  end of function Awk_HelpAwkSupport ----------
"
"------------------------------------------------------------------------------
"  Awk_help : lookup word under the cursor or ask    {{{1
"------------------------------------------------------------------------------
let s:Awk_DocBufferName       = "AWK_HELP"
let s:Awk_DocHelpBufferNumber = -1
"
function! Awk_help( type )
	"
	" jump to an already open AWK manual window or create one
	"
	if bufloaded(s:Awk_DocBufferName) != 0 && bufwinnr(s:Awk_DocHelpBufferNumber) != -1
		exe bufwinnr(s:Awk_DocHelpBufferNumber) . "wincmd w"
		" buffer number may have changed, e.g. after a 'save as'
		if bufnr("%") != s:Awk_DocHelpBufferNumber
			let s:Awk_DocHelpBufferNumber=bufnr(s:Awk_OutputBufferName)
			exe ":bn ".s:Awk_DocHelpBufferNumber
		endif
	else
		exe ":new ".s:Awk_DocBufferName
		let s:Awk_DocHelpBufferNumber=bufnr("%")
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
	" open the AWK manual
	"-------------------------------------------------------------------------------
	let win_w = winwidth( winnr() )
	if a:type == 'awk'
		if s:UNIX && win_w > 0
			silent exe ":%! MANWIDTH=".win_w." ".s:Awk_ManualReader." 1 awk"
		else
			silent exe ":%!".s:Awk_ManualReader." 1 awk"
		endif

		if s:MSWIN
			call s:awk_RemoveSpecialCharacters()
		endif
	endif

	setlocal nomodifiable
endfunction		" ---------- end of function  Awk_help  ----------
"
"------------------------------------------------------------------------------
"  remove <backspace><any character> in CYGWIN man(1) output   {{{1
"  remove           _<any character> in CYGWIN man(1) output
"------------------------------------------------------------------------------
"
function! s:awk_RemoveSpecialCharacters ( )
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
endfunction		" ---------- end of function  s:awk_RemoveSpecialCharacters   ----------
"
"===  FUNCTION  ================================================================
"          NAME:  Awk_Settings     {{{1
"   DESCRIPTION:  Display plugin settings
"    PARAMETERS:  -
"       RETURNS:
"===============================================================================
function! Awk_Settings ( verbose )

	if     s:MSWIN | let sys_name = 'Windows'
	elseif s:UNIX  | let sys_name = 'UN*X'
	else           | let sys_name = 'unknown' | endif

	let	txt = " Awk-Support settings\n\n"
	" template settings: macros, style, ...
	if exists ( 'g:Awk_Templates' )
		let txt .= '                   author :  "'.mmtemplates#core#ExpandText( g:Awk_Templates, '|AUTHOR|'       )."\"\n"
		let txt .= '                authorref :  "'.mmtemplates#core#ExpandText( g:Awk_Templates, '|AUTHORREF|'    )."\"\n"
		let txt .= '                    email :  "'.mmtemplates#core#ExpandText( g:Awk_Templates, '|EMAIL|'        )."\"\n"
		let txt .= '             organization :  "'.mmtemplates#core#ExpandText( g:Awk_Templates, '|ORGANIZATION|' )."\"\n"
		let txt .= '         copyright holder :  "'.mmtemplates#core#ExpandText( g:Awk_Templates, '|COPYRIGHT|'    )."\"\n"
		let txt .= '                  license :  "'.mmtemplates#core#ExpandText( g:Awk_Templates, '|LICENSE|'      )."\"\n"
		let txt .= '                  project :  "'.mmtemplates#core#ExpandText( g:Awk_Templates, '|PROJECT|'     )."\"\n"
		let txt .= '           template style :  "'.mmtemplates#core#Resource ( g:Awk_Templates, "style" )[0]."\"\n\n"
	else
		let txt .= "                templates :  -not loaded-\n\n"
	endif
	" plug-in installation
	let txt .= '      plugin installation :  '.s:installation.' on '.sys_name."\n"
	let txt .= "\n"
	" templates, snippets
	if exists ( 'g:Awk_Templates' )
		let [ templist, msg ] = mmtemplates#core#Resource ( g:Awk_Templates, 'template_list' )
		let sep  = "\n"."                             "
		let txt .=      "           template files :  "
					\ .join ( templist, sep )."\n"
	else
		let txt .= "           template files :  -not loaded-\n"
	endif
	let txt .=
				\  '       code snippets dir. :  '.s:Awk_CodeSnippets."\n"
	" ----- dictionaries ------------------------
	if !empty(g:Awk_Dictionary_File)
		let ausgabe= &dictionary
		let ausgabe= substitute( ausgabe, ",", ",\n                             ", "g" )
		let txt = txt."       dictionary file(s) :  ".ausgabe."\n"
	endif
	" ----- map leader, menus, file headers -----
	if a:verbose >= 1
		let	txt .= "\n"
					\ .'                mapleader :  "'.g:Awk_MapLeader."\"\n"
					\ .'     load menus / delayed :  "'.s:Awk_LoadMenus.'" / "'.s:Awk_CreateMenusDelayed."\"\n"
					\ .'       insert file header :  "'.s:Awk_InsertFileHeader."\"\n"
	endif
	let txt .= "\n"
	" ----- executables, cmd.-line args, ... -------
	if exists( "b:Awk_AwkCmdLineArgs" )
		let cmd_line_args = b:Awk_AwkCmdLineArgs
	else
		let cmd_line_args = ''
	endif
	let txt .= '           Awk executable :  "'.s:Awk_Awk."\"\n"
	let txt .= '  Awk cmd. line arguments :  "'.cmd_line_args."\"\n"
	let txt = txt."\n"
	" ----- output ------------------------------
	let txt = txt.'     current output dest. :  '.s:Awk_OutputGvim."\n"
	if !s:MSWIN
		let txt = txt.'           xterm defaults :  '.s:Awk_XtermDefaults."\n"
	endif
	let	txt = txt."__________________________________________________________________________\n"
	let	txt = txt." Awk-Support, Version ".g:AwkSupportVersion." / Wolfgang Mehner / wolfgang-mehner@web.de\n\n"

	if a:verbose == 2
		split AwkSupport_Settings.txt
		put = txt
	else
		echo txt
	endif
endfunction    " ----------  end of function Awk_Settings ----------
"
"------------------------------------------------------------------------------
"  Awk_CreateGuiMenus     {{{1
"------------------------------------------------------------------------------
function! Awk_CreateGuiMenus ()
	if s:Awk_MenuVisible == 'no'
		aunmenu <silent> &Tools.Load\ Awk\ Support
		amenu   <silent> 40.1000 &Tools.-SEP100- :
		amenu   <silent> 40.1010 &Tools.Unload\ Awk\ Support :call Awk_RemoveGuiMenus()<CR>
		"
		call Awk_RereadTemplates()
		call s:InitMenus ()
		"
		let s:Awk_MenuVisible = 'yes'
	endif
endfunction    " ----------  end of function Awk_CreateGuiMenus  ----------
"
"------------------------------------------------------------------------------
"  Awk_ToolMenu     {{{1
"------------------------------------------------------------------------------
function! Awk_ToolMenu ()
	amenu   <silent> 40.1000 &Tools.-SEP100- :
	amenu   <silent> 40.1010 &Tools.Load\ Awk\ Support :call Awk_CreateGuiMenus()<CR>
endfunction    " ----------  end of function Awk_ToolMenu  ----------

"------------------------------------------------------------------------------
"  Awk_RemoveGuiMenus     {{{1
"------------------------------------------------------------------------------
function! Awk_RemoveGuiMenus ()
	if s:Awk_MenuVisible == 'yes'
		exe "aunmenu <silent> ".s:Awk_RootMenu
		"
		aunmenu <silent> &Tools.Unload\ Awk\ Support
		call Awk_ToolMenu()
		"
		let s:Awk_MenuVisible = 'no'
	endif
endfunction    " ----------  end of function Awk_RemoveGuiMenus  ----------
"
"----------------------------------------------------------------------
"  Run : toggle output destination (Linux/Unix)    {{{1
"----------------------------------------------------------------------
function! Awk_Toggle_Gvim_Xterm ()

	if has("gui_running")
	let [ esc_mapl, err ] = mmtemplates#core#Resource ( g:Awk_Templates, 'escaped_mapleader' )
		if s:Awk_OutputGvim == "vim"
			exe "aunmenu  <silent>  ".s:Awk_RootMenu.'.&Run.&output:\ VIM->buffer->xterm'
			exe " menu    <silent>  ".s:Awk_RootMenu.'.&Run.&output:\ BUFFER->xterm->vim<Tab>'.esc_mapl.'          :call Awk_Toggle_Gvim_Xterm()<CR>'
			exe "imenu    <silent>  ".s:Awk_RootMenu.'.&Run.&output:\ BUFFER->xterm->vim<Tab>'.esc_mapl.'     <C-C>:call Awk_Toggle_Gvim_Xterm()<CR>'
			let	s:Awk_OutputGvim	= "buffer"
		else
			if s:Awk_OutputGvim == "buffer"
				exe "aunmenu  <silent>  ".s:Awk_RootMenu.'.&Run.&output:\ BUFFER->xterm->vim'
				exe " menu    <silent>  ".s:Awk_RootMenu.'.&Run.&output:\ XTERM->vim->buffer<Tab>'.esc_mapl.'        :call Awk_Toggle_Gvim_Xterm()<CR>'
				exe "imenu    <silent>  ".s:Awk_RootMenu.'.&Run.&output:\ XTERM->vim->buffer<Tab>'.esc_mapl.'   <C-C>:call Awk_Toggle_Gvim_Xterm()<CR>'
				let	s:Awk_OutputGvim	= "xterm"
			else
				" ---------- output : xterm -> gvim
				exe "aunmenu  <silent>  ".s:Awk_RootMenu.'.&Run.&output:\ XTERM->vim->buffer'
				exe " menu    <silent>  ".s:Awk_RootMenu.'.&Run.&output:\ VIM->buffer->xterm<Tab>'.esc_mapl.'        :call Awk_Toggle_Gvim_Xterm()<CR>'
				exe "imenu    <silent>  ".s:Awk_RootMenu.'.&Run.&output:\ VIM->buffer->xterm<Tab>'.esc_mapl.'   <C-C>:call Awk_Toggle_Gvim_Xterm()<CR>'
				let	s:Awk_OutputGvim	= "vim"
			endif
		endif
	else
		if s:Awk_OutputGvim == "vim"
			let	s:Awk_OutputGvim	= "buffer"
		else
			let	s:Awk_OutputGvim	= "vim"
		endif
	endif
	echomsg "output destination is '".s:Awk_OutputGvim."'"

endfunction    " ----------  end of function Awk_Toggle_Gvim_Xterm ----------
"
"----------------------------------------------------------------------
"  Run : toggle output destination (Windows)    {{{1
"----------------------------------------------------------------------
function! Awk_Toggle_Gvim_Xterm_MS ()
	if has("gui_running")
	let [ esc_mapl, err ] = mmtemplates#core#Resource ( g:Awk_Templates, 'escaped_mapleader' )
		if s:Awk_OutputGvim == "buffer"
			exe "aunmenu  <silent>  ".s:Awk_RootMenu.'.&Run.&output:\ BUFFER->term'
			exe " menu    <silent>  ".s:Awk_RootMenu.'.&Run.&output:\ TERM->buffer<Tab>'.esc_mapl.'         :call Awk_Toggle_Gvim_Xterm_MS()<CR>'
			exe "imenu    <silent>  ".s:Awk_RootMenu.'.&Run.&output:\ TERM->buffer<Tab>'.esc_mapl.'    <C-C>:call Awk_Toggle_Gvim_Xterm_MS()<CR>'
			let	s:Awk_OutputGvim	= "xterm"
		else
			exe "aunmenu  <silent>  ".s:Awk_RootMenu.'.&Run.&output:\ TERM->buffer'
			exe " menu    <silent>  ".s:Awk_RootMenu.'.&Run.&output:\ BUFFER->term<Tab>'.esc_mapl.'         :call Awk_Toggle_Gvim_Xterm_MS()<CR>'
			exe "imenu    <silent>  ".s:Awk_RootMenu.'.&Run.&output:\ BUFFER->term<Tab>'.esc_mapl.'    <C-C>:call Awk_Toggle_Gvim_Xterm_MS()<CR>'
			let	s:Awk_OutputGvim	= "buffer"
		endif
	endif
endfunction    " ----------  end of function Awk_Toggle_Gvim_Xterm_MS ----------
"
"------------------------------------------------------------------------------
"  Run : xterm geometry    {{{1
"------------------------------------------------------------------------------
function! Awk_XtermSize ()
	let regex	= '-geometry\s\+\d\+x\d\+'
	let geom	= matchstr( s:Awk_XtermDefaults, regex )
	let geom	= matchstr( geom, '\d\+x\d\+' )
	let geom	= substitute( geom, 'x', ' ', "" )
	let	answer= Awk_Input("   xterm size (COLUMNS LINES) : ", geom, '' )
	while match(answer, '^\s*\d\+\s\+\d\+\s*$' ) < 0
		let	answer= Awk_Input(" + xterm size (COLUMNS LINES) : ", geom, '' )
	endwhile
	let answer  = substitute( answer, '^\s\+', "", "" )		 				" remove leading whitespaces
	let answer  = substitute( answer, '\s\+$', "", "" )						" remove trailing whitespaces
	let answer  = substitute( answer, '\s\+', "x", "" )						" replace inner whitespaces
	let s:Awk_XtermDefaults	= substitute( s:Awk_XtermDefaults, regex, "-geometry ".answer , "" )
endfunction		" ---------- end of function  Awk_XtermSize  ----------
"
"------------------------------------------------------------------------------
"  Awk_SaveOption    {{{1
"  param 1 : option name
"  param 2 : characters to be escaped (optional)
"------------------------------------------------------------------------------
function! Awk_SaveOption ( option, ... )
	exe 'let escaped =&'.a:option
	if a:0 == 0
		let escaped	= escape( escaped, ' |"\' )
	else
		let escaped	= escape( escaped, ' |"\'.a:1 )
	endif
	let s:Awk_saved_option[a:option]	= escaped
endfunction    " ----------  end of function Awk_SaveOption  ----------
"
let s:Awk_saved_option					= {}
"
"------------------------------------------------------------------------------
"  Awk_RestoreOption    {{{1
"------------------------------------------------------------------------------
function! Awk_RestoreOption ( option )
	exe ':setlocal '.a:option.'='.s:Awk_saved_option[a:option]
endfunction    " ----------  end of function Awk_RestoreOption  ----------
"
"------------------------------------------------------------------------------
"  Run : Command line arguments    {{{1
"------------------------------------------------------------------------------
function! Awk_ScriptCmdLineArguments ( ... )
	let	b:Awk_ScriptCmdLineArgs	= join( a:000 )
endfunction		" ---------- end of function  Awk_ScriptCmdLineArguments  ----------
"
"------------------------------------------------------------------------------
"  Awk_AwkCmdLineArguments : AWK command line arguments       {{{1
"------------------------------------------------------------------------------
function! Awk_AwkCmdLineArguments ( ... )
	let	b:Awk_AwkCmdLineArgs	= join( a:000 )
endfunction    " ----------  end of function Awk_AwkCmdLineArguments ----------
"
"------------------------------------------------------------------------------
"  Run : run    {{{1
"------------------------------------------------------------------------------
"
let s:Awk_OutputBufferName   = "AWK-Output"
let s:Awk_OutputBufferNumber = -1
"
function! Awk_Run ( mode ) range

	silent exe ':cclose'
"
	let	l:arguments				= exists("b:Awk_ScriptCmdLineArgs") ? " ".b:Awk_ScriptCmdLineArgs : ""
	let	l:currentbuffer   = bufname("%")
	let l:fullname				= expand("%:p")
	let l:fullnameesc			= fnameescape( l:fullname )
	"
	silent exe ":update"

	let l:awkCmdLineArgs	= exists("b:Awk_AwkCmdLineArgs") ? ' '.b:Awk_AwkCmdLineArgs.' ' : ''

	if l:arguments =~ '^\s*$'
		echohl WarningMsg
		echomsg 'Script call has no file argument.'
		echohl None
	endif
	"
	"------------------------------------------------------------------------------
	"  Run : run from the vim command line (Linux only)
	"------------------------------------------------------------------------------
	"
	if s:Awk_OutputGvim == "vim"
		"
		" ----- normal mode ----------
		"
 		exe ':!'.s:Awk_Awk.l:awkCmdLineArgs." -f '".l:fullname."' ".l:arguments
		if &term == 'xterm'
			redraw!
		endif
		"
	endif
	"
	"------------------------------------------------------------------------------
	"  Run : redirect output to an output buffer
	"------------------------------------------------------------------------------
	if s:Awk_OutputGvim == "buffer"

		let	l:currentbuffernr = bufnr("%")

		if l:currentbuffer ==  bufname("%")
			"
			if bufloaded(s:Awk_OutputBufferName) != 0 && bufwinnr(s:Awk_OutputBufferNumber)!=-1
				exe bufwinnr(s:Awk_OutputBufferNumber) . "wincmd w"
				" buffer number may have changed, e.g. after a 'save as'
				if bufnr("%") != s:Awk_OutputBufferNumber
					let s:Awk_OutputBufferNumber	= bufnr(s:Awk_OutputBufferName)
					exe ":bn ".s:Awk_OutputBufferNumber
				endif
			else
				silent exe ":new ".s:Awk_OutputBufferName
				let s:Awk_OutputBufferNumber=bufnr("%")
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
					silent exe ":%!".s:Awk_Awk.l:awkCmdLineArgs.' -f "'.l:fullname.'" '.l:arguments
				else
					silent exe ":%!".s:Awk_Awk.l:awkCmdLineArgs." -f ".l:fullnameesc.l:arguments
				endif
			endif
			"
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
	"  Run : run in a detached xterm
	"------------------------------------------------------------------------------
	if s:Awk_OutputGvim == 'xterm'
		"
		if	s:MSWIN
			exe ':!'.s:Awk_Awk.l:awkCmdLineArgs.' -f "'.l:fullname.'" '.l:arguments
		else
			silent exe '!xterm -title '.l:fullnameesc.' '.s:Awk_XtermDefaults
						\			.' -e '.s:Awk_Wrapper.' '.l:awkCmdLineArgs.l:fullnameesc.l:arguments.' &'
		endif
		"
	endif
	"
	if !has("gui_running") &&  v:progname != 'vim'
		redraw!
	endif
endfunction    " ----------  end of function Awk_Run  ----------
"
"===  FUNCTION  ================================================================
"          NAME:  Awk_SyntaxCheck     {{{1
"   DESCRIPTION:  syntax check
"    PARAMETERS:  -
"       RETURNS:
"===============================================================================
function! Awk_SyntaxCheck ( check )
  exe ":cclose"
  let l:currentbuffer   = bufname("%")
	let l:fullname        = expand("%:p")
  silent exe  ":update"
  "
	let	l:arguments				= exists("b:Awk_ScriptCmdLineArgs") ? " ".b:Awk_ScriptCmdLineArgs : ""
	call s:Awk_SaveGlobalOption('errorformat')
	call s:Awk_SaveGlobalOption('makeprg')
	"
	if a:check == 'syntax'
		if s:MSWIN && ( l:fullname =~ ' '  )
			"
			let tmpfile = tempname()
			exe	':setlocal errorformat='.s:Awk_Errorformat
			silent exe  ":make -e 'BEGIN { exit(0) } END { exit(0) }' -f ".l:fullname
			exe ":cfile ".tmpfile
		else
			"
			" no whitespaces
			"
			exe	":setlocal makeprg=".s:Awk_Awk
			exe	':setlocal errorformat='.s:Awk_Errorformat
			let	l:fullname	= fnameescape( l:fullname )
			silent exe  ":make -e 'BEGIN { exit(0) } END { exit(0) }' -f ".l:fullname
		endif
	endif
	"
	if a:check == 'lint'
		if s:MSWIN && ( l:fullname =~ ' '  )
			"
			let tmpfile = tempname()
			exe	':setlocal errorformat='.s:Awk_Errorformat
			silent exe  ":make --lint -f ".l:fullname.' '.l:arguments
			exe ":cfile ".tmpfile
		else
			"
			" no whitespaces
			"
			exe	":setlocal makeprg=".s:Awk_Awk
			exe	':setlocal errorformat='.s:Awk_Errorformat
			let	l:fullname	= fnameescape( l:fullname )
			exe  ":make --lint -f ".l:fullname.' '.l:arguments
		endif
	endif

  exe ":botright cwindow"
	call s:Awk_RestoreGlobalOption('makeprg')
	call s:Awk_RestoreGlobalOption('errorformat')
  "
  " message in case of success
  "
	redraw!
	if l:currentbuffer ==  bufname("%")
		echohl Search
		if a:check == 'lint'
			echomsg l:currentbuffer." : lint check is OK"
		else
			echomsg l:currentbuffer." : Syntax is OK"
		endif
		echohl None
		return 0
	else
		setlocal wrap
		setlocal linebreak
	endif
endfunction   " ---------- end of function  Awk_SyntaxCheck  ----------

"===  FUNCTION  ================================================================
"          NAME:  Awk_MakeScriptExecutable     {{{1
"   DESCRIPTION:  make script executable
"    PARAMETERS:  -
"       RETURNS:
"===============================================================================
function! Awk_MakeScriptExecutable ()
	let filename	= expand("%:p")
	if executable(filename) == 0
		"
		" not executable -> executable
		"
		if Awk_Input( '"'.filename.'" NOT executable. Make it executable [y/n] : ', 'y' ) == 'y'
			silent exe "!chmod u+x ".shellescape(filename)
			if v:shell_error
				" confirmation for the user
				echohl WarningMsg
				echo 'Could not make "'.filename.'" executable!'
			else
				" reload the file, otherwise the message will not be visible
				if &autoread && ! &l:modified
					silent exe "edit"
				endif
				" confirmation for the user
				echohl Search
				echo 'Made "'.filename.'" executable.'
			endif
			echohl None
		endif
	else
		"
		" executable -> not executable
		"
		if Awk_Input( '"'.filename.'" is executable. Make it NOT executable [y/n] : ', 'y' ) == 'y'
			silent exe "!chmod u-x ".shellescape(filename)
			if v:shell_error
				" confirmation for the user
				echohl WarningMsg
				echo 'Could not make "'.filename.'" not executable!'
			else
				" reload the file, otherwise the message will not be visible
				if &autoread && ! &l:modified
					silent exe "edit"
				endif
				" confirmation for the user
				echohl Search
				echo 'Made "'.filename.'" not executable.'
			endif
			echohl None
		endif
	endif
endfunction   " ---------- end of function  Awk_MakeScriptExecutable  ----------

"----------------------------------------------------------------------
"  *** SETUP PLUGIN ***  {{{1
"----------------------------------------------------------------------

call Awk_ToolMenu()

if s:Awk_LoadMenus == 'yes' && s:Awk_CreateMenusDelayed == 'no'
	call Awk_CreateGuiMenus()
endif
"
if has( 'autocmd' )

  autocmd FileType *
        \ if &filetype == 'awk' |
        \   if ! exists( 'g:Awk_Templates' ) |
        \     if s:Awk_LoadMenus == 'yes' | call Awk_CreateGuiMenus ()  |
        \     else                        | call Awk_RereadTemplates () |
        \     endif |
        \   endif |
        \   call s:CreateAdditionalMaps () |
				\		call s:CheckTemplatePersonalization() |
        \ endif

  if s:Awk_InsertFileHeader == 'yes'
    autocmd BufNewFile  *.awk  call mmtemplates#core#InsertTemplate(g:Awk_Templates, 'Comments.file description')
  endif

endif
" }}}1
"
" =====================================================================================
" vim: tabstop=2 shiftwidth=2 foldmethod=marker
