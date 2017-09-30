"===============================================================================
"
"          File:  tools.vim
" 
"   Description:  Toolbox engine.
" 
"                 Maps & Menus - Toolbox Engine
" 
"   VIM Version:  7.0+
"        Author:  Wolfgang Mehner, wolfgang-mehner@web.de
"  Organization:  
"       Version:  see variable g:Toolbox_Version below
"       Created:  29.12.2012
"      Revision:  30.09.2017
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

"-------------------------------------------------------------------------------
" Basic checks.   {{{1
"-------------------------------------------------------------------------------
"
" need at least 7.0
if v:version < 700
	echohl WarningMsg
	echo 'The plugin tools/tools.vim needs Vim version >= 7.'
	echohl None
	finish
endif
"
" prevent duplicate loading
" need compatible
if &cp || ( exists('g:Toolbox_Version') && g:Toolbox_Version != 'searching' && ! exists('g:Toolbox_DevelopmentOverwrite') )
	finish
endif
"
let s:Toolbox_Version = '1.3'     " version number of this script; do not change
"
"----------------------------------------------------------------------
"  --- Find Newest Version ---   {{{2
"----------------------------------------------------------------------
"
if exists('g:Toolbox_DevelopmentOverwrite')
	" skip ahead
elseif exists('g:Toolbox_VersionUse')
	"
	" not the newest one: abort
	if s:Toolbox_Version != g:Toolbox_VersionUse
		finish
	endif
	"
	" otherwise: skip ahead
	"
elseif exists('g:Toolbox_VersionSearch')
	"
	" add own version number to the list
	call add ( g:Toolbox_VersionSearch, s:Toolbox_Version )
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
		let g:Toolbox_Version = 'searching'
		let g:Toolbox_VersionSearch = []
		"
		runtime! autoload/mmtoolbox/tools.vim
		"
		" select the newest one
		call sort ( g:Toolbox_VersionSearch, 's:VersionComp' )
		"
		let g:Toolbox_VersionUse = g:Toolbox_VersionSearch[ 0 ]
		"
		" run all scripts again, the newest one will be used
		runtime! autoload/mmtoolbox/tools.vim
		"
		unlet g:Toolbox_VersionSearch
		unlet g:Toolbox_VersionUse
		"
		finish
		"
	catch /.*/
		"
		" an error occurred, skip ahead
		echohl WarningMsg
		echomsg 'Search for the newest version number failed.'
		echomsg 'Using this version ('.s:Toolbox_Version.').'
		echohl None
	endtry
	"
endif
" }}}2
"-------------------------------------------------------------------------------
"
let g:Toolbox_Version = s:Toolbox_Version     " version number of this script; do not change
"
"-------------------------------------------------------------------------------
" Auxiliary functions   {{{1
"-------------------------------------------------------------------------------
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
" s:GetToolConfig : Get the configuration from a global variable.   {{{2
"
" Parameters:
"   plugin - the name of the plg-in (string)
"   name - the name of the tool (string)
" Returns:
"   config - 'yes' or 'no' (string)
"
" Returns whether the tool should be loaded.
" If the variable g:<plugin>_UseTool_<name> exists, return its value.
" Otherwise returns 'no'.
"-------------------------------------------------------------------------------
function! s:GetToolConfig ( plugin, name )
	"
	let name = s:GetToolConfigVarName ( a:plugin, a:name )
	if exists ( name )
		return {name}
	endif
	return 'no'
endfunction    " ----------  end of function s:GetToolConfig  ----------
"
"-------------------------------------------------------------------------------
" s:GetToolConfigVarName : Get the name of the configuration variable.   {{{2
"
" Parameters:
"   plugin - the name of the plg-in (string)
"   name - the name of the tool (string)
" Returns:
"   varname - name of the configuration variable (string)
"
" Returns the variable g:<plugin>_UseTool_<name>.
"-------------------------------------------------------------------------------
function! s:GetToolConfigVarName ( plugin, name )
	return 'g:'.a:plugin.'_UseTool_'.a:name
endfunction    " ----------  end of function s:GetToolConfigVarName  ----------
" }}}2
"-------------------------------------------------------------------------------
"
"-------------------------------------------------------------------------------
" Modul setup.   {{{1
"-------------------------------------------------------------------------------
"
" tool registry,
" maps plug-in name -> toolbox
if ! exists ( 's:ToolRegistry' )
	let s:ToolRegistry = {}
endif
"
"-------------------------------------------------------------------------------
" NewToolbox : Create a new toolbox.   {{{1
"-------------------------------------------------------------------------------
function! mmtoolbox#tools#NewToolbox ( plugin )
	"
	" properties:
	" - plugin    : the name (id) if the plugin
	" - mapleader : only required for menu creation,
	"               for map creation, the current mapleader/maplocalleader is
	"               used, it must already be set accordingly
	" - tools     : dictionary holding the meta information about the tools
	"               associates: name -> info
	" - unused    : further tools which have not been loaded
	" - names     : the names of all the tools, sorted alphabetically
	" - n_menu    : the number of tools which create a menu
	" - menu_root : last root menu used for menu creation
	" - menu_mldr : last mapleader menu used for menu creation (escaped)
	let toolbox = {
				\ 'plugin'    : a:plugin,
				\ 'mapleader' : '\',
				\ 'tools'     : {},
				\ 'unused'    : {},
				\ 'names'     : [],
				\ 'n_menu'    : 0,
				\ 'menu_root' : '',
				\ 'menu_mldr' : '',
				\	}
	"
	let s:ToolRegistry[ a:plugin ] = toolbox
	"
	return toolbox
	"
endfunction    " ----------  end of function mmtoolbox#tools#NewToolbox  ----------
"
"-------------------------------------------------------------------------------
" s:LoadTool : Load a tool.   {{{1
"
" Parameters:
"   toolbox - the toolbox (dict)
"   name_full - the full name of the tool (string)
"   name - the short name of the tool (string)
"   file - the script (string)
" Returns:
"   success - tool loaded without errors, but might still be disabled (integer)
"-------------------------------------------------------------------------------
function! s:LoadTool ( toolbox, name_full, name, file )

	let toolbox   = a:toolbox
	let name_full = a:name_full
	let name      = a:name

	" try to load and initialize
	try
		"
		" get tool information
		let retlist = {name_full}#GetInfo()
		"
		" assemble the entry
		let entry = {
					\	"name_full"  : a:name_full,
					\	"name"       : name,
					\	"prettyname" : retlist[0],
					\	"version"    : retlist[1],
					\	"enabled"    : 1,
					\	"domenu"     : 1,
					\	"filename"   : a:file,
					\	}
		"
		" process the flags
		if len ( retlist ) > 2
			if index ( retlist, 'nomenu', 2 ) != -1
				let entry.domenu = 0
			endif
			if index ( retlist, 'disabled', 2 ) != -1
				let entry.enabled = 0
			endif
		endif
		"
		" save the entry
		let toolbox.tools[ name ] = entry
		call add ( toolbox.names, name )
		"
		if entry.enabled && entry.domenu
			let toolbox.n_menu += 1
		endif
		"
		return 1
		"
	catch /.*/
		" could not load the plugin: ?
		call s:ErrorMsg ( "Could not load the tool \"".name."\" (".v:exception.")",
					\	" - occurred at " . v:throwpoint )
	endtry
	"
	return 0
	"
endfunction    " ----------  end of function s:LoadTool  ----------
"
"-------------------------------------------------------------------------------
" s:RegisterTool : Register an unused tool.   {{{1
"
" Parameters:
"   toolbox - the toolbox (dict)
"   name_full - the full name of the tool (string)
"   name - the short name of the tool (string)
"   file - the script (string)
" Returns:
"   -
"-------------------------------------------------------------------------------
function! s:RegisterTool ( toolbox, name_full, name, file )
	"
	" assemble the entry
	" - also record which tools was loaded later on, to keep creating correct
	"   menus
	let entry = {
				\	"name_full"  : a:name_full,
				\	"name"       : a:name,
				\	"filename"   : a:file,
				\ "loaded"     : 0,
				\	}
	"
	let a:toolbox.unused[ a:name ] = entry
	"
endfunction    " ----------  end of function s:RegisterTool  ----------
"
"-------------------------------------------------------------------------------
" Load : Load the tools from various directories.   {{{1
"-------------------------------------------------------------------------------
function! mmtoolbox#tools#Load ( toolbox, directories )
	"
	" check the parameters
	if type( a:toolbox ) != type( {} )
		return s:ErrorMsg ( 'Argument "toolbox" must be given as a dict.' )
	elseif type( a:directories ) != type( [] )
		return s:ErrorMsg ( 'Argument "directories" must be given as a list.' )
	endif
	"
	let a:toolbox.n_menu = 0
	"
	" go through all directories
	for dir in a:directories
		"
		" is a directory
		if ! isdirectory ( dir )
			continue
		endif
		"
		" go through all dir/*.vim
		for file in split( glob (dir.'/*.vim'), '\n' )

			if file =~ 'autoload[/\\]\(.\{-}\)[/\\]\{1,2}\([^/\\]\+\)\.vim$'
				let mlist = matchlist( file, 'autoload[/\\]\(.\{-}\)[/\\]\{1,2}\([^/\\]\+\)\.vim$' )
				let name_full  = substitute( mlist[1], '[/\\]', '#', 'g' ).'#'.mlist[2]
				let name       = mlist[2]
			else
				" invalid name
				continue
			endif

			" do not process 'tools.vim' (this script)
			if name == 'tools'
				continue
			endif
			"
			" do not load multiple times
			if has_key ( a:toolbox.tools, name )
				continue
			endif
			"
			" check whether to use the tool
			if s:GetToolConfig ( a:toolbox.plugin, name ) == 'yes'
				call s:LoadTool ( a:toolbox, name_full, name, file )
			else
				call s:RegisterTool ( a:toolbox, name_full, name, file )
			endif
			"
		endfor
		"
	endfor
	"
	" sort the names
	call sort ( a:toolbox.names )
	"
endfunction    " ----------  end of function mmtoolbox#tools#Load  ----------
"
"-------------------------------------------------------------------------------
" s:LoadAdditionalTool : Load an additional tool.   {{{1
"
" Parameters:
"   toolbox_name - the name of the toolbox (string)
"   name - the name of the tool (string)
" Returns:
"   -
"-------------------------------------------------------------------------------
function! s:LoadAdditionalTool ( toolbox_name, name )
	"
	let toolbox = s:ToolRegistry[ a:toolbox_name ]
	let name    = a:name
	"
	" do not load multiple times
	if has_key ( toolbox.tools, name )
		echo 'The tool "'.name.'" has already been loaded.'
		return
	endif
	"
	" check the 'unused' entry (should not cause any problems)
	if ! has_key ( toolbox.unused, name ) || toolbox.unused[name].loaded == 1
		echo 'Internal error #1 while loading the tool "'.name.'".'
		return
	endif
	"
	" check the 'menu_root' and 'menu_mldr' entry (should not cause any problems)
	if empty ( toolbox.menu_root ) || empty ( toolbox.menu_mldr )
		echo 'Internal error #2 while loading the tool "'.name.'".'
		return
	endif
	"
	" load the tool
	let toolbox.unused[name].loaded = 1
	let success = s:LoadTool ( toolbox, toolbox.unused[name].name_full, name, toolbox.unused[name].filename )
	"
	" create the menu entry
	if success
		call s:CreateToolMenu ( toolbox, name, toolbox.menu_root, toolbox.menu_mldr )
	endif
	"
	echomsg 'To always load the tool "'.name.'", add this line to your vimrc:'
	echomsg '  let '.s:GetToolConfigVarName ( toolbox.plugin, name )." = 'yes'"
endfunction    " ----------  end of function s:LoadAdditionalTool  ----------
"
"-------------------------------------------------------------------------------
" ToolEnabled : Whether a tool is enabled.   {{{1
"-------------------------------------------------------------------------------
function! mmtoolbox#tools#ToolEnabled ( toolbox, name )
	"
	" check the parameters
	if type( a:toolbox ) != type( {} )
		return s:ErrorMsg ( 'Argument "toolbox" must be given as a dict.' )
	endif
	"
	if type( a:name ) != type( '' )
		return s:ErrorMsg ( 'Argument "name" must be given as a string.' )
	endif
	"
	" has not been loaded?
	if ! has_key ( a:toolbox.tools, a:name )
		return 0
	endif

	let entry = a:toolbox.tools[ a:name ]
	let enabled = 0

	try
		let enabled = {entry.name_full}#Property('get','enabled')
	catch /.*/
		" fail quietly
	endtry

	return enabled
endfunction    " ----------  end of function mmtoolbox#tools#ToolEnabled  ----------
"
"-------------------------------------------------------------------------------
" Property : Get/set a property.   {{{1
"-------------------------------------------------------------------------------
function! mmtoolbox#tools#Property ( toolbox, property, ... )
	"
	" check the parameters
	if type( a:toolbox ) != type( {} )
		return s:ErrorMsg ( 'Argument "toolbox" must be given as a dict.' )
	endif
	"
	if type( a:property ) != type( '' )
		return s:ErrorMsg ( 'Argument "property" must be given as a string.' )
	endif
	"
	" check the property
	if a:property == 'mapleader'
		" ok
	elseif a:property == 'empty-menu'
		return a:toolbox.n_menu == 0
	else
		return s:ErrorMsg ( 'Unknown property: '.a:property )
	endif
	"
	" get/set the property
	if a:0 == 0
		return a:toolbox[ a:property ]
	else
		let a:toolbox[ a:property ] = a:1
	endif
	"
endfunction    " ----------  end of function mmtoolbox#tools#Property  ----------
"
"-------------------------------------------------------------------------------
" GetList : Get the list of all tools.   {{{1
"-------------------------------------------------------------------------------
function! mmtoolbox#tools#GetList ( toolbox )
	"
	" check the parameters
	if type( a:toolbox ) != type( {} )
		return s:ErrorMsg ( 'Argument "toolbox" must be given as a dict.' )
	endif
	"
	" assemble the list
	let toollist = []
	"
	for name in a:toolbox.names
		let entry = a:toolbox.tools[ name ]
		if entry.enabled
			call add ( toollist, entry.prettyname." (".entry.version.")" )
		else
			call add ( toollist, entry.prettyname." (".entry.version.", disabled)" )
		endif
	endfor
	"
	call add ( toollist, '(toolbox version '.g:Toolbox_Version.')' )
	"
	return toollist
	"
endfunction    " ----------  end of function mmtoolbox#tools#GetList  ----------
"
"-------------------------------------------------------------------------------
" Info : Echo debug information.   {{{1
"-------------------------------------------------------------------------------
function! mmtoolbox#tools#Info ( toolbox )
	"
	" check the parameters
	if type( a:toolbox ) != type( {} )
		return s:ErrorMsg ( 'Argument "toolbox" must be given as a dict.' )
	endif
	"
	let txt = ''
	"
	for name in a:toolbox.names
		let entry = a:toolbox.tools[ name ]
		"
		let line  = entry.prettyname." (".entry.version."), "
		let line .= repeat ( " ", 25-len(line) )
		if entry.enabled | let line .= "enabled,  "
		else             | let line .= "disabled, " | endif
		if entry.domenu  | let line .= "menu,   "
		else             | let line .= "nomenu, " | endif
		let line .= "from: ".entry.filename."\n"
		"
		let txt .= line
	endfor
	"
	echo txt
	"
endfunction    " ----------  end of function mmtoolbox#tools#Info  ----------
"
"-------------------------------------------------------------------------------
" AddMaps : Create maps for all tools.   {{{1
"-------------------------------------------------------------------------------
function! mmtoolbox#tools#AddMaps ( toolbox )
	"
	" check the parameters
	if type( a:toolbox ) != type( {} )
		return s:ErrorMsg ( 'Argument "toolbox" must be given as a dict.' )
	endif
	"
	" go through all the tools
	for name in a:toolbox.names
		let entry = a:toolbox.tools[ name ]
		"
		if ! entry.enabled
			continue
		endif
		"
		try
			" try to create the maps
			call {entry.name_full}#AddMaps()
		catch /.*/
			" could not load the plugin: ?
			call s:ErrorMsg ( "Could not create maps for the tool \"".name."\" (".v:exception.")",
						\	" - occurred at " . v:throwpoint )
		endtry
	endfor
endfunction    " ----------  end of function mmtoolbox#tools#AddMaps  ----------
"
"-------------------------------------------------------------------------------
" s:CreateToolMenu : Create the sub-menu for a tool.   {{{1
"
" Parameters:
"   toolbox - the toolbox (dict)
"   name - the name of the tool (string)
"   root - the root menu (string)
"   mleader - the map leader (string)
" Returns:
"   -
"-------------------------------------------------------------------------------
function! s:CreateToolMenu ( toolbox, name, root, mleader )
	"
	let entry = a:toolbox.tools[ a:name ]
	"
	if ! entry.enabled || ! entry.domenu
		return
	endif
	"
	" correctly escape the name
	" and add a shortcut
	let menu_item_r = escape ( entry.prettyname, ' .|\' )
	let menu_item_l = substitute ( menu_item_r, '\V&', '\&&', 'g' )
	let menu_scut   = substitute ( menu_item_l, '\w',  '\&&', '' )
	let menu_root   = a:root.'.'.menu_scut
	"
	" create the menu header
	exe 'amenu '.menu_root.'.'.menu_item_l.'<TAB>'.menu_item_r.' :echo "This is a menu header."<CR>'
	exe 'amenu '.menu_root.'.-SepHead-     :'
	"
	try
		" try to create the menu
		call {entry.name_full}#AddMenu( menu_root, a:mleader )
	catch /.*/
		" could not load the plugin: ?
		call s:ErrorMsg ( "Could not create menus for the tool \"".a:name."\" (".v:exception.")",
					\	" - occurred at " . v:throwpoint )
	endtry
	"
endfunction    " ----------  end of function s:CreateToolMenu  ----------
"
"-------------------------------------------------------------------------------
" AddMenus : Create menus for all tools.   {{{1
"-------------------------------------------------------------------------------
function! mmtoolbox#tools#AddMenus ( toolbox, root )
	"
	" check the parameters
	if type( a:toolbox ) != type( {} )
		return s:ErrorMsg ( 'Argument "toolbox" must be given as a dict.' )
	endif
	"
	if type( a:root ) != type( '' )
		return s:ErrorMsg ( 'Argument "root" must be given as a string.' )
	endif
	"
	" correctly escape the mapleader
	if ! empty ( a:toolbox.mapleader )   | let mleader = a:toolbox.mapleader
	elseif exists ( 'g:maplocalleader' ) | let mleader = g:maplocalleader
	else                                 | let mleader = '\'
	endif
	"
	if mleader == ''
		let mleader = '\'
	endif
	"
	let mleader = escape ( mleader, ' .|\' )
	let mleader = substitute ( mleader, '\V&', '\&&', 'g' )
	"
	" save the information for later use
	let a:toolbox.menu_root = a:root
	let a:toolbox.menu_mldr = mleader
	"
	" go through all the tools
	for name in a:toolbox.names
		call s:CreateToolMenu ( a:toolbox, name, a:root, mleader )
	endfor
	"
	" create 'load more tools' below the other entries
	let root_level  = len( split( a:root, '\%(\_^\|[^\\]\)\%(\\\\\)*\zs\.' ) )
	let prio_prefix = repeat ( '.', root_level )
	exe 'amenu '.prio_prefix.'600     '.a:root.'.-SepBottom-                          :'
	exe 'amenu '.prio_prefix.'600.400 '.a:root.'.load\ more\ tools.Available\ Tools   :echo "This is a menu header."<CR>'
	exe 'amenu '.prio_prefix.'600.400 '.a:root.'.load\ more\ tools.-SepHead-          :'
	"
	let shead = 'amenu <silent> '.a:root.'.load\ more\ tools.'
	"
	for name in sort ( keys ( a:toolbox.unused ) )
		silent exe shead.name.'  :call <SID>LoadAdditionalTool('.string( a:toolbox.plugin ).','.string( name ).')<CR>'
	endfor
	"
	"
endfunction    " ----------  end of function mmtoolbox#tools#AddMenus  ----------
" }}}1
"-------------------------------------------------------------------------------
"
" =====================================================================================
"  vim: foldmethod=marker
