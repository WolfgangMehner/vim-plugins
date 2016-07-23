"===============================================================================
"
"          File:  git-support.vim
" 
"   Description:  Provides access to Git's functionality from inside Vim.
" 
"                 See help file gitsupport.txt .
"
"   VIM Version:  7.0+
"        Author:  Wolfgang Mehner, wolfgang-mehner@web.de
"  Organization:  
"       Version:  see variable g:GitSupport_Version below
"       Created:  06.10.2012
"      Revision:  18.07.2015
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
" Basic checks.   {{{1
"-------------------------------------------------------------------------------
"
" need at least 7.0
if v:version < 700
	echohl WarningMsg
	echo 'The plugin git-support.vim needs Vim version >= 7.'
	echohl None
	finish
endif
"
" prevent duplicate loading
" need compatible
if &cp || ( exists('g:GitSupport_Version') && ! exists('g:GitSupport_DevelopmentOverwrite') )
	finish
endif
let g:GitSupport_Version= '0.9.3'     " version number of this script; do not change
"
"-------------------------------------------------------------------------------
" Auxiliary functions.   {{{1
"-------------------------------------------------------------------------------
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
		exe 'let g:'.a:varname.' = '.string( a:value )
	endif
endfunction    " ----------  end of function s:ApplyDefaultSetting  ----------
"
"-------------------------------------------------------------------------------
" s:AssembleCmdLine : Assembles a cmd-line with the cursor in the right place.   {{{2
"
" Parameters:
"   part1 - part left of the cursor (string)
"   part2 - part right of the cursor (string)
"   left  - used to move the cursor left (string, optional)
" Returns:
"   cmd_line - the command line (string)
"-------------------------------------------------------------------------------
"
function! s:AssembleCmdLine ( part1, part2, ... )
	if a:0 == 0 || a:1 == ''
		let left = "\<Left>"
	else
		let left = a:1
	endif
	return a:part1.a:part2.repeat( left, s:UnicodeLen( a:part2 ) )
endfunction    " ----------  end of function s:AssembleCmdLine  ----------
"
"-------------------------------------------------------------------------------
" s:ChangeCWD : Check the buffer and the CWD.   {{{2
"
" Parameters:
"   [ bufnr, dir ] - data (list: integer and string, optional)
" Returns:
"   -
"
" Example:
" First check the current working directory:
"   let data = s:CheckCWD ()
" then jump to the Git buffer:
"   call s:OpenGitBuffer ( 'Git - <name>' )
" then call this function to correctly set the directory of the buffer:
"   call s:ChangeCWD ( data )
"
" Usage:
" The function s:CheckCWD queries the working directory of the buffer your
" starting out in, which is the buffer where you called the Git command. The
" call to s:OpenGitBuffer then opens the requested buffer or jumps to it if it
" already exists. Finally, s:ChangeCWD sets the working directory of the Git
" buffer.
" The buffer 'data' is a list, containing first the number of the current buffer
" at the time s:CheckCWD was called, and second the name of the directory.
"
" When called without parameters, changes to the directory stored in
" 'b:GitSupport_CWD'.
"-------------------------------------------------------------------------------
"
function! s:ChangeCWD ( ... )
	"
	" call originated from outside the Git buffer?
	" also the case for a new buffer
	if a:0 == 0
		if ! exists ( 'b:GitSupport_CWD' )
			call s:ErrorMsg ( 'Not inside a Git buffer.' )
			return
		endif
	elseif bufnr('%') != a:1[0]
		"echomsg '2 - call from outside: '.a:1[0]
		let b:GitSupport_CWD = a:1[1]
	else
		"echomsg '2 - call from inside: '.bufnr('%')
		" noop
	endif
	"
	" change buffer
	"echomsg '3 - changing to: '.b:GitSupport_CWD
	exe	'lchdir '.fnameescape( b:GitSupport_CWD )
endfunction    " ----------  end of function s:ChangeCWD  ----------
"
"-------------------------------------------------------------------------------
" s:CheckCWD : Check the buffer and the CWD.   {{{2
"
" Parameters:
"   -
" Returns:
"   [ bufnr, dir ] - data (list: integer and string)
"
" Usage: see s:ChangeCWD
"-------------------------------------------------------------------------------
"
function! s:CheckCWD ()
	"echomsg '1 - calling from: '.getcwd()
	return [ bufnr('%'), getcwd() ]
endfunction    " ----------  end of function s:CheckCWD  ----------
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
" s:EscapeCurrent : Escape the name of the current file for the shell,   {{{2
"     and prefix it with "--".
"
" Parameters:
"   -
" Returns:
"   file_argument - the escaped filename (string)
"-------------------------------------------------------------------------------
"
function! s:EscapeCurrent ()
	return '-- '.shellescape ( expand ( '%' ) )
endfunction    " ----------  end of function s:EscapeCurrent  ----------
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
" s:GitCmdLineArgs : Split command-line parameters into a list.   {{{2
"
" Parameters:
"   args - the arguments in one string (string)
" Returns:
"   [ <arg1>, <arg2>, ... ] - the split arguments (list of strings)
"
" In case of an error, a list with one empty string is returned:
"   [ '' ]
"-------------------------------------------------------------------------------
"
function! s:GitCmdLineArgs ( args )
	"
	let [ sh_err, text ] = s:StandardRun ( 'rev-parse', '-- '.a:args, 't' )
	"
	if sh_err == 0
		return split ( text, '\n' )
	else
		call s:ErrorMsg ( "Can not parse the command line arguments:\n\n".text )
		return [ '' ]
	endif
	"
endfunction    " ----------  end of function s:GitCmdLineArgs  ----------
"
"-------------------------------------------------------------------------------
" s:GitGetConfig : Get an option.   {{{2
"
" Parameters:
"   option - name of the option (string)
"   source - where to get the option from (string, optional)
" Returns:
"   value - the value of the option (string)
"
" The possible sources are:
"   'local'  - current repository
"   'global' - global settings
"   'system' - system settings
"-------------------------------------------------------------------------------
"
function! s:GitGetConfig ( option, ... )
	"
	let args = ''
	"
	if a:0 > 0
		if a:1 == ''
			" noop
		elseif a:1 == 'local'
			" noop
		elseif a:1 == 'global'
			let args = '--global '
		elseif a:1 == 'system'
			let args = '--system '
		else
			call s:ErrorMsg ( "Unknown option: ".a:1 )
			return ''
		endif
	endif
	"
	let args .= '--get '.a:option
	"
	let [ sh_err, text ] = s:StandardRun ( 'config', args, 't' )
	"
	" from the help:
	"   the section or key is invalid (ret=1)
	if sh_err == 1 || text == ''
		if has_key ( s:Config_DefaultValues, a:option )
			return s:Config_DefaultValues[ a:option ]
		else
			return ''
		endif
	elseif sh_err == 0
		return text
	else
		call s:ErrorMsg ( "Can not query the option: ".text )
		return ''
	endif
	"
endfunction    " ----------  end of function s:GitGetConfig  ----------
"
"-------------------------------------------------------------------------------
" s:GitRepoDir : Get the base directory of a repository.   {{{2
"
" Parameters:
"   file - get another path than the top-level directory (string, optional)
" Returns:
"   path - the name of the base directory (string)
"
" The possible options for 'file' are:
"   'top'        - the top-level directory (default)
"   'top/<file>  - a file in the top-level directory <top-level>/<file>
"   'git/<file>' - a file in the git directory <top-level>/.git/<file>,
"                    respects $GIT_DIR
"-------------------------------------------------------------------------------
"
function! s:GitRepoDir ( ... )
	"
	let get_cmd = 'rev-parse'
	let get_arg = '--show-toplevel'
	let postfix = ''
	"
	let dir = 'top'
	"
	if a:0 == 0 || a:1 == '' || a:1 == 'top'
		let [ sh_err, text ] = s:StandardRun ( 'rev-parse', '--show-toplevel', 't' )
	elseif a:1 =~ '^top/'
		let dir = a:1
		let [ sh_err, text ] = s:StandardRun ( 'rev-parse', '--show-toplevel', 't' )
		"
		if sh_err == 0
			let text = substitute ( a:1, 'top', escape( text, '\&' ), '' )
		endif
	elseif a:1 =~ '^git/'
		let dir = a:1
		let [ sh_err, text ] = s:StandardRun ( 'rev-parse', '--git-dir', 't' )
		"
		if sh_err == 0
			let text = substitute ( a:1, 'git', escape( text, '\&' ), '' )
		endif
	else
		call s:ErrorMsg ( "Unknown option: ".a:1 )
		return ''
	endif
	"
	if sh_err == 0
		return fnamemodify ( text, ':p' )
	else
		call s:ErrorMsg ( "Can not query the directory \"".dir."\":","",text )
		return ''
	endif
	"
endfunction    " ----------  end of function s:GitRepoDir  ----------
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
"
function! s:ImportantMsg ( ... )
	echohl Search
	echo join ( a:000, "\n" )
	echohl None
endfunction    " ----------  end of function s:ImportantMsg  ----------
"
"-------------------------------------------------------------------------------
" s:OpenFile : Open a file or jump to its window.   {{{2
"
" Parameters:
"   filename - the name of the file (string)
"   line     - line number (integer, optional)
"   column   - column version number (integer, optional)
" Returns:
"   -
"
" If the file is already open, jump to its window. Otherwise open a window
" showing the file. If the line number is given, jump to this line in the
" buffer. If the column number is given, jump to the column.
"-------------------------------------------------------------------------------
"
function! s:OpenFile ( filename, ... )
	"
	let filename = resolve ( fnamemodify ( a:filename, ':p' ) )
	"
	if bufwinnr ( '^'.filename.'$' ) == -1
		" open buffer
		belowright new
		exe "edit ".fnameescape( filename )
	else
		" jump to window
		exe bufwinnr( '^'.filename.'$' ).'wincmd w'
	endif
	"
	if a:0 >= 1
		" jump to line
		let pos = getpos( '.' )
		let pos[1] = a:1   " line
		if a:0 >= 2
			let pos[2] = a:2   " col
		endif
		call setpos( '.', pos )
	endif
	"
	if foldlevel('.') && g:Git_OpenFoldAfterJump == 'yes'
		normal! zv
	endif
endfunction    " ----------  end of function s:OpenFile  ----------
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
"
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
" s:StandardRun : execute 'git <cmd> ...'   {{{2
"
" Parameters:
"   cmd     - the Git command to run (string), this is not the Git executable!
"   param   - the parameters (string)
"   flags   - all set flags (string)
"   allowed - all allowed flags (string, default: 'cet')
" Returns:
"   [ ret, text ] - the status code and text produced by the command (string),
"                   only if the flag 't' is set
"
" Flags are characters. The parameter 'flags' is a concatenation of all set
" flags, the parameter 'allowed' is a concatenation of all allowed flags.
"
" Flags:
"   c - ask for confirmation
"   e - expand empty 'param' to current buffer
"   t - return the text instead of echoing it
"-------------------------------------------------------------------------------
"
function! s:StandardRun( cmd, param, flags, ... )
	"
	if a:0 == 0
		let flag_check = '[^cet]'
	else
		let flag_check = '[^'.a:1.']'
	endif
	"
	if a:flags =~ flag_check
		return s:ErrorMsg ( 'Unknown flag "'.matchstr( a:flags, flag_check ).'".' )
	endif
	"
	if a:flags =~ 'e' && empty( a:param ) | let param = s:EscapeCurrent()
	else                                  | let param = a:param
	endif
	"
	let cmd = s:Git_Executable.' '.a:cmd.' '.param
	"
	if a:flags =~ 'c' && s:Question ( 'Execute "git '.a:cmd.' '.param.'"?' ) != 1
		echo "aborted"
		return
	endif
	"
	let text = system ( cmd )
	"
	if a:flags =~ 't'
		return [ v:shell_error, substitute ( text, '\_s*$', '', '' ) ]
	elseif v:shell_error != 0
		echo "\"".cmd."\" failed:\n\n".text           | " failure
	elseif text =~ '^\_s*$'
		echo "ran successfully"                       | " success
	else
		echo "ran successfully:\n".text               | " success
	endif
	"
endfunction    " ----------  end of function s:StandardRun  ----------
"
"-------------------------------------------------------------------------------
" s:UnicodeLen : Number of characters in a Unicode string.   {{{2
"
" Parameters:
"   str - a string (string)
" Returns:
"   len - the length (integer)
"
" Returns the correct length in the presence of Unicode characters which take
" up more than one byte.
"-------------------------------------------------------------------------------
"
function! s:UnicodeLen ( str )
	return len(split(a:str,'.\zs'))
endfunction    " ----------  end of function s:UnicodeLen  ----------
"
"-------------------------------------------------------------------------------
" s:VersionLess : Compare two version numbers.   {{{2
"
" Parameters:
"   v1 - 1st version number (string)
"   v2 - 2nd version number (string)
" Returns:
"   less - true, if v1 < v2 (string)
"-------------------------------------------------------------------------------
"
function! s:VersionLess ( v1, v2 )
	"
	let l1 = matchlist( a:v1, '^\(\d\+\)\.\(\d\+\)\%(\.\(\d\+\)\)\?\%(\.\(\d\+\)\)\?' )
	let l2 = matchlist( a:v2, '^\(\d\+\)\.\(\d\+\)\%(\.\(\d\+\)\)\?\%(\.\(\d\+\)\)\?' )
	"
	if empty( l1 ) || empty( l2 )
		echoerr 'Can not compare version numbers "'.a:v1.'" and "'.a:v2.'".'
		return
	endif
	"
	for i in range( 1, 4 )
		" all previous numbers have been identical!
		if empty(l2[i])
			" l1[i] is empty as well or "0"  -> versions are the same
			" l1[i] is not empty             -> v1 can not be less
			return 0
		elseif empty(l1[i])
			" only l1[i] is empty -> v2 must be larger, unless l2[i] is "0"
			return l2[i] != 0
		elseif str2nr(l1[i]) != str2nr( l2[i] )
			return str2nr(l1[i]) < str2nr( l2[i] )
		endif
	endfor
	"
	echoerr 'Something went wrong while comparing "'.a:v1.'" and "'.a:v2.'".'
	return -1
endfunction    " ----------  end of function s:VersionLess  ----------
" }}}2
"-------------------------------------------------------------------------------
"
"-------------------------------------------------------------------------------
" Custom menus.   {{{1
"-------------------------------------------------------------------------------
"
"-------------------------------------------------------------------------------
" s:GenerateCustomMenu : Generate custom menu entries.   {{{2
"
" Parameters:
"   prefix - defines the menu the entries will be placed in (string)
"   data   - custom menu entries (list of lists of strings)
" Returns:
"   -
"
" See :help g:Git_CustomMenu for a description of the format 'data' uses.
"-------------------------------------------------------------------------------
"
function! s:GenerateCustomMenu ( prefix, data )
	"
	for [ entry_l, entry_r, cmd ] in a:data
		" escape special characters and assemble entry
		let entry_l = escape ( entry_l, ' |\' )
		let entry_l = substitute ( entry_l, '\.\.', '\\.', 'g' )
		let entry_r = escape ( entry_r, ' .|\' )
		"
		if entry_r == '' | let entry = a:prefix.'.'.entry_l
		else             | let entry = a:prefix.'.'.entry_l.'<TAB>'.entry_r
		endif
		"
		if cmd == ''
			let cmd = ':'
		endif
		"
		let silent = '<silent> '
		"
		" prepare command
		if cmd =~ '<CURSOR>'
			let mlist = matchlist ( cmd, '^\(.\+\)<CURSOR>\(.\{-}\)$' )
			let cmd = s:AssembleCmdLine ( mlist[1], mlist[2], '<Left>' )
			let silent = ''
		elseif cmd =~ '<EXECUTE>$'
			let cmd = substitute ( cmd, '<EXECUTE>$', '<CR>', '' )
		endif
		"
		let cmd = substitute ( cmd, '<WORD>',   '<cword>', 'g' )
		let cmd = substitute ( cmd, '<FILE>',   '<cfile>', 'g' )
		let cmd = substitute ( cmd, '<BUFFER>', '%',       'g' )
		"
		exe 'anoremenu '.silent.entry.'      '.cmd
		exe 'vnoremenu '.silent.entry.' <C-C>'.cmd
	endfor
	"
endfunction    " ----------  end of function s:GenerateCustomMenu  ----------
" }}}2
"-------------------------------------------------------------------------------
"
"-------------------------------------------------------------------------------
" Modul setup.   {{{1
"-------------------------------------------------------------------------------
"
"-------------------------------------------------------------------------------
" command lists, help topics   {{{2
"
let s:GitCommands = [
			\ 'add',               'add--interactive',         'am',                'annotate',           'apply',
			\ 'archive',           'bisect',                   'bisect--helper',    'blame',              'branch',
			\ 'bundle',            'cat-file',                 'check-attr',        'checkout',           'checkout-index',
			\ 'check-ref-format',  'cherry',                   'cherry-pick',       'citool',             'clean',
			\ 'clone',             'commit',                   'commit-tree',       'config',             'count-objects',
			\ 'credential-cache',  'credential-cache--daemon', 'credential-store',  'daemon',             'describe',
			\ 'diff',              'diff-files',               'diff-index',        'difftool',           'difftool--helper',
			\ 'diff-tree',         'fast-export',              'fast-import',       'fetch',              'fetch-pack',
			\ 'filter-branch',     'fmt-merge-msg',            'for-each-ref',      'format-patch',       'fsck',
			\ 'fsck-objects',      'gc',                       'get-tar-commit-id', 'grep',               'gui',
			\ 'gui--askpass',      'hash-object',              'help',              'http-backend',       'http-fetch',
			\ 'http-push',         'imap-send',                'index-pack',        'init',               'init-db',
			\ 'instaweb',          'log',                      'lost-found',        'ls-files',           'ls-remote',
			\ 'ls-tree',           'mailinfo',                 'mailsplit',         'merge',              'merge-base',
			\ 'merge-file',        'merge-index',              'merge-octopus',     'merge-one-file',     'merge-ours',
			\ 'merge-recursive',   'merge-resolve',            'merge-subtree',     'mergetool',          'merge-tree',
			\ 'mktag',             'mktree',                   'mv',                'name-rev',           'notes',
			\ 'pack-objects',      'pack-redundant',           'pack-refs',         'patch-id',           'peek-remote',
			\ 'prune',             'prune-packed',             'pull',              'push',               'quiltimport',
			\ 'read-tree',         'rebase',                   'receive-pack',      'reflog',             'relink',
			\ 'remote',            'remote-ext',               'remote-fd',         'remote-ftp',         'remote-ftps',
			\ 'remote-http',       'remote-https',             'remote-testgit',    'repack',             'replace',
			\ 'repo-config',       'request-pull',             'rerere',            'reset',              'revert',
			\ 'rev-list',          'rev-parse',                'rm',                'send-pack',          'shell',
			\ 'sh-i18n--envsubst', 'shortlog',                 'show',              'show-branch',        'show-index',
			\ 'show-ref',          'stage',                    'stash',             'status',             'stripspace',
			\ 'submodule',         'symbolic-ref',             'tag',               'tar-tree',           'unpack-file',
			\ 'unpack-objects',    'update-index',             'update-ref',        'update-server-info', 'upload-archive',
			\ 'upload-pack',       'var',                      'verify-pack',       'verify-tag',         'web--browse',
			\ 'whatchanged',       'write-tree',
			\ ]
"
let s:HelpTopics = s:GitCommands + [
			\ 'attributes', 'cli',               'core-tutorial', 'cvs-migration', 'diffcore',
			\ 'gitk',       'glossary',          'hooks',         'ignore',        'modules',
			\ 'namespaces', 'repository-layout', 'tutorial',      'tutorial-2',    'workflows'
			\ ]
"
function! GitS_HelpTopicsComplete ( ArgLead, CmdLine, CursorPos )
	return filter( copy( s:HelpTopics ), 'v:val =~ "\\V\\<'.escape(a:ArgLead,'\').'\\w\\*"' )
endfunction    " ----------  end of function GitS_HelpTopicsComplete  ----------
"
"----------------------------------------------------------------------
" list of file IDs for :GitEdit   {{{2
"
let s:EditFileIDs = [
			\ 'config-global', 'config-local',
			\ 'description',
			\ 'hooks',
			\ 'ignore-global', 'ignore-local', 'ignore-private',
			\ 'modules',
			\ ]
"
function! GitS_EditFilesComplete ( ArgLead, CmdLine, CursorPos )
	return filter( copy( s:EditFileIDs ), 'v:val =~ "\\V\\<'.escape(a:ArgLead,'\').'\\w\\*"' )
endfunction    " ----------  end of function GitS_EditFilesComplete  ----------
"
" configuration defaults   {{{2
" - only defaults which are relevant for Git-Support are listed here
"
let s:Config_DefaultValues = {
			\ 'help.format'          : 'man',
			\ 'status.relativePaths' : 'true'
			\ }
"
" platform specifics   {{{2
"
let s:MSWIN = has("win16") || has("win32")   || has("win64")     || has("win95")
let s:UNIX	= has("unix")  || has("macunix") || has("win32unix")
"
if s:MSWIN
	"
	"-------------------------------------------------------------------------------
	" MS Windows
	"-------------------------------------------------------------------------------
	"
	if match(      substitute( expand('<sfile>'), '\\', '/', 'g' ),
				\   '\V'.substitute( expand('$HOME'),   '\\', '/', 'g' ) ) == 0
		" user installation assumed
		let s:installation = 'local'
	else
		" system wide installation
		let s:installation = 'system'
	endif
	"
	let s:plugin_dir = substitute( expand('<sfile>:p:h:h'), '\\', '/', 'g' )
	"
else
	"
	"-------------------------------------------------------------------------------
	" Linux/Unix
	"-------------------------------------------------------------------------------
	"
	if match( expand('<sfile>'), '\V'.resolve(expand('$HOME')) ) == 0
		" user installation assumed
		let s:installation = 'local'
	else
		" system wide installation
		let s:installation = 'system'
	endif
	"
	let s:plugin_dir = expand('<sfile>:p:h:h')
	"
endif
"
" settings   {{{2
"
let s:Git_LoadMenus      = 'yes'    " load the menus?
let s:Git_RootMenu       = '&Git'   " name of the root menu
"
let s:Git_CmdLineOptionsFile = s:plugin_dir.'/git-support/data/options.txt'
"
if ! exists ( 's:MenuVisible' )
	let s:MenuVisible = 0           " menus are not visible at the moment
endif
"
let s:Git_CustomMenu = [
			\ [ '&grep, word under cursor',  ':GitGrepTop', ':GitGrepTop <WORD><EXECUTE>' ],
			\ [ '&grep, version x..y',       ':GitGrepTop', ':GitGrepTop -i "Version[^[:digit:]]\+<CURSOR>"' ],
			\ [ '-SEP1-',                    '',            '' ],
			\ [ '&log, grep commit msg..',   ':GitLog',     ':GitLog -i --grep="<CURSOR>"' ],
			\ [ '&log, grep diff word',      ':GitLog',     ':GitLog -p -S "<CURSOR>"' ],
			\ [ '&log, grep diff line',      ':GitLog',     ':GitLog -p -G "<CURSOR>"' ],
			\ [ '-SEP2-',                    '',            '' ],
			\ [ '&merge, fast-forward only', ':GitMerge',   ':GitMerge --ff-only <CURSOR>' ],
			\ [ '&merge, no commit',         ':GitMerge',   ':GitMerge --no-commit <CURSOR>' ],
			\ [ '&merge, abort',             ':GitMerge',   ':GitMerge --abort<EXECUTE>' ],
			\ ]
"
if s:MSWIN
	let s:Git_BinPath = 'C:\Program Files\Git\bin\'
else
	let s:Git_BinPath = ''
endif
"
call s:GetGlobalSetting ( 'Git_BinPath' )
"
if s:MSWIN
	let s:Git_BinPath = substitute ( s:Git_BinPath, '[^\\/]$', '&\\', '' )
	"
	let s:Git_Executable     = s:Git_BinPath.'git.exe'     " Git executable
	let s:Git_GitKExecutable = s:Git_BinPath.'tclsh.exe'   " GitK executable
	let s:Git_GitKScript     = s:Git_BinPath.'gitk'        " GitK script
else
	let s:Git_BinPath = substitute ( s:Git_BinPath, '[^\\/]$', '&/', '' )
	"
	let s:Git_Executable     = s:Git_BinPath.'git'         " Git executable
	let s:Git_GitKExecutable = s:Git_BinPath.'gitk'        " GitK executable
	let s:Git_GitKScript     = ''                          " GitK script (do not specify separate script by default)
endif
"
call s:GetGlobalSetting ( 'Git_Executable' )
call s:GetGlobalSetting ( 'Git_GitKExecutable' )
call s:GetGlobalSetting ( 'Git_GitKScript' )
call s:GetGlobalSetting ( 'Git_LoadMenus' )
call s:GetGlobalSetting ( 'Git_RootMenu' )
call s:GetGlobalSetting ( 'Git_CustomMenu' )
"
call s:ApplyDefaultSetting ( 'Git_CheckoutExpandEmpty',  'no' )
call s:ApplyDefaultSetting ( 'Git_DiffExpandEmpty',      'no' )
call s:ApplyDefaultSetting ( 'Git_ResetExpandEmpty',     'no' )
call s:ApplyDefaultSetting ( 'Git_OpenFoldAfterJump',    'yes' )
call s:ApplyDefaultSetting ( 'Git_StatusStagedOpenDiff', 'cached' )
call s:ApplyDefaultSetting ( 'Git_Editor',               '' )

let s:Enabled         = 1           " Git enabled?
let s:DisabledMessage = "Git-Support not working:"
let s:DisabledReason  = ""
"
let s:EnabledGitK        = 1        " gitk enabled?
let s:DisableGitKMessage = "gitk not avaiable:"
let s:DisableGitKReason  = ""
"
let s:EnabledGitBash        = 1     " git bash enabled?
let s:DisableGitBashMessage = "git bash not avaiable:"
let s:DisableGitBashReason  = ""
"
let s:FoundGitKScript  = 1
let s:GitKScriptReason = ""
"
let s:GitVersion    = ""            " Git Version
let s:GitHelpFormat = ""            " 'man' or 'html'
"
" git bash
if s:MSWIN
	let s:Git_GitBashExecutable = s:Git_BinPath.'sh.exe'
	call s:GetGlobalSetting ( 'Git_GitBashExecutable' )
else
	if exists ( 'g:Xterm_Executable' )
		let s:Git_GitBashExecutable = g:Xterm_Executable
	else
		let s:Git_GitBashExecutable = 'xterm'
	endif
	call s:GetGlobalSetting ( 'Git_GitBashExecutable' )
	call s:ApplyDefaultSetting ( 'Xterm_Options', '-fa courier -fs 12 -geometry 80x24' )
endif
"
" check git executable   {{{2
"
function! s:CheckExecutable ( name, exe )
	"
	let executable = a:exe
	let enabled = 1
	let reason  = ""
	"
	if executable =~ '^LANG=\w\+\s.'
		let [ lang, executable ] = matchlist ( executable, '^\(LANG=\w\+\)\s\+\(.\+\)$' )[1:2]
		if ! executable ( executable )
			let enabled = 0
			let reason = a:name." not executable: ".executable
		endif
		let executable = lang.' '.shellescape( executable )
	elseif executable =~ '^\(["'']\)\zs.\+\ze\1'
		if ! executable ( matchstr ( executable, '^\(["'']\)\zs.\+\ze\1' ) )
			let enabled = 0
			let reason = a:name." not executable: ".executable
		endif
	else
		if ! executable ( executable )
			let enabled = 0
			let reason = a:name." not executable: ".executable
		endif
		let executable = shellescape( executable )
	endif
	"
	return [ executable, enabled, reason ]
endfunction    " ----------  end of function s:CheckExecutable  ----------
"
function! s:CheckFile ( shortname, filename, esc )
	"
	let filename = a:filename
	let found    = 1
	let message  = ""
	"
	if ! filereadable ( filename )
		let found = 0
		let message = a:shortname." not found: ".filename
	endif
	let filename = shellescape( filename )
	"
	return [ filename, found, message ]
endfunction    " ----------  end of function s:CheckFile  ----------
"
let [ s:Git_Executable,     s:Enabled,     s:DisabledReason    ] = s:CheckExecutable( 'git',  s:Git_Executable )
let [ s:Git_GitKExecutable, s:EnabledGitK, s:DisableGitKReason ] = s:CheckExecutable( 'gitk', s:Git_GitKExecutable )
if ! empty ( s:Git_GitKScript )
	let [ s:Git_GitKScript, s:FoundGitKScript, s:GitKScriptReason ] = s:CheckFile( 'gitk script', s:Git_GitKScript, 1 )
endif
let [ s:Git_GitBashExecutable, s:EnabledGitBash, s:DisableGitBashReason ] = s:CheckExecutable ( 'git bash', s:Git_GitBashExecutable )
"
" check Git version   {{{2
"
" added in 1.7.2:
" - "git status --ignored"
" - "git status -s -b"
let s:HasStatusIgnore = 0
let s:HasStatusBranch = 0
"
" changed in 1.8.5:
" - output of "git status" without leading "#" char.
let s:HasStatus185Format = 0
"
if s:Enabled
	let s:GitVersion = s:StandardRun( '', ' --version', 't' )[1]
	if s:GitVersion =~ 'git version [0-9.]\+'
		let s:GitVersion = matchstr( s:GitVersion, 'git version \zs[0-9.]\+' )
		"
		if ! s:VersionLess ( s:GitVersion, '1.7.2' )
			let s:HasStatusIgnore = 1
			let s:HasStatusBranch = 1
		endif
		"
		if ! s:VersionLess ( s:GitVersion, '1.8.5' )
			let s:HasStatus185Format = 1
		endif
		"
	else
		call s:ErrorMsg ( 'Can not obtain the version number of Git.' )
	endif
endif
"
" check Git help.format   {{{2
"
if s:Enabled
	let s:GitHelpFormat = s:GitGetConfig( 'help.format' )
	"
	if s:GitHelpFormat == 'web'
		let s:GitHelpFormat = 'html'
	endif
endif
"
" standard help text   {{{2
"
let s:HelpTxtStd  = "S-F1    : help\n"
let s:HelpTxtStd .= "q       : close\n"
let s:HelpTxtStd .= "u       : update"
"
let s:HelpTxtStdNoUpdate  = "S-F1    : help\n"
let s:HelpTxtStdNoUpdate .= "q       : close"
"
" custom commands   {{{2
"
if s:Enabled
"	command! -nargs=* -complete=file                                 GitAbove           :call GitS_Split('above',<count>,<q-args>)
"	command! -nargs=* -complete=file                                 GitBelow           :call GitS_Split('below',<count>,<q-args>)
"	command! -nargs=* -complete=file -count=1000                     GitTab             :call GitS_Split('tab',<count>,<q-args>)
	command! -nargs=* -complete=file -bang                           GitAdd             :call GitS_Add(<q-args>,'<bang>'=='!'?'ef':'e')
	command! -nargs=* -complete=file -range=0                        GitBlame           :call GitS_Blame('update',<q-args>,<line1>,<line2>)
	command! -nargs=* -complete=file                                 GitBranch          :call GitS_Branch(<q-args>,'')
	command! -nargs=* -complete=file                                 GitCheckout        :call GitS_Checkout(<q-args>,'c')
	command! -nargs=* -complete=file                                 GitCommit          :call GitS_Commit('direct',<q-args>,'')
	command! -nargs=? -complete=file                                 GitCommitFile      :call GitS_Commit('file',<q-args>,'')
	command! -nargs=0                                                GitCommitMerge     :call GitS_Commit('merge','','')
	command! -nargs=+                                                GitCommitMsg       :call GitS_Commit('msg',<q-args>,'')
	command! -nargs=* -complete=file                                 GitDiff            :call GitS_Diff('update',<q-args>)
	command! -nargs=*                                                GitFetch           :call GitS_Fetch(<q-args>,'')
	command! -nargs=+ -complete=file                                 GitGrep            :call GitS_Grep('update',<q-args>)
	command! -nargs=+ -complete=file                                 GitGrepTop         :call GitS_Grep('top',<q-args>)
	command! -nargs=* -complete=customlist,GitS_HelpTopicsComplete   GitHelp            :call GitS_Help('update',<q-args>)
	command! -nargs=* -complete=file                                 GitLog             :call GitS_Log('update',<q-args>)
	command! -nargs=*                                                GitMerge           :call GitS_Merge('direct',<q-args>,'')
	command! -nargs=*                                                GitMergeUpstream   :call GitS_Merge('upstream',<q-args>,'')
	command! -nargs=* -complete=file                                 GitMove            :call GitS_Move(<q-args>,'')
	command! -nargs=* -complete=file                                 GitMv              :call GitS_Move(<q-args>,'')
	command! -nargs=*                                                GitPull            :call GitS_Pull(<q-args>,'')
	command! -nargs=*                                                GitPush            :call GitS_Push(<q-args>,'')
	command! -nargs=* -complete=file                                 GitRemote          :call GitS_Remote(<q-args>,'')
	command! -nargs=* -complete=file                                 GitRemove          :call GitS_Remove(<q-args>,'e')
	command! -nargs=* -complete=file                                 GitRm              :call GitS_Remove(<q-args>,'e')
	command! -nargs=* -complete=file                                 GitReset           :call GitS_Reset(<q-args>,'')
	command! -nargs=* -complete=file                                 GitShow            :call GitS_Show('update',<q-args>)
	command! -nargs=*                                                GitStash           :call GitS_Stash(<q-args>,'')
	command! -nargs=*                                                GitSlist           :call GitS_Stash('list '.<q-args>,'')
	command! -nargs=? -complete=file                                 GitStatus          :call GitS_Status('update',<q-args>)
	command! -nargs=*                                                GitTag             :call GitS_Tag(<q-args>,'')
	command  -nargs=* -complete=file -bang                           Git                :call GitS_Run(<q-args>,'<bang>'=='!'?'b':'')
	command! -nargs=* -complete=file                                 GitRun             :call GitS_Run(<q-args>,'')
	command! -nargs=* -complete=file                                 GitBuf             :call GitS_Run(<q-args>,'b')
	command! -nargs=* -complete=file                                 GitK               :call GitS_GitK(<q-args>)
	command! -nargs=* -complete=file                                 GitBash            :call GitS_GitBash(<q-args>)
	command! -nargs=1 -complete=customlist,GitS_EditFilesComplete    GitEdit            :call GitS_GitEdit(<q-args>)
	command! -nargs=0                                                GitSupportHelp     :call GitS_PluginHelp("gitsupport")
	command! -nargs=?                -bang                           GitSupportSettings :call GitS_PluginSettings(('<bang>'=='!')+str2nr(<q-args>))
	"
else
	command  -nargs=*                -bang                           Git                :call GitS_Help('disabled')
	command! -nargs=*                                                GitRun             :call GitS_Help('disabled')
	command! -nargs=*                                                GitBuf             :call GitS_Help('disabled')
	command! -nargs=*                                                GitHelp            :call GitS_Help('disabled')
	command! -nargs=0                                                GitSupportHelp     :call GitS_PluginHelp("gitsupport")
	command! -nargs=?                -bang                           GitSupportSettings :call GitS_PluginSettings(('<bang>'=='!')+str2nr(<q-args>))
endif
"
" syntax highlighting   {{{2
"
highlight default link GitComment     Comment
highlight default      GitHeading     term=bold       cterm=bold       gui=bold
highlight default link GitHighlight1  Identifier
highlight default link GitHighlight2  PreProc
highlight default      GitHighlight3  term=underline  cterm=underline  gui=underline
highlight default link GitWarning     WarningMsg
highlight default link GitSevere      ErrorMsg
"
highlight default link GitAdd         DiffAdd
highlight default link GitRemove      DiffDelete
highlight default link GitConflict    DiffText
"
" }}}2
"-------------------------------------------------------------------------------
"
"-------------------------------------------------------------------------------
" s:OpenGitBuffer : Put output in a read-only buffer.   {{{1
"
" Parameters:
"   buf_name - name of the buffer (string)
" Returns:
"   opened -  true, if a new buffer was opened (integer)
"
" If a buffer called 'buf_name' already exists, jump to that buffer. Otherwise,
" open a buffer of the given name an set it up as a "temporary" buffer. It is
" deleted after the window is closed.
"
" Settings:
" - noswapfile
" - bufhidden=wipe
" - tabstop=8
" - foldmethod=syntax
"-------------------------------------------------------------------------------
"
function! s:OpenGitBuffer ( buf_name )

	" a buffer like this already opened on the current tab page?
	if bufwinnr ( a:buf_name ) != -1
		" yes -> go to the window containing the buffer
		exe bufwinnr( a:buf_name ).'wincmd w'
		return 0
	endif

	" no -> open a new window
	if s:SplitMode == '' || s:SplitMode == 'above'
		aboveleft new
	elseif s:SplitMode == 'below'
		belowright new
	elseif s:SplitMode == 'tab'
		exe s:SplitAddArg.'tabnew'
	endif

	" buffer exists elsewhere?
	if bufnr ( a:buf_name ) != -1
		" yes -> settings of the new buffer
		silent exe 'edit #'.bufnr( a:buf_name )
		return 0
	else
		" no -> settings of the new buffer
		silent exe 'file '.escape( a:buf_name, ' ' )
		setlocal noswapfile
		setlocal bufhidden=wipe
		setlocal tabstop=8
		setlocal foldmethod=syntax
	endif

	return 1
endfunction    " ----------  end of function s:OpenGitBuffer  ----------
"
"-------------------------------------------------------------------------------
" s:UpdateGitBuffer : Put output in a read-only buffer.   {{{1
"
" Parameters:
"   command - the command to run (string)
"   stay    - if true, return to the old position in the buffer
"             (integer, default: 0)
" Returns:
"   success - true, if the command was run successfully (integer)
"
" The output of the command is used to replace the text in the current buffer.
" If 'stay' is true, return to the same line the cursor was placed in before
" the update. After updating, 'modified' is cleared.
"-------------------------------------------------------------------------------
"
function! s:UpdateGitBuffer ( command, ... )
	"
	if a:0 == 1 && a:1
		" return to old position
		let pos_window = line('.') - winline() + 1
		let pos_cursor = line('.')
	else
		let pos_window = 1
		let pos_cursor = 1
	endif
	"
	" delete the previous contents
	setlocal modifiable
	setlocal noro
	silent exe '1,$delete _'
	"
	" pause syntax highlighting (for speed)
	if &syntax != ''
		setlocal syntax=OFF
	endif
	"
	" insert the output of the command
	silent exe 'r! '.a:command
	"
	" delete the first line (empty) and go to position
	normal! gg"_dd
	silent exe 'normal! '.pos_window.'zt'
	silent exe ':'.pos_cursor
	"
	" restart syntax highlighting
	if &syntax != ''
		setlocal syntax=ON
	endif
	"
	" open all folds (closed by the syntax highlighting)
	normal! zR
	"
	" read-only again
	setlocal ro
	setlocal nomodified
	setlocal nomodifiable
	"
	return v:shell_error == 0
endfunction    " ----------  end of function s:UpdateGitBuffer  ----------
"
"-------------------------------------------------------------------------------
" GitS_FoldLog : fold text for 'git diff/log/show/status'   {{{1
"-------------------------------------------------------------------------------
"
function! GitS_FoldLog ()
	let line = getline( v:foldstart )
	let head = '+-'.v:folddashes.' '
	let tail = ' ('.( v:foldend - v:foldstart + 1 ).' lines) '
	"
	if line =~ '^tag'
		" search for the first line which starts with a space,
		" this is the first line of the commit message
		return head.'tag - '.substitute( line, '^tag\s\+', '', '' ).tail
	elseif line =~ '^commit'
		" search for the first line which starts with a space,
		" this is the first line of the commit message
		let pos = v:foldstart
		while pos <= v:foldend
			if getline(pos) =~ '^\s\+\S'
				break
			endif
			let pos += 1
		endwhile
		if pos > v:foldend | let pos = v:foldstart | endif
		return head.'commit - '.substitute( getline(pos), '^\s\+', '', '' ).tail
	elseif line =~ '^diff'
	  " take the filename from (we also consider backslashes):
		"   diff --git a/<file> b/<file>
		let file = matchstr ( line, 'a\([/\\]\)\zs\(.*\)\ze b\1\2\s*$' )
		if file != ''
			return head.'diff - '.file.tail
		else
			return head.line.tail
		endif
	elseif ! s:HasStatus185Format && line =~ '^#\s\a.*:$'
				\ || s:HasStatus185Format && line =~ '^\a.*:$'
		" we assume a line in the status comment block and try to guess the number of lines (=files)
		" :TODO:20.03.2013 19:30:WM: (might be something else)
		"
		let prefix = s:HasStatus185Format ? '' : '#'
		"
		let filesstart = v:foldstart+1
		let filesend   = v:foldend
		while filesstart < v:foldend && getline(filesstart) =~ '\_^'.prefix.'\s*\_$\|\_^'.prefix.'\s\+('
			let filesstart += 1
		endwhile
		while filesend > v:foldstart && getline(filesend) =~ '^'.prefix.'\s*$'
			let filesend -= 1
		endwhile
		return line.' '.( filesend - filesstart + 1 ).' files '
	else
		return head.line.tail
	endif
endfunction    " ----------  end of function GitS_FoldLog  ----------
"
"-------------------------------------------------------------------------------
" GitS_FoldGrep : fold text for 'git grep'   {{{1
"-------------------------------------------------------------------------------
"
function! GitS_FoldGrep ()
	let line = getline( v:foldstart )
	let head = '+-'.v:folddashes.' '
	let tail = ' ('.( v:foldend - v:foldstart + 1 ).' lines) '
	"
	" take the filename from the first line
	let file = matchstr ( line, '^[^:]\+\ze:' )
	if file != ''
		return file.tail
	else
		return head.line.tail
	endif
endfunction    " ----------  end of function GitS_FoldGrep  ----------

"-------------------------------------------------------------------------------
" GitS_Split : Open a Git buffer differently.   {{{1
"
" Mode:
"   above - split aboveleft
"   below - split belowright
"   tab   - open in new tab
"-------------------------------------------------------------------------------

let s:SplitMode   = ''
let s:SplitAddArg = 0

function! GitS_Split ( mode, count, args )

	if a:mode == 'above'
	elseif a:mode == 'below'
	elseif a:mode == 'tab'
		let s:SplitAddArg = a:count == 1000 ? tabpagenr() : a:count
	else
		return s:ErrorMsg ( 'Unknown mode "'.a:mode.'".' )
	endif

	let s:SplitMode = a:mode

	try
		exe a:args
	catch /.*/
		call s:ErrorMsg ( substitute ( v:exception, '^Vim:', '', '' ) )
	finally
	endtry

	let s:SplitMode   = ''
	let s:SplitAddArg = 0

endfunction    " ----------  end of function GitS_Split  ----------

"-------------------------------------------------------------------------------
" GitS_Run : execute 'git ...'   {{{1
"
" Flags: -> s:StandardRun
"-------------------------------------------------------------------------------
"
function! GitS_Run( param, flags )
	"
	if a:flags =~ 'b'
		call GitS_RunBuf ( 'update', a:param )
	else
		return s:StandardRun ( '', a:param, a:flags, 'bc' )
	endif
	"
endfunction    " ----------  end of function GitS_Run  ----------
"
"-------------------------------------------------------------------------------
" GitS_RunBuf : execute 'git ...'   {{{1
"-------------------------------------------------------------------------------
"
function! GitS_RunBuf( action, ... )
	"
	if a:action == 'help'
		echo s:HelpTxtStd
		return
	elseif a:action == 'quit'
		close
		return
	elseif a:action == 'update'
		"
		if a:1 =~ '^!'
			let subcmd = matchstr ( a:1, '[a-z][a-z\-]*' )
		else
			let param  = a:1
			let subcmd = matchstr ( a:1, '[a-z][a-z\-]*' )
		endif
		"
	else
		echoerr 'Unknown action "'.a:action.'".'
		return
	endif
	"
	let buf = s:CheckCWD ()
	"
	if s:OpenGitBuffer ( 'Git - git '.subcmd )
		"
		let b:GitSupport_RunBufFlag = 1
		"
		exe 'nnoremap          <buffer> <S-F1> :call GitS_RunBuf("help")<CR>'
		exe 'nnoremap <silent> <buffer> q      :call GitS_RunBuf("quit")<CR>'
		exe 'nnoremap <silent> <buffer> u      :call GitS_RunBuf("update","!'.subcmd.'")<CR>'
	endif
	"
	call s:ChangeCWD ( buf )
	"
	if ! exists ( 'param' )
		let param = b:GitSupport_Param
	else
		let b:GitSupport_Param = param
	endif
	"
	let cmd = s:Git_Executable.' '.param
	"
	call s:UpdateGitBuffer ( cmd )
	"
endfunction    " ----------  end of function GitS_RunBuf  ----------
"
"-------------------------------------------------------------------------------
" GitS_Add : execute 'git add ...'   {{{1
"
" Flags:
"   c - Ask for confirmation.
"   e - Expand empty 'param' to current buffer.
"   f - Force add (cmdline param -f).
"-------------------------------------------------------------------------------
"
function! GitS_Add( param, flags )
	"
	if a:flags =~ '[^cef]'
		return s:ErrorMsg ( 'Unknown flag "'.matchstr( a:flags, '[^cef]' ).'".' )
	endif
	"
	if a:flags =~ 'e' && empty( a:param ) | let param = s:EscapeCurrent()
	else                                  | let param = a:param
	endif
	"
	if a:flags =~ 'f' | let param = '-f '.param | endif
	"
	let cmd = s:Git_Executable.' add '.param
	"
	if a:flags =~ 'c' && s:Question ( 'Execute "git add '.param.'"?' ) != 1
		echo "aborted"
		return
	endif
	"
	let text = system ( cmd )
	"
	if v:shell_error == 0 && text =~ '^\s*$'
		echo "ran successfully"               | " success
	elseif v:shell_error == 0
		echo "ran successfully:\n".text       | " success
	else
		echo "\"".cmd."\" failed:\n\n".text   | " failure, may use the force instead
		if ! a:flags =~ 'f'
			echo "\nUse \":GitAdd! ...\" to force adding the files.\n"
		endif
	endif
	"
endfunction    " ----------  end of function GitS_Add  ----------
"
"-------------------------------------------------------------------------------
" GitS_Blame : execute 'git blame ...'   {{{1
"-------------------------------------------------------------------------------
"
"-------------------------------------------------------------------------------
" s:Blame_GetFile : Get the file, line and the commit under the cursor.   {{{2
"
" Parameters:
"   -
" Returns:
"   [ <file-name>, <line>, <commit> ] - data (list: string, integer, string)
"
" The entries are as follows:
"   file name - name of the file under the cursor (string)
"   line      - the line in the original file (integer)
"   commit    - the commit (string)
"
" If only the name of the file could be obtained, returns:
"   [ <file-name>, -1, ... ]
" If the name of the file could be found:
"   [ '', -1, ... ]
" If the line is not committed yet:
"   [ ..., ..., '-NEW-' ]
" If the commit could not be obtained:
"   [ ..., ..., '' ]
"-------------------------------------------------------------------------------
"
function! s:Blame_GetFile()
	"
	let f_name = ''
	let f_line = '-1'
	let commit = ''
	"
	if exists ( 'b:GitSupport_BlameFile ' )
		let f_name = b:GitSupport_BlameFile
	else
		let args = s:GitCmdLineArgs( b:GitSupport_Param )
		"
		if empty ( args )
			let f_name = ''
		else
			let f_name = args[-1]
		endif
		"
		let b:GitSupport_BlameFile = f_name
	endif
	"
	" LINE:
	"   [^] commit [ofile] (INFO line)
	" The token 'ofile' appears if the file has been renamed in the meantime.
	" INFO: (not used)
	"   author date time timezone
	let line = getline('.')
	let mlist = matchlist ( line, '^\^\?\(\x\+\)\s\+\%([^(]\{-}\s\+\)\?(\([^)]\+\)\s\(\d\+\))' )
	"
	if empty ( mlist )
		return [ f_name, -1, '' ]
	endif
	"
	let [ commit, info, f_line ] = mlist[1:3]
	"
	if info =~ '^Not Committed Yet '
		let commit = '-NEW-'
	endif
	"
	return [ f_name, str2nr ( f_line ), commit ]
	"
endfunction    " ----------  end of function s:Blame_GetFile  ----------
" }}}2
"-------------------------------------------------------------------------------
"
function! GitS_Blame( action, ... )
	"
	let update_only = 0
	let param = ''
	"
	if a:action == 'help'
		let txt  = s:HelpTxtStd."\n\n"
		let txt .= "of      : file under cursor: open file (edit)\n"
		let txt .= "oj      : file under cursor: open and jump to the corresponding line\n"
		let txt .= "\n"
		let txt .= "cs      : commit under cursor: show\n"
		echo txt
		return
	elseif a:action == 'quit'
		close
		return
	elseif a:action == 'update'
		"
		let update_only = a:0 == 0
		"
		if update_only
			" run again with old parameters
		else
			if   empty( a:1 ) | let param = s:EscapeCurrent()
			else              | let param = a:1
			endif
			"
			if a:0 >= 3 && a:2 <= a:3 && ! ( a:2 == 1 && a:3 == 1 )
				let param = '-L '.a:2.','.a:3.' '.param
			endif
			"
		endif
		"
	elseif a:action =~ '\<\%(\|edit\|jump\)\>'
		"
		call s:ChangeCWD ()
		"
		let [ f_name, f_line, commit ] = s:Blame_GetFile ()
		"
		if f_name == ''
			return s:ErrorMsg ( 'No file under the cursor.' )
		endif
		"
		if a:action == 'edit'
					\ || ( a:action == 'jump' && f_line == -1 )
			call s:OpenFile( f_name )
		elseif a:action == 'jump'
			call s:OpenFile( f_name, f_line, 1 )
		endif
		"
		return
	elseif a:action == 'show'
		"
		let [ f_name, f_line, commit ] = s:Blame_GetFile ()
		"
		if commit == '-NEW-'
			return s:ImportantMsg ( 'Line not committed yet.' )
		elseif commit == ''
			return s:ErrorMsg ( 'Not commit under the cursor.' )
		endif
		"
		call GitS_Show( 'update', commit )
		"
		return
	else
		echoerr 'Unknown action "'.a:action.'".'
		return
	endif
	"
	let buf = s:CheckCWD ()
	"
	if s:OpenGitBuffer ( 'Git - blame' )
		"
		let b:GitSupport_BlameFlag = 1
		"
" 		setlocal filetype=gitsdiff
		"
		exe 'nnoremap          <buffer> <S-F1> :call GitS_Blame("help")<CR>'
		exe 'nnoremap <silent> <buffer> q      :call GitS_Blame("quit")<CR>'
		exe 'nnoremap <silent> <buffer> u      :call GitS_Blame("update")<CR>'
		"
		exe 'nnoremap <silent> <buffer> of      :call GitS_Blame("edit")<CR>'
		exe 'nnoremap <silent> <buffer> oj      :call GitS_Blame("jump")<CR>'
		"
		exe 'nnoremap <silent> <buffer> cs      :call GitS_Blame("show")<CR>'
	endif
	"
	call s:ChangeCWD ( buf )
	"
	if update_only
		let param = b:GitSupport_Param
	else
		let b:GitSupport_Param = param
	endif
	"
	let cmd = s:Git_Executable.' blame '.param
	"
	call s:UpdateGitBuffer ( cmd, update_only )
	"
endfunction    " ----------  end of function GitS_Blame  ----------
"
"-------------------------------------------------------------------------------
" GitS_Branch : execute 'git branch ...'   {{{1
"
" Flags: -> s:StandardRun
"-------------------------------------------------------------------------------
"
function! GitS_Branch( param, flags )
	"
	if empty ( a:param )
		call GitS_BranchList ( 'update' )
	else
		return s:StandardRun ( 'branch', a:param, a:flags, 'c' )
	endif
	"
endfunction    " ----------  end of function GitS_Branch  ----------
"
"-------------------------------------------------------------------------------
" GitS_BranchList : execute 'git branch' (list branches)   {{{1
"-------------------------------------------------------------------------------
"
"-------------------------------------------------------------------------------
" s:BranchList_GetBranch : Get the branch under the cursor.   {{{2
"
" Parameters:
"   -
" Returns:
"   [ <branch-name>, <flag> ] - data (list: string, string)
"
" The entries are as follows:
"   branch name - name of the branch under the cursor (string)
"   flag        - contains: "r" if remote branch (string)
"
" If only the name of the branch could be obtained, returns:
"   [ <branch-name>, '' ]
" If no branch could be found:
"   [ '', '' ]
"-------------------------------------------------------------------------------
"
function! s:BranchList_GetBranch()
	"
	let line = getline('.')
	let mlist = matchlist ( line, '^[[:space:]*]*\(remotes/\)\?\(\S\+\)' )
	"
	if empty ( mlist )
		return [ '', '' ]
	else
		let branch = mlist[2]
		let flag   = empty( mlist[1] ) ? '' : 'r'
		return [ branch, flag ]
	endif
	"
endfunction    " ----------  end of function s:BranchList_GetBranch  ----------
" }}}2
"-------------------------------------------------------------------------------
"
function! GitS_BranchList( action )
	"
	if a:action == 'help'
		let txt  = s:HelpTxtStd."\n\n"
		let txt .= "branch under cursor ...\n"
		let txt .= "ch      : checkout\n"
		let txt .= "cr      : use as starting point for creating a new branch\n"
		let txt .= "de      : delete\n"
		let txt .= "De / DE : delete (via -D)\n"
		let txt .= "me      : merge with current branch\n"
		let txt .= "re      : rebase\n"
		let txt .= "rn      : rename\n"
		let txt .= "su      : set as upstream from current branch\n"
		let txt .= "cs      : show the commit\n"
		echo txt
		return
	elseif a:action == 'quit'
		close
		return
	elseif a:action == 'update'
		" noop
	elseif -1 != index ( [ 'checkout', 'create', 'delete', 'delete-force', 'merge', 'rebase', 'rename', 'set-upstream', 'show' ], a:action )
		"
		let [ b_name, b_flag ] = s:BranchList_GetBranch ()
		"
		if b_name == ''
			return s:ErrorMsg ( 'No branch under the cursor.' )
		endif
		"
		if a:action == 'checkout'
			call GitS_Checkout( shellescape(b_name), 'c' )
		elseif a:action == 'create'
			"
			let suggestion = ''
			if b_flag =~ 'r' && b_name !~ '/HEAD$'
				let suggestion = matchstr ( b_name, '[^/]\+$' )
			endif
			"
			return s:AssembleCmdLine ( ':GitBranch '.suggestion, ' '.b_name )
		elseif a:action == 'delete'
			if b_flag =~ 'r'
				call GitS_Branch( '-rd '.shellescape(b_name), 'c' )
			else
				call GitS_Branch( '-d '.shellescape(b_name), 'c' )
			endif
		elseif a:action == 'delete-force'
			if b_flag =~ 'r'
				call GitS_Branch( '-rD '.shellescape(b_name), 'c' )
			else
				call GitS_Branch( '-D '.shellescape(b_name), 'c' )
			endif
		elseif a:action == 'merge'
			call GitS_Merge( 'direct', shellescape(b_name), 'c' )
		elseif a:action == 'rebase'
			call GitS_Run( 'rebase '.shellescape(b_name), 'c')
		elseif a:action == 'rename'
			return ':GitBranch -m '.b_name.' '
		elseif a:action == 'set-upstream'
			" get short name of current HEAD
			let b_current = s:StandardRun ( 'symbolic-ref', '-q HEAD', 't' )[1]
			let b_current = s:StandardRun ( 'for-each-ref', " --format='%(refname:short)' ".shellescape( b_current ), 't' )[1]
			"
			return s:AssembleCmdLine ( ':GitBranch --set-upstream '.b_current, ' '.b_name )
		elseif a:action == 'show'
			call GitS_Show( 'update', shellescape(b_name), '' )
		endif
		"
		return
	else
		echoerr 'Unknown action "'.a:action.'".'
		return
	endif
	"
	if s:OpenGitBuffer ( 'Git - branch' )
		"
		let b:GitSupport_BranchFlag = 1
		"
		setlocal filetype=gitsbranch
		"
		exe 'nnoremap          <buffer> <S-F1> :call GitS_BranchList("help")<CR>'
		exe 'nnoremap <silent> <buffer> q      :call GitS_BranchList("quit")<CR>'
		exe 'nnoremap <silent> <buffer> u      :call GitS_BranchList("update")<CR>'
		"
		exe 'nnoremap <silent> <buffer> ch     :call GitS_BranchList("checkout")<CR>'
		exe 'nnoremap <expr>   <buffer> cr     GitS_BranchList("create")'
		exe 'nnoremap <silent> <buffer> de     :call GitS_BranchList("delete")<CR>'
		exe 'nnoremap <silent> <buffer> De     :call GitS_BranchList("delete-force")<CR>'
		exe 'nnoremap <silent> <buffer> DE     :call GitS_BranchList("delete-force")<CR>'
		exe 'nnoremap <silent> <buffer> me     :call GitS_BranchList("merge")<CR>'
		exe 'nnoremap <silent> <buffer> re     :call GitS_BranchList("rebase")<CR>'
		exe 'nnoremap <expr>   <buffer> rn     GitS_BranchList("rename")'
		exe 'nnoremap <expr>   <buffer> su     GitS_BranchList("set-upstream")'
		exe 'nnoremap <silent> <buffer> cs     :call GitS_BranchList("show")<CR>'
	endif
	"
	let cmd = s:Git_Executable.' branch -avv'
	"
	call s:UpdateGitBuffer ( cmd, 1 )
	"
endfunction    " ----------  end of function GitS_BranchList  ----------
"
"-------------------------------------------------------------------------------
" GitS_Checkout : execute 'git checkout ...'   {{{1
"
" Flags: -> s:StandardRun
"-------------------------------------------------------------------------------
"
function! GitS_Checkout( param, flags )
	"
	if a:flags =~ '[^ce]'
		return s:ErrorMsg ( 'Unknown flag "'.matchstr( a:flags, '[^ce]' ).'".' )
	endif
	"
	if g:Git_CheckoutExpandEmpty == 'yes' && empty( a:param )
		"
		" checkout on the current file potentially destroys unstaged changed,
		" ask question with different highlighting
		if a:flags =~ 'c' && s:Question ( 'Check out current file?', 'warning' ) != 1
			echo "aborted"
			return
		endif
		"
		" remove confirmation from flags and add expanding of the current file
		let flags  = substitute ( a:flags, 'c', '', 'g' )
		let flags .= 'e'
		"
	else
		let flags = a:flags
	endif
	"
	return s:StandardRun ( 'checkout', a:param, flags )
	"
endfunction    " ----------  end of function GitS_Checkout  ----------
"
"-------------------------------------------------------------------------------
" GitS_Commit : execute 'git commit ...'   {{{1
"
" Flags:
"   c - Ask for confirmation.
"-------------------------------------------------------------------------------
"
function! GitS_Commit( mode, param, flags )

	if a:flags =~ '[^c]'
		return s:ErrorMsg ( 'Unknown flag "'.matchstr( a:flags, '[^c]' ).'".' )
	endif

	if a:mode == 'direct'

		let args = s:GitCmdLineArgs ( a:param )

		if index ( args, '--dry-run', 1 ) != -1
			" dry run in separate buffer
			call GitS_CommitDryRun ( 'update', a:param )
			return
		elseif ! empty ( a:param ) || exists ( '$GIT_EDITOR' ) || g:Git_Editor != ''
			" run assuming sensible parameters ...
			" or assuming a correctly set "$GIT_EDITOR", e.g.
			" - xterm -e vim
			" - gvim -f
			let param = a:param
		elseif empty ( a:param )
			" empty parameter list

			return s:ErrorMsg ( 'The command :GitCommit currently can not be used this way.',
						\ 'Set $GIT_EDITOR properly, or use the confirmation variable "g:Git_Editor".',
						\ 'Alternatively, supply the message using either the -m or -F options, or by',
						\ 'using the special commands :GitCommitFile, :GitCommitMerge, or :GitCommitMsg.' )

" 			" get ./.git/COMMIT_EDITMSG file
" 			let file = s:GitRepoDir ()
" 			"
" 			" could not get base?
" 			if file == '' | return | endif
" 			"
" 			let file .= '/.git/COMMIT_EDITMSG'
" 			"
" 			" not readable?
" 			if ! filereadable ( file )
" 				echo 'could not read the file ".git/COMMIT_EDITMSG"'
" 				return
" 			endif
" 			"
" 			" open new buffer
" 			belowright new
" 			exe "edit ".fnameescape( file )
" 			"
" 			return
" 			"
		endif

	elseif a:mode == 'file'
		" message from file

		" update the file
		try
			update
		catch /E45.*/
			call s:ErrorMsg ( 'Could not write the file: '.buffer_name( '%' ) )
		catch /.*/
			call s:ErrorMsg ( 'Unknown error while writing the file: '.buffer_name( '%' ) )
		endtry

		" write the given file or the current one
		if empty( a:param ) | let param = '-F '.shellescape( expand('%') )
		else                | let param = '-F '.a:param
		endif

	elseif a:mode == 'merge'
		" merge conflict

		" find the file "MERGE_HEAD"
		if ! filereadable ( s:GitRepoDir ( 'git/MERGE_HEAD' ) )
			return s:ErrorMsg (
						\ 'could not read the file ".git/MERGE_HEAD" /',
						\ 'there does not seem to be a merge conflict' )
		endif

		" message from ./.git/MERGE_MSG file
		let file = s:GitRepoDir ( 'git/MERGE_MSG' )

		" not readable?
		if ! filereadable ( file )
			return s:ErrorMsg (
						\ 'could not read the file ".git/MERGE_MSG" /',
						\ 'but found ./git/MERGE_HEAD (see :help GitCommitMerge)' )
		endif

		" commit
		let param = '-F '.shellescape( file )

	elseif a:mode == 'msg'
		" message from command line
		let param = '-m "'.a:param.'"'
	else
		echoerr 'Unknown mode "'.a:mode.'".'
		return
	endif

	if a:flags =~ 'c' && s:Question ( 'Execute "git commit '.param.'"?' ) != 1
		echo "aborted"
		return
	endif

	" set '$GIT_EDITOR' according to 's:Git_Editor'
	if g:Git_Editor != ''
		if exists ( '$GIT_EDITOR' )
			let git_edit_save = $GIT_EDITOR
		endif
		if g:Git_Editor == 'vim'
			let $GIT_EDITOR = s:Git_GitBashExecutable.' '.g:Xterm_Options.' -title "git commit" -e vim '
		elseif g:Git_Editor == 'gvim'
			let $GIT_EDITOR = 'gvim -f'
		else
			return s:ErrorMsg ( 'Invalid setting for "g:Git_Editor".' )
		endif
	endif

	call s:StandardRun ( 'commit', param, '' )

	" reset '$GIT_EDITOR' if necessary
	if exists ( 'git_edit_save' )
		let $GIT_EDITOR = git_edit_save
	endif

endfunction    " ----------  end of function GitS_Commit  ----------
"
"-------------------------------------------------------------------------------
" GitS_CommitDryRun : execute 'git commit --dry-run ...'   {{{1
"-------------------------------------------------------------------------------
"
function! GitS_CommitDryRun( action, ... )
	"
	let update_only = 0
	let param = ''
	"
	if a:action == 'help'
		echo s:HelpTxtStd
		return
	elseif a:action == 'quit'
		close
		return
	elseif a:action == 'update'
		"
		let update_only = a:0 == 0
		"
		if update_only      | " run again with old parameters
		elseif empty( a:1 ) | let param = ''
		else                | let param = a:1
		endif
		"
	else
		echoerr 'Unknown action "'.a:action.'".'
		return
	endif
	"
	let buf = s:CheckCWD ()
	"
	if s:OpenGitBuffer ( 'Git - commit --dry-run' )
		"
		let b:GitSupport_CommitDryRunFlag = 1
		"
		setlocal filetype=gitsstatus
		setlocal foldtext=GitS_FoldLog()
		"
		exe 'nnoremap          <buffer> <S-F1> :call GitS_CommitDryRun("help")<CR>'
		exe 'nnoremap <silent> <buffer> q      :call GitS_CommitDryRun("quit")<CR>'
		exe 'nnoremap <silent> <buffer> u      :call GitS_CommitDryRun("update")<CR>'
	endif
	"
	call s:ChangeCWD ( buf )
	"
	if update_only
		let param = b:GitSupport_Param
	else
		let b:GitSupport_Param = param
	endif
	"
	let cmd = s:Git_Executable.' commit --dry-run '.param

	let success = s:UpdateGitBuffer ( cmd, update_only )

	if ! success
		redraw     " redraw after opening the buffer, before echoing
		call s:ImportantMsg ( '"git commit --dry-run" reports an error' )
	endif
endfunction    " ----------  end of function GitS_CommitDryRun  ----------
"
"-------------------------------------------------------------------------------
" GitS_Diff : execute 'git diff ...'   {{{1
"-------------------------------------------------------------------------------
"
"-------------------------------------------------------------------------------
" s:Diff_GetFile : Get the file (and line/col) under the cursor.   {{{2
"
" Parameters:
"   line - if the argument equals 'line', return line number (string, optional)
" Returns:
"   [ <file-name>, <line>, <column> ] - data (list: string, integer, integer)
"
" The entries are as follows:
"   file name - name of the file under the cursor (string)
"   line      - the line in the original file (integer)
"   column    - the column in the original file (integer)
"
" Only obtains the line if the optional parameter 'line' is given:
"   let [ ... ] = s:Diff_GetFile ( 'line' )
"
" If only the name of the file could be obtained, returns:
"   [ <file-name>, -1, -1 ]
" If no file could be found:
"   [ '', -1, -1 ]
"-------------------------------------------------------------------------------
"
function! s:Diff_GetFile( ... )
	"
	" :TODO:17.08.2014 15:01:WM: recognized renamed files
	"
	let f_name = ''
	let f_line = -1
	let f_col  = -1
	"
	let f_pos = line('.')
	"
	" get line and col
	if a:0 > 0 && a:1 == 'line'
		"
		let r_pos = f_pos
		let f_col = getpos( '.' )[2]
		let f_off1 = 0
		let f_off2 = 0
		"
		while r_pos > 0
			"
			if getline(r_pos) =~ '^[+ ]'
				let f_off1 += 1
				if getline(r_pos) =~ '^[+ ][+ ]'
					let f_off2 += 1
				endif
			elseif getline(r_pos) =~ '^@@ '
				let s_range = matchstr( getline(r_pos), '^@@ -\d\+,\d\+ +\zs\d\+\ze,\d\+ @@' )
				let f_line = s_range - 1 + f_off1
				let f_col  = max ( [ f_col-1, 1 ] )
				break
			elseif getline(r_pos) =~ '^@@@ '
				let s_range = matchstr( getline(r_pos), '^@@@ -\d\+,\d\+ -\d\+,\d\+ +\zs\d\+\ze,\d\+ @@@' )
				let f_line = s_range - 1 + f_off2
				let f_col  = max ( [ f_col-2, 1 ] )
				break
			elseif getline(r_pos) =~ '^diff '
				break
			endif
			"
			let r_pos -= 1
		endwhile
		"
		let f_pos = r_pos
		"
	endif
	"
	" get file
	while f_pos > 0
		"
		if getline(f_pos) =~ '^diff --git'
			let f_name = matchstr ( getline(f_pos), 'a\([/\\]\)\zs\(.*\)\ze b\1\2\s*$' )
			break
		elseif getline(f_pos) =~ '^diff --cc'
			let f_name = matchstr ( getline(f_pos), '^diff --cc \zs.*$' )
			break
		endif
		"
		let f_pos -= 1
	endwhile
	"
	return [ f_name, f_line, f_col ]
	"
endfunction    " ----------  end of function s:Diff_GetFile  ----------
"
"-------------------------------------------------------------------------------
" s:Diff_GetChunk : Get a diff header and chunk.   {{{2
"
" Parameters:
"   line - the chunk containing this line will be extracted (integer)
" Returns:
"   [ <diff-head>, <chunk-head>, <chunk-text> ] - extract texts (list of strings)
"
" The entries are as follows:
"   diff_head  - diff header "diff --git a/..." (string)
"   chunk_head - chunk header "@@ -45,6 ..." (string)
"   chunk_text - chunk text (string)
"   c_pos - position of the chunk header in the buffer (integer)
"-------------------------------------------------------------------------------
"
function! s:Diff_GetChunk ( line )
	"
	let pos_save = getpos ( '.' )
	call cursor ( a:line, 1 )
	"
	" the positions in the buffer
	let d_pos = search ( '\m\_^diff ', 'bcnW' )         " the position of the diff header
	let c_pos = search ( '\m\_^@@ ', 'bcnW' )           " the start of the chunk
	let c_end = search ( '\m\_^@@ \|\_^diff ', 'nW' )   " ... the end
	"
	call setpos ( '.', pos_save )
	"
	if d_pos == 0 || c_pos == 0
		return [ '', '', 'no valid chunk selected', 0 ]
	elseif c_end == 0
		" found the other two positions
		" -> the end of the chunk must be the end of the file
		let c_end = line('$')+1
	endif
	"
	" get the diff header
	let diff_head = getline(d_pos)
	"
	while 1
		let d_pos += 1
		let line = getline ( d_pos )
		"
		if line =~ '\m\_^\%(diff\|@@\) '
			break
		endif
		"
		let diff_head .= "\n".line
	endwhile
	"
	" get the chunk
	let chunk_head = getline ( c_pos )
	let chunk_text = join ( getline ( c_pos+1, c_end-1 ), "\n" )
	"
	return [ diff_head, chunk_head, chunk_text, c_pos ]
endfunction    " ----------  end of function s:Diff_GetChunk  ----------
"
"-------------------------------------------------------------------------------
" s:Diff_VisualChunk : Rewrite a chunk to only change the visual selection.   {{{2
"
" In case of an error, a list with two empty string and the error message is
" returned:
"   [ '', '', <error-msg> ]
"
" Parameters:
"   diff_head  - diff header "diff --git a/..." (string)
"   chunk_head - chunk header "@@ -45,6 ..." (string)
"   chunk_text - chunk text (string)
"   reverse - will be committed with the "--reverse" flag (integer)
"   v_start - start of the visual selection (integer)
"   v_end - end of the visual selection (integer)
" Returns:
"   diff_head  - diff header "diff --git a/..." (string)
"   chunk_head - rewritten chunk header "@@ -45,6 ..." (string)
"   chunk_text - rewritten chunk text (string)
"-------------------------------------------------------------------------------
"
function! s:Diff_VisualChunk ( diff_head, chunk_head, chunk_text, reverse, v_start, v_end )
	"
	" error message from 's:Diff_GetChunk'?
	if a:diff_head == ''
		return [ a:diff_head, a:chunk_head, a:chunk_text ]
	endif
	"
	let v_start = a:v_start - 1                   " convert to indices
	let v_end   = a:v_end   - 1                   " ...
	let lines = split ( a:chunk_text, '\n' )
	"
	if v_start < 0 || v_end >= len ( lines )
		return [ '', '', 'visual selection crosses chunk boundary' ]
	elseif a:chunk_head =~ '^@@@'
		return [ '', '', 'can not handle this type of chunk' ]
	endif
	"
	let n_add_off = 0
	let n_rm_off  = 0
	"
	let r = range ( len(lines)-1, v_end+1, -1 ) + range ( v_start-1, 0, -1 )
	"
	for i in r
		let line = lines[i]
		"
		if line =~ '^-' && ! a:reverse
			let lines[i] = substitute ( line, '^-', ' ', '' )
			let n_add_off += 1                        " we add one more line
		elseif line =~ '^+' && ! a:reverse
			call remove ( lines, i )
			let n_add_off -= 1                        " we add one less line
		elseif line =~ '^-' && a:reverse
			call remove ( lines, i )
			let n_rm_off -= 1                         " we remove one less line
		elseif line =~ '^+' && a:reverse
			let lines[i] = substitute ( line, '^+', ' ', '' )
			let n_rm_off += 1                         " we remove one more line
		endif
		"
	endfor
	"
	let mlist = matchlist ( a:chunk_head, '^@@ -\(\d\+\),\(\d\+\) +\(\d\+\),\(\d\+\) @@\s\?\(.*\)' )
	"
	if empty ( mlist )
		return [ '', '', 'can not parse the chunk header' ]
	else
		let [ l_rm, n_rm, l_add, n_add ] = mlist[1:4]
		let n_rm  += n_rm_off
		let n_add += n_add_off
		let chunk_head = printf ( '@@ -%d,%d +%d,%d @@ %s', l_rm, n_rm, l_add, n_add, mlist[5] )
	endif
	"
	return [ a:diff_head, chunk_head, join ( lines, "\n" ) ]
endfunction    " ----------  end of function s:Diff_VisualChunk  ----------
"
"-------------------------------------------------------------------------------
" s:Diff_ChunkHandler : Add/checkout/reset a chunk.   {{{2
"
" Parameters:
"   action - "add-chunk", "checkout-chunk", "reset-chunk" (string)
" Returns:
"   success - true, if the command was run successfully (integer)
"-------------------------------------------------------------------------------
"
function! s:Diff_ChunkHandler ( action, mode, v_start, v_end )
	"
	" get the chunk under the cursor/visual selection
	if a:mode == 'n'
		let [ diff_head, chunk_head, chunk_text, c_pos ] = s:Diff_GetChunk ( getpos('.')[1] )
	elseif a:mode == 'v'
		let reverse = a:action == 'add-chunk' ? 0 : 1
		let [ diff_head, chunk_head, chunk_text, c_pos ] = s:Diff_GetChunk ( a:v_start )
		let [ diff_head, chunk_head, chunk_text        ] = s:Diff_VisualChunk ( diff_head, chunk_head, chunk_text, reverse, a:v_start - c_pos, a:v_end - c_pos )
	endif
	"
	" error while extracting chunk?
	if diff_head == ''
		echo chunk_text
		return 0
	endif
	"
	" change to the top-level dir
	let base = s:GitRepoDir()
	"
	" could not get top-level?
	if base == '' | return | endif
	"
	silent exe 'lchdir '.fnameescape( base )
	"
	" apply the patch, depending on the action
	let chunk = diff_head."\n".chunk_head."\n".chunk_text."\n"
	"
	if a:action == 'add-chunk'
		let text = system ( s:Git_Executable.' apply --cached -- -', chunk )
	elseif a:action == 'checkout-chunk'
		let text = system ( s:Git_Executable.' apply -R -- -', chunk )
	elseif a:action == 'reset-chunk'
		let text = system ( s:Git_Executable.' apply --cached -R -- -', chunk )
	endif
	"
	silent exe 'lchdir -'
	"
	" check the result
	if v:shell_error != 0
		echo "applying the chunk failed:\n\n".text              | " failure
	elseif text =~ '^\_s*$'
		echo "chunk applied successfully"                       | " success
	else
		echo "chunk applied successfully:\n".text               | " success
	endif
	"
	return v:shell_error == 0
endfunction    " ----------  end of function s:Diff_ChunkHandler  ----------
" }}}2
"-------------------------------------------------------------------------------
"
"-------------------------------------------------------------------------------
" GitS_Diff : execute 'git diff ...'
"-------------------------------------------------------------------------------
"
function! GitS_Diff( action, ... ) range
	"
	let update_only = 0
	let param = ''
	"
	if a:action == 'help'
		let txt  = s:HelpTxtStd."\n\n"
		let txt .= "file under cursor ...\n"
		let txt .= "of      : open file (edit)\n"
		let txt .= "oj      : open and jump to the position under the cursor\n\n"
		let txt .= "\n"
		let txt .= "chunk under cursor ...\n"
		let txt .= "ac      : add to index (add chunk)\n"
		let txt .= "cc      : undo change (checkout chunk)\n"
		let txt .= "rc      : remove from index (reset chunk)\n"
		let txt .= " ->       in visual mode, these maps only apply the selected lines\n\n"
		let txt .= "For settings see:\n"
		let txt .= "  :help g:Git_DiffExpandEmpty"
		echo txt
		return
	elseif a:action == 'quit'
		close
		return
	elseif a:action == 'color-words'
		"
		" :TODO:18.01.2014 13:46:WM: use own version: git diff --word-diff=porcelain
		" :TODO:18.01.2014 13:46:WM: uncheck parameters
		call GitS_GitBash( 'diff --word-diff=color '.a:1 )
		return
		"
	elseif a:action == 'update'
		"
		let update_only = a:0 == 0
		"
		if update_only
			" run again with old parameters
		elseif empty( a:1 ) && g:Git_DiffExpandEmpty == 'yes'
			let param = s:EscapeCurrent()
		else
			let param = a:1
		endif
		"
	elseif a:action =~ '\<\%(\|edit\|jump\)\>'
		"
		let base = s:GitRepoDir()
		"
		" could not get top-level?
		if base == '' | return | endif
		"
		if a:action == 'edit'
	 		let [ f_name, f_line, f_col ] = s:Diff_GetFile ()
		elseif a:action == 'jump'
			let [ f_name, f_line, f_col ] = s:Diff_GetFile ( 'line' )
		endif
		"
		if f_name == ''
			return s:ErrorMsg ( 'No file under the cursor.' )
		endif
		"
		let f_name = base.'/'.f_name
		"
		if a:action == 'edit'
					\ || ( a:action == 'jump' && f_line == -1 )
			call s:OpenFile( f_name )
		elseif a:action == 'jump'
			call s:OpenFile( f_name, f_line, f_col )
		endif
		"
		return
	elseif a:action =~ '\<\%(\|add\|checkout\|reset\)-chunk\>'
		"
		if s:Diff_ChunkHandler ( a:action, a:1, a:firstline, a:lastline )
			call GitS_Diff ( 'update' )
		endif
		"
		return
	else
		echoerr 'Unknown action "'.a:action.'".'
		return
	endif
	"
	let buf = s:CheckCWD ()
	"
	if s:OpenGitBuffer ( 'Git - diff' )
		"
		let b:GitSupport_DiffFlag = 1
		"
		setlocal filetype=gitsdiff
		setlocal foldtext=GitS_FoldLog()
		"
		exe 'nnoremap          <buffer> <S-F1> :call GitS_Diff("help")<CR>'
		exe 'nnoremap <silent> <buffer> q      :call GitS_Diff("quit")<CR>'
		exe 'nnoremap <silent> <buffer> u      :call GitS_Diff("update")<CR>'
		"
		exe 'nnoremap <silent> <buffer> of     :call GitS_Diff("edit")<CR>'
		exe 'nnoremap <silent> <buffer> oj     :call GitS_Diff("jump")<CR>'
		"
		exe 'nnoremap <silent> <buffer> ac     :call GitS_Diff("add-chunk","n")<CR>'
		exe 'vnoremap <silent> <buffer> ac     :call GitS_Diff("add-chunk","v")<CR>'
		exe 'nnoremap <silent> <buffer> cc     :call GitS_Diff("checkout-chunk","n")<CR>'
		exe 'vnoremap <silent> <buffer> cc     :call GitS_Diff("checkout-chunk","v")<CR>'
		exe 'nnoremap <silent> <buffer> rc     :call GitS_Diff("reset-chunk","n")<CR>'
		exe 'vnoremap <silent> <buffer> rc     :call GitS_Diff("reset-chunk","v")<CR>'
	endif
	"
	call s:ChangeCWD ( buf )
	"
	if update_only
		let param = b:GitSupport_Param
	else
		let b:GitSupport_Param = param
	endif
	"
	let cmd = s:Git_Executable.' diff '.param
	"
	call s:UpdateGitBuffer ( cmd, update_only )
	"
endfunction    " ----------  end of function GitS_Diff  ----------
"
"-------------------------------------------------------------------------------
" GitS_Fetch : execute 'git fetch ...'   {{{1
"
" Flags: -> s:StandardRun
"-------------------------------------------------------------------------------
"
function! GitS_Fetch( param, flags )
	"
	return s:StandardRun ( 'fetch', a:param, a:flags, 'c' )
	"
endfunction    " ----------  end of function GitS_Fetch  ----------
"
"-------------------------------------------------------------------------------
" GitS_Grep : execute 'git grep ...'   {{{1
"-------------------------------------------------------------------------------
"
"-------------------------------------------------------------------------------
" s:Grep_GetFile : Get the file and line under the cursor.   {{{2
"
" Parameters:
"   -
" Returns:
"   [ <file-name>, <line> ] - data (list: string, integer)
"
" The entries are as follows:
"   file name - name of the file under the cursor (string)
"   line      - the line in the original file (integer)
"
" If only the name of the file could be obtained, returns:
"   [ <file-name>, -1 ]
" If no file could be found:
"   [ '', -1 ]
"-------------------------------------------------------------------------------
"
function! s:Grep_GetFile()
	"
	let mlist = matchlist ( getline('.'), '^\([^:]\+\):\%(\(\d\+\):\)\?' )
	"
	if empty ( mlist )
		return [ '', -1 ]
	endif
	"
	let f_name = mlist[1]
	let f_line = mlist[2]
	"
	if f_line == ''
		return [ f_name, -1 ]
	endif
	"
	return [ f_name, str2nr ( f_line ) ]
	"
endfunction    " ----------  end of function s:Grep_GetFile  ----------
" }}}2
"-------------------------------------------------------------------------------
"
function! GitS_Grep( action, ... )
	"
	let update_only = 0
	let param = ''
	"
	if a:action == 'help'
		let txt  = s:HelpTxtStd."\n\n"
		let txt .= "of      : file under cursor: open file (edit)\n"
		let txt .= "oj      : file under cursor: open and jump to the corresponding line\n"
		let txt .= "<Enter> : file under cursor: open and jump to the corresponding line"
		echo txt
		return
	elseif a:action == 'quit'
		close
		return
	elseif a:action == 'update' || a:action == 'top'
		"
		let update_only = a:0 == 0
		"
		if update_only      | " run again with old parameters
		elseif empty( a:1 ) | let param = ''
		else                | let param = a:1
		endif
		"
	elseif a:action =~ '\<\%(\|edit\|jump\)\>'
		"
		call s:ChangeCWD ()
		"
		let [ f_name, f_line ] = s:Grep_GetFile ()
		"
		if f_name == ''
			return s:ErrorMsg ( 'No file under the cursor.' )
		endif
		"
		if a:action == 'edit'
					\ || ( a:action == 'jump' && f_line == -1 )
			call s:OpenFile( f_name )
		elseif a:action == 'jump'
			call s:OpenFile( f_name, f_line, 1 )
		endif
		"
		return
	else
		echoerr 'Unknown action "'.a:action.'".'
		return
	endif
	"
	let buf = s:CheckCWD ()
	"
	" for action 'top', set the working directory to the top-level directory
	if a:action == 'top'
		let base = s:GitRepoDir()
		"
		" could not get top-level?
		if base == '' | return | endif
		"
		let buf[1] = base
	endif
	"
	if s:OpenGitBuffer ( 'Git - grep' )
		"
		let b:GitSupport_GrepFlag = 1
		"
		setlocal filetype=gitsgrep
		setlocal foldtext=GitS_FoldGrep()
		"
		exe 'nnoremap          <buffer> <S-F1> :call GitS_Grep("help")<CR>'
		exe 'nnoremap <silent> <buffer> q      :call GitS_Grep("quit")<CR>'
		exe 'nnoremap <silent> <buffer> u      :call GitS_Grep("update")<CR>'
		"
		exe 'nnoremap <silent> <buffer> of      :call GitS_Grep("edit")<CR>'
		exe 'nnoremap <silent> <buffer> oj      :call GitS_Grep("jump")<CR>'
		exe 'nnoremap <silent> <buffer> <Enter> :call GitS_Grep("jump")<CR>'
	endif
	"
	call s:ChangeCWD ( buf )
	"
	if update_only
		let param = b:GitSupport_Param
	else
		let b:GitSupport_Param = param
	endif
	"
	let cmd = s:Git_Executable.' grep '.param
	"
	call s:UpdateGitBuffer ( cmd, update_only )
	"
endfunction    " ----------  end of function GitS_Grep  ----------
"
"-------------------------------------------------------------------------------
" GitS_Help : execute 'git help'   {{{1
"-------------------------------------------------------------------------------
"
function! GitS_Help( action, ... )
	"
	let helpcmd = ''
	"
	if a:action == 'disabled'
		return s:ImportantMsg ( s:DisabledMessage, s:DisabledReason )
	elseif a:action == 'help'
		echo s:HelpTxtStdNoUpdate
" 		let txt  = s:HelpTxtStdNoUpdate."\n\n"
" 		let txt .= "c       : show contents and jump to section\n"
" 		echo txt
		return
	elseif a:action == 'quit'
		close
		return
	elseif a:action == 'update'
		if a:0 == 0
			" noop
		else
			let helpcmd = a:1
		endif
" 	elseif a:action == 'toc'
" 		for i in range( 1, len(b:GitSupport_TOC) )
" 			echo i.' - '.b:GitSupport_TOC[i-1][1]
" 		endfor
" 		return
	else
		echoerr 'Unknown action "'.a:action.'".'
		return
	endif

	if s:GitHelpFormat == 'html'
		return s:StandardRun ( 'help', helpcmd, '' )
	endif

	let ts_save = &g:tabstop

	if s:OpenGitBuffer ( 'Git - help' )
		"
		let b:GitSupport_HelpFlag = 1
		"
		setlocal filetype=man
		"
		exe 'nnoremap          <buffer> <S-F1> :call GitS_Help("help")<CR>'
		exe 'nnoremap <silent> <buffer> q      :call GitS_Help("quit")<CR>'
		"
		"exe 'nnoremap <silent> <buffer> c      :call GitS_Help("toc")<CR>'
	endif
	"
	let cmd = s:Git_Executable.' help '.helpcmd
	"
	if s:UNIX && winwidth( winnr() ) > 0
		let cmd = 'MANWIDTH='.winwidth( winnr() ).' '.cmd
	endif

	call s:UpdateGitBuffer ( cmd )

	let &g:tabstop = ts_save

	" :TODO:19.01.2014 18:26:WM: own toc or via ctags?
" 	let b:GitSupport_TOC = []
" 	"
" 	let cpos = getpos ('.')
" 	call setpos ( '.', [ bufnr('%'),1,1,1 ] )
" 	"
"  	while 1
"  		let pos = search ( '^\w', 'W' )
"  		"
"  		if pos == 0 | break | endif
" 		if pos == 1 || pos == line('$') | continue | endif
"  		"
"  		let item = matchstr ( getline(pos), '^[0-9A-Za-z \t]\+' )
"  		"
" 		call add ( b:GitSupport_TOC, [ pos, item ] )
"  		"
"  	endwhile
" 	"
" 	call setpos ('.',cpos)
	"
endfunction    " ----------  end of function GitS_Help  ----------
"
"-------------------------------------------------------------------------------
" GitS_Log : execute 'git log ...'   {{{1
"-------------------------------------------------------------------------------
"
"-------------------------------------------------------------------------------
" s:Log_GetCommit : Get the commit under the cursor.   {{{2
"
" Parameters:
"   -
" Returns:
"   <commit-name> - the name of the commit (string)
"
" If the commit could not be obtained returns an empty string.
"-------------------------------------------------------------------------------
"
function! s:Log_GetCommit()
	"
	" in case of "git log --oneline"
	if match ( getline('.'), '^\x\{6,}\(\s\|\_$\)' ) >= 0
		echo 'oneline'
		return matchstr ( getline('.'), '^\x\+' )
	endif
	"
	let c_pos = search ( '\m\_^commit \x', 'bcnW' )      " the position of the commit name
	"
	if c_pos == 0
		return ''
	endif
	"
	return matchstr ( getline(c_pos), '^commit\s\zs\x\+' )
	"
endfunction    " ----------  end of function s:Log_GetCommit  ----------
" }}}2
"-------------------------------------------------------------------------------
"
function! GitS_Log( action, ... )
	"
	let param = ''
	"
	if a:action == 'help'
		let txt  = s:HelpTxtStd."\n\n"
		let txt .= "commit under cursor ...\n"
		let txt .= "ch      : checkout\n"
		let txt .= "cr      : use as starting point for creating a new branch\n"
		let txt .= "sh / cs : show the commit\n"
		let txt .= "ta      : tag the commit\n"
		echo txt
		return
	elseif a:action == 'quit'
		close
		return
	elseif a:action == 'update'
		"
		if a:0 == 0         | " run again with old parameters
		elseif empty( a:1 ) | let param = ''
		else                | let param = a:1
		endif
		"
	elseif -1 != index ( [ 'checkout', 'create', 'show', 'tag' ], a:action )
		"
		let c_name = s:Log_GetCommit ()
		"
		if c_name == ''
			return s:ErrorMsg ( 'No commit under the cursor.' )
		endif
		"
		if a:action == 'checkout'
			call GitS_Checkout( shellescape(c_name), 'c' )
		elseif a:action == 'create'
			return s:AssembleCmdLine ( ':GitBranch ', ' '.c_name )
		elseif a:action == 'show'
			call GitS_Show( 'update', shellescape(c_name), '' )
		elseif a:action == 'tag'
			return s:AssembleCmdLine ( ':GitTag ', ' '.c_name )
		endif
		"
		return
	else
		echoerr 'Unknown action "'.a:action.'".'
		return
	endif
	"
	let buf = s:CheckCWD ()
	"
	if s:OpenGitBuffer ( 'Git - log' )
		"
		let b:GitSupport_LogFlag = 1
		"
		setlocal filetype=gitslog
		setlocal foldtext=GitS_FoldLog()
		"
		exe 'nnoremap          <buffer> <S-F1> :call GitS_Log("help")<CR>'
		exe 'nnoremap <silent> <buffer> q      :call GitS_Log("quit")<CR>'
		exe 'nnoremap <silent> <buffer> u      :call GitS_Log("update")<CR>'
		"
		exe 'nnoremap <silent> <buffer> ch     :call GitS_Log("checkout")<CR>'
		exe 'nnoremap <expr>   <buffer> cr     GitS_Log("create")'
		exe 'nnoremap <silent> <buffer> sh     :call GitS_Log("show")<CR>'
		exe 'nnoremap <silent> <buffer> cs     :call GitS_Log("show")<CR>'
		exe 'nnoremap <expr>   <buffer> ta     GitS_Log("tag")'
	endif
	"
	call s:ChangeCWD ( buf )
	"
	if a:0 == 0
		let param = b:GitSupport_Param
	else
		let b:GitSupport_Param = param
	endif
	"
	let cmd = s:Git_Executable.' log '.param
	"
	call s:UpdateGitBuffer ( cmd )
	"
endfunction    " ----------  end of function GitS_Log  ----------
"
"-------------------------------------------------------------------------------
" GitS_Merge : execute 'git merge ...'   {{{1
"
" Flags: -> s:StandardRun
"-------------------------------------------------------------------------------
"
function! GitS_Merge( mode, param, flags )
	"
	if a:mode == 'direct'
		"
		return s:StandardRun ( 'merge', a:param, a:flags, 'c' )
		"
	elseif a:mode == 'upstream'
		"
		let b_current = s:StandardRun ( 'symbolic-ref', '-q HEAD', 't' )[1]
		let b_upstream = s:StandardRun ( 'for-each-ref', " --format='%(upstream:short)' ".shellescape( b_current ), 't' )[1]
		"
		if b_upstream == ''
			return s:ImportantMsg ( 'No upstream branch.' )
		elseif a:param == ''
			return s:StandardRun ( 'merge', b_upstream, 'c' )
		else
			return s:StandardRun ( 'merge', a:param.' '.b_upstream, 'c' )
		endif
		"
	else
		echoerr 'Unknown mode "'.a:mode.'".'
		return
	endif
	"
endfunction    " ----------  end of function GitS_Merge  ----------
"
"-------------------------------------------------------------------------------
" GitS_Move : execute 'git move ...'   {{{1
"
" Flags: -> s:StandardRun
"-------------------------------------------------------------------------------
"
function! GitS_Move( param, flags )
	"
	return s:StandardRun ( 'mv', a:param, a:flags, 'c' )
	"
endfunction    " ----------  end of function GitS_Move  ----------
"
"-------------------------------------------------------------------------------
" GitS_Pull : execute 'git pull ...'   {{{1
"
" Flags: -> s:StandardRun
"-------------------------------------------------------------------------------
"
function! GitS_Pull( param, flags )
	"
	return s:StandardRun ( 'pull', a:param, a:flags, 'c' )
	"
endfunction    " ----------  end of function GitS_Pull  ----------
"
"-------------------------------------------------------------------------------
" GitS_Push : execute 'git push ...'   {{{1
"
" Flags: -> s:StandardRun
"-------------------------------------------------------------------------------
"
function! GitS_Push( param, flags )
	"
	return s:StandardRun ( 'push', a:param, a:flags, 'c' )
	"
endfunction    " ----------  end of function GitS_Push  ----------
"
"-------------------------------------------------------------------------------
" GitS_Remote : execute 'git remote ...'   {{{1
"
" Flags: -> s:StandardRun
"-------------------------------------------------------------------------------
"
function! GitS_Remote( param, flags )
	"
	if empty ( a:param )
		call GitS_RemoteList ( 'update' )
	else
		return s:StandardRun ( 'remote', a:param, a:flags, 'c' )
	endif
	"
endfunction    " ----------  end of function GitS_Remote  ----------
"
"-------------------------------------------------------------------------------
" GitS_RemoteList : execute 'git remote' (list remotes)   {{{1
"-------------------------------------------------------------------------------
"
"-------------------------------------------------------------------------------
" s:RemoteList_GetRemote : Get the remote and URL under the cursor.   {{{2
"
" Parameters:
"   -
" Returns:
"   [ <remote-name>, <url> ] - data (list: string, string)
"
" The entries are as follows:
"   remote name - name of the remote under the cursor (string)
"   url         - its URL (string)
"
" If only the name of the remote could be obtained, returns:
"   [ <remote-name>, '' ]
" If no remote could be found:
"   [ '', '' ]
"-------------------------------------------------------------------------------
"
function! s:RemoteList_GetRemote()
	"
	let line = getline('.')
	let mlist = matchlist ( line, '^\s*\(\S\+\)\s\+\(.\+\)\s\+(\w\+)$' )
	"
	if empty ( mlist )
		return [ '', '' ]
	else
		return mlist[1:2]
	endif
	"
endfunction    " ----------  end of function s:RemoteList_GetRemote  ----------
" }}}2
"-------------------------------------------------------------------------------
"
function! GitS_RemoteList( action )
	"
	if a:action == 'help'
		let txt  = s:HelpTxtStd."\n\n"
		let txt .= "remote under cursor ...\n"
		let txt .= "fe      : fetch\n"
		let txt .= "ph      : push\n"
		let txt .= "pl      : pull\n"
		let txt .= "rm      : remove\n"
		let txt .= "rn      : rename\n"
		let txt .= "su      : set-url\n"
		let txt .= "sh      : show\n"
		echo txt
		return
	elseif a:action == 'quit'
		close
		return
	elseif a:action == 'update'
		" noop
	elseif -1 != index ( [ 'fetch', 'push', 'pull', 'remove', 'rename', 'set-url', 'show' ], a:action )
		"
		let [ r_name, r_url ] = s:RemoteList_GetRemote ()
		"
		if r_name == ''
			return s:ErrorMsg ( 'No remote under the cursor.' )
		endif
		"
		if a:action == 'fetch'
			return ':GitFetch '.r_name.' '
		elseif a:action == 'push'
			return ':GitPush '.r_name.' '
		elseif a:action == 'pull'
			return ':GitPull '.r_name.' '
		elseif a:action == 'remove'
			call GitS_Remote( 'rm '.shellescape(r_name), 'c' )
		elseif a:action == 'rename'
			return ':GitRemote rename '.r_name.' '
		elseif a:action == 'set-url'
			if empty ( r_url )
				return ':GitRemote set-url '.r_name.' '
			else
				return ':GitRemote set-url '.r_name.' '.shellescape( r_url )
			endif
		elseif a:action == 'show'
			call GitS_Remote( 'show '.shellescape(r_name), '' )
		endif
		"
		return
	else
		echoerr 'Unknown action "'.a:action.'".'
		return
	endif
	"
	if s:OpenGitBuffer ( 'Git - remote' )
		"
		let b:GitSupport_RemoteFlag = 1
		"
		"setlocal filetype=
		"
		exe 'nnoremap          <buffer> <S-F1> :call GitS_RemoteList("help")<CR>'
		exe 'nnoremap <silent> <buffer> q      :call GitS_RemoteList("quit")<CR>'
		exe 'nnoremap <silent> <buffer> u      :call GitS_RemoteList("update")<CR>'
		"
		exe 'nnoremap <expr>   <buffer> fe     GitS_RemoteList("fetch")'
		exe 'nnoremap <expr>   <buffer> ph     GitS_RemoteList("push")'
		exe 'nnoremap <expr>   <buffer> pl     GitS_RemoteList("pull")'
		exe 'nnoremap <silent> <buffer> rm     :call GitS_RemoteList("remove")<CR>'
		exe 'nnoremap <expr>   <buffer> rn     GitS_RemoteList("rename")'
		exe 'nnoremap <expr>   <buffer> su     GitS_RemoteList("set-url")'
		exe 'nnoremap <silent> <buffer> sh     :call GitS_RemoteList("show")<CR>'
	endif
	"
	let cmd = s:Git_Executable.' remote -v'
	"
	call s:UpdateGitBuffer ( cmd, 1 )
	"
endfunction    " ----------  end of function GitS_RemoteList  ----------
"
"-------------------------------------------------------------------------------
" GitS_Remove : execute 'git rm ...'   {{{1
"
" Flags: -> s:StandardRun
"-------------------------------------------------------------------------------
"
function! GitS_Remove( param, flags )
	"
	call s:StandardRun ( 'rm', a:param, a:flags )
	"
	if empty ( a:param ) && s:Question ( 'Delete the current buffer as well?' ) == 1
		bdelete
		echo "deleted"
	endif
	"
endfunction    " ----------  end of function GitS_Remove  ----------
"
"-------------------------------------------------------------------------------
" GitS_Reset : execute 'git reset ...'   {{{1
"
" Flags: -> s:StandardRun
"-------------------------------------------------------------------------------
"
function! GitS_Reset( param, flags )
	"
	if g:Git_ResetExpandEmpty == 'yes'
		let flags = a:flags.'e'
	else
		let flags = a:flags
	endif
	"
	return s:StandardRun ( 'reset', a:param, flags )
	"
endfunction    " ----------  end of function GitS_Reset  ----------
"
"-------------------------------------------------------------------------------
" GitS_Show : execute 'git show ...'   {{{1
"-------------------------------------------------------------------------------
"
"-------------------------------------------------------------------------------
" s:Show_RevisionNames : Special names for git show.   {{{2
"-------------------------------------------------------------------------------
"
let s:Show_RevisionNames = {
			\ ':'   : 'STAGED',
			\ ':0:' : 'STAGED',
			\ ':1:' : 'COMMON_ANCESTOR',
			\ ':2:' : 'TARGET_BRANCH',
			\ ':3:' : 'SOURCE_BRANCH',
			\ }
"
"-------------------------------------------------------------------------------
" s:Show_AnalyseObject : Analyse the object given to show.   {{{2
"
" Parameters:
"   args - command line args given to :GitShow (string)
" Returns:
"   [ <last>, <type> ] - data (list: string, string)
"
" The entries are as follows:
"   last - the last argument (string)
"   type - type of the object: "blob", "commit", "tag" or "tree" (string)
"
" If the object or type could not be obtained:
"   [ '', '' ]
"-------------------------------------------------------------------------------
"
function! s:Show_AnalyseObject( args )
	"
	let args = s:GitCmdLineArgs ( a:args )
	if args[-1] == ''
		return [ '', '' ]
	else
		let [ ret, type ] = s:StandardRun ( 'cat-file', " -t ".shellescape( args[-1] ), 't' )
	endif
	"
	if ret != 0
		return [ '', '' ]
	endif
	"
	return [ args[-1], type ]
	"
endfunction    " ----------  end of function s:Show_AnalyseObject  ----------
" }}}2
"-------------------------------------------------------------------------------
"
function! GitS_Show( action, ... )
	"
	let param = ''
	"
	if a:action == 'help'
		echo s:HelpTxtStd
		return
	elseif a:action == 'quit'
		close
		return
	elseif a:action == 'update'
		"
		if a:0 == 0
			" run again with old parameters
			"
			let [ last_arg, type ] = [ '', '' ]
		elseif a:1 =~ '^\s*$'
			let param = ''
			"
			let [ last_arg, type ] = [ 'HEAD', 'commit' ]
		else
			" new arguments
			let param = a:1
			"
			let [ last_arg, type ] = s:Show_AnalyseObject ( param )
			"
		endif
		"
	else
		echoerr 'Unknown action "'.a:action.'".'
		return
	endif
	"
	" BLOB: treat separately
	if type == 'blob'
		"
		if last_arg =~ '\_^:[0123]:\|\_^:[^/]'
			let obj_src = s:Show_RevisionNames[ matchstr( last_arg, '\_^:[0123]:\|\_^:' ) ]
			let last_arg = substitute( last_arg, '\_^:[0123]:\|\_^:', obj_src.'.', '' )
		endif
		"
		let last_arg = substitute ( last_arg, ':', '.', '' )
		let last_arg = substitute ( last_arg, '/', '.', 'g' )
		"
		call s:OpenGitBuffer ( last_arg )
		call s:UpdateGitBuffer ( s:Git_Executable.' show '.param )
		filetype detect
		return
	endif
	"
	let buf = s:CheckCWD ()
	"
	if s:OpenGitBuffer ( 'Git - show' )
		"
		let b:GitSupport_ShowFlag = 1
		"
		setlocal filetype=gitslog
		setlocal foldtext=GitS_FoldLog()
		"
		exe 'nnoremap          <buffer> <S-F1> :call GitS_Show("help")<CR>'
		exe 'nnoremap <silent> <buffer> q      :call GitS_Show("quit")<CR>'
		exe 'nnoremap <silent> <buffer> u      :call GitS_Show("update")<CR>'
	endif
	"
	call s:ChangeCWD ( buf )
	"
	if a:0 == 0
		let param = b:GitSupport_Param
	else
		let b:GitSupport_Param = param
	endif
	"
	let cmd = s:Git_Executable.' show '.param
	"
	call s:UpdateGitBuffer ( cmd )
	"
endfunction    " ----------  end of function GitS_Show  ----------
"
"-------------------------------------------------------------------------------
" GitS_Stash : execute 'git stash ...'   {{{1
"
" Flags: -> s:StandardRun
"-------------------------------------------------------------------------------
"
function! GitS_Stash( param, flags )
	"
	let subcmd = matchstr ( a:param, '^\s*\zs\w\+' )
	"
	if subcmd == 'list'
		call GitS_StashList ( 'update', a:param )
	elseif subcmd == 'show'
		call GitS_StashShow ( 'update', a:param )
	else
		return s:StandardRun ( 'stash', a:param, a:flags, 'c' )
	endif
	"
	"
endfunction    " ----------  end of function GitS_Stash  ----------
"
"-------------------------------------------------------------------------------
" GitS_StashList : execute 'git stash list ...'   {{{1
"-------------------------------------------------------------------------------
"
"-------------------------------------------------------------------------------
" s:StashList_GetStash : Get the stash under the cursor.   {{{2
"
" Parameters:
"   -
" Returns:
"   <stash-name> - the name of the stash (string)
"
" If the name could not be obtained returns an empty string.
"-------------------------------------------------------------------------------
"
function! s:StashList_GetStash()
	"
	let line = getline('.')
	let name = matchstr ( line, '^stash@{\d\+}' )
	"
	return name
	"
endfunction    " ----------  end of function s:StashList_GetStash  ----------
" }}}2
"-------------------------------------------------------------------------------
"
function! GitS_StashList( action, ... )
	"
	let update_only = 0
	let param = ''
	"
	if a:action == 'help'
		let txt  = s:HelpTxtStd."\n\n"
		let txt .= "sh      : show the stash under the cursor\n"
		let txt .= "sp      : show the stash in patch form\n"
		let txt .= "\n"
		let txt .= "sa      : save with a message\n"
		let txt .= "pu      : create a new stash (push)\n"
		let txt .= "\n"
		let txt .= "stash under cursor ...\n"
		let txt .= "ap      : apply\n"
		let txt .= "po      : pop\n"
		let txt .= "dr      : drop\n"
		let txt .= "br      : create and checkout a new branch\n"
		echo txt
		return
	elseif a:action == 'quit'
		close
		return
	elseif a:action == 'update'
		"
		let update_only = a:0 == 0
		"
		if update_only      | " run again with old parameters
		elseif empty( a:1 ) | let param = ''
		else                | let param = a:1
		endif
		"
	elseif -1 != index ( [ 'save', 'save-msg' ], a:action )
		"
		if a:action == 'save'
			call GitS_Stash( '', '' )
		elseif a:action == 'save-msg'
			return s:AssembleCmdLine ( ':GitStash save "', '"' )
		endif
		"
		return
	elseif -1 != index ( [ 'show', 'show-patch', 'apply', 'drop', 'pop', 'branch' ], a:action )
		"
		let s_name = s:StashList_GetStash ()
		"
		if s_name == ''
			return s:ErrorMsg ( 'No stash under the cursor.' )
		endif
		"
		if a:action == 'show'
			call GitS_Stash( 'show '.shellescape(s_name), '' )
		elseif a:action == 'show-patch'
			call GitS_Stash( 'show -p '.shellescape(s_name), '' )
		elseif a:action == 'apply'
			call GitS_Stash( 'apply '.shellescape(s_name), 'c' )
		elseif a:action == 'drop'
			call GitS_Stash( 'drop '.shellescape(s_name), 'c' )
		elseif a:action == 'pop'
			call GitS_Stash( 'pop '.shellescape(s_name), 'c' )
		elseif a:action == 'branch'
			return s:AssembleCmdLine ( ':GitStash branch ', ' '.shellescape(s_name) )
		endif
		"
		return
	else
		echoerr 'Unknown action "'.a:action.'".'
		return
	endif
	"
	let buf = s:CheckCWD ()
	"
	if s:OpenGitBuffer ( 'Git - stash list' )
		"
		let b:GitSupport_StashListFlag = 1
		"
		setlocal filetype=gitslog
		"
		exe 'nnoremap          <buffer> <S-F1> :call GitS_StashList("help")<CR>'
		exe 'nnoremap <silent> <buffer> q      :call GitS_StashList("quit")<CR>'
		exe 'nnoremap <silent> <buffer> u      :call GitS_StashList("update")<CR>'
		"
		exe 'nnoremap <silent> <buffer> sh     :call GitS_StashList("show")<CR>'
		exe 'nnoremap <silent> <buffer> sp     :call GitS_StashList("show-patch")<CR>'
		"
		exe 'nnoremap <expr>   <buffer> sa     GitS_StashList("save-msg")'
		exe 'nnoremap <silent> <buffer> pu     :call GitS_StashList("save")<CR>'
		"
		exe 'nnoremap <silent> <buffer> ap     :call GitS_StashList("apply")<CR>'
		exe 'nnoremap <silent> <buffer> dr     :call GitS_StashList("drop")<CR>'
		exe 'nnoremap <silent> <buffer> po     :call GitS_StashList("pop")<CR>'
		exe 'nnoremap <expr>   <buffer> br     GitS_StashList("branch")'
	endif
	"
	call s:ChangeCWD ( buf )
	"
	if update_only
		let param = b:GitSupport_Param
	else
		let b:GitSupport_Param = param
	endif
	"
	let cmd = s:Git_Executable.' stash '.param
	"
	call s:UpdateGitBuffer ( cmd, update_only )
	"
endfunction    " ----------  end of function GitS_StashList  ----------
"
"-------------------------------------------------------------------------------
" GitS_StashShow : execute 'git stash show ...'   {{{1
"-------------------------------------------------------------------------------
"
function! GitS_StashShow( action, ... )
	"
	let update_only = 0
	let param = ''
	"
	if a:action == 'help'
		echo s:HelpTxtStdNoUpdate
		return
	elseif a:action == 'quit'
		close
		return
	elseif a:action == 'update'
		"
		let update_only = a:0 == 0
		"
		if update_only      | " run again with old parameters
		elseif empty( a:1 ) | let param = ''
		else                | let param = a:1
		endif
		"
	else
		echoerr 'Unknown action "'.a:action.'".'
		return
	endif
	"
	let buf = s:CheckCWD ()
	"
	if s:OpenGitBuffer ( 'Git - stash show' )
		"
		let b:GitSupport_StashShowFlag = 1
		"
		setlocal filetype=gitsdiff
		"
		exe 'nnoremap          <buffer> <S-F1> :call GitS_StashShow("help")<CR>'
		exe 'nnoremap <silent> <buffer> q      :call GitS_StashShow("quit")<CR>'
	endif
	"
	call s:ChangeCWD ( buf )
	"
	if update_only
		let param = b:GitSupport_Param
	else
		let b:GitSupport_Param = param
	endif
	"
	let cmd = s:Git_Executable.' stash '.param
	"
	call s:UpdateGitBuffer ( cmd, update_only )
	"
endfunction    " ----------  end of function GitS_StashShow  ----------
"
"-------------------------------------------------------------------------------
" GitS_Status : execute 'git status'   {{{1
"-------------------------------------------------------------------------------
"
"-------------------------------------------------------------------------------
" s:Status_SectionCodes   {{{2
"-------------------------------------------------------------------------------
"
let s:Status_SectionCodes = {
			\ 'b': 'staged/modified',
			\ 's': 'staged',
			\ 'm': 'modified',
			\ 'u': 'untracked',
			\ 'i': 'ignored',
			\ 'c': 'conflict',
			\ 'd': 'diff',
			\ }
"
"-------------------------------------------------------------------------------
" s:Status_GetFile : Get the file under the cursor and its status.   {{{2
"
" Parameters:
"   -
" Returns:
"   [ <section-code>, <file-status>, <file-name> ] - data (list: 3x string)
"     or
"   [ <section-code>, <file-status>, <old-name>, <new-name> ] - data (list: 4x string)
"
" The entries are as follows:
"   section code - one character encoding the section the file was found in,
"                  use 's:Status_SectionCodes' to decode the meaning (string)
"   file status  - status of the file, see below (string)
"   file name    - name of the file under the cursor (string)
"
" Status:
" - "new file"
" - "modified"
" - "deleted"
" - "renamed"
" - "conflict"
" - one of the two-letter status codes of "git status --short"
"
" In case of an error, the list contains to empty strings and an error message:
"   [ '', '', <error-message> ]
"-------------------------------------------------------------------------------
"
function! s:Status_GetFile()
	"
	let f_name   = ''
	let f_new    = ''
	let f_status = ''
	let s_code   = ''
	"
	if b:GitSupport_ShortOption
		"
		" short output
		"
		let line = getline('.')
		"
		if line =~ '^##'
			return [ '', '', 'No file under the cursor.' ]
		elseif line =~ '^\%([MARC][MD]\|DM\)\s'
			let s_code = 'b'
		elseif line =~ '^[MARCD] \s'
			let s_code = 's'
		elseif line =~ '^ [MD]\s'
			let s_code = 'm'
		elseif line =~ '^??\s'
			let s_code = 'u'
		elseif line =~ '^!!\s'
			let s_code = 'i'
		elseif line =~ '^\%(AA\|DD\|[AD]U\|U[ADU]\)\s'
			let s_code = 'c'
		else
			return [ '', '', 'Unknown section, aborting.' ]
		endif
		"
		let [ f_status, f_name ] = matchlist( line, '^\(..\)\s\(.*\)' )[1:2]
		"
	elseif ! s:HasStatus185Format
		"
		" long output (prior to 1.8.5)
		"
		let c_line = getline('.')                   " line under the cursor
		let c_pos  = line('.')                      " line number
		let h_pos  = c_pos                          " header line number
		let s_head = ''                             " header line
		"
		if c_line =~ '^#'
			"
			let h_pos = search ( '^# [[:alnum:][:space:]]\+:$', 'bcnW' )
			"
			" find header
			if h_pos > 0
				let s_head = matchstr( getline(h_pos), '^# \zs[[:alnum:][:space:]]\+\ze:$' )
			else
				return [ '', '', 'Not in any section.' ]
			endif
			"
			" which header?
			if s_head == 'Changes to be committed'
				let s_code = 's'
			elseif s_head == 'Changed but not updated' || s_head == 'Changes not staged for commit'
				let s_code = 'm'
			elseif s_head == 'Untracked files'
				let s_code = 'u'
			elseif s_head == 'Ignored files'
				let s_code = 'i'
			elseif s_head == 'Unmerged paths'
				let s_code = 'c'
			else
				return [ '', '', 'Unknown section "'.s_head.'", aborting.' ]
			endif
			"
			" get the filename
			if s_code =~ '[smc]'
				let mlist = matchlist( c_line, '^#\t\([[:alnum:][:space:]]\+\):\s\+\(\S.*\)$' )
			else
				let mlist = matchlist( c_line, '^#\t\(\)\(\S.*\)$' )
			endif
			"
			" check the filename
			if empty( mlist )
				return [ '', '', 'No file under the cursor.' ]
			endif
			"
			let [ f_status, f_name ] = mlist[1:2]
			"
			if s_code == 'c'
				let f_status = 'conflict'
			endif
			"
		elseif b:GitSupport_VerboseOption == 1
			"
	 		let [ f_name, f_line, f_col ] = s:Diff_GetFile ()
			"
			if f_name == ''
				return [ '', '', 'No file under the cursor.' ]
			else
				let base = s:GitRepoDir()
				" could not get top-level?
				if base == ''
					return [ '', '', 'could not obtain the top-level directory' ]
				endif
				" :TODO:17.01.2014 14:42:WM: might be "new file", "deleted"?
				let f_name   = base.'/'.f_name
				let f_status = 'modified'
				let s_code   = 'd'
			endif
		endif
		"
	else
		"
		" long output (1.8.5 and after)
		"
		" :TODO:08.05.2014 09:55:WM: with a few modifications, we can use this for output prior to 1.8.5 as well
		"
		let c_line = getline('.')                   " line under the cursor
		let c_pos  = line('.')                      " line number
		let h_line = ''                             " header line
		let h_pos  = c_pos                          " header line number
		"
		" find header (including "diff" and "@@")
		while h_pos > 0
			"
			let h_line = matchstr( getline(h_pos), '^\(\u[[:alnum:][:space:]]*:\_$\|diff\|@@\)' )
			"
			if ! empty( h_line )
				break
			endif
			"
			let h_pos -= 1
		endwhile
		"
		let h_line = substitute ( h_line, ':$', '', '' )
		"
		if h_line !~ '^diff' && h_line !~ '^@@'
			"
			" which header?
			if h_line == ''
				return [ '', '', 'Not in any section.' ]
			elseif h_line == 'Changes to be committed'
				let s_code = 's'
			elseif h_line == 'Changed but not updated' || h_line == 'Changes not staged for commit'
				let s_code = 'm'
			elseif h_line == 'Untracked files'
				let s_code = 'u'
			elseif h_line == 'Ignored files'
				let s_code = 'i'
			elseif h_line == 'Unmerged paths'
				let s_code = 'c'
			else
				return [ '', '', 'Unknown section "'.h_line.'", aborting.' ]
			endif
			"
			" get the filename
			if s_code =~ '[smc]'
				let mlist = matchlist( c_line, '^\t\([[:alnum:][:space:]]\+\):\s\+\(\S.*\)$' )
			else
				let mlist = matchlist( c_line, '^\t\(\)\(\S.*\)$' )
			endif
			"
			" check the filename
			if empty( mlist )
				return [ '', '', 'No file under the cursor.' ]
			endif
			"
			let [ f_status, f_name ] = mlist[1:2]
			"
			if s_code == 'c'
				let f_status = 'conflict'
			endif
			"
		elseif b:GitSupport_VerboseOption == 1
			"
			" diff output
			"
			let [ f_name, f_line, f_col ] = s:Diff_GetFile ()
			"
			if f_name == ''
				return [ '', '', 'No file under the cursor.' ]
			else
				let base = s:GitRepoDir()
				" could not get top-level?
				if base == ''
					return [ '', '', 'could not obtain the top-level directory' ]
				endif
				" :TODO:17.01.2014 14:42:WM: might be "new file", "deleted"?
				let f_name   = base.'/'.f_name
				let f_status = 'modified'
				let s_code   = 'd'
			endif
		endif
		"
	endif
	"
	if f_status == 'renamed' || f_status =~ '^R'
		let mlist = matchlist( f_name, '^\(.*\) -> \(.*\)$' )
		"
		" check the filename
		if empty( mlist )
			return [ '', '', 'Could not correctly detect the rename.' ]
		endif
		"
		let [ f_name, f_new ] = mlist[1:2]
	endif
	"
	if f_name =~ '^".\+"$'
		let f_name = substitute ( f_name, '\_^"\|"\_$', '', 'g' )
		let f_name = substitute ( f_name, '\\\(.\)', '\1', 'g' )
	endif
	"
	if f_new == ''
		return [ s_code, f_status, f_name ]
	else
		return [ s_code, f_status, f_name, f_new ]
	endif
	"
endfunction    " ----------  end of function s:Status_GetFile  ----------
"
"-------------------------------------------------------------------------------
" s:Status_FileAction : Execute a command for the file under the cursor.   {{{2
"
" Parameters:
"   action - the action to perform, see below (string)
" Returns:
"   success - true, if the command was run successfully (integer)
"
" Uses 's:Status_GetFile' to obtain the section and file under the cursor. Then
" the action is performed, if allowed for this section. The actions are named
" for Git commands, except for "edit" (ckout = checkout):
"
"    section / action
"                  | edit  | diff  log   | add   ckout reset rm    | del
"  staged    (b/s) |  x    |  x     x    |  -     -     x     -    |  -
"  modified  (b/m) |  x    |  x     x    |  x     x     -     ?    |  -
"  untracked (u)   |  x    |  -     -    |  x     -     -     -    |  x
"  ignored   (i)   |  x    |  -     -    |  x     -     -     -    |  x
"  unmerged  (c)   |  x    |  x     x    |  x     -     x     -    |  -
"  diff      (d)   |  x    |  x     x    |  -     -     x     -    |  -
"
"  in section 'staged'   : action 'diff' may behave differently
"  in section 'modified' : action 'rm' only for status 'deleted'
"-------------------------------------------------------------------------------
"
function! s:Status_FileAction( action )
	"
	" the file under the cursor
	let fileinfo = s:Status_GetFile()
	"
	if len ( fileinfo ) == 3
		let [ s_code, f_status, f_name_old ] = fileinfo
		let f_name_new = f_name_old
	else
		let [ s_code, f_status, f_name_old, f_name_new ] = fileinfo
	endif
	"
	if s_code == ''
		" in this case 'f_name_old' contains the error message
		call s:ErrorMsg ( f_name_old )
		return 0
	endif
	"
	if a:action == 'edit'
		"
		" any section, action "edit"
		call s:OpenFile( f_name_new )
		"
	elseif s_code == 's' && ( a:action == 'diff' || a:action == 'diff-word' )
		"
		" section "staged", action "diff"
		"
		if a:action == 'diff' | let mode = 'update'
		else                  | let mode = 'color-words' | endif
		"
		if g:Git_StatusStagedOpenDiff == 'cached'
			let which = '--cached '
		elseif g:Git_StatusStagedOpenDiff == 'head'
			let which = 'HEAD '
		else
			let which = ''
		endif
		"
		if f_name_new == f_name_old
			call GitS_Diff( mode, which.'-- '.shellescape( f_name_old ) )
		else
			call GitS_Diff( mode, '--find-renames '.which.'-- '.shellescape( f_name_old ).' '.shellescape( f_name_new ) )
		endif
		"
	elseif s_code =~ '[bmcd]' && ( a:action == 'diff' || a:action == 'diff-word' )
		"
		" section "modified", "conflict" or "diff", action "diff"
		" (this is also called for section "both" in short status output)
		"
		if a:action == 'diff' | let mode = 'update'
		else                  | let mode = 'color-words' | endif
		"
		call GitS_Diff( mode, '-- '.shellescape( f_name_new ) )
		"
	elseif s_code =~ '[bsmcd]' && a:action == 'log'
		"
		" section "staged", "modified", "conflict" or "diff", action "log"
		call GitS_Log( 'update', '--stat -- '.shellescape( f_name_old ) )
		"
	elseif s_code == 'i' && a:action == 'add'
		"
		" section "ignored", action "add"
		if s:Question( 'Add ignored file "'.f_name_old.'"?', 'warning' ) == 1
			call GitS_Add( '-- '.shellescape( f_name_old ), 'f' )
			return 1
		endif
		"
	elseif s_code == 'u' && a:action == 'add'
		"
		" section "untracked", action "add"
		if s:Question( 'Add untracked file "'.f_name_old.'"?' ) == 1
			call GitS_Add( '-- '.shellescape( f_name_old ), '' )
			return 1
		endif
		"
	elseif s_code =~ '[bm]' && a:action == 'add'
		"
		" section "modified", action "add"
		"
		if f_status == 'modified' || f_status =~ '^.M$'
			" add a modified file?
			if s:Question( 'Add file "'.f_name_old.'"?' ) == 1
				call GitS_Add( '-- '.shellescape( f_name_old ), '' )
				return 1
			endif
		elseif f_status == 'deleted' || f_status =~ '^.D$'
			" add a deleted file? -> remove it?
			if s:Question( 'Remove file "'.f_name_old.'"?' ) == 1
				call GitS_Remove( '-- '.shellescape( f_name_old ), '' )
				return 1
			endif
		else
			call s:ErrorMsg ( 'Adding not implemented yet for file status "'.f_status.'".' )
		endif
		"
	elseif s_code =~ '[bm]' && a:action == 'add-patch'
		"
		" section "modified", action "add-patch"
		"
		if f_status == 'modified' || f_status =~ '^.M$'
			call GitS_GitBash( 'add -p -- '.shellescape( f_name_old ) )
			return 1
		else
			call s:ErrorMsg ( 'No "add -p" for file status "'.f_status.'".' )
		endif
		"
	elseif s_code =~ '[bm]' && a:action == 'checkout'
		"
		" section "modified", action "checkout"
		"
		if f_status == 'modified' || f_status == 'deleted' || f_status =~ '^.[MD]$'
			" check out a modified or deleted file?
			if s:Question( 'Checkout file "'.f_name_old.'"?', 'warning' ) == 1
				call GitS_Checkout( '-- '.shellescape( f_name_old ), '' )
				return 1
			endif
		else
			call s:ErrorMsg ( 'Checking out not implemented yet for file status "'.f_status.'".' )
		endif
		"
	elseif s_code =~ '[bsm]' && a:action == 'checkout-head'
		"
		" section "staged", "modified" or "both", action "checkout-head"
		"
		if f_status == 'modified' || f_status == 'deleted' || f_status =~ '^[MAD].$' || f_status =~ '^.[MD]$'
			" check out a modified or deleted file?
			if s:Question( 'Checkout file "'.f_name_old.'" and change both the index and working tree copy?', 'warning' ) == 1
				call GitS_Checkout( 'HEAD -- '.shellescape( f_name_old ), '' )
				return 1
			endif
		else
			call s:ErrorMsg ( 'Checking out the HEAD not implemented yet for file status "'.f_status.'".' )
		endif
		"
	elseif s_code =~ '[bm]' && a:action == 'checkout-patch'
		"
		" section "modified", action "checkout-patch"
		"
		if f_status == 'modified' || f_status =~ '^.M$'
			call GitS_GitBash( 'checkout -p -- '.shellescape( f_name_old ) )
			return 1
		else
			call s:ErrorMsg ( 'No "checkout -p" for file status "'.f_status.'".' )
		endif
		"
	elseif s_code =~ '[bsd]' && a:action == 'reset'
		"
		" section "staged" or "diff", action "reset"
		"
		if f_status == 'modified' || f_status == 'new file' || f_status == 'deleted' || f_status =~ '^[MADC].$'
			" reset a modified, new or deleted file?
			if s:Question( 'Reset file "'.f_name_old.'"?' ) == 1
				call GitS_Reset( '-q -- '.shellescape( f_name_old ), '' )   " use '-q' to prevent return value '1' and suppress output
				return 1
			endif
		elseif f_status == 'renamed' || f_status =~ '^R.$'
			" reset a modified, new or deleted file?
			if s:Question( 'Reset the old file "'.f_name_old.'"?' ) == 1
				call GitS_Reset( '-q -- '.shellescape( f_name_old ), '' )   " use '-q' to prevent return value '1' and suppress output
			endif
			if s:Question( 'Reset the new file "'.f_name_new.'"?' ) == 1
				call GitS_Reset( '-q -- '.shellescape( f_name_new ), '' )   " use '-q' to prevent return value '1' and suppress output
			endif
			if s:Question( 'Undo the rename?' ) == 1
				call rename( f_name_new, f_name_old )
			endif
			return 1
		else
			call s:ErrorMsg ( 'Reseting not implemented yet for file status "'.f_status.'".' )
		endif
		"
	elseif s_code =~ '[bs]' && a:action == 'reset-patch'
		"
		" section "staged", action "reset-patch"
		"
		if f_status == 'modified' || f_status =~ '^M.$'
			call GitS_GitBash( 'reset -p -- '.shellescape( f_name_old ) )
			return 1
		else
			call s:ErrorMsg ( 'No "reset -p" for file status "'.f_status.'".' )
		endif
		"
	elseif s_code =~ 'c' && a:action == 'add'
		"
		" section "unmerged", action "add"
		if s:Question( 'Add unmerged file "'.f_name_old.'"?' ) == 1
			call GitS_Add( '-- '.shellescape( f_name_old ), '' )
			return 1
		endif
		"
	elseif s_code =~ 'c' && a:action == 'reset'
		"
		" section "unmerged", action "reset"
		if s:Question( 'Reset unmerged file "'.f_name_old.'"?' ) == 1
			call GitS_Reset( '-- '.shellescape( f_name_old ), '' )
			return 1
		endif
		"
	elseif s_code =~ '[ui]' && a:action == 'delete'
		"
		" section "untracked" or "ignored", action "delete"
		"
		if ! exists( '*delete' )
			call s:ErrorMsg ( 'Can not delete files from harddisk.' )
		elseif s:Question( 'Delete file "'.f_name_old.'" from harddisk?' ) == 1
			return delete ( f_name_old ) == 0
		endif
		"
	else
		"
		" action not implemented for section
		"
		call s:ErrorMsg ( 'Can not execute "'.a:action.'" in section "'.s:Status_SectionCodes[s_code].'".' )
		"
	endif
	"
	return 0
	"
endfunction    " ----------  end of function s:Status_FileAction  ----------
" }}}2
"-------------------------------------------------------------------------------
"
"-------------------------------------------------------------------------------
" GitS_Status : execute 'git status'
"-------------------------------------------------------------------------------
"
function! GitS_Status( action, ... )
	"
	let update_only = 0
	let limited_dir = ''
	"
	if a:action == 'help'
		let txt  = s:HelpTxtStd."\n\n"
		let txt .= "toggle ...\n"
		let txt .= "i       : show ignored files\n"
		let txt .= "s       : short output\n"
		let txt .= "v       : verbose output\n"
		let txt .= "\n"
		let txt .= "file under cursor ...\n"
		if s:EnabledGitBash
			let txt .= "a / ap  : add / add --patch\n"
		else
			let txt .= "a       : add\n"
		endif
		if s:EnabledGitBash
			let txt .= "c / cp  : checkout / checkout --patch\n"
		else
			let txt .= "c       : checkout\n"
		endif
		let txt .= "ch      : checkout HEAD\n"
		let txt .= "od      : open diff\n"
		let txt .= "of / oj : open file (edit)\n"
		let txt .= "ol      : open log\n"
		if s:EnabledGitBash
			let txt .= "r / rp  : reset / reset --patch\n"
		else
			let txt .= "r       : reset\n"
		endif
		let txt .= "D       : delete from file system (only untracked files)\n"
		let txt .= "\n"
		let txt .= "For settings see:\n"
		let txt .= "  :help g:Git_StatusStagedOpenDiff"
		echo txt
		return
	elseif a:action == 'quit'
		close
		return
	elseif a:action == 'update'
		let update_only = a:0 == 0
		"
		if update_only
			" run again with old parameters
		else
			let limited_dir = a:1
		endif
		"
	elseif a:action == 'ignored'
		if ! s:HasStatusIgnore
			return s:ErrorMsg ( '"show ignored files" not available in Git version '.s:GitVersion.'.' )
		endif
	elseif a:action =~ '\<\%(short\|verbose\)\>'
		" noop
	elseif -1 != index ( [ 'add', 'add-patch', 'checkout', 'checkout-head', 'checkout-patch', 'diff', 'diff-word', 'edit', 'log', 'reset', 'reset-patch', 'delete' ], a:action )
		"
 		call s:ChangeCWD ()
		"
		if s:Status_FileAction ( a:action )
			call GitS_Status( 'update' )
		endif
		"
		return
	else
		echoerr 'Unknown action "'.a:action.'".'
		return
	endif
	"
	let buf = s:CheckCWD ()
	"
	" if a directory has been given, set the working directory accordingly
	if ! update_only
		let relative_paths = s:GitGetConfig ( 'status.relativePaths' )
		"
		" use the top-level directory
		if relative_paths == 'false' || limited_dir == '/'
			let base = s:GitRepoDir()
			"
			" could not get top-level?
			if base == '' | return | endif
			"
			let buf[1] = base
		endif
		"
		if limited_dir == '/'
			" we use the top-level directory as the cwd, no further path required
			let limited_dir = ''
		elseif relative_paths == 'false' && limited_dir != ''
			" we need the limited_dir relative to the top-level directory
			silent exe 'lchdir '.fnameescape( limited_dir )
			let [ sh_err, limited_dir ] = s:StandardRun ( 'rev-parse', '--show-prefix', 't' )
			silent exe 'lchdir -'
		elseif relative_paths != 'false' && limited_dir != ''
			" we set the cwd and restrict the output to it
			let buf[1] = fnamemodify( limited_dir, ':p' )
			let limited_dir = '.'
		endif
	endif
	"
	if s:OpenGitBuffer ( 'Git - status' )
		"
		let b:GitSupport_StatusFlag = 1
		let b:GitSupport_StatusLimitedDir   = ''
		let b:GitSupport_StatusRelativePath = s:GitGetConfig ( 'status.relativePaths' )
		let b:GitSupport_IgnoredOption    = 0
		let b:GitSupport_ShortOption      = 0
		let b:GitSupport_VerboseOption    = 0
		"
		setlocal filetype=gitsstatus
		setlocal foldtext=GitS_FoldLog()
		"
		exe 'nnoremap          <buffer> <S-F1> :call GitS_Status("help")<CR>'
		exe 'nnoremap <silent> <buffer> q      :call GitS_Status("quit")<CR>'
		exe 'nnoremap <silent> <buffer> u      :call GitS_Status("update")<CR>'
		"
		exe 'nnoremap <silent> <buffer> i      :call GitS_Status("ignored")<CR>'
		exe 'nnoremap <silent> <buffer> s      :call GitS_Status("short")<CR>'
		exe 'nnoremap <silent> <buffer> v      :call GitS_Status("verbose")<CR>'
		"
		exe 'nnoremap <silent> <buffer> a      :call GitS_Status("add")<CR>'
		exe 'nnoremap <silent> <buffer> c      :call GitS_Status("checkout")<CR>'
		exe 'nnoremap <silent> <buffer> ch     :call GitS_Status("checkout-head")<CR>'
		exe 'nnoremap <silent> <buffer> od     :call GitS_Status("diff")<CR>'
		exe 'nnoremap <silent> <buffer> ow     :call GitS_Status("diff-word")<CR>'
		exe 'nnoremap <silent> <buffer> of     :call GitS_Status("edit")<CR>'
		exe 'nnoremap <silent> <buffer> oj     :call GitS_Status("edit")<CR>'
		exe 'nnoremap <silent> <buffer> ol     :call GitS_Status("log")<CR>'
		exe 'nnoremap <silent> <buffer> r      :call GitS_Status("reset")<CR>'
		exe 'nnoremap <silent> <buffer> D      :call GitS_Status("delete")<CR>'
		"
		if s:EnabledGitBash
			exe 'nnoremap <silent> <buffer> ap     :call GitS_Status("add-patch")<CR>'
			exe 'nnoremap <silent> <buffer> cp     :call GitS_Status("checkout-patch")<CR>'
			exe 'nnoremap <silent> <buffer> rp     :call GitS_Status("reset-patch")<CR>'
		endif
		"
	endif
	"
	call s:ChangeCWD ( buf )
	"
	if a:action == 'update'
		"
		if update_only
			let limited_dir = b:GitSupport_StatusLimitedDir
		else
			let b:GitSupport_StatusLimitedDir = limited_dir
		endif
		"
	elseif a:action == 'ignored'
		let b:GitSupport_IgnoredOption = ( b:GitSupport_IgnoredOption + 1 ) % 2
	elseif a:action == 'short'
		if b:GitSupport_ShortOption == 0
			" switch to short
			let b:GitSupport_ShortOption = 1
			setlocal filetype=gitssshort
		else
			" switch to normal
			let b:GitSupport_ShortOption = 0
			setlocal filetype=gitsstatus
		endif
	elseif a:action == 'verbose'
		let b:GitSupport_VerboseOption = ( b:GitSupport_VerboseOption + 1 ) % 2
	endif
	"
	let cmd = s:Git_Executable.' status'
	"
	if limited_dir != ''
		let cmd .= ' '.shellescape( limited_dir )
	endif
	"
	if b:GitSupport_IgnoredOption == 1 &&   s:HasStatusIgnore | let cmd .= ' --ignored'        | endif
	if b:GitSupport_ShortOption   == 1 &&   s:HasStatusBranch | let cmd .= ' --short --branch' | endif
	if b:GitSupport_ShortOption   == 1 && ! s:HasStatusBranch | let cmd .= ' --short'          | endif
	if b:GitSupport_VerboseOption == 1                        | let cmd .= ' --verbose'        | endif
	"
	call s:UpdateGitBuffer ( cmd, update_only )
	"
endfunction    " ----------  end of function GitS_Status  ----------
"
"-------------------------------------------------------------------------------
" GitS_Tag : execute 'git tag ...'   {{{1
"
" Flags: -> s:StandardRun
"-------------------------------------------------------------------------------
"
function! GitS_Tag( param, flags )
	"
	let args = s:GitCmdLineArgs ( a:param )
	"
	if empty ( a:param )
				\ || index ( args, '-l', 1 ) != -1
				\ || index ( args, '--list', 1 ) != -1
				\ || index ( args, '--contains', 1 ) != -1
				\ || match ( args, '^-n\d\?', 1 ) != -1
		call GitS_TagList ( 'update', a:param )
	else
		return s:StandardRun ( 'tag', a:param, a:flags, 'c' )
	endif
	"
	"
endfunction    " ----------  end of function GitS_Tag  ----------
"
"-------------------------------------------------------------------------------
" GitS_TagList : execute 'git tag' (list tags)   {{{1
"-------------------------------------------------------------------------------
"
"-------------------------------------------------------------------------------
" s:TagList_GetTag : Get the tag under the cursor.   {{{2
"
" Parameters:
"   -
" Returns:
"   <tag-name> - the name of the tag (string)
"
" If the name could not be obtained returns an empty string.
"-------------------------------------------------------------------------------
"
function! s:TagList_GetTag()
	"
	let t_pos = search ( '\m\_^\S', 'bcnW' )      " the position of the tag name
	"
	if t_pos == 0
		return ''
	endif
	"
	return matchstr ( getline(t_pos), '^\S\+' )
	"
endfunction    " ----------  end of function s:TagList_GetTag  ----------
" }}}2
"-------------------------------------------------------------------------------
"
function! GitS_TagList( action, ... )
	"
	let update_only = 0
	let param = ''
	"
	if a:action == 'help'
		let txt  = s:HelpTxtStd."\n\n"
		let txt .= "tag under cursor ...\n"
		let txt .= "ch      : checkout\n"
		let txt .= "cr      : use as starting point for creating a new branch\n"
		let txt .= "de      : delete\n"
		let txt .= "me      : merge with current branch\n"
		let txt .= "sh      : show the tag\n"
		let txt .= "cs      : show the commit\n"
		echo txt
		return
	elseif a:action == 'quit'
		close
		return
	elseif a:action == 'update'
		"
		let update_only = a:0 == 0
		"
		if update_only      | " run again with old parameters
		elseif empty( a:1 ) | let param = ''
		else                | let param = a:1
		endif
		"
	elseif -1 != index ( [ 'checkout', 'create', 'delete', 'merge', 'show-tag', 'show-commit' ], a:action )
		"
		let t_name = s:TagList_GetTag ()
		"
		if t_name == ''
			return s:ErrorMsg ( 'No tag under the cursor.' )
		endif
		"
		if a:action == 'checkout'
			call GitS_Checkout( shellescape(t_name), 'c' )
		elseif a:action == 'create'
			return s:AssembleCmdLine ( ':GitBranch ', ' '.t_name )
		elseif a:action == 'delete'
			call GitS_Tag( '-d '.shellescape(t_name), 'c' )
		elseif a:action == 'merge'
			call GitS_Merge( 'direct', shellescape(t_name), 'c' )
		elseif a:action == 'show-tag'
			call GitS_Show( 'update', shellescape(t_name), '' )
		elseif a:action == 'show-commit'
			call GitS_Show( 'update', shellescape(t_name).'^{commit}', '' )
		endif
		"
		return
	else
		echoerr 'Unknown action "'.a:action.'".'
		return
	endif
	"
	let buf = s:CheckCWD ()
	"
	if s:OpenGitBuffer ( 'Git - tag' )
		"
		let b:GitSupport_TagListFlag = 1
		"
" 		setlocal filetype=gitslog
		"
		exe 'nnoremap          <buffer> <S-F1> :call GitS_TagList("help")<CR>'
		exe 'nnoremap <silent> <buffer> q      :call GitS_TagList("quit")<CR>'
		exe 'nnoremap <silent> <buffer> u      :call GitS_TagList("update")<CR>'
		"
		exe 'nnoremap <silent> <buffer> ch     :call GitS_TagList("checkout")<CR>'
		exe 'nnoremap <expr>   <buffer> cr     GitS_TagList("create")'
		exe 'nnoremap <silent> <buffer> de     :call GitS_TagList("delete")<CR>'
		exe 'nnoremap <silent> <buffer> me     :call GitS_TagList("merge")<CR>'
		exe 'nnoremap <silent> <buffer> sh     :call GitS_TagList("show-tag")<CR>'
		exe 'nnoremap <silent> <buffer> cs     :call GitS_TagList("show-commit")<CR>'
	endif
	"
	call s:ChangeCWD ( buf )
	"
	if update_only
		let param = b:GitSupport_Param
	else
		let b:GitSupport_Param = param
	endif
	"
	let cmd = s:Git_Executable.' tag '.param
	"
	call s:UpdateGitBuffer ( cmd, update_only )
	"
endfunction    " ----------  end of function GitS_TagList  ----------
"
"-------------------------------------------------------------------------------
" GitS_GitK : execute 'gitk ...'   {{{1
"-------------------------------------------------------------------------------
"
function! GitS_GitK( param )
	"
	" :TODO:10.12.2013 20:14:WM: graphics available?
	if s:EnabledGitK == 0
		return s:ErrorMsg ( s:DisableGitKMessage, s:DisableGitKReason )
	elseif s:FoundGitKScript == 0
		return s:ErrorMsg ( s:DisableGitKMessage, s:GitKScriptReason )
	endif
	"
	let param = escape( a:param, '%#' )
	"
	if s:MSWIN
		" :TODO:02.01.2014 13:00:WM: Windows: try the shell command 'start'
		silent exe '!start '.s:Git_GitKExecutable.' '.s:Git_GitKScript.' '.param
	else
		silent exe '!'.s:Git_GitKExecutable.' '.s:Git_GitKScript.' '.param.' &'
	endif
	"
endfunction    " ----------  end of function GitS_GitK  ----------
"
"-------------------------------------------------------------------------------
" GitS_GitBash : execute 'xterm git ...' or "git bash"   {{{1
"-------------------------------------------------------------------------------
"
function! GitS_GitBash( param )
	"
	" :TODO:10.12.2013 20:14:WM: graphics available?
	if s:EnabledGitBash == 0
		return s:ErrorMsg ( s:DisableGitBashMessage, s:DisableGitBashReason )
	endif
	"
	let title = 'git '.matchstr( a:param, '\S\+' )
	let param = escape( a:param, '%#' )
	"
	if s:MSWIN && param =~ '^\s*$'
		" no parameters: start interactive mode in background
		silent exe '!start '.s:Git_GitBashExecutable.' --login -i'
	elseif s:MSWIN
		" otherwise: block editor and execute command
		silent exe '!'.s:Git_GitBashExecutable.' --login -c '.shellescape ( 'git '.param )
	else
		" UNIX: block editor and execute command, wait for confirmation afterwards
		silent exe '!'.s:Git_GitBashExecutable.' '.g:Xterm_Options
					\ .' -title '.shellescape( title )
					\ .' -e '.shellescape( s:Git_Executable.' '.param.' ; echo "" ; read -p "  ** PRESS ENTER **  " dummy ' )
	endif
	"
endfunction    " ----------  end of function GitS_GitBash  ----------
"
"-------------------------------------------------------------------------------
" GitS_GitEdit : edit a Git config file   {{{1
"-------------------------------------------------------------------------------
"
function! GitS_GitEdit( fileid )
	"
	let filename = ''
	"
	if a:fileid == 'config-global'
		let filename = expand ( '$HOME/.gitconfig' )
	elseif a:fileid == 'config-local'
		let filename = expand ( '$GIT_CONFIG' )
		if filename == '$GIT_CONFIG'
			let filename = s:GitRepoDir ( 'git/config' )
		endif
	elseif a:fileid == 'description'
		let filename = s:GitRepoDir ( 'git/description' )
	elseif a:fileid == 'hooks'
		let filename = s:GitRepoDir ( 'git/hooks/' )
	elseif a:fileid == 'ignore-global'
		let filename = s:GitGetConfig ( 'core.excludesfile' )
	elseif a:fileid == 'ignore-local'
		let filename = s:GitRepoDir ( 'top/.gitignore' )
	elseif a:fileid == 'ignore-private'
		let filename = s:GitRepoDir ( 'git/info/exclude' )
	elseif a:fileid == 'modules'
		let filename = s:GitRepoDir ( 'top/.gitmodules' )
	endif
	"
	if filename == ''
		call s:ErrorMsg ( 'No file with ID "'.a:fileid.'".' )
	else
		exe 'spl '.fnameescape( filename )
	endif
	"
endfunction    " ----------  end of function GitS_GitEdit  ----------
"
"-------------------------------------------------------------------------------
" GitS_PluginHelp : Plug-in help.   {{{1
"-------------------------------------------------------------------------------
"
function! GitS_PluginHelp( topic )
	try
		silent exe 'help '.a:topic
	catch
		exe 'helptags '.s:plugin_dir.'/doc'
		silent exe 'help '.a:topic
	endtry
endfunction    " ----------  end of function GitS_PluginHelp  ----------
"
"-------------------------------------------------------------------------------
" GitS_PluginSettings : Print the settings on the command line.   {{{1
"-------------------------------------------------------------------------------
"
function! GitS_PluginSettings( verbose )
	"
	if     s:MSWIN | let sys_name = 'Windows'
	elseif s:UNIX  | let sys_name = 'UNIX'
	else           | let sys_name = 'unknown' | endif
	"
	if s:Enabled | let git_e_status = ' (version '.s:GitVersion.')'
	else         | let git_e_status = ' (not executable)'
	endif
	let gitk_e_status  = s:EnabledGitK     ? '' : ' (not executable)'
	let gitk_s_status  = s:FoundGitKScript ? '' : ' (not found)'
	let gitbash_status = s:EnabledGitBash  ? '' : ' (not executable)'
	"
	let file_options_status = filereadable ( s:Git_CmdLineOptionsFile ) ? '' : ' (not readable)'
	"
	let	txt = " Git-Support settings\n\n"
				\ .'     plug-in installation :  '.s:installation.' on '.sys_name."\n"
				\ .'           git executable :  '.s:Git_Executable.git_e_status."\n"
				\ .'          gitk executable :  '.s:Git_GitKExecutable.gitk_e_status."\n"
	if ! empty ( s:Git_GitKScript )
		let txt .=
					\  '              gitk script :  '.s:Git_GitKScript.gitk_s_status."\n"
	endif
	let txt .=
				\  '      git bash executable :  '.s:Git_GitBashExecutable.gitbash_status."\n"
	if s:UNIX && a:verbose >= 1
		let txt .= '            xterm options :  "'.g:Xterm_Options."\"\n"
	endif
	if a:verbose >= 1
		let	txt .= "\n"
					\ .'             expand empty :  checkout: "'.g:Git_CheckoutExpandEmpty.'" ; diff: "'.g:Git_DiffExpandEmpty.'" ; reset: "'.g:Git_ResetExpandEmpty."\"\n"
					\ .'     open fold after jump :  "'.g:Git_OpenFoldAfterJump."\"\n"
					\ .'  status staged open diff :  "'.g:Git_StatusStagedOpenDiff."\"\n\n"
					\ .'    cmd-line options file :  '.s:Git_CmdLineOptionsFile.file_options_status."\n"
"					\ .'            commit editor :  "'.g:Git_Editor."\"\n"
	endif
	let txt .=
				\  "________________________________________________________________________________\n"
				\ ." Git-Support, Version ".g:GitSupport_Version." / Wolfgang Mehner / wolfgang-mehner@web.de\n\n"
	"
	if a:verbose == 2
		split GitSupport_Settings.txt
		put = txt
	else
		echo txt
	endif
endfunction    " ----------  end of function GitS_PluginSettings  ----------
"
"-------------------------------------------------------------------------------
" s:LoadCmdLineOptions : Load s:CmdLineOptions   {{{1
"-------------------------------------------------------------------------------
"
function! s:LoadCmdLineOptions ()
	"
	let s:CmdLineOptions = {}
	let current_list     = []
	"
	if ! filereadable ( s:Git_CmdLineOptionsFile )
		return
	endif
	"
	for line in readfile ( s:Git_CmdLineOptionsFile )
		let name = matchstr ( line, '^\s*\zs.*\S\ze\s*$' )
		"
		if line =~ '^\S'
			let current_list = []
			let s:CmdLineOptions[ name ] = current_list
		else
			call add ( current_list, name )
		endif
	endfor
endfunction    " ----------  end of function s:LoadCmdLineOptions  ----------
"
call s:LoadCmdLineOptions ()
"
"-------------------------------------------------------------------------------
" s:CmdLineComplete : Command line completion.   {{{1
"-------------------------------------------------------------------------------
"
function! s:CmdLineComplete ( mode, ... )
	"
	let forward = 1
	"
	if a:0 >= 1 && a:1 == 1
		let forward = 0
	endif
	"
	let cmdline = getcmdline()
	let cmdpos  = getcmdpos() - 1
	"
	let cmdline_tail = strpart ( cmdline, cmdpos )
	let cmdline_head = strpart ( cmdline, 0, cmdpos )
	"
	let idx = match ( cmdline_head, '[^[:blank:]:]*$' )
	"
	" prefixed by --option=
	if a:mode != 'command' && -1 != match ( strpart ( cmdline_head, idx ), '^--[^=]\+=' )
		let idx2 = matchend ( strpart ( cmdline_head, idx ), '^--[^=]\+=' )
		if idx2 >= 0
			let idx += idx2
		endif
	endif
	"
	" for a branch or tag, split at a ".." or "..."
	if a:mode == 'branch' || a:mode == 'tag'
		let idx2 = matchend ( strpart ( cmdline_head, idx ), '\.\.\.\?' )
		if idx2 >= 0
			let idx += idx2
		endif
	endif
	"
	let cmdline_pre = strpart ( cmdline_head, 0, idx )
	"
	" not a word, skip completion
	if idx < 0
		return cmdline_head.cmdline_tail
	endif
	"
	" s:vars initial if first time or changed cmdline
	if ! exists('b:GitSupport_NewCmdLine') || cmdline_head != b:GitSupport_NewCmdLine || a:mode != b:GitSupport_CurrentMode
		"
		let b:GitSupport_NewCmdLine  = ''
		let b:GitSupport_CurrentMode = a:mode
		"
		let b:GitSupport_WordPrefix = strpart ( cmdline_head, idx )
		let b:GitSupport_WordMatch  = escape ( b:GitSupport_WordPrefix, '\' )
		let b:GitSupport_WordList   = [ b:GitSupport_WordPrefix ]
		let b:GitSupport_WordIndex  = 0
		"
		if a:mode == 'branch'
			let [ suc, txt ] = s:StandardRun ( 'branch', '-a', 't' )
			"
			for part in split( txt, "\n" ) + [ 'HEAD', 'ORIG_HEAD', 'FETCH_HEAD', 'MERGE_HEAD' ]
				" remove leading whitespaces, "*" (current branch), and "remotes/"
				" remove trailing "-> ..." (as in "origin/HEAD -> origin/master")
				let branch = matchstr( part, '^[ *]*\%(remotes\/\)\?\zs.\{-}\ze\%(\s*->.*\)\?$' )
				if -1 != match( branch, '\V\^'.b:GitSupport_WordMatch )
					call add ( b:GitSupport_WordList, branch )
				endif
			endfor
		elseif a:mode == 'command'
			let suc      = 0                          " initialized variable 'suc' needed below
			let use_list = s:GitCommands
			let sub_cmd  = matchstr ( cmdline_pre,
						\       '\c\_^Git\%(!\|Run\|Buf\|Bash\)\?\s\+\zs[a-z\-]\+\ze\s'
						\ .'\|'.'\c\_^Git\zs[a-z]\+\ze\s' )
			"
			if sub_cmd != ''
				let sub_cmd = tolower ( sub_cmd )
				if has_key ( s:CmdLineOptions, sub_cmd )
					let use_list = get ( s:CmdLineOptions, sub_cmd, s:GitCommands )
				endif
			endif
				"
			for part in use_list
				if -1 != match( part, '\V\^'.b:GitSupport_WordMatch )
					call add ( b:GitSupport_WordList, part )
				endif
			endfor
		elseif a:mode == 'remote'
			let [ suc, txt ] = s:StandardRun ( 'remote', '', 't' )
			"
			for part in split( txt, "\n" )
				if -1 != match( part, '\V\^'.b:GitSupport_WordMatch )
					call add ( b:GitSupport_WordList, part )
				endif
			endfor
		elseif a:mode == 'tag'
			let [ suc, txt ] = s:StandardRun ( 'tag', '', 't' )
			"
			for part in split( txt, "\n" )
				if -1 != match( part, '\V\^'.b:GitSupport_WordMatch )
					call add ( b:GitSupport_WordList, part )
				endif
			endfor
		else
			return cmdline_head.cmdline_tail
		endif
		"
		if suc != 0
			return cmdline_head.cmdline_tail
		endif
		"
	endif
	"
	if forward
		let b:GitSupport_WordIndex = ( b:GitSupport_WordIndex + 1 ) % len( b:GitSupport_WordList )
	else
		let b:GitSupport_WordIndex = ( b:GitSupport_WordIndex - 1 + len( b:GitSupport_WordList ) ) % len( b:GitSupport_WordList )
	endif
	"
	let word = b:GitSupport_WordList[ b:GitSupport_WordIndex ]
	"
	" new cmdline
	let b:GitSupport_NewCmdLine = cmdline_pre.word
	"
	" overcome map silent
	" (silent map together with this trick seems to look prettier)
	call feedkeys(" \<bs>")
	"
	" set new cmdline cursor postion
	call setcmdpos ( len(b:GitSupport_NewCmdLine)+1 )
	"
	return b:GitSupport_NewCmdLine.cmdline_tail
	"
endfunction    " ----------  end of function s:CmdLineComplete  ----------
"
"-------------------------------------------------------------------------------
" s:InitMenus : Initialize menus.   {{{1
"-------------------------------------------------------------------------------
"
function! s:InitMenus()

	if ! has ( 'menu' )
		return
	endif

	let ahead = 'anoremenu '.s:Git_RootMenu.'.'

	exe ahead.'Git       :echo "This is a menu header!"<CR>'
	exe ahead.'-Sep00-   :'

	" Commands   {{{2
	let ahead = 'anoremenu '.s:Git_RootMenu.'.&git\ \.\.\..'
	let vhead = 'vnoremenu '.s:Git_RootMenu.'.&git\ \.\.\..'

	exe ahead.'Commands<TAB>Git :echo "This is a menu header!"<CR>'
	exe ahead.'-Sep00-          :'

	exe ahead.'&add<TAB>:GitAdd           :GitAdd<space>'
	exe ahead.'&blame<TAB>:GitBlame       :GitBlame<space>'
	exe vhead.'&blame<TAB>:GitBlame       :GitBlame<space>'
	exe ahead.'&branch<TAB>:GitBranch     :GitBranch<space>'
	exe ahead.'&checkout<TAB>:GitCheckout :GitCheckout<space>'
	exe ahead.'&commit<TAB>:GitCommit     :GitCommit<space>'
	exe ahead.'&diff<TAB>:GitDiff         :GitDiff<space>'
	exe ahead.'&fetch<TAB>:GitFetch       :GitFetch<space>'
	exe ahead.'&grep<TAB>:GitGrep         :GitGrep<space>'
	exe ahead.'&help<TAB>:GitHelp         :GitHelp<space>'
	exe ahead.'&log<TAB>:GitLog           :GitLog<space>'
	exe ahead.'&merge<TAB>:GitMerge       :GitMerge<space>'
	exe ahead.'&mv<TAB>:GitMv             :GitMv<space>'
	exe ahead.'&pull<TAB>:GitPull         :GitPull<space>'
	exe ahead.'&push<TAB>:GitPush         :GitPush<space>'
	exe ahead.'&remote<TAB>:GitRemote     :GitRemote<space>'
	exe ahead.'&rm<TAB>:GitRm             :GitRm<space>'
	exe ahead.'&reset<TAB>:GitReset       :GitReset<space>'
	exe ahead.'&show<TAB>:GitShow         :GitShow<space>'
	exe ahead.'&stash<TAB>:GitStash       :GitStash<space>'
	exe ahead.'&status<TAB>:GitStatus     :GitStatus<space>'
	exe ahead.'&tag<TAB>:GitTag           :GitTag<space>'

	exe ahead.'-Sep01-                      :'
	exe ahead.'run\ git&k<TAB>:GitK         :GitK<space>'
	exe ahead.'run\ git\ &bash<TAB>:GitBash :GitBash<space>'

	" Current File   {{{2
	let shead = 'anoremenu <silent> '.s:Git_RootMenu.'.&file.'
	let vhead = 'vnoremenu <silent> '.s:Git_RootMenu.'.&file.'

	exe shead.'Current\ File<TAB>Git :echo "This is a menu header!"<CR>'
	exe shead.'-Sep00-               :'

	exe shead.'&add<TAB>:GitAdd               :GitAdd -- %<CR>'
	exe shead.'&blame<TAB>:GitBlame           :GitBlame -- %<CR>'
	exe vhead.'&blame<TAB>:GitBlame           :GitBlame -- %<CR>'
	exe shead.'&checkout<TAB>:GitCheckout     :GitCheckout -- %<CR>'
	exe shead.'&diff<TAB>:GitDiff             :GitDiff -- %<CR>'
	exe shead.'&diff\ --cached<TAB>:GitDiff   :GitDiff --cached -- %<CR>'
	exe shead.'&log<TAB>:GitLog               :GitLog --stat -- %<CR>'
	exe shead.'r&m<TAB>:GitRm                 :GitRm -- %<CR>'
	exe shead.'&reset<TAB>:GitReset           :GitReset -q -- %<CR>'

	" Specials   {{{2
	let ahead = 'anoremenu          '.s:Git_RootMenu.'.s&pecials.'
	let shead = 'anoremenu <silent> '.s:Git_RootMenu.'.s&pecials.'

	exe ahead.'Specials<TAB>Git :echo "This is a menu header!"<CR>'
	exe ahead.'-Sep00-          :'

	exe ahead.'&commit,\ msg\ from\ file<TAB>:GitCommitFile   :GitCommitFile<space>'
	exe shead.'&commit,\ msg\ from\ merge<TAB>:GitCommitMerge :GitCommitMerge<CR>'
	exe ahead.'&commit,\ msg\ from\ cmdline<TAB>:GitCommitMsg :GitCommitMsg<space>'
	exe ahead.'-Sep01-          :'

	exe ahead.'&grep,\ use\ top-level\ dir<TAB>:GitGrepTop       :GitGrepTop<space>'
	exe ahead.'&merge,\ upstream\ branch<TAB>:GitMergeUpstream   :GitMergeUpstream<space>'
	exe shead.'&stash\ list<TAB>:GitSlist                        :GitSlist<CR>'

	" Custom Menu   {{{2
	if ! empty ( s:Git_CustomMenu )

		let ahead = 'anoremenu          '.s:Git_RootMenu.'.&custom.'
		let ahead = 'anoremenu <silent> '.s:Git_RootMenu.'.&custom.'

		exe ahead.'Custom<TAB>Git :echo "This is a menu header!"<CR>'
		exe ahead.'-Sep00-        :'

		call s:GenerateCustomMenu ( s:Git_RootMenu.'.custom', s:Git_CustomMenu )

		exe ahead.'-HelpSep-                                  :'
		exe ahead.'help\ (custom\ menu)<TAB>:GitSupportHelp   :call GitS_PluginHelp("gitsupport-menus")<CR>'

	endif

	" Edit   {{{2
	let ahead = 'anoremenu          '.s:Git_RootMenu.'.&edit.'
	let shead = 'anoremenu <silent> '.s:Git_RootMenu.'.&edit.'

	exe ahead.'Edit File<TAB>Git :echo "This is a menu header!"<CR>'
	exe ahead.'-Sep00-          :'

	for fileid in s:EditFileIDs
		let filepretty = substitute ( fileid, '-', '\\ ', 'g' )
		exe shead.'&'.filepretty.'<TAB>:GitEdit   :GitEdit '.fileid.'<CR>'
	endfor

	" Help   {{{2
	let ahead = 'anoremenu          '.s:Git_RootMenu.'.help.'
	let shead = 'anoremenu <silent> '.s:Git_RootMenu.'.help.'

	exe ahead.'Help<TAB>Git :echo "This is a menu header!"<CR>'
	exe ahead.'-Sep00-      :'

	exe shead.'help\ (Git-Support)<TAB>:GitSupportHelp     :call GitS_PluginHelp("gitsupport")<CR>'
	exe shead.'plug-in\ settings<TAB>:GitSupportSettings   :call GitS_PluginSettings(0)<CR>'

	" Main Menu - open buffers   {{{2
	let ahead = 'anoremenu          '.s:Git_RootMenu.'.'
	let shead = 'anoremenu <silent> '.s:Git_RootMenu.'.'

	exe ahead.'-Sep01-                      :'

	exe ahead.'&run\ git<TAB>:Git           :Git<space>'
	exe shead.'&branch<TAB>:GitBranch       :GitBranch<CR>'
	exe ahead.'&help\ \.\.\.<TAB>:GitHelp   :GitHelp<space>'
	exe shead.'&log<TAB>:GitLog             :GitLog<CR>'
	exe shead.'&remote<TAB>:GitRemote       :GitRemote<CR>'
	exe shead.'&stash\ list<TAB>:GitSlist   :GitSlist<CR>'
	exe shead.'&status<TAB>:GitStatus       :GitStatus<CR>'
	exe shead.'&tag<TAB>:GitTag             :GitTag<CR>'
	" }}}2

endfunction    " ----------  end of function s:InitMenus  ----------
"
"-------------------------------------------------------------------------------
" s:ToolMenu : Add or remove tool menu entries.   {{{1
"-------------------------------------------------------------------------------
"
function! s:ToolMenu( action )
	"
	if ! has ( 'menu' )
		return
	endif
	"
	if a:action == 'setup'
		anoremenu <silent> 40.1000 &Tools.-SEP100- :
		anoremenu <silent> 40.1080 &Tools.Load\ Git\ Support   :call Git_AddMenus()<CR>
	elseif a:action == 'loading'
		aunmenu   <silent> &Tools.Load\ Git\ Support
		anoremenu <silent> 40.1080 &Tools.Unload\ Git\ Support :call Git_RemoveMenus()<CR>
	elseif a:action == 'unloading'
		aunmenu   <silent> &Tools.Unload\ Git\ Support
		anoremenu <silent> 40.1080 &Tools.Load\ Git\ Support   :call Git_AddMenus()<CR>
	endif
	"
endfunction    " ----------  end of function s:ToolMenu  ----------
"
"-------------------------------------------------------------------------------
" Git_AddMenus : Add menus.   {{{1
"-------------------------------------------------------------------------------
"
function! Git_AddMenus()
	if s:MenuVisible == 0
		" initialize if not existing
		call s:ToolMenu ( 'loading' )
		call s:InitMenus ()
		" the menu is now visible
		let s:MenuVisible = 1
	endif
endfunction    " ----------  end of function Git_AddMenus  ----------
"
"-------------------------------------------------------------------------------
" Git_RemoveMenus : Remove menus.   {{{1
"-------------------------------------------------------------------------------
"
function! Git_RemoveMenus()
	if s:MenuVisible == 1
		" destroy if visible
		call s:ToolMenu ( 'unloading' )
		if has ( 'menu' )
			exe 'aunmenu <silent> '.s:Git_RootMenu
		endif
		" the menu is now invisible
		let s:MenuVisible = 0
	endif
endfunction    " ----------  end of function Git_RemoveMenus  ----------
"
"-------------------------------------------------------------------------------
" Setup maps.   {{{1
"-------------------------------------------------------------------------------
"
let s:maps = [
			\ [ 'complete branch',  'g:Git_MapCompleteBranch',  '<C-\>e<SID>CmdLineComplete("branch")<CR>'  ],
			\ [ 'complete command', 'g:Git_MapCompleteCommand', '<C-\>e<SID>CmdLineComplete("command")<CR>' ],
			\ [ 'complete remote',  'g:Git_MapCompleteRemote',  '<C-\>e<SID>CmdLineComplete("remote")<CR>'  ],
			\ [ 'complete tag',     'g:Git_MapCompleteTag',     '<C-\>e<SID>CmdLineComplete("tag")<CR>'     ],
			\ ]
"
for [ name, map_var, cmd ] in s:maps
	if exists ( map_var )
		try
			silent exe 'cnoremap <silent> '.{map_var}.' '.cmd
		catch /.*/
			call s:ErrorMsg ( 'Error while creating the map "'.name.'", with lhs "'.{map_var}.'":', v:exception )
		finally
		endtry
	endif
endfor
"
"-------------------------------------------------------------------------------
" Setup menus.   {{{1
"-------------------------------------------------------------------------------
"
" tool menu entry
call s:ToolMenu ( 'setup' )
"
" load the menu right now?
if s:Git_LoadMenus == 'yes'
	call Git_AddMenus ()
endif
" }}}1
"-------------------------------------------------------------------------------
"
" =====================================================================================
"  vim: foldmethod=marker
