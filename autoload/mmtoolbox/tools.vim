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
"      Revision:  ---
"       License:  Copyright (c) 2012, Wolfgang Mehner
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
let g:Toolbox_Version= '0.9'     " version number of this script; do not change
"
"-------------------------------------------------------------------------------
" Auxiliary functions   {{{1
"-------------------------------------------------------------------------------
"
"-------------------------------------------------------------------------------
" s:ErrorMsg : Print an error message.   {{{2
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
" s:GetGlobalSetting : Get a setting from a global variable.   {{{2
"-------------------------------------------------------------------------------
function! s:GetGlobalSetting ( varname )
	if exists ( 'g:'.a:varname )
		exe 'let s:'.a:varname.' = g:'.a:varname
	endif
endfunction    " ----------  end of function s:GetGlobalSetting  ----------
" }}}2
"
"-------------------------------------------------------------------------------
" NewToolbox : Create a new toolbox.   {{{1
"-------------------------------------------------------------------------------
function! mmtoolbox#tools#NewToolbox ()
	"
	let toolbox = {
				\	'mapleader' : '\',
				\ 'tools'     : {},
				\ 'names'     : [],
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
	endif
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
			" the category is the last directory
			let name = fnamemodify( file, ':t:r' )
			let cat = fnamemodify( file, ':p:h:t' )
			"
			" try to load and initialize
			try
				" 
				" call the init function
				exe 'let retlist = mmtoolbox#'.cat.'#'.name.'#Init()'
				"
				" assemble the entry
				let entry = {
							\	"name"       : name,
							\	"cat"        : cat,
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
" Info : Get the list of all tools.   {{{1
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
		let line .= "category: ".entry.cat." / "
		let line .= repeat ( " ", 45-len(line) )
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
			exe 'call mmtoolbox#'.entry.cat.'#'.entry.name.'#AddMaps()'
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
	else                                 | let mleader = 't'
	endif
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
		let menu_item = entry.prettyname
		let menu_item = escape ( menu_item, ' .|\' )
		let menu_item = substitute ( menu_item, '\V&', '\&&', 'g' )
		let menu_scut = substitute ( menu_item, '\w',  '\&&', '' )
		let menu_root = a:root.'.'.menu_scut
		"
		" create the menu header
		exe 'amenu '.menu_root.'.'.menu_item.'<TAB>'.menu_item.' :echo "This is a menu header."<CR>'
		exe 'amenu '.menu_root.'.-SepHead-     :'
		"
		try
			" try to create the menu
			exe 'call mmtoolbox#'.entry.cat.'#'.entry.name.'#AddMenu('.string( menu_root ).',mleader)'
		catch /.*/
			" could not load the plugin: ?
			call s:ErrorMsg ( "Could not create maps for the tool \"".name."\" (".v:exception.")",
						\	" - occurred at " . v:throwpoint )
		endtry
	endfor
	"
endfunction    " ----------  end of function mmtoolbox#tools#AddMenus  ----------
" }}}1
"
" =====================================================================================
"  vim: foldmethod=marker
