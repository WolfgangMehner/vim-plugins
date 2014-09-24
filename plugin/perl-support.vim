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
"                   configured (see the files README.perlsupport and
"                   perlsupport.txt).
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
"         Author:  Dr.-Ing. Fritz Mehner <mehner.fritz@fh-swf.de>
"
"        Version:  see variable  g:Perl_PluginVersion  below
"        Created:  09.07.2001
"        License:  Copyright (c) 2001-2014, Fritz Mehner
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
"
" Prevent duplicate loading:
"
if exists("g:Perl_PluginVersion") || &compatible
  finish
endif
let g:Perl_PluginVersion= "5.3.2"
"
"===  FUNCTION  ================================================================
"          NAME:  Perl_SetGlobalVariable     {{{1
"   DESCRIPTION:  Define a global variable and assign a default value if nor
"                 already defined
"    PARAMETERS:  name - global variable
"                 default - default value
"===============================================================================
function! s:perl_SetGlobalVariable ( name, default )
  if !exists('g:'.a:name)
    exe 'let g:'.a:name."  = '".a:default."'"
	else
		" check for an empty initialization
		exe 'let	val	= g:'.a:name
		if empty(val)
			exe 'let g:'.a:name."  = '".a:default."'"
		endif
  endif
endfunction   " ---------- end of function  s:perl_SetGlobalVariable  ----------
"
"===  FUNCTION  ================================================================
"          NAME:  Perl_SetLocalVariable     {{{1
"   DESCRIPTION:  Assign a value to a local variable if a corresponding global
"                 variable exists
"    PARAMETERS:  name - name of a global variable
"===============================================================================
function! s:perl_SetLocalVariable ( name )
  if exists('g:'.a:name)
    exe 'let s:'.a:name.'  = g:'.a:name
  endif
endfunction   " ---------- end of function  s:perl_SetLocalVariable  ----------
"
call s:perl_SetGlobalVariable( "Perl_MenuHeader",'yes' )
call s:perl_SetGlobalVariable( "Perl_OutputGvim",'vim' )
call s:perl_SetGlobalVariable( "Perl_PerlRegexSubstitution",'$~' )
"
"------------------------------------------------------------------------------
"
" Platform specific items:
" - plugin directory
" - characters that must be escaped for filenames
"
let s:MSWIN = has("win16") || has("win32")   || has("win64")    || has("win95")
let s:UNIX	= has("unix")  || has("macunix") || has("win32unix")
"
let s:Perl_Perl			          = ''                     " the Perl interpreter used
let s:Perl_Perl_is_executable = 0                      " the Perl interpreter used
let g:Perl_Installation				= '*undefined*'
let g:Perl_PluginDir					= ''
"
let s:Perl_GlobalTemplateFile	= ''
let s:Perl_LocalTemplateFile	= ''
let g:Perl_FilenameEscChar 		= ''
"
let s:Perl_ToolboxDir					= []
"
if  s:MSWIN
  " ==========  MS Windows  ======================================================
	"
	let g:Perl_PluginDir = substitute( expand('<sfile>:p:h:h'), '\', '/', 'g' )
	"
	" change '\' to '/' to avoid interpretation as escape character
	if match(	substitute( expand("<sfile>"), '\', '/', 'g' ),
				\		substitute( expand("$HOME"),   '\', '/', 'g' ) ) == 0
		" USER INSTALLATION ASSUMED
		let g:Perl_Installation				= 'local'
		let s:Perl_LocalTemplateFile	= g:Perl_PluginDir.'/perl-support/templates/Templates'
		let s:Perl_ToolboxDir				 += [ g:Perl_PluginDir.'/autoload/mmtoolbox/' ]
	else
		" SYSTEM WIDE INSTALLATION
		let g:Perl_Installation				= 'system'
		let s:Perl_GlobalTemplateFile	= g:Perl_PluginDir.'/perl-support/templates/Templates'
		let s:Perl_LocalTemplateFile	= $HOME.'/vimfiles/perl-support/templates/Templates'
		let s:Perl_ToolboxDir				 += [
					\	g:Perl_PluginDir.'/autoload/mmtoolbox/',
					\	$HOME.'/vimfiles/autoload/mmtoolbox/' ]
	end
	"
	let s:Perl_Perl		  	          = 'C:/Perl/bin/perl.exe'
  let g:Perl_FilenameEscChar 			= ''
	"
else
  " ==========  Linux/Unix  ======================================================
	"
	let g:Perl_PluginDir = expand("<sfile>:p:h:h")
	"
	if match( expand("<sfile>"), resolve( expand("$HOME") ) ) == 0
		" USER INSTALLATION ASSUMED
		let g:Perl_Installation				= 'local'
		let s:Perl_LocalTemplateFile	= g:Perl_PluginDir.'/perl-support/templates/Templates'
		let s:Perl_ToolboxDir				 += [ g:Perl_PluginDir.'/autoload/mmtoolbox/' ]
	else
		" SYSTEM WIDE INSTALLATION
		let g:Perl_Installation				= 'system'
		let s:Perl_GlobalTemplateFile	= g:Perl_PluginDir.'/perl-support/templates/Templates'
		let s:Perl_LocalTemplateFile	= $HOME.'/.vim/perl-support/templates/Templates'
		let s:Perl_ToolboxDir				 += [
					\	g:Perl_PluginDir.'/autoload/mmtoolbox/',
					\	$HOME.'/.vim/autoload/mmtoolbox/' ]
	endif
	"
	let s:Perl_Perl		  	          = '/usr/bin/perl'
  let g:Perl_FilenameEscChar 			= ' \%#[]'
	"
  " ==============================================================================
endif
"
" g:Perl_CodeSnippets is used in autoload/perlsupportgui.vim
"
let s:Perl_CodeSnippets  				= g:Perl_PluginDir.'/perl-support/codesnippets/'
call s:perl_SetGlobalVariable( 'Perl_CodeSnippets', s:Perl_CodeSnippets )
"
"
call s:perl_SetGlobalVariable( 'Perl_PerlTags', 'off' )
"
if !exists("g:Perl_Dictionary_File")
  let g:Perl_Dictionary_File       = g:Perl_PluginDir.'/perl-support/wordlists/perl.list'
endif
"
"
"  Modul global variables (with default values) which can be overridden.     {{{1
"
let s:Perl_LoadMenus             = 'yes'        " display the menus ?
let s:Perl_TemplateOverriddenMsg = 'no'
let s:Perl_Ctrl_j								 = 'on'
"
let s:Perl_TimestampFormat       = '%Y%m%d.%H%M%S'

let s:Perl_PerlModuleList        = g:Perl_PluginDir.'/perl-support/modules/perl-modules.list'
let s:Perl_XtermDefaults         = "-fa courier -fs 12 -geometry 80x24"
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
let s:Perl_GuiTemplateBrowser    = 'gui'										" gui / explorer / commandline
let s:Perl_CreateMenusDelayed    = 'yes'
let s:Perl_DirectRun             = 'no'
"
let s:Perl_InsertFileHeader			   = 'yes'
let s:Perl_Wrapper                 = g:Perl_PluginDir.'/perl-support/scripts/wrapper.sh'
let s:Perl_PerlModuleListGenerator = g:Perl_PluginDir.'/perl-support/scripts/pmdesc3.pl'
let s:Perl_PerltidyBackup			     = "no"
"
call s:perl_SetGlobalVariable ( 'Perl_MapLeader', '' )
let s:Perl_RootMenu								= '&Perl'
"
let s:Perl_UseToolbox             = 'yes'
call s:perl_SetGlobalVariable ( 'Perl_UseTool_make',    'yes' )
"
"------------------------------------------------------------------------------
"
"  Look for global variables (if any), to override the defaults.
"
call s:perl_SetLocalVariable('Perl_Perl                   ')
call s:perl_SetLocalVariable('Perl_DirectRun              ')
call s:perl_SetLocalVariable('Perl_InsertFileHeader       ')
call s:perl_SetLocalVariable('Perl_CreateMenusDelayed     ')
call s:perl_SetLocalVariable('Perl_Ctrl_j                 ')
call s:perl_SetLocalVariable('Perl_Debugger               ')
call s:perl_SetLocalVariable('Perl_GlobalTemplateFile     ')
call s:perl_SetLocalVariable('Perl_LocalTemplateFile      ')
call s:perl_SetLocalVariable('Perl_GuiSnippetBrowser      ')
call s:perl_SetLocalVariable('Perl_GuiTemplateBrowser     ')
call s:perl_SetLocalVariable('Perl_LineEndCommColDefault  ')
call s:perl_SetLocalVariable('Perl_LoadMenus              ')
call s:perl_SetLocalVariable('Perl_NYTProf_browser        ')
call s:perl_SetLocalVariable('Perl_NYTProf_html           ')
call s:perl_SetLocalVariable('Perl_PerlcriticOptions      ')
call s:perl_SetLocalVariable('Perl_PerlcriticSeverity     ')
call s:perl_SetLocalVariable('Perl_PerlcriticVerbosity    ')
call s:perl_SetLocalVariable('Perl_PerlModuleList         ')
call s:perl_SetLocalVariable('Perl_PerlModuleListGenerator')
call s:perl_SetLocalVariable('Perl_PerltidyBackup         ')
call s:perl_SetLocalVariable('Perl_PodcheckerWarnings     ')
call s:perl_SetLocalVariable('Perl_Printheader            ')
call s:perl_SetLocalVariable('Perl_ProfilerTimestamp      ')
call s:perl_SetLocalVariable('Perl_TemplateOverriddenMsg  ')
call s:perl_SetLocalVariable('Perl_TimestampFormat        ')
call s:perl_SetLocalVariable('Perl_UseToolbox             ')
call s:perl_SetLocalVariable('Perl_XtermDefaults          ')
"
let s:Perl_Perl_is_executable	= executable(s:Perl_Perl)
"
" set default geometry if not specified
"
if match( s:Perl_XtermDefaults, "-geometry\\s\\+\\d\\+x\\d\\+" ) < 0
  let s:Perl_XtermDefaults  = s:Perl_XtermDefaults." -geometry 80x24"
endif
"
" Flags for perldoc
"
if has("gui_running")
  let s:Perl_perldoc_flags  = ""
else
  " Display docs using plain text converter.
  let s:Perl_perldoc_flags  = "-otext"
endif
"
" escape the printheader
"
let s:Perl_Printheader  					= escape( s:Perl_Printheader, ' %' )
let s:Perl_PerlExecutableVersion	= ''
"
"------------------------------------------------------------------------------
"  Control variables (not user configurable)
"------------------------------------------------------------------------------
"
let s:Perl_MenuVisible 						= 'no'
let s:Perl_TemplateJumpTarget 		= ''

let s:MsgInsNotAvail							= "insertion not available for a fold"
let g:Perl_PerlRegexAnalyser			= 'no'
let g:Perl_InterfaceInitialized		= 'no'
let s:Perl_saved_global_option		= {}
"
let s:PCseverityName	= [ "DUMMY", "brutal", "cruel", "harsh", "stern", "gentle" ]
let s:PCverbosityName	= [ '1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11' ]
"
"===  FUNCTION  ================================================================
"          NAME:  Perl_Input     {{{1
"   DESCRIPTION:  Input after a highlighted prompt
"    PARAMETERS:  prompt - prompt
"                 text   - default reply
"                 ...    - completion (optional)
"       RETURNS:
"===============================================================================
function! Perl_Input ( prompt, text, ... )
	echohl Search																					" highlight prompt
	call inputsave()																			" preserve typeahead
	if a:0 == 0 || empty(a:1)
		let retval	=input( a:prompt, a:text )
	else
		let retval	=input( a:prompt, a:text, a:1 )
	endif
	call inputrestore()																		" restore typeahead
	echohl None																						" reset highlighting
	let retval  = substitute( retval, '^\s\+', "", "" )		" remove leading whitespaces
	let retval  = substitute( retval, '\s\+$', "", "" )		" remove trailing whitespaces
	return retval
endfunction    " ----------  end of function Perl_Input ----------
"
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
			let b:Perl_LineEndCommentColumn = Perl_Input( 'start line-end comment at virtual column : ', actcol, '' )
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
			let item=Perl_Input("perldoc - module, function or FAQ keyword : ", "", '')
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
    "
    " search order:  library module --> builtin function --> FAQ keyword
    "
    let delete_perldoc_errors = ""
    if s:UNIX && ( match( $shell, '\ccsh$' ) >= 0 )
			" not for csh, tcsh
      let delete_perldoc_errors = " 2>/dev/null"
    endif
    setlocal  modifiable
    "
    " controll repeated search
    "
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
        redraw!
        let s:Perl_PerldocTry         = 'function'
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
        redraw!
        let s:Perl_PerldocTry         = 'faq'
      endif
    endif
    "
    " FAQ documentation
    if s:Perl_PerldocTry == 'faq'
      silent exe ":%!perldoc ".s:Perl_perldoc_flags." -q ".item.delete_perldoc_errors
      if v:shell_error != 0
        redraw!
        let s:Perl_PerldocTry         = 'error'
      endif
    endif
    "
    " no documentation found
    if s:Perl_PerldocTry == 'error'
      redraw!
      let zz=   "No documentation found for perl module, perl function or perl FAQ keyword\n"
      let zz=zz."  '".item."'  "
      silent put! =zz
      normal!  2jdd$
      let s:Perl_PerldocTry         = 'module'
      let s:Perl_PerldocSearchWord  = ""
    endif
    if s:UNIX
      " remove windows line ends
      silent! exe ":%s/\r$// | normal! gg"
    endif
    setlocal nomodifiable
    redraw!
		" highlight the headlines
		:match Search '^\S.*$'
		" ------------
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
    silent exe ":!".s:Perl_Perl." ".fnameescape(s:Perl_PerlModuleListGenerator)." > ".shellescape(s:Perl_PerlModuleList)
    silent exe ":!sort ".fnameescape(s:Perl_PerlModuleList)." /O ".fnameescape(s:Perl_PerlModuleList)
  else
		" direct STDOUT and STDERR to the module list file :
    silent exe ":!".s:Perl_Perl." ".shellescape(s:Perl_PerlModuleListGenerator)." -s &> ".s:Perl_PerlModuleList
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
function! Perl_Settings ()
  let txt =     "  Perl-Support settings\n\n"
  let txt = txt.'  code snippet directory  :  "'.g:Perl_CodeSnippets."\"\n"
	let txt = txt.'                   author :  "'.mmtemplates#core#ExpandText( g:Perl_Templates, '|AUTHOR|'    )."\"\n"
	let txt = txt.'                authorref :  "'.mmtemplates#core#ExpandText( g:Perl_Templates, '|AUTHORREF|' )."\"\n"
	let txt = txt.'         copyright holder :  "'.mmtemplates#core#ExpandText( g:Perl_Templates, '|COPYRIGHT|' )."\"\n"
	let txt = txt.'                    email :  "'.mmtemplates#core#ExpandText( g:Perl_Templates, '|EMAIL|'     )."\"\n"
	let txt = txt.'             organization :  "'.mmtemplates#core#ExpandText( g:Perl_Templates, '|ORGANIZATION|'   )."\"\n"
 	let txt = txt.'           template style :  "'.mmtemplates#core#Resource ( g:Perl_Templates, "style" )[0]."\"\n"
	let txt = txt.'      plugin installation :  "'.g:Perl_Installation."\"\n"
	" ----- template files  ------------------------
	if g:Perl_Installation == 'system'
		let txt = txt.'     global template file :  "'.s:Perl_GlobalTemplateFile."\"\n"
		if filereadable( s:Perl_LocalTemplateFile )
			let txt = txt.'      local template file :  '.s:Perl_LocalTemplateFile."\n"
		endif
	else
		let txt = txt.'      local template file :  '.s:Perl_LocalTemplateFile."\n"
	endif
	" ----- xterm ------------------------
	if	!s:MSWIN
		let txt = txt.'           xterm defaults :  '.s:Perl_XtermDefaults."\n"
	endif
	" ----- dictionaries ------------------------
  if !empty(g:Perl_Dictionary_File)
		let ausgabe= &dictionary
    let ausgabe = substitute( ausgabe, ",", ",\n                          + ", "g" )
    let txt     = txt."       dictionary file(s) :  ".ausgabe."\n"
  endif
  let txt = txt."    current output dest.  :  ".g:Perl_OutputGvim."\n"
  let txt = txt."              perlcritic  :  perlcritic -severity ".s:Perl_PerlcriticSeverity
				\				.' ['.s:PCseverityName[s:Perl_PerlcriticSeverity].']'
				\				."  -verbosity ".s:Perl_PerlcriticVerbosity
				\				."  ".s:Perl_PerlcriticOptions."\n"
	if !empty(s:Perl_PerlExecutableVersion)
		let txt = txt."  Perl interface version  :  ".s:Perl_PerlExecutableVersion."\n"
	endif
	" ----- toolbox -----------------------------
	if s:Perl_UseToolbox == 'yes'
		let toollist = mmtoolbox#tools#GetList ( s:Perl_Toolbox )
		if empty ( toollist )
			let txt .= "                  toolbox :  -no tools-\n"
		else
			let sep  = "\n"."                             "
			let txt .=      "                  toolbox :  "
						\ .join ( toollist, sep )."\n"
		endif
	endif
  let txt = txt."\n"
  let txt = txt."    Additional hot keys\n\n"
  let txt = txt."                Shift-F1  :  read perldoc (for word under cursor)\n"
  let txt = txt."                      F9  :  start a debugger (".s:Perl_Debugger.")\n"
  let txt = txt."                  Alt-F9  :  run syntax check          \n"
  let txt = txt."                 Ctrl-F9  :  run script                \n"
  let txt = txt."                Shift-F9  :  set command line arguments\n"
  let txt = txt."_________________________________________________________________________\n"
  let txt = txt."  Perl-Support, Version ".g:Perl_PluginVersion." / Dr.-Ing. Fritz Mehner / mehner.fritz@fh-swf.de\n\n"
  echo txt
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
	exe ':set makeprg='.s:Perl_Perl.'\ -cW'
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
		echomsg '(possibly default) Perl interpreter "'.s:Perl_Perl.'" not executable'
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
			exe '!'.s:Perl_Perl.' '.l:switches.shellescape(l:fullname).l:arguments
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
			exe '%!'.s:Perl_Perl.' '.l:switches.shellescape(l:fullname).l:arguments
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
			exe '!'.s:Perl_Perl.' '.l:switches.shellescape(l:fullname).l:arguments
		else
			" Linux
			if executable(l:fullname) == 1 && s:Perl_DirectRun == 'yes'
				silent exe '!xterm -title '.shellescape(l:fullname).' '.s:Perl_XtermDefaults.' -e '.s:Perl_Wrapper.' '.shellescape(l:fullname).l:arguments
			else
				silent exe '!xterm -title '.shellescape(l:fullname).' '.s:Perl_XtermDefaults.' -e '.s:Perl_Wrapper.' '.s:Perl_Perl.' '.l:switches.shellescape(l:fullname).l:arguments
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
      exe '!'. s:Perl_Perl .' -d '.shellescape( filename.l:arguments )
    else
      if has("gui_running") || &term == "xterm"
     	 	silent exe "!xterm ".s:Perl_XtermDefaults.' -e ' . s:Perl_Perl . l:switches .' -d '.shellescape(filename).l:arguments.' &'
      else
        silent exe '!clear; ' .s:Perl_Perl. l:switches . ' -d '.shellescape(filename).l:arguments
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
  let geom  = matchstr( s:Perl_XtermDefaults, regex )
  let geom  = matchstr( geom, '\d\+x\d\+' )
  let geom  = substitute( geom, 'x', ' ', "" )
  let answer= Perl_Input("   xterm size (COLUMNS LINES) : ", geom )
  while match(answer, '^\s*\d\+\s\+\d\+\s*$' ) < 0
    let answer= Perl_Input(" + xterm size (COLUMNS LINES) : ", geom )
  endwhile
  let answer  = substitute( answer, '\s\+', "x", "" )           " replace inner whitespaces
  let s:Perl_XtermDefaults  = substitute( s:Perl_XtermDefaults, regex, "-geometry ".answer , "" )
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
		if Perl_Input( '"'.filename.'" NOT executable. Make it executable [y/n] : ', 'y' ) == 'y'
			silent exe "!chmod u+x ".shellescape(filename)
			if v:shell_error
				" confirmation for the user
				echohl WarningMsg
				echo 'Could not make "'.filename.'" executable!'
			else
				" reload the file, otherwise the message will not be visible
				if ! &l:modified
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
		if Perl_Input( '"'.filename.'" is executable. Make it NOT executable [y/n] : ', 'y' ) == 'y'
			" reset all execution bits
			silent exe "!chmod  -x ".shellescape(filename)
			if v:shell_error
				" confirmation for the user
				echohl WarningMsg
				echo 'Could not make "'.filename.'" not executable!'
			else
				" reload the file, otherwise the message will not be visible
				if ! &l:modified
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
"          NAME:  Perl_BrowseTemplateFiles     {{{1
"   DESCRIPTION:  browse the template files
"    PARAMETERS:  type - local / global
"       RETURNS:
"===============================================================================
function! Perl_BrowseTemplateFiles ( type )
	let	templatefile	= eval( 's:Perl_'.a:type.'TemplateFile' )
	let	templatedir		= eval( 's:Perl_'.a:type.'TemplateDir' )
	if isdirectory( templatedir )
		if has("browse") && s:Perl_GuiTemplateBrowser == 'gui'
			let	l:templatefile	= browse(0,"edit a template file", templatedir, "" )
		else
				let	l:templatefile	= ''
			if s:Perl_GuiTemplateBrowser == 'explorer'
				exe ':Explore '.templatedir
			endif
			if s:Perl_GuiTemplateBrowser == 'commandline'
				let	l:templatefile	= input("edit a template file", templatedir, "file" )
			endif
		endif
		if !empty(l:templatefile)
			:execute "update! | split | edit ".l:templatefile
		endif
	else
		echomsg "Template directory '".templatedir."' does not exist."
	endif
endfunction    " ----------  end of function Perl_BrowseTemplateFiles  ----------

"===  FUNCTION  ================================================================
"          NAME:  Perl_OpenFold     {{{1
"   DESCRIPTION:  Open fold and go to the first or last line of this fold
"    PARAMETERS:  mode - below / start
"       RETURNS:
"===============================================================================
function! Perl_OpenFold ( mode )
	if foldclosed(".") >= 0
		" we are on a closed  fold: get end position, open fold, jump to the
		" last line of the previously closed fold
		let	foldstart	= foldclosed(".")
		let	foldend		= foldclosedend(".")
		normal! zv
		if a:mode == 'below'
			exe ":".foldend
		endif
		if a:mode == 'start'
			exe ":".foldstart
		endif
	endif
endfunction    " ----------  end of function Perl_OpenFold  ----------

"===  FUNCTION  ================================================================
"          NAME:  Perl_HighlightJumpTargets     {{{1
"   DESCRIPTION:  highlight the jump targets
"    PARAMETERS:  -
"       RETURNS:
"===============================================================================
function! Perl_HighlightJumpTargets ()
	if s:Perl_Ctrl_j == 'on'
		exe 'match Search /'.s:Perl_TemplateJumpTarget.'/'
	endif
endfunction    " ----------  end of function Perl_HighlightJumpTargets  ----------

"===  FUNCTION  ================================================================
"          NAME:  Perl_JumpCtrlJ     {{{1
"   DESCRIPTION:  replaces the template system function for C-j
"    PARAMETERS:  -
"       RETURNS:
"===============================================================================
function! Perl_JumpCtrlJ ()
  let match	= search( s:Perl_TemplateJumpTarget, 'c' )
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
endfunction    " ----------  end of function Perl_JumpCtrlJ  ----------

let s:Perl_perltidy_startscript_executable = 'no'
let s:Perl_perltidy_module_executable      = 'no'

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
  "
  " check if perltidy start script is executable
  "
  if s:Perl_perltidy_startscript_executable == 'no'
    if !executable("perltidy")
      echohl WarningMsg
      echo 'perltidy does not exist or is not executable!'
      echohl None
      return
    else
      let s:Perl_perltidy_startscript_executable  = 'yes'
    endif
  endif
  "
  " check if perltidy module is executable
  " WORKAROUND: after upgrading Perl the module will no longer be found
  "
  if s:Perl_perltidy_module_executable == 'no'
    let perltidy_version = system("perltidy -v")
    if match( perltidy_version, 'copyright\c' )      >= 0 &&
    \  match( perltidy_version, 'Steve\s\+Hancock' ) >= 0
      let s:Perl_perltidy_module_executable = 'yes'
    else
      echohl WarningMsg
      echo 'The module Perl::Tidy can not be found! Please reinstall perltidy.'
      echohl None
      return
    endif
  endif
	"
  " ----- normal mode ----------------
  if a:mode=="n"
    if Perl_Input("reformat whole file [y/n/Esc] : ", "y", '' ) != "y"
      return
    endif
    if s:Perl_PerltidyBackup == 'yes'
    	exe ':write! '.Sou.'.bak'
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
		call s:Perl_RereadTemplates('no')
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
"
"===  FUNCTION  ================================================================
"          NAME:  Perl_RereadTemplates     {{{1
"   DESCRIPTION:  rebuild commands and the menu from the (changed) template file
"    PARAMETERS:  displaymsg - yes / no
"       RETURNS:
"===============================================================================
function! s:Perl_RereadTemplates ( displaymsg )
	"
	"-------------------------------------------------------------------------------
	" SETUP TEMPLATE LIBRARY
	"-------------------------------------------------------------------------------
	let g:Perl_Templates = mmtemplates#core#NewLibrary ()
	"
	" mapleader
	if empty ( g:Perl_MapLeader )
		call mmtemplates#core#Resource ( g:Perl_Templates, 'set', 'property', 'Templates::Mapleader', '\' )
	else
		call mmtemplates#core#Resource ( g:Perl_Templates, 'set', 'property', 'Templates::Mapleader', g:Perl_MapLeader )
	endif
	"
	" map: choose style
	call mmtemplates#core#Resource ( g:Perl_Templates, 'set', 'property', 'Templates::ChooseStyle::Map', 'nts' )
	"
	" syntax: comments
	call mmtemplates#core#ChangeSyntax ( g:Perl_Templates, 'comment', '§' )
	let s:Perl_TemplateJumpTarget = mmtemplates#core#Resource ( g:Perl_Templates, "jumptag" )[0]
	"
	let	messsage = ''
	"
	if g:Perl_Installation == 'system'
		"-------------------------------------------------------------------------------
		" SYSTEM INSTALLATION
		"-------------------------------------------------------------------------------
		if filereadable( s:Perl_GlobalTemplateFile )
			call mmtemplates#core#ReadTemplates ( g:Perl_Templates, 'load', s:Perl_GlobalTemplateFile )
		else
			echomsg "Global template file '".s:Perl_GlobalTemplateFile."' not readable."
			return
		endif
		let	messsage	= "Templates read from '".s:Perl_GlobalTemplateFile."'"
		"
		"-------------------------------------------------------------------------------
		" handle local template files
		"-------------------------------------------------------------------------------
		let templ_dir = fnamemodify( s:Perl_LocalTemplateFile, ":p:h" ).'/'
		"
		if finddir( templ_dir ) == ''
			" try to create a local template directory
			if exists("*mkdir")
				try
					call mkdir( templ_dir, "p" )
				catch /.*/
				endtry
			endif
		endif

		if isdirectory( templ_dir ) && !filereadable( s:Perl_LocalTemplateFile )
			" write a default local template file
			let template	= [	]
			let sample_template_file	= g:Perl_PluginDir.'/perl-support/rc/sample_template_file'
			if filereadable( sample_template_file )
				for line in readfile( sample_template_file )
					call add( template, line )
				endfor
				call writefile( template, s:Perl_LocalTemplateFile )
			endif
		endif
		"
		if filereadable( s:Perl_LocalTemplateFile )
			call mmtemplates#core#ReadTemplates ( g:Perl_Templates, 'load', s:Perl_LocalTemplateFile )
			let messsage	= messsage." and '".s:Perl_LocalTemplateFile."'"
			if mmtemplates#core#ExpandText( g:Perl_Templates, '|AUTHOR|' ) == 'YOUR NAME'
				echomsg "Please set your personal details in file '".s:Perl_LocalTemplateFile."'."
			endif
		endif
		"
	else
		"-------------------------------------------------------------------------------
		" LOCAL INSTALLATION
		"-------------------------------------------------------------------------------
		if filereadable( s:Perl_LocalTemplateFile )
			call mmtemplates#core#ReadTemplates ( g:Perl_Templates, 'load', s:Perl_LocalTemplateFile )
			let	messsage	= "Templates read from '".s:Perl_LocalTemplateFile."'"
		else
			echomsg "Local template file '".s:Perl_LocalTemplateFile."' not readable."
			return
		endif
		"
	endif
	if a:displaymsg == 'yes'
		echomsg messsage.'.'
	endif

endfunction    " ----------  end of function s:Perl_RereadTemplates  ----------
"
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
"          NAME:  Perl_MenuTitle     {{{1
"   DESCRIPTION:  display warning
"    PARAMETERS:  -
"       RETURNS:
"===============================================================================
function! Perl_MenuTitle ()
		echohl WarningMsg | echo "This is a menu header." | echohl None
endfunction    " ----------  end of function Perl_MenuTitle  ----------
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
		call mmtemplates#core#CreateMenus ( 'g:Perl_Templates', s:Perl_RootMenu, 'sub_menu', '&Tool Box', 'priority', 900 )
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
	exe ahead.'edit\ &local\ templates<Tab>'.esc_mapl.'ntl       :call mmtemplates#core#EditTemplateFiles(g:Perl_Templates,-1)<CR>'
	exe ihead.'edit\ &local\ templates<Tab>'.esc_mapl.'ntl  <C-C>:call mmtemplates#core#EditTemplateFiles(g:Perl_Templates,-1)<CR>'
	if g:Perl_Installation == 'system'
		exe ahead.'edit\ &global\ templates<Tab>'.esc_mapl.'ntg       :call mmtemplates#core#EditTemplateFiles(g:Perl_Templates,0)<CR>'
		exe ihead.'edit\ &global\ templates<Tab>'.esc_mapl.'ntg  <C-C>:call mmtemplates#core#EditTemplateFiles(g:Perl_Templates,0)<CR>'
	endif
	"
	exe ahead.'reread\ &templates<Tab>'.esc_mapl.'ntr       :call mmtemplates#core#ReadTemplates(g:Perl_Templates,"reload","all")<CR>'
	exe ihead.'reread\ &templates<Tab>'.esc_mapl.'ntr  <C-C>:call mmtemplates#core#ReadTemplates(g:Perl_Templates,"reload","all")<CR>'
	"
	call mmtemplates#core#CreateMenus ( 'g:Perl_Templates', s:Perl_RootMenu, 'do_styles', 'specials_menu', 'Snippets'	)
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
  "   run the script from the local directory
  "   ( the one which is being edited; other versions may exist elsewhere ! )
  "
	let	ahead	= 'amenu <silent> '.s:Perl_RootMenu.'.&Run.'
	let	vhead	= 'vmenu <silent> '.s:Perl_RootMenu.'.&Run.'
	"
  exe ahead.'update,\ &run\ script<Tab>'.esc_mapl.'rr\ \ <C-F9>         :call Perl_Run()<CR>'
  exe ahead.'update,\ check\ &syntax<Tab>'.esc_mapl.'rs\ \ <A-F9>       :call Perl_SyntaxCheck()<CR>'
  exe 'amenu '.s:Perl_RootMenu.'.&Run.cmd\.\ line\ &arg\.<Tab>'.esc_mapl.'ra\ \ <S-F9>  :PerlScriptArguments<Space>'
  exe 'amenu .'s:Perl_RootMenu.'.&Run.perl\ s&witches<Tab>'.esc_mapl.'rw                :PerlSwitches<Space>'
  "
  " set execution rights for user only ( user may be root ! )
  if !s:MSWIN
    exe ahead.'make\ script\ &exe\./not\ exec\.<Tab>'.esc_mapl.'re              :call Perl_MakeScriptExecutable()<CR>'
  endif
  exe ahead.'start\ &debugger<Tab>'.esc_mapl.'rd\ \ <F9>                :call Perl_Debugger()<CR>'
	"
  exe ahead.'-SEP2-                     :'
  exe ahead.'show\ &installed\ Perl\ modules<Tab>'.esc_mapl.'ri  :call Perl_perldoc_show_module_list()<CR>'
  exe ahead.'&generate\ Perl\ module\ list<Tab>'.esc_mapl.'rg    :call Perl_perldoc_generate_module_list()<CR><CR>'
  "
  exe ahead.'-SEP4-                     :'
  exe ahead.'run\ perltid&y<Tab>'.esc_mapl.'ry                        :call Perl_Perltidy("n")<CR>'
  exe vhead.'run\ perltid&y<Tab>'.esc_mapl.'ry                   <C-C>:call Perl_Perltidy("v")<CR>'
	"
	"
  exe ahead.'-SEP3-                     :'
  exe ahead.'run\ perl&critic<Tab>'.esc_mapl.'rpc                     :call Perl_Perlcritic()<CR>'
  "
  if g:Perl_MenuHeader == "yes"
    exe ahead.'perlcritic\ severity<Tab>'.esc_mapl.'rpcs.severity     :call Perl_MenuTitle()<CR>'
    exe ahead.'perlcritic\ severity<Tab>'.esc_mapl.'rpcs.-Sep5-       :'
  endif

  let levelnumber = 1
  for level in s:PCseverityName[1:]
    exe ahead.'perlcritic\ severity<Tab>'.esc_mapl.'rpcs.&'.level.'<Tab>(='.levelnumber.')    :call Perl_GetPerlcriticSeverity("'.level.'")<CR>'
    let levelnumber = levelnumber+1
  endfor
  "
  if g:Perl_MenuHeader == "yes"
    exe ahead.'perlcritic\ &verbosity<Tab>'.esc_mapl.'rpcv.verbosity     :call Perl_MenuTitle()<CR>'
    exe ahead.'perlcritic\ &verbosity<Tab>'.esc_mapl.'rpcv.-Sep6-            :'
  endif

  for level in s:PCverbosityName
    exe ahead.'perlcritic\ &verbosity<Tab>'.esc_mapl.'rpcv.&'.level.'   :call Perl_GetPerlcriticVerbosity('.level.')<CR>'
  endfor
  exe ahead.'perlcritic\ &options<Tab>'.esc_mapl.'rpco                :call Perl_PerlcriticOptionsInput()<CR>'

  exe ahead.'-SEP5-                     :'
  exe ahead.'save\ buffer\ with\ &timestamp<Tab>'.esc_mapl.'rt        :call Perl_SaveWithTimestamp()<CR>'
  exe ahead.'&hardcopy\ to\ FILENAME\.ps<Tab>'.esc_mapl.'rh           :call Perl_Hardcopy("n")<CR>'
  exe vhead.'&hardcopy\ to\ FILENAME\.ps<Tab>'.esc_mapl.'rh      <C-C>:call Perl_Hardcopy("v")<CR>'
  exe ahead.'-SEP6-                     :'
  exe ahead.'settings\ and\ hot\ &keys<Tab>'.esc_mapl.'rk             :call Perl_Settings()<CR>'
  "
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
 			VIM::DoCommand("let s:Perl_PerlExecutableVersion = \"$^V\"");
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
"
"===  FUNCTION  ================================================================
"          NAME:  CreateAdditionalMaps     {{{1
"   DESCRIPTION:  create additional maps
"    PARAMETERS:  -
"       RETURNS:
"===============================================================================
function! s:CreateAdditionalMaps ()
	"
	if exists('g:Perl_Perltidy') && g:Perl_Perltidy == 'on' && executable("perltidy")
		setlocal equalprg='perltidy'
	endif
	"
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
	nnoremap    <buffer>  <silent> <LocalLeader>ntl       :call mmtemplates#core#EditTemplateFiles(g:Perl_Templates,-1)<CR>
	inoremap    <buffer>  <silent> <LocalLeader>ntl  <C-C>:call mmtemplates#core#EditTemplateFiles(g:Perl_Templates,-1)<CR>
	if g:Perl_Installation == 'system'
		nnoremap    <buffer>  <silent> <LocalLeader>ntg       :call mmtemplates#core#EditTemplateFiles(g:Perl_Templates,0)<CR>
		inoremap    <buffer>  <silent> <LocalLeader>ntg  <C-C>:call mmtemplates#core#EditTemplateFiles(g:Perl_Templates,0)<CR>
	endif
	nnoremap    <buffer>  <silent> <LocalLeader>ntr       :call mmtemplates#core#ReadTemplates(g:Perl_Templates,"reload","all")<CR>
	inoremap    <buffer>  <silent> <LocalLeader>ntr  <C-C>:call mmtemplates#core#ReadTemplates(g:Perl_Templates,"reload","all")<CR>
	nnoremap    <buffer>  <silent> <LocalLeader>nts       :call mmtemplates#core#ChooseStyle(g:Perl_Templates,"!pick")<CR>
	inoremap    <buffer>  <silent> <LocalLeader>nts  <C-C>:call mmtemplates#core#ChooseStyle(g:Perl_Templates,"!pick")<CR>
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
	noremap    <buffer>  <silent>  <LocalLeader>rk    :call Perl_Settings()<CR>
	"
	inoremap    <buffer>  <silent>  <LocalLeader>ri    <C-C>:call Perl_perldoc_show_module_list()<CR>
	inoremap    <buffer>  <silent>  <LocalLeader>rg    <C-C>:call Perl_perldoc_generate_module_list()<CR>
	inoremap    <buffer>  <silent>  <LocalLeader>ry    <C-C>:call Perl_Perltidy("n")<CR>
	inoremap    <buffer>  <silent>  <LocalLeader>rpc   <C-C>:call Perl_Perlcritic()<CR>
	inoremap    <buffer>  <silent>  <LocalLeader>rt    <C-C>:call Perl_SaveWithTimestamp()<CR>
	inoremap    <buffer>  <silent>  <LocalLeader>rh    <C-C>:call Perl_Hardcopy("n")<CR>
	inoremap    <buffer>  <silent>  <LocalLeader>rk    <C-C>:call Perl_Settings()<CR>
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
	" ----------------------------------------------------------------------------
	"
	if !exists("g:Perl_Ctrl_j") || ( exists("g:Perl_Ctrl_j") && g:Perl_Ctrl_j != 'off' )
		nnoremap    <buffer>  <silent>  <C-j>    i<C-R>=Perl_JumpCtrlJ()<CR>
		inoremap    <buffer>  <silent>  <C-j>     <C-R>=Perl_JumpCtrlJ()<CR>
	endif
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
	if ! empty ( g:Perl_MapLeader )
		if exists ( 'll_save' )
			let g:maplocalleader = ll_save
		else
			unlet g:maplocalleader
		endif
	endif
	"
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

"===============================================================================
"
" Plug-in setup:  {{{1
"
"------------------------------------------------------------------------------
"  setup the toolbox
"------------------------------------------------------------------------------
"
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
	"
	autocmd FileType *
				\	if ( &filetype == 'perl' || &filetype == 'pod') |
				\		if ! exists( 'g:Perl_Templates' ) |
				\			if s:Perl_LoadMenus == 'yes' | call Perl_CreateGuiMenus ()        |
				\			else                         | call s:Perl_RereadTemplates ('no') |
				\			endif |
				\		endif |
				\		call s:CreateAdditionalMaps() |
				\		call mmtemplates#core#CreateMaps ( 'g:Perl_Templates', g:Perl_MapLeader ) |
				\	endif
	"
	autocmd BufNewFile,BufRead *.pod  setlocal  syntax=perl
  autocmd BufNewFile,BufRead *.t    setlocal  filetype=perl
	"
	if s:Perl_InsertFileHeader == 'yes'
		autocmd BufNewFile  *.pl  call mmtemplates#core#InsertTemplate(g:Perl_Templates, 'Comments.file description pl')
		autocmd BufNewFile  *.pm  call mmtemplates#core#InsertTemplate(g:Perl_Templates, 'Comments.file description pm')
		autocmd BufNewFile  *.t   call mmtemplates#core#InsertTemplate(g:Perl_Templates, 'Comments.file description t')
	endif

	autocmd BufNew   *.pl,*.pm,*.t,*.pod  call Perl_InitializePerlInterface()
	autocmd BufRead  *.pl,*.pm,*.t,*.pod  call Perl_HighlightJumpTargets()
  "
  " Wrap error descriptions in the quickfix window.
  autocmd BufReadPost quickfix  setlocal wrap | setlocal linebreak
  "
	exe 'autocmd BufNewFile,BufReadPost  '.s:Perl_PerlModuleList.' setlocal foldmethod=expr | setlocal foldexpr=Perl_ModuleListFold(v:lnum)'
	"
endif
"
" vim: tabstop=2 shiftwidth=2 foldmethod=marker
