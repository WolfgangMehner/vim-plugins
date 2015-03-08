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
"       License:  Copyright (c) 2014-2015, Wolfgang Mehner
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
"----------------------------------------------------------------------
"  === Modul Setup ===   {{{1
"----------------------------------------------------------------------
"
" platform specifics
let s:MSWIN = has("win16") || has("win32")   || has("win64")     || has("win95")
let s:UNIX	= has("unix")  || has("macunix") || has("win32unix")
"
"-------------------------------------------------------------------------------
"  === Script: Auxiliary Functions ===   {{{1
"-------------------------------------------------------------------------------
"
"-------------------------------------------------------------------------------
" s:GetFileFromBrowser : Get a file from a GUI filebrowser.   {{{2
"
" Parameters:
"   save - if true, select a file for saving (integer)
"   title - title of the window (string)
"   dir - directory to start browsing in (string)
"   default - default file name (string)
"   browsefilter - filter for selecting files (string, optional)
" Returns:
"   file - the filename (string)
"
" Returns an empty string if no file was chosen by the user.
"-------------------------------------------------------------------------------
function! s:GetFileFromBrowser ( save, title, dir, default, ... )
	"
	if s:MSWIN
		" overwrite 'b:browsefilter', only applicable under Windows
		if exists ( 'b:browsefilter' )
			let bf_backup = b:browsefilter
		endif
		"
		if a:0 == 0
			let b:browsefilter = "Template Files (*.templates, ...)\tTemplates;*.template;*.templates\n"
						\ . "All Files (*.*)\t*.*\n"
		else
			let b:browsefilter = a:1
		endif
	endif
	"
	" open a file browser, returns an empty string if "Cancel" is pressed
	let	file = browse ( a:save, a:title, a:dir, a:default )
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
	return file
endfunction    " ----------  end of function s:GetFileFromBrowser  ----------
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
"
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
"
"-------------------------------------------------------------------------------
" s:VimrcCodeSnippet : Codesnippet for .vimrc.   {{{2
"
" Parameters:
"   text - the snippet (string)
" Returns:
"   -
"-------------------------------------------------------------------------------
function! s:VimrcCodeSnippet ( text )
	"
	if a:text == ''
		return
	endif
	"
	aboveleft new
	put! = a:text
	set syntax=vim
	set nomodified
	normal! gg
endfunction    " ----------  end of function s:VimrcCodeSnippet  ----------
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
	let list_args    = []
	"
	call add ( list_display, len( list_display ).': personalization file (for your name, mail, ...), shared across plug-ins' )
	call add ( list_wizards, 's:SetupPersonal' )
	call add ( list_args,    [] )
	call add ( list_display, len( list_display ).': customization file (for custom templates)' )
	call add ( list_wizards, 's:SetupCustom' )
	call add ( list_args,    [ 'without_person' ] )
	call add ( list_display, len( list_display ).': customization file with personalization, combines the above two' )
	call add ( list_wizards, 's:SetupCustom' )
	call add ( list_args,    [ 'with_person' ] )
	"
	call add ( list_display, len( list_display ).': -abort-' )
	"
	let d_idx = inputlist ( list_display )
	let use_wizard = get ( list_wizards, d_idx-1, '' )
	let use_args   = get ( list_args,    d_idx-1, [] )
	echo "\n"
	"
	if d_idx >= 1 && use_wizard != ''
		call call ( use_wizard, [ t_lib ] + use_args )
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
			" :TODO:12.02.2015 19:08:WM: search for duplicates
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
	if personal_file != '' && ! filereadable ( personal_file )
		try
			call mkdir ( fnamemodify ( personal_file, ':h' ), 'p' )
		catch /.*/   " fail quietly, the directory may already exist
		endtry
		try
			let sample_file = mmtemplates#core#Resource ( t_lib, 'get', 'property', 'Templates::Wizard::FilePersonal' )[0]
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
		let help_topic_missing = 0
		try
			help g:Templates_PersonalizationFile
		catch /.*/   " failed, print some more help below
			let help_topic_missing = 1
		endtry
		redraw
		echo "Failed to create the personalization file:"
					\ ."\n    ".personal_file
					\ ."\nFor configuring the file manually, see:"
					\ ."\n    :help g:Templates_PersonalizationFile"
		if help_topic_missing
			echo "... but redo your helptags first:"
						\ ."\n    :helptags .../doc"
		endif
	else
		call mmtemplates#core#EnableTemplateFile ( t_lib, 'personal' )
		"
		" automatic setup succeeded, start editing
		let plugin_name   = mmtemplates#core#Resource ( t_lib, 'get', 'property', 'Templates::Wizard::PluginName' )[0]
		let filetype_name = mmtemplates#core#Resource ( t_lib, 'get', 'property', 'Templates::Wizard::FiletypeName' )[0]
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
"
"-------------------------------------------------------------------------------
" s:SetupCustom : Setup customization template file.   {{{1
"
" Parameters:
"   library - the template library (dict)
"   mode    - the mode "without_person" or "without_person"
" Returns:
"   success - whether the customization template file was created successfully
"-------------------------------------------------------------------------------
function! s:SetupCustom ( library, mode )
	"
	let t_lib = a:library
	"
	let plugin_name = mmtemplates#core#Resource ( t_lib, 'get', 'property', 'Templates::Wizard::PluginName' )[0]
	"
	" ==================================================
	"  do the job
	" ==================================================
	"
	let settings = mmtemplates#core#Resource ( a:library, 'settings_table' )[0]
	let [ custom_file_info, file_error ] = mmtemplates#core#Resource ( t_lib, 'get', 'template_file', 'custom' )
	"
	if file_error != ''
		echomsg 'Internal error (setup wizard):'
		echomsg '  '.file_error
		return
	endif
	"
	echo "\nThe template customization file will be read by the ".plugin_name." template"
				\ ."\nlibrary after the stock templates. The settings made there will overwrite the"
				\ ."\ndefault ones and the templates defined there will be added to the stock"
				\ ."\ntemplates. If a template is defined again with the same name, it overwrites the"
				\ ."\nprevious version."
	"
	" does the customization file already exist?
	let custom_file = ''
	let vimrc_hint  = ''
	"
	if custom_file_info.available
		echo "\nThe template customization file already exists:"
					\ ."\n    ".custom_file_info.filename
		let custom_file = custom_file_info.filename
	else
		echo "\nThe customization file will be stored here by default:"
					\ ."\n    ".custom_file_info.filename
	endif
	"
	call s:HitEnter ()
	"
	" file not available?
	if ! custom_file_info.available
		"
		" select a different location for the file?
		if 1 == s:Question ( 'Choose a different location?' )
			"
			" how to get the filename
			let method = settings.Templates_TemplateBrowser
			"
			if method == 'browse' && ! has ( 'browse' ) || method == 'explore'
				let method = 'edit'
			endif
			"
			" get the filename
			if method == 'browse'
				let custom_file = s:GetFileFromBrowser ( 1,
							\ 'choose a custom template file',
							\ expand('$HOME/'),
							\ fnamemodify ( custom_file_info.filename, ':t' ) )
			else
				" is empty in case of no input
				let custom_file = s:UserInput ( 'Choose a file: ', expand('$HOME/'), 'file' )
			endif
			"
			" hint about changes in .vimrc
			if custom_file != ''
				let varname = mmtemplates#core#Resource ( t_lib, 'get', 'property', 'Templates::Wizard::CustomFileVariable' )[0]
				let vimrc_hint =
							\  "\" to always load the custom template file from that location,\n"
							\ ."\" add this line to your vimrc (".$MYVIMRC."):\n"
							\ ."let ".varname." = '".substitute( custom_file, "'", "''", 'g' )."'"
			endif
		else
			" use default instead
			let custom_file = custom_file_info.filename
		endif
		"
	endif
	"
	" create the file if necessary
	if custom_file != '' && ! filereadable ( custom_file )
		try
			call mkdir ( fnamemodify ( custom_file, ':h' ), 'p' )
		catch /.*/   " fail quietly, the directory may already exist
		endtry
		try
			if a:mode == 'without_person'
				let sample_file = mmtemplates#core#Resource ( t_lib, 'get', 'property', 'Templates::Wizard::FileCustomNoPersonal' )[0]
			else
				let sample_file = mmtemplates#core#Resource ( t_lib, 'get', 'property', 'Templates::Wizard::FileCustomWithPersonal' )[0]
			endif
			call writefile ( readfile ( sample_file ), custom_file )
		catch /.*/   " fail quietly, we check for the file later on
		endtry
	endif
	"
	" check the success
	if custom_file == ''
		" no file chosen
		echo "\nNo customization file chosen."
					\ ."\nFor configuring the file manually, see the help of the plug-in."
	elseif ! filereadable ( custom_file )
		" automatic setup failed
		echo "\nFailed to create the customization file:"
					\ ."\n    ".custom_file
					\ ."\nFor configuring the file manually, see the help of the plug-in."
	else
		call s:VimrcCodeSnippet ( vimrc_hint )
		"
		call mmtemplates#core#EnableTemplateFile ( t_lib, 'custom', custom_file )
		"
		" automatic setup succeeded, start editing
		let filetype_name = mmtemplates#core#Resource ( t_lib, 'get', 'property', 'Templates::Wizard::FiletypeName' )[0]
		let maplead       = mmtemplates#core#Resource ( t_lib, 'get', 'property', 'Templates::Mapleader' )[0]
		let reload_map    = mmtemplates#core#Resource ( t_lib, 'get', 'property', 'Templates::RereadTemplates::Map' )[0]
		"
		exe 'split '.fnameescape( custom_file )
		redraw
		echo "Customize the file and then reload the template library:"
					\ ."\n- use the menu entry \"".plugin_name." -> Snippets -> reread templates\""
					\ ."\n- use the map \"".maplead.reload_map."\" inside a ".filetype_name." buffer"
		if vimrc_hint != ''
			echo "\nTo always load the new file, update your vimrc."
		endif
		"
		return 1
	endif
	"
	return 0
endfunction    " ----------  end of function s:SetupCustom  ----------
" }}}1
"-------------------------------------------------------------------------------
"
"-------------------------------------------------------------------------------
"  vim: foldmethod=marker
