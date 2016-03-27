"===============================================================================
"
"          File:  config.vim
"
"   Description:  Template engine: Config.
"
"                 Maps & Menus - Template Engine
"
"   VIM Version:  7.0+
"        Author:  Wolfgang Mehner, wolfgang-mehner@web.de
"  Organization:  
"       Version:  1.0
"       Created:  27.12.2015
"      Revision:  ---
"       License:  Copyright (c) 2015-2016, Wolfgang Mehner
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
" === Basic Checks ===   {{{1
"-------------------------------------------------------------------------------

" need at least 7.0
if v:version < 700
	echohl WarningMsg
	echo 'The plugin templates.vim needs Vim version >= 7.'
	echohl None
	finish
endif

" prevent duplicate loading
" need compatible
if &cp || ( exists('g:TemplatesConfig_Version') && g:TemplatesConfig_Version != 'searching' && ! exists('g:TemplatesConfig_DevelopmentOverwrite') )
	finish
endif

let s:TemplatesConfig_Version = '1.0'     " version number of this script; do not change

"-------------------------------------------------------------------------------
"  --- Find Newest Version ---   {{{2
"-------------------------------------------------------------------------------

if exists('g:TemplatesConfig_DevelopmentOverwrite')
	" skip ahead
elseif exists('g:TemplatesConfig_VersionUse')

	" not the newest one: abort
	if s:TemplatesConfig_Version != g:TemplatesConfig_VersionUse
		finish
	endif

	" otherwise: skip ahead

elseif exists('g:TemplatesConfig_VersionSearch')

	" add own version number to the list
	call add ( g:TemplatesConfig_VersionSearch, s:TemplatesConfig_Version )

	finish

else

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

		let l1 = split ( a:op1, '[.-]' )
		let l2 = split ( a:op2, '[.-]' )

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

		return 0                                    " same amount of fields, all equal
	endfunction    " ----------  end of function s:VersionComp  ----------
	" }}}3
	"-------------------------------------------------------------------------------

	try

		" collect all available version
		let g:TemplatesConfig_Version = 'searching'
		let g:TemplatesConfig_VersionSearch = []

		runtime! autoload/mmtemplates/config.vim

		" select the newest one
		call sort ( g:TemplatesConfig_VersionSearch, 's:VersionComp' )

		let g:TemplatesConfig_VersionUse = g:TemplatesConfig_VersionSearch[ 0 ]

		" run all scripts again, the newest one will be used
		runtime! autoload/mmtemplates/config.vim

		unlet g:TemplatesConfig_VersionSearch
		unlet g:TemplatesConfig_VersionUse

		finish

	catch /.*/

		" an error occurred, skip ahead
		echohl WarningMsg
		echomsg 'Search for the newest version number failed.'
		echomsg 'Using this version ('.s:TemplatesConfig_Version.').'
		echohl None
	endtry

endif
" }}}2
"-------------------------------------------------------------------------------

let g:TemplatesConfig_Version = s:TemplatesConfig_Version     " version number of this script; do not change

"----------------------------------------------------------------------
"  === Modul Setup ===   {{{1
"----------------------------------------------------------------------

" platform specifics
let s:MSWIN = has("win16") || has("win32")   || has("win64")     || has("win95")
let s:UNIX	= has("unix")  || has("macunix") || has("win32unix")

" list of template files
let s:filetype_list = {}

"-------------------------------------------------------------------------------
"  === Script: Auxiliary Functions ===   {{{1
"-------------------------------------------------------------------------------

"-------------------------------------------------------------------------------
" s:UserInput : Input using a highlighting prompt.   {{{2
"
" Parameters:
"   prompt - prompt, shown to the user (string)
"   text   - default reply (string)
"   compl  - type of completion, see :help command-completion (string, optional)
" Returns:
"   retval - the user input (string)
"
" Returns an empty string if the input procedure was aborted by the user.
"-------------------------------------------------------------------------------
function! s:UserInput ( prompt, text, ... )
	echohl Search                                        " highlight prompt
	call inputsave()                                     " preserve typeahead
	if a:0 == 0 || a:1 == ''
		let retval = input( a:prompt, a:text )             " read input
	else
		let retval = input( a:prompt, a:text, a:1 )        " read input (with completion)
	end
	call inputrestore()                                  " restore typeahead
	echohl None                                          " reset highlighting
	let retval = substitute( retval, '^\s\+', '', '' )   " remove leading whitespaces
	let retval = substitute( retval, '\s\+$', '', '' )   " remove trailing whitespaces
	return retval
endfunction    " ----------  end of function s:UserInput  ----------
" }}}2
"-------------------------------------------------------------------------------

" }}}1
"-------------------------------------------------------------------------------

function! mmtemplates#config#Add ( ft, path, ... )
	
	let ft    = tolower ( a:ft )
	let entry = [ a:path ]

	if a:0 >= 1
		call add ( entry, a:1 )
	endif
	if a:0 >= 2
		call add ( entry, a:2 )
	endif

	if has_key ( s:filetype_list, ft )
		call add ( s:filetype_list[ft], entry )
	else
		let s:filetype_list[ft] = [ entry ]
	endif

endfunction    " ----------  end of function mmtemplates#config#Add  ----------

function! mmtemplates#config#GetAll ()
	
	return s:filetype_list

endfunction    " ----------  end of function mmtemplates#config#GetAll  ----------

function! mmtemplates#config#GetFt ( ft )
	
	let ft    = tolower ( a:ft )

	if has_key ( s:filetype_list, ft )
		return s:filetype_list[ft]
	else
		return []
	endif

endfunction    " ----------  end of function mmtemplates#config#GetFt  ----------

function! mmtemplates#config#Print ()
	
	let ft_names = keys ( s:filetype_list )
	call sort ( ft_names )

	for ft in ft_names
		echo 'Filetype "'.ft.'":'
		for entry in s:filetype_list[ft]
			echo "\t- ".entry[0]
		endfor
	endfor

endfunction    " ----------  end of function mmtemplates#config#Print  ----------

"-------------------------------------------------------------------------------
"  vim: foldmethod=marker
