"===============================================================================
"
"          File:  mmtemplates#core.vim
" 
"   Description:  Template engine: Core.
"
"                 Maps & Menus - Template Engine
" 
"   VIM Version:  7.0+
"        Author:  Wolfgang Mehner, wolfgang-mehner@web.de
"  Organization:  
"       Version:  see variable g:Templates_Version below
"       Created:  30.08.2011
"      Revision:  30.09.2015
"       License:  Copyright (c) 2012-2016, Wolfgang Mehner
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
" === Basic Checks ===   {{{1
"-------------------------------------------------------------------------------
"
" need at least 7.0
if v:version < 700
	echohl WarningMsg
	echo 'The plugin templates.vim needs Vim version >= 7.'
	echohl None
	finish
endif
"
" prevent duplicate loading
" need compatible
if &cp || ( exists('g:Templates_Version') && g:Templates_Version != 'searching' && ! exists('g:Templates_DevelopmentOverwrite') )
	finish
endif
"
let s:Templates_Version = '1.0'     " version number of this script; do not change
"
"----------------------------------------------------------------------
"  --- Find Newest Version ---   {{{2
"----------------------------------------------------------------------
"
if exists('g:Templates_DevelopmentOverwrite')
	" skip ahead
elseif exists('g:Templates_VersionUse')
	"
	" not the newest one: abort
	if s:Templates_Version != g:Templates_VersionUse
		finish
	endif
	"
	" otherwise: skip ahead
	"
elseif exists('g:Templates_VersionSearch')
	"
	" add own version number to the list
	call add ( g:Templates_VersionSearch, s:Templates_Version )
	"
	finish
	"
else
	"
	"-------------------------------------------------------------------------------
	" s:VersionComp : Compare two version numbers.   {{{3
	"
	" Parameters:
	"   op1 - first version number (string)
	"   op2 - second version number (string)
	" Returns:
	"   result - -1, 0 or 1, to the specifications of sort() (integer)
	"-------------------------------------------------------------------------------
	function! s:VersionComp ( op1, op2 )
		"
		let l1 = split ( a:op1, '[.-]' )
		let l2 = split ( a:op2, '[.-]' )
		"
		for i in range( 0, max( [ len( l1 ), len( l2 ) ] ) - 1 )
			" until now, all fields where equal
			if len ( l2 ) <= i
				return -1                               " op1 has more fields -> sorts first
			elseif len( l1 ) <= i
				return 1                                " op2 has more fields -> sorts first
			elseif str2nr ( l1[i] ) > str2nr ( l2[i] )
				return -1                               " op1 is larger here -> sorts first
			elseif str2nr ( l2[i] ) > str2nr ( l1[i] )
				return 1                                " op2 is larger here -> sorts first
			endif
		endfor
		"
		return 0                                    " same amount of fields, all equal
	endfunction    " ----------  end of function s:VersionComp  ----------
	" }}}3
	"-------------------------------------------------------------------------------
	"
	try
		"
		" collect all available version
		let g:Templates_Version = 'searching'
		let g:Templates_VersionSearch = []
		"
		runtime! autoload/mmtemplates/core.vim
		"
		" select the newest one
		call sort ( g:Templates_VersionSearch, 's:VersionComp' )
		"
		let g:Templates_VersionUse = g:Templates_VersionSearch[ 0 ]
		"
		" run all scripts again, the newest one will be used
		runtime! autoload/mmtemplates/core.vim
		"
		unlet g:Templates_VersionSearch
		unlet g:Templates_VersionUse
		"
		finish
		"
	catch /.*/
		"
		" an error occurred, skip ahead
		echohl WarningMsg
		echomsg 'Search for the newest version number failed.'
		echomsg 'Using this version ('.s:Templates_Version.').'
		echohl None
	endtry
	"
endif
" }}}2
"-------------------------------------------------------------------------------
"
let g:Templates_Version = s:Templates_Version     " version number of this script; do not change
"
"----------------------------------------------------------------------
"  === Modul Setup ===   {{{1
"----------------------------------------------------------------------
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
		let { 'g:'.a:varname } = a:value
	endif
endfunction    " ----------  end of function s:ApplyDefaultSetting  ----------
"
"-------------------------------------------------------------------------------
" s:GetGlobalSetting : Get a setting from a global variable.   {{{2
"
" Parameters:
"   varname - name of the variable (string)
"   mode    - 'bin' (string, optional)
" Returns:
"   -
"
" If g:<varname> exists, assign:
"   s:<varname> = g:<varname>
" If the flag 'bin' is given as the second argument, translate an integer
" value of the global variable into a "yes" or "no" settings:
"   g:<varname> == 0  ->  s:<varname> = "no"
"   otherwise         ->  s:<varname> = "yes"
"-------------------------------------------------------------------------------
"
function! s:GetGlobalSetting ( varname, ... )
	if a:0 > 0 && a:1 == 'bin' && exists ( 'g:'.a:varname ) && type ( 0 ) == type ( { 'g:'.a:varname } )
		let { 's:'.a:varname } = { 'g:'.a:varname } == 0 ? 'no' : 'yes'
	elseif exists ( 'g:'.a:varname )
		let { 's:'.a:varname } = { 'g:'.a:varname }
	endif
	"
	let s:Templates_AllSettings[ a:varname ] = { 's:'.a:varname }
endfunction    " ----------  end of function s:GetGlobalSetting  ----------
"
" }}}2
"-------------------------------------------------------------------------------
"
" platform specifics
let s:MSWIN = has("win16") || has("win32")   || has("win64")     || has("win95")
let s:UNIX	= has("unix")  || has("macunix") || has("win32unix")
"
if s:MSWIN
	"
	"-------------------------------------------------------------------------------
	" MS Windows
	"-------------------------------------------------------------------------------
	"
	let s:plugin_dir = substitute( expand('<sfile>:p:h:h'), '\\', '/', 'g' )
	"
	" :TODO:27.08.2014 20:37:WM: check windows default browser
	let s:Templates_InternetBrowserExec  = 'C:\Program Files\Mozilla Firefox\firefox.exe'
	let s:Templates_InternetBrowserFlags = ''
	"
else
	"
	"-------------------------------------------------------------------------------
	" Linux/Unix
	"-------------------------------------------------------------------------------
	"
	let s:plugin_dir = expand('<sfile>:p:h:h')
	"
	let s:Templates_InternetBrowserExec  = 'firefox'
	let s:Templates_InternetBrowserFlags = ''
	"
endif
"
" user configurable settings
let s:Templates_OverwriteWarning = 'no'
let s:Templates_MapInUseWarn     = 'yes'
let s:Templates_TemplateBrowser  = 'explore'
"
let s:Templates_PersonalizationFile = 'templates/personal.template*'
let s:Templates_UsePersonalizationFile = 'yes'
"
let s:Templates_AllSettings = {}
"
call s:GetGlobalSetting ( 'Templates_OverwriteWarning', 'bin' )
call s:GetGlobalSetting ( 'Templates_MapInUseWarn', 'bin' )
call s:GetGlobalSetting ( 'Templates_TemplateBrowser' )
call s:GetGlobalSetting ( 'Templates_PersonalizationFile' )
call s:GetGlobalSetting ( 'Templates_UsePersonalizationFile' )
call s:GetGlobalSetting ( 'Templates_InternetBrowserExec' )
call s:GetGlobalSetting ( 'Templates_InternetBrowserFlags' )
"
" internally used variables
let s:DebugGlobalOverwrite = 0
let s:DebugLevel           = s:DebugGlobalOverwrite
"
let s:Flagactions = {
			\ ':i' : '',
			\ ':l' : ' (-> lowercase)',
			\ ':u' : ' (-> uppercase)',
			\ ':c' : ' (-> capitalize)',
			\ ':L' : ' (-> legalize name)',
			\ }
"
let s:StandardPriority = 500
"
let g:CheckedFiletypes = {}
"
"----------------------------------------------------------------------
"  s:StandardMacros : The standard macros.   {{{2
"----------------------------------------------------------------------
"
let s:StandardMacros = {
			\ 'BASENAME'       : '',
			\ 'FILENAME'       : '',
			\ 'PATH'           : '',
			\ 'SUFFIX'         : '',
			\
			\ 'DATE'           : '%x',
			\ 'DATE_PRETTY'    : '%B %d %Y',
			\ 'DATE_PRETTY1'   : '%B %d %Y',
			\ 'DATE_PRETTY2'   : '%b %d %Y',
			\ 'DATE_PRETTY3'   : '%x',
			\ 'TIME'           : '%X',
			\ 'TIME_PRETTY'    : '%X',
			\ 'YEAR'           : '%Y',
			\ 'YEAR_PRETTY'    : '%Y',
			\ 'TIME_LOCALE'    : '',
			\ }
"
"----------------------------------------------------------------------
"  s:StandardProperties : The standard properties.   {{{2
"----------------------------------------------------------------------
"
let s:StandardProperties = {
			\ 'Templates::EditTemplates::Map'   : 're',
			\ 'Templates::RereadTemplates::Map' : 'rr',
			\ 'Templates::SetupWizard::Map'     : 'rw',
			\ 'Templates::ChooseStyle::Map'     : 'rs',
			\
			\ 'Templates::EditTemplates::Shortcut'   : 'e',
			\ 'Templates::RereadTemplates::Shortcut' : 'r',
			\ 'Templates::SetupWizard::Shortcut'     : 'w',
			\ 'Templates::ChooseStyle::Shortcut'     : 's',
			\
			\ 'Templates::Mapleader' : '\',
			\
			\ 'Templates::UsePersonalizationFile' : s:Templates_UsePersonalizationFile,
			\
			\ 'Templates::Wizard::PluginName'             : '',
			\ 'Templates::Wizard::FiletypeName'           : '',
			\ 'Templates::Wizard::FileCustomNoPersonal'   : '',
			\ 'Templates::Wizard::FileCustomWithPersonal' : '',
			\ 'Templates::Wizard::FilePersonal'           : '',
			\ 'Templates::Wizard::CustomFileVariable'     : '',
			\ }
"
"----------------------------------------------------------------------
"  s:TypeNames : Name of types as characters.   {{{2
"----------------------------------------------------------------------
"
let s:TypeNames = [ ' ', ' ', ' ', ' ', ' ', ' ' ]
"
let s:TypeNames[ type(0)   ] = 'i'  " integer
let s:TypeNames[ type("")  ] = 's'  " string
let s:TypeNames[ type([])  ] = 'l'  " list
let s:TypeNames[ type({})  ] = 'd'  " dict
"let s:TypeNames[ type(0.0) ] = 'n'  " number
" TODO: why does float not work in some cases?
"       not important right now.
"
"----------------------------------------------------------------------
"  === Syntax: Regular Expressions ===   {{{1
"----------------------------------------------------------------------
"
"----------------------------------------------------------------------
"  s:RegexSettings : The essential tokens of the grammar.   {{{2
"----------------------------------------------------------------------
"
let s:RegexSettings = {
			\ 'MacroName'      : '[a-zA-Z_][a-zA-Z0-9_]*',
			\ 'MacroList'      : '\%([a-zA-Z_]\|[a-zA-Z_][a-zA-Z0-9_ \t,]*[a-zA-Z0-9_]\)',
			\ 'TemplateName'   : '[a-zA-Z_][a-zA-Z0-9_+\-\., ]*[a-zA-Z0-9_+\-\.,]',
			\ 'TextOpt'        : '[a-zA-Z_][a-zA-Z0-9_+\-: \t,]*[a-zA-Z0-9_+\-]',
			\ 'Mapping'        : '[a-zA-Z0-9+\-]\+',
			\
			\ 'CommentStart'   : '\$',
			\ 'BlockDelimiter' : '==',
			\
			\ 'CommentHint'    : '$',
			\ 'CommandHint'    : '[A-Z]',
			\ 'DelimHint'      : '=',
			\ 'MacroHint'      : '|',
			\
			\ 'MacroStart'     : '|',
			\ 'MacroEnd'       : '|',
			\ 'EditTagStart'   : '<',
			\ 'EditTagEnd'     : '>',
			\ 'JumpTag1Start'  : '{',
			\ 'JumpTag1End'    : '}',
			\ 'JumpTag2Start'  : '<',
			\ 'JumpTag2End'    : '>',
			\ }
"
"----------------------------------------------------------------------
"  s:UpdateFileReadRegex : Update the regular expressions.   {{{2
"----------------------------------------------------------------------
"
function! s:UpdateFileReadRegex ( regex, settings, interface )
	"
	let quote = '\(["'']\?\)'
	"
	" Basics
	let a:regex.MacroName     = a:settings.MacroName
	let a:regex.MacroNameC    = '\('.a:settings.MacroName.'\)'
	let a:regex.TemplateNameC = '\('.a:settings.TemplateName.'\)'
	let a:regex.Mapping       = a:settings.Mapping
	let a:regex.AbsolutePath  = '^[\~/]'                " TODO: Is that right and/or complete?
	"
	" Syntax Categories
	let a:regex.EmptyLine     = '^\s*$'
	let a:regex.CommentLine   = '^'.a:settings.CommentStart
	let a:regex.FunctionCall  = '^\s*'.a:regex.MacroNameC.'\s*(\(.*\))\s*$'
	let a:regex.MacroAssign   = '^\s*'.a:settings.MacroStart.a:regex.MacroNameC.a:settings.MacroEnd
				\                    .'\s*=\s*'.quote.'\(.\{-}\)'.'\2'.'\s*$'   " deprecated
	"
	" Blocks
	let delim                 = a:settings.BlockDelimiter
	let a:regex.Styles1Hint   = '^'.delim.'\s*IF\s\+|STYLE|\s\+IS\s'
	let a:regex.Styles1Start  = '^'.delim.'\s*IF\s\+|STYLE|\s\+IS\s\+'.a:regex.MacroNameC.'\s*'.delim
	let a:regex.Styles1End    = '^'.delim.'\s*ENDIF\s*'.delim

	let a:regex.Styles2Hint   = '^'.delim.'\s*USE\s\+STYLES\s*:'
	let a:regex.Styles2Start  = '^'.delim.'\s*USE\s\+STYLES\s*:'
				\                     .'\s*\('.a:settings.MacroList.'\)'.'\s*'.delim
	let a:regex.Styles2End    = '^'.delim.'\s*ENDSTYLES\s*'.delim
	"
	let a:regex.FiletypeHint  = '^'.delim.'\s*USE\s\+FILETYPES\s*:'
	let a:regex.FiletypeStart = '^'.delim.'\s*USE\s\+FILETYPES\s*:'
				\                     .'\s*\('.a:settings.MacroList.'\)'.'\s*'.delim
	let a:regex.FiletypeEnd   = '^'.delim.'\s*ENDFILETYPES\s*'.delim
	"
	" Texts
	let a:regex.TemplateHint  = '^'.delim.'\s*\%(TEMPLATE:\)\?\s*'.a:settings.TemplateName.'\s*'.delim
				\                     .'\s*\%(\('.a:settings.TextOpt.'\)\s*'.delim.'\)\?'
	let a:regex.TemplateStart = '^'.delim.'\s*\%(TEMPLATE:\)\?\s*'.a:regex.TemplateNameC.'\s*'.delim
				\                     .'\s*\%(\('.a:settings.TextOpt.'\)\s*'.delim.'\)\?'
	let a:regex.TemplateEnd   = '^'.delim.'\s*ENDTEMPLATE\s*'.delim
	"
	let a:regex.HelpHint      = '^'.delim.'\s*HELP:'
	let a:regex.HelpStart     = '^'.delim.'\s*HELP:\s*'.a:regex.TemplateNameC.'\s*'.delim
				\                     .'\s*\%(\('.a:settings.TextOpt.'\)\s*'.delim.'\)\?'
	"let a:regex.HelpEnd       = '^'.delim.'\s*ENDHELP\s*'.delim
	"
	let a:regex.MenuSepHint   = '^'.delim.'\s*SEP:'
	let a:regex.MenuSep       = '^'.delim.'\s*SEP:\s*'.a:regex.TemplateNameC.'\s*'.delim
	"
	let a:regex.ListHint      = '^'.delim.'\s*LIST:'
	let a:regex.ListStart     = '^'.delim.'\s*LIST:\s*'.a:regex.MacroNameC.'\s*'.delim
				\                     .'\s*\%(\('.a:settings.TextOpt.'\)\s*'.delim.'\)\?'
	let a:regex.ListEnd       = '^'.delim.'\s*ENDLIST\s*'.delim
	"
	" Special Hints
	let a:regex.CommentHint   = a:settings.CommentHint
	let a:regex.CommandHint   = a:settings.CommandHint
	let a:regex.DelimHint     = a:settings.DelimHint
	let a:regex.MacroHint     = a:settings.MacroHint
	"
endfunction    " ----------  end of function s:UpdateFileReadRegex  ----------
"
"----------------------------------------------------------------------
"  s:UpdateTemplateRegex : Update the regular expressions.   {{{2
"----------------------------------------------------------------------
"
function! s:UpdateTemplateRegex ( regex, settings, interface )
	"
	let quote = '["'']'
	"
	" Function Arguments
	let a:regex.RemoveQuote  = '^\s*'.quote.'\zs.*\ze'.quote.'\s*$'
	"
	" Basics
	let a:regex.MacroStart   = a:settings.MacroStart
	let a:regex.MacroEnd     = a:settings.MacroEnd
	let a:regex.MacroName    = a:settings.MacroName
	let a:regex.MacroNameC   = '\('.a:settings.MacroName.'\)'
	let a:regex.MacroMatch   = '^'.a:settings.MacroStart.a:settings.MacroName.a:settings.MacroEnd.'$'
	"
	" Syntax Categories
	let a:regex.FunctionLine    = '^'.a:settings.MacroStart.'\('.a:regex.MacroNameC.'(\(.*\))\)'.a:settings.MacroEnd.'\s*\n'
	let a:regex.FunctionChecked = '^'.a:regex.MacroNameC.'(\(.*\))$'
	let a:regex.FunctionList    = '^LIST(\(.\{-}\))$'
	let a:regex.FunctionComment = a:settings.MacroStart.'\(C\|Comment\)'.'(\(.\{-}\))'.a:settings.MacroEnd
	let a:regex.FunctionInsert  = a:settings.MacroStart.'\(Insert\|InsertLine\)'.'(\(.\{-}\))'.a:settings.MacroEnd
	let a:regex.MacroRequest    = a:settings.MacroStart.'?'.  a:regex.MacroNameC.   '\(:\a\)\?'. '\(%\%([-+*]\+\|[-+*]\?\d\+\)[lcr]\?\)\?'.a:settings.MacroEnd
	let a:regex.MacroInsert     = a:settings.MacroStart.'?\?'.a:regex.MacroNameC.   '\(:\a\)\?'. '\(%\%([-+*]\+\|[-+*]\?\d\+\)[lcr]\?\)\?'.a:settings.MacroEnd
	let a:regex.MacroNoCapture  = a:settings.MacroStart.'?\?'.a:settings.MacroName.'\%(:\a\)\?'.'\%(%[-+*]*\d*[lcr]\?\)\?'.                a:settings.MacroEnd
	let a:regex.ListItem        = a:settings.MacroStart.''.a:regex.MacroNameC.':ENTRY_*'.a:settings.MacroEnd
	let a:regex.LeftRightSep    = a:settings.MacroStart.'<\+>\+'.a:settings.MacroEnd
	"
	let a:regex.TextBlockFunctions = '^\%(C\|Comment\|Insert\|InsertLine\)$'
	"
	" Jump Tags
	let a:regex.JumpTagAll   = '<-\w*->\|{-\w*-}\|<+\w*+>\|{+\w*+}'
	let a:regex.JumpTagType2 = '<-\w*->\|{-\w*-}'
	"
	if a:interface >= 1000000
		let a:regex.JumpTagAll   = '<-\w*->\|{-\w*-}\|\[-\w*-]\|<+\w*+>\|{+\w*+}\|\[+\w*+]'
		let a:regex.JumpTagType2 = '<-\w*->\|{-\w*-}\|\[-\w*-]'
		let a:regex.JumpTagOpt   = '\[-\w*-]\|\[+\w*+]'
		let a:regex.JTListSep    = ','
	endif
	"
endfunction    " ----------  end of function s:UpdateTemplateRegex  ----------
" }}}2
"----------------------------------------------------------------------
"
"----------------------------------------------------------------------
"  === Script: Auxiliary Functions ===   {{{1
"----------------------------------------------------------------------
"
"----------------------------------------------------------------------
"  s:VersionCode : Get the numeric code for a version.   {{{2
"
"  The numeric code is 1e6 * major + 1e3 * minor + release.
"
"  Examples:
"  - s:VersionCode ( '1.0' )   -> 1000000
"  - s:VersionCode ( '1.2' )   -> 1002000
"  - s:VersionCode ( '1.3.2' ) -> 1003002
"----------------------------------------------------------------------
"
function! s:VersionCode ( version )
	"
	if -1 == match ( a:version, '^\%(\d\+\.\d\+\.\d\+\|\d\+\.\d\+\)$' )
		return -1
	endif
	"
	let mlist = matchlist ( a:version, '\(\d\+\)\.\(\d\+\)\%(\.\(\d\+\)\)\?' )
	"
	if empty( mlist )
		return -1
	endif
	"
	return 1000000 * str2nr( mlist[1] ) + 1000 * str2nr( mlist[2] ) + 1 * str2nr( mlist[3] )
	"
endfunction    " ----------  end of function s:VersionCode  ----------
"
"----------------------------------------------------------------------
"  s:ParameterTypes : Get the types of the arguments.   {{{2
"
"  Returns a string with one character per argument, denoting the type.
"  Uses the codebook 's:TypeNames'.
"
"  Examples:
"  - s:ParameterTypes ( 1, "string", [] ) -> "isl"
"  - s:ParameterTypes ( 1, 'string', {} ) -> "isd"
"  - s:ParameterTypes ( 1, 1.0 )          -> "in"
"----------------------------------------------------------------------
"
function! s:ParameterTypes ( ... )
	return join( map( copy( a:000 ), 's:TypeNames[ type ( v:val ) ]' ), '' )
endfunction    " ----------  end of function s:ParameterTypes  ----------
"
"----------------------------------------------------------------------
"  s:FunctionCheck : Check the syntax, name and parameter types.   {{{2
"
"  Throw a 'Template:Check:*' exception whenever:
"  - The syntax of the call "name( params )" is wrong.
"  - The function name 'name' is not a key in 'namespace'.
"  - The parameter string (as produced by s:ParameterTypes) does not match
"    the regular expression found in "namespace[name]".
"----------------------------------------------------------------------
"
function! s:FunctionCheck ( name, param, namespace )
	"
	" check the syntax and get the parameter string
	try
		exe 'let param_s = s:ParameterTypes( '.a:param.' )'
	catch /^Vim(let):E\d\+:/
		throw 'Template:Check:function call "'.a:name.'('.a:param.')": '.matchstr ( v:exception, '^Vim(let):E\d\+:\zs.*' )
	endtry
	"
	" check the function and the parameters
	if ! has_key ( a:namespace, a:name )
		throw 'Template:Check:unknown function: "'.a:name.'"'
	elseif param_s !~ '^'.a:namespace[ a:name ].'$'
		throw 'Template:Check:wrong parameter types: "'.a:name.'"'
	endif
	"
endfunction    " ----------  end of function s:FunctionCheck  ----------
"
"----------------------------------------------------------------------
"  s:LiteralReplacement : Substitute without using regular expressions.   {{{2
"----------------------------------------------------------------------
"
function! s:LiteralReplacement ( text, remove, insert, flag )
	return substitute( a:text,
				\ '\V'.escape( a:remove, '\' ),
				\      escape( a:insert, '\&~' ), a:flag )
"				\ '\='.string( a:insert      ), a:flag )
endfunction    " ----------  end of function s:LiteralReplacement  ----------
"
"----------------------------------------------------------------------
"  s:ConcatNormalizedFilename : Concatenate and normalize a filename.   {{{2
"----------------------------------------------------------------------
"
function! s:ConcatNormalizedFilename ( ... )
	if a:0 == 1
		let filename = ( a:1 )
	elseif a:0 == 2
		let filename = ( a:1 ).'/'.( a:2 )
	endif
	if filename == ''
		return ''
	endif
	return fnamemodify( filename, ':p' )
endfunction    " ----------  end of function s:ConcatNormalizedFilename  ----------
"
"----------------------------------------------------------------------
"  s:GetNormalizedPath : Split and normalize a path.   {{{2
"----------------------------------------------------------------------
"
function! s:GetNormalizedPath ( filename )
	return fnamemodify( a:filename, ':p:h' )
endfunction    " ----------  end of function s:GetNormalizedPath  ----------
"
"----------------------------------------------------------------------
"  s:UserInput : Input after a highlighted prompt.   {{{2
"  
"  3. argument : optional completion
"  4. argument : optional list, if the 3. argument is 'customlist'
"
"  Throws an exception 'Template:UserInputAborted' if the obtained input is empty,
"  so use it like this:
"    try
"      let style = s:UserInput( 'prompt', '', ... )
"    catch /Template:UserInputAborted/
"      return
"    endtry
"----------------------------------------------------------------------
"
" s:UserInputEx : ex-command for s:UserInput   {{{3
function! s:UserInputEx ( ArgLead, CmdLine, CursorPos )
	if empty( a:ArgLead )
		return copy( s:UserInputList )
	endif
	" The obvious choice here would be '\<' followed by the regular expression
	" which matches the argument lead. We use '\[0-9a-zA-Z]\@<!' as an
	" alternative, which means that underscores can also break up words.
	return filter( copy( s:UserInputList ), 'v:val =~ ''\V\[0-9a-zA-Z]\@<!'.escape(a:ArgLead,'\').'\w\*''' )
endfunction    " ----------  end of function s:UserInputEx  ----------
"
" s:UserInputList : list for s:UserInput   {{{3
let s:UserInputList = []
" }}}3
"
function! s:UserInput ( prompt, text, ... )
	"
	echohl Search																					" highlight prompt
	call inputsave()																			" preserve typeahead
	if a:0 == 0 || a:1 == ''
		let retval = input( a:prompt, a:text )
	elseif a:1 == 'customlist'
		let s:UserInputList = a:2
		let retval = input( a:prompt, a:text, 'customlist,<SNR>'.s:SID().'_UserInputEx' )
		let s:UserInputList = []
	else
		let retval = input( a:prompt, a:text, a:1 )
	endif
	call inputrestore()																		" restore typeahead
	echohl None																						" reset highlighting
	"
	if empty( retval )
		throw 'Template:UserInputAborted'
	endif
	"
	let retval  = substitute( retval, '^\s\+', "", "" )		" remove leading whitespaces
	let retval  = substitute( retval, '\s\+$', "", "" )		" remove trailing whitespaces
	"
	return retval
	"
endfunction    " ----------  end of function s:UserInput ----------
"
"-------------------------------------------------------------------------------
" s:DebugMsg : Print debug information.   {{{2
"-------------------------------------------------------------------------------
function! s:DebugMsg ( lvl, ... )
	if s:DebugLevel < a:lvl
		return
	endif
	"
	for line in a:000
		echomsg line
	endfor
endfunction    " ----------  end of function s:DebugMsg  ----------
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
function! s:ErrorMsg ( ... )
	echohl WarningMsg
	for line in a:000
		echomsg line
	endfor
	echohl None
endfunction    " ----------  end of function s:ErrorMsg  ----------
"
"-------------------------------------------------------------------------------
" s:GetVisualArea : Get the visual area.   {{{2
"
" Get the visual area using the register " and reset the register afterwards.
"
" Parameters:
"   -
" Returns:
"   selection - the visual selection (string)
"
" Credits:
"   The solution is take from Jeremy Cantrell, vim-opener, which is distributed
"   under the same licence as Vim itself.
"-------------------------------------------------------------------------------
function! s:GetVisualArea ()
	" windows:  register @* does not work
	" solution: recover area of the visual mode and yank,
	"           puts the selected area into the register @"
	"
	" save contents of register " and the 'clipboard' setting
	" set clipboard to it default value
	let reg_save     = getreg('"')
	let regtype_save = getregtype('"')
	let cb_save      = &clipboard
	set clipboard&
	"
	" get the register
	normal! gv""y
	let res = @"
	"
	" reset register " and 'clipboard'
	call setreg ( '"', reg_save, regtype_save )
	let &clipboard = cb_save
	"
	return res
endfunction    " ----------  end of function s:GetVisualArea  ----------
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
function! s:ImportantMsg ( ... )
	echohl Search
	echo join ( a:000, "\n" )
	echohl None
endfunction    " ----------  end of function s:ImportantMsg  ----------
"
"-------------------------------------------------------------------------------
" s:OpenFold : Open fold and go to the first or last line of this fold.   {{{2
"
" If the cursor is on a closed fold at the "start" of the file or "below" the
" cursor, open it and move the cursor appropriately.
"
" Parameters:
"   mode - "start" or "below" (string)
" Returns:
"   -
"-------------------------------------------------------------------------------
function! s:OpenFold ( mode )
	if foldclosed(".") < 0
		return
	endif
	" we are on a closed fold:
	" get end position, open fold,
	" jump to the last line of the previously closed fold
	let foldstart = foldclosed(".")
	let foldend		= foldclosedend(".")
	normal! zv
	if a:mode == 'below'
		exe ":".foldend
	elseif a:mode == 'start'
		exe ":".foldstart
	endif
endfunction    " ----------  end of function s:OpenFold  ----------
"
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
endfun
"
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
"----------------------------------------------------------------------
"
"----------------------------------------------------------------------
"  mmtemplates#core#NewLibrary : Create a new template library.   {{{1
"----------------------------------------------------------------------
"
function! mmtemplates#core#NewLibrary ( ... )

	" ==================================================
	"  options
	" ==================================================

	let api_version_str = '0.9'
	let api_version     = s:VersionCode ( api_version_str )

	let i = 1
	while i <= a:0

		if a:[i] == 'api_version' && i+1 <= a:0
			let api_version_str = a:[i+1]
			let api_version     = s:VersionCode ( api_version_str )
			if api_version == -1
				call s:ErrorMsg ( 'Invalid version number: "'.api_version_str.'"' )
				let api_version_str = '0.9'
				let api_version     = s:VersionCode ( api_version_str )
			endif
			let i += 2
		elseif a:[i] == 'debug' && i+1 <= a:0 && ! s:DebugGlobalOverwrite
			let s:DebugLevel = a:[i+1]
			let i += 2
		else
			if type ( a:[i] ) == type ( '' ) | call s:ErrorMsg ( 'Unknown option: "'.a:[i].'"' )
			else                             | call s:ErrorMsg ( 'Unknown option at position '.i.'.' ) | endif
			let i += 1
		endif

	endwhile

	" ==================================================
	"  data
	" ==================================================

	" library
	let library   = {
				\ 'api_version_str' : api_version_str,
				\ 'api_version'     : api_version,
				\ 'interface_str'   : '0.9',
				\ 'interface'       : ( s:VersionCode('0.9') ),
				\
				\ 'macros'         : {},
				\ 'properties'     : {},
				\ 'resources'      : {},
				\ 'templates'      : {},
				\
				\ 'menu_order'     : [],
				\
				\ 'styles'         : [ 'default' ],
				\ 'current_style'  : 'default',
				\
				\ 'menu_shortcuts' : {},
				\ 'menu_existing'  : { 'base' : 0 },
				\
				\ 'regex_settings' : ( copy ( s:RegexSettings ) ),
				\ 'regex_file'     : {},
				\ 'regex_template' : {},
				\
				\ 'namespace_file'      : s:FileReadNameSpace_0_9,
				\ 'namespace_templ_std' : s:NamespaceStdTempl_0_9,
				\ 'namespace_templ_ins' : s:NamespaceStdTemplInsert_0_9,
				\ 'namespace_templ_hlp' : s:NamespaceHelp_0_9,
				\
				\ 'library_files'  : [],
				\ }
	" entries used by maps: 'map_commands!<filetype>'

	let library.macros.AUTHOR = 'YOUR NAME'
	call extend ( library.macros,     s:StandardMacros,     'keep' )
	call extend ( library.properties, s:StandardProperties, 'keep' )

	call s:UpdateFileReadRegex ( library.regex_file,     library.regex_settings, library.interface )
	call s:UpdateTemplateRegex ( library.regex_template, library.regex_settings, library.interface )

	" ==================================================
	"  wrap up
	" ==================================================

	let s:DebugLevel = s:DebugGlobalOverwrite   " reset debug

	return library      " return the new library

endfunction    " ----------  end of function mmtemplates#core#NewLibrary  ----------
"
"----------------------------------------------------------------------
"  === Read Templates: Auxiliary Functions ===   {{{1
"----------------------------------------------------------------------
"
"----------------------------------------------------------------------
"  s:TemplateTypeNames : Readable type names for templates.   {{{2
"----------------------------------------------------------------------
"
let s:TemplateTypeNames = {
			\ 'help' : 'help',
			\ 'sep'  : 'separator',
			\ 't'    : 'template',
			\ }
"
"----------------------------------------------------------------------
"  s:AddText : Add a text.   {{{2
"----------------------------------------------------------------------
"
function! s:AddText ( type, name, settings, lines )
	"
	if a:type == 'help'
		call s:AddTemplate ( 'help', a:name, a:settings, a:lines )
	elseif a:type == 'list'
		call s:AddList ( 'list', a:name, a:settings, a:lines )
	elseif a:type == 'template'
		call s:AddTemplate ( 't', a:name, a:settings, a:lines )
	endif
	"
endfunction    " ----------  end of function s:AddText  ----------
"
"----------------------------------------------------------------------
"  s:AddList : Add a list.   {{{2
"----------------------------------------------------------------------
"
function! s:AddList ( type, name, settings, lines )
	"
	" ==================================================
	"  checks
	" ==================================================
	"
	" Error: empty name
	if empty ( a:name )
		call s:ErrorMsg ( 'List name can not be empty.' )
		return
	endif
	"
	" Warning: empty list
	if empty ( a:lines )
		call s:ErrorMsg ( 'Warning: Empty list: "'.a:name.'"' )
	endif
	"
	" Warning: already existing
	if s:t_runtime.overwrite_warning && has_key ( s:library.resources, 'list!'.a:name )
		call s:ErrorMsg ( 'Warning: Overwriting list "'.a:name.'"' )
	endif
	"
	" ==================================================
	"  settings
	" ==================================================
	"
	let type  = 'list'
	let bare  = 0
	"
	for s in a:settings
		"
		if s == 'list'
			let type = 'list'
		elseif s == 'hash' || s == 'dict' || s == 'dictionary'
			let type = 'dict'
		elseif s == 'bare'
			let bare = 1
		else
			call s:ErrorMsg ( 'Warning: Unknown setting in list "'.a:name.'": "'.s.'"' )
		endif
		"
	endfor
	"
	if type == 'list'
		if bare
			let lines = escape( a:lines, '"' )
			let lines = substitute( lines, '^\s*',     '"',    '' )
			let lines = substitute( lines, '\s*\n$',   '"',    '' )
			let lines = substitute( lines, '\s*\n\s*', '", "', 'g' )
			exe 'let list = [ '.lines.' ]'
		else
			exe 'let list = [ '.substitute( a:lines, '\n', ' ', 'g' ).' ]'
		end
		call sort ( list )
	elseif type == 'dict'
		if bare
			s:ErrorMsg ( 'bare hash: to be implemented' )
		else
			exe 'let list = { '.substitute( a:lines, '\n', ' ', 'g' ).' }'
		end
	endif
	"
	let s:library.resources[ 'list!'.a:name ] = list
	"
endfunction    " ----------  end of function s:AddList  ----------
"
"----------------------------------------------------------------------
"  s:AddTemplate : Add a template.   {{{2
"----------------------------------------------------------------------
"
function! s:AddTemplate ( type, name, settings, lines )
	"
	let name = a:name
	"
	" ==================================================
	"  checks
	" ==================================================
	"
	" Error: empty name
	if empty ( name )
		call s:ErrorMsg ( 'Template name can not be empty.' )
		return
	endif
	"
	" Warning: empty template
	if empty ( a:lines )
		call s:ErrorMsg ( 'Warning: Empty template: "'.name.'"' )
	endif
	"
	" ==================================================
	"  new template
	" ==================================================
	"
	if has_key ( s:library.templates, name.'!!type' )
		let my_type    = a:type
		let other_type = s:library.templates[ name.'!!type' ].type
		"
		if my_type != other_type
			if my_type == 't'
				call s:ErrorMsg ( 'Template "'.name.'" can not overwrite an object of the same name of type "'.s:TemplateTypeNames[other_type].'".' )
			elseif my_type == 'help'
				call s:ErrorMsg ( 'Help template "'.name.'" can not overwrite an object of the same name of type "'.s:TemplateTypeNames[other_type].'".' )
			endif
			return
		endif
	else
		"
		" --------------------------------------------------
		"  new template
		" --------------------------------------------------
		let s:library.templates[ name.'!!type' ] = {
					\ 'type'        : a:type,
					\ 'placement'   : 'below',
					\ 'indentation' : 1,
					\ }
		let s:library.templates[ name.'!!menu' ] = {
					\ 'filetypes' : s:t_runtime.use_filetypes,
					\ 'visual'    : -1 != stridx ( a:lines, '<SPLIT>' ),
					\ 'map'       : '',
					\ 'entry'     : 1,
					\ 'mname'     : '',
					\ 'shortcut'  : '',
					\ }
		" when "entry == 2" these entries also appear:
		" - expand_list
		" - expand_left
		" - expand_right
		"
		" TODO: review this
		if a:type == 'help'
			let s:library.templates[ name.'!!type' ].placement = 'help'
		endif
		"
		call add ( s:library.menu_order, name )
		"
	endif
	"
	" --------------------------------------------------
	"  settings
	" --------------------------------------------------
	"
	let templ_type = s:library.templates[ name.'!!type' ]
	let templ_menu = s:library.templates[ name.'!!menu' ]
	"
	for s in a:settings
		"
		if s == 'start' || s == 'above' || s == 'below' || s == 'append' || s == 'insert'
			let templ_type.placement = s

			" indentation
		elseif s == 'indent'
			let templ_type.indentation = 1
		elseif s == 'noindent'
			let templ_type.indentation = 0

			" special insertion in visual mode:
		elseif s == 'visual'
			let templ_menu.visual = 1
		elseif s == 'novisual'
			let templ_menu.visual = 0

			" map:
		elseif s =~ '^map\s*:'
			let templ_menu.map = matchstr ( s, '^map\s*:\s*\zs'.s:library.regex_file.Mapping )

			" entry and shortcut:
		elseif s == 'nomenu'
			let templ_menu.entry = 0
		elseif s == 'expandmenu'
			let templ_menu.entry = 2
			if ! has_key ( templ_menu, 'expand_list' )
				let templ_menu.expand_list  = ''
				let templ_menu.expand_left  = ''
				let templ_menu.expand_right = ''
			endif
		elseif s =~ '^expandmenu\s*:'
			let templ_menu.entry = 2
			if s:library.interface < 1000000
				call s:ErrorMsg ( 'The option "expandmenu:..." with an explicitly named list is only available for libraries using versions >= 1.0.' )
			else
				if ! has_key ( templ_menu, 'expand_list' )
					let templ_menu.expand_left  = ''
					let templ_menu.expand_right = ''
				endif
				let templ_menu.expand_list = matchstr ( s, '^expandmenu\s*:\s*\zs'.s:library.regex_file.MacroName )
			endif
		elseif s =~ '^expandleft\s*:'
			if s:library.interface < 1000000
				call s:ErrorMsg ( 'The option "expandleft:..." is only available for libraries using versions >= 1.0.' )
			else
				let templ_menu.expand_left = matchstr ( s, '^expandleft\s*:\s*\zs.*' )
				let templ_menu.expand_left = s:HandleMenuExpandOptions ( templ_menu.expand_left )
				" :TODO:04.01.2015 17:35:WM: error handling, disallowed options, ...
			endif
		elseif s =~ '^expandright\s*:'
			if s:library.interface < 1000000
				call s:ErrorMsg ( 'The option "expandright:..." is only available for libraries using versions >= 1.0.' )
			else
				let templ_menu.expand_right = matchstr ( s, '^expandright\s*:\s*\zs.*' )
				let templ_menu.expand_right = s:HandleMenuExpandOptions ( templ_menu.expand_right )
				" :TODO:04.01.2015 17:35:WM: error handling, disallowed options, ...
			endif
		elseif s =~ '^sc\s*:' || s =~ '^shortcut\s*:'
			let templ_menu.shortcut = matchstr ( s, '^\w\+\s*:\s*\zs'.s:library.regex_file.Mapping )

		else
			call s:ErrorMsg ( 'Warning: Unknown setting in template "'.name.'": "'.s.'"' )
		endif
		"
	endfor
	"
	" ==================================================
	"  text
	" ==================================================
	"
	" the styles
	if a:type == 'help'
		" Warning: overwriting a style
		if s:t_runtime.overwrite_warning && has_key ( s:library.templates, name.'!default' )
			call s:ErrorMsg ( 'Warning: Overwriting a help template: "'.name.'"' )
		endif
		let s:library.templates[ name.'!default' ] = a:lines
		return
	elseif empty ( s:t_runtime.use_styles )
		let styles = [ 'default' ]
	else
		let styles = s:t_runtime.use_styles
	endif
	"
	" save the lines
	for s in styles
		"
		" Warning: overwriting a style
		if s:t_runtime.overwrite_warning && has_key ( s:library.templates, name.'!'.s )
			call s:ErrorMsg ( 'Warning: Overwriting style in template "'.name.'": "'.s.'"' )
		endif
		"
		let s:library.templates[ name.'!'.s ] = a:lines
		"
	endfor
	"
endfunction    " ----------  end of function s:AddTemplate  ----------
"
"----------------------------------------------------------------------
"  s:AddSeparator : Add a menu separator.   {{{2
"----------------------------------------------------------------------
"
function! s:AddSeparator ( type, name, settings )
	"
	let name = a:name
	"
	" ==================================================
	"  checks
	" ==================================================
	"
	" Error: empty name
	if empty ( name )
		call s:ErrorMsg ( 'Separator name can not be empty.' )
		return
	endif
	"
	" ==================================================
	"  new separator
	" ==================================================
	"
	if has_key ( s:library.templates, name.'!!type' )
		"
		let my_type    = a:type
		let other_type = s:library.templates[ name.'!!type' ].type
		"
		if my_type != other_type
			call s:ErrorMsg ( 'Separator "'.name.'" can not overwrite an object of the same name of type "'.s:TemplateTypeNames[other_type].'".' )
			return
		endif
	else
		"
		let s:library.templates[ name.'!!type' ] = { 'type'  : 'sep', }
		let s:library.templates[ name.'!!menu' ] = { 'entry' : 11, }
		"
		call add ( s:library.menu_order, name )
		"
	endif
	"
endfunction    " ----------  end of function s:AddSeparator  ----------
"
"----------------------------------------------------------------------
"  s:AddStyles : Add styles to the list.   {{{2
"----------------------------------------------------------------------
"
function! s:AddStyles ( styles )
	"
	" TODO: check for valid name
	" add the styles to the list
	for s in a:styles
		if -1 == index ( s:library.styles, s )
			call add ( s:library.styles, s )
		endif
	endfor
	"
endfunction    " ----------  end of function s:AddStyles  ----------
"
"----------------------------------------------------------------------
"  s:UseStyles : Set the styles.   {{{2
"----------------------------------------------------------------------
"
function! s:UseStyles ( styles )
	"
	" 'use_styles' empty? -> we may have new styles
	" otherwise           -> must be a subset, so no new styles
	if empty ( s:t_runtime.use_styles )
		" add the styles to the list
		call s:AddStyles ( a:styles )
	else
		" are the styles a sub-set of the currently used styles?
		for s in a:styles
			if -1 == index ( s:t_runtime.use_styles, s )
				call s:ErrorMsg ( 'Style "'.s.'" currently not in use.' )
				return
			endif
		endfor
	endif
	"
	" push the new style and use it as the current style
	call add ( s:t_runtime.styles_stack, a:styles )
	let  s:t_runtime.use_styles = a:styles
	"
endfunction    " ----------  end of function s:UseStyles  ----------
"
"----------------------------------------------------------------------
"  s:RevertStyles : Revert the styles.   {{{2
"----------------------------------------------------------------------
"
function! s:RevertStyles ( times )
	"
	" get the current top, and check whether any more styles can be removed
	let state_lim = s:t_runtime.state_stack[-1].style_stack_top
	let state_top = len( s:t_runtime.styles_stack )
	"
	if state_lim > ( state_top - a:times )
		call s:ErrorMsg ( 'Can not close any more style sections.' )
		return
	endif
	"
	" remove the top
	call remove ( s:t_runtime.styles_stack, -1 * a:times, -1 )
	"
	" reset the current style
	if state_top > a:times
		let s:t_runtime.use_styles = s:t_runtime.styles_stack[ -1 ]
	else
		let s:t_runtime.use_styles = []
	endif
	"
endfunction    " ----------  end of function s:RevertStyles  ----------
"
"----------------------------------------------------------------------
"  s:UseFiletypes : Set the filetypes.   {{{2
"----------------------------------------------------------------------
"
function! s:UseFiletypes ( filetypes )
	"
	if s:library.interface < 1000000
		call s:ErrorMsg ( 'The expression "USE FILETYPES: ..." is only available for libraries using versions >= 1.0.' )
		return
	endif
	"
	" 'filetypes_stack' empty? -> we may have new filetypes
	" otherwise                -> must be a subset, so no new filetypes
	if empty ( s:t_runtime.filetypes_stack )
		" :TODO:05.09.2013 19:26:WM: Call 'AddFiletypes' ?
		" add the filetypes to the list
		"call s:AddFiletypes ( a:filetypes )
	else
		" are the filetypes a sub-set of the currently used filetypes?
		for s in a:filetypes
			if -1 == index ( s:t_runtime.use_filetypes, s )
				call s:ErrorMsg ( 'Filetype "'.s.'" currently not in use.' )
				return
			endif
		endfor
	endif
	"
	" push the new filetype and use it as the current filetype
	call add ( s:t_runtime.filetypes_stack, copy ( a:filetypes ) )
	if empty ( a:filetypes )
		let s:t_runtime.use_filetypes = [ 'default' ]
	else
		let s:t_runtime.use_filetypes = copy ( a:filetypes )
	endif
	"
endfunction    " ----------  end of function s:UseFiletypes  ----------
"
"----------------------------------------------------------------------
"  s:RevertFiletypes : Revert the filetypes.   {{{2
"----------------------------------------------------------------------
"
function! s:RevertFiletypes ( times )
	"
	if s:library.interface < 1000000
		call s:ErrorMsg ( 'The expression "USE FILETYPES: ..." is only available for libraries using versions >= 1.0.' )
		return
	endif
	"
	" get the current top, and check whether any more filetypes can be removed
	let state_lim = s:t_runtime.state_stack[-1].filetype_stack_top
	let state_top = len( s:t_runtime.filetypes_stack )
	"
	if state_lim > ( state_top - a:times )
		call s:ErrorMsg ( 'Can not close any more filetype sections.' )
		return
	endif
	"
	" remove the top
	call remove ( s:t_runtime.filetypes_stack, -1 * a:times, -1 )
	"
	" reset the current filetype
	if state_top > a:times
		let s:t_runtime.use_filetypes = s:t_runtime.filetypes_stack[ -1 ]
	elseif s:library.interface >= 1000000
		let s:t_runtime.use_filetypes = [ 'default' ]
	else
		let s:t_runtime.use_filetypes = []
	endif
	"
endfunction    " ----------  end of function s:RevertFiletypes  ----------
"
"-------------------------------------------------------------------------------
" s:HandleMenuExpandOptions : Handle "expandleft:..." and "expandright:..." {{{2
"-------------------------------------------------------------------------------
"
function! s:HandleMenuExpandOptions ( option )
	"
	if a:option == 'key'
		return '|KEY|'
	elseif a:option == 'key-notags'
		return '|KEY:T|'
	elseif a:option == 'key-whitetags'
		return '|KEY:W|'
	elseif a:option == 'value'
		return '|VALUE|'
	elseif a:option == 'value-notags'
		return '|VALUE:T|'
	elseif a:option == 'value-whitetags'
		return '|VALUE:W|'
	endif
	"
	" error
	return ''
endfunction    " ----------  end of function s:HandleMenuExpandOptions  ----------
"
"-------------------------------------------------------------------------------
" s:InterfaceVersionRuntimeUpdates : Set the library version (runtime info).   {{{2
"-------------------------------------------------------------------------------
"
function! s:InterfaceVersionRuntimeUpdates ()
	"
	" version 1.0 setup
	if s:library.interface >= 1000000
		let s:t_runtime.use_filetypes = [ 'default' ]
	endif
	"
	" version 1.1 setup
	if s:library.interface >= 1001000
		" ...
	endif
	"
endfunction    " ----------  end of function s:InterfaceVersionRuntimeUpdates  ----------
" }}}2
"----------------------------------------------------------------------
"
"----------------------------------------------------------------------
"  === Read Templates: Template File Namespace ===   {{{1
"----------------------------------------------------------------------
"
"----------------------------------------------------------------------
"  s:FileReadNameSpace : The set of functions a template file can call.   {{{2
"----------------------------------------------------------------------
"
let s:FileReadNameSpace_0_9 = {
			\ 'InterfaceVersion' : 's',
			\
			\ 'IncludeFile'  : 'ss\?',
			\ 'SetFormat'    : 'ss',
			\ 'SetMacro'     : 'ss',
			\ 'SetPath'      : 'ss',
			\ 'SetProperty'  : 'ss',
			\ 'SetStyle'     : 's',
			\
			\ 'SetMap'       : 'ss',
			\ 'SetShortcut'  : 'ss',
			\ 'SetMenuEntry' : 'ss',
			\ 'SetExpansion' : 'sss\?',
			\
			\ 'MenuShortcut' : 'ss',
			\ }
"
"----------------------------------------------------------------------
"  s:InterfaceVersion : Set the library version (template function).   {{{2
"----------------------------------------------------------------------
"
function! s:InterfaceVersion ( version_str )
	"
	" :TODO:22.04.2014 08:20:WM: check whether templates, lists, were already
	" defined, check whether style, or filetype sections were already used, ...
	"
	let version_id = s:VersionCode ( a:version_str )
	"
	" check for valid version number
	if version_id == -1
		call s:ErrorMsg ( 'Illigal version name: '.a:version_str )
		return
	elseif s:library.interface != 9000 && s:library.interface != version_id
		call s:ErrorMsg ( 'Trying to set library version '.a:version_str.', but already set '.s:library.interface_str.' before.' )
		return
	endif
	"
	if s:library.interface == version_id
		return
	endif
	"
	let s:library.interface_str = a:version_str
	let s:library.interface     = version_id
	"
	" version 1.0 setup
	if s:library.interface >= 1000000
		let s:library.namespace_templ_hlp = s:NamespaceHelp_1_0
	endif
	"
	" version 1.1 setup
	if s:library.interface >= 1001000
		" ...
	endif
	"
	" version 1.0+ syntax
	if s:library.interface >= 1000000
		call s:UpdateTemplateRegex ( s:library.regex_template, s:library.regex_settings, s:library.interface )
	endif
	"
	" version 1.0+ runtime environment
	if s:library.interface >= 1000000
		call s:InterfaceVersionRuntimeUpdates ()
	endif
	"
endfunction    " ----------  end of function s:InterfaceVersion  ----------
"
"----------------------------------------------------------------------
"  s:SetFormat : Set the format of |DATE|, ... (template function).   {{{2
"----------------------------------------------------------------------
"
function! s:SetFormat ( name, replacement )

	" check for valid name
	if a:name !~ s:library.regex_file.MacroName
		call s:ErrorMsg ( 'Macro name must be a valid identifier: '.a:name )
		return
	elseif a:name !~ '^\%(TIME.*\|DATE.*\|YEAR.*\)'
		call s:ErrorMsg ( 'Can not set the format of: '.a:name )
		return
	elseif a:name == 'TIME_LOCALE'

		let save_time_lang = v:lc_time

		try
			silent exe 'language time '.a:replacement
		catch /E197:.*/
			call s:ErrorMsg ( 'Can not set the time locale to "'.a:replacement.'".' )
			return
		finally
			silent exe 'language time '.save_time_lang
		endtry
	endif

	let s:library.macros[ a:name ] = a:replacement

endfunction    " ----------  end of function s:SetFormat  ----------
"
"----------------------------------------------------------------------
"  s:SetMacro : Set a replacement (template function).   {{{2
"----------------------------------------------------------------------
"
function! s:SetMacro ( name, replacement )
	"
	" check for valid name
	if a:name !~ s:library.regex_file.MacroName
		call s:ErrorMsg ( 'Macro name must be a valid identifier: '.a:name )
		return
	elseif has_key ( s:StandardMacros, a:name )
		call s:ErrorMsg ( 'The special macro "'.a:name.'" can not be replaced via SetMacro.' )
		return
	endif
	"
	let s:library.macros[ a:name ] = a:replacement
	"
endfunction    " ----------  end of function s:SetMacro  ----------
"
"----------------------------------------------------------------------
"  s:SetStyle : Set the current style (template function).   {{{2
"----------------------------------------------------------------------
"
function! s:SetStyle ( name )
	"
	" check for valid name
	if a:name !~ s:library.regex_file.MacroName
		call s:ErrorMsg ( 'Style name must be a valid identifier: '.a:name )
		return
	endif
	"
	let s:library.current_style = a:name
	"
endfunction    " ----------  end of function s:SetStyle  ----------
"
"----------------------------------------------------------------------
"  s:SetPath : Set a path-resource (template function).   {{{2
"----------------------------------------------------------------------
"
function! s:SetPath ( name, value )
	"
	" check for valid name
	if a:name !~ s:library.regex_file.MacroName
		call s:ErrorMsg ( 'Path name must be a valid identifier: '.a:name )
		return
	endif
	"
	call mmtemplates#core#Resource ( s:library, 'set', 'path', a:name, a:value )
	"
endfunction    " ----------  end of function s:SetPath  ----------
"
"----------------------------------------------------------------------
"  s:MenuShortcut : Set a shortcut for a sub-menu (template function).   {{{2
"----------------------------------------------------------------------
"
function! s:MenuShortcut ( name, shortcut )
	"
	" check for valid shortcut
	if len ( a:shortcut ) > 1
		call s:ErrorMsg ( 'The shortcut for "'.a:name.'" must be a single character.' )
		return
	endif
	"
	let name = substitute( a:name, '\.$', '', '' )
	"
	let s:library.menu_shortcuts[ name ] = a:shortcut
	"
endfunction    " ----------  end of function s:MenuShortcut  ----------
"
"----------------------------------------------------------------------
"  s:SetMap : Set the map of a template (template function).   {{{2
"----------------------------------------------------------------------
"
function! s:SetMap ( name, map )
	"
	" check for valid name and format
	if ! has_key ( s:library.templates, a:name.'!!type' )
		return s:ErrorMsg ( 'The template does not exist: '.a:name )
	elseif -1 == match ( a:map, '^'.s:library.regex_file.Mapping.'$' )
		return s:ErrorMsg ( 'The new map has an illegal format: '.a:map )
	endif
	"
	let s:library.templates[ a:name.'!!menu' ].map = a:map
	"
endfunction    " ----------  end of function s:SetMap  ----------
"
"----------------------------------------------------------------------
"  s:SetProperty : Set an existing property.   {{{2
"----------------------------------------------------------------------
"
function! s:SetProperty ( name, value )
	"
	let [ _, err ] = mmtemplates#core#Resource ( s:library, 'set', 'property', a:name , a:value )
	"
	if err != ''
		return s:ErrorMsg ( 'Can not set the property "'.a:name.'".' )
	endif
	"
endfunction    " ----------  end of function s:SetProperty  ----------
"
"----------------------------------------------------------------------
"  s:SetShortcut : Set the shortcut of a template (template function).   {{{2
"----------------------------------------------------------------------
"
function! s:SetShortcut ( name, shortcut )
	"
	" check for valid name and format
	if ! has_key ( s:library.templates, a:name.'!!type' )
		return s:ErrorMsg ( 'The template does not exist: '.a:name )
	elseif len ( a:shortcut ) > 1
		return s:ErrorMsg ( 'The new shortcut must be a single character: '.a:shortcut )
	elseif -1 == match ( a:shortcut, '^'.s:library.regex_file.Mapping.'$' )
		return s:ErrorMsg ( 'The new shortcut has an illegal format: '.a:shortcut )
	endif
	"
	let s:library.templates[ a:name.'!!menu' ].shortcut = a:shortcut
	"
endfunction    " ----------  end of function s:SetShortcut  ----------
"
"-------------------------------------------------------------------------------
" s:SetMenuEntry : Set the menu entry of a template (template function).   {{{2
"-------------------------------------------------------------------------------
"
function! s:SetMenuEntry ( name, menu_entry )
	"
	" check for valid name and format
	if ! has_key ( s:library.templates, a:name.'!!type' )
		return s:ErrorMsg ( 'The template does not exist: '.a:name )
	elseif a:menu_entry == ''
		return s:ErrorMsg ( 'The menu entry can not empty.' )
	endif
	"
	let s:library.templates[ a:name.'!!menu' ].mname = a:menu_entry
	"
endfunction    " ----------  end of function s:SetMenuEntry  ----------
"
"----------------------------------------------------------------------
" s:SetExpansion : Set the expansion of a list menu (template function).   {{{2
"-------------------------------------------------------------------------------

function! s:SetExpansion ( name, expand_left, ... )

	let expand_left = a:expand_left
	if a:0 >= 1 | let expand_right = a:1
	else        | let expand_right = ''
	endif

	" check for valid name and format
	if ! has_key ( s:library.templates, a:name.'!!type' )
		return s:ErrorMsg ( 'The template does not exist: '.a:name )
	endif

	let templ_menu = s:library.templates[ a:name.'!!menu' ]

	if templ_menu.entry != 2
		let templ_menu.entry        = 2
		let templ_menu.expand_list  = ''
	endif

	let templ_menu.expand_left  = expand_left
	let templ_menu.expand_right = expand_right

endfunction    " ----------  end of function s:SetExpansion  ----------

"----------------------------------------------------------------------
"  s:IncludeFile : Read a template file (template function).   {{{2
"----------------------------------------------------------------------
"
function! s:IncludeFile ( templatefile, ... )
	"
	let regex = s:library.regex_file
	"
	let read_abs = 0
	if a:0 >= 1 && a:1 == 'abs'
		let read_abs = 1
	endif
	"
	" ==================================================
	"  checks
	" ==================================================
	"
	" Expand ~, $HOME, ... and check for absolute path
	let templatefile = expand( a:templatefile )
	"
" 	if templatefile =~ regex.AbsolutePath
" 		let templatefile = s:ConcatNormalizedFilename ( templatefile )
" 	else
"		let templatefile = s:ConcatNormalizedFilename ( s:t_runtime.state_stack[-1].current_path, templatefile )
" 	endif
	if read_abs
		let templatefile = s:ConcatNormalizedFilename ( templatefile )
	else
		let templatefile = s:ConcatNormalizedFilename ( s:t_runtime.state_stack[-1].current_path, templatefile )
	endif
	"
	" file does not exists or was already visited?
	if !filereadable( templatefile )
		throw 'Template:Check:file "'.templatefile.'" does not exist or is not readable'
	elseif has_key ( s:t_runtime.files_visited, templatefile )
		throw 'Template:Check:file "'.templatefile.'" already read'
	endif
	"
	" ==================================================
	"  setup
	" ==================================================
	"
	" add to the state stack
	call add ( s:t_runtime.state_stack, {
				\ 'current_path'       : s:GetNormalizedPath( templatefile ),
				\ 'style_stack_top'    : len( s:t_runtime.styles_stack ),
				\ 'filetype_stack_top' : len( s:t_runtime.filetypes_stack ),
				\ } )
	"
	" mark file as read
	let s:t_runtime.files_visited[templatefile] = 1
	"
	" debug:
	call s:DebugMsg ( 3, 'Reading '.templatefile.' ...' )
	"
	let state        = 'command'
	let t_start      = 0
	let last_section = ''
	"
	" ==================================================
	"  go trough the file
	" ==================================================
	"
	let filelines = readfile( templatefile )
	"
	for line in filelines
		"
		let firstchar = line[0]
		"
		" which state
		if state == 'command'
			" ==================================================
			"  state: command
			" ==================================================
			"
			" empty line? 
			if empty ( line )
				continue
			endif
			"
			" comment?
			if firstchar == regex.CommentHint
				if line =~ regex.CommentLine
					continue
				endif
			endif
			"
			" macro line? --- |MACRO| = something
			if firstchar == regex.MacroHint
				"
				let mlist = matchlist ( line, regex.MacroAssign )
				if ! empty ( mlist )
					" STYLE, includefile or general macro
					if mlist[1] == 'STYLE'
						call s:SetStyle ( mlist[3] )
					elseif mlist[1] == 'includefile'
						try
							call s:IncludeFile ( mlist[3], 'old' )
						catch /Template:Check:.*/
							let msg = v:exception[ len( 'Template:Check:') : -1 ]
							call s:ErrorMsg ( 'While loading "'.templatefile.'":', msg )
						endtry
					else
						call s:SetMacro ( mlist[1], mlist[3] )
					endif
					continue
				endif
				"
			endif
			"
			" function call? --- Function( param_list )
			if firstchar =~ regex.CommandHint
				"
				let mlist = matchlist ( line, regex.FunctionCall )
				if ! empty ( mlist )
					let [ name, param ] = mlist[ 1 : 2 ]
					"
					try
						" check the call
						call s:FunctionCheck ( name, param, s:library.namespace_file )
						" try to call
						exe 'call s:'.name.' ( '.param.' ) '
					catch /Template:Check:.*/
						let msg = v:exception[ len( 'Template:Check:') : -1 ]
						call s:ErrorMsg ( 'While loading "'.templatefile.'":', msg )
					catch //
						call s:ErrorMsg ( 'While calling "'.name.'" in "'.templatefile.'":', v:exception )
					endtry
					"
					continue
				endif
				"
			endif
			"
			" section or text?
			if firstchar == regex.DelimHint
				"
				" switch styles?
				let mlist = matchlist ( line, regex.Styles1Start )
				if ! empty ( mlist )
					call s:UseStyles ( [ mlist[1] ] )
					let last_section = mlist[0]
					continue
				endif
				"
				" switch styles?
				if line =~ regex.Styles1End
					call s:RevertStyles ( 1 )
					continue
				endif
				"
				" switch styles?
				let mlist = matchlist ( line, regex.Styles2Start )
				if ! empty ( mlist )
					call s:UseStyles ( split( mlist[1], '\s*,\s*' ) )
					let last_section = mlist[0]
					continue
				endif
				"
				" switch styles?
				if line =~ regex.Styles2End
					call s:RevertStyles ( 1 )
					continue
				endif
				"
				" switch filetypes?
				let mlist = matchlist ( line, regex.FiletypeStart )
				if ! empty ( mlist )
					call s:UseFiletypes ( split( mlist[1], '\s*,\s*' ) )
					let last_section = mlist[0]
					continue
				endif
				"
				" switch filetypes?
				if line =~ regex.FiletypeEnd
					call s:RevertFiletypes ( 1 )
					continue
				endif
				"
				" separator?
				let mlist = matchlist ( line, regex.MenuSep )
				if ! empty ( mlist )
					call s:AddSeparator ( 'sep', mlist[1], '' )
					continue
				endif
				"
				" start of text?
				let mlist_template = matchlist ( line, regex.TemplateStart )
				let mlist_help     = matchlist ( line, regex.HelpStart )
				let mlist_list     = matchlist ( line, regex.ListStart )
				if ! empty ( mlist_template )
					let state   = 'text'
					let t_type  = 'template'
					let t_start = 1
				elseif ! empty ( mlist_help )
					let state   = 'text'
					let t_type  = 'help'
					let t_start = 1
				elseif ! empty ( mlist_list )
					let state   = 'text'
					let t_type  = 'list'
					let t_start = 1
				endif
				"
			endif
			"
			" empty line?
			if line =~ regex.EmptyLine
				continue
			endif
			"
		elseif state == 'text'
			" ==================================================
			"  state: text
			" ==================================================
			"
			if firstchar == regex.CommentHint || firstchar == regex.DelimHint
				"
				" comment or end of template?
				if line =~ regex.CommentLine
							\ || line =~ regex.TemplateEnd
							\ || line =~ regex.ListEnd
					let state = 'command'
					call s:AddText ( t_type, t_name, t_settings, t_lines )
					continue
				endif
				"
				" start of new text?
				let mlist_template = matchlist ( line, regex.TemplateStart )
				let mlist_help     = matchlist ( line, regex.HelpStart )
				let mlist_list     = matchlist ( line, regex.ListStart )
				if ! empty ( mlist_template )
					call s:AddText ( t_type, t_name, t_settings, t_lines )
					let t_type  = 'template'
					let t_start = 1
				elseif ! empty ( mlist_help )
					call s:AddText ( t_type, t_name, t_settings, t_lines )
					let t_type  = 'help'
					let t_start = 1
				elseif ! empty ( mlist_list )
					call s:AddText ( t_type, t_name, t_settings, t_lines )
					let t_type  = 'list'
					let t_start = 1
				else
					let t_lines .= line."\n"    " read the line
					continue
				endif
				"
			else
				let t_lines .= line."\n"      " read the line
				continue
			endif
			"
		endif
		"
		" start of template?
		if t_start
			if t_type == 'template'
				let t_name     = mlist_template[1]
				let t_settings = split( mlist_template[2], '\s*,\s*' )
			elseif t_type == 'list'
				let t_name     = mlist_list[1]
				let t_settings = split( mlist_list[2], '\s*,\s*' )
			elseif t_type == 'help'
				let t_name     = mlist_help[1]
				let t_settings = split( mlist_help[2], '\s*,\s*' )
			endif
			let t_lines    = ''
			let t_start    = 0
			continue
		endif
		"
		call s:ErrorMsg ( 'Failed to read line: '.line )
		"
	endfor
	"
	" ==================================================
	"  wrap up
	" ==================================================
	"
	if state == 'text'
		call s:AddText ( t_type, t_name, t_settings, t_lines )
	endif
	"
	" all style sections closed?
	let state_lim = s:t_runtime.state_stack[-1].style_stack_top
	let state_top = len( s:t_runtime.styles_stack )
	if state_lim < state_top
		call s:RevertStyles ( state_top - state_lim )
		call s:ErrorMsg ( 'Section has not been closed: '.last_section )
	endif
	"
	" all filetype sections closed?
	let state_lim = s:t_runtime.state_stack[-1].filetype_stack_top
	let state_top = len( s:t_runtime.filetypes_stack )
	if s:library.interface >= 1000000 && state_lim < state_top
		call s:RevertFiletypes ( state_top - state_lim )
		call s:ErrorMsg ( 'Section has not been closed: '.last_section )
	endif
	"
	" debug:
	call s:DebugMsg ( 3, '... '.templatefile.' done.' )
	"
	" restore the previous state
	call remove ( s:t_runtime.state_stack, -1 )
	"
endfunction    " ----------  end of function s:IncludeFile  ----------
" }}}2
"----------------------------------------------------------------------

"----------------------------------------------------------------------
"  mmtemplates#core#ReadTemplates : Read a template file.   {{{1
"----------------------------------------------------------------------
"
function! mmtemplates#core#ReadTemplates ( library, ... )
	"
	" ==================================================
	"  parameters
	" ==================================================
	"
	if type( a:library ) == type( '' )
		exe 'let t_lib = '.a:library
	elseif type( a:library ) == type( {} )
		let t_lib = a:library
	else
		return s:ErrorMsg ( 'Argument "library" must be given as a dict or string.' )
	endif
	"
	" ==================================================
	"  setup
	" ==================================================
	"
	" library and runtime information
	" setup for interface version 0.9, libraries call InterfaceVersion() anyway
	let s:library   = t_lib
	let s:t_runtime = {
				\ 'state_stack'     : [],
				\ 'use_styles'      : [],
				\ 'styles_stack'    : [],
				\ 'use_filetypes'   : [],
				\ 'filetypes_stack' : [],
				\ 'files_visited'   : {},
				\
				\ 'overwrite_warning' : s:Templates_OverwriteWarning == 'yes',
				\ }
	"
	if s:library.interface >= 1000000
		call s:InterfaceVersionRuntimeUpdates ()
	endif
	"
	let mode = ''
	let file = ''
	let optional_file = 0
	let hidden_file   = 0
	let reload_map    = ''
	let reload_sc     = ''
	let symbolic_name = ''
	"
	" ==================================================
	"  options
	" ==================================================
	"
	let i = 1
	while i <= a:0
		"
		if a:[i] == 'load' && i+1 <= a:0
			let mode = 'load'
			let file = a:[i+1]
			let i += 2
		elseif a:[i] == 'reload' && i+1 <= a:0
			let mode = 'reload'
			let file = a:[i+1]
			let i += 2
		elseif a:[i] == 'personalization'
			let mode = 'load'
			let file = mmtemplates#core#FindPersonalizationFile ( s:library )
			let symbolic_name = 'personal'
			let optional_file = 1
			"
			let i += 1
		elseif a:[i] == 'map' && i+1 <= a:0
			let reload_map = a:[i+1]
			let i += 2
		elseif a:[i] == 'shortcut' && i+1 <= a:0
			let reload_sc = a:[i+1]
			let i += 2
		elseif a:[i] == 'name' && i+1 <= a:0
			let symbolic_name = a:[i+1]
			let i += 2
		elseif a:[i] == 'optional'
			let optional_file = 1
			let i += 1
		elseif a:[i] == 'hidden'
			let optional_file = 1
			let hidden_file   = 1
			let i += 1
		elseif a:[i] == 'overwrite_warning'
			let s:t_runtime.overwrite_warning = 1
			let i += 1
		elseif a:[i] == 'debug' && i+1 <= a:0 && ! s:DebugGlobalOverwrite
			let s:DebugLevel = a:[i+1]
			let i += 2
		else
			if type ( a:[i] ) == type ( '' ) | call s:ErrorMsg ( 'Unknown option: "'.a:[i].'"' )
			else                             | call s:ErrorMsg ( 'Unknown option at position '.i.'.' ) | endif
			let i += 1
		endif
		"
	endwhile
	"
	" ==================================================
	"  files
	" ==================================================
	"
	let templatefiles = []
	"
	if mode == 'load'
		"
		" check the type
		if type( file ) != type( '' )
			return s:ErrorMsg ( 'Argument "filename" must be given as a string.' )
		endif
		"
		" expand ~, $HOME, ... and normalize
		let file = s:ConcatNormalizedFilename ( expand ( file, 1 ) )
		let available = filereadable ( file )
		"
		if available
			call add ( templatefiles, file )
		elseif ! optional_file                      " optional and hidden files do not cause this warning
			call s:ErrorMsg ( 'The template file "'.file.'",', 'named "'.symbolic_name.'", does not exist or is not readable.' )
		endif
		"
		" add to library
		let fileinfo = {
					\ 'filename'   : file,
					\ 'reload_map' : reload_map,
					\ 'reload_sc'  : reload_sc,
					\ 'sym_name'   : symbolic_name,
					\ 'available'  : available,
					\ 'optional'   : optional_file,
					\ 'hidden'     : hidden_file && ! available,
					\ }
		call add ( t_lib.library_files, fileinfo )
		"
	elseif mode == 'reload'
		"
		if type( file ) == type( 0 )
			if empty( get( t_lib.library_files, file, [] ) )
				return s:ErrorMsg ( 'No template file with index '.file.'.' )
			endif
			if t_lib.library_files[ file ].available
				call add ( templatefiles, t_lib.library_files[ file ].filename )
			endif
		elseif type( file ) == type( '' )
			" load all or a specific file
			if file == 'all'
				for fileinfo in t_lib.library_files
					if fileinfo.available
						call add ( templatefiles, fileinfo.filename )
					endif
				endfor
			else
				"
				" check and add the file
				let file = expand ( file )
				let file = s:ConcatNormalizedFilename ( file )
				"
				if ! filereadable ( file )
					return s:ErrorMsg ( 'The file "'.file.'" does not exist.' )
				else
					let found_file = 0
					for fileinfo in t_lib.library_files
						if fileinfo.filename == file && fileinfo.available
							let found_file = 1
							break
						endif
					endfor
					if found_file == 0
						return s:ErrorMsg ( 'The file "'.file.'" is not part of the template library.' )
					endif
				endif
				"
				call add ( templatefiles, file )
				"
			endif
		else
			return s:ErrorMsg ( 'Argument "fileid" must be given as an integer or string.' )
		endif
		"
		" remove old maps
		for key in keys( t_lib )
			if key =~ '^map_commands!'
				call remove ( t_lib, key )
			endif
		endfor
		"
	endif
	"
	" ==================================================
	"  read the library
	" ==================================================
	"
	" debug:
	let time_start = reltime()
	"
	for f in templatefiles
		"
		" file exists?
		if !filereadable ( f )
			call s:ErrorMsg ( 'The template file "'.f.'" does not exist or is not readable.' )
			continue
		endif
		"
		" runtime information:
		" - set up the state stack: length of styles_stack + current path
		let s:t_runtime.state_stack = [ {
					\ 'current_path'       : s:GetNormalizedPath( f ),
					\ 'style_stack_top'    : 0,
					\ 'filetype_stack_top' : 0,
					\ } ]
		let s:t_runtime.styles_stack    = []
		let s:t_runtime.filetypes_stack = []
		"
		" read the top-level file
		try
			call s:IncludeFile ( f, 'abs' )
		catch /Template:Check:.*/
			let msg = v:exception[ len( 'Template:Check:') : -1 ]
			call s:ErrorMsg ( 'While loading "'.f.'":', msg )
		endtry
		"
	endfor
	"
	call sort ( s:library.styles )          " sort the styles
	"
	" debug:
	if ! empty ( templatefiles )
		call s:DebugMsg ( 2, 'Loading library ('.templatefiles[0].'): '.reltimestr( reltime( time_start ) ) )
	endif
	"
	"
	if mode == 'reload'
		echo 'Reloaded the template library.'
	endif
	"
	" ==================================================
	"  wrap up
	" ==================================================
	"
	unlet s:library                             " remove script variables
	unlet s:t_runtime                           " ...
	"
	let s:DebugLevel = s:DebugGlobalOverwrite   " reset debug
	"
endfunction    " ----------  end of function mmtemplates#core#ReadTemplates  ----------
"
"-------------------------------------------------------------------------------
" mmtemplates#core#EnableTemplateFile : Enable a template file.   {{{1
"-------------------------------------------------------------------------------
"
function! mmtemplates#core#EnableTemplateFile ( library, sym_name, ... )
	"
	" ==================================================
	"  parameters
	" ==================================================
	"
	let new_filename = ''
	"
	if a:0 >= 1
		let new_filename = a:1
	endif
	"
	if type( a:library ) == type( '' )
		exe 'let t_lib = '.a:library
	elseif type( a:library ) == type( {} )
		let t_lib = a:library
	else
		return s:ErrorMsg ( 'Argument "library" must be given as a dict or string.' )
	endif
	"
	if type( a:sym_name ) != type( '' )
		return s:ErrorMsg ( 'Argument "sym_name" must be given as a string.' )
	elseif type( new_filename ) != type( '' )
		return s:ErrorMsg ( 'Argument "new_filename" must be given as a string.' )
	endif
	"
	" ==================================================
	"  enable
	" ==================================================
	"
	let symbolic_name = a:sym_name
	let fileinfo_use = {}
	"
	for fileinfo in t_lib.library_files
		if fileinfo.sym_name == symbolic_name
			let fileinfo_use = fileinfo
		endif
	endfor
	"
	if symbolic_name == 'personal'
		let file = mmtemplates#core#FindPersonalizationFile ( t_lib )
		"
		if ! empty ( file )
			let fileinfo_use.filename  = file     " the filename was empty before
			let fileinfo_use.available = 1        " file is readable now
			let fileinfo_use.hidden    = 0        " ... and visible
		endif
	else
		if new_filename != '' && filereadable ( new_filename )
			let fileinfo_use.filename = new_filename
		endif
		if filereadable ( fileinfo_use.filename )
			let fileinfo_use.available = 1        " file is readable now
			let fileinfo_use.hidden    = 0        " ... and visible
		endif
	endif
	"
	return
endfunction    " ----------  end of function mmtemplates#core#EnableTemplateFile  ----------
"
"----------------------------------------------------------------------
" === Templates ===   {{{1
"----------------------------------------------------------------------
"
"-------------------------------------------------------------------------------
" s:ApplyFlag : Modify a text according to 'flag' and 'format'.   {{{2
"
" Parameters:
"   text   - the text (string)
"   flag   - the flag (string)
"   format - the format specifier (string)
"   width  - width of the macro (integer)
" Returns:
"   text   - the modified text (string)
"
" For a description of the meaning of the flags and formats see:
"   :help template-support-templ-macro
"
" Flags:
"   :l :u :c - change the case
"   :L :T :W - modify the text
" Format:
"   % [-+*]+ [lcr]?
"   % [-+*]?\d+ [lcr]?
"-------------------------------------------------------------------------------
"
function! s:ApplyFlag ( text, flag, format, width )
	"
	let text = a:text
	"
	" apply a flag?
	if a:flag == '' || a:flag == 'i'      " i : identity
		" noop
	elseif a:flag == 'l'                  " l : lowercase
		let text = tolower(a:text)
	elseif a:flag == 'u'                  " u : uppercase
		let text = toupper(a:text)
	elseif a:flag == 'c'                  " c : capitalize
		let text = toupper(a:text[0]).a:text[1:]
	elseif a:flag == 'L'                  " L : legalized name
		let text = substitute( a:text, '\s\+', '_', 'g' ) " multiple whitespaces
		let text = substitute(   text, '\W\+', '_', 'g' ) " multiple non-word characters
		let text = substitute(   text, '_\+',  '_', 'g' ) " multiple underscores
		let text = text
	elseif a:flag == 'T'                  " T : remove tags
		let text = substitute( a:text, '<R\?CURSOR>\|{R\?CURSOR}\|<SPLIT>', '', 'g' ) " cursor and split tags
		let text = substitute(   text, s:library.regex_template.JumpTagAll, '', 'g' ) " jump tags
		let text = text
	elseif a:flag == 'W'                  " W : replace tags with whitespaces
		let text = substitute( a:text, '<R\?CURSOR>\|{R\?CURSOR}\|<SPLIT>', ' ', 'g' ) " cursor and split tags
		let text = substitute(   text, s:library.regex_template.JumpTagAll, ' ', 'g' ) " jump tags
		let text = text
	else                                  " flag not valid
		" noop
	endif
	"
	" apply a format specifier?
	if a:format != ''
		"
		" last character -> the alignment (optional)
		let align = matchstr ( a:format, '[lcr]$' )
		"
		" contains a number? -> use this width
		if a:format =~ '\d'
			let width = str2nr ( matchstr ( a:format, '^[-+]\?\zs\d\+' ) )
		else
			let width = a:width
		endif
		"
		" first character a minus? -> cutoff
		let cutoff = a:format[0] == '-'
		"
		if len ( text ) >= width
			if ! cutoff
				let text = text
			else
				let text = text[:(width-1)]
			endif
		else
			let pad = width - len ( text )
			"
			if align == 'l' || align == ''
				let text = text . repeat ( ' ', pad )                     " alignment: left
			elseif align == 'r'
				let text = repeat ( ' ', pad ) . text                     " alignment: right
			elseif align == 'c'
				let text = repeat ( ' ', pad/2 ) . text . repeat ( ' ', pad/2 + pad%2 ) " alignment: center
			else
				let text = 'ALIGNMENT FAILED!!! PLEASE REPORT!!!'
			endif
		end
	endif
	"
	return text
	"
endfunction    " ----------  end of function s:ApplyFlag  ----------
"
"----------------------------------------------------------------------
" s:ReplaceMacros : Replace all the macros in a text.   {{{2
"----------------------------------------------------------------------
"
function! s:ReplaceMacros ( text, m_local )
	"
	let regex_macro = '\(.\{-}\)'.s:library.regex_template.MacroInsert.'\(\_.*\)'
	let regex_lrsep = '\(.\{-}\)\s*'.s:library.regex_template.LeftRightSep.'\s*\(\_.*\)'
	"
	let text_res = ''
	"
	" split lines (keep newline)
	for line_raw in split( a:text, '\n\zs' )
		"
		let line_width = len ( line_raw )
		"
		let line_res  = ''
		let line_tail = line_raw
		"
		" search for macros
		while 1
			"
			let mlist = matchlist ( line_tail, regex_macro )
			"
			" no more macros?
			if empty ( mlist )
				let line_res .= line_tail                                 " assemble the result
				break
			endif
			"
			" check for recursion
			if -1 != index ( s:t_runtime.macro_stack, mlist[2] )
				let m_text = ''
				call add ( s:t_runtime.macro_stack, mlist[2] )
				throw 'Template:MacroRecursion'
			end
			"
			" has local replacement?
			if has_key ( a:m_local, mlist[2] )
				let m_text = get ( a:m_local, mlist[2] )                  " get local replacement
			else
				let m_text = get ( s:library.macros, mlist[2], '' )       " try to get global replacement
			end
			"
			" the replacement text contains macros itself?
			if m_text =~ s:library.regex_template.MacroNoCapture
				"
				call add ( s:t_runtime.macro_stack, mlist[2] )            " add to the macro stack (for recursion checks)
				"
				let m_text = s:ReplaceMacros ( m_text, a:m_local )        " replace the macros in the replacement text
				"
				call remove ( s:t_runtime.macro_stack, -1 )               " revert the stack
				"
			endif
			"
			" apply flag?
			if ! empty ( mlist[3] ) || ! empty ( mlist[4] )
				let width  = 2 + len ( mlist[2] ) + len ( mlist[3] ) + len ( mlist[4] )
				let m_text = s:ApplyFlag ( m_text, mlist[3][1:], mlist[4][1:], width )   " apply flags to the replacement text
			endif
			"
			let line_res .= mlist[1].m_text                             " assemble the result
			let line_tail = mlist[5]
			"
		endwhile
		"
		" special: left-right separator
		if line_res =~ s:library.regex_template.LeftRightSep
			let mlist = matchlist ( line_res, regex_lrsep )
			"
			let text_l = mlist[1]
			let text_r = mlist[2]
			"
			let pad = max ( [ line_width - len ( text_l ) - len ( text_r ), 1 ] )
			"
			let line_res = text_l.repeat( ' ', pad ).text_r
		endif
		"
		let text_res .= line_res
	endfor
	"
	return text_res
	"
endfunction    " ----------  end of function s:ReplaceMacros  ----------
"
"----------------------------------------------------------------------
" s:NamespaceHelp : Namespace of help templates.   {{{2
"----------------------------------------------------------------------
"
let s:NamespaceHelp_0_9 = {
			\ 'Word'       : 's',
			\ 'Pattern'    : 's',   'Default'    : 's',
			\ 'Substitute' : 'sss', 'LiteralSub' : 'sss',
			\ 'System'     : 's',   'Vim'        : 's',
			\ }
"
let s:NamespaceHelp_1_0 = copy ( s:NamespaceHelp_0_9 )
"
let s:NamespaceHelp_1_0.Browser = 'ss\?'
let s:NamespaceHelp_1_0.System  = 'ss\?'
let s:NamespaceHelp_1_0.Vim     = 'ss\?'
"
"----------------------------------------------------------------------
" s:CheckHelp : Check a template (help).   {{{2
"
" Perform the following actions:
" - none (none are required as of now)
"----------------------------------------------------------------------
"
function! s:CheckHelp ( cmds, text, calls )
	return [ a:cmds, a:text ]
endfunction    " ----------  end of function s:CheckHelp  ----------
"
"----------------------------------------------------------------------
" s:NamespaceStdTempl : Namespace of standard templates.   {{{2
"----------------------------------------------------------------------
"
" command-block in front of the template
let s:NamespaceStdTempl_0_9 = {
			\ 'DefaultMacro' : 's[sl]',
			\ 'PickFile'     : 'ss',
			\ 'PickList'     : 's[sld]',
			\ 'Prompt'       : 'ss',
			\ 'SurroundWith' : 's[sl]*',
			\ }
"
" commands appearing in the text itself
let s:NamespaceStdTemplInsert_0_9 = {
			\ 'Comment'    : 's\?',
			\ 'Insert'     : 's[sl]*',
			\ 'InsertLine' : 's[sl]*',
			\ }
"
"----------------------------------------------------------------------
" s:CheckStdTempl : Check a template (standard).   {{{2
"
" Perform the following actions:
"----------------------------------------------------------------------
"
function! s:CheckStdTempl ( cmds, text, calls )
	"
	let regex = s:library.regex_template
	let ms    = regex.MacroStart
	let me    = regex.MacroEnd
	"
	let cmds = a:cmds
	let text = a:text
	"
	let prompted = {}
	"
	" --------------------------------------------------
	"  replacements
	" --------------------------------------------------
	"
	let pos = 0
	"
	while 1
		"
		let pos = match ( text, regex.MacroRequest, pos )
		"
		" no more macros?
		if pos == -1
			break
		endif
		"
		let mlist = matchlist ( text, regex.MacroRequest, pos )
		"
		let pos += len ( mlist[0] )
		"
		let m_name = mlist[1]
		let m_flag = mlist[2]
		let m_frmt = mlist[3]
		"
		" not a special macro and not already done?
		if has_key ( s:StandardMacros, m_name )
			call s:ErrorMsg ( 'The special macro "'.m_name.'" can not be replaced via |?'.m_name.'|.' )
		elseif ! has_key ( prompted, m_name )
			let cmds .= "Prompt(".string(m_name).",".string(m_flag[1:]).")\n"
			let prompted[ m_name ] = 1
		endif
		"
	endwhile
	"
	" --------------------------------------------------
	"  lists
	" --------------------------------------------------
	let list_items = [ 'EMPTY', 'SINGLE', 'FIRST', 'LAST' ]   " + 'ENTRY'
	"
	while 1
		"
		let mlist = matchlist ( text, regex.ListItem )
		"
		" no more macros?
		if empty ( mlist )
			break
		endif
		"
		let l_name = mlist[1]
		"
		let mlist = matchlist ( text,
					\ '\([^'."\n".']*\)'.ms.l_name.':ENTRY_*'.me.'\([^'."\n".']*\)\n' )
		"
		let cmds .= "LIST(".string(l_name).","
					\ .string(mlist[1]).",".string(mlist[2]).")\n"
		let text  = s:LiteralReplacement ( text,
					\ mlist[0], ms.l_name.':LIST'.me."\n", '' )
		"
		for item in list_items
			"
			let mlist = matchlist ( text,
						\ '\([^'."\n".']*\)'.ms.l_name.':'.item.'_*'.me.'\([^'."\n".']*\)\n' )
			"
			if empty ( mlist )
				let cmds .= "\n"
				continue
			endif
			"
			let cmds .= "[".string(mlist[1]).",".string(mlist[2])."]\n"
			let text  = s:LiteralReplacement ( text, mlist[0], '', '' )
		endfor
		"
	endwhile
	"
	" --------------------------------------------------
	"  comments
	" --------------------------------------------------
	while 1
		"
		let mlist = matchlist ( text, regex.FunctionComment )
		"
		" no more comments?
		if empty ( mlist )
			break
		endif
		"
		let [ f_name, f_param ] = mlist[ 1 : 2 ]
		"
		" check the call
		call s:FunctionCheck ( 'Comment', f_param, s:library.namespace_templ_ins )
		"
		exe 'let flist = ['.f_param.']'
		"
		if empty ( flist ) | let flag = 'eol'
		else               | let flag = flist[0] | endif
		"
		let mlist = matchlist ( text, regex.FunctionComment.'\s*\([^'."\n".']*\)' )
		"
		let text = s:LiteralReplacement ( text, mlist[0],
					\ ms.'InsertLine("Comments.end-of-line","|CONTENT|",'.string( mlist[3] ).')'.me, '' )
		"
	endwhile
	"
	return [ cmds, text ]
	"
endfunction    " ----------  end of function s:CheckStdTempl  ----------
"
"----------------------------------------------------------------------
" s:CheckTemplate : Check a template.   {{{2
"
" Perform the following actions:
" - get the command and text block
" - check the calls in the command block
" - perform further checks depending on the type
"----------------------------------------------------------------------
"
function! s:CheckTemplate ( template, type )
	"
	let regex = s:library.regex_template
	"
	let cmds          = ''
	let text          = ''
	let calls         = []
	"
	" the known functions
	if a:type == 't'
		let namespace = s:library.namespace_templ_std
	elseif a:type == 'help'
		let namespace = s:library.namespace_templ_hlp
	endif
	"
	" go trough the lines
	let idx = 0
	while idx < len ( a:template )
		"
		let idx_n = stridx ( a:template, "\n", idx )
		let mlist = matchlist ( a:template[ idx : idx_n ], regex.FunctionLine )
		"
		" no match or 'Comment' or 'Insert' function?
		if empty ( mlist ) || mlist[ 2 ] =~ regex.TextBlockFunctions
			break
		endif
		"
		let [ f_name, f_param ] = mlist[ 2 : 3 ]
		"
		" check the call
		call s:FunctionCheck ( f_name, f_param, namespace )
		"
		call add ( calls,  [ f_name, f_param ] )
		"
		let cmds .= mlist[1]."\n"
		let idx  += len ( mlist[0] )
		"
	endwhile
	"
	let text = a:template[ idx : -1 ]
	"
	" checks depending on the type
	if a:type == 't'
		return s:CheckStdTempl( cmds, text, calls )
	elseif a:type == 'help'
		return s:CheckHelp( cmds, text, calls )
	endif
	"
endfunction    " ----------  end of function s:CheckTemplate  ----------
"
"----------------------------------------------------------------------
" s:GetTemplate : Get a template.   {{{2
"----------------------------------------------------------------------
"
function! s:GetTemplate ( name, style )
	"
	let name  = a:name
	let style = a:style
	"
	" check the template
	if has_key ( s:library.templates, name.'!!type' )
		let info = s:library.templates[ a:name.'!!type' ]
	else
		throw 'Template:Prepare:template does not exist'
	endif
	"
	if style == '!any'
		for s in s:library.styles
			if has_key ( s:library.templates, name.'!'.s )
				let template = get ( s:library.templates, name.'!'.s )
				let style    = s
			endif
		endfor
	else
		" check the style
		if has_key ( s:library.templates, name.'!'.style )
			let template = get ( s:library.templates, name.'!'.style )
		elseif has_key ( s:library.templates, name.'!default' )
			let template = get ( s:library.templates, name.'!default' )
			let style    = 'default'
		elseif style == 'default'
			throw 'Template:Prepare:template does not have the default style'
		else
			throw 'Template:Prepare:template has neither the style "'.style.'" nor the default style'
		endif
	endif
	"
	" check the text
	let head = template[ 0 : 5 ]
	"
	if head == "|P()|\n"          " plain text
		" TODO: special type for plain
		let cmds = ''
		let text = template[ 6 : -1 ]
	elseif head == "|T()|\n"      " only text (contains only macros without '?')
		let cmds = ''
		let text = template[ 6 : -1 ]
	elseif head == "|C()|\n"      " command and text block
		let splt = stridx ( template, "|T()|\n" ) - 1
		let cmds = template[ 6 : splt ]
		let text = template[ splt+7 : -1 ]
	else
		"
		" do checks
		let [ cmds, text ] = s:CheckTemplate ( template, info.type )
		"
		" save the result
		if empty ( cmds )
			let template = "|T()|\n".text
		else
			let template = "|C()|\n".cmds."|T()|\n".text
		end
		let s:library.templates[ a:name.'!'.style  ] = template
		"
	end
	"
	return [ cmds, text, info.type, info.placement, info.indentation ]
endfunction    " ----------  end of function s:GetTemplate  ----------
"
"----------------------------------------------------------------------
" s:GetPickList : Get the list used in a template.   {{{2
"----------------------------------------------------------------------
"
function! s:GetPickList ( name, ... )
	"
	let regex = s:library.regex_template
	"
	" get the template
	let [ cmds, text, type, placement, indentation ] = s:GetTemplate ( a:name, '!any' )
	"
	if type != 't'
		call s:ErrorMsg ( 'Template "'.a:name.'" can not have a list to pick.' )
		return []
	endif
		"
	if a:0 == 0 || a:1 == '' || a:1 == '?'
		for line in split( cmds, "\n" )
			" the line will match and it will be a valid function
			let [ f_name, f_param ] = matchlist ( line, regex.FunctionChecked )[ 1 : 2 ]
			"
			if f_name == 'PickList'
				"
				exe 'let [ _, listarg ] = [ '.f_param.' ]'
				"
				let entry = ''
				"
				if type ( listarg ) == type ( '' )
					if ! has_key ( s:library.resources, 'list!'.listarg )
						call s:ErrorMsg ( 'In template "'.a:name.'":', 'List "'.listarg.'" does not exist.' )
						return []
					endif
					let list = s:library.resources[ 'list!'.listarg ]
				else
					let list = listarg
				endif
				"
			endif
		endfor
		"
	else
		let listname = a:1
		if ! has_key ( s:library.resources, 'list!'.listname )
			call s:ErrorMsg ( 'In template "'.a:name.'":', 'List "'.listname.'" does not exist.' )
			return []
		endif
		let list = s:library.resources[ 'list!'.listname ]
	endif
	"
	if ! exists ( 'list' )
		call s:ErrorMsg ( 'Template "'.a:name.'" is not a list picker.' )
		return []
	endif
	"
	return list
	"
endfunction    " ----------  end of function s:GetPickList  ----------
"
"----------------------------------------------------------------------
" s:PrepareHelp : Prepare a template (help).   {{{2
"----------------------------------------------------------------------
"
function! s:PrepareHelp ( cmds, text )
	"
	let regex = s:library.regex_template
	"
	let pick    = ''
	let default = ''
	let method  = ''
	let call    = ''
	"
	let buf_line = getline('.')
	let buf_pos  = col('.') - 1
	"
	" ==================================================
	"  command block
	" ==================================================
	"
	for line in split( a:cmds, "\n" )
		"
		" the line will match and it will be a valid function
		let [ f_name, f_param ] = matchlist ( line, regex.FunctionChecked )[ 1 : 2 ]
		"
		if f_name == 'C'
			" ignore
		elseif f_name == 'Word'
			exe 'let switch = '.f_param   | " TODO: works differently than 'Pattern': picks up word behind the cursor, too
			if switch == 'W' | let pick = expand('<cWORD>')
			else             | let pick = expand('<cword>') | endif
		elseif f_name == 'Pattern'
			exe 'let pattern = '.f_param
			let cnt = 1
			while 1
				let m_end = matchend ( buf_line, pattern, 0, cnt ) - 1
				if m_end < 0
					let pick = ''
					break
				elseif m_end >= buf_pos
					let m_start = match ( buf_line, pattern, 0, cnt )
					if m_start <= buf_pos | let pick = buf_line[ m_start : m_end ]
					else                  | let pick = ''                          | endif
					break
				endif
				let cnt += 1
			endwhile
		elseif f_name == 'Default'
			exe 'let default = '.f_param
		elseif f_name == 'LiteralSub'
			exe 'let [ p, r, f ] = ['.f_param.']'
			let pick = s:LiteralReplacement ( pick, p, r, f )
		elseif f_name == 'Substitute'
			exe 'let [ p, r, f ] = ['.f_param.']'
			let pick = substitute ( pick, p, r, f )
		elseif f_name == 'Browser' || f_name == 'System' || f_name == 'Vim'
			"
			let f_param_list = eval ( '[ '.f_param.' ]' )
			"
			let method = f_name
			let call = f_param_list[0]
			"
			if len ( f_param_list ) == 2
				let default = f_param_list[1]
			endif
		endif
		"
	endfor
	"
	" ==================================================
	"  call for help
	" ==================================================
	"
	if empty ( pick ) && empty ( default )
				\ || empty ( method )
		return ''
	endif
	"
	let m_local = copy ( s:t_runtime.macros )
	"
	if ! empty ( pick )
		let m_local.PICK = pick
		let call = s:ReplaceMacros ( call,    m_local )
	else
		let call = s:ReplaceMacros ( default, m_local )
	endif
	"
	if method == 'Browser'
		call s:DebugMsg ( 3, '!'.shellescape( s:Templates_InternetBrowserExec ).' '.s:Templates_InternetBrowserFlags.' '.call )
		let call = escape ( call, '%#' )
		if ! executable ( s:Templates_InternetBrowserExec )
			call s:ErrorMsg ( 'The internet browser is not executable ('.s:Templates_InternetBrowserExec.')',
						\ 'for the cofiguration, see:',
						\ '  :help g:Templates_InternetBrowserExec' )
		elseif s:MSWIN
			silent exe '!start '.shellescape( s:Templates_InternetBrowserExec ).' '.s:Templates_InternetBrowserFlags.' '.shellescape( call )
		else
			silent exe '!'.shellescape( s:Templates_InternetBrowserExec ).' '.s:Templates_InternetBrowserFlags.' '.shellescape( call ).' &'
		endif
	elseif method == 'System'
		call s:DebugMsg ( 3, '!'.call )
		let call = escape ( call, '%#' )
		if s:MSWIN
			silent exe '!start '.call
		else
			silent exe '!'.call.' &'
		endif
	elseif method == 'Vim'
		call s:DebugMsg ( 3, ':'.call )
		silent exe call
	endif
	"
	return ''
	"
endfunction    " ----------  end of function s:PrepareHelp  ----------
"
" "----------------------------------------------------------------------
" s:PrepareStdTempl : Prepare a template (standard).   {{{2
"----------------------------------------------------------------------
"
function! s:PrepareStdTempl ( cmds, text, name )
	"
	" TODO: revert must work like a stack, first set, last reverted
	" TODO: revert in case of PickList and PickFile
	"
	let regex = s:library.regex_template
	let ms    = regex.MacroStart
	let me    = regex.MacroEnd
	"
	let m_local  = s:t_runtime.macros
	let m_global = s:library.macros
	let prompted = s:t_runtime.prompted
	"
	let text     = a:text
	let surround = ''
	let revert   = ''
	"
	"
	" ==================================================
	"  command block
	" ==================================================
	"
	let cmds   = split( a:cmds, "\n" )
	let i_cmds = 0
	let n_cmds = len( cmds )
	"
	while i_cmds < n_cmds
		"
		" the line will match and it will be a valid function
		let [ f_name, f_param ] = matchlist ( cmds[ i_cmds ], regex.FunctionChecked )[ 1 : 2 ]
		"
		if f_name == 'C'
			" ignore
		elseif f_name == 'SurroundWith'
			let surround = f_param
		elseif f_name == 'DefaultMacro'
			"
			let [ m_name, m_text ] = eval ( '[ '.f_param.' ]' )
			"
			if ! has_key ( m_local, m_name )
				let revert = 'call remove ( m_local, "'.m_name.'" ) | '.revert
				let m_local[ m_name ] = m_text
			endif
			"
		elseif f_name == 'PickFile'
			"
			let [ p_prompt, p_path ] = eval ( '[ '.f_param.' ]' )
			"
			if p_path =~ regex.MacroName
				if ! has_key ( s:library.resources, 'path!'.p_path )
					throw 'Template:Prepare:the resources "'.p_path.'" does not exist'
				endif
				let p_path = s:library.resources[ 'path!'.p_path ]
			endif
			"
			let p_path = expand ( p_path )
			let	file = s:UserInput ( p_prompt.' : ', p_path, 'file' )
			"
			let m_local.PICK_COMPL = file
			let m_local.PATH_COMPL = fnamemodify ( file, ':h' )
			"
			let file = substitute ( file, '\V\^'.p_path, '', '' )
			"
			let m_local.PICK     = file
			let m_local.PATH     = fnamemodify ( file, ':h'   )
			let m_local.FILENAME = fnamemodify ( file, ':t'   )
			let m_local.BASENAME = fnamemodify ( file, ':t:r' )
			let m_local.SUFFIX   = fnamemodify ( file, ':e'   )
			"
		elseif f_name == 'PickEntry'
			"
			let [ p_which, p_entry ] = eval ( '[ '.f_param.' ]' )
			"
			let l:pick_entry = p_entry
			"
		elseif f_name == 'PickList'
			"
			let [ p_prompt, p_list ] = eval ( '[ '.f_param.' ]' )
			"
			if type ( p_list ) == type ( '' )
				if ! has_key ( s:library.resources, 'list!'.p_list )
					throw 'Template:Prepare:the resources "'.p_list.'" does not exist'
				endif
				let list = s:library.resources[ 'list!'.p_list ]
			else
				let list = p_list
			end
			"
			if type ( list ) == type ( [] )
				let type = 'list'
				let input_list = list
			else
				let type = 'dict'
				let input_list = sort ( keys ( list ) )
			endif
			"
			let plain     = 1
			let menu_info = get ( s:library.templates, a:name.'!!menu' )
			"
			if menu_info.entry == 2
				let expand_l = ''
				let expand_r = ''
				"
				if menu_info.expand_left != ''
					let plain = 0
					let expand_l = menu_info.expand_left
					let expand_r = menu_info.expand_right
				elseif menu_info.expand_right != ''
					let plain = 0
					let expand_l = '|KEY|'
					let expand_r = menu_info.expand_right
				endif
			endif
			"
			if exists ( 'l:pick_entry' )
				let entry = l:pick_entry
			elseif ! plain
				let formated_list = []
				let format_string = expand_l.' ('.expand_r.')'
				"
				let m_local = {}
				"
				for item in input_list
					"
					if type == 'list'
						let m_local.KEY   = item
						let m_local.VALUE = item
					else
						let m_local.KEY   = item
						let m_local.VALUE = list[item]
					endif
					"
					try
						let f_item = s:ReplaceMacros ( format_string,  m_local )
						"
						call add ( formated_list, f_item )
					catch /.*/
						call s:ErrorMsg ( v:exception )
						"
						call add ( formated_list, item )
					endtry
				endfor
				"
				let entry = s:UserInput ( p_prompt.' : ', '', 'customlist', formated_list )
				let idx   = index ( formated_list, entry )
				if idx != -1
					let entry = input_list[ idx ]
				endif
			else
				let entry = s:UserInput ( p_prompt.' : ', '', 'customlist', input_list )
			endif
			"
			let m_local.KEY = entry
			"
			if type == 'dict'
				if ! has_key ( list, entry ) && plain
					throw 'Template:Prepare:the entry "'.entry.'" does not exist'
				elseif ! has_key ( list, entry ) && ! plain
					throw 'Template:Prepare:no entry associated with "'.entry.'"'
				endif
				let entry = list[ entry ]
			endif
			"
			let m_local.VALUE = entry
			let m_local.PICK  = entry
			"
		elseif f_name == 'Prompt'
			"
			let [ m_name, m_flag ] = eval ( '[ '.f_param.' ]' )
			"
			" not already done and not a local macro?
			if ! has_key ( prompted, m_name )
						\ && ! has_key ( m_local, m_name )
				let m_text = get ( m_global, m_name, '' )
				"
				" prompt user for replacement
				let flagaction = get ( s:Flagactions, m_flag, '' )         " notify flag action, if any
				let m_text = s:UserInput ( m_name.flagaction.' : ', m_text )
				let m_text = s:ApplyFlag ( m_text, m_flag, '', 0 )
				"
				" save the result
				let m_global[ m_name ] = m_text
				let prompted[ m_name ] = 1
			endif
		else
			break
		endif
		"
		let i_cmds += 1
	endwhile
	"
	" --------------------------------------------------
	"  lists
	" --------------------------------------------------
	"
	while i_cmds < n_cmds
		"
		let mlist = matchlist ( cmds[ i_cmds ], regex.FunctionList )
		"
		if empty ( mlist )
			break
		endif
		"
		exe 'let [ l_name, head_def, tail_def ] = ['.mlist[1].']'
		let l_text = ''
		if ! has_key ( m_local, l_name )
			let l_len = 0
		elseif type ( m_local[ l_name ] ) == type ( '' )
			let l_list = [ m_local[ l_name ] ]
			let l_len  = 1
		else
			let l_list = m_local[ l_name ]
			let l_len  = len ( l_list )
		endif
		"
		if l_len == 0
			if ! empty ( cmds[ i_cmds+1 ] )
				exe 'let [ head, tail ] = '.cmds[ i_cmds+1 ]
				let l_text = head.tail."\n"
			endif
		elseif l_len == 1
			if ! empty ( cmds[ i_cmds+2 ] )
				exe 'let [ head, tail ] = '.cmds[ i_cmds+2 ]
				let l_text = head.l_list[0].tail."\n"
			elseif ! empty ( cmds[ i_cmds+3 ] )
				exe 'let [ head, tail ] = '.cmds[ i_cmds+3 ]
				let l_text = head.l_list[0].tail."\n"
			else
				let l_text = head_def.l_list[0].tail_def."\n"
			end
		else     " l_len >= 2
			"
			if ! empty ( cmds[ i_cmds+3 ] )
				exe 'let [ head, tail ] = '.cmds[ i_cmds+3 ]
				let l_text .= head.l_list[0].tail."\n"
			else
				let l_text .= head_def.l_list[0].tail_def."\n"
			endif
			"
			for idx in range ( 1, l_len-2 )
				let l_text .= head_def.l_list[idx].tail_def."\n"
			endfor
			"
			if ! empty ( cmds[ i_cmds+4 ] )
				exe 'let [ head, tail ] = '.cmds[ i_cmds+4 ]
				let l_text .= head.l_list[-1].tail."\n"
			else
				let l_text .= head_def.l_list[-1].tail_def."\n"
			endif
		endif
		"
		let text = s:LiteralReplacement ( text, ms.l_name.':LIST'.me."\n", l_text, '' )
		"
		let i_cmds += 5
	endwhile
	"
	" ==================================================
	"  text block: macros and templates
	" ==================================================
	"
	" insert other templates
	while 1
		"
		let mlist = matchlist ( text, regex.FunctionInsert )
		"
		" no more inserts?
		if empty ( mlist )
			break
		endif
		"
		let [ f_name, f_param ] = mlist[ 1 : 2 ]
		"
		" check the call
		call s:FunctionCheck ( f_name, f_param, s:library.namespace_templ_ins )
		"
		if f_name == 'InsertLine'
			" get the replacement
			exe 'let m_text = s:PrepareTemplate ( '.f_param.' )[0]'
			let m_text = m_text[ 0 : -2 ]
			" check
			if m_text =~ "\n"
				throw 'Template:Prepare:inserts more than a single line: "'.mlist[0].'"'
			endif
		elseif f_name == 'Insert'
			" get the replacement
			exe 'let m_text = s:PrepareTemplate ( '.f_param.' )[0]'
			let m_text = m_text[ 0 : -2 ]
			" prepare
			let mlist = matchlist ( text, '\([^'."\n".']*\)'.regex.FunctionInsert.'\([^'."\n".']*\)' )
			let head = mlist[1]
			let tail = mlist[4]
			let m_text = head.substitute( m_text, "\n", tail."\n".head, 'g' ).tail
		else
			throw 'Template:Check:the function "'.f_name.'" does not exist'
		endif
		"
		" insert
		let text = s:LiteralReplacement ( text, mlist[0], m_text, '' )
		"
	endwhile
	"
	" insert the replacements
	let text = s:ReplaceMacros ( text, m_local )
	"
	" ==================================================
	"  surround the template
	" ==================================================
	"
	if ! empty ( surround )
		" get the replacement
		exe 'let [ s_text, s_place ] = s:PrepareTemplate ( '.surround.', "do_surround" )'
		"
		if s_place == 'CONTENT'
			if -1 == match( s_text, '<CONTENT>' )
				throw 'Template:Prepare:surround template: <CONTENT> missing'
			endif
			"
			let mcontext = matchlist ( s_text, '\([^'."\n".']*\)'.'<CONTENT>'.'\([^'."\n".']*\)' )
			let head = mcontext[1]
			let tail = mcontext[2]
			" insert
			let text = text[ 0: -2 ]  " remove trailing '\n'
			let text = head.substitute( text, "\n", tail."\n".head, 'g' ).tail
			let text = s:LiteralReplacement ( s_text, mcontext[0], text, '' )
		elseif s_place == 'SPLIT'
			if -1 == match( s_text, '<SPLIT>' )
				throw 'Template:Prepare:surround template: <SPLIT> missing'
			endif
			"
			if match( s_text, '<SPLIT>\s*\n' ) >= 0
				let part = split ( s_text, '\s*<SPLIT>\s*\n', 1 )
			else
				let part = split ( s_text, '<SPLIT>', 1 )
			endif
			let text = part[0].text.part[1]
		endif
	endif
	"
	exe revert
	"
	return text
	"
endfunction    " ----------  end of function s:PrepareStdTempl  ----------
"
"----------------------------------------------------------------------
" s:PrepareTemplate : Prepare a template for insertion.   {{{2
"----------------------------------------------------------------------
"
function! s:PrepareTemplate ( name, ... )
	"
	let regex = s:library.regex_template
	"
	" ==================================================
	"  setup and checks
	" ==================================================
	"
	" check for recursion
	if -1 != index ( s:t_runtime.obj_stack, a:name )
		call add ( s:t_runtime.obj_stack, a:name )
		throw 'Template:Recursion'
	endif
	"
	call add ( s:t_runtime.obj_stack, a:name )
	"
	" current style
	let style = s:library.current_style
	"
	" get the template
	let [ cmds, text, type, placement, indentation ] = s:GetTemplate ( a:name, style )
	"
	" current macros
	let m_local  = s:t_runtime.macros
	let prompted = s:t_runtime.prompted
	"
	let remove_cursor  = 1
	let remove_split   = 1
	let use_surround   = 0
	let use_split      = 0
	"
	let revert = ''
	"
	" ==================================================
	"  parameters
	" ==================================================
	"
	let i = 1
	while i <= a:0
		"
		if a:[i] =~ regex.MacroMatch && i+1 <= a:0
			let m_name = matchlist ( a:[i], regex.MacroNameC )[1]
			if has_key ( m_local, m_name )
				let revert = 'let  m_local["'.m_name.'"] = '.string( m_local[ m_name ] ).' | '.revert
			else
				let revert = 'call remove ( m_local, "'.m_name.'" ) | '.revert
			endif
			let m_local[ m_name ] = a:[i+1]
			let i += 2
		elseif a:[i] =~ '<CURSOR>\|{CURSOR}'
			let remove_cursor = 0
			let i += 1
		elseif a:[i] == '<SPLIT>'
			let remove_split = 0
			let i += 1
		elseif a:[i] == 'do_surround'
			let use_surround = 1
			let i += 1
		elseif a:[i] == 'use_split'
			let use_split    = 1
			let remove_split = 0
			let i += 1
		elseif a:[i] == 'pick' && i+1 <= a:0
			let cmds = "PickEntry( '', ".string(a:[i+1])." )\n".cmds
			let i += 2
		else
			if type ( a:[i] ) == type ( '' ) | call s:ErrorMsg ( 'Unknown option: "'.a:[i].'"' )
			else                             | call s:ErrorMsg ( 'Unknown option at position '.i.'.' ) | endif
			let i += 1
		endif
		"
	endwhile
	"
	" ==================================================
	"  prepare
	" ==================================================
	"
	if type == 't'
		let text = s:PrepareStdTempl( cmds, text, a:name )
"		" TODO: remove this code:
" 	elseif type == 'pick-file'
" 		let text = s:PreparePickFile( cmds, text )
" 	elseif type == 'pick-list'
" 		let text = s:PreparePickList( cmds, text )
	elseif type == 'help'
		let text = s:PrepareHelp( cmds, text )
	endif
	"
	if remove_cursor
		let text = substitute( text, '<CURSOR>\|{CURSOR}',   '', 'g' )
		let text = substitute( text, '<RCURSOR>\|{RCURSOR}', '         ', 'g' )
	endif
	if remove_split
		let text = s:LiteralReplacement( text, '<SPLIT>',  '', 'g' )
	endif
	if ! use_surround || use_split
		let text = s:LiteralReplacement( text, '<CONTENT>',  '', 'g' )
	endif
	"
	" ==================================================
	"  wrap up
	" ==================================================
	"
	exe revert
	"
	call remove ( s:t_runtime.obj_stack, -1 )
	"
	if use_split
		return [ text, 'SPLIT' ]
	elseif use_surround
		return [ text, 'CONTENT' ]
	else
		return [ text, placement, indentation ]
	endif
	"
endfunction    " ----------  end of function s:PrepareTemplate  ----------
" }}}2
"-------------------------------------------------------------------------------
"
"----------------------------------------------------------------------
" === Insert Templates: Auxiliary Functions ===   {{{1
"----------------------------------------------------------------------

"-------------------------------------------------------------------------------
" s:RenewStdMacros : Renew the standard macros.   {{{2
"
" Parameters:
"   to_list - <+DESCRIPTION+> (<+TYPE+>)
"   from_list - <+DESCRIPTION+> (<+TYPE+>)
" Returns:
"   -
"-------------------------------------------------------------------------------

function! s:RenewStdMacros ( to_list, from_list )

	let a:to_list[ 'BASENAME' ] = expand( '%:t:r' )
	let a:to_list[ 'FILENAME' ] = expand( '%:t'   )
	let a:to_list[ 'PATH'     ] = expand( '%:p:h' )
	let a:to_list[ 'SUFFIX'   ] = expand( '%:e'   )

	if a:from_list[ 'TIME_LOCALE' ] != ''
		let save_time_lang = v:lc_time
		silent exe 'language time '.a:from_list[ 'TIME_LOCALE' ]
	endif

	let a:to_list[ 'DATE' ]          = strftime( a:from_list[ 'DATE' ] )
	let a:to_list[ 'DATE_PRETTY' ]   = strftime( a:from_list[ 'DATE_PRETTY' ] )
	let a:to_list[ 'DATE_PRETTY1' ]  = strftime( a:from_list[ 'DATE_PRETTY1' ] )
	let a:to_list[ 'DATE_PRETTY2' ]  = strftime( a:from_list[ 'DATE_PRETTY2' ] )
	let a:to_list[ 'DATE_PRETTY3' ]  = strftime( a:from_list[ 'DATE_PRETTY3' ] )
	let a:to_list[ 'TIME' ]          = strftime( a:from_list[ 'TIME' ] )
	let a:to_list[ 'TIME_PRETTY' ]   = strftime( a:from_list[ 'TIME_PRETTY' ] )
	let a:to_list[ 'YEAR' ]          = strftime( a:from_list[ 'YEAR' ] )
	let a:to_list[ 'YEAR_PRETTY' ]   = strftime( a:from_list[ 'YEAR_PRETTY' ] )

	if a:from_list[ 'TIME_LOCALE' ] != ''
		silent exe 'language time '.save_time_lang
	endif

endfunction    " ----------  end of function s:RenewStdMacros  ----------

"----------------------------------------------------------------------
" s:InsertIntoBuffer : Insert a text into the buffer.   {{{2
" (thanks to Fritz Mehner)
"----------------------------------------------------------------------
"
function! s:InsertIntoBuffer ( text, placement, indentation, flag_mode )
	"
	" TODO: syntax
	let regex = s:library.regex_template
	"
	let placement   = a:placement
	let indentation = a:indentation
	"
	if a:flag_mode != 'v'
		" --------------------------------------------------
		"  command and insert mode
		" --------------------------------------------------
		"
		" remove the split point
		let text = substitute( a:text, '\V'.'<SPLIT>', '', 'g' )
		"
		if placement == 'below'
			"
			exe ':'.s:t_runtime.range[1]
			call s:OpenFold('below')
			let pos1 = line(".")+1
			silent put = text
			let pos2 = line(".")
			"
		elseif placement == 'above'
			"
			exe ':'.s:t_runtime.range[0]
			let pos1 = line(".")
			silent put! = text
			let pos2 = line(".")
			"
		elseif placement == 'start'
			"
			exe ':1'
			call s:OpenFold('start')
			let pos1 = 1
			silent put! = text
			let pos2 = line(".")
			"
		elseif placement == 'append' || placement == 'insert'
			"
			if &foldenable && foldclosed(".") >= 0
				throw 'Template:Insert:insertion not available for a closed fold'
			elseif placement == 'append'
				let pos1 = line(".")
				silent put = text
				let pos2 = line(".")-1
				exe ":".pos1
				:join!
				let indentation = 0
			elseif placement == 'insert'

				" set textwidth to zero to disable auto-wrapping of lines,
				" compare 'formatoptions'
				let save_textwidth = &l:textwidth
				let &l:textwidth = 0

				let text = text[ 0: -2 ]  " remove trailing '\n'
				let currentline = getline( "." )
				let pos1 = line(".")
				let pos2 = pos1 + count( split(text,'\zs'), "\n" )
				if a:flag_mode == 'i'
					exe 'normal! gi'.text
				else
					exe 'normal! a'.text
				endif

				" reformat only multi-line inserts and previously empty lines
				if pos1 == pos2 && currentline != ''
					let indentation = 0
				endif

				let &l:textwidth = save_textwidth
			endif
			"
		else
			throw 'Template:Insert:unknown placement "'.placement.'"'
		endif
		"
	elseif a:flag_mode == 'v'
		" --------------------------------------------------
		"  visual mode
		" --------------------------------------------------
		"
		" remove the jump targets (2nd type)
		let text = substitute( a:text, regex.JumpTagType2, '', 'g' )
		"
		" TODO: Is the behaviour well-defined?
		" Suggestion: The line might include a cursor and a split and nothing else.
		if match( text, '<SPLIT>' ) >= 0
			if match( text, '<SPLIT>\s*\n' ) >= 0
				let part = split ( text, '\s*<SPLIT>\s*\n', 1 )
			else
				let part = split ( text, '<SPLIT>', 1 )
			endif
			let part[1] = part[1][ 0: -2 ]  " remove trailing '\n'
		else
			let part = [ "", text[ 0: -2 ] ]  " remove trailing '\n'
			echomsg 'tag <SPLIT> missing in template.'
		endif
		"
		" 'visual' and placement 'insert':
		"   <part0><marked area><part1>
		" part0 and part1 can consist of several lines
		"
		" 'visual' and placement 'below':
		"   <part0>
		"   <marked area>
		"   <part1>
		" part0 and part1 can consist of several lines
		"
		if placement == 'insert'
			let pos1 = line("'<")
			let pos2 = line("'>") + len(split( text, '\n' )) - 1
			" substitute the selected area (using the '< and '> marks)
			" - insert the second part first, such that the line numbers are still
			"   correct
			" - the mark '> is positioned strangely, so we have to include one
			"   character from the buffer in the pattern
			exe ':'.pos2.'s/\%''>.\?/&'.escape ( part[1], '/\&~' ).'/'
			exe ':'.pos1.'s/\%''</'.    escape ( part[0], '/\&~' ).'/'
			let indentation = 0
		elseif placement == 'below'
			silent '<put! = part[0]
			silent '>put  = part[1]
			let pos1 = line("'<") - len(split( part[0], '\n' ))
			let pos2 = line("'>") + len(split( part[1], '\n' ))
		elseif placement =~ '^\%(start\|above\|append\)$'
			throw 'Template:Insert:usage in split mode not allowed for placement "'.placement.'"'
		else
			throw 'Template:Insert:unknown placement "'.placement.'"'
		endif
		"
	endif
	"
	" proper indenting
	if indentation
		silent exe ":".pos1
		silent exe "normal! ".( pos2-pos1+1 )."=="
	endif
	"
	return [ pos1, pos2 ]
	"
endfunction    " ----------  end of function s:InsertIntoBuffer  ----------
"
"----------------------------------------------------------------------
" s:PositionCursor : Position the cursor.   {{{2
" (thanks to Fritz Mehner)
"----------------------------------------------------------------------
"
function! s:PositionCursor ( placement, flag_mode, pos1, pos2 )
	"
	" :TODO:12.08.2013 11:03:WM: changeable syntax?
	" :TODO:12.08.2013 12:00:WM: change behavior?
	"
	call setpos ( '.', [ bufnr('%'), a:pos1, 1, 0 ] )
	let mtch = search( '\m<R\?CURSOR>\|{R\?CURSOR}', 'c', a:pos2 )
	if mtch != 0
		" tag found (and cursor moved, we are now at the position of the match)
		let line = getline(mtch)
		if line =~ '<CURSOR>$\|{CURSOR}$'
			" the tag is at the end of the line
			call setline( mtch, substitute( line, '<CURSOR>\|{CURSOR}', '', '' ) )
			if a:flag_mode == 'v' && getline('.') =~ '^\s*$'
			"if a:flag_mode == 'v' && getline('.') =~ '^\s*\%(<CURSOR>\|{CURSOR}\)\s*$'
				" the line contains nothing but the tag: remove and join without
				" changing the second line
				normal! J
				"call setline( mtch, '' )
				"normal! gJ
			else
				" the line contains other characters: remove the tag and start appending
				"call setline( mtch, substitute( line, '<CURSOR>\|{CURSOR}', '', '' ) )
				startinsert!
			endif
		elseif line =~ '<RCURSOR>\|{RCURSOR}'
			call setline( mtch, substitute( line, '<RCURSOR>\|{RCURSOR}', '         ', '' ) )
			startreplace
		else
			" the line contains other characters: remove the tag and start inserting
			call setline( mtch, substitute( line, '<CURSOR>\|{CURSOR}', '', '' ) )
			startinsert
		endif
	else
		" no tag found (and cursor not moved)
		if a:placement == 'below'
			" to the end of the block, needed for repeated inserts
			exe ":".a:pos2
		endif
	endif
	"
endfunction    " ----------  end of function s:PositionCursor  ----------
"
"----------------------------------------------------------------------
" s:HighlightJumpTargets : Highlight the jump targets.   {{{2
"----------------------------------------------------------------------
"
function! s:HighlightJumpTargets ( regex )
	exe 'match Search /'.a:regex.'/'
endfunction    " ----------  end of function s:HighlightJumpTargets  ----------
" }}}2
"----------------------------------------------------------------------
"
"----------------------------------------------------------------------
" mmtemplates#core#InsertTemplate : Insert a template.   {{{1
"----------------------------------------------------------------------
"
function! mmtemplates#core#InsertTemplate ( library, t_name, ... ) range
	"
	" ==================================================
	"  parameters
	" ==================================================
	"
	if type( a:library ) == type( '' )
		exe 'let t_lib = '.a:library
	elseif type( a:library ) == type( {} )
		let t_lib = a:library
	else
		return s:ErrorMsg ( 'Argument "library" must be given as a dict or string.' )
	endif
	"
	if type( a:t_name ) != type( '' )
		return s:ErrorMsg ( 'Argument "template_name" must be given as a string.' )
	endif
	"
	" ==================================================
	"  setup
	" ==================================================
	"
	" library and runtime information
	let s:library = t_lib
	let s:t_runtime = {
				\ 'obj_stack'   : [],
				\ 'macro_stack' : [],
				\ 'macros'      : {},
				\ 'prompted'    : {},
				\
				\ 'placement' : '',
				\ 'range'     : [ a:firstline, a:lastline ],
				\ }
	let regex = s:library.regex_template
	"
	" renew the predefined macros
	call s:RenewStdMacros ( s:t_runtime.macros, s:library.macros )
	"
	" handle folds internally (and save the state)
	if &foldenable
		let foldmethod_save = &foldmethod
		set foldmethod=manual
	endif
	" use internal formatting to avoid conflicts when using == below
	" (and save the state)
	let equalprg_save = &equalprg
	set equalprg=
	"
	let flag_mode = 'n'
	let options   = []
	"
	" ==================================================
	"  options
	" ==================================================
	"
	let i = 1
	while i <= a:0
		"
		if a:[i] == 'i' || a:[i] == 'insert'
			let flag_mode = 'i'
			let i += 1
		elseif a:[i] == 'v' || a:[i] == 'visual'
			let flag_mode = 'v'
			let i += 1
		elseif a:[i] == 'placement' && i+1 <= a:0
			let s:t_runtime.placement = a:[i+1]
			let i += 2
		elseif a:[i] == 'range' && i+2 <= a:0
			let s:t_runtime.range[0] = a:[i+1]
			let s:t_runtime.range[1] = a:[i+2]
			let i += 3
		elseif a:[i] =~ regex.MacroMatch && i+1 <= a:0
			let name = matchlist ( a:[i], regex.MacroNameC )[1]
			let s:t_runtime.macros[ name ] = a:[i+1]
			let i += 2
		elseif a:[i] == 'pick' && i+1 <= a:0
			call add ( options, 'pick' )
			call add ( options, a:[i+1] )
			let i += 2
		elseif a:[i] == 'debug' && i+1 <= a:0 && ! s:DebugGlobalOverwrite
			let s:DebugLevel = a:[i+1]
			let i += 2
		else
			if type ( a:[i] ) == type ( '' ) | call s:ErrorMsg ( 'Unknown option: "'.a:[i].'"' )
			else                             | call s:ErrorMsg ( 'Unknown option at position '.i.'.' ) | endif
			let i += 1
		endif
		"
	endwhile
	"
	" ==================================================
	"  do the job
	" ==================================================
	"
	try
		"
		" prepare the template for insertion
		if empty ( options )
			let [ text, placement, indentation ] = s:PrepareTemplate ( a:t_name, '<CURSOR>', '<SPLIT>' )
		else
			let [ text, placement, indentation ] = call ( 's:PrepareTemplate', [ a:t_name, '<CURSOR>', '<SPLIT>' ] + options )
		endif
		"
		if placement == 'help'
			" job already done, TODO: review this
		else
			"
			if ! empty ( s:t_runtime.placement )
				let placement = s:t_runtime.placement
			endif
			"
			" insert the text into the buffer
			let [ pos1, pos2 ] = s:InsertIntoBuffer ( text, placement, indentation, flag_mode )
			"
			" position the cursor
			call s:PositionCursor ( placement, flag_mode, pos1, pos2 )
			"
			" highlight jump targets
			call s:HighlightJumpTargets ( regex.JumpTagAll )
		endif
		"
	catch /Template:UserInputAborted/
		" noop
	catch /Template:Check:.*/
		"
		let templ = s:t_runtime.obj_stack[ -1 ]
		let msg   = v:exception[ len( 'Template:Check:') : -1 ]
		call s:ErrorMsg ( 'Checking "'.templ.'":', msg )
		"
	catch /Template:Prepare:.*/
		"
		let templ = s:t_runtime.obj_stack[ -1 ]
		let incld = len ( s:t_runtime.obj_stack ) == 1 ? '' : '(included by: "'.s:t_runtime.obj_stack[ -2 ].'")'
		let msg   = v:exception[ len( 'Template:Prepare:') : -1 ]
		call s:ErrorMsg ( 'Preparing "'.templ.'":', incld, msg )
		"
	catch /Template:Recursion/
		"
		let templ = s:t_runtime.obj_stack[ -1 ]
		let idx1  = index ( s:t_runtime.obj_stack, templ )
		let cont  = idx1 == 0 ? [] : [ '...' ]
		call call ( 's:ErrorMsg', [ 'Recursion detected while including the template/s:' ] + cont +
					\ s:t_runtime.obj_stack[ idx1 : -1 ] )
		"
	catch /Template:MacroRecursion/
		"
		let macro = s:t_runtime.macro_stack[ -1 ]
		let idx1  = index ( s:t_runtime.macro_stack, macro )
		let cont  = idx1 == 0 ? [] : [ '...' ]
		call call ( 's:ErrorMsg', [ 'Recursion detected while replacing the macro/s:' ] + cont +
					\ s:t_runtime.macro_stack[ idx1 : -1 ] )
		"
	catch /Template:Insert:.*/
		"
		let msg   = v:exception[ len( 'Template:Insert:') : -1 ]
		call s:ErrorMsg ( 'Inserting "'.a:t_name.'":', msg )
		"
	catch /Template:.*/
		"
		let msg = v:exception[ len( 'Template:') : -1 ]
		call s:ErrorMsg ( msg )
		"
	finally
		"
		" ==================================================
		"  wrap up
		" ==================================================
		"
		" restore the state: folding and formatter program
		if &foldenable
			exe "set foldmethod=".foldmethod_save
			normal! zv
		endif
		let &equalprg = equalprg_save
		"
		unlet s:library                             " remove script variables
		unlet s:t_runtime                           " ...
		"
		let s:DebugLevel = s:DebugGlobalOverwrite   " reset debug
		"
	endtry
	"
endfunction    " ----------  end of function mmtemplates#core#InsertTemplate  ----------
"
"----------------------------------------------------------------------
" === Create Maps: Auxiliary Functions ===   {{{1
"----------------------------------------------------------------------

"-------------------------------------------------------------------------------
" s:DoCreateMap : Check whether a map already exists.   {{{2
"-------------------------------------------------------------------------------

function! s:DoCreateMap ( map, mode, report )

	let mapinfo = maparg ( a:map, a:mode )

	if ! empty ( mapinfo ) && a:report
		if mapinfo !~ 'mmtemplates#core#'
			call s:ErrorMsg ( 'Mapping already in use: "'.a:map.'", mode "'.a:mode.'", command:', '  '.mapinfo )
		elseif 0
			" :TODO:15.12.2015 11:47:WM: the template maps are not existing at this
			" point, since the commands are serialized as a string before they are
			" executed; find another way to obtain the template name
			let temp_name = 'TODO - not implemented yet -'
			call s:ErrorMsg ( 'Mapping already in use: "'.a:map.'", mode "'.a:mode.'", template:', '  '.temp_name )
		endif
	endif

	return empty ( mapinfo )
endfunction    " ----------  end of function s:DoCreateMap  ----------
" }}}2
"----------------------------------------------------------------------

"----------------------------------------------------------------------
" mmtemplates#core#CreateMaps : Create maps for a template library.   {{{1
"----------------------------------------------------------------------
"
function! mmtemplates#core#CreateMaps ( library, localleader, ... )
	"
	" ==================================================
	"  parameters
	" ==================================================
	"
	if type( a:library ) == type( '' )
		exe 'let t_lib = '.a:library
	else
		return s:ErrorMsg ( 'Argument "library" must be given as a string.' )
	endif
	"
	if type( a:localleader ) != type( '' )
		call s:ErrorMsg ( 'Argument "localleader" must be given as a string.' )
		return
	elseif ! empty ( a:localleader )
		if exists ( 'g:maplocalleader' )
			let ll_save = g:maplocalleader
		endif
		let g:maplocalleader = a:localleader
	endif
	"
	" ==================================================
	"  setup
	" ==================================================
	"
	" options
	let options = '<buffer> <silent>'
	let leader  = '<LocalLeader>'
	let sep     = "\n"
	"
	let do_jump_map     = 0
	let do_del_opt_map  = 0
	let do_special_maps = 0
	"
	let cmd     = ''
	"
	let opt_ft  = 'default'
	"
	" ==================================================
	"  options
	" ==================================================
	"
	let i = 1
	while i <= a:0
		"
		if a:[i] == 'do_jump_map'
			let do_jump_map = 1
			let i += 1
		elseif a:[i] == 'do_del_opt_map'
			let do_del_opt_map = 1
			let i += 1
		elseif a:[i] == 'do_special_maps'
			let do_special_maps = 1
			let i += 1
		elseif a:[i] == 'filetype' && i+1 <= a:0
			let opt_ft = a:[i+1]
			let i += 2
		else
			if type ( a:[i] ) == type ( '' ) | call s:ErrorMsg ( 'Unknown option: "'.a:[i].'"' )
			else                             | call s:ErrorMsg ( 'Unknown option at position '.i.'.' ) | endif
			let i += 1
		endif
		"
	endwhile
	"
	" ==================================================
	"  reuse previous commands
	" ==================================================
	"
	if has_key ( t_lib, 'map_commands!'.opt_ft )
		let time_start = reltime()
		exe t_lib['map_commands!'.opt_ft]
		if ! empty ( a:localleader )
			if exists ( 'll_save' )
				let g:maplocalleader = ll_save
			else
				unlet g:maplocalleader
			endif
		endif
		call s:DebugMsg ( 5, 'Executing maps: '.reltimestr( reltime( time_start ) ) )
		return
	endif
	"
	let time_start = reltime()
	"
	" ==================================================
	"  generate new commands
	" ==================================================
	"
	if has_key ( g:CheckedFiletypes, &filetype )
		let echo_warning = 0
	else
		let g:CheckedFiletypes[ &filetype ] = 1
		let echo_warning = s:Templates_MapInUseWarn == 'yes'
	endif
	"
	" go through all the templates
	for t_name in t_lib.menu_order
		"
		let info = t_lib.templates[ t_name.'!!menu' ]
		"
		" a separator?
		" no map?
		if info.entry == 11 || empty ( info.map )
			continue
		endif
		"
		" wrong filetype?
		if t_lib.interface >= 1000000 && -1 == index ( info.filetypes, opt_ft )
			continue
		endif
		"
		" visual mode, flag 'v': template contains a split tag, or the mode is forced
		if info.visual == 1
			let v_flag = ',"v"'
		else
			let v_flag = ''
		endif
		"
		let mp = info.map
		"
		if s:DoCreateMap ( leader.mp, 'n', echo_warning )
			let cmd .= 'nnoremap '.options.' '.leader.mp.'            :call mmtemplates#core#InsertTemplate('.a:library.',"'.t_name.'")<CR>'.sep
		endif
		if s:DoCreateMap ( leader.mp, 'v', echo_warning )
			let cmd .= 'vnoremap '.options.' '.leader.mp.'       <Esc>:call mmtemplates#core#InsertTemplate('.a:library.',"'.t_name.'"'.v_flag.')<CR>'.sep
		endif
		if s:DoCreateMap ( leader.mp, 'i', echo_warning )
			let cmd .= 'inoremap '.options.' '.leader.mp.' <C-g>u<Esc>:call mmtemplates#core#InsertTemplate('.a:library.',"'.t_name.'","i")<CR>'.sep
		endif
	endfor
	"
	" jump map
	if do_jump_map
		let jump_key = '<C-j>'   " TODO: configurable
		let jump_regex = string ( escape ( t_lib.regex_template.JumpTagAll, '|' ) )
		"
		if s:DoCreateMap ( jump_key, 'n', echo_warning )
			let cmd .= 'nnoremap '.options.' '.jump_key.'      i<C-R>=mmtemplates#core#JumpToTag('.jump_regex.')<CR>'.sep
		endif
		if s:DoCreateMap ( jump_key, 'i', echo_warning )
			let cmd .= 'inoremap '.options.' '.jump_key.' <C-g>u<C-R>=mmtemplates#core#JumpToTag('.jump_regex.')<CR>'.sep
		endif
	endif
	"
	if do_del_opt_map && t_lib.interface >= 1000000
		let jump_key = '<C-d>'   " TODO: configurable
		let del_regex = string ( escape ( t_lib.regex_template.JumpTagOpt, '|' ) )
		let del_sep   = string ( escape ( t_lib.regex_template.JTListSep, '|' ) )
		"
		if s:DoCreateMap ( jump_key, 'n', echo_warning )
			let cmd .= 'nnoremap '.options.' '.jump_key.'            :call mmtemplates#core#DeleteOptTag('.del_regex.','.del_sep.',"n")<CR>'.sep
		endif
		if s:DoCreateMap ( jump_key, 'i', echo_warning )
			let cmd .= 'inoremap '.options.' '.jump_key.' <C-g>u<Esc>:call mmtemplates#core#DeleteOptTag('.del_regex.','.del_sep.',"i")<CR>gi'.sep
		endif
	endif
	"
	" special maps
	" TODO: configuration of maps
	" TODO: edit template
	if do_special_maps
		let special_maps = []
		"
		for idx in range( 0, len ( t_lib.library_files ) - 1 )
			let fileinfo = t_lib.library_files[idx]
			if ! empty ( fileinfo.reload_map ) && ! fileinfo.hidden
				call add ( special_maps, [
							\ fileinfo.reload_map,
							\ ':call mmtemplates#core#EditTemplateFiles('.a:library.','.idx.')<CR>' ] )
			endif
		endfor
		"
		" no template library with a map?
		" -> add standard map for last file
		if empty ( special_maps )
			call add ( special_maps, [ t_lib.properties[ 'Templates::EditTemplates::Map'   ], ':call mmtemplates#core#EditTemplateFiles('.a:library.',-1)<CR>' ] )
		endif
		"
		call add ( special_maps, [ t_lib.properties[ 'Templates::RereadTemplates::Map' ], ':call mmtemplates#core#ReadTemplates('.a:library.',"reload","all")<CR>' ] )
		call add ( special_maps, [ t_lib.properties[ 'Templates::SetupWizard::Map'     ], ':call mmtemplates#wizard#SetupWizard('.a:library.')<CR>' ] )
		call add ( special_maps, [ t_lib.properties[ 'Templates::ChooseStyle::Map'     ], ':call mmtemplates#core#ChooseStyle('.a:library.',"!pick")<CR>' ] )
		"
		for [ mp, action ] in special_maps
			if s:DoCreateMap ( leader.mp, 'n', echo_warning )
				let cmd .= 'nnoremap '.options.' '.leader.mp.'      '.action.sep
			endif
			if s:DoCreateMap ( leader.mp, 'v', echo_warning )
				let cmd .= 'vnoremap '.options.' '.leader.mp.' <Esc>'.action.sep
			endif
			if s:DoCreateMap ( leader.mp, 'i', echo_warning )
				let cmd .= 'inoremap '.options.' '.leader.mp.' <Esc>'.action.sep
			endif
		endfor
	endif
	"
	let t_lib['map_commands!'.opt_ft] = cmd
	exe cmd
	"
	" ==================================================
	"  wrap up
	" ==================================================
	"
	if ! empty ( a:localleader )
		if exists ( 'll_save' )
			let g:maplocalleader = ll_save
		else
			unlet g:maplocalleader
		endif
	endif
	"
	call s:DebugMsg ( 5, 'Generating maps: '.reltimestr( reltime( time_start ) ) )
	"
endfunction    " ----------  end of function mmtemplates#core#CreateMaps  ----------
"
"----------------------------------------------------------------------
" === Create Menus: Auxiliary Functions ===   {{{1
"----------------------------------------------------------------------
"
"----------------------------------------------------------------------
" s:InsertShortcut : Insert a shortcut into a menu entry.   {{{2
"
" Inserts the shortcut by prefixing the appropriate character with '&',
" or by appending " (<shortcut>)". If escaped is true, the appended string is
" correctly escaped.
"----------------------------------------------------------------------
"
function! s:InsertShortcut ( entry, shortcut, escaped )
	if empty ( a:shortcut )
		return a:entry
	else
		let entry = a:entry
		let sc    = a:shortcut
		if stridx ( tolower( entry ), tolower( sc ) ) == -1
			if a:escaped | return entry.'\ (&'.sc.')'
			else         | return entry.' (&'.sc.')'
			endif
		else
			return substitute( entry, '\V\c'.sc, '\&&', '' )
		endif
	endif
endfunction    " ----------  end of function s:InsertShortcut  ----------
"
"----------------------------------------------------------------------
" s:CreateSubmenu : Create sub-menus, given they do not already exists.   {{{2
"
" The menu name 'menu' is supposed to be correctly escaped.
" It can contain '&' and a trailing '.'. Both are ignored.
"----------------------------------------------------------------------
"
function! s:CreateSubmenu ( menu, priority )
	"
	" split point:
	" a point, preceded by an even number of backslashes
	" in turn, the backslashes must be preceded by a different character, or the
	" beginning of the string
	let level    = len( split( s:t_runtime.root_menu, '\%(\_^\|[^\\]\)\%(\\\\\)*\zs\.' ) )
	let parts    =      split( a:menu,                '\%(\_^\|[^\\]\)\%(\\\\\)*\zs\.' )
	let n_parts  = len( parts )
	let level   += n_parts
	"
	let priority_str = ''
	"
	" go through the menu, clean up and check for new menus
	let submenu = ''
	for i in range( 1, len( parts ) )
		"
		let part = parts[ i-1 ]
		"
		if i == n_parts
			let priority_str = repeat( '.', level-1 ).a:priority.'. '
		endif
		"
		let clean = substitute( part, '&', '', 'g' )
		if ! has_key ( s:library.menu_existing, submenu.clean )
			" a new menu!
			" (the key is the menu name, it has to be correctly escaped)
			let s:library.menu_existing[ submenu.clean ] = 0
			"
			" shortcut and menu entry
			let tname = substitute( submenu.clean, '\\\(.\)', '\1', 'g' )
			if has_key ( s:library.menu_shortcuts, tname )
				let shortcut = s:library.menu_shortcuts[ tname ]
				let assemble = submenu.s:InsertShortcut( clean, shortcut, 1 )
			else
				let assemble = submenu.part
			endif
			"
			if -1 != stridx ( clean, '<TAB>' )
				exe 'anoremenu '.priority_str.s:t_runtime.root_menu.assemble.'.'.clean.' :echo "This is a menu header."<CR>'
			else
				exe 'anoremenu '.priority_str.s:t_runtime.root_menu.assemble.'.'.clean.'<TAB>'.escape( s:t_runtime.global_name, ' .' ).' :echo "This is a menu header."<CR>'
			endif
			exe 'anoremenu '.s:t_runtime.root_menu.assemble.'.-TSep00- <Nop>'
		endif
		let submenu .= clean.'.'
	endfor
	"
endfunction    " ----------  end of function s:CreateSubmenu  ----------
"
"----------------------------------------------------------------------
" s:CreateListMenus : Create the expanded list menu.   {{{2
"----------------------------------------------------------------------
"
function! s:CreateListMenus ( t_name, submenu, visual )
	"
	let t_name = a:t_name
	let plain  = 1
	"
	let info = s:library.templates[ t_name.'!!menu' ]
	"
	if info.expand_left != ''
		let plain = 0
	elseif info.expand_right != ''
		let plain = 0
		let info.expand_left = '|KEY|'                   " default for left-hand side
	endif
	"
	let list_compl = s:GetPickList ( t_name, info.expand_list )
	"
	if type ( list_compl ) == type ( [] )
		let list_keys = list_compl
		let is_list   = 1
	else
		let list_keys = sort ( keys ( list_compl ) )
		let is_list   = 0
	endif
	"
	if plain
		"
		for item in list_keys
			if s:library.interface < 1000000
				" old incomplete escaping
				let item_entry = substitute ( substitute ( escape ( item, ' .' ), '&', '\&\&', 'g' ), '\w', '\&&', '' )
			else
				let item_entry = mmtemplates#core#EscapeMenu ( item, 'entry' )
				let item_entry = substitute ( item_entry, '\w', '\&&', '' )   " shortcut
			endif
			"
			let item = escape ( item, '|' )           " must be escaped, even inside a string
			"
			exe 'anoremenu <silent> '.a:submenu.item_entry.'       <Esc><Esc>:call mmtemplates#core#InsertTemplate('.s:t_runtime.lib_name.',"'.t_name.'","pick",'.string(item).')<CR>'
			exe 'inoremenu <silent> '.a:submenu.item_entry.' <C-g>u<Esc><Esc>:call mmtemplates#core#InsertTemplate('.s:t_runtime.lib_name.',"'.t_name.'","i","pick",'.string(item).')<CR>'
			if a:visual == 1
				exe 'vnoremenu <silent> '.a:submenu.item_entry.' <Esc><Esc>:call mmtemplates#core#InsertTemplate('.s:t_runtime.lib_name.',"'.t_name.'","v","pick",'.string(item).')<CR>'
			endif
		endfor
		"
	else
		let s:t_runtime.macro_stack = []
		"
		let m_local = {}
		"
		for item in list_keys
			"
			if is_list
				let m_local.KEY   = item
				let m_local.VALUE = item
			else
				let m_local.KEY   = item
				let m_local.VALUE = list_compl[item]
			endif
			"
			try
				"
				let item_left  = s:ReplaceMacros ( info.expand_left,  m_local )
				let item_right = s:ReplaceMacros ( info.expand_right, m_local )
				"
				if empty ( item_left )
					let item_entry = mmtemplates#core#EscapeMenu ( item, 'entry' )
					let item_entry = substitute ( item_entry, '\w', '\&&', '' )   " shortcut
				else
					let item_entry = mmtemplates#core#EscapeMenu ( item_left, 'entry' )
					let item_entry = substitute ( item_entry, '\w', '\&&', '' )   " shortcut
					if ! empty ( item_right )
						let item_entry .= '<TAB>'.mmtemplates#core#EscapeMenu ( item_right, 'right' )
					endif
				endif
				"
			catch /.*/
				"
				call s:ErrorMsg ( v:exception )
				let item_entry = mmtemplates#core#EscapeMenu ( item, 'entry' )
				let item_entry = substitute ( item_entry, '\w', '\&&', '' )   " shortcut
				"
			endtry
			"
			let item = escape ( item, '|' )           " must be escaped, even inside a string
			"
			exe 'anoremenu <silent> '.a:submenu.item_entry.'       <Esc><Esc>:call mmtemplates#core#InsertTemplate('.s:t_runtime.lib_name.',"'.t_name.'","pick",'.string(item).')<CR>'
			exe 'inoremenu <silent> '.a:submenu.item_entry.' <C-g>u<Esc><Esc>:call mmtemplates#core#InsertTemplate('.s:t_runtime.lib_name.',"'.t_name.'","i","pick",'.string(item).')<CR>'
			if a:visual == 1
				exe 'vnoremenu <silent> '.a:submenu.item_entry.' <Esc><Esc>:call mmtemplates#core#InsertTemplate('.s:t_runtime.lib_name.',"'.t_name.'","v","pick",'.string(item).')<CR>'
			endif
		endfor
	endif
	"
endfunction    " ----------  end of function s:CreateListMenus  ----------
"
"----------------------------------------------------------------------
" s:CreateTemplateMenus : Create menus for the templates.   {{{2
"----------------------------------------------------------------------
"
function! s:CreateTemplateMenus (  )
	"
	let map_ldr = mmtemplates#core#EscapeMenu ( s:library.properties[ 'Templates::Mapleader' ], 'right' )
	"
	" go through all the templates
	for t_name in s:library.menu_order
		"
		let info = s:library.templates[ t_name.'!!menu' ]
		"
		" no menu entry?
		if info.entry == 0
			continue
		endif
		"
		" get the sub-menu and the entry
		let [ t_menu, t_last ] = matchlist ( t_name, '^\(.*\.\)\?\([^\.]\+\)$' )[1:2]
		"
		" menu does not exist?
		if ! empty ( t_menu ) && ! has_key ( s:library.menu_existing, t_menu[ 0 : -2 ] )
			call s:CreateSubmenu ( mmtemplates#core#EscapeMenu( t_menu[ 0 : -2 ], 'menu' ), s:StandardPriority )
		endif
		"
		if info.entry == 11
			let m_key = mmtemplates#core#EscapeMenu( t_menu[ 0 : -2 ], 'menu' )
			if empty ( m_key )
				let m_key = '!base'
			endif
			"
			let sep_nr = s:library.menu_existing[ m_key ] + 1
			let s:library.menu_existing[ m_key ] = sep_nr
			"
			exe 'anoremenu '.s:t_runtime.root_menu.escape( t_menu, ' ' ).'-TSep'.sep_nr.'- :'
			"
			continue
		endif
		"
		if info.mname != ''
			let t_last = mmtemplates#core#EscapeMenu ( info.mname, 'entry' )
		else
			let t_last = mmtemplates#core#EscapeMenu ( t_last, 'entry' )
		endif
		"
		" shortcut and menu entry
		if ! empty ( info.shortcut )
			let t_last = s:InsertShortcut( t_last, info.shortcut, 1 )
		endif
		"
		" assemble the entry, including the map
		let compl_entry = mmtemplates#core#EscapeMenu( t_menu, 'menu' ).t_last
		if empty ( info.map )
			let map_entry = ''
		else
			let map_entry = '<TAB>'.map_ldr.mmtemplates#core#EscapeMenu( info.map, 'right' )
		end
		"
		if info.entry == 1
			" <Esc><Esc> prevents problems in insert mode
			exe 'anoremenu <silent> '.s:t_runtime.root_menu.compl_entry.map_entry.'       <Esc><Esc>:call mmtemplates#core#InsertTemplate('.s:t_runtime.lib_name.',"'.t_name.'")<CR>'
			exe 'inoremenu <silent> '.s:t_runtime.root_menu.compl_entry.map_entry.' <C-g>u<Esc><Esc>:call mmtemplates#core#InsertTemplate('.s:t_runtime.lib_name.',"'.t_name.'","i")<CR>'
			if info.visual == 1
				exe 'vnoremenu <silent> '.s:t_runtime.root_menu.compl_entry.map_entry.' <Esc><Esc>:call mmtemplates#core#InsertTemplate('.s:t_runtime.lib_name.',"'.t_name.'","v")<CR>'
			endif
		elseif info.entry == 2
			call s:CreateSubmenu ( compl_entry.map_entry, s:StandardPriority )
			call s:CreateListMenus ( t_name, s:t_runtime.root_menu.compl_entry.'.', info.visual )
		endif
		"
	endfor
	"
endfunction    " ----------  end of function s:CreateTemplateMenus  ----------
"
"----------------------------------------------------------------------
" s:CreateSpecialsMenus : Create menus for a template library.   {{{2
"----------------------------------------------------------------------
"
function! s:CreateSpecialsMenus ( styles_only )
	"
	" sanitize
	let specials_menu = substitute( s:t_runtime.spec_menu, '\.$', '', '' )
	let map_ldr       = mmtemplates#core#EscapeMenu ( s:library.properties[ 'Templates::Mapleader' ], 'right' )
	"
	" create the specials menu
	call s:CreateSubmenu ( specials_menu, s:StandardPriority )
	"
	" ==================================================
	"  create a menu for all the styles
	" ==================================================
	if ! a:styles_only
		let entries = []
		"
		" add entries for template files
		for idx in range( 0, len ( s:library.library_files ) - 1 )
			let fileinfo = s:library.library_files[idx]
			if ! empty ( fileinfo.sym_name ) && ! fileinfo.hidden
				call add ( entries, [
							\ mmtemplates#core#EscapeMenu ( 'edit '.fileinfo.sym_name.' templates', 'entry' ),
							\ fileinfo.reload_sc,
							\ fileinfo.reload_map,
							\ ':call mmtemplates#core#EditTemplateFiles('.s:t_runtime.lib_name.','.idx.')<CR>' ] )
				"
				" empty shortcut -> use first letter of 'sym_name'
				if empty ( fileinfo.reload_sc )
					let entries[-1][1] = matchstr ( fileinfo.sym_name, '\w' )
				endif
			endif
		endfor
		"
		" no template library with a symbolic name?
		" -> add standard entry for last file
		" :TODO:27.12.2014 16:26:WM: review this, maybe add no file?
		if empty ( entries )
			let sc_edit  = s:library.properties[ 'Templates::EditTemplates::Shortcut' ]
			let map_edit = s:library.properties[ 'Templates::EditTemplates::Map' ]
			call add ( entries, [ 'edit\ templates', sc_edit, map_edit, ':call mmtemplates#core#EditTemplateFiles('.s:t_runtime.lib_name.',-1)<CR>' ] )
		endif
		"
		" add entry for reloading the whole library
		let sc_read  = s:library.properties[ 'Templates::RereadTemplates::Shortcut' ]
		let map_read = s:library.properties[ 'Templates::RereadTemplates::Map' ]
		call add ( entries, [ 'reread\ templates', sc_read, map_read, ':call mmtemplates#core#ReadTemplates('.s:t_runtime.lib_name.',"reload","all")<CR>' ] )
		"
		" add entry for starting the setup wizard
		let sc_read  = s:library.properties[ 'Templates::SetupWizard::Shortcut' ]
		let map_read = s:library.properties[ 'Templates::SetupWizard::Map' ]
		call add ( entries, [ 'template\ setup\ wizard', sc_read, map_read, ':call mmtemplates#wizard#SetupWizard('.s:t_runtime.lib_name.')<CR>' ] )
		"
		" create edit and reread templates
		for [ e_name, e_sc, e_map, cmd ] in entries
			let entry_compl = s:InsertShortcut ( '.'.e_name, e_sc, 1 )
			if ! empty ( e_map )
				let entry_compl .= '<TAB>'.map_ldr.mmtemplates#core#EscapeMenu( e_map, 'right' )
			endif
			exe 'anoremenu <silent> '.s:t_runtime.root_menu.specials_menu.entry_compl.' '.cmd
		endfor
	endif
	"
	" ==================================================
	"  create a menu for all the styles
	" ==================================================
	let sc_style  = s:library.properties[ 'Templates::ChooseStyle::Shortcut' ]
	let map_style = map_ldr.mmtemplates#core#EscapeMenu ( s:library.properties[ 'Templates::ChooseStyle::Map' ], 'right' )
	"
	" create the submenu
	if sc_style == 's' | let entry_styles = '.choose\ &style<TAB>'.map_style
	else               | let entry_styles = s:InsertShortcut ( '.choose\ style', sc_style, 0 ).'<TAB>'.map_style
	endif
	call s:CreateSubmenu ( specials_menu.entry_styles, s:StandardPriority )
	"
	" add entries for all styles
	for s in s:library.styles
		exe 'anoremenu <silent> '.s:t_runtime.root_menu.specials_menu.'.choose\ style.&'.s
					\ .' :call mmtemplates#core#ChooseStyle('.s:t_runtime.lib_name.','.string(s).')<CR>'
	endfor
	"
endfunction    " ----------  end of function s:CreateSpecialsMenus  ----------
" }}}2
"----------------------------------------------------------------------
"
"----------------------------------------------------------------------
" mmtemplates#core#CreateMenus : Create menus for a template library.   {{{1
"----------------------------------------------------------------------
"
function! mmtemplates#core#CreateMenus ( library, root_menu, ... )
	"
	" check for feature
	if ! has ( 'menu' )
		return
	endif
	"
	" ==================================================
	"  parameters
	" ==================================================
	"
	if type( a:library ) == type( '' )
		exe 'let t_lib = '.a:library
	else
		call s:ErrorMsg ( 'Argument "library" must be given as a string.' )
		return
	endif
	"
	if type( a:root_menu ) != type( '' )
		call s:ErrorMsg ( 'Argument "root_menu" must be given as a string.' )
		return
	endif
	"
	" ==================================================
	"  setup
	" ==================================================
	"
	let s:library = t_lib
	let s:t_runtime = {
				\ 'lib_name'    : a:library,
				\ 'global_name' : '',
				\ 'root_menu'   : '',
				\ 'spec_menu'   : '&Run',
				\ }
	"
	" options
	let s:t_runtime.root_menu   = substitute(         a:root_menu, '&',   '', 'g' )
	let s:t_runtime.global_name = substitute( s:t_runtime.root_menu, '\.$', '', ''  )
	let s:t_runtime.root_menu   = s:t_runtime.global_name.'.'
	let specials_menu = '&Run'
	let priority      = s:StandardPriority
	let existing      = []
	"
	" jobs
	let do_reset     = 0
	let do_templates = 0
	let do_specials  = 0   " no specials
	let submenus     = []
	"
	" ==================================================
	"  options
	" ==================================================
	"
	let i = 1
	while i <= a:0
		"
		if a:[i] == 'global_name' && i+1 <= a:0
			let global_name = a:[i+1]
			let i += 2
		elseif a:[i] == 'existing_menu' && i+1 <= a:0
			if type ( a:[i+1] ) == type ( '' ) | call add    ( existing, a:[i+1] )
			else                               | call extend ( existing, a:[i+1] ) | endif
			let i += 2
		elseif a:[i] == 'sub_menu' && i+1 <= a:0
			if type ( a:[i+1] ) == type ( '' ) | call add    ( submenus, a:[i+1] )
			else                               | call extend ( submenus, a:[i+1] ) | endif
			let i += 2
		elseif a:[i] == 'specials_menu' && i+1 <= a:0
			if t_lib.api_version < 1000000
				let s:t_runtime.spec_menu = escape ( a:[i+1], ' ' )
			else
				let s:t_runtime.spec_menu = a:[i+1]
			endif
			let i += 2
		elseif a:[i] == 'priority' && i+1 <= a:0
			let priority = a:[i+1]
			let i += 2
		elseif a:[i] == 'do_all'
			let do_reset     = 1
			let do_templates = 1
			let do_specials  = 1
			let i += 1
		elseif a:[i] == 'do_reset'
			let do_reset     = 1
			let i += 1
		elseif a:[i] == 'do_templates'
			let do_templates = 1
			let i += 1
		elseif a:[i] == 'do_specials'
			let do_specials   = 1
			let i += 1
		elseif a:[i] == 'do_styles'
			let do_specials   = 2
			let i += 1
		else
			if type ( a:[i] ) == type ( '' ) | call s:ErrorMsg ( 'Unknown option: "'.a:[i].'"' )
			else                             | call s:ErrorMsg ( 'Unknown option at position '.i.'.' ) | endif
			let i += 1
		endif
		"
	endwhile
	"
	" ==================================================
	"  do the jobs
	" ==================================================
	"
	" reset
	if do_reset
		let t_lib.menu_existing = { '!base' : 0 }
	endif
	"
	" existing menus
	for name in existing
		let name = substitute( name, '&', '', 'g' )
		let name = substitute( name, '\.$', '', '' )
		if t_lib.api_version < 1000000
			let t_lib.menu_existing[ escape ( name, ' ' ) ] = 0
		else
			let t_lib.menu_existing[ name ] = 0
		endif
	endfor
	"
	" sub-menus
	for name in submenus
		if t_lib.api_version < 1000000
			call s:CreateSubmenu ( escape ( name, ' ' ), priority )
		else
			call s:CreateSubmenu ( name, priority )
		endif
	endfor
	"
	" templates
	if do_templates
		call s:CreateTemplateMenus ()
	endif
	"
	" specials
	if do_specials == 1
		" all specials
		call s:CreateSpecialsMenus ( 0 )
	elseif do_specials == 2
		" styles only
		call s:CreateSpecialsMenus ( 1 )
	endif
	"
	" ==================================================
	"  wrap up
	" ==================================================
	"
	unlet s:library                               " remove script variables
	unlet s:t_runtime                             " ...
	"
endfunction    " ----------  end of function mmtemplates#core#CreateMenus  ----------
"
"----------------------------------------------------------------------
" mmtemplates#core#EscapeMenu : Escape a string so it can be used as a menu item.   {{{1
"----------------------------------------------------------------------
"
function! mmtemplates#core#EscapeMenu ( str, ... )
	"
	let mode = 'entry'
	"
	if a:0 > 0
		if type( a:1 ) != type( '' )
			return s:ErrorMsg ( 'Argument "mode" must be given as a string.' )
		elseif a:1 == 'menu'
			let mode = 'menu'
		elseif a:1 == 'entry'
			let mode = 'entry'
		elseif a:1 == 'right'
			let mode = 'right'
		else
			return s:ErrorMsg ( 'Unknown mode: '.a:1 )
		endif
	endif
	"
	" whole menu: do not escape '.'
	if mode == 'menu'
		let str = escape ( a:str, ' \|' )
	else
		let str = escape ( a:str, ' \|.' )
	endif
	"
	" right-aligned text: do not escape '&'
	if mode != 'right'
		let str = substitute (   str, '&', '\&\&', 'g' )
	endif
	"
	" entry: escape '-...-' by appending a space
	if mode == 'entry'
		if match ( str, '^-.*-$' ) > -1
			let str .= '\ '
		endif
	endif
	"
	return str
	"
endfunction    " ----------  end of function mmtemplates#core#EscapeMenu  ----------
"
"----------------------------------------------------------------------
" mmtemplates#core#ChooseStyle : Choose a style.   {{{1
"----------------------------------------------------------------------
"
function! mmtemplates#core#ChooseStyle ( library, style )
	"
	" ==================================================
	"  parameters
	" ==================================================
	"
	if type( a:library ) == type( '' )
		exe 'let t_lib = '.a:library
	elseif type( a:library ) == type( {} )
		let t_lib = a:library
	else
		call s:ErrorMsg ( 'Argument "library" must be given as a dict or string.' )
		return
	endif
	"
	if type( a:style ) != type( '' )
		call s:ErrorMsg ( 'Argument "style" must be given as a string.' )
		return
	endif
	"
	" ==================================================
	"  change the style
	" ==================================================
	"
	" pick the style
	if a:style == '!pick'
		try
			let style = s:UserInput( 'Style (currently '.t_lib.current_style.') : ', '', 
						\ 'customlist', t_lib.styles )
		catch /Template:UserInputAborted/
			return
		endtry
	else
		let style = a:style
	endif
	"
	" check and set the new style
	if style == ''
		" noop
	elseif -1 != index ( t_lib.styles, style )
		if t_lib.current_style != style
			let t_lib.current_style = style
			echo 'Changed style to "'.style.'".'
		elseif a:style == '!pick'
			echo 'Style stayed "'.style.'".'
		endif
	else
		call s:ErrorMsg ( 'Style was not changed. Style "'.style.'" is not available.' )
	end
	"
endfunction    " ----------  end of function mmtemplates#core#ChooseStyle  ----------
"
"----------------------------------------------------------------------
" mmtemplates#core#Resource : Access to various resources.   {{{1
"----------------------------------------------------------------------
"
function! mmtemplates#core#Resource ( library, mode, ... )
	"
	" TODO mode 'special' for |DATE|, |TIME| and |YEAR|
	"
	" ==================================================
	"  parameters
	" ==================================================
	"
	if type( a:library ) == type( '' )
		exe 'let t_lib = '.a:library
	elseif type( a:library ) == type( {} )
		let t_lib = a:library
	else
		return [ '', 'Argument "library" must be given as a dict or string.' ]
	endif
	"
	if type( a:mode ) != type( '' )
		return [ '', 'Argument "mode" must be given as a string.' ]
	endif
	"
	" ==================================================
	"  special inquiries
	" ==================================================
	"
	if a:mode == 'add' || a:mode == 'get' || a:mode == 'set'
		" continue below
	elseif a:mode == 'escaped_mapleader'
		return [ mmtemplates#core#EscapeMenu( t_lib.properties[ 'Templates::Mapleader' ], 'right' ), '' ]
	elseif a:mode == 'jumptag'
		return [ t_lib.regex_template.JumpTagAll, '' ]
	elseif a:mode == 'style'
		return [ t_lib.current_style, '' ]
	elseif a:mode == 'settings_table'
		return [ s:Templates_AllSettings, '' ]
	elseif a:mode == 'template_list'
		let templist = []
		"
		for fileinfo in t_lib.library_files
			if fileinfo.available
				call add ( templist, fileinfo.filename." (".fileinfo.sym_name.")" )
			elseif ! fileinfo.hidden
				let fname = fileinfo.filename == '' ? '-missing-' : fileinfo.filename
				if fileinfo.optional
					call add ( templist, fname." (".fileinfo.sym_name.", not used)" )
				else
					call add ( templist, fname." (".fileinfo.sym_name.", missing!)" )
				endif
			endif
		endfor
		"
		call add ( templist,
					\ '(template engine version '.g:Templates_Version
					\ .', API '.t_lib.api_version_str.', interface '.t_lib.interface_str.')' )
		"
		return [ templist, '' ]
	else
		return [ '', 'Mode "'.a:mode.'" is unknown.' ]
	endif
	"
	" ==================================================
	"  options
	" ==================================================
	"
	" type of 'resource'
	let types = { 'list' : '[ld]', 'macro' : 's', 'path' : 's', 'property' : 's', 'template_file' : '' }
	"
	if a:mode == 'add' && a:0 != 3
		return [ '', 'Mode "add" requires three additional arguments.' ]
	elseif a:mode == 'get' && a:0 != 2
		return [ '', 'Mode "get" requires two additional arguments.' ]
	elseif a:mode == 'set' && a:0 != 3
		return [ '', 'Mode "set" requires three additional arguments.' ]
	elseif type( a:1 ) != type( '' )
		return [ '', 'Argument "resource" must be given as a string.' ]
	elseif type( a:2 ) != type( '' )
		return [ '', 'Argument "key" must be given as a string.' ]
	elseif ! has_key ( types, a:1 )
		return [ '', 'Resource "'.a:1.'" does not exist.' ]
	elseif a:mode == 'add' && a:1 != 'property'
		return [ '', 'Can not execute add for resource of type "'.a:1.'".' ]
	endif
	"
	" ==================================================
	"  add, get or set
	" ==================================================
	"
	let resource = a:1
	let key      = a:2
	"
	if a:mode == 'add'
		"
		let value = a:3
		"
		" add (property only)
		if type( value ) != type( '' )
			return [ '', 'Argument "value" must be given as a string.' ]
		else
			let t_lib.properties[ key ] = value
			return [ '', '' ]
		endif
		"
		return [ '', '' ]
	elseif a:mode == 'get'
		"
		" get
		if resource == 'list'
			return [ get( t_lib.resources, 'list!'.key ), '' ]
		elseif resource == 'macro'
			return [ get( t_lib.macros, key ), '' ]
		elseif resource == 'path'
			return [ get( t_lib.resources, 'path!'.key ), '' ]
		elseif resource == 'property'
			if has_key ( t_lib.properties, key )
				return [ t_lib.properties[ key ], '' ]
			else
				return [ '', 'Property "'.key.'" does not exist.' ]
			endif
		elseif resource == 'template_file'
			"
			let fileinfo_use = {}
			"
			for fileinfo in t_lib.library_files
				if fileinfo.sym_name == key
					let fileinfo_use = {
								\ 'filename'  : fileinfo.filename,
								\ 'sym_name'  : fileinfo.sym_name,
								\ 'available' : fileinfo.available,
								\ 'optional'  : fileinfo.optional,
								\ 'hidden'    : fileinfo.hidden,
								\ }
				endif
			endfor
			"
			if ! empty ( fileinfo_use )
				return [ fileinfo_use, '' ]
			else
				return [ {}, 'Template file "'.key.'" does not exist.' ]
			endif
			"
		endif
		"
	elseif a:mode == 'set'
		"
		let value = a:3
		"
		" check type and set
		if types[ resource ] == ''
			return [ '', 'Resource "'.a:1.'" can not be set.' ]
		elseif s:TypeNames[ type( value ) ] !~ types[ resource ]
			return [ '', 'Argument "value" has the wrong type.' ]
		elseif resource == 'list'
			let t_lib.resources[ 'list!'.key ] = value
		elseif resource == 'macro'
			let t_lib.macros[ key ] = value
		elseif resource == 'path'
			let t_lib.resources[ 'path!'.key ] = fnamemodify( expand( value ), ":p" )
		elseif resource == 'property'
			if has_key ( t_lib.properties, key )
				let t_lib.properties[ key ] = value
				return [ '', '' ]
			else
				return [ '', 'Property "'.key.'" does not exist.' ]
			endif
		endif
		"
		return [ '', '' ]
	endif
	"
endfunction    " ----------  end of function mmtemplates#core#Resource  ----------
"
"----------------------------------------------------------------------
" mmtemplates#core#ChangeSyntax : Change the syntax of the templates.   {{{1
"-------------------------------------------------------------------------------
"
function! mmtemplates#core#ChangeSyntax ( library, category, ... )
	"
	" ==================================================
	"  parameters
	" ==================================================
	"
	if type( a:library ) == type( '' )
		exe 'let t_lib = '.a:library
	elseif type( a:library ) == type( {} )
		let t_lib = a:library
	else
		return s:ErrorMsg ( 'Argument "library" must be given as a dict or string.' )
	endif
	"
	if type( a:category ) != type( '' )
		return s:ErrorMsg ( 'Argument "category" must be given as an integer or string.' )
	endif
	"
	" ==================================================
	"  set the syntax
	" ==================================================
	"
	if a:category == 'comment'
		"
		if a:0 < 1
			return s:ErrorMsg ( 'Not enough arguments for '.a:category.'.' )
		elseif a:0 == 1
			let t_lib.regex_settings.CommentStart = a:1
			let t_lib.regex_settings.CommentHint  = a:1[0]
		elseif a:0 == 2
			let t_lib.regex_settings.CommentStart = a:1
			let t_lib.regex_settings.CommentHint  = a:2[0]
		endif
		"
		call s:UpdateFileReadRegex ( t_lib.regex_file, t_lib.regex_settings, t_lib.interface )
		"
	else
		return s:ErrorMsg ( 'Unknown category: '.a:category )
	endif
	"
endfunction    " ----------  end of function mmtemplates#core#ChangeSyntax  ----------
"
"-------------------------------------------------------------------------------
" mmtemplates#core#ExpandText : Expand the macros in a text.   {{{1
"----------------------------------------------------------------------
"
function! mmtemplates#core#ExpandText ( library, text )
	"
	" ==================================================
	"  parameters
	" ==================================================
	"
	if type( a:library ) == type( '' )
		exe 'let t_lib = '.a:library
	elseif type( a:library ) == type( {} )
		let t_lib = a:library
	else
		return s:ErrorMsg ( 'Argument "library" must be given as a dict or string.' )
	endif
	"
	if type( a:text ) != type( '' )
		return s:ErrorMsg ( 'Argument "text" must be given as a string.' )
	endif
	"
	" ==================================================
	"  setup
	" ==================================================
	"
	" library and runtime information
	let s:library = t_lib
	let s:t_runtime = {
				\ 'macro_stack' : [],
				\ }
	"
	" renew the predefined macros
	let m_local = {}
	call s:RenewStdMacros ( m_local, t_lib.macros )
	"
	" ==================================================
	"  do the job
	" ==================================================
	"
	let res = ''
	"
	try
		"
		let res = s:ReplaceMacros ( a:text, m_local )
		"
	catch /Template:MacroRecursion/
		"
		let macro = s:t_runtime.macro_stack[ -1 ]
		let idx1  = index ( s:t_runtime.macro_stack, macro )
		let cont  = idx1 == 0 ? [] : [ '...' ]
		call call ( 's:ErrorMsg', [ 'Recursion detected while replacing the macro/s:' ] + cont +
					\ s:t_runtime.macro_stack[ idx1 : -1 ] )
		"
	catch /Template:.*/
		"
		let msg = v:exception[ len( 'Template:') : -1 ]
		call s:ErrorMsg ( msg )
		"
	finally
		"
		" ==================================================
		"  wrap up
		" ==================================================
		"
		unlet s:library                             " remove script variables
		unlet s:t_runtime                           " ...
		"
	endtry
	"
	return res
	"
endfunction    " ----------  end of function mmtemplates#core#ExpandText  ----------
"
"-------------------------------------------------------------------------------
" mmtemplates#core#EditTemplateFiles : Choose and edit a template file.   {{{1
"-------------------------------------------------------------------------------
"
function! mmtemplates#core#EditTemplateFiles ( library, file )
	"
	" ==================================================
	"  parameters
	" ==================================================
	"
	if type( a:library ) == type( '' )
		exe 'let t_lib = '.a:library
	elseif type( a:library ) == type( {} )
		let t_lib = a:library
	else
		return s:ErrorMsg ( 'Argument "library" must be given as a dict or string.' )
	endif
	"
	if type( a:file ) == type( 0 )
		if empty( get( t_lib.library_files, a:file, [] ) )
			return s:ErrorMsg ( 'No template file with index '.a:file.'.' )
		endif
		let file = t_lib.library_files[ a:file ].filename
		let available = t_lib.library_files[ a:file ].available
	elseif type( a:file ) == type( '' )
		"
		let file = expand ( a:file )
		let file = s:ConcatNormalizedFilename ( file )
		let available = 0
		"
		if ! filereadable ( file )
			return s:ErrorMsg ( 'The file "'.file.'" does not exist.' )
		else
			let found_file = 0
			for fileinfo in t_lib.library_files
				if fileinfo.filename == file
					let found_file = 1
					let available  = fileinfo.available
					break
				endif
			endfor
			if found_file == 0
				return s:ErrorMsg ( 'The file "'.file.'" is not part of the template library.' )
			endif
		endif
		"
	else
		return s:ErrorMsg ( 'Argument "file" must be given as an integer or string.' )
	endif
	"
	" ==================================================
	"  file not available
	" ==================================================
	"
	if ! available
		return s:ErrorMsg ( 'This template file is not avaiable. Use the wizard to set it up',
					\ 'or follow the instructions of your plug-in for setting up this file.' )
	endif
	"
	" ==================================================
	"  do the job
	" ==================================================
	"
	if ! filereadable ( file )
		return s:ErrorMsg ( 'The template file "'.file.'" does not exist.' )
	endif
	"
	" get the directory
	let dir = fnamemodify ( file, ':h' )
	"
	let method = s:Templates_TemplateBrowser
	"
	if method == 'browse' && ! has ( 'browse' )
		let method = 'explore'
	endif
	"
	if method == 'explore' && ! exists ( 'g:loaded_netrwPlugin' )
		let method = 'edit'
	endif
	"
	if method == 'browse'
		if s:MSWIN
			" overwrite 'b:browsefilter', only applicable under Windows
			if exists ( 'b:browsefilter' )
				let bf_backup = b:browsefilter
			endif
			"
			let b:browsefilter = "Template Files (*.templates, ...)\tTemplates;*.template;*.templates\n"
						\ . "All Files (*.*)\t*.*\n"
		endif
		"
		" open a file browser, returns an empty string if "Cancel" is pressed
		let	templatefile = browse ( 0, 'edit a template file', dir, '' )
		"
		if s:MSWIN
			" reset 'b:browsefilter'
			if exists ( 'bf_backup' )
				let b:browsefilter = bf_backup
			else
				unlet b:browsefilter
			endif
		endif
		"
		" open a buffer and start editing
		if ! empty ( templatefile )
			exe 'update! | split | edit '.fnameescape( templatefile )
		endif
	elseif method == 'explore'
		" open a file explorer
		exe 'update! | split | Explore '.fnameescape( dir )
	else     " method == 'edit'
		" edit the top-level template file
		exe 'update! | split '.fnameescape( file )
	endif
	"
endfunction    " ----------  end of function mmtemplates#core#EditTemplateFiles  ----------
"
"-------------------------------------------------------------------------------
" mmtemplates#core#FindPersonalizationFile : Find the personalization file.   {{{1
"-------------------------------------------------------------------------------
"
function! mmtemplates#core#FindPersonalizationFile ( library )
	"
	" ==================================================
	"  parameters
	" ==================================================
	"
	if type( a:library ) == type( '' )
		exe 'let t_lib = '.a:library
	elseif type( a:library ) == type( {} )
		let t_lib = a:library
	else
		return s:ErrorMsg ( 'Argument "library" must be given as a dict or string.' )
	endif
	"
	" ==================================================
	"  do the job
	" ==================================================
	"
	if t_lib.properties[ 'Templates::UsePersonalizationFile' ] == 'no'
		return ''
	endif
	"
	let files = split ( globpath ( &rtp, s:Templates_PersonalizationFile, 1 ), "\<NL>" )
	"
	if empty ( files )
		return ''
	endif
	"
	return files[0]
endfunction    " ----------  end of function mmtemplates#core#FindPersonalizationFile  ----------
"
"-------------------------------------------------------------------------------
" mmtemplates#core#AddCustomTemplateFiles : Add custom template files.   {{{1
"-------------------------------------------------------------------------------
"
function! mmtemplates#core#AddCustomTemplateFiles ( library, temp_list, list_name )
	"
	" ==================================================
	"  parameters
	" ==================================================
	"
	if type( a:library ) == type( '' )
		exe 'let t_lib = '.a:library
	elseif type( a:library ) == type( {} )
		let t_lib = a:library
	else
		return s:ErrorMsg ( 'Argument "library" must be given as a dict or string.' )
	endif
	"
	if type( a:temp_list ) != type( [] )
		return s:ErrorMsg ( 'Argument "temp_list" must be given as a list.' )
	endif
	"
	if type( a:list_name ) != type( '' )
		return s:ErrorMsg ( 'Argument "list_name" must be given as a string.' )
	endif
	"
	" ==================================================
	"  do the job
	" ==================================================
	"
	for i in range( 0, len ( a:temp_list )-1 )
		"
		if type( a:temp_list[i] ) != type( [] )
			call s:ErrorMsg ( 'The entry of '.a:list_name.' with index '.i.' is not a list.' )
			continue
		endif
		"
		let entry     = a:temp_list[i]
		let file_name = get ( entry, 0, '' )
		let sym_name  = get ( entry, 1, '' )
		let edit_map  = get ( entry, 2, '' )
		let file_name = expand ( file_name )
		"
		if file_name == ''
			call s:ErrorMsg ( 'The entry of '.a:list_name.' with index '.i.' does not contain a file name.' )
			continue
		elseif ! filereadable ( file_name )
			call s:ErrorMsg ( 'The entry of '.a:list_name.' with index '.i.' does not name a readable file.' )
			continue
		endif
		"
		let sym_name = ! empty ( sym_name ) ? sym_name : 'No. '.(i+1)
		let edit_map = ! empty ( edit_map ) ? edit_map : 'nt'.(i+1)
		"
		call mmtemplates#core#ReadTemplates ( t_lib, 'load', file_name,
					\ 'name', sym_name, 'map', edit_map )
		"
	endfor
	"
endfunction    " ----------  end of function mmtemplates#core#AddCustomTemplateFiles  ----------
"
"----------------------------------------------------------------------
" mmtemplates#core#JumpToTag : Jump to the next tag.   {{{1
"----------------------------------------------------------------------
"
function! mmtemplates#core#JumpToTag ( regex )
	"
	let match	= search( '\m'.a:regex, 'c' )
	if match > 0
		" remove the target
		call setline( '.', substitute( getline('.'), a:regex, '', '' ) )
	endif
	"
	return ''
endfunction    " ----------  end of function mmtemplates#core#JumpToTag  ----------
"
"----------------------------------------------------------------------
" mmtemplates#core#DeleteOptTag : Delete the next optional tag.   {{{1
"----------------------------------------------------------------------
"
function! mmtemplates#core#DeleteOptTag ( jmp_regex, sep_regex, mode )
	"
	let col = getpos('.')[2]-1
	echo col
	"
	" separator after the target
	let match_line = search( '\m\%('.a:jmp_regex.'\)\s*\V\%('.a:sep_regex.'\)\m\s*', 'cn', line('.') )
	if match_line > 0
		call setline( '.', substitute( getline('.'), '\%>'.col.'c\%('.a:jmp_regex.'\)\s*\V\%('.a:sep_regex.'\)\m\s*', '', '' ) )
	else
		" separator before the target
		let match_line = search( '\m\s*\V\%('.a:sep_regex.'\)\m\s*\zs\%('.a:jmp_regex.'\)', 'cn', line('.') )
		if match_line > 0
			call setline( '.', substitute( getline('.'), '\s*\V\%('.a:sep_regex.'\)\m\s*\%>'.col.'c\%('.a:jmp_regex.'\)', '', '' ) )
		else
			" no separator
			let match_line = search( '\m\%('.a:jmp_regex.'\)', 'cn', line('.') )
			if match_line > 0
				call setline( '.', substitute( getline('.'), '\%>'.col.'c\%('.a:jmp_regex.'\)', '', '' ) )
			endif
		endif
	endif
	"
	if match_line > 0
		" noop
	elseif a:mode == 'n'
		" normal ctrl-d operation
		" :TODO:08.06.2014 17:27:WM: jump map configurable
		silent exe "normal! \<c-d>"
	endif
	"
endfunction    " ----------  end of function mmtemplates#core#DeleteOptTag  ----------
"
"----------------------------------------------------------------------
" mmtemplates#core#SetMapleader : Set the local mapleader.   {{{1
"----------------------------------------------------------------------
"
" list of lists: [ "<localleader>", "<globalleader>" ]
let s:mapleader_stack = []
"
function! mmtemplates#core#SetMapleader ( localleader )
	"
	if empty ( a:localleader )
		call add ( s:mapleader_stack, [] )
	else
		if exists ( 'g:maplocalleader' )
			call add ( s:mapleader_stack, [ a:localleader, g:maplocalleader ] )
		else
			call add ( s:mapleader_stack, [ a:localleader ] )
		endif
		let g:maplocalleader = a:localleader
	endif
	"
endfunction    " ----------  end of function mmtemplates#core#SetMapleader  ----------
"
"----------------------------------------------------------------------
" mmtemplates#core#ResetMapleader : Reset the local mapleader.   {{{1
"----------------------------------------------------------------------
"
function! mmtemplates#core#ResetMapleader ()
	"
	let ll_save = remove ( s:mapleader_stack, -1 )
	"
	if ! empty ( ll_save )
		if len ( ll_save ) > 1
			let g:maplocalleader = ll_save[1]
		else
			unlet g:maplocalleader
		endif
	endif
	"
endfunction    " ----------  end of function mmtemplates#core#ResetMapleader  ----------
" }}}1
"-------------------------------------------------------------------------------
"
" =====================================================================================
"  vim: foldmethod=marker
