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
"      Revision:  07.06.2013
"       License:  Copyright (c) 2012-2013, Wolfgang Mehner
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
let g:GitSupport_Version= '0.9.1'     " version number of this script; do not change
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
" s:EscapeFile : Escape a file for usage on the shell.   {{{2
"
" Parameters:
"   filename - the name of the file (string)
" Returns:
"   file_argument - the escaped filename (string)
"-------------------------------------------------------------------------------
"
function! s:EscapeFile ( filename )
	return shellescape ( a:filename )
endfunction    " ----------  end of function s:EscapeFile  ----------
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
	let text = system ( s:Git_Executable.' rev-parse -- '.a:args )
	"
	if v:shell_error == 0
		return split ( text, '\n' )
	else
		echo "Can not parse the command line arguments:\n\n".text
		return [ '' ]
	endif
	"
endfunction    " ----------  end of function s:GitCmdLineArgs  ----------
"
"-------------------------------------------------------------------------------
" s:GitRepoBase : Get the base directory of a repository.   {{{2
"
" Parameters:
"   -
" Returns:
"   path - the name of the base directory (string)
"-------------------------------------------------------------------------------
"
function! s:GitRepoBase ()
	"
	let text = system ( s:Git_Executable.' rev-parse --show-toplevel' )
	"
	if v:shell_error == 0
		return resolve ( substitute ( text, '\_s\+$', '', '' ) )   " remove whitespaces and end-of-line at the end of the string
	else
		echo "Can not query the base directory:\n\n".text
		return ''
	endif
	"
endfunction    " ----------  end of function s:GitRepoBase  ----------
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
	if bufwinnr ( '^'.a:filename.'$' ) == -1
		" open buffer
		belowright new
		exe "edit ".fnameescape( a:filename )
	else
		" jump to window
		exe bufwinnr( a:filename ).'wincmd w'
	end
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
		normal zv
	endif
endfunction    " ----------  end of function s:OpenFile  ----------
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
			let cmd = mlist[1].mlist[2].repeat( '<LEFT>', len( mlist[2] ) )
			let silent = ''
		elseif cmd =~ '<EXECUTE>$'
			let cmd = substitute ( cmd, '<EXECUTE>$', '<CR>', '' )
		endif
		"
		let cmd = substitute ( cmd, '<WORD>',   '<cword>', 'g' )
		let cmd = substitute ( cmd, '<FILE>',   '<cfile>', 'g' )
		let cmd = substitute ( cmd, '<BUFFER>', '%',       'g' )
		"
		exe 'amenu '.silent.entry.' '.cmd
	endfor
	"
endfunction    " ----------  end of function s:GenerateCustomMenu  ----------
" }}}2
"-------------------------------------------------------------------------------
"
"-------------------------------------------------------------------------------
" Test: Custom cmdline completion.   {{{1
"-------------------------------------------------------------------------------
"
" Debug:
let g:GitSupport_LastCmdlineComplete = []
"
"-------------------------------------------------------------------------------
" s:GitS_CmdlineComplete : Git-specific command line completion.   {{{2
"-------------------------------------------------------------------------------
"
function! GitS_CmdlineComplete ( ArgLead, CmdLine, CursorPos )
	"
	let git_cmd = tolower ( matchstr ( a:CmdLine, '^Git\zs\w*' ) )
	"
	if git_cmd == ''
		let git_cmd = matchstr ( a:CmdLine, '^Git\s\+\zs\w*' )
	endif
	"
	" files
	let filelist = split ( glob ( a:ArgLead.'*' ), "\n" )
	"
	for i in range( 0, len(filelist)-1 )
		if isdirectory ( filelist[i] )
			let filelist[i] .= '/'
		endif
	endfor
	"
	" git objects: branched, tags, remotes
	let gitlist = []
	"
	" branches
	let gitlist += split ( s:StandardRun ( 'branch', '-a', 't' ), '\_[* ]\+\%(remotes/\)\?' )
	"
	" tags
	let gitlist += split ( s:StandardRun ( 'tag', '', 't' ), "\n" )
	"
	" remotes
	let gitlist += split ( s:StandardRun ( 'remote', '', 't' ), "\n" )
	"
	call filter ( gitlist, '0 == match ( v:val, "\\V'.escape(a:ArgLead,'\').'" )' )
	"
	let g:GitSupport_LastCmdlineComplete = [ git_cmd, a:ArgLead, gitlist ]
	"
" 	return filelist
	return escape ( join ( filelist + gitlist, "\n" ), ' \?*"' )
	"
endfunction    " ----------  end of function GitS_CmdlineComplete  ----------
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

if s:MSWIN
	let s:Git_Executable     = 'C:\Program Files\Git\bin\git.exe'     " Git executable
	let s:Git_GitKExecutable = 'C:\Program Files\Git\bin\tclsh.exe'   " GitK executable
	let s:Git_GitKScript     = 'C:\Program Files\Git\bin\gitk'        " GitK script
else
	let s:Git_Executable     = 'git'    " Git executable
	let s:Git_GitKExecutable = 'gitk'   " GitK executable
	let s:Git_GitKScript     = ''       " GitK script
endif
let s:Git_LoadMenus      = 'yes'    " load the menus?
let s:Git_RootMenu       = '&Git'   " name of the root menu
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
call s:GetGlobalSetting ( 'Git_Executable' )
call s:GetGlobalSetting ( 'Git_GitKExecutable' )
call s:GetGlobalSetting ( 'Git_GitKScript' )
call s:GetGlobalSetting ( 'Git_LoadMenus' )
call s:GetGlobalSetting ( 'Git_RootMenu' )
call s:GetGlobalSetting ( 'Git_CustomMenu' )
"
call s:ApplyDefaultSetting ( 'Git_DiffExpandEmpty',      'no' )
call s:ApplyDefaultSetting ( 'Git_OpenFoldAfterJump',    'yes' )
call s:ApplyDefaultSetting ( 'Git_StatusStagedOpenDiff', 'cached' )
"
let s:Enabled         = 1           " Git enabled?
let s:DisabledMessage = "Git-Support not working:"
let s:DisabledReason  = ""
"
let s:EnabledGitK        = 1        " GitK enabled?
let s:DisableGitKMessage = "GitK not avaiable:"
let s:DisableGitKReason  = ""
"
let s:FoundGitKScript   = 1
let s:GitKScriptMessage = ""
"
let s:GitVersion    = ""            " Git Version
let s:GitHelpFormat = ""            " 'man' or 'html'
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
	let [ s:Git_GitKScript, s:FoundGitKScript, s:GitKScriptMessage ] = s:CheckFile( 'gitk script', s:Git_GitKScript, 1 )
endif
"
" check Git version   {{{2
"
" added in 1.7.2:
" - "git status --ignored"
" - "git status -s -b"
let s:HasStatusIgnore = 0
let s:HasStatusBranch = 0
"
if s:Enabled
	let s:GitVersion = system( s:Git_Executable.' --version' )
	if s:GitVersion =~ 'git version [0-9.]\+'
		let s:GitVersion = matchstr( s:GitVersion, 'git version \zs[0-9.]\+' )
		"
		if ! s:VersionLess ( s:GitVersion, '1.7.2' )
			let s:HasStatusIgnore = 1
			let s:HasStatusBranch = 1
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
	let s:GitHelpFormat = system( s:Git_Executable.' config --get help.format' )
	let s:GitHelpFormat = substitute( s:GitHelpFormat,  '\_s',  '',  'g' )
	"
	if s:GitHelpFormat == ''
		let s:GitHelpFormat = 'man'
	elseif s:GitHelpFormat == 'web'
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
	command! -nargs=* -complete=file -bang                           GitAdd             :call GitS_Add(<q-args>,'<bang>'=='!'?'ef':'e')
	command! -nargs=* -complete=file -range=0                        GitBlame           :call GitS_Blame('update',<q-args>,<line1>,<line2>)
	command! -nargs=* -complete=file                                 GitBranch          :call GitS_Branch(<q-args>,'')
	command! -nargs=* -complete=file                                 GitCheckout        :call GitS_Checkout(<q-args>,'ce')
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
	command! -nargs=* -complete=file                                 GitReset           :call GitS_Reset(<q-args>,'e')
	command! -nargs=* -complete=file                                 GitShow            :call GitS_Show('update',<q-args>)
	command! -nargs=*                                                GitStash           :call GitS_Stash(<q-args>,'')
	command! -nargs=0                                                GitStatus          :call GitS_Status('update')
	command! -nargs=*                                                GitTag             :call GitS_Tag(<q-args>,'')
	command  -nargs=* -complete=file -bang                           Git                :call GitS_Run(<q-args>,'<bang>'=='!'?'b':'')
	command! -nargs=* -complete=file                                 GitRun             :call GitS_Run(<q-args>,'')
	command! -nargs=* -complete=file                                 GitBuf             :call GitS_Run(<q-args>,'b')
	command! -nargs=* -complete=file                                 GitK               :call GitS_GitK(<q-args>)
	command! -nargs=0                                                GitSupportHelp     :call GitS_PluginHelp("gitsupport")
	command! -nargs=0                                                GitSupportSettings :call GitS_PluginSettings()
else
	command  -nargs=*                -bang                           Git                :call GitS_Help('disabled')
	command! -nargs=*                                                GitRun             :call GitS_Help('disabled')
	command! -nargs=*                                                GitBuf             :call GitS_Help('disabled')
	command! -nargs=*                                                GitHelp            :call GitS_Help('disabled')
	command! -nargs=0                                                GitSupportHelp     :call GitS_PluginHelp("gitsupport")
	command! -nargs=0                                                GitSupportSettings :call GitS_PluginSettings()
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
" s:Question : Ask the user a question.   {{{1
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
	end
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
	"
	" a buffer like this already opened on the current tab page?
	if bufwinnr ( a:buf_name ) != -1
		" yes -> go to the window containing the buffer
		exe bufwinnr( a:buf_name ).'wincmd w'
		return 0
	endif
	"
	" no -> open a new window
	aboveleft new
	"
	" buffer exists elsewhere?
	if bufnr ( a:buf_name ) != -1
		" yes -> settings of the new buffer
		silent exe 'edit #'.bufnr( a:buf_name )
	else
		" no -> settings of the new buffer
		silent exe 'file '.escape( a:buf_name, ' ' )
		setlocal noswapfile
		setlocal bufhidden=wipe
		setlocal tabstop=8
		setlocal foldmethod=syntax
	end
	"
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
		let pos = line('.')
	else
		let pos = 1
	endif
	"
	" delete the previous contents
	setlocal modifiable
	setlocal noro
	silent exe '1,$delete'
	"
	" pause syntax highlighting (for speed)
	if &syntax != ''
		setlocal syntax=OFF
	endif
	"
	" insert the output of the command
	silent exe 'r! '.a:command
	"
	" restart syntax highlighting
	if &syntax != ''
		setlocal syntax=ON
	endif
	"
	" delete the first line (empty) and go to position
	normal zR
	normal ggdd
	silent exe ':'.pos
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
" s:StandardRun : execute 'git <cmd> ...'   {{{1
"
" Parameters:
"   cmd     - the Git command to run (string), this is not the Git executable!
"   param   - the parameters (string)
"   flags   - all set flags (string)
"   allowed - all allowed flags (string, default: 'cet')
" Returns:
"   text    - the text produced by the command (string),
"             only if the flag 't' is set
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
	end
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
	if v:shell_error != 0
		echo "\"".cmd."\" failed:\n\n".text           | " failure
	elseif a:flags =~ 't'
		return substitute ( text, '\_s*$', '', '' )     " success
	elseif text =~ '^\_s*$'
		echo "ran successfully"                       | " success
	else
		echo "ran successfully:\n".text               | " success
	endif
	"
endfunction    " ----------  end of function s:StandardRun  ----------
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
	if line =~ '^#\s'
		" we assume a line in the status comment block (TODO: might be something else),
		" and try to guess the number of lines
		let filesstart = v:foldstart+1
		let filesend   = v:foldend
		while filesstart < v:foldend && getline(filesstart) =~ '\_^#\s*\_$\|\_^#\s\+('
			let filesstart += 1
		endwhile
		while filesend > v:foldstart && getline(filesend) =~ '^#\s*$'
			let filesend -= 1
		endwhile
		return line.' '.( filesend - filesstart + 1 ).' files '
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
		end
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
	end
endfunction    " ----------  end of function GitS_FoldGrep  ----------
"
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
		exe 'nmap          <buffer> <S-F1> :call GitS_RunBuf("help")<CR>'
		exe 'nmap <silent> <buffer> q      :call GitS_RunBuf("quit")<CR>'
		exe 'nmap <silent> <buffer> u      :call GitS_RunBuf("update","!'.subcmd.'")<CR>'
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
		end
		"
		let b:GitSupport_BlameFile = f_name
	end
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
		end
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
		end
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
		exe 'nmap          <buffer> <S-F1> :call GitS_Blame("help")<CR>'
		exe 'nmap <silent> <buffer> q      :call GitS_Blame("quit")<CR>'
		exe 'nmap <silent> <buffer> u      :call GitS_Blame("update")<CR>'
		"
		exe 'nmap <silent> <buffer> of      :call GitS_Blame("edit")<CR>'
		exe 'nmap <silent> <buffer> oj      :call GitS_Blame("jump")<CR>'
		"
		exe 'nmap <silent> <buffer> cs      :call GitS_Blame("show")<CR>'
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
function! GitS_BranchList( action )
	"
	if a:action == 'help'
		echo s:HelpTxtStd
		return
	elseif a:action == 'quit'
		close
		return
	elseif a:action == 'update'
		" noop
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
		exe 'nmap          <buffer> <S-F1> :call GitS_BranchList("help")<CR>'
		exe 'nmap <silent> <buffer> q      :call GitS_BranchList("quit")<CR>'
		exe 'nmap <silent> <buffer> u      :call GitS_BranchList("update")<CR>'
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
	if empty( a:param )
		"
		" checkout on the current file potentially destroys unstaged changed,
		" ask question with different highlighting
		if a:flags =~ 'c' && s:Question ( 'Check out current file?', 'warning' ) != 1
			echo "aborted"
			return
		endif
		"
		" remove confirmation from flags
		let flags = substitute ( a:flags, 'c', '', 'g' )
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
	"
	if a:flags =~ '[^c]'
		return s:ErrorMsg ( 'Unknown flag "'.matchstr( a:flags, '[^c]' ).'".' )
	endif
	"
	if a:mode == 'direct'
		"
		let args = s:GitCmdLineArgs ( a:param )
		"
		" empty parameter list?
		if empty ( a:param )
			return s:ErrorMsg ( 'The command :GitCommit currently can not be used this way.',
						\ 'Please supply the message using either the -m or -F options,',
						\ 'or by using the special commands :GitCommitFile, :GitCommitMerge or :GitCommitMsg.' )
" 			"
" 			" get ./.git/COMMIT_EDITMSG file
" 			let file = s:GitRepoBase ()
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
		elseif index ( args, '--dry-run', 1 ) != -1
			"
			call GitS_CommitDryRun ( 'update', a:param )
			return
			"
		else
			"
			" commit ...
			let param = a:param
			"
		endif
		"
	elseif a:mode == 'file'
		"
		" message from file
		if empty( a:param ) | let param = '-F '.s:EscapeFile( expand('%') )
		else                | let param = '-F '.a:param
		endif
		"
	elseif a:mode == 'merge'
		"
		" message from ./.git/MERGE_MSG file
		let file = s:GitRepoBase ()
		"
		" could not get top-level?
		if file == '' | return | endif
		"
		let file .= '/.git/MERGE_MSG'
		"
		" not readable?
		if ! filereadable ( file )
			return s:ErrorMsg (
						\ 'could not read the file ".git/MERGE_MSG" /',
						\ 'there does not seem to be a merge conflict (see :help GitCommitMerge)' )
		endif
		"
		" commit
		let param = '-F '.s:EscapeFile( file )
		"
	elseif a:mode == 'msg'
		" message from command line
		let param = '-m "'.a:param.'"'
	else
		echoerr 'Unknown mode "'.a:mode.'".'
		return
	endif
	"
	let cmd = s:Git_Executable.' commit '.param
	"
	if a:flags =~ 'c' && s:Question ( 'Execute "git commit '.param.'"?' ) != 1
		echo "aborted"
		return
	endif
	"
	" :TODO:27.11.2013 15:18:WM: use s:StandardRun
	let text = system ( cmd )
	"
	if v:shell_error == 0 && text =~ '^\s*$'
		echo "ran successfully"               | " success
	elseif v:shell_error == 0
		echo "ran successfully:\n".text       | " success
	else
		echo "\"".cmd."\" failed:\n\n".text   | " failure
	endif
	"
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
		exe 'nmap          <buffer> <S-F1> :call GitS_CommitDryRun("help")<CR>'
		exe 'nmap <silent> <buffer> q      :call GitS_CommitDryRun("quit")<CR>'
		exe 'nmap <silent> <buffer> u      :call GitS_CommitDryRun("update")<CR>'
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
	"
	call s:UpdateGitBuffer ( cmd, update_only )
	"
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
" }}}2
"-------------------------------------------------------------------------------
"
"-------------------------------------------------------------------------------
" GitS_Diff : execute 'git diff ...'
"-------------------------------------------------------------------------------
"
function! GitS_Diff( action, ... )
	"
	let update_only = 0
	let param = ''
	"
	if a:action == 'help'
		let txt  = s:HelpTxtStd."\n\n"
		let txt .= "of      : file under cursor: open file (edit)\n"
		let txt .= "oj      : file under cursor: open and jump to the position under the cursor\n\n"
		let txt .= "For settings see:\n"
		let txt .= "  :help g:Git_DiffExpandEmpty"
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
		elseif empty( a:1 ) && g:Git_DiffExpandEmpty == 'yes'
			let param = s:EscapeCurrent()
		else
			let param = a:1
		endif
		"
	elseif a:action =~ '\<\%(\|edit\|jump\)\>'
		"
		let base = s:GitRepoBase()
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
		exe 'nmap          <buffer> <S-F1> :call GitS_Diff("help")<CR>'
		exe 'nmap <silent> <buffer> q      :call GitS_Diff("quit")<CR>'
		exe 'nmap <silent> <buffer> u      :call GitS_Diff("update")<CR>'

		exe 'nmap <silent> <buffer> of     :call GitS_Diff("edit")<CR>'
		exe 'nmap <silent> <buffer> oj     :call GitS_Diff("jump")<CR>'
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
		end
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
		let base = s:GitRepoBase()
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
		exe 'nmap          <buffer> <S-F1> :call GitS_Grep("help")<CR>'
		exe 'nmap <silent> <buffer> q      :call GitS_Grep("quit")<CR>'
		exe 'nmap <silent> <buffer> u      :call GitS_Grep("update")<CR>'
		"
		exe 'nmap <silent> <buffer> of      :call GitS_Grep("edit")<CR>'
		exe 'nmap <silent> <buffer> oj      :call GitS_Grep("jump")<CR>'
		exe 'nmap <silent> <buffer> <Enter> :call GitS_Grep("jump")<CR>'
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
	"
	if s:GitHelpFormat == 'html'
		return s:StandardRun ( 'help', helpcmd, '' )
	endif
	"
	if s:OpenGitBuffer ( 'Git - help' )
		"
		let b:GitSupport_HelpFlag = 1
		"
		setlocal filetype=man
		"
		exe 'nmap          <buffer> <S-F1> :call GitS_Help("help")<CR>'
		exe 'nmap <silent> <buffer> q      :call GitS_Help("quit")<CR>'
		"
		"exe 'nmap <silent> <buffer> c      :call GitS_Help("toc")<CR>'
	endif
	"
	let cmd = s:Git_Executable.' help '.helpcmd
	"
	call s:UpdateGitBuffer ( cmd )
	"
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
function! GitS_Log( action, ... )
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
		if a:0 == 0         | " run again with old parameters
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
	if s:OpenGitBuffer ( 'Git - log' )
		"
		let b:GitSupport_LogFlag = 1
		"
		setlocal filetype=gitslog
		setlocal foldtext=GitS_FoldLog()
		"
		exe 'nmap          <buffer> <S-F1> :call GitS_Log("help")<CR>'
		exe 'nmap <silent> <buffer> q      :call GitS_Log("quit")<CR>'
		exe 'nmap <silent> <buffer> u      :call GitS_Log("update")<CR>'
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
	" TODO: git for-each-ref --format='%(upstream:short)' refs/heads/csupport-dev
	"
	if a:mode == 'direct'
		"
		return s:StandardRun ( 'merge', a:param, a:flags, 'c' )
		"
	elseif a:mode == 'upstream'
		"
		let b_current = s:StandardRun ( 'symbolic-ref', '-q HEAD', 't' )
		let b_upstream = s:StandardRun ( 'for-each-ref', " --format='%(upstream:short)' ".shellescape( b_current ), 't' )
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
function! GitS_RemoteList( action )
	"
	if a:action == 'help'
		echo s:HelpTxtStd
		return
	elseif a:action == 'quit'
		close
		return
	elseif a:action == 'update'
		" noop
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
		exe 'nmap          <buffer> <S-F1> :call GitS_RemoteList("help")<CR>'
		exe 'nmap <silent> <buffer> q      :call GitS_RemoteList("quit")<CR>'
		exe 'nmap <silent> <buffer> u      :call GitS_RemoteList("update")<CR>'
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
	return s:StandardRun ( 'reset', a:param, a:flags )
	"
endfunction    " ----------  end of function GitS_Reset  ----------
"
"-------------------------------------------------------------------------------
" GitS_Show : execute 'git show ...'   {{{1
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
		if a:0 == 0         | " run again with old parameters
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
	if s:OpenGitBuffer ( 'Git - show' )
		"
		let b:GitSupport_ShowFlag = 1
		"
		setlocal filetype=gitslog
		setlocal foldtext=GitS_FoldLog()
		"
		exe 'nmap          <buffer> <S-F1> :call GitS_Show("help")<CR>'
		exe 'nmap <silent> <buffer> q      :call GitS_Show("quit")<CR>'
		exe 'nmap <silent> <buffer> u      :call GitS_Show("update")<CR>'
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
function! GitS_StashList( action, ... )
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
	if s:OpenGitBuffer ( 'Git - stash list' )
		"
		let b:GitSupport_StashListFlag = 1
		"
		setlocal filetype=gitslog
		"
		exe 'nmap          <buffer> <S-F1> :call GitS_StashList("help")<CR>'
		exe 'nmap <silent> <buffer> q      :call GitS_StashList("quit")<CR>'
		exe 'nmap <silent> <buffer> u      :call GitS_StashList("update")<CR>'
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
		exe 'nmap          <buffer> <S-F1> :call GitS_StashShow("help")<CR>'
		exe 'nmap <silent> <buffer> q      :call GitS_StashShow("quit")<CR>'
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
" s:Status_SectionCodes   {{{2
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
"   [ <file-name>, <file-status>, <section-code> ] - data (list: 3x string)
"
" The entries are as follows:
"   file name    - name of the file under the cursor (string)
"   file status  - status of the file, see below (string)
"   section code - one character encoding the section the file was found in,
"                  use 's:Status_SectionCodes' to decode the meaning (string)
"
" Status:
" - "new file"
" - "modified"
" - "deleted"
" - "conflict"
" - one of the two-letter status codes of "git status --short"
"
" In case of an error, the list contains to empty strings and an error message:
"   [ '', '', <error-message> ]
"-------------------------------------------------------------------------------
"
function! s:Status_GetFile()
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
	else
		"
		" regular output
		"
		let c_line = getline('.')
		let c_pos  = line('.')
		let h_pos  = c_pos
		let s_head = ''
		"
		if c_line =~ '^#'
			"
			" find header
			while h_pos > 0
				"
				let s_head = matchstr( getline(h_pos), '^# \zs[[:alnum:][:space:]]\+\ze:$' )
				"
				if ! empty( s_head )
					break
				endif
				"
				let h_pos -= 1
			endwhile
			"
			" which header?
			if s_head == ''
				return [ '', '', 'Not in any section.' ]
			elseif s_head == 'Changes to be committed'
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
				let base = s:GitRepoBase()
				" could not get top-level?
				if base == ''
					return [ '', '', 'could not obtain the top-level directory' ]
				endif
				return[ 'd', 'modified', s:GitRepoBase().'/'.f_name ]
			endif
		endif
		"
	endif
	"
	if f_name =~ '^".\+"$'
		let f_name = substitute ( f_name, '\_^"\|"\_$', '', 'g' )
		let f_name = substitute ( f_name, '\\\(.\)', '\1', 'g' )
	endif
	"
	return [ f_name, f_status, s_code ]
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
"  unmerged  (c)   |  x    |  x     x    |  x     -     -     x    |  -
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
	let [ f_name, f_status, s_code ] = fileinfo
	"
	if f_name == ''
		call s:ErrorMsg ( s_code )
		return 0
	endif
	"
	let f_name_esc = '-- '.s:EscapeFile( f_name )
	"
	if a:action == 'edit'
		"
		" any section, action "edit"
		call s:OpenFile( f_name )
		"
	elseif s_code == 's' && a:action == 'diff'
		"
		" section "staged", action "diff"
		if g:Git_StatusStagedOpenDiff == 'cached'
			call GitS_Diff( 'update', '--cached '.f_name_esc )
		elseif g:Git_StatusStagedOpenDiff == 'head'
			call GitS_Diff( 'update', 'HEAD '.f_name_esc )
		else
			call GitS_Diff( 'update', f_name_esc )
		endif
		"
	elseif s_code =~ '[bmcd]' && a:action == 'diff'
		"
		" section "modified", "conflict" or "diff", action "diff"
		" (this is also called for section "both" in short status output)
		call GitS_Diff( 'update', f_name_esc )
		"
	elseif s_code =~ '[bsmcd]' && a:action == 'log'
		"
		" section "staged", "modified", "conflict" or "diff", action "log"
		call GitS_Log( 'update', f_name_esc )
		"
	elseif s_code == 'i' && a:action == 'add'
		"
		" section "ignored", action "add"
		if s:Question( 'Add ignored file "'.f_name.'"?', 'warning' ) == 1
			call GitS_Add( f_name_esc, 'f' )
			return 1
		endif
		"
	elseif s_code == 'u' && a:action == 'add'
		"
		" section "untracked", action "add"
		if s:Question( 'Add untracked file "'.f_name.'"?' ) == 1
			call GitS_Add( f_name_esc, '' )
			return 1
		endif
		"
	elseif s_code =~ '[bm]' && a:action == 'add'
		"
		" section "modified", action "add"
		"
		if f_status == 'modified' || f_status =~ '^.M$'
			" add a modified file?
			if s:Question( 'Add file "'.f_name.'"?' ) == 1
				call GitS_Add( f_name_esc, '' )
				return 1
			endif
		elseif f_status == 'deleted' || f_status =~ '^.D$'
			" add a deleted file? -> remove it?
			if s:Question( 'Remove file "'.f_name.'"?' ) == 1
				call GitS_Remove( f_name_esc, '' )
				return 1
			endif
		else
			call s:ErrorMsg ( 'Adding not implemented yet for file status "'.f_status.'".' )
		endif
		"
	elseif s_code =~ '[bm]' && a:action == 'checkout'
		"
		" section "modified", action "checkout"
		"
		if f_status == 'modified' || f_status == 'deleted' || f_status =~ '^.[MD]$'
			" check out a modified or deleted file?
			if s:Question( 'Checkout file "'.f_name.'"?', 'warning' ) == 1
				call GitS_Checkout( f_name_esc, '' )
				return 1
			endif
		else
			call s:ErrorMsg ( 'Checking out not implemented yet for file status "'.f_status.'".' )
		endif
		"
	elseif s_code =~ '[bsd]' && a:action == 'reset'
		"
		" section "staged" or "diff", action "reset"
		"
		if f_status == 'modified' || f_status == 'new file' || f_status == 'deleted' || f_status =~ '^[MADRC].$'
			" reset a modified, new or deleted file?
			if s:Question( 'Reset file "'.f_name.'"?' ) == 1
				call GitS_Reset( f_name_esc, '' )
				return 1
			endif
		else
			call s:ErrorMsg ( 'Reseting not implemented yet for file status "'.f_status.'".' )
		endif
		"
	elseif s_code =~ 'c' && a:action == 'add'
		"
		" section "unmerged", action "add"
		if s:Question( 'Add unmerged file "'.f_name.'"?' ) == 1
			call GitS_Add( f_name_esc, '' )
			return 1
		endif
		"
	elseif s_code =~ 'c' && a:action == 'reset'
		"
		" section "unmerged", action "reset" -> "remove"
		if s:Question( 'Remove unmerged file "'.f_name.'"?' ) == 1
			call GitS_Remove( f_name_esc, '' )
			return 1
		endif
		"
	elseif s_code =~ '[ui]' && a:action == 'delete'
		"
		" section "untracked" or "ignored", action "delete"
		"
		if ! exists( '*delete' )
			call s:ErrorMsg ( 'Can not delete files from harddisk.' )
		elseif s:Question( 'Delete file "'.f_name.'" from harddisk?' ) == 1
			return delete ( f_name ) == 0
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
function! GitS_Status( action )
	"
	let update_only = 0
	"
	if a:action == 'help'
		let txt  = s:HelpTxtStd."\n\n"
		let txt .= "toggle ...\n"
		let txt .= "i       : show ignored files\n"
		let txt .= "s       : short output\n"
		let txt .= "v       : verbose output\n"
		let txt .= "\n"
		let txt .= "file under cursor ...\n"
		let txt .= "a       : add\n"
		let txt .= "c       : checkout\n"
		let txt .= "od      : open diff\n"
		let txt .= "of      : open file (edit)\n"
		let txt .= "ol      : open log\n"
		let txt .= "r       : reset\n"
		let txt .= "r       : remove (only for unmerged changes)\n"
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
		let update_only = 1
	elseif a:action == 'ignored'
		if ! s:HasStatusIgnore
			return s:ErrorMsg ( '"show ignored files" not available in Git version '.s:GitVersion.'.' )
		endif
	elseif a:action =~ '\<\%(short\|verbose\)\>'
		" noop
	elseif a:action =~ '\<\%(add\|checkout\|diff\|edit\|log\|reset\|delete\)\>'
		"
 		call s:ChangeCWD ()
		"
" 		if getline('.') =~ '^#' || b:GitSupport_ShortOption
			if s:Status_FileAction ( a:action )
				call GitS_Status( 'update' )
			endif
" 		else
" 			call s:ErrorMsg ( 'Not in status section.' )
" 		endif
		"
		return
	else
		echoerr 'Unknown action "'.a:action.'".'
		return
	endif
	"
	let buf = s:CheckCWD ()
	"
	if s:OpenGitBuffer ( 'Git - status' )
		"
		let b:GitSupport_StatusFlag = 1
		let b:GitSupport_IgnoredOption    = 0
		let b:GitSupport_ShortOption      = 0
		let b:GitSupport_VerboseOption    = 0
		"
		setlocal filetype=gitsstatus
		setlocal foldtext=GitS_FoldLog()
		"
		exe 'nmap          <buffer> <S-F1> :call GitS_Status("help")<CR>'
		exe 'nmap <silent> <buffer> q      :call GitS_Status("quit")<CR>'
		exe 'nmap <silent> <buffer> u      :call GitS_Status("update")<CR>'
		"
		exe 'nmap <silent> <buffer> i      :call GitS_Status("ignored")<CR>'
		exe 'nmap <silent> <buffer> s      :call GitS_Status("short")<CR>'
		exe 'nmap <silent> <buffer> v      :call GitS_Status("verbose")<CR>'
		"
		exe 'nmap <silent> <buffer> a      :call GitS_Status("add")<CR>'
		exe 'nmap <silent> <buffer> c      :call GitS_Status("checkout")<CR>'
		exe 'nmap <silent> <buffer> od     :call GitS_Status("diff")<CR>'
		exe 'nmap <silent> <buffer> of     :call GitS_Status("edit")<CR>'
		exe 'nmap <silent> <buffer> ol     :call GitS_Status("log")<CR>'
		exe 'nmap <silent> <buffer> r      :call GitS_Status("reset")<CR>'
		exe 'nmap <silent> <buffer> D      :call GitS_Status("delete")<CR>'
		"
	endif
	"
	call s:ChangeCWD ( buf )
	"
	if a:action == 'update'
		" noop
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
function! GitS_TagList( action, ... )
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
	if s:OpenGitBuffer ( 'Git - tag' )
		"
		let b:GitSupport_TagListFlag = 1
		"
" 		setlocal filetype=gitslog
		"
		exe 'nmap          <buffer> <S-F1> :call GitS_TagList("help")<CR>'
		exe 'nmap <silent> <buffer> q      :call GitS_TagList("quit")<CR>'
		exe 'nmap <silent> <buffer> u      :call GitS_TagList("update")<CR>'
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
		return s:ErrorMsg ( s:DisableGitKMessage, s:GitKScriptMessage )
	endif
	"
	if s:MSWIN
		silent exe '!'.s:Git_GitKExecutable.' '.s:Git_GitKScript.' '.a:param
	else
		silent exe '!'.s:Git_GitKExecutable.' '.s:Git_GitKScript.' '.a:param.' &'
	endif
	"
endfunction    " ----------  end of function GitS_GitK  ----------
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
function! GitS_PluginSettings(  )
	"
	if     s:MSWIN | let sys_name = 'Windows'
	elseif s:UNIX  | let sys_name = 'UNIX'
	else           | let sys_name = 'unknown' | endif
	"
	let gitk_e_status = s:EnabledGitK     ? '<yes>' : '<no>'
	let gitk_s_status = s:FoundGitKScript ? '<yes>' : '<no>'
	"
	let	txt = " Git-Support settings\n\n"
				\ .'     plug-in installation :  '.s:installation.' on '.sys_name."\n"
				\ .'           git executable :  '.s:Git_Executable."\n"
	if s:Enabled
		let txt .= '                > version :  '.s:GitVersion."\n"
	else
		let txt .= "                > enabled :  <no>\n"
	endif
	let txt .=
				\  '          gitk executable :  '.s:Git_GitKExecutable."\n"
				\ .'                > enabled :  '.gitk_e_status."\n"
	if ! empty ( s:Git_GitKScript )
		let txt .=
					\  '              gitk script :  '.s:Git_GitKScript."\n"
					\ .'                  > found :  '.gitk_s_status."\n"
	endif
	let txt .=
				\  "________________________________________________________________________________\n"
				\ ." Git-Support, Version ".g:GitSupport_Version." / Wolfgang Mehner / wolfgang-mehner@web.de\n\n"
	"
	echo txt
endfunction    " ----------  end of function GitS_PluginSettings  ----------
"
"-------------------------------------------------------------------------------
" s:InitMenus : Initialize menus.   {{{1
"-------------------------------------------------------------------------------
"
function! s:InitMenus()
	"
	if ! has ( 'menu' )
		return
	endif
	"
	let ahead = 'amenu '.s:Git_RootMenu.'.'
	"
	exe ahead.'Git       :echo "This is a menu header!"<CR>'
	exe ahead.'-Sep00-   :'
	"
	" Commands
	let ahead = 'amenu '.s:Git_RootMenu.'.&git\ \.\.\..'
	let vhead = 'vmenu '.s:Git_RootMenu.'.&git\ \.\.\..'
	"
	exe ahead.'Commands<TAB>Git :echo "This is a menu header!"<CR>'
	exe ahead.'-Sep00-          :'
	"
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
	exe ahead.'-Sep01-                    :'
	exe ahead.'git&k<TAB>:GitK            :GitK<space>'
	"
	" Current File
	let shead = 'amenu <silent> '.s:Git_RootMenu.'.&file.'
	let vhead = 'vmenu <silent> '.s:Git_RootMenu.'.&file.'
	"
	exe shead.'Current\ File<TAB>Git :echo "This is a menu header!"<CR>'
	exe shead.'-Sep00-               :'
	"
	exe shead.'&add<TAB>:GitAdd           :GitAdd -- %<CR>'
	exe shead.'&blame<TAB>:GitBlame       :GitBlame -- %<CR>'
	exe vhead.'&blame<TAB>:GitBlame       :GitBlame -- %<CR>'
	exe shead.'&checkout<TAB>:GitCheckout :GitCheckout -- %<CR>'
	exe shead.'&diff<TAB>:GitDiff         :GitDiff -- %<CR>'
	exe shead.'&log<TAB>:GitLog           :GitLog -- %<CR>'
	exe shead.'r&m<TAB>:GitRm             :GitRm -- %<CR>'
	exe shead.'&reset<TAB>:GitReset       :GitReset -- %<CR>'
	"
	" Specials
	let ahead = 'amenu          '.s:Git_RootMenu.'.s&pecials.'
	let shead = 'amenu <silent> '.s:Git_RootMenu.'.s&pecials.'
	"
	exe ahead.'Specials<TAB>Git :echo "This is a menu header!"<CR>'
	exe ahead.'-Sep00-          :'
	"
	exe ahead.'&commit,\ msg\ from\ file<TAB>:GitCommitFile   :GitCommitFile<space>'
	exe shead.'&commit,\ msg\ from\ merge<TAB>:GitCommitMerge :GitCommitMerge<CR>'
	exe ahead.'&commit,\ msg\ from\ cmdline<TAB>:GitCommitMsg :GitCommitMsg<space>'
	exe ahead.'-Sep01-          :'
	"
	exe ahead.'&grep,\ use\ top-level\ dir<TAB>:GitGrepTop       :GitGrepTop<space>'
	exe ahead.'&merge,\ upstream\ branch<TAB>:GitMergeUpstream   :GitMergeUpstream<space>'
	"
	" Custom Menu
	if ! empty ( s:Git_CustomMenu )
		"
		let ahead = 'amenu          '.s:Git_RootMenu.'.&custom.'
		let ahead = 'amenu <silent> '.s:Git_RootMenu.'.&custom.'
		"
		exe ahead.'Custom<TAB>Git :echo "This is a menu header!"<CR>'
		exe ahead.'-Sep00-        :'
		"
		call s:GenerateCustomMenu ( s:Git_RootMenu.'.custom', s:Git_CustomMenu )
		"
		exe ahead.'-HelpSep-                                  :'
		exe ahead.'help\ (custom\ menu)<TAB>:GitSupportHelp   :call GitS_PluginHelp("gitsupport-menus")<CR>'
		"
	endif
	"
	" Help
	let ahead = 'amenu          '.s:Git_RootMenu.'.help.'
	let shead = 'amenu <silent> '.s:Git_RootMenu.'.help.'
	"
	exe ahead.'Help<TAB>Git :echo "This is a menu header!"<CR>'
	exe ahead.'-Sep00-      :'
	"
	exe shead.'help\ (Git-Support)<TAB>:GitSupportHelp     :call GitS_PluginHelp("gitsupport")<CR>'
	exe shead.'plug-in\ settings<TAB>:GitSupportSettings   :call GitS_PluginSettings()<CR>'
	"
	" Main Menu - open buffers
	let ahead = 'amenu          '.s:Git_RootMenu.'.'
	let shead = 'amenu <silent> '.s:Git_RootMenu.'.'
	"
	exe ahead.'-Sep01-                      :'
	"
	exe ahead.'&run\ git<TAB>:Git           :Git<space>'
	exe shead.'&branch<TAB>:GitBranch       :GitBranch<CR>'
	exe ahead.'&help\ \.\.\.<TAB>:GitHelp   :GitHelp<space>'
	exe shead.'&log<TAB>:GitLog             :GitLog<CR>'
	exe shead.'&remote<TAB>:GitRemote       :GitRemote<CR>'
	exe shead.'&status<TAB>:GitStatus       :GitStatus<CR>'
	exe shead.'&tag<TAB>:GitTag             :GitTag<CR>'
	"
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
		amenu   <silent> 40.1000 &Tools.-SEP100- :
		amenu   <silent> 40.1080 &Tools.Load\ Git\ Support   :call Git_AddMenus()<CR>
	elseif a:action == 'loading'
		aunmenu <silent> &Tools.Load\ Git\ Support
		amenu   <silent> 40.1080 &Tools.Unload\ Git\ Support :call Git_RemoveMenus()<CR>
	elseif a:action == 'unloading'
		aunmenu <silent> &Tools.Unload\ Git\ Support
		amenu   <silent> 40.1080 &Tools.Load\ Git\ Support   :call Git_AddMenus()<CR>
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
