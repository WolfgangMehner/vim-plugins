"#################################################################################
"
"       Filename:  perl-support.vim
"
"    Description:  perl-support.vim implements a Perl-IDE for Vim/gVim.  It is
"                  written to considerably speed up writing code in a consistent
"                  style.
"                  This is done by inserting complete statements, comments,
"                  idioms, code snippets, templates, comments and POD
"                  documentation.  Reading perldoc is integrated.  Syntax
"                  checking, running a script, starting a debugger and a
"                  profiler can be done by a keystroke.
"                  There a many additional hints and options which can improve
"                  speed and comfort when writing Perl. Please read the
"                  documentation.
"
"  Configuration:  There are at least some personal details which should be
"                   configured (see the files README.md and perlsupport.txt).
"
"   Dependencies:  perl           pod2man
"                  podchecker     pod2text
"                  pod2html       perldoc
"
"                  optional:
"
"                  Devel::FastProf      (profiler)
"                  Devel::NYTProf       (profiler)
"                  Devel::SmallProf     (profiler)
"                  Devel::ptkdb         (debugger frontend)
"                  Perl::Critic         (stylechecker)
"                  Perl::Tags::Naive    (generate Ctags style tags)
"                  Perl::Tidy           (beautifier)
"                  YAPE::Regex::Explain (regular expression analyzer)
"                  ddd                  (debugger frontend)
"                  sort(1)              (rearrange profiler statistics)
"
"         Author:  Wolfgang Mehner <wolfgang-mehner@web.de>
"                  Fritz Mehner <mehner.fritz@web.de>
"
"        Version:  see variable  g:Perl_PluginVersion  below
"        Created:  09.07.2001
"       Revision:  12.02.2017
"        License:  Copyright (c) 2001-2014, Fritz Mehner
"                  Copyright (c) 2015-2017, Wolfgang Mehner
"                  This program is free software; you can redistribute it
"                  and/or modify it under the terms of the GNU General Public
"                  License as published by the Free Software Foundation,
"                  version 2 of the License.
"                  This program is distributed in the hope that it will be
"                  useful, but WITHOUT ANY WARRANTY; without even the implied
"                  warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
"                  PURPOSE.
"                  See the GNU General Public License version 2 for more details.
"        Credits:  see perlsupport.txt
"-------------------------------------------------------------------------------

"-------------------------------------------------------------------------------
" === Basic checks ===   {{{1
"-------------------------------------------------------------------------------

" need at least 7.0
if v:version < 700
	echohl WarningMsg
	echo 'The plugin perl-support.vim needs Vim version >= 7.'
	echohl None
	finish
endif

" prevent duplicate loading
" need compatible
if exists("g:Perl_PluginVersion") || &cp
	finish
endif

let g:Perl_PluginVersion= "5.5pre"                  " version number of this script; do not change

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
" === Module setup ===   {{{1
"-------------------------------------------------------------------------------

"-------------------------------------------------------------------------------
" == Platform specific items ==   {{{2
"-------------------------------------------------------------------------------

let s:MSWIN = has("win16") || has("win32")   || has("win64")     || has("win95")
let s:UNIX  = has("unix")  || has("macunix") || has("win32unix")

let s:Perl_Executable         = ''                     " the Perl interpreter used
let s:Perl_Perl_is_executable = 0                      " the Perl interpreter used
let g:Perl_Installation				= '*undefined*'
let g:Perl_PluginDir					= ''
"
let s:Perl_GlobalTemplateFile	= ''
let s:Perl_LocalTemplateFile	= ''
let s:Perl_CustomTemplateFile = ''              " the custom templates
let g:Perl_FilenameEscChar 		= ''
"
let s:Perl_ToolboxDir					= []

if s:MSWIN
	" ==========  MS Windows  ======================================================

	let g:Perl_PluginDir = substitute( expand('<sfile>:p:h:h'), '\', '/', 'g' )

	" change '\' to '/' to avoid interpretation as escape character
	if match(	substitute( expand("<sfile>"), '\', '/', 'g' ),
				\		substitute( expand("$HOME"),   '\', '/', 'g' ) ) == 0
		" USER INSTALLATION ASSUMED
		let g:Perl_Installation				= 'local'
		let s:Perl_LocalTemplateFile	= g:Perl_PluginDir.'/perl-support/templates/Templates'
		let s:Perl_CustomTemplateFile = $HOME.'/vimfiles/templates/perl.templates'
		let s:Perl_ToolboxDir				 += [ g:Perl_PluginDir.'/autoload/mmtoolbox/' ]
	else
		" SYSTEM WIDE INSTALLATION
		let g:Perl_Installation				= 'system'
		let s:Perl_GlobalTemplateFile	= g:Perl_PluginDir.'/perl-support/templates/Templates'
		let s:Perl_LocalTemplateFile	= $HOME.'/vimfiles/perl-support/templates/Templates'
		let s:Perl_CustomTemplateFile = $HOME.'/vimfiles/templates/perl.templates'
		let s:Perl_ToolboxDir				 += [
					\	g:Perl_PluginDir.'/autoload/mmtoolbox/',
					\	$HOME.'/vimfiles/autoload/mmtoolbox/' ]
	endif

	let s:Perl_Executable           = 'C:/Perl/bin/perl.exe'
  let g:Perl_FilenameEscChar      = ''

else
	" ==========  Linux/Unix  ======================================================

	let g:Perl_PluginDir = expand("<sfile>:p:h:h")

	if match( expand("<sfile>"), resolve( expand("$HOME") ) ) == 0
		" USER INSTALLATION ASSUMED
		let g:Perl_Installation				= 'local'
		let s:Perl_LocalTemplateFile	= g:Perl_PluginDir.'/perl-support/templates/Templates'
		let s:Perl_CustomTemplateFile = $HOME.'/.vim/templates/perl.templates'
		let s:Perl_ToolboxDir				 += [ g:Perl_PluginDir.'/autoload/mmtoolbox/' ]
	else
		" SYSTEM WIDE INSTALLATION
		let g:Perl_Installation				= 'system'
		let s:Perl_GlobalTemplateFile	= g:Perl_PluginDir.'/perl-support/templates/Templates'
		let s:Perl_LocalTemplateFile	= $HOME.'/.vim/perl-support/templates/Templates'
		let s:Perl_CustomTemplateFile = $HOME.'/.vim/templates/perl.templates'
		let s:Perl_ToolboxDir				 += [
					\	g:Perl_PluginDir.'/autoload/mmtoolbox/',
					\	$HOME.'/.vim/autoload/mmtoolbox/' ]
	endif

	let s:Perl_Executable           = '/usr/bin/perl'
  let g:Perl_FilenameEscChar      = ' \%#[]'

  " ==============================================================================
endif

" g:Perl_CodeSnippets is used in autoload/perlsupportgui.vim
let s:Perl_CodeSnippets  				= g:Perl_PluginDir.'/perl-support/codesnippets/'
call s:ApplyDefaultSetting( 'Perl_CodeSnippets', s:Perl_CodeSnippets )

"-------------------------------------------------------------------------------
" == Various settings ==   {{{2
"-------------------------------------------------------------------------------

call s:ApplyDefaultSetting( 'Perl_PerlTags', 'off' )

"-------------------------------------------------------------------------------
" Use of dictionaries   {{{3
"
" - keyword completion is enabled by the function 's:CreateAdditionalMaps' below
"-------------------------------------------------------------------------------

if !exists("g:Perl_Dictionary_File")
	let g:Perl_Dictionary_File = g:Perl_PluginDir.'/perl-support/wordlists/perl.list'
endif

"-------------------------------------------------------------------------------
" User configurable options   {{{3
"-------------------------------------------------------------------------------

let s:Perl_LoadMenus             = 'yes'        " display the menus ?
let s:Perl_Ctrl_j                = 'yes'
let s:Perl_Ctrl_d                = 'yes'

let s:Perl_TimestampFormat       = '%Y%m%d.%H%M%S'

let s:Perl_PerlModuleList        = g:Perl_PluginDir.'/perl-support/modules/perl-modules.list'
let s:Perl_Debugger              = "perl"
let s:Perl_ProfilerTimestamp     = "no"
let s:Perl_LineEndCommColDefault = 49
let s:PerlStartComment					 = '#'
let s:Perl_PodcheckerWarnings    = "yes"
let s:Perl_PerlcriticOptions     = ""
let s:Perl_PerlcriticSeverity    = 3
let s:Perl_PerlcriticVerbosity   = 5
let s:Perl_Printheader           = "%<%f%h%m%<  %=%{strftime('%x %X')}     Page %N"
let s:Perl_GuiSnippetBrowser     = 'gui'										" gui / commandline
let s:Perl_CreateMenusDelayed    = 'yes'
let s:Perl_DirectRun             = 'no'

let s:Perl_InsertFileHeader			   = 'yes'
let s:Perl_Wrapper                 = g:Perl_PluginDir.'/perl-support/scripts/wrapper.sh'
let s:Perl_PerlModuleListGenerator = g:Perl_PluginDir.'/perl-support/scripts/pmdesc3.pl'
let s:Perl_PerltidyBackup			     = "no"
"
call s:ApplyDefaultSetting ( 'Perl_MapLeader', '' )
let s:Perl_RootMenu								= '&Perl'
"
let s:Perl_AdditionalTemplates    = mmtemplates#config#GetFt ( 'perl' )
let s:Perl_UseToolbox             = 'yes'
call s:ApplyDefaultSetting ( 'Perl_UseTool_make',    'yes' )

"-------------------------------------------------------------------------------
" Get user configuration   {{{3
"-------------------------------------------------------------------------------

call s:GetGlobalSetting('Perl_Executable','Perl_Perl')
call s:GetGlobalSetting('Perl_Executable')
call s:GetGlobalSetting('Perl_DirectRun')
call s:GetGlobalSetting('Perl_InsertFileHeader')
call s:GetGlobalSetting('Perl_CreateMenusDelayed')
call s:GetGlobalSetting('Perl_Ctrl_j')
call s:GetGlobalSetting('Perl_Ctrl_d')
call s:GetGlobalSetting('Perl_Debugger')
call s:GetGlobalSetting('Perl_GlobalTemplateFile')
call s:GetGlobalSetting('Perl_LocalTemplateFile')
call s:GetGlobalSetting('Perl_CustomTemplateFile')
call s:GetGlobalSetting('Perl_GuiSnippetBrowser')
call s:GetGlobalSetting('Perl_LineEndCommColDefault')
call s:GetGlobalSetting('Perl_LoadMenus')
call s:GetGlobalSetting('Perl_NYTProf_browser')
call s:GetGlobalSetting('Perl_NYTProf_html')
call s:GetGlobalSetting('Perl_PerlcriticOptions')
call s:GetGlobalSetting('Perl_PerlcriticSeverity')
call s:GetGlobalSetting('Perl_PerlcriticVerbosity')
call s:GetGlobalSetting('Perl_PerlModuleList')
call s:GetGlobalSetting('Perl_PerlModuleListGenerator')
call s:GetGlobalSetting('Perl_PerltidyBackup')
call s:GetGlobalSetting('Perl_PodcheckerWarnings')
call s:GetGlobalSetting('Perl_Printheader')
call s:GetGlobalSetting('Perl_ProfilerTimestamp')
call s:GetGlobalSetting('Perl_TimestampFormat')
call s:GetGlobalSetting('Perl_UseToolbox')

" initialize global variables, if they do not already exist

call s:ApplyDefaultSetting( "Perl_OutputGvim",'vim' )
call s:ApplyDefaultSetting( "Perl_PerlRegexSubstitution",'$~' )

"-------------------------------------------------------------------------------
" Xterm   {{{3
"-------------------------------------------------------------------------------

let s:Xterm_Executable   = 'xterm'
let s:Perl_XtermDefaults = '-fa courier -fs 12 -geometry 80x24'

" check 'g:Perl_XtermDefaults' for backwards compatibility
if ! exists ( 'g:Xterm_Options' )
	call s:GetGlobalSetting ( 'Perl_XtermDefaults' )
	" set default geometry if not specified
	if match( s:Perl_XtermDefaults, "-geometry\\s\\+\\d\\+x\\d\\+" ) < 0
		let s:Perl_XtermDefaults  = s:Perl_XtermDefaults." -geometry 80x24"
	endif
endif

call s:GetGlobalSetting ( 'Xterm_Executable' )
call s:ApplyDefaultSetting ( 'Xterm_Options', s:Perl_XtermDefaults )

"-------------------------------------------------------------------------------
" Control variables (not user configurable)   {{{3
"-------------------------------------------------------------------------------

" flags for perldoc
if has("gui_running")
  let s:Perl_perldoc_flags  = ""
else
  " display docs using plain text converter
  let s:Perl_perldoc_flags  = "-otext"
endif

" escape the printheader
let s:Perl_Printheader = escape( s:Perl_Printheader, ' %' )

" Perl executable and interface version
let s:Perl_Perl_is_executable = executable(s:Perl_Executable)
let s:Perl_InterfaceVersion   = ''

let s:Perl_MenuVisible 						= 'no'
let s:Perl_TemplateJumpTarget 		= ''

let s:MsgInsNotAvail							= "insertion not available for a fold"
let g:Perl_PerlRegexAnalyser			= 'no'
let g:Perl_InterfaceInitialized		= 'no'
let s:Perl_saved_global_option		= {}
"
let s:PCseverityName	= [ "DUMMY", "brutal", "cruel", "harsh", "stern", "gentle" ]
let s:PCverbosityName	= [ '1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11' ]

" }}}3
"-------------------------------------------------------------------------------

" }}}2
"-------------------------------------------------------------------------------

"------------------------------------------------------------------------------
"  Perl_SaveGlobalOption    {{{1
"  param 1 : option name
"  param 2 : characters to be escaped (optional)
"------------------------------------------------------------------------------
function! s:Perl_SaveGlobalOption ( option, ... )
	exe 'let escaped =&'.a:option
	if a:0 == 0
		let escaped	= escape( escaped, ' |"\' )
	else
		let escaped	= escape( escaped, ' |"\'.a:1 )
	endif
	let s:Perl_saved_global_option[a:option]	= escaped
endfunction    " ----------  end of function Perl_SaveGlobalOption  ----------
"
"------------------------------------------------------------------------------
"  Perl_RestoreGlobalOption    {{{1
"------------------------------------------------------------------------------
function! s:Perl_RestoreGlobalOption ( option )
	exe ':set '.a:option.'='.s:Perl_saved_global_option[a:option]
endfunction    " ----------  end of function Perl_RestoreGlobalOption  ----------
"
"===  FUNCTION  ================================================================
"          NAME:  Perl_GetLineEndCommCol     {{{1
"   DESCRIPTION:  get end-of-line comment position
"===============================================================================
function! Perl_GetLineEndCommCol ()
  let actcol  = virtcol(".")
  if actcol+1 == virtcol("$")
    let b:Perl_LineEndCommentColumn = ''
		while match( b:Perl_LineEndCommentColumn, '^\s*\d\+\s*$' ) < 0
			let b:Perl_LineEndCommentColumn = s:UserInput( 'start line-end comment at virtual column : ', actcol, '' )
		endwhile
  else
    let b:Perl_LineEndCommentColumn = virtcol(".")
  endif
  echomsg "line end comments will start at column  ".b:Perl_LineEndCommentColumn
endfunction   " ---------- end of function  Perl_GetLineEndCommCol  ----------
"
"===  FUNCTION  ================================================================
"          NAME:  Perl_EndOfLineComment     {{{1
"   DESCRIPTION:  apply single end-of-line comment
"===============================================================================
function! Perl_EndOfLineComment ( ) range
	if !exists("b:Perl_LineEndCommentColumn")
		let	b:Perl_LineEndCommentColumn	= s:Perl_LineEndCommColDefault
	endif
	" ----- trim whitespaces -----
	exe a:firstline.','.a:lastline.'s/\s*$//'

	for line in range( a:lastline, a:firstline, -1 )
		silent exe ":".line
		if getline(line) !~ '^\s*$'
			let linelength	= virtcol( [line, "$"] ) - 1
			let	diff				= 1
			if linelength < b:Perl_LineEndCommentColumn
				let diff	= b:Perl_LineEndCommentColumn -1 -linelength
			endif
			exe "normal!	".diff."A "
			call mmtemplates#core#InsertTemplate(g:Perl_Templates, 'Comments.end-of-line-comment')
		endif
	endfor
endfunction		" ---------- end of function  Perl_EndOfLineComment  ----------
"
"------------------------------------------------------------------------------
"  Perl_AlignLineEndComm: adjust line-end comments
"------------------------------------------------------------------------------
"
" patterns to ignore when adjusting line-end comments (incomplete):
" some heuristics used (only Perl can parse Perl)
let	s:AlignRegex	= [
	\	'\$#' ,
	\	"'\\%(\\\\'\\|[^']\\)*'"  ,
	\	'"\%(\\.\|[^"]\)*"'  ,
	\	'`[^`]\+`' ,
	\	'\%(m\|qr\)#[^#]\+#' ,
	\	'\%(m\|qr\)\?\([\?\/]\).*\1[imsxg]*'  ,
	\	'\%(m\|qr\)\([[:punct:]]\).*\2[imsxg]*'  ,
	\	'\%(m\|qr\){.*}[imsxg]*'  ,
	\	'\%(m\|qr\)(.*)[imsxg]*'  ,
	\	'\%(m\|qr\)\[.*\][imsxg]*'  ,
	\	'\%(s\|tr\)#[^#]\+#[^#]\+#' ,
	\	'\%(s\|tr\){[^}]\+}{[^}]\+}' ,
	\	]

"===  FUNCTION  ================================================================
"          NAME:  Perl_AlignLineEndComm     {{{1
"   DESCRIPTION:  align end-of-line comments
"===============================================================================
function! Perl_AlignLineEndComm ( ) range
	"
	" comment character (for use in regular expression)
	let cc = '#'                       " start of a Perl comment
	"
	" patterns to ignore when adjusting line-end comments (maybe incomplete):
 	let align_regex	= join( s:AlignRegex, '\|' )
	"
	" local position
	if !exists( 'b:Perl_LineEndCommentColumn' )
		let b:Perl_LineEndCommentColumn = s:Perl_LineEndCommColDefault
	endif
	let correct_idx = b:Perl_LineEndCommentColumn
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
endfunction		" ---------- end of function  Perl_AlignLineEndComm  ----------
"
let s:Perl_CmtCounter   = 0
let s:Perl_CmtLabel     = "BlockCommentNo_"
"
"===  FUNCTION  ================================================================
"          NAME:  Perl_CommentBlock     {{{1
"   DESCRIPTION:  set block of code within POD == begin / == end
"    PARAMETERS:  mode - curent edit mode
"===============================================================================
function! Perl_CommentBlock (mode)
  "
  let s:Perl_CmtCounter = 0
  let save_line         = line(".")
  let actual_line       = 0
  "
  " search for the maximum option number (if any)
  "
  normal! gg
  while actual_line < search( s:Perl_CmtLabel."\\d\\+" )
    let actual_line = line(".")
    let actual_opt  = matchstr( getline(actual_line), s:Perl_CmtLabel."\\d\\+" )
    let actual_opt  = strpart( actual_opt, strlen(s:Perl_CmtLabel),strlen(actual_opt)-strlen(s:Perl_CmtLabel))
    if s:Perl_CmtCounter < actual_opt
      let s:Perl_CmtCounter = actual_opt
    endif
  endwhile
  let s:Perl_CmtCounter = s:Perl_CmtCounter+1
  silent exe ":".save_line
  "
  if a:mode=='a'
    let zz=      "\n=begin  BlockComment  # ".s:Perl_CmtLabel.s:Perl_CmtCounter
    let zz= zz."\n\n=end    BlockComment  # ".s:Perl_CmtLabel.s:Perl_CmtCounter
    let zz= zz."\n\n=cut\n\n"
    put =zz
  endif

  if a:mode=='v'
    let zz=    "\n=begin  BlockComment  # ".s:Perl_CmtLabel.s:Perl_CmtCounter."\n\n"
    :'<put! =zz
    let zz=    "\n=end    BlockComment  # ".s:Perl_CmtLabel.s:Perl_CmtCounter
    let zz= zz."\n\n=cut\n\n"
    :'>put  =zz
  endif

endfunction    " ----------  end of function Perl_CommentBlock ----------
"
"===  FUNCTION  ================================================================
"          NAME:  Perl_UncommentBlock     {{{1
"   DESCRIPTION:  uncomment block of code (remove POD commands)
"===============================================================================
function! Perl_UncommentBlock ()

  let frstline  = searchpair( '^=begin\s\+BlockComment\s*#\s*'.s:Perl_CmtLabel.'\d\+',
      \                       '',
      \                       '^=end\s\+BlockComment\s\+#\s*'.s:Perl_CmtLabel.'\d\+',
      \                       'bn' )
  if frstline<=0
    echohl WarningMsg | echo 'no comment block/tag found or cursor not inside a comment block'| echohl None
    return
  endif
  let lastline  = searchpair( '^=begin\s\+BlockComment\s*#\s*'.s:Perl_CmtLabel.'\d\+',
      \                       '',
      \                       '^=end\s\+BlockComment\s\+#\s*'.s:Perl_CmtLabel.'\d\+',
      \                       'n' )
  if lastline<=0
    echohl WarningMsg | echo 'no comment block/tag found or cursor not inside a comment block'| echohl None
    return
  endif
  let actualnumber1  = matchstr( getline(frstline), s:Perl_CmtLabel."\\d\\+" )
  let actualnumber2  = matchstr( getline(lastline), s:Perl_CmtLabel."\\d\\+" )
  if actualnumber1 != actualnumber2
    echohl WarningMsg | echo 'lines '.frstline.', '.lastline.': comment tags do not match'| echohl None
    return
  endif

  let line1 = lastline
  let line2 = lastline
  " empty line before =end
  if match( getline(lastline-1), '^\s*$' ) != -1
    let line1 = line1-1
  endif
  if lastline+1<line("$") && match( getline(lastline+1), '^\s*$' ) != -1
    let line2 = line2+1
  endif
  if lastline+2<line("$") && match( getline(lastline+2), '^=cut' ) != -1
    let line2 = line2+1
  endif
  if lastline+3<line("$") && match( getline(lastline+3), '^\s*$' ) != -1
    let line2 = line2+1
  endif
  silent exe ':'.line1.','.line2.'d'

  let line1 = frstline
  let line2 = frstline
  if frstline>1 && match( getline(frstline-1), '^\s*$' ) != -1
    let line1 = line1-1
  endif
  if match( getline(frstline+1), '^\s*$' ) != -1
    let line2 = line2+1
  endif
  silent exe ':'.line1.','.line2.'d'

endfunction    " ----------  end of function Perl_UncommentBlock ----------
"
"===  FUNCTION  ================================================================
"          NAME:  Perl_CommentToggle     {{{1
"   DESCRIPTION:  toggle comment
"===============================================================================
function! Perl_CommentToggle () range
	let	comment=1									"
	for line in range( a:firstline, a:lastline )
		if match( getline(line), '^#') == -1					" no comment
			let comment = 0
			break
		endif
	endfor

	if comment == 0
			exe a:firstline.','.a:lastline."s/^/#/"
	else
			exe a:firstline.','.a:lastline."s/^#//"
	endif

endfunction    " ----------  end of function Perl_CommentToggle ----------
"
"===  FUNCTION  ================================================================
"          NAME:  Perl_CodeSnippet     {{{1
"   DESCRIPTION:  read / write / edit code sni
"    PARAMETERS:  mode - edit, read, write, writemarked, view
"===============================================================================
function! Perl_CodeSnippet(mode)
  if isdirectory(g:Perl_CodeSnippets)
    "
    " read snippet file, put content below current line
    "
    if a:mode == "read"
			if has("gui_running") && s:Perl_GuiSnippetBrowser == 'gui'
				let l:snippetfile=browse(0,"read a code snippet",g:Perl_CodeSnippets,"")
			else
				let	l:snippetfile=input("read snippet ", g:Perl_CodeSnippets, "file" )
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
			if has("gui_running") && s:Perl_GuiSnippetBrowser == 'gui'
				let l:snippetfile=browse(0,"edit a code snippet",g:Perl_CodeSnippets,"")
			else
				let	l:snippetfile=input("edit snippet ", g:Perl_CodeSnippets, "file" )
			endif
      if !empty(l:snippetfile)
        :execute "update! | split | edit ".l:snippetfile
      endif
    endif
    "
    " update current buffer / split window / view snippet file
    "
    if a:mode == "view"
			if has("gui_running") && s:Perl_GuiSnippetBrowser == 'gui'
				let l:snippetfile=browse(0,"view a code snippet",g:Perl_CodeSnippets,"")
			else
				let	l:snippetfile=input("view snippet ", g:Perl_CodeSnippets, "file" )
			endif
      if !empty(l:snippetfile)
        :execute "update! | split | view ".l:snippetfile
      endif
    endif
    "
    " write whole buffer or marked area into snippet file
    "
    if a:mode == "write" || a:mode == "writemarked"
			if has("gui_running") && s:Perl_GuiSnippetBrowser == 'gui'
				let l:snippetfile=browse(1,"write a code snippet",g:Perl_CodeSnippets,"")
			else
				let	l:snippetfile=input("write snippet ", g:Perl_CodeSnippets, "file" )
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
    echo "code snippet directory ".g:Perl_CodeSnippets." does not exist"
    echohl None
  endif
endfunction   " ---------- end of function  Perl_CodeSnippet  ----------
"
"------------------------------------------------------------------------------
"  Perl-Run : Perl_perldoc - lookup word under the cursor or ask
"------------------------------------------------------------------------------
"
let s:Perl_PerldocBufferName       = "PERLDOC"
let s:Perl_PerldocHelpBufferNumber = -1
let s:Perl_PerldocModulelistBuffer = -1
let s:Perl_PerldocSearchWord       = ""
let s:Perl_PerldocTry              = "module"
"
"===  FUNCTION  ================================================================
"          NAME:  Perl_perldoc     {{{1
"   DESCRIPTION:  Perl_perldoc - lookup word under the cursor or ask
"===============================================================================
function! Perl_perldoc()

  if( expand("%:p") == s:Perl_PerlModuleList )
    normal! 0
    let item=expand("<cWORD>")        			" WORD under the cursor
  else
		let cuc		= getline(".")[col(".") - 1]	" character under the cursor
    let item	= expand("<cword>")       		" word under the cursor
		if empty(item) || match( item, cuc ) == -1
			let item = s:UserInput("perldoc - module, function or FAQ keyword : ", '', '')
		endif
  endif

  "------------------------------------------------------------------------------
  "  replace buffer content with Perl documentation
  "------------------------------------------------------------------------------
  if item != ""
    "
    " jump to an already open PERLDOC window or create one
    "
    if bufloaded(s:Perl_PerldocBufferName) != 0 && bufwinnr(s:Perl_PerldocHelpBufferNumber) != -1
      exe bufwinnr(s:Perl_PerldocHelpBufferNumber) . "wincmd w"
      " buffer number may have changed, e.g. after a 'save as'
      if bufnr("%") != s:Perl_PerldocHelpBufferNumber
        let s:Perl_PerldocHelpBufferNumber=bufnr(s:Perl_OutputBufferName)
        exe ":bn ".s:Perl_PerldocHelpBufferNumber
      endif
    else
      exe ":new ".s:Perl_PerldocBufferName
      let s:Perl_PerldocHelpBufferNumber=bufnr("%")
      setlocal buftype=nofile
      setlocal noswapfile
      setlocal bufhidden=delete
      setlocal syntax=OFF
    endif

		let error_list = []

    " search order:  library module --> builtin function --> FAQ keyword
    "
    let delete_perldoc_errors = ""
    if s:UNIX && ( match( $shell, '\ccsh$' ) >= 0 )
			" not for csh, tcsh
      let delete_perldoc_errors = " 2>/dev/null"
    endif
    setlocal  modifiable

		" control repeated search

    if item == s:Perl_PerldocSearchWord
      " last item : search ring :
      if s:Perl_PerldocTry == 'module'
        let next  = 'function'
      endif
      if s:Perl_PerldocTry == 'function'
        let next  = 'faq'
      endif
      if s:Perl_PerldocTry == 'faq'
        let next  = 'module'
      endif
      let s:Perl_PerldocTry = next
    else
      " new item :
      let s:Perl_PerldocSearchWord  = item
      let s:Perl_PerldocTry         = 'module'
    endif
    "
    " module documentation
    if s:Perl_PerldocTry == 'module'
      let command=":%!perldoc  ".s:Perl_perldoc_flags." ".item.delete_perldoc_errors
      silent exe command
      if v:shell_error != 0
				let s:Perl_PerldocTry = 'function'
				if empty ( error_list) || error_list[-1] != getline ( 1 )
					let error_list += getline ( 1, '$' )
				endif
      endif
      if s:MSWIN
				call s:perl_RemoveSpecialCharacters()
			endif
    endif
    "
    " function documentation
    if s:Perl_PerldocTry == 'function'
      " -otext has to be ahead of -f and -q
      silent exe ":%!perldoc ".s:Perl_perldoc_flags." -f ".item.delete_perldoc_errors
      if v:shell_error != 0
				let s:Perl_PerldocTry = 'faq'
				if empty ( error_list) || error_list[-1] != getline ( 1 )
					let error_list += getline ( 1, '$' )
				endif
      endif
    endif
    "
    " FAQ documentation
    if s:Perl_PerldocTry == 'faq'
      silent exe ":%!perldoc ".s:Perl_perldoc_flags." -q ".item.delete_perldoc_errors
      if v:shell_error != 0
				let s:Perl_PerldocTry = 'error'
				if empty ( error_list) || error_list[-1] != getline ( 1 )
					let error_list += getline ( 1, '$' )
				endif
      endif
    endif
    "
    " no documentation found
    if s:Perl_PerldocTry == 'error'
			" delete into black hole register "_
			normal! gg"_dG
			let zz = "No documentation found for perl module, perl function or perl FAQ keyword\n"
						\ ."  '".item."'\n\n"
						\ ."perldoc reports:\n  "
						\ .join( error_list, "\n  " )
			silent put! = zz
			" delete into black hole register "_
			normal! G"_dd
			let s:Perl_PerldocTry        = 'module'
			let s:Perl_PerldocSearchWord = ""
    endif
    if s:UNIX
      " remove windows line ends
      silent! exe ":%s/\r$// | normal! gg"
    endif
    setlocal nomodifiable
    redraw!
		" highlight the headlines
		:match Search '^\S.*$'
		"
		" ---------- Add ':' to the keyword characters -------------------------------
		"            Tokens like 'File::Find' are recognized as one keyword
		setlocal iskeyword+=:
 		 noremap   <buffer>  <silent>  <S-F1>             :call Perl_perldoc()<CR>
 		inoremap   <buffer>  <silent>  <S-F1>        <C-C>:call Perl_perldoc()<CR>
  endif
endfunction   " ---------- end of function  Perl_perldoc  ----------
"
"===  FUNCTION  ================================================================
"          NAME:  Perl_RemoveSpecialCharacters     {{{1
"   DESCRIPTION:  remove <backspace><any character> in CYGWIN man(1) output
"                 remove           _<any character> in CYGWIN man(1) output
"===============================================================================
function! s:perl_RemoveSpecialCharacters ( )
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
endfunction		" ---------- end of function  s:perl_RemoveSpecialCharacters   ----------
"
"===  FUNCTION  ================================================================
"          NAME:  Perl_perldoc_show_module_list     {{{1
"   DESCRIPTION:  show module list
"===============================================================================
function! Perl_perldoc_show_module_list()
  if !filereadable(s:Perl_PerlModuleList)
    redraw!
    echohl WarningMsg | echo 'Have to create '.s:Perl_PerlModuleList.' for the first time:'| echohl None
    call Perl_perldoc_generate_module_list()
  endif
  "
  " jump to the already open buffer or create one
  "
  if bufexists(s:Perl_PerldocModulelistBuffer) && bufwinnr(s:Perl_PerldocModulelistBuffer)!=-1
    silent exe bufwinnr(s:Perl_PerldocModulelistBuffer) . "wincmd w"
  else
		:split
    exe ":view ".s:Perl_PerlModuleList
    let s:Perl_PerldocModulelistBuffer=bufnr("%")
    setlocal nomodifiable
    setlocal filetype=perl
    setlocal syntax=none
 		 noremap   <buffer>  <silent>  <S-F1>             :call Perl_perldoc()<CR>
 		inoremap   <buffer>  <silent>  <S-F1>        <C-C>:call Perl_perldoc()<CR>
  endif
  normal! gg
  redraw!
  if has("gui_running")
    echohl Search | echomsg 'use S-F1 to show a manual' | echohl None
  else
    echohl Search | echomsg 'use \hh in normal mode to show a manual' | echohl None
  endif
endfunction   " ---------- end of function  Perl_perldoc_show_module_list  ----------
"
"===  FUNCTION  ================================================================
"          NAME:  Perl_perldoc_generate_module_list     {{{1
"   DESCRIPTION:  generate module list
"===============================================================================
function! Perl_perldoc_generate_module_list()
	" save the module list, if any
	if filereadable( s:Perl_PerlModuleList )
		let	backupfile	= s:Perl_PerlModuleList.'.backup'
		if rename( s:Perl_PerlModuleList, backupfile ) != 0
			echomsg 'Could not rename "'.s:Perl_PerlModuleList.'" to "'.backupfile.'"'
		endif
	endif
	"
  echohl Search
  echo " ... generating Perl module list ... "
  if  s:MSWIN
    silent exe ":!".s:Perl_Executable." ".fnameescape(s:Perl_PerlModuleListGenerator)." > ".shellescape(s:Perl_PerlModuleList)
    silent exe ":!sort ".fnameescape(s:Perl_PerlModuleList)." /O ".fnameescape(s:Perl_PerlModuleList)
  else
		" direct STDOUT and STDERR to the module list file :
    silent exe ":!".s:Perl_Executable." ".shellescape(s:Perl_PerlModuleListGenerator)." -s &> ".s:Perl_PerlModuleList
  endif
	redraw!
  echo " DONE "
  echohl None
endfunction   " ---------- end of function  Perl_perldoc_generate_module_list  ----------
"
"===  FUNCTION  ================================================================
"          NAME:  Perl_Settings     {{{1
"   DESCRIPTION:  display various plugin settings
"    PARAMETERS:  -
"       RETURNS:
"===============================================================================
function! Perl_Settings ( verbose )

	if     s:MSWIN | let sys_name = 'Windows'
	elseif s:UNIX  | let sys_name = 'UN*X'
	else           | let sys_name = 'unknown' | endif

	call s:CheckPerltidy ()
	let perl_exe_status = s:Perl_Perl_is_executable ? '' : ' (not executable)'
	let perltidy_status = s:Perl_perltidy_module_executable == 'yes' ? '' : ' ('.s:perltidy_short_message.')'

  let txt = " Perl-Support settings\n\n"
	" template settings: macros, style, ...
	if exists ( 'g:Perl_Templates' )
		let txt .= '                   author :  "'.mmtemplates#core#ExpandText( g:Perl_Templates, '|AUTHOR|'       )."\"\n"
		let txt .= '                authorref :  "'.mmtemplates#core#ExpandText( g:Perl_Templates, '|AUTHORREF|'    )."\"\n"
		let txt .= '                    email :  "'.mmtemplates#core#ExpandText( g:Perl_Templates, '|EMAIL|'        )."\"\n"
		let txt .= '             organization :  "'.mmtemplates#core#ExpandText( g:Perl_Templates, '|ORGANIZATION|' )."\"\n"
		let txt .= '         copyright holder :  "'.mmtemplates#core#ExpandText( g:Perl_Templates, '|COPYRIGHT|'    )."\"\n"
		let txt .= '                  license :  "'.mmtemplates#core#ExpandText( g:Perl_Templates, '|LICENSE|'      )."\"\n"
		let txt .= '           template style :  "'.mmtemplates#core#Resource ( g:Perl_Templates, "style" )[0]."\"\n\n"
	else
		let txt .= "                templates :  -not loaded-\n\n"
	endif
	" plug-in installation
	let txt .= '      plugin installation :  '.g:Perl_Installation.' on '.sys_name."\n"
	" toolbox
	if s:Perl_UseToolbox == 'yes'
		let toollist = mmtoolbox#tools#GetList ( s:Perl_Toolbox )
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
	if exists ( 'g:Perl_Templates' )
		let [ templist, msg ] = mmtemplates#core#Resource ( g:Perl_Templates, 'template_list' )
		let sep  = "\n"."                             "
		let txt .=      "           template files :  "
					\ .join ( templist, sep )."\n"
	else
		let txt .= "           template files :  -not loaded-\n"
	endif
	let txt .=
				\  '       code snippets dir. :  '.s:Perl_CodeSnippets."\n"
	" ----- dictionaries ------------------------
  if !empty(g:Perl_Dictionary_File)
		let ausgabe= &dictionary
    let ausgabe = substitute( ausgabe, ",", ",\n                             + ", "g" )
    let txt     = txt."       dictionary file(s) :  ".ausgabe."\n"
  endif
	" ----- map leader, menus, file headers -----
	if a:verbose >= 1
		let	txt .= "\n"
					\ .'                mapleader :  "'.g:Perl_MapLeader."\"\n"
					\ .'     load menus / delayed :  "'.s:Perl_LoadMenus.'" / "'.s:Perl_CreateMenusDelayed."\"\n"
					\ .'       insert file header :  "'.s:Perl_InsertFileHeader."\"\n"
	endif
	let txt .= "\n"
	" ----- perlcritic --------------------------
	let txt .= "         perl interpreter :  ".s:Perl_Executable.perl_exe_status."\n"
	if executable("perlcritic")
		let txt .= "               perlcritic :  perlcritic -severity ".s:Perl_PerlcriticSeverity
					\ .' ['.s:PCseverityName[s:Perl_PerlcriticSeverity].']'
					\ ."  -verbosity ".s:Perl_PerlcriticVerbosity
					\ ."  ".s:Perl_PerlcriticOptions."\n"
	else
		let txt .= "               perlcritic :  perlcritic (not executable)\n"
	endif
	let txt .= "                 perltidy :  perltidy".perltidy_status."\n"
	if !empty(s:Perl_InterfaceVersion)
		let txt = txt."  Perl interface version  :  ".s:Perl_InterfaceVersion."\n"
	endif
	" ----- output ------------------------------
	if a:verbose >= 1
		let txt = txt."               direct run :  ".s:Perl_DirectRun."\n"
		let txt = txt."            output method :  ".g:Perl_OutputGvim."\n"
	endif
	if !s:MSWIN && a:verbose >= 1
		let txt = txt.'         xterm executable :  '.s:Xterm_Executable."\n"
		let txt = txt.'            xterm options :  '.g:Xterm_Options."\n"
	endif
	if a:verbose == 0
		let txt = txt."\n"
		let txt = txt."    Additional hot keys\n\n"
		let txt = txt."                Shift-F1  :  read perldoc (for word under cursor)\n"
		let txt = txt."                      F9  :  start a debugger (".s:Perl_Debugger.")\n"
		let txt = txt."                  Alt-F9  :  run syntax check          \n"
		let txt = txt."                 Ctrl-F9  :  run script                \n"
		let txt = txt."                Shift-F9  :  set command line arguments\n"
	endif
	let txt = txt."________________________________________________________________________________\n"
	let txt = txt."  Perl-Support, Version ".g:Perl_PluginVersion." / Wolfgang Mehner / wolfgang-mehner@web.de\n\n"

	if a:verbose == 2
		split PerlSupport_Settings.txt
		put = txt
	else
		echo txt
	endif
endfunction   " ---------- end of function  Perl_Settings  ----------
"
"===  FUNCTION  ================================================================
"          NAME:  Perl_SyntaxCheck     {{{1
"   DESCRIPTION:  syntax check
"    PARAMETERS:  -
"       RETURNS:
"===============================================================================
function! Perl_SyntaxCheck ()
 
	if !Perl_Check_Interpreter()
		return
	endif
  
  exe ":cclose"
  let l:currentbuffer   = bufname("%")
	let l:fullname        = expand("%:p")
  silent exe  ":update"
  "
  " avoid filtering the Perl output if the file name does not contain blanks:
  "
	call s:Perl_SaveGlobalOption('errorformat')
	call s:Perl_SaveGlobalOption('makeprg')
	"
	" Errorformat from compiler/perl.vim (VIM distribution).
	"
	exe ':set makeprg='.s:Perl_Executable.'\ -cW'
	exe ':set errorformat=
				\%-G%.%#had\ compilation\ errors.,
				\%-G%.%#syntax\ OK,
				\%m\ at\ %f\ line\ %l.,
				\%+A%.%#\ at\ %f\ line\ %l\\,%.%#,
				\%+C%.%#'
	silent exe  ':make  '. shellescape (l:fullname) 

	exe ":botright cwindow"
	call s:Perl_RestoreGlobalOption('makeprg')
	call s:Perl_RestoreGlobalOption('errorformat')
  "
  " message in case of success
  "
	redraw!
  if l:currentbuffer ==  bufname("%")
			echohl Search
			echomsg l:currentbuffer." : Syntax is OK"
			echohl None
    return 0
  else
    setlocal wrap
    setlocal linebreak
  endif
endfunction   " ---------- end of function  Perl_SyntaxCheck  ----------
"
"===  FUNCTION  ================================================================
"          NAME:  Perl_Toggle_Gvim_Xterm     {{{1
"   DESCRIPTION:  toggle output destination (vim/buffer/xterm)
"    PARAMETERS:  -
"       RETURNS:
"===============================================================================
function! Perl_Toggle_Gvim_Xterm ()

	let [ esc_mapl, err ] = mmtemplates#core#Resource ( g:Perl_Templates, 'escaped_mapleader' )
	if g:Perl_OutputGvim == "vim"
		exe "aunmenu  <silent>  ".s:Perl_RootMenu.'.&Run.&output:\ VIM->buffer->xterm'
		exe "amenu    <silent>  ".s:Perl_RootMenu.'.&Run.&output:\ BUFFER->xterm->vim<Tab>'.esc_mapl.'ro              :call Perl_Toggle_Gvim_Xterm()<CR>'
		let	g:Perl_OutputGvim	= "buffer"
	else
		if g:Perl_OutputGvim == "buffer"
			exe "aunmenu  <silent>  ".s:Perl_RootMenu.'.&Run.&output:\ BUFFER->xterm->vim'
			if (!s:MSWIN)
				exe "amenu    <silent>  ".s:Perl_RootMenu.'.&Run.&output:\ XTERM->vim->buffer<Tab>'.esc_mapl.'ro             :call Perl_Toggle_Gvim_Xterm()<CR>'
			else
				exe "amenu    <silent>  ".s:Perl_RootMenu.'.&Run.&output:\ VIM->buffer->xterm <Tab>'.esc_mapl.'ro           :call Perl_Toggle_Gvim_Xterm()<CR>'
			endif
			if (!s:MSWIN) && (!empty($DISPLAY))
				let	g:Perl_OutputGvim	= "xterm"
			else
				let	g:Perl_OutputGvim	= "vim"
			endif
		else
			" ---------- output : xterm -> gvim
			exe "aunmenu  <silent>  ".s:Perl_RootMenu.'.&Run.&output:\ XTERM->vim->buffer'
			exe "amenu    <silent>  ".s:Perl_RootMenu.'.&Run.&output:\ VIM->buffer->xterm<Tab>'.esc_mapl.'ro            :call Perl_Toggle_Gvim_Xterm()<CR>'
			let	g:Perl_OutputGvim	= "vim"
		endif
	endif
	echomsg "output destination is '".g:Perl_OutputGvim."'"

endfunction    " ----------  end of function Perl_Toggle_Gvim_Xterm ----------
"
"------------------------------------------------------------------------------
"  Command line arguments    {{{1
"------------------------------------------------------------------------------
function! Perl_ScriptCmdLineArguments ( ... )
	let	b:Perl_CmdLineArgs= join( a:000 )
endfunction		" ---------- end of function  Perl_ScriptCmdLineArguments  ----------
"
"------------------------------------------------------------------------------
"  Perl command line arguments       {{{1
"------------------------------------------------------------------------------
function! Perl_PerlCmdLineArguments ( ... )
	let	b:Perl_Switches	= join( a:000 )
endfunction    " ----------  end of function Perl_PerlCmdLineArguments ----------
"
let s:Perl_OutputBufferName   = "Perl-Output"
let s:Perl_OutputBufferNumber = -1
"
"------------------------------------------------------------------------------
"  Check if perl interpreter is executable       {{{1
"------------------------------------------------------------------------------
function! Perl_Check_Interpreter ()
	if !s:Perl_Perl_is_executable
		echohl WarningMsg
		echomsg '(possibly default) Perl interpreter "'.s:Perl_Executable.'" not executable'
		echohl None
		return 0
	endif
	return 1
endfunction    " ----------  end of function Perl_Check_Interpreter  ----------

"===  FUNCTION  ================================================================
"          NAME:  Perl_Run     {{{1
"   DESCRIPTION:  run the current buffer
"    PARAMETERS:  -
"       RETURNS:
"===============================================================================
function! Perl_Run ()
  
	if !Perl_Check_Interpreter()
		return
	endif

  if &filetype != "perl"
    echohl WarningMsg | echo expand("%:p").' seems not to be a Perl file' | echohl None
    return
  endif
  let buffername  = expand("%")
  if fnamemodify( s:Perl_PerlModuleList, ":p:t" ) == buffername || s:Perl_PerldocBufferName == buffername
    return
  endif
  "
  let l:currentbuffernr = bufnr("%")
  let l:arguments       = exists("b:Perl_CmdLineArgs") ? " ".b:Perl_CmdLineArgs : ""
  let l:switches        = exists("b:Perl_Switches") ? b:Perl_Switches.' ' : ""
  let l:currentbuffer   = bufname("%")
	let l:fullname				= expand("%:p")
  "
  silent exe ":update"
  silent exe ":cclose"
  "
  "------------------------------------------------------------------------------
  "  run : run from the vim command line
  "------------------------------------------------------------------------------
	if g:Perl_OutputGvim == "vim"
		"
		if executable(l:fullname) && s:Perl_DirectRun == 'yes'
			exe "!".shellescape(l:fullname).l:arguments
		else
			exe '!'.s:Perl_Executable.' '.l:switches.shellescape(l:fullname).l:arguments
		endif
		"
	endif
	"
	"------------------------------------------------------------------------------
	"  run : redirect output to an output buffer
	"------------------------------------------------------------------------------
	if g:Perl_OutputGvim == "buffer"
		let l:currentbuffernr = bufnr("%")
		if l:currentbuffer ==  bufname("%")
      "
      "
      if bufloaded(s:Perl_OutputBufferName) != 0 && bufwinnr(s:Perl_OutputBufferNumber) != -1
        exe bufwinnr(s:Perl_OutputBufferNumber) . "wincmd w"
        " buffer number may have changed, e.g. after a 'save as'
        if bufnr("%") != s:Perl_OutputBufferNumber
          let s:Perl_OutputBufferNumber=bufnr(s:Perl_OutputBufferName)
          exe ":bn ".s:Perl_OutputBufferNumber
        endif
      else
        silent exe ":new ".s:Perl_OutputBufferName
        let s:Perl_OutputBufferNumber=bufnr("%")
        setlocal buftype=nofile
        setlocal noswapfile
        setlocal syntax=none
        setlocal bufhidden=delete
        setlocal tabstop=8
      endif
      "
      " run script
      "
      setlocal  modifiable
      silent exe ":update"
		"
		if executable(l:fullname) && s:Perl_DirectRun == 'yes'
			exe "%!".shellescape(l:fullname).l:arguments
		else
			exe '%!'.s:Perl_Executable.' '.l:switches.shellescape(l:fullname).l:arguments
		endif
		"
      setlocal  nomodifiable
      "
			if winheight(winnr()) >= line("$")
				exe bufwinnr(l:currentbuffernr) . "wincmd w"
			endif
			"
    endif
  endif
  "
  "------------------------------------------------------------------------------
  "  run : run in a detached xterm  (not available for MS Windows)
  "------------------------------------------------------------------------------
	if g:Perl_OutputGvim == "xterm"
		"
		if  s:MSWIN
			" MSWIN : same as "vim"
			exe '!'.s:Perl_Executable.' '.l:switches.shellescape(l:fullname).l:arguments
		else
			" Linux
			if executable(l:fullname) == 1 && s:Perl_DirectRun == 'yes'
				silent exe '!'.s:Xterm_Executable.' -title '.shellescape(l:fullname).' '.g:Xterm_Options.' -e '.s:Perl_Wrapper.' '.shellescape(l:fullname).l:arguments
			else
				silent exe '!'.s:Xterm_Executable.' -title '.shellescape(l:fullname).' '.g:Xterm_Options.' -e '.s:Perl_Wrapper.' '.s:Perl_Executable.' '.l:switches.shellescape(l:fullname).l:arguments
			endif
			:redraw!
		endif
		"
	endif
  "
endfunction    " ----------  end of function Perl_Run  ----------
"
"===  FUNCTION  ================================================================
"          NAME:  Perl_Debugger     {{{1
"   DESCRIPTION:  start debugger
"    PARAMETERS:  -
"       RETURNS:
"===============================================================================
function! Perl_Debugger ()
  "
  silent exe  ":update"
  let l:arguments 	= exists("b:Perl_CmdLineArgs") ? " ".b:Perl_CmdLineArgs : ""
  let l:switches    = exists("b:Perl_Switches") ? b:Perl_Switches.' ' : ""
  let filename      = expand("%:p")
  "
  if  s:MSWIN
    let l:arguments = substitute( l:arguments, '^\s\+', ' ', '' )
    let l:arguments = substitute( l:arguments, '\s\+', "\" \"", 'g')
		let l:switches  = substitute( l:switches,  '^\s\+', ' ', '' )
		let l:switches  = substitute( l:switches,  '\s\+', "\" \"", 'g')
  endif
  "
  " debugger is ' perl -d ... '
  "
  if s:Perl_Debugger == "perl"

		if !Perl_Check_Interpreter()
			return
		endif
    if  s:MSWIN
      exe '!'. s:Perl_Executable .' -d '.shellescape( filename.l:arguments )
    else
      if has("gui_running") || &term == "xterm"
				silent exe '!'.s:Xterm_Executable.' '.g:Xterm_Options.' -e ' . s:Perl_Executable . l:switches .' -d '.shellescape(filename).l:arguments.' &'
      else
        silent exe '!clear; ' .s:Perl_Executable. l:switches . ' -d '.shellescape(filename).l:arguments
      endif
    endif
  endif
  "
  if v:windowid != 0
    "
    " grapical debugger is 'ptkdb', uses a PerlTk interface
    "
    if s:Perl_Debugger == "ptkdb"
      if  s:MSWIN
				exe '!perl -d:ptkdb "'.filename.l:arguments.'"'
      else
        silent exe '!perl -d:ptkdb  '.shellescape(filename).l:arguments.' &'
      endif
    endif
    "
    " debugger is 'ddd'  (not available for MS Windows); graphical front-end for GDB
    "
    if s:Perl_Debugger == "ddd" && !s:MSWIN
      if !executable("ddd")
        echohl WarningMsg
        echo 'ddd does not exist or is not executable!'
        echohl None
        return
      else
        silent exe '!ddd '.shellescape(filename).l:arguments.' &'
      endif
    endif
    "
  endif
  "
	redraw!
endfunction   " ---------- end of function  Perl_Debugger  ----------
"
"===  FUNCTION  ================================================================
"          NAME:  Perl_XtermSize     {{{1
"   DESCRIPTION:  read xterm geometry
"    PARAMETERS:  -
"       RETURNS:
"===============================================================================
function! Perl_XtermSize ()
  let regex = '-geometry\s\+\d\+x\d\+'
  let geom  = matchstr( g:Xterm_Options, regex )
  let geom  = matchstr( geom, '\d\+x\d\+' )
  let geom  = substitute( geom, 'x', ' ', "" )
	let answer = s:UserInput( "   xterm size (COLUMNS LINES) : ", geom )
	while match(answer, '^\s*\d\+\s\+\d\+\s*$' ) < 0
		let answer = s:UserInput( " + xterm size (COLUMNS LINES) : ", geom )
	endwhile
  let answer  = substitute( answer, '\s\+', "x", "" )           " replace inner whitespaces
  let g:Xterm_Options  = substitute( g:Xterm_Options, regex, "-geometry ".answer , "" )
endfunction   " ---------- end of function  Perl_XtermSize  ----------
"
"===  FUNCTION  ================================================================
"          NAME:  Perl_MakeScriptExecutable     {{{1
"   DESCRIPTION:  make script executable
"    PARAMETERS:  -
"       RETURNS:
"===============================================================================
function! Perl_MakeScriptExecutable ()
	let filename	= expand("%:p")
	if executable(filename) == 0
		"
		" not executable -> executable
		"
		if s:UserInput( '"'.filename.'" NOT executable. Make it executable [y/n] : ', 'y' ) == 'y'
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
		if s:UserInput( '"'.filename.'" is executable. Make it NOT executable [y/n] : ', 'y' ) == 'y'
			" reset all execution bits
			silent exe "!chmod  -x ".shellescape(filename)
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
endfunction   " ---------- end of function  Perl_MakeScriptExecutable  ----------
"
"===  FUNCTION  ================================================================
"          NAME:  Perl_PodCheck     {{{1
"   DESCRIPTION:  run POD checker
"    PARAMETERS:  -
"       RETURNS:
"===============================================================================
function! Perl_PodCheck ()
  exe ":cclose"
  let l:currentbuffer   = bufname("%")
  silent exe  ":update"
  "
  if s:Perl_PodcheckerWarnings == "no"
    let PodcheckerWarnings  = '-nowarnings '
  else
    let PodcheckerWarnings  = '-warnings '
  endif
	call s:Perl_SaveGlobalOption('makeprg')
  set makeprg=podchecker

	call s:Perl_SaveGlobalOption('errorformat')
  exe ':set errorformat=***\ %m\ at\ line\ %l\ in\ file\ %f'
	if  s:MSWIN
		silent exe  ':make '.PodcheckerWarnings.'"'.expand("%:p").'"'
	else
		silent exe  ':make '.PodcheckerWarnings.fnameescape( expand("%:p") )
	endif

  exe ":botright cwindow"
	call s:Perl_RestoreGlobalOption('makeprg')
	call s:Perl_RestoreGlobalOption('errorformat')
  "
  " message in case of success
  "
	redraw!
  if l:currentbuffer ==  bufname("%")
    echohl Search
    echomsg  l:currentbuffer." : POD syntax is OK"
    echohl None
    return 0
  endif
  return 1
endfunction   " ---------- end of function  Perl_PodCheck  ----------
"
"===  FUNCTION  ================================================================
"          NAME:  Perl_POD     {{{1
"   DESCRIPTION:  convert POD into html / man / text
"    PARAMETERS:  format - target format
"       RETURNS:
"===============================================================================
function! Perl_POD ( format )
	let	source			= expand("%:p")
	let	source_esc	= fnameescape( expand("%:p"),  )
	let target	  	= source.'.'.a:format
	let target_esc	= source_esc.'.'.a:format

  silent exe  ":update"
	if executable( 'pod2'.a:format )
		if  s:MSWIN
			if a:format=='html'
				silent exe  ':!pod2'.a:format.' "--infile='.source.'"  "--outfile='.target.'"'
			else
				silent exe  ':!pod2'.a:format.' "'.source.'" "'.target.'"'
			endif
		else
			if a:format=='html'
				silent exe  ':!pod2'.a:format.' --infile='.source_esc.' --outfile='.target_esc
			else
				silent exe  ':!pod2'.a:format.' '.source_esc.' '.target_esc
			endif
		endif
		redraw!
		echo  "file '".target."' generated"
	else
		redraw!
		echomsg 'Application "pod2'.a:format.'" does not exist or is not executable.'
	endif
endfunction   " ---------- end of function  Perl_POD  ----------

"===  FUNCTION  ================================================================
"          NAME:  s:CheckPerltidy   {{{1
"   DESCRIPTION:  check whether perltidy(1) is executable and correctly set up
"    PARAMETERS:  -
"       RETURNS:  -
"===============================================================================

let s:Perl_perltidy_startscript_executable = 'no'
let s:Perl_perltidy_module_executable      = 'no'

let s:perltidy_long_message = ''
let s:perltidy_short_message = ''

function! s:CheckPerltidy ()

  " check if perltidy start script is executable
  if s:Perl_perltidy_startscript_executable == 'no'
    if executable("perltidy")
      let s:Perl_perltidy_startscript_executable  = 'yes'
    else
      let s:perltidy_long_message = 'perltidy does not exist or is not executable!'
			let s:perltidy_short_message = 'not executable'
      return
    endif
  endif

  " check if perltidy module is executable
  " WORKAROUND: after upgrading Perl the module will no longer be found
  if s:Perl_perltidy_module_executable == 'no'
    let perltidy_version = system("perltidy -v")
    if match( perltidy_version, 'copyright\c' )      >= 0 &&
    \  match( perltidy_version, 'Steve\s\+Hancock' ) >= 0
      let s:Perl_perltidy_module_executable = 'yes'
    else
      let s:perltidy_long_message = 'The module Perl::Tidy can not be found! Please reinstall perltidy.'
			let s:perltidy_short_message = 'module Perl::Tidy not found'
      return
    endif
  endif
endfunction    " ----------  end of function s:CheckPerltidy  ----------

"===  FUNCTION  ================================================================
"          NAME:  Perl_Perltidy     {{{1
"   DESCRIPTION:  run perltidy(1) as a compiler
"    PARAMETERS:  mode - n:normal / v:visual
"       RETURNS:
"===============================================================================
function! Perl_Perltidy (mode)

  let Sou   = expand("%")               " name of the file in the current buffer
	if   (&filetype != 'perl') &&
				\ ( a:mode != 'v' || input( "'".Sou."' seems not to be a Perl file. Continue (y/n) : " ) != 'y' )
		echomsg "'".Sou."' seems not to be a Perl file."
		return
	endif

  " check if perltidy is available
	call s:CheckPerltidy ()

	if s:Perl_perltidy_module_executable != 'yes'
		echohl WarningMsg
		echo s:perltidy_long_message
		echohl None
		return
	endif

	" ----- normal mode ----------------
	if a:mode == "n"
		if s:UserInput( "reformat whole file [y/n/Esc] : ", "y", '' ) != "y"
			return
		endif
		if s:Perl_PerltidyBackup == 'yes'
			exe 'write! '.Sou.'.bak'
		endif
    silent exe  ":update"
    let pos1  = line(".")
    exe '%!perltidy'
    exe ':'.pos1
    echo 'File "'.Sou.'" reformatted.'
  endif
  " ----- visual mode ----------------
  if a:mode=="v"
    let pos1  = line("'<")
    let pos2  = line("'>")
		if s:Perl_PerltidyBackup == 'yes'
			exe pos1.','.pos2.':write! '.Sou.'.bak'
		endif
    silent exe pos1.','.pos2.'!perltidy'
    echo 'File "'.Sou.'" (lines '.pos1.'-'.pos2.') reformatted.'
  endif
  "
  if v:shell_error
    echohl WarningMsg
    echomsg 'perltidy reported error code '.v:shell_error.' !'
    echohl None
  endif
	"
  if filereadable("perltidy.ERR")
    echohl WarningMsg
    echo 'Perltidy detected an error when processing file "'.Sou.'". Please see file perltidy.ERR'
    echohl None
  endif
  "
endfunction   " ---------- end of function  Perl_Perltidy  ----------

"===  FUNCTION  ================================================================
"          NAME:  Perl_SaveWithTimestamp     {{{1
"   DESCRIPTION:  Save buffer with timestamp
"    PARAMETERS:  -
"       RETURNS:
"===============================================================================
function! Perl_SaveWithTimestamp ()
  let file   = fnameescape( expand("%") ) " name of the file in the current buffer
  if empty(file)
		" do we have a quickfix buffer : syntax errors / profiler report
		if &filetype == 'qf'
			let file	= getcwd().'/Quickfix-List'
		else
			redraw!
			echohl WarningMsg | echo " no file name " | echohl None
			return
		endif
  endif
  let file   = file.'.'.strftime(s:Perl_TimestampFormat)
  silent exe ":write ".file
  echomsg 'file "'.file.'" written'
endfunction   " ---------- end of function  Perl_SaveWithTimestamp  ----------
"
"===  FUNCTION  ================================================================
"          NAME:  Perl_Hardcopy     {{{1
"   DESCRIPTION:  print PostScript to file
"    PARAMETERS:  mode - n:normal / v:visual
"       RETURNS:
"===============================================================================
function! Perl_Hardcopy (mode)
  let outfile = expand("%")
  if empty(outfile)
    redraw!
    echohl WarningMsg | echo " no file name " | echohl None
    return
  endif
	let outdir	= getcwd()
	if outdir == substitute( s:Perl_PerlModuleList, '/[^/]\+$', '', '' ) || filewritable(outdir) != 2
		let outdir	= $HOME
	endif
	if  !s:MSWIN
		let outdir	= outdir.'/'
	endif

	let old_printheader=&printheader
	exe  ':set printheader='.s:Perl_Printheader
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
endfunction   " ---------- end of function  Perl_Hardcopy  ----------
"
"===  FUNCTION  ================================================================
"          NAME:  Perl_HelpPerlsupport     {{{1
"   DESCRIPTION:  display plugin help
"    PARAMETERS:  -
"       RETURNS:
"===============================================================================
function! Perl_HelpPerlsupport ()
  try
    :help perlsupport
  catch
    exe ':helptags '.g:Perl_PluginDir.'/doc'
    :help perlsupport
  endtry
endfunction    " ----------  end of function Perl_HelpPerlsupport ----------
"
"------------------------------------------------------------------------------
"  run : perlcritic
"------------------------------------------------------------------------------
"
" All formats consist of 2 parts:
"  1. the perlcritic message format
"  2. the trailing    '%+A%.%#\ at\ %f\ line\ %l%.%#'
" Part 1 rebuilds the original perlcritic message. This is done to make
" parsing of the messages easier.
" Part 2 captures errors from inside perlcritic if any.
" Some verbosity levels are treated equal to give quickfix the filename.
"
" verbosity rebuilt
"
let s:PCverbosityFormat1 	= 1
let s:PCverbosityFormat2 	= 2
let s:PCverbosityFormat3 	= 3
let s:PCverbosityFormat4 	= escape( '"%f:%l:%c:%m.  %e  (Severity: %s)\n"', '%' )
let s:PCverbosityFormat5 	= escape( '"%f:%l:%c:%m.  %e  (Severity: %s)\n"', '%' )
let s:PCverbosityFormat6 	= escape( '"%f:%l:%m, near ' . "'%r'." . '  (Severity: %s)\n"', '%' )
let s:PCverbosityFormat7 	= escape( '"%f:%l:%m, near ' . "'%r'." . '  (Severity: %s)\n"', '%' )
let s:PCverbosityFormat8 	= escape( '"%f:%l:%c:[%p] %m. (Severity: %s)\n"', '%' )
let s:PCverbosityFormat9 	= escape( '"%f:%l:[%p] %m, near ' . "'%r'" . '. (Severity: %s)\n"', '%' )
let s:PCverbosityFormat10	= escape( '"%f:%l:%c:%m.\n  %p (Severity: %s)\n%d\n"', '%' )
let s:PCverbosityFormat11	= escape( '"%f:%l:%m, near ' . "'%r'" . '.\n  %p (Severity: %s)\n%d\n"', '%' )
"
" parses output for different verbosity levels:
"
let s:PCInnerErrorFormat	= ',\%+A%.%#\ at\ %f\ line\ %l%.%#'
let s:PCerrorFormat1 			= '%f:%l:%c:%m'         . s:PCInnerErrorFormat
let s:PCerrorFormat2 			= '%f:\ (%l:%c)\ %m'    . s:PCInnerErrorFormat
let s:PCerrorFormat3 			= '%m\ at\ %f\ line\ %l'. s:PCInnerErrorFormat
let s:PCerrorFormat4 			= '%f:%l:%c:%m'         . s:PCInnerErrorFormat
let s:PCerrorFormat5 			= '%f:%l:%c:%m'         . s:PCInnerErrorFormat
let s:PCerrorFormat6 			= '%f:%l:%m'            . s:PCInnerErrorFormat
let s:PCerrorFormat7 			= '%f:%l:%m'            . s:PCInnerErrorFormat
let s:PCerrorFormat8 			= '%f:%l:%m'            . s:PCInnerErrorFormat
let s:PCerrorFormat9 			= '%f:%l:%m'            . s:PCInnerErrorFormat
let s:PCerrorFormat10			= '%f:%l:%m'            . s:PCInnerErrorFormat
let s:PCerrorFormat11			= '%f:%l:%m'            . s:PCInnerErrorFormat
"
"===  FUNCTION  ================================================================
"          NAME:  Perl_Perlcritic     {{{1
"   DESCRIPTION:  run perlcritic(1) liek a compiler
"    PARAMETERS:  -
"       RETURNS:
"===============================================================================
function! Perl_Perlcritic ()
  let l:currentbuffer = bufname("%")
  if &filetype != "perl"
    echohl WarningMsg | echo l:currentbuffer.' seems not to be a Perl file' | echohl None
    return
  endif
  if executable("perlcritic") == 0                  " not executable
    echohl WarningMsg | echo 'perlcritic not installed or not executable' | echohl None
    return
  endif
  let s:Perl_PerlcriticMsg = ""
  exe ":cclose"
  silent exe  ":update"
	"
	" check for a configuration file
	"
	let	perlCriticRcFile			= ''
	let	perlCriticRcFileUsed	= 'no'
	if exists("$PERLCRITIC")
		let	perlCriticRcFile	= $PERLCRITIC
	elseif filereadable( '.perlcriticrc' )
		let	perlCriticRcFile	= '.perlcriticrc'
	elseif filereadable( $HOME.'/.perlcriticrc' )
		let	perlCriticRcFile	= $HOME.'/.perlcriticrc'
	endif
	"
	" read severity and/or verbosity from the configuration file if specified
	"
	if perlCriticRcFile != ''
		for line in readfile(perlCriticRcFile)
			" default settings come before the first named block
			if line =~ '^\s*['
				break
			else
				let	list = matchlist( line, '^\s*severity\s*=\s*\([12345]\)' )
				if !empty(list)
					let s:Perl_PerlcriticSeverity	= list[1]
					let	perlCriticRcFileUsed	= 'yes'
				endif
				let	list = matchlist( line, '^\s*severity\s*=\s*\(brutal\|cruel\|harsh\|stern\|gentle\)' )
				if !empty(list)
					let s:Perl_PerlcriticSeverity	= index( s:PCseverityName, list[1] )
					let	perlCriticRcFileUsed	= 'yes'
				endif
				let	list = matchlist( line, '^\s*verbose\s*=\s*\(\d\+\)' )
				if !empty(list) && 1<= list[1] && list[1] <= 11
					let s:Perl_PerlcriticVerbosity	= list[1]
					let	perlCriticRcFileUsed	= 'yes'
				endif
			endif
		endfor
	endif
	"
  let perlcriticoptions	=
		  \      ' -severity '.s:Perl_PerlcriticSeverity
      \     .' -verbose '.eval("s:PCverbosityFormat".s:Perl_PerlcriticVerbosity)
      \     .' '.escape( s:Perl_PerlcriticOptions, g:Perl_FilenameEscChar )
      \     .' '
	"
	call s:Perl_SaveGlobalOption('errorformat')
  exe  ':set errorformat='.eval("s:PCerrorFormat".s:Perl_PerlcriticVerbosity)
	call s:Perl_SaveGlobalOption('makeprg')
	set makeprg=perlcritic
  "
	if  s:MSWIN
		silent exe ':make '.perlcriticoptions.'"'.expand("%:p").'"'
	else
		silent exe ':make '.perlcriticoptions.fnameescape( expand("%:p") )
	endif
  "
	redraw!
  exe ":botright cwindow"
	call s:Perl_RestoreGlobalOption('errorformat')
	call s:Perl_RestoreGlobalOption('makeprg')
  "
  " message in case of success
  "
	let sev_and_verb	= 'severity '.s:Perl_PerlcriticSeverity.
				\				      ' ['.s:PCseverityName[s:Perl_PerlcriticSeverity].']'.
				\							', verbosity '.s:Perl_PerlcriticVerbosity
	"
	let rcfile	= ''
	if perlCriticRcFileUsed == 'yes'
		let rcfile	= " ( configcfile '".perlCriticRcFile."' )"
	endif
  if l:currentbuffer ==  bufname("%")
		let s:Perl_PerlcriticMsg	= l:currentbuffer.' :  NO CRITIQUE, '.sev_and_verb.' '.rcfile
  else
    setlocal wrap
    setlocal linebreak
		let s:Perl_PerlcriticMsg	= 'perlcritic : '.sev_and_verb.rcfile
  endif
	redraw!
  echohl Search | echo s:Perl_PerlcriticMsg | echohl None
endfunction   " ---------- end of function  Perl_Perlcritic  ----------

"===  FUNCTION  ================================================================
"          NAME:  Perl_PerlcriticSeverityList     {{{1
"   DESCRIPTION:  perlcritic severity : callback function for completion
"    PARAMETERS:  ArgLead -
"                 CmdLine -
"                 CursorPos -
"       RETURNS:
"===============================================================================
function!	Perl_PerlcriticSeverityList ( ArgLead, CmdLine, CursorPos )
	return filter( copy( s:PCseverityName[1:] ), 'v:val =~ "\\<'.a:ArgLead.'\\w*"' )
endfunction    " ----------  end of function Perl_PerlcriticSeverityList  ----------

"===  FUNCTION  ================================================================
"          NAME:  Perl_PerlcriticVerbosityList     {{{1
"   DESCRIPTION:  perlcritic verbosity : callback function for completion
"    PARAMETERS:  ArgLead -
"                 CmdLine -
"                 CursorPos -
"       RETURNS:
"===============================================================================
function!	Perl_PerlcriticVerbosityList ( ArgLead, CmdLine, CursorPos )
	return filter( copy( s:PCverbosityName), 'v:val =~ "\\<'.a:ArgLead.'\\w*"' )
endfunction    " ----------  end of function Perl_PerlcriticVerbosityList  ----------

"===  FUNCTION  ================================================================
"          NAME:  Perl_GetPerlcriticSeverity     {{{1
"   DESCRIPTION:  perlcritic severity : used in command definition
"    PARAMETERS:  severity - perlcritic severity
"       RETURNS:
"===============================================================================
function! Perl_GetPerlcriticSeverity ( severity )
	let s:Perl_PerlcriticSeverity = 3                         " the default
	let	sev	= a:severity
	let sev	= substitute( sev, '^\s\+', '', '' )  	     			" remove leading whitespaces
	let sev	= substitute( sev, '\s\+$', '', '' )	       			" remove trailing whitespaces
	"
	if sev =~ '^\d$' && 1 <= sev && sev <= 5
		" parameter is numeric
		let s:Perl_PerlcriticSeverity = sev
		"
	elseif sev =~ '^\a\+$'
		" parameter is a word
		let	nr	= index( s:PCseverityName, tolower(sev) )
		if nr > 0
			let s:Perl_PerlcriticSeverity = nr
		endif
	else
		"
		echomsg "wrong argument '".a:severity."' / severity is set to ".s:Perl_PerlcriticSeverity
		return
	endif
	echomsg "perlcritic severity is set to ".s:Perl_PerlcriticSeverity
endfunction    " ----------  end of function Perl_GetPerlcriticSeverity  ----------
"
"===  FUNCTION  ================================================================
"          NAME:  Perl_PerlcriticSeverityInput
"   DESCRIPTION:  read perlcritic severity from the command line
"    PARAMETERS:  -
"       RETURNS:
"===============================================================================
function! Perl_PerlcriticSeverityInput ()
		let retval = input( "perlcritic severity  (current = '".s:PCseverityName[s:Perl_PerlcriticSeverity]."' / tab exp.): ", '', 'customlist,Perl_PerlcriticSeverityList' )
		redraw!
		call Perl_GetPerlcriticSeverity( retval )
	return
endfunction    " ----------  end of function Perl_PerlcriticSeverityInput  ----------
"
"===  FUNCTION  ================================================================
"          NAME:  Perl_GetPerlcriticVerbosity     {{{1
"   DESCRIPTION:  perlcritic verbosity : used in command definition
"    PARAMETERS:  verbosity - perlcritic verbosity
"       RETURNS:
"===============================================================================
function! Perl_GetPerlcriticVerbosity ( verbosity )
	let s:Perl_PerlcriticVerbosity = 4
	let	vrb	= a:verbosity
  let vrb	= substitute( vrb, '^\s\+', '', '' )  	     			" remove leading whitespaces
  let vrb	= substitute( vrb, '\s\+$', '', '' )	       			" remove trailing whitespaces
  if vrb =~ '^\d\{1,2}$' && 1 <= vrb && vrb <= 11
    let s:Perl_PerlcriticVerbosity = vrb
		echomsg "perlcritic verbosity is set to ".s:Perl_PerlcriticVerbosity
	else
		echomsg "wrong argument '".a:verbosity."' / perlcritic verbosity is set to ".s:Perl_PerlcriticVerbosity
  endif
endfunction    " ----------  end of function Perl_GetPerlcriticVerbosity  ----------
"
"===  FUNCTION  ================================================================
"          NAME:  Perl_PerlcriticVerbosityInput     {{{1
"   DESCRIPTION:  read perlcritic verbosity from the command line
"    PARAMETERS:  -
"       RETURNS:
"===============================================================================
function! Perl_PerlcriticVerbosityInput ()
		let retval = input( "perlcritic verbosity  (current = ".s:Perl_PerlcriticVerbosity." / tab exp.): ", '', 'customlist,Perl_PerlcriticVerbosityList' )
		redraw!
		call Perl_GetPerlcriticVerbosity( retval )
	return
endfunction    " ----------  end of function Perl_PerlcriticVerbosityInput  ----------
"
"===  FUNCTION  ================================================================
"          NAME:  Perl_GetPerlcriticOptions     {{{1
"   DESCRIPTION:  perlcritic options : used in command definition
"    PARAMETERS:  ... -
"       RETURNS:
"===============================================================================
function! Perl_GetPerlcriticOptions ( ... )
	let s:Perl_PerlcriticOptions = ""
	if a:0 > 0
		let s:Perl_PerlcriticOptions = a:1
	endif
endfunction    " ----------  end of function Perl_GetPerlcriticOptions  ----------
"
"===  FUNCTION  ================================================================
"          NAME:  Perl_PerlcriticOptionsInput     {{{1
"   DESCRIPTION:  read perlcritic options from the command line
"    PARAMETERS:  -
"       RETURNS:
"===============================================================================
function! Perl_PerlcriticOptionsInput ()
		let retval = input( "perlcritic options (current = '".s:Perl_PerlcriticOptions."'): " )
		redraw!
		call Perl_GetPerlcriticOptions( retval )
	return
endfunction    " ----------  end of function Perl_PerlcriticOptionsInput  ----------
"
"===  FUNCTION  ================================================================
"          NAME:  Perl_CreateGuiMenus     {{{1
"   DESCRIPTION:  create GUI menus immediate
"    PARAMETERS:  -
"       RETURNS:
"===============================================================================
function! Perl_CreateGuiMenus ()
  if s:Perl_MenuVisible != 'yes'
		aunmenu <silent> &Tools.Load\ Perl\ Support
    amenu   <silent> 40.1000 &Tools.-SEP100- :
    amenu   <silent> 40.1160 &Tools.Unload\ Perl\ Support :call Perl_RemoveGuiMenus()<CR>
		call s:RereadTemplates()
		call s:Perl_InitMenus ()
    let s:Perl_MenuVisible = 'yes'
  endif
endfunction    " ----------  end of function Perl_CreateGuiMenus  ----------
"
"------------------------------------------------------------------------------
"  === Templates API ===   {{{1
"------------------------------------------------------------------------------
"
"------------------------------------------------------------------------------
"  Perl_SetMapLeader   {{{2
"------------------------------------------------------------------------------
function! Perl_SetMapLeader ()
	if exists ( 'g:Perl_MapLeader' )
		call mmtemplates#core#SetMapleader ( g:Perl_MapLeader )
	endif
endfunction    " ----------  end of function Perl_SetMapLeader  ----------
"
"------------------------------------------------------------------------------
"  Perl_ResetMapLeader   {{{2
"------------------------------------------------------------------------------
function! Perl_ResetMapLeader ()
	if exists ( 'g:Perl_MapLeader' )
		call mmtemplates#core#ResetMapleader ()
	endif
endfunction    " ----------  end of function Perl_ResetMapLeader  ----------
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
	" setup template library
	"-------------------------------------------------------------------------------
	let g:Perl_Templates = mmtemplates#core#NewLibrary ( 'api_version', '1.0' )
	"
	" mapleader
	if empty ( g:Perl_MapLeader )
		call mmtemplates#core#Resource ( g:Perl_Templates, 'set', 'property', 'Templates::Mapleader', '\' )
	else
		call mmtemplates#core#Resource ( g:Perl_Templates, 'set', 'property', 'Templates::Mapleader', g:Perl_MapLeader )
	endif
	"
	" some metainfo
	call mmtemplates#core#Resource ( g:Perl_Templates, 'set', 'property', 'Templates::Wizard::PluginName',   'Perl' )
	call mmtemplates#core#Resource ( g:Perl_Templates, 'set', 'property', 'Templates::Wizard::FiletypeName', 'Perl' )
	call mmtemplates#core#Resource ( g:Perl_Templates, 'set', 'property', 'Templates::Wizard::FileCustomNoPersonal',   g:Perl_PluginDir.'/perl-support/rc/custom.templates' )
	call mmtemplates#core#Resource ( g:Perl_Templates, 'set', 'property', 'Templates::Wizard::FileCustomWithPersonal', g:Perl_PluginDir.'/perl-support/rc/custom_with_personal.templates' )
	call mmtemplates#core#Resource ( g:Perl_Templates, 'set', 'property', 'Templates::Wizard::FilePersonal',           g:Perl_PluginDir.'/perl-support/rc/personal.templates' )
	call mmtemplates#core#Resource ( g:Perl_Templates, 'set', 'property', 'Templates::Wizard::CustomFileVariable',     'g:Perl_CustomTemplateFile' )
	"
	" maps: special operations
	call mmtemplates#core#Resource ( g:Perl_Templates, 'set', 'property', 'Templates::RereadTemplates::Map', 'ntr' )
	call mmtemplates#core#Resource ( g:Perl_Templates, 'set', 'property', 'Templates::ChooseStyle::Map',     'nts' )
	call mmtemplates#core#Resource ( g:Perl_Templates, 'set', 'property', 'Templates::SetupWizard::Map',     'ntw' )
	"
	" syntax: comments
	call mmtemplates#core#ChangeSyntax ( g:Perl_Templates, 'comment', '§' )

	" property: file skeletons (use safe defaults here, more sensible settings are applied in the template library)
	call mmtemplates#core#Resource ( g:Perl_Templates, 'add', 'property', 'Perl::FileSkeleton::Script', 'Comments.file description pl' )
	call mmtemplates#core#Resource ( g:Perl_Templates, 'add', 'property', 'Perl::FileSkeleton::Module', 'Comments.file description pm' )
	call mmtemplates#core#Resource ( g:Perl_Templates, 'add', 'property', 'Perl::FileSkeleton::Test',   'Comments.file description t' )
	call mmtemplates#core#Resource ( g:Perl_Templates, 'add', 'property', 'Perl::FileSkeleton::POD',    '' )

	"-------------------------------------------------------------------------------
	" load template library
	"-------------------------------------------------------------------------------

	" global templates (global installation only)
	if g:Perl_Installation == 'system'
		call mmtemplates#core#ReadTemplates ( g:Perl_Templates, 'load', s:Perl_GlobalTemplateFile,
					\ 'name', 'global', 'map', 'ntg' )
	endif

	" local templates (optional for global installation)
	if g:Perl_Installation == 'system'
		call mmtemplates#core#ReadTemplates ( g:Perl_Templates, 'load', s:Perl_LocalTemplateFile,
					\ 'name', 'local', 'map', 'ntl', 'optional', 'hidden' )
	else
		call mmtemplates#core#ReadTemplates ( g:Perl_Templates, 'load', s:Perl_LocalTemplateFile,
					\ 'name', 'local', 'map', 'ntl' )
	endif

	" additional templates (optional)
	if ! empty ( s:Perl_AdditionalTemplates )
		call mmtemplates#core#AddCustomTemplateFiles ( g:Perl_Templates, s:Perl_AdditionalTemplates, "Perl's additional templates" )
	endif

	" personal templates (shared across template libraries) (optional, existence of file checked by template engine)
	call mmtemplates#core#ReadTemplates ( g:Perl_Templates, 'personalization',
				\ 'name', 'personal', 'map', 'ntp' )

	" custom templates (optional, existence of file checked by template engine)
	call mmtemplates#core#ReadTemplates ( g:Perl_Templates, 'load', s:Perl_CustomTemplateFile,
				\ 'name', 'custom', 'map', 'ntc', 'optional' )

	"-------------------------------------------------------------------------------
	" further setup
	"-------------------------------------------------------------------------------
	"
	" get the jump target for <CTRL-J>
	let s:Perl_TemplateJumpTarget = mmtemplates#core#Resource ( g:Perl_Templates, "jumptag" )[0]
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
				\ || mmtemplates#core#ExpandText ( g:Perl_Templates, '|AUTHOR|' ) != 'YOUR NAME'
				\ || s:Perl_InsertFileHeader != 'yes'
		return
	endif

	let s:DoneCheckTemplatePersonalization = 1

	let maplead = mmtemplates#core#Resource ( g:Perl_Templates, 'get', 'property', 'Templates::Mapleader' )[0]

	redraw
	call s:ImportantMsg ( 'The personal details are not set in the template library. Use the map "'.maplead.'ntw".' )

endfunction    " ----------  end of function s:CheckTemplatePersonalization  ----------

"-------------------------------------------------------------------------------
" s:CheckAndRereadTemplates : Make sure the templates are loaded.   {{{1
"-------------------------------------------------------------------------------
function! s:CheckAndRereadTemplates ()
	if ! exists ( 'g:Perl_Templates' )
		call s:RereadTemplates()
	endif
endfunction    " ----------  end of function s:CheckAndRereadTemplates  ----------

"-------------------------------------------------------------------------------
" s:InsertFileHeader : Insert a file header.   {{{1
"
" The type must be one for which a property exists:
"   Perl::FileSkeleton::<script_type>
"
" Parameters:
"   script_type - type (string)
"-------------------------------------------------------------------------------
function! s:InsertFileHeader ( script_type )
	call s:CheckAndRereadTemplates()

	" prevent insertion for a file generated from a some error
	if isdirectory(expand('%:p:h')) && s:Perl_InsertFileHeader == 'yes'
		let templ_s = mmtemplates#core#Resource ( g:Perl_Templates, 'get', 'property', 'Perl::FileSkeleton::'.a:script_type )[0]

		" insert templates in reverse order, always above the first line
		" the last one to insert (the first in the list), will determine the
		" placement of the cursor
		let templ_l = split ( templ_s, ';' )
		for i in range ( len(templ_l)-1, 0, -1 )
			exe 1
			if -1 != match ( templ_l[i], '^\s\+$' )
				put! =''
			else
				call mmtemplates#core#InsertTemplate ( g:Perl_Templates, templ_l[i], 'placement', 'above' )
			endif
		endfor
		if len(templ_l) > 0
			set modified
		endif
	endif
endfunction    " ----------  end of function s:InsertFileHeader  ----------

"-------------------------------------------------------------------------------
" s:HighlightJumpTargets : Highlight the jump targets.   {{{1
"-------------------------------------------------------------------------------
function! s:HighlightJumpTargets ()
	if s:Perl_Ctrl_j == 'yes'
		exe 'match Search /'.s:Perl_TemplateJumpTarget.'/'
	endif
endfunction    " ----------  end of function s:HighlightJumpTargets  ----------

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
	let match = search( s:Perl_TemplateJumpTarget, 'c' )
	if match > 0
		" remove the target
		call setline( match, substitute( getline('.'), s:Perl_TemplateJumpTarget, '', '' ) )
	else
		" try to jump behind parenthesis or strings in the current line
		if match( getline(".")[col(".") - 1], "[\]})\"'`]"  ) != 0
			call search( "[\]})\"'`]", '', line(".") )
		endif
		normal! l
	endif
	return ''
endfunction    " ----------  end of function s:JumpForward  ----------

"------------------------------------------------------------------------------
"  Check the perlcritic default severity and verbosity.
"------------------------------------------------------------------------------
silent call Perl_GetPerlcriticSeverity (s:Perl_PerlcriticSeverity)
silent call Perl_GetPerlcriticVerbosity(s:Perl_PerlcriticVerbosity)

"===  FUNCTION  ================================================================
"          NAME:  Perl_do_tags     {{{1
"   DESCRIPTION:  tag a new file with Perl::Tags::Naive
"    PARAMETERS:  filename -
"                 tagfile - name of the tag file
"       RETURNS:
"===============================================================================
function! Perl_do_tags(filename, tagfile)

	if g:Perl_PerlTags == 'on'

		perl <<PERL_DO_TAGS
		my $filename = VIM::Eval('a:filename');
		my $tagfile  = VIM::Eval('a:tagfile');

		if ( -e $filename ) {
			$naive_tagger->process(files => $filename, refresh=>1 );
			}

		VIM::SetOption("tags+=$tagfile");

		# of course, it may not even output, for example, if there's nothing new to process
		$naive_tagger->output( outfile => $tagfile );
PERL_DO_TAGS

	endif
endfunction    " ----------  end of function Perl_do_tags  ----------

"===  FUNCTION  ================================================================
"          NAME:  Perl_ModuleListFold     {{{1
"   DESCRIPTION:  compute foldlevel for a module list
"                 debug with "set debug=msg"
"    PARAMETERS:  lnum -
"       RETURNS:
"===============================================================================
function! Perl_ModuleListFold (lnum)
	let line1 		= split( getline(a:lnum-1), '::' )
	let line2 		= split( getline(a:lnum  ), '::' )
	let foldlevel	= 0

	if !empty(line1)
		while foldlevel < len(line1) && foldlevel < len(line2) && line1[foldlevel] == line2[foldlevel]
			let	foldlevel	+= 1
		endwhile
	endif

	return foldlevel
endfunction    " ----------  end of function Perl_ModuleListFold  ----------
"
"===  FUNCTION  ================================================================
"          NAME:  Perl_InitMenus     {{{1
"   DESCRIPTION:  initialize the hardcoded menu items
"    PARAMETERS:  -
"       RETURNS:
"===============================================================================
function! s:Perl_InitMenus ()
	"
	if ! has ( 'menu' )
		return
	endif
	"
	" Preparation
	call mmtemplates#core#CreateMenus ( 'g:Perl_Templates', s:Perl_RootMenu, 'do_reset' )
	"
	" get the mapleader (correctly escaped)
	let [ esc_mapl, err ] = mmtemplates#core#Resource ( g:Perl_Templates, 'escaped_mapleader' )
	"
	exe 'amenu '.s:Perl_RootMenu.'.Perl  <Nop>'
	exe 'amenu '.s:Perl_RootMenu.'.-Sep00- <Nop>'
	"
	"-------------------------------------------------------------------------------
	" menu headers
	"-------------------------------------------------------------------------------
	"
	call mmtemplates#core#CreateMenus ( 'g:Perl_Templates', s:Perl_RootMenu, 'sub_menu', '&Comments', 'priority', 500 )
 	" the other, automatically created menus go here; their priority is the standard priority 500
	call mmtemplates#core#CreateMenus ( 'g:Perl_Templates', s:Perl_RootMenu, 'sub_menu', 'S&nippets' , 'priority', 600 )
	call mmtemplates#core#CreateMenus ( 'g:Perl_Templates', s:Perl_RootMenu, 'sub_menu', '&Profiling', 'priority', 700 )
	call mmtemplates#core#CreateMenus ( 'g:Perl_Templates', s:Perl_RootMenu, 'sub_menu', '&Run'      , 'priority', 800 )
	if s:Perl_UseToolbox == 'yes' && mmtoolbox#tools#Property ( s:Perl_Toolbox, 'empty-menu' ) == 0
		call mmtemplates#core#CreateMenus ( 'g:Perl_Templates', s:Perl_RootMenu, 'sub_menu', '&Tool\ Box', 'priority', 900 )
	endif
	call mmtemplates#core#CreateMenus ( 'g:Perl_Templates', s:Perl_RootMenu, 'sub_menu', '&Help'     , 'priority', 1000 )
	"
  "===============================================================================================
  "----- Menu : Comments                              {{{2
  "===============================================================================================
	"
	let ahead = 'anoremenu <silent> '.s:Perl_RootMenu.'.&Comments.'
	let vhead = 'vnoremenu <silent> '.s:Perl_RootMenu.'.&Comments.'
	let ihead = 'inoremenu <silent> '.s:Perl_RootMenu.'.&Comments.'
	"
	exe ahead.'end-of-&line\ comment<Tab>'.esc_mapl.'cl                    :call Perl_EndOfLineComment()<CR>'
	exe vhead.'end-of-&line\ comment<Tab>'.esc_mapl.'cl                    :call Perl_EndOfLineComment()<CR>'
	exe ahead.'ad&just\ end-of-line\ com\.<Tab>'.esc_mapl.'cj              :call Perl_AlignLineEndComm()<CR>'
	exe vhead.'ad&just\ end-of-line\ com\.<Tab>'.esc_mapl.'cj              :call Perl_AlignLineEndComm()<CR>'
	exe ahead.'&set\ end-of-line\ com\.\ col\.<Tab>'.esc_mapl.'cs     <C-C>:call Perl_GetLineEndCommCol()<CR>'
  "
	exe ahead.'-Sep01-						<Nop>'
  exe ahead.'toggle\ &comment<Tab>'.esc_mapl.'cc         :call Perl_CommentToggle()<CR>j'
  exe ihead.'toggle\ &comment<Tab>'.esc_mapl.'cc    <C-C>:call Perl_CommentToggle()<CR>j'
	exe vhead.'toggle\ &comment<Tab>'.esc_mapl.'cc         :call Perl_CommentToggle()<CR>j'

  exe ahead.'comment\ &block<Tab>'.esc_mapl.'cb           :call Perl_CommentBlock("a")<CR>'
  exe ihead.'comment\ &block<Tab>'.esc_mapl.'cb      <C-C>:call Perl_CommentBlock("a")<CR>'
  exe vhead.'comment\ &block<Tab>'.esc_mapl.'cb      <C-C>:call Perl_CommentBlock("v")<CR>'
  exe ahead.'u&ncomment\ block<Tab>'.esc_mapl.'cub        :call Perl_UncommentBlock()<CR>'
	exe ahead.'-Sep02-						<Nop>'
	"
  "===============================================================================================
  "----- Menu : GENERATE MENU ITEMS FROM THE TEMPLATES                              {{{2
  "===============================================================================================
	call mmtemplates#core#CreateMenus ( 'g:Perl_Templates', s:Perl_RootMenu, 'do_templates' )
	"
  "===============================================================================================
  "----- Menu : Snippets                              {{{2
  "===============================================================================================
	"
	let	ahead	= 'anoremenu <silent> '.s:Perl_RootMenu.'.S&nippets.'
	let	vhead	= 'vnoremenu <silent> '.s:Perl_RootMenu.'.S&nippets.'
	let	ihead	= 'inoremenu <silent> '.s:Perl_RootMenu.'.S&nippets.'
	"
	if !empty(s:Perl_CodeSnippets)
		exe ahead.'&read\ code\ snippet<Tab>'.esc_mapl.'nr       :call Perl_CodeSnippet("read")<CR>'
		exe ihead.'&read\ code\ snippet<Tab>'.esc_mapl.'nr  <C-C>:call Perl_CodeSnippet("read")<CR>'
		exe ahead.'&view\ code\ snippet<Tab>'.esc_mapl.'nv       :call Perl_CodeSnippet("view")<CR>'
		exe ihead.'&view\ code\ snippet<Tab>'.esc_mapl.'nv  <C-C>:call Perl_CodeSnippet("view")<CR>'
		exe ahead.'&write\ code\ snippet<Tab>'.esc_mapl.'nw      :call Perl_CodeSnippet("write")<CR>'
		exe vhead.'&write\ code\ snippet<Tab>'.esc_mapl.'nw <C-C>:call Perl_CodeSnippet("writemarked")<CR>'
		exe ihead.'&write\ code\ snippet<Tab>'.esc_mapl.'nw <C-C>:call Perl_CodeSnippet("write")<CR>'
		exe ahead.'&edit\ code\ snippet<Tab>'.esc_mapl.'ne       :call Perl_CodeSnippet("edit")<CR>'
		exe ihead.'&edit\ code\ snippet<Tab>'.esc_mapl.'ne  <C-C>:call Perl_CodeSnippet("edit")<CR>'
		exe ahead.'-SepSnippets-                       :'
	endif
	"
	" templates: edit and reload templates, styles
	call mmtemplates#core#CreateMenus ( 'g:Perl_Templates', s:Perl_RootMenu, 'do_specials', 'specials_menu', 'Snippets'	)
	"
  "===============================================================================================
  "----- Menu : Profiling                             {{{2
  "===============================================================================================
	"
	let	ahead	= 'amenu <silent> '.s:Perl_RootMenu.'.&Profiling.'
	exe ahead.'&run\ SmallProf<Tab>'.esc_mapl.'rps                       :call perlsupportprofiling#Perl_Smallprof()<CR>'
 	exe ahead.'sort\ SmallProf\ report<Tab>'.esc_mapl.'rpss              :call perlsupportprofiling#Perl_SmallProfSortInput()<CR>'
	exe ahead.'open\ existing\ SmallProf\ results<Tab>'.esc_mapl.'rpso   :call perlsupportprofiling#Perl_Smallprof_OpenQuickfix()<CR>'
	exe ahead.'-Sep01-						<Nop>'
	"
	if !s:MSWIN
		exe ahead.'&run\ FastProf<Tab>'.esc_mapl.'rpf                      :call perlsupportprofiling#Perl_Fastprof()<CR>'
 		exe ahead.'sort\ FastProf\ report<Tab>'.esc_mapl.'rpfs             :call perlsupportprofiling#Perl_FastProfSortInput()<CR>'
		exe ahead.'open\ existing\ FastProf\ results<Tab>'.esc_mapl.'rpfo  :call perlsupportprofiling#Perl_FastProf_OpenQuickfix()<CR>'
		exe ahead.'-Sep02-						<Nop>'
	endif
	"
	exe ahead.'&run\ NYTProf<Tab>'.esc_mapl.'rpn                         :call perlsupportprofiling#Perl_NYTprof()<CR>'
	exe ahead.'show\ &HTML\ report<Tab>'.esc_mapl.'rph                   :call perlsupportprofiling#Perl_NYTprofReadHtml()<CR>'
	exe ahead.'open\ &CSV\ file<Tab>'.esc_mapl.'rpno                     :call perlsupportprofiling#Perl_NYTprofReadCSV("read","line")<CR>'
 	exe ahead.'sort\ NYTProf\ CSV\ report<Tab>'.esc_mapl.'rpns           :call perlsupportprofiling#Perl_SmallProfSortInput()<CR>'
	"
  "===============================================================================================
  "----- Menu : Run                             {{{2
  "===============================================================================================
	"
	let	ahead	= 'amenu <silent> '.s:Perl_RootMenu.'.&Run.'
	let	vhead	= 'vmenu <silent> '.s:Perl_RootMenu.'.&Run.'

	" ----- run, syntax check -----
  exe ahead.'update,\ &run\ script<Tab>'.esc_mapl.'rr\ \ <C-F9>         :call Perl_Run()<CR>'
  exe ahead.'update,\ check\ &syntax<Tab>'.esc_mapl.'rs\ \ <A-F9>       :call Perl_SyntaxCheck()<CR>'
  exe 'amenu '.s:Perl_RootMenu.'.&Run.cmd\.\ line\ &arg\.<Tab>'.esc_mapl.'ra\ \ <S-F9>  :PerlScriptArguments<Space>'
  exe 'amenu .'s:Perl_RootMenu.'.&Run.perl\ s&witches<Tab>'.esc_mapl.'rw                :PerlSwitches<Space>'

  " ----- set execution rights for user only ( user may be root ! ) -----
  if !s:MSWIN
    exe ahead.'make\ script\ &exe\./not\ exec\.<Tab>'.esc_mapl.'re              :call Perl_MakeScriptExecutable()<CR>'
  endif
  exe ahead.'start\ &debugger<Tab>'.esc_mapl.'rd\ \ <F9>                :call Perl_Debugger()<CR>'

	" ----- module list -----
  exe ahead.'-SEP2-                     :'
  exe ahead.'show\ &installed\ Perl\ modules<Tab>'.esc_mapl.'ri  :call Perl_perldoc_show_module_list()<CR>'
  exe ahead.'&generate\ Perl\ module\ list<Tab>'.esc_mapl.'rg    :call Perl_perldoc_generate_module_list()<CR><CR>'

	" ----- perltidy -----
  exe ahead.'-SEP4-                     :'
  exe ahead.'run\ perltid&y<Tab>'.esc_mapl.'ry                        :call Perl_Perltidy("n")<CR>'
  exe vhead.'run\ perltid&y<Tab>'.esc_mapl.'ry                   <C-C>:call Perl_Perltidy("v")<CR>'

	" ----- perlcritic -----
  exe ahead.'-SEP3-                     :'
  exe ahead.'run\ perl&critic<Tab>'.esc_mapl.'rpc                     :call Perl_Perlcritic()<CR>'

  " ----- submenu : perlcritic severity -----
	call mmtemplates#core#CreateMenus ( 'g:Perl_Templates', s:Perl_RootMenu, 'sub_menu', 'Run.perl&critic\ severity' )

  let levelnumber = 1
  for level in s:PCseverityName[1:]
    exe ahead.'perlcritic\ severity<Tab>'.esc_mapl.'rpcs.&'.level.'<Tab>(='.levelnumber.')    :call Perl_GetPerlcriticSeverity("'.level.'")<CR>'
    let levelnumber = levelnumber+1
  endfor

  " ----- submenu : perlcritic verbosity -----
	call mmtemplates#core#CreateMenus ( 'g:Perl_Templates', s:Perl_RootMenu, 'sub_menu', 'Run.perlcritic\ &verbosity' )

  for level in s:PCverbosityName
    exe ahead.'perlcritic\ &verbosity<Tab>'.esc_mapl.'rpcv.&'.level.'   :call Perl_GetPerlcriticVerbosity('.level.')<CR>'
  endfor
  exe ahead.'perlcritic\ &options<Tab>'.esc_mapl.'rpco                :call Perl_PerlcriticOptionsInput()<CR>'

  " ----- hardcopy, settings -----
  exe ahead.'-SEP5-                     :'
  exe ahead.'save\ buffer\ with\ &timestamp<Tab>'.esc_mapl.'rt        :call Perl_SaveWithTimestamp()<CR>'
  exe ahead.'&hardcopy\ to\ FILENAME\.ps<Tab>'.esc_mapl.'rh           :call Perl_Hardcopy("n")<CR>'
  exe vhead.'&hardcopy\ to\ FILENAME\.ps<Tab>'.esc_mapl.'rh      <C-C>:call Perl_Hardcopy("v")<CR>'
  exe ahead.'-SEP6-                     :'
  exe ahead.'settings\ and\ hot\ &keys<Tab>'.esc_mapl.'rk             :call Perl_Settings(0)<CR>'

  " ----- xterm -----
  if  !s:MSWIN
    exe ahead.'&xterm\ size<Tab>'.esc_mapl.'rx                          :call Perl_XtermSize()<CR>'
  endif
  if g:Perl_OutputGvim == "vim"
    exe ahead.'&output:\ VIM->buffer->xterm<Tab>'.esc_mapl.'ro          :call Perl_Toggle_Gvim_Xterm()<CR>'
  else
    if g:Perl_OutputGvim == "buffer"
      exe ahead.'&output:\ BUFFER->xterm->vim<Tab>'.esc_mapl.'ro        :call Perl_Toggle_Gvim_Xterm()<CR>'
    else
      exe ahead.'&output:\ XTERM->vim->buffer<Tab>'.esc_mapl.'ro        :call Perl_Toggle_Gvim_Xterm()<CR>'
    endif
  endif
	"
  "===============================================================================================
  "----- Menu : Tools                            {{{2
  "===============================================================================================
	"
	if s:Perl_UseToolbox == 'yes' && mmtoolbox#tools#Property ( s:Perl_Toolbox, 'empty-menu' ) == 0
		call mmtoolbox#tools#AddMenus ( s:Perl_Toolbox, s:Perl_RootMenu.'.&Tool\ Box' )
	endif
	"
  "===============================================================================================
  "----- Menu : Help                             {{{2
  "===============================================================================================
	"
	let	ahead	= 'anoremenu <silent> '.s:Perl_RootMenu.'.Help.'
	let	vhead	= 'vnoremenu <silent> '.s:Perl_RootMenu.'.Help.'
	let	ihead	= 'inoremenu <silent> '.s:Perl_RootMenu.'.Help.'
	"
	exe ahead.'read\ &perldoc<Tab>'.esc_mapl.'h                :call Perl_perldoc()<CR>'
	exe ihead.'read\ &perldoc<Tab>'.esc_mapl.'h           <C-C>:call Perl_perldoc()<CR>'
	exe ahead.'-SEP1-                              :'
	exe ahead.'&help\ (Perl-Support)<Tab>'.esc_mapl.'hp        :call Perl_HelpPerlsupport()<CR>'
	exe ihead.'&help\ (Perl-Support)<Tab>'.esc_mapl.'hp   <C-C>:call Perl_HelpPerlsupport()<CR>'
	"
  "===============================================================================================
  "----- Menu : Regex menu (items)                              {{{2
  "===============================================================================================
	"
  exe " noremenu      ".s:Perl_RootMenu.'.Rege&x.-SEP7-                               :'
  exe "amenu <silent> ".s:Perl_RootMenu.'.Rege&x.pick\ up\ &regex<Tab>'.esc_mapl.'xr          :call perlsupportregex#Perl_RegexPick( "Regexp", "n" )<CR>j'
  exe "amenu <silent> ".s:Perl_RootMenu.'.Rege&x.pick\ up\ s&tring<Tab>'.esc_mapl.'xs         :call perlsupportregex#Perl_RegexPick( "String", "n" )<CR>j'
  exe "amenu <silent> ".s:Perl_RootMenu.'.Rege&x.pick\ up\ &flag(s)<Tab>'.esc_mapl.'xf        :call perlsupportregex#Perl_RegexPickFlag( "n" )<CR>'
  exe "vmenu <silent> ".s:Perl_RootMenu.'.Rege&x.pick\ up\ &regex<Tab>'.esc_mapl.'xr     <C-C>:call perlsupportregex#Perl_RegexPick( "Regexp", "v" )<CR>'."'>j"
  exe "vmenu <silent> ".s:Perl_RootMenu.'.Rege&x.pick\ up\ s&tring<Tab>'.esc_mapl.'xs    <C-C>:call perlsupportregex#Perl_RegexPick( "String", "v" )<CR>'."'>j"
  exe "vmenu <silent> ".s:Perl_RootMenu.'.Rege&x.pick\ up\ &flag(s)<Tab>'.esc_mapl.'xf   <C-C>:call perlsupportregex#Perl_RegexPickFlag( "v" )<CR>'."'>j"
  "                                Menu
  exe "amenu <silent> ".s:Perl_RootMenu.'.Rege&x.&match<Tab>'.esc_mapl.'xm                     :call perlsupportregex#Perl_RegexVisualize( )<CR>'
  exe "amenu <silent> ".s:Perl_RootMenu.'.Rege&x.matc&h\ several\ targets<Tab>'.esc_mapl.'xmm  :call perlsupportregex#Perl_RegexMatchSeveral( )<CR>'
  exe "amenu <silent> ".s:Perl_RootMenu.'.Rege&x.&explain\ regex<Tab>'.esc_mapl.'xe            :call perlsupportregex#Perl_RegexExplain( "n" )<CR>'
  exe "vmenu <silent> ".s:Perl_RootMenu.'.Rege&x.&explain\ regex<Tab>'.esc_mapl.'xe       <C-C>:call perlsupportregex#Perl_RegexExplain( "v" )<CR>'
	"
  "===============================================================================================
  "----- Menu : POD menu (items)                              {{{2
  "===============================================================================================
	"
  exe "amenu          ".s:Perl_RootMenu.'.&POD.-SEP4-                  :'
  exe "amenu <silent> ".s:Perl_RootMenu.'.&POD.run\ &podchecker<Tab>'.esc_mapl.'pod  :call Perl_PodCheck()<CR>'
  exe "amenu <silent> ".s:Perl_RootMenu.'.&POD.POD\ ->\ &html<Tab>'.esc_mapl.'podh   :call Perl_POD("html")<CR>'
  exe "amenu <silent> ".s:Perl_RootMenu.'.&POD.POD\ ->\ &man<Tab>'.esc_mapl.'podm    :call Perl_POD("man")<CR>'
  exe "amenu <silent> ".s:Perl_RootMenu.'.&POD.POD\ ->\ &text<Tab>'.esc_mapl.'podt   :call Perl_POD("text")<CR>'
	"
	return
endfunction    " ----------  end of function s:Perl_InitMenus  ----------

"===  FUNCTION  ================================================================
"          NAME:  Perl_ToolMenu     {{{1
"   DESCRIPTION:  generate the tool menu item
"    PARAMETERS:  -
"       RETURNS:
"===============================================================================
function! Perl_ToolMenu ()
    amenu   <silent> 40.1000 &Tools.-SEP100- :
    amenu   <silent> 40.1160 &Tools.Load\ Perl\ Support :call Perl_CreateGuiMenus()<CR>
endfunction    " ----------  end of function Perl_ToolMenu  ----------

"===  FUNCTION  ================================================================
"          NAME:  Perl_RemoveGuiMenus     {{{1
"   DESCRIPTION:  remove the Perl menu
"    PARAMETERS:  -
"       RETURNS:
"===============================================================================
function! Perl_RemoveGuiMenus ()
  if s:Perl_MenuVisible == 'yes'
		exe "aunmenu <silent> ".s:Perl_RootMenu
    "
    aunmenu <silent> &Tools.Unload\ Perl\ Support
		call Perl_ToolMenu()
    "
    let s:Perl_MenuVisible = 'no'
  endif
endfunction    " ----------  end of function Perl_RemoveGuiMenus  ----------
"
"===  FUNCTION  ================================================================
"          NAME:  Perl_GetRegexSubstitution     {{{1
"   DESCRIPTION:  get regex control character replacements (2 characters)
"    PARAMETERS:  -
"===============================================================================
function! Perl_GetRegexSubstitution ()
	let retval	= input( "regex control character replacements (current = '".g:Perl_PerlRegexSubstitution."'): " )
	if strlen( retval ) == 2
		let	g:Perl_PerlRegexSubstitution	= retval
	endif
endfunction    " ----------  end of function Perl_GetRegexSubstitution  ----------
"
"===  FUNCTION  ================================================================
"          NAME:  Perl_InitializePerlInterface     {{{1
"   DESCRIPTION:  initialize the Perl interface
"    PARAMETERS:  -
"       RETURNS:
"===============================================================================
function! Perl_InitializePerlInterface( )
	if g:Perl_InterfaceInitialized == 'no'
		if has('perl')
			perl <<INITIALIZE_PERL_INTERFACE
			#
			use utf8;                                   # Perl pragma to enable/disable UTF-8 in source
			#
			# ---------------------------------------------------------------
			# find out the version of the Perl interface
			# ---------------------------------------------------------------
			VIM::DoCommand("let s:Perl_InterfaceVersion = \"$^V\"");
			VIM::DoCommand("let g:Perl_InterfaceInitialized = 'yes'");
			#
			# ---------------------------------------------------------------
			# Perl_RegexExplain (function)
			# try to load the regex analyzer module; report failure
			# ---------------------------------------------------------------
			eval { require YAPE::Regex::Explain };
			if ( !$@ ) {
				VIM::DoCommand("let g:Perl_PerlRegexAnalyser = 'yes'");
				}
			#
INITIALIZE_PERL_INTERFACE
		endif
	endif
endfunction    " ----------  end of function Perl_InitializePerlInterface  ----------

"-------------------------------------------------------------------------------
" s:CreateAdditionalMaps : Create additional maps.   {{{1
"-------------------------------------------------------------------------------
function! s:CreateAdditionalMaps ()

	" we allow this, since the default is 'off'
	if exists('g:Perl_Perltidy') && g:Perl_Perltidy == 'on' && executable("perltidy")
		setlocal equalprg='perltidy'
	endif

	" ---------- Perl dictionary -------------------------------------------------
	" This will enable keyword completion for Perl
	" using Vim's dictionary feature |i_CTRL-X_CTRL-K|.
	"
	if exists("g:Perl_Dictionary_File")
		silent! exe 'setlocal dictionary+='.g:Perl_Dictionary_File
	endif
	"
	"-------------------------------------------------------------------------------
	" USER DEFINED COMMANDS
	"-------------------------------------------------------------------------------
	"
	" ---------- commands : run -------------------------------------
  command! -nargs=* -complete=file PerlScriptArguments call Perl_ScriptCmdLineArguments(<q-args>)
  command! -nargs=* -complete=file PerlSwitches        call Perl_PerlCmdLineArguments(<q-args>)

	"
	" ---------- commands : perlcritic -------------------------------------
	command! -nargs=? CriticOptions         call Perl_GetPerlcriticOptions  (<f-args>)
	command! -nargs=1 -complete=customlist,Perl_PerlcriticSeverityList   CriticSeverity   call Perl_GetPerlcriticSeverity (<f-args>)
	command! -nargs=1 -complete=customlist,Perl_PerlcriticVerbosityList  CriticVerbosity  call Perl_GetPerlcriticVerbosity(<f-args>)
	"
	" ---------- commands : perlcritic -------------------------------------
	command! -nargs=1 RegexSubstitutions    call perlsupportregex#Perl_PerlRegexSubstitutions(<f-args>)
	"
	" ---------- commands : profiling -------------------------------------
	command! -nargs=1 -complete=customlist,perlsupportprofiling#Perl_SmallProfSortList SmallProfSort
				\ call  perlsupportprofiling#Perl_SmallProfSortQuickfix ( <f-args> )
	"
	if  !s:MSWIN
		command! -nargs=1 -complete=customlist,perlsupportprofiling#Perl_FastProfSortList FastProfSort
					\ call  perlsupportprofiling#Perl_FastProfSortQuickfix ( <f-args> )
	endif
	"
	command! -nargs=1 -complete=customlist,perlsupportprofiling#Perl_NYTProfSortList NYTProfSort
				\ call  perlsupportprofiling#Perl_NYTProfSortQuickfix ( <f-args> )
	"
	command! -nargs=0  NYTProfCSV call perlsupportprofiling#Perl_NYTprofReadCSV  ()
	"
	command! -nargs=0  NYTProfHTML call perlsupportprofiling#Perl_NYTprofReadHtml  ()
	"
	"-------------------------------------------------------------------------------
	" settings - local leader
	"-------------------------------------------------------------------------------
	if ! empty ( g:Perl_MapLeader )
		if exists ( 'g:maplocalleader' )
			let ll_save = g:maplocalleader
		endif
		let g:maplocalleader = g:Perl_MapLeader
	endif
	"
	" ---------- Key mappings : function keys ------------------------------------
	"
	"   Ctrl-F9   run script
	"    Alt-F9   run syntax check
	"  Shift-F9   set command line arguments
	"  Shift-F1   read Perl documentation
	" Vim (non-GUI) : shifted keys are mapped to their unshifted key !!!
	"
	if has("gui_running")
		"
		noremap    <buffer>  <silent>  <A-F9>             :call Perl_SyntaxCheck()<CR>
		inoremap   <buffer>  <silent>  <A-F9>        <C-C>:call Perl_SyntaxCheck()<CR>
		"
		noremap    <buffer>  <silent>  <C-F9>             :call Perl_Run()<CR>
		inoremap   <buffer>  <silent>  <C-F9>        <C-C>:call Perl_Run()<CR>
		"
		noremap    <buffer>            <S-F9>             :PerlScriptArguments<Space>
		inoremap   <buffer>            <S-F9>        <C-C>:PerlScriptArguments<Space>
		"
 		noremap    <buffer>  <silent>  <S-F1>             :call Perl_perldoc()<CR>
 		inoremap   <buffer>  <silent>  <S-F1>        <C-C>:call Perl_perldoc()<CR>
	endif
	"
	" ---------- plugin help -----------------------------------------------------
	"
	noremap    <buffer>  <silent>  <LocalLeader>h          :call Perl_perldoc()<CR>
	inoremap   <buffer>  <silent>  <LocalLeader>h     <C-C>:call Perl_perldoc()<CR>
	noremap    <buffer>  <silent>  <LocalLeader>hp         :call Perl_HelpPerlsupport()<CR>
	inoremap   <buffer>  <silent>  <LocalLeader>hp    <C-C>:call Perl_HelpPerlsupport()<CR>
	"
	" ----------------------------------------------------------------------------
	" Comments
	" ----------------------------------------------------------------------------
	"
	 noremap    <buffer>  <silent>  <LocalLeader>cl         :call Perl_EndOfLineComment()<CR>
	inoremap    <buffer>  <silent>  <LocalLeader>cl    <C-C>:call Perl_EndOfLineComment()<CR>
	"
	nnoremap    <buffer>  <silent>  <LocalLeader>cj         :call Perl_AlignLineEndComm()<CR>
	inoremap    <buffer>  <silent>  <LocalLeader>cj    <C-C>:call Perl_AlignLineEndComm()<CR>
	vnoremap    <buffer>  <silent>  <LocalLeader>cj         :call Perl_AlignLineEndComm()<CR>

	nnoremap    <buffer>  <silent>  <LocalLeader>cs         :call Perl_GetLineEndCommCol()<CR>

	nnoremap    <buffer>  <silent>  <LocalLeader>cc         :call Perl_CommentToggle()<CR>j
	vnoremap    <buffer>  <silent>  <LocalLeader>cc         :call Perl_CommentToggle()<CR>j

	nnoremap    <buffer>  <silent>  <LocalLeader>cb         :call Perl_CommentBlock("a")<CR>
	inoremap    <buffer>  <silent>  <LocalLeader>cb    <C-C>:call Perl_CommentBlock("a")<CR>
	vnoremap    <buffer>  <silent>  <LocalLeader>cb    <C-C>:call Perl_CommentBlock("v")<CR>
	nnoremap    <buffer>  <silent>  <LocalLeader>cub        :call Perl_UncommentBlock()<CR>
	"
	" ----------------------------------------------------------------------------
	" Snippets & Templates
	" ----------------------------------------------------------------------------
	"
	nnoremap    <buffer>  <silent>  <LocalLeader>nr         :call Perl_CodeSnippet("read")<CR>
	nnoremap    <buffer>  <silent>  <LocalLeader>nw         :call Perl_CodeSnippet("write")<CR>
	vnoremap    <buffer>  <silent>  <LocalLeader>nw    <Esc>:call Perl_CodeSnippet("writemarked")<CR>
	nnoremap    <buffer>  <silent>  <LocalLeader>ne         :call Perl_CodeSnippet("edit")<CR>
	nnoremap    <buffer>  <silent>  <LocalLeader>nv         :call Perl_CodeSnippet("view")<CR>
	"
	inoremap    <buffer>  <silent>  <LocalLeader>nr    <Esc>:call Perl_CodeSnippet("read")<CR>
	inoremap    <buffer>  <silent>  <LocalLeader>nw    <Esc>:call Perl_CodeSnippet("write")<CR>
	inoremap    <buffer>  <silent>  <LocalLeader>ne    <Esc>:call Perl_CodeSnippet("edit")<CR>
	inoremap    <buffer>  <silent>  <LocalLeader>nv    <Esc>:call Perl_CodeSnippet("view")<CR>
	"
	"
	" ----------------------------------------------------------------------------
	" Regex
	" ----------------------------------------------------------------------------
	"
	nnoremap    <buffer>  <silent>  <LocalLeader>xr        :call perlsupportregex#Perl_RegexPick( "Regexp", "n" )<CR>j
	nnoremap    <buffer>  <silent>  <LocalLeader>xs        :call perlsupportregex#Perl_RegexPick( "String", "n" )<CR>j
	nnoremap    <buffer>  <silent>  <LocalLeader>xf        :call perlsupportregex#Perl_RegexPickFlag( "n" )<CR>
	vnoremap    <buffer>  <silent>  <LocalLeader>xr   <C-C>:call perlsupportregex#Perl_RegexPick( "Regexp", "v" )<CR>'>j
	vnoremap    <buffer>  <silent>  <LocalLeader>xs   <C-C>:call perlsupportregex#Perl_RegexPick( "String", "v" )<CR>'>j
	vnoremap    <buffer>  <silent>  <LocalLeader>xf   <C-C>:call perlsupportregex#Perl_RegexPickFlag( "v" )<CR>'>j
	nnoremap    <buffer>  <silent>  <LocalLeader>xm        :call perlsupportregex#Perl_RegexVisualize( )<CR>
	nnoremap    <buffer>  <silent>  <LocalLeader>xmm       :call perlsupportregex#Perl_RegexMatchSeveral( )<CR>
	nnoremap    <buffer>  <silent>  <LocalLeader>xe        :call perlsupportregex#Perl_RegexExplain( "n" )<CR>
	vnoremap    <buffer>  <silent>  <LocalLeader>xe   <C-C>:call perlsupportregex#Perl_RegexExplain( "v" )<CR>
	"
	"
	" ----------------------------------------------------------------------------
	" POD
	" ----------------------------------------------------------------------------
	"
	nnoremap    <buffer>  <silent>  <LocalLeader>pod        :call Perl_PodCheck()<CR>
	nnoremap    <buffer>  <silent>  <LocalLeader>podh       :call Perl_POD('html')<CR>
	nnoremap    <buffer>  <silent>  <LocalLeader>podm       :call Perl_POD('man')<CR>
	nnoremap    <buffer>  <silent>  <LocalLeader>podt       :call Perl_POD('text')<CR>
	"
	inoremap    <buffer>  <silent>  <LocalLeader>pod   <Esc>:call Perl_PodCheck()<CR>
	inoremap    <buffer>  <silent>  <LocalLeader>podh  <Esc>:call Perl_POD('html')<CR>
	inoremap    <buffer>  <silent>  <LocalLeader>podm  <Esc>:call Perl_POD('man')<CR>
	inoremap    <buffer>  <silent>  <LocalLeader>podt  <Esc>:call Perl_POD('text')<CR>
	"
	" ----------------------------------------------------------------------------
	" Profiling
	" ----------------------------------------------------------------------------
	"
	nnoremap    <buffer>  <silent>  <LocalLeader>rps         :call perlsupportprofiling#Perl_Smallprof()<CR>
	inoremap    <buffer>  <silent>  <LocalLeader>rps    <C-C>:call perlsupportprofiling#Perl_Smallprof()<CR>
	nnoremap    <buffer>  <silent>  <LocalLeader>rpss        :call perlsupportprofiling#Perl_SmallProfSortInput()<CR>
	inoremap    <buffer>  <silent>  <LocalLeader>rpss   <C-C>:call perlsupportprofiling#Perl_SmallProfSortInput()<CR>

	nnoremap    <buffer>  <silent>  <LocalLeader>rpf         :call perlsupportprofiling#Perl_Fastprof()<CR>
	inoremap    <buffer>  <silent>  <LocalLeader>rpf    <C-C>:call perlsupportprofiling#Perl_Fastprof()<CR>
	nnoremap    <buffer>  <silent>  <LocalLeader>rpfs        :call perlsupportprofiling#Perl_FastProfSortInput()<CR>
	inoremap    <buffer>  <silent>  <LocalLeader>rpfs   <C-C>:call perlsupportprofiling#Perl_FastProfSortInput()<CR>

	nnoremap    <buffer>  <silent>  <LocalLeader>rpn         :call perlsupportprofiling#Perl_NYTprof()<CR>
	nnoremap    <buffer>  <silent>  <LocalLeader>rpnc        :call perlsupportprofiling#Perl_NYTprofReadCSV("read","line")<CR>
	nnoremap    <buffer>  <silent>  <LocalLeader>rpns        :call perlsupportprofiling#Perl_NYTProfSortInput()<CR>
	nnoremap    <buffer>  <silent>  <LocalLeader>rpnh        :call perlsupportprofiling#Perl_NYTprofReadHtml()<CR>
	"
	inoremap    <buffer>  <silent>  <LocalLeader>rpn    <C-C>:call perlsupportprofiling#Perl_NYTprof()<CR>
	inoremap    <buffer>  <silent>  <LocalLeader>rpnc   <C-C>:call perlsupportprofiling#Perl_NYTprofReadCSV("read","line")<CR>
	inoremap    <buffer>  <silent>  <LocalLeader>rpns   <C-C>:call perlsupportprofiling#Perl_NYTProfSortInput()<CR>
	inoremap    <buffer>  <silent>  <LocalLeader>rpnh   <C-C>:call perlsupportprofiling#Perl_NYTprofReadHtml()<CR>
	"
	" ----------------------------------------------------------------------------
	" Run
	" ----------------------------------------------------------------------------
	"
	noremap    <buffer>  <silent>  <LocalLeader>rr         :call Perl_Run()<CR>
	noremap    <buffer>  <silent>  <LocalLeader>rs         :call Perl_SyntaxCheck()<CR>
	noremap    <buffer>            <LocalLeader>ra         :PerlScriptArguments<Space>
	noremap    <buffer>            <LocalLeader>rw         :PerlSwitches<Space>
	"
	inoremap    <buffer>  <silent>  <LocalLeader>rr    <C-C>:call Perl_Run()<CR>
	inoremap    <buffer>  <silent>  <LocalLeader>rs    <C-C>:call Perl_SyntaxCheck()<CR>
	inoremap    <buffer>            <LocalLeader>ra    <C-C>:PerlScriptArguments<Space>
	inoremap    <buffer>            <LocalLeader>rw    <C-C>:PerlSwitches<Space>
	"
	noremap    <buffer>  <silent>  <LocalLeader>rd    :call Perl_Debugger()<CR>
	noremap    <buffer>  <silent>    <F9>             :call Perl_Debugger()<CR>
	inoremap   <buffer>  <silent>    <F9>        <C-C>:call Perl_Debugger()<CR>
	"
	if s:UNIX
		 noremap    <buffer>  <silent>  <LocalLeader>re         :call Perl_MakeScriptExecutable()<CR>
		inoremap    <buffer>  <silent>  <LocalLeader>re    <C-C>:call Perl_MakeScriptExecutable()<CR>
	endif
	"
	noremap    <buffer>  <silent>  <LocalLeader>ri         :call Perl_perldoc_show_module_list()<CR>
	noremap    <buffer>  <silent>  <LocalLeader>rg         :call Perl_perldoc_generate_module_list()<CR>
	"
	noremap    <buffer>  <silent>  <LocalLeader>ry         :call Perl_Perltidy("n")<CR>
	vnoremap    <buffer>  <silent>  <LocalLeader>ry    <C-C>:call Perl_Perltidy("v")<CR>
	"
	noremap    <buffer>  <silent>  <LocalLeader>rpc        :call Perl_Perlcritic()<CR>
	noremap    <buffer>  <silent>  <LocalLeader>rt         :call Perl_SaveWithTimestamp()<CR>
	noremap    <buffer>  <silent>  <LocalLeader>rh         :call Perl_Hardcopy("n")<CR>
	vnoremap    <buffer>  <silent>  <LocalLeader>rh    <C-C>:call Perl_Hardcopy("v")<CR>
	"
	noremap    <buffer>  <silent>  <LocalLeader>rk    :call Perl_Settings(0)<CR>
	"
	inoremap    <buffer>  <silent>  <LocalLeader>ri    <C-C>:call Perl_perldoc_show_module_list()<CR>
	inoremap    <buffer>  <silent>  <LocalLeader>rg    <C-C>:call Perl_perldoc_generate_module_list()<CR>
	inoremap    <buffer>  <silent>  <LocalLeader>ry    <C-C>:call Perl_Perltidy("n")<CR>
	inoremap    <buffer>  <silent>  <LocalLeader>rpc   <C-C>:call Perl_Perlcritic()<CR>
	inoremap    <buffer>  <silent>  <LocalLeader>rt    <C-C>:call Perl_SaveWithTimestamp()<CR>
	inoremap    <buffer>  <silent>  <LocalLeader>rh    <C-C>:call Perl_Hardcopy("n")<CR>
	inoremap    <buffer>  <silent>  <LocalLeader>rk    <C-C>:call Perl_Settings(0)<CR>
	"
	if has("gui_running") && s:UNIX
		noremap    <buffer>  <silent>  <LocalLeader>rx        :call Perl_XtermSize()<CR>
		inoremap    <buffer>  <silent>  <LocalLeader>rx   <C-C>:call Perl_XtermSize()<CR>
	endif
	"
	noremap    <buffer>  <silent>  <LocalLeader>ro         :call Perl_Toggle_Gvim_Xterm()<CR>
	inoremap    <buffer>  <silent>  <LocalLeader>ro    <C-C>:call Perl_Toggle_Gvim_Xterm()<CR>
	"
	noremap 		<buffer>  <silent>  <LocalLeader>rpcs       :call Perl_PerlcriticSeverityInput()<CR>
	noremap 		<buffer>  <silent>  <LocalLeader>rpcv       :call Perl_PerlcriticVerbosityInput()<CR>
	noremap 		<buffer>  <silent>  <LocalLeader>rpco       :call Perl_PerlcriticOptionsInput()<CR>
	"
	"-------------------------------------------------------------------------------
	" tool box
	"-------------------------------------------------------------------------------
	"
	if s:Perl_UseToolbox == 'yes'
		call mmtoolbox#tools#AddMaps ( s:Perl_Toolbox )
	endif
	"
	"-------------------------------------------------------------------------------
	" settings - reset local leader
	"-------------------------------------------------------------------------------
	"
	if ! empty ( g:Perl_MapLeader )
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
	if s:Perl_Ctrl_j == 'yes' || s:Perl_Ctrl_j == 'on'
		nnoremap    <buffer>  <silent>  <C-j>       i<C-R>=<SID>JumpForward()<CR>
		inoremap    <buffer>  <silent>  <C-j>  <C-g>u<C-R>=<SID>JumpForward()<CR>
	endif

	if s:Perl_Ctrl_d == 'yes'
		call mmtemplates#core#CreateMaps ( 'g:Perl_Templates', g:Perl_MapLeader, 'do_special_maps', 'do_del_opt_map' )
	else
		call mmtemplates#core#CreateMaps ( 'g:Perl_Templates', g:Perl_MapLeader, 'do_special_maps' )
	endif

	" ----------------------------------------------------------------------------
	"  Generate (possibly exuberant) Ctags style tags for Perl sourcecode.
	"  Controlled by g:Perl_PerlTags, disabled by default.
	" ----------------------------------------------------------------------------
	if has('perl') && exists("g:Perl_PerlTags") && g:Perl_PerlTags == 'on'

		if ! exists("s:defined_functions")
			function s:init_tags()
			perl <<EOF

			use if defined $ENV{PERL_LOCAL_INSTALLATION}, lib => $ENV{PERL_LOCAL_INSTALLATION};

 			eval { require Perl::Tags::Naive };
			if ( $@ ) {
				# Perl::Tags::Naive not loadable
				VIM::DoCommand("let g:Perl_PerlTags = 'off'" );
				}
			else {
				$naive_tagger = Perl::Tags::Naive->new( max_level=>2 );
			}
EOF
		endfunction

		" let vim do the tempfile cleanup and protection
		let s:tagfile = tempname()

		call s:init_tags() " only the first time

		let s:defined_functions = 1
	endif

	call Perl_do_tags( expand('%'), s:tagfile )

	augroup perltags
		au!
		autocmd BufRead,BufWritePost *.pm,*.pl call Perl_do_tags(expand('%'), s:tagfile)
	augroup END

endif
	"
endfunction    " ----------  end of function s:CreateAdditionalMaps  ----------

"-------------------------------------------------------------------------------
" s:Initialize : Initialize templates, menus, and maps.   {{{1
"-------------------------------------------------------------------------------
function! s:Initialize ( ftype )
	if ! exists( 'g:Perl_Templates' )
		if s:Perl_LoadMenus == 'yes' | call Perl_CreateGuiMenus()
		else                         | call s:RereadTemplates()
		endif
	endif
	call s:CreateAdditionalMaps()
	call s:CheckTemplatePersonalization()
endfunction    " ----------  end of function s:Initialize  ----------

"-------------------------------------------------------------------------------
" === Setup: Templates, toolbox and menus ===   {{{1
"-------------------------------------------------------------------------------

"------------------------------------------------------------------------------
"  setup the toolbox
"------------------------------------------------------------------------------

if s:Perl_UseToolbox == 'yes'
	"
	let s:Perl_Toolbox = mmtoolbox#tools#NewToolbox ( 'Perl' )
	call mmtoolbox#tools#Property ( s:Perl_Toolbox, 'mapleader', g:Perl_MapLeader )
	"
	call mmtoolbox#tools#Load ( s:Perl_Toolbox, s:Perl_ToolboxDir )
	"
	" debugging only:
	"call mmtoolbox#tools#Info ( s:Perl_Toolbox )
	"
endif
"
call Perl_ToolMenu()

if s:Perl_LoadMenus == 'yes' && s:Perl_CreateMenusDelayed == 'no'
	call Perl_CreateGuiMenus()
endif

"------------------------------------------------------------------------------
"  Automated header insertion
"------------------------------------------------------------------------------
if has("autocmd")
	augroup PerlSupport

	" create menus and maps
	autocmd FileType perl  call s:Initialize('perl')
	autocmd FileType pod   call s:Initialize('pod')

	" insert file header
	autocmd BufNewFile  *.pl   call s:InsertFileHeader('Script')
	autocmd BufNewFile  *.pm   call s:InsertFileHeader('Module')
	autocmd BufNewFile  *.t    call s:InsertFileHeader('Test')
	autocmd BufNewFile  *.pod  call s:InsertFileHeader('POD')

	" highlight jump targets after opening file
	autocmd BufReadPost *.pl,*.pm,*.t,*.pod  call s:HighlightJumpTargets()

	" initialize the Perl interface
	autocmd FileType perl,pod  call Perl_InitializePerlInterface()

	" set foldmethod and expression for file s:Perl_PerlModuleList
	exe 'autocmd BufNewFile,BufReadPost' s:Perl_PerlModuleList 'setlocal foldmethod=expr | setlocal foldexpr=Perl_ModuleListFold(v:lnum)'

	augroup END
endif
" }}}1
"-------------------------------------------------------------------------------

" =====================================================================================
" vim: tabstop=2 shiftwidth=2 foldmethod=marker
