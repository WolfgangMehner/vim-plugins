"===============================================================================
"
"          File:  mmtemplates#wizard.vim
" 
"   Description:  Template engine: Wizard.
"
"                 Maps & Menus - Template Engine
" 
"   VIM Version:  7.0+
"        Author:  Wolfgang Mehner, wolfgang-mehner@web.de
"  Organization:  
"       Version:  1.0
"       Created:  01.12.2014
"      Revision:  ---
"       License:  Copyright (c) 2014, Wolfgang Mehner
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
if &cp || ( exists('g:TemplatesWizard_Version') && g:TemplatesWizard_Version != 'searching' && ! exists('g:TemplatesWizard_DevelopmentOverwrite') )
	finish
endif
"
let s:TemplatesWizard_Version = '1.0alpha'     " version number of this script; do not change
"
"-------------------------------------------------------------------------------
"  --- Find Newest Version ---   {{{2
"-------------------------------------------------------------------------------
"
if exists('g:TemplatesWizard_DevelopmentOverwrite')
	" skip ahead
elseif exists('g:TemplatesWizard_VersionUse')
	"
	" not the newest one: abort
	if s:TemplatesWizard_Version != g:TemplatesWizard_VersionUse
		finish
	endif
	"
	" otherwise: skip ahead
	"
elseif exists('g:TemplatesWizard_VersionSearch')
	"
	" add own version number to the list
	call add ( g:TemplatesWizard_VersionSearch, s:TemplatesWizard_Version )
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
		let g:TemplatesWizard_Version = 'searching'
		let g:TemplatesWizard_VersionSearch = []
		"
		runtime! autoload/mmtemplates/wizard.vim
		"
		" select the newest one
		call sort ( g:TemplatesWizard_VersionSearch, 's:VersionComp' )
		"
		let g:TemplatesWizard_VersionUse = g:TemplatesWizard_VersionSearch[ 0 ]
		"
		" run all scripts again, the newest one will be used
		runtime! autoload/mmtemplates/wizard.vim
		"
		unlet g:TemplatesWizard_VersionSearch
		unlet g:TemplatesWizard_VersionUse
		"
		finish
		"
	catch /.*/
		"
		" an error occurred, skip ahead
		echohl WarningMsg
		echomsg 'Search for the newest version number failed.'
		echomsg 'Using this version ('.s:TemplatesWizard_Version.').'
		echohl None
	endtry
	"
endif
" }}}2
"-------------------------------------------------------------------------------
"
let g:TemplatesWizard_Version = s:TemplatesWizard_Version     " version number of this script; do not change
"
"-------------------------------------------------------------------------------
"  === Script: Auxiliary Functions ===   {{{1
"-------------------------------------------------------------------------------
"
"-------------------------------------------------------------------------------
" s:HitEnter : Wait for enter key.   {{{2
"
" Echoes "Hit return." and then waits for a key.
"
" Parameters:
"   -
" Returns:
"   -
"-------------------------------------------------------------------------------
function! s:HitEnter ()
	echo 'Hit return.'
	call getchar()
endfunction    " ----------  end of function s:HitEnter  ----------
"
"-------------------------------------------------------------------------------
" s:Question : Ask the user a question.   {{{2
"
" Parameters:
"   prompt    - prompt, shown to the user (string)
"   highlight - "normal" or "warning" (string, default "normal")
" Returns:
"   retval - the user input (integer)
"
" The possible values of 'retval' are:
"    1 - answer was yes ("y")
"    0 - answer was no ("n")
"   -1 - user aborted ("ESC" or "CTRL-C")
"-------------------------------------------------------------------------------
function! s:Question ( text, ... )
	"
	let ret = -2
	"
	" highlight prompt
	if a:0 == 0 || a:1 == 'normal'
		echohl Search
	elseif a:1 == 'warning'
		echohl Error
	else
		echoerr 'Unknown option : "'.a:1.'"'
		return
	endif
	"
	" question
	echo a:text.' [y/n]: '
	"
	" answer: "y", "n", "ESC" or "CTRL-C"
	while ret == -2
		let c = nr2char( getchar() )
		"
		if c == "y"
			let ret = 1
		elseif c == "n"
			let ret = 0
		elseif c == "\<ESC>" || c == "\<C-C>"
			let ret = -1
		endif
	endwhile
	"
	" reset highlighting
	echohl None
	"
	return ret
endfunction    " ----------  end of function s:Question  ----------
" }}}2
"-------------------------------------------------------------------------------
"
"-------------------------------------------------------------------------------
" mmtemplates#wizard#SetupWizard : Setup wizard.   {{{1
"
" Parameters:
"   library - the template library (dict)
" Returns:
"   success - whether the operation was successful
"-------------------------------------------------------------------------------
function! mmtemplates#wizard#SetupWizard ( library )
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
	let list_display = [ 'What do you want to set up?' ]
	let list_wizards = []
	"
	call add ( list_display, len( list_display ).': personalization file (for your name, mail, ...), shared across plug-ins' )
	call add ( list_wizards, 's:SetupPersonal' )
	"
	call add ( list_display, len( list_display ).': -abort-' )
	"
	let d_idx = inputlist ( list_display )
	let use_wizard = get ( list_wizards, d_idx-1, '' )
	echo "\n"
	"
	if d_idx >= 1 && use_wizard != ''
		call call ( use_wizard, [ t_lib ] )
	endif
	"
	return
endfunction    " ----------  end of function mmtemplates#wizard#SetupWizard  ----------
"
"-------------------------------------------------------------------------------
" s:SetupPersonal : Setup personalization template file.   {{{1
"
" Parameters:
"   library - the template library (dict)
" Returns:
"   success - whether the personalization template file was created successfully
"-------------------------------------------------------------------------------
function! s:SetupPersonal ( library )
	"
	let t_lib = a:library
	"
	" ==================================================
	"  do the job
	" ==================================================
	"
	" check setting g:Templates_UsePersonalizationFile
	" check property Templates::UsePersonalizationFile
	"
"	" start the wizard
"	if get ( a:data, 'ask_start_question', 1 ) && 1 != s:Question ( 'Template personalization missing. Start setup wizard?' )
"		return 0
"	endif
	"
	let settings = mmtemplates#core#Resource ( a:library, 'settings_table' )[0]
	let personal_file = mmtemplates#core#FindPersonalizationFile (a:library )
	"
	echo "\nThe template personalization file will be read by all template libraries which"
				\ ."\nsupport this feature. It should only contain information which are used by all"
				\ ."\ntemplate libraries, such as the name, mail address, ..."
				\ ."\nIt is located in a directory relative to runtimepath (see :help rtp), under the"
				\ ."\nsubdirectory and filename:"
				\ ."\n    ".settings.Templates_PersonalizationFile
	"
	" does the personalization file already exist?
	if personal_file != '' && filewritable ( personal_file ) == 1
		echo "\nThe template personalization file already exists:"
					\ ."\n    ".personal_file
	endif
	"
	call s:HitEnter ()
	"
	" let the user select a location for the file
	if personal_file == ''
		let subdir   = fnamemodify ( settings.Templates_PersonalizationFile, ':h' )
		let filename = fnamemodify ( settings.Templates_PersonalizationFile, ':t' )
		let filename = substitute  ( filename, '\*$', 's', '' )
		"
		let dir_list = split ( &g:runtimepath, ',' )
		let dir_list_rw      = []
		let dir_list_display = [ 'Where should the file be located?' ]
		"
		for dir in dir_list
			if filewritable ( dir ) == 2
				call add ( dir_list_rw,      dir.'/'.subdir )
				call add ( dir_list_display, len( dir_list_rw ).': '.dir.'/'.subdir )
			endif
		endfor
		call add ( dir_list_display, len( dir_list_rw )+1.': -abort-' )
		"
		echo "\n"
		let d_idx = inputlist ( dir_list_display )
		let personal_file = get ( dir_list_rw, d_idx-1, '' )
		echo "\n"
		"
		if d_idx >= 1 && personal_file != ''
			let personal_file .= '/'.filename
		endif
	endif
	"
	" create the file if necessary
	if ! filereadable ( personal_file )
		try
			call mkdir ( fnamemodify ( personal_file, ':h' ), 'p' )
		catch /.*/   " fail quietly, the directory may already exist
		endtry
		try
			let sample_file = mmtemplates#core#Resource ( t_lib, 'get', 'property', 'Templates::FileSkeleton::personal' )[0]
			call writefile ( readfile ( sample_file ), personal_file )
		catch /.*/   " fail quietly, we check for the file later on
		endtry
	endif
	"
	" check the success
	if personal_file == ''
		" no file chosen
		echo "\nNo personalization file chosen."
					\ ."\nFor configuring the file manually, see:"
					\ ."\n    :help g:Templates_PersonalizationFile"
	elseif ! filereadable ( personal_file )
		" automatic setup failed
		help g:Templates_PersonalizationFile
		redraw
		echo "Failed to create the personalization file:"
					\ ."\n    ".personal_file
					\ ."\nFor configuring the file manually, see:"
					\ ."\n    :help g:Templates_PersonalizationFile"
	else
		call mmtemplates#core#EnableTemplateFile ( t_lib, 'personal' )
		"
		" automatic setup succeeded, start editing
		let plugin_name   = mmtemplates#core#Resource ( t_lib, 'get', 'property', 'Templates::Names::Plugin' )[0]
		let filetype_name = mmtemplates#core#Resource ( t_lib, 'get', 'property', 'Templates::Names::Filetype' )[0]
		let maplead       = mmtemplates#core#Resource ( t_lib, 'get', 'property', 'Templates::Mapleader' )[0]
		let reload_map    = mmtemplates#core#Resource ( t_lib, 'get', 'property', 'Templates::RereadTemplates::Map' )[0]
		"
		exe 'split '.fnameescape( personal_file )
		redraw
		echo "Change your personal details and then reload the template library:"
					\ ."\n- use the menu entry \"".plugin_name." -> Snippets -> reread templates\""
					\ ."\n- use the map \"".maplead.reload_map."\" inside a ".filetype_name." buffer"
		"
		return 1
	endif
	"
	return 0
endfunction    " ----------  end of function s:SetupPersonal  ----------
" }}}1
"-------------------------------------------------------------------------------
"
"-------------------------------------------------------------------------------
"  vim: foldmethod=marker
