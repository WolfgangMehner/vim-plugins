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
"      Revision:  04.01.2014
"       License:  Copyright (c) 2012-2014, Wolfgang Mehner
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
if &cp || ( exists('g:Toolbox_Version') && ! exists('g:Toolbox_DevelopmentOverwrite') )
	finish
endif
let g:Toolbox_Version= '1.0.1'     " version number of this script; do not change
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
	let name = 'g:'.a:plugin.'_UseTool_'.a:name
	if exists ( name )
		return {name}
	endif
	return 'no'
endfunction    " ----------  end of function s:GetToolConfig  ----------
" }}}2
"-------------------------------------------------------------------------------
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
	" - names     : the names of all the tools, sorted alphabetically
	" - n_menu    : the number of tools which create a menu
	let toolbox = {
				\ 'plugin'    : a:plugin,
				\ 'mapleader' : '\',
				\ 'tools'     : {},
				\ 'names'     : [],
				\ 'n_menu'    : 0,
				\	}
	"
	return toolbox
	"
endfunction    " ----------  end of function mmtoolbox#tools#NewToolbox  ----------
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
			"
			" the name is the basename of the file
			let name = fnamemodify( file, ':t:r' )
			"
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
			if s:GetToolConfig ( a:toolbox.plugin, name ) != 'yes'
				continue
			endif
			"
			" try to load and initialize
			try
				" 
				" get tool information
				let retlist = mmtoolbox#{name}#GetInfo()
				"
				" assemble the entry
				let entry = {
							\	"name"       : name,
							\	"prettyname" : retlist[0],
							\	"version"    : retlist[1],
							\	"enabled"    : 1,
							\	"domenu"     : 1,
							\	"filename"   : file,
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
				let a:toolbox.tools[ name ] = entry
				call add ( a:toolbox.names, name )
				"
				if entry.enabled && entry.domenu
					let a:toolbox.n_menu += 1
				endif
				"
			catch /.*/
				" could not load the plugin: ?
				call s:ErrorMsg ( "Could not load the tool \"".name."\" (".v:exception.")",
							\	" - occurred at " . v:throwpoint )
			endtry
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
	" has been loaded?
	if s:GetToolConfig ( a:toolbox.plugin, a:name ) != 'yes'
		return 0
	endif
	"
	let enabled = 0
	"
	try
		let enabled = mmtoolbox#{a:name}#Property('get','enabled')
	catch /.*/
		" fail quietly
	endtry
	"
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
			call mmtoolbox#{entry.name}#AddMaps()
		catch /.*/
			" could not load the plugin: ?
			call s:ErrorMsg ( "Could not create maps for the tool \"".name."\" (".v:exception.")",
						\	" - occurred at " . v:throwpoint )
		endtry
	endfor
endfunction    " ----------  end of function mmtoolbox#tools#AddMaps  ----------
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
	" go through all the tools
	for name in a:toolbox.names
		let entry = a:toolbox.tools[ name ]
		"
		if ! entry.enabled || ! entry.domenu
			continue
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
			call mmtoolbox#{entry.name}#AddMenu( menu_root, mleader )
		catch /.*/
			" could not load the plugin: ?
			call s:ErrorMsg ( "Could not create menus for the tool \"".name."\" (".v:exception.")",
						\	" - occurred at " . v:throwpoint )
		endtry
	endfor
	"
endfunction    " ----------  end of function mmtoolbox#tools#AddMenus  ----------
" }}}1
"
" =====================================================================================
"  vim: foldmethod=marker
