"===============================================================================
"
"          File:  git-support.vim
" 
"   Description:  Provides access to Git's functionality from inside Vim.
" 
"   VIM Version:  7.0+
"        Author:  Wolfgang Mehner, wolfgang-mehner@web.de
"  Organization:  
"       Version:  see variable g:GitSupport_Version below
"       Created:  06.10.2012
"      Revision:  22.03.2013
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
let g:GitSupport_Version= '0.9'     " version number of this script; do not change
"
"-------------------------------------------------------------------------------
" Auxiliary functions.   {{{1
"-------------------------------------------------------------------------------
"
"-------------------------------------------------------------------------------
" s:ErrorMsg : Print an error message.   {{{2
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
" s:ChangeCWD : Check the buffer and the CWD.   {{{2
"
" First check the current working directory:
"   let data = s:CheckCWD ()
" then jump to the Git buffer:
"   call s:OpenGitBuffer ( 'Git - <name>' )
" then call this function to correctly set the directory of the buffer:
"   call s:ChangeCWD ()
"
" The function s:ChangeCWD queries the working directory of the buffer your
" starting out in, which is the buffer where you called the Git command. The
" call to s:OpenGitBuffer then opens the requested buffer or jumps to it if it
" already exists. Finally, s:ChangeCWD sets the working directory of the Git
" buffer.
"-------------------------------------------------------------------------------
"
function! s:ChangeCWD ( data )
	"
	" call originated from outside the Git buffer?
	" also the case for a new buffer
	if bufnr('%') != a:data[0]
		"echomsg '2 - call from outside: '.a:data[0]
		let b:GitSupport_CWD = a:data[1]
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
" Usage: see s:ChangeCWD
"-------------------------------------------------------------------------------
"
function! s:CheckCWD ()
	"echomsg '1 - calling from: '.getcwd()
	return [ bufnr('%'), getcwd() ]
endfunction    " ----------  end of function s:CheckCWD  ----------
"
"-------------------------------------------------------------------------------
" s:EscapeCurrent : Escape the name of the current file for the shell,   {{{2
"     and prefix it with "--".
"-------------------------------------------------------------------------------
"
function! s:EscapeCurrent ()
	return '-- '.shellescape ( expand ( '%' ) )
endfunction    " ----------  end of function s:EscapeCurrent  ----------
"
"-------------------------------------------------------------------------------
" s:EscapeFile : Escape a file for usage on the shell.   {{{2
"-------------------------------------------------------------------------------
"
function! s:EscapeFile ( file )
	return shellescape ( a:file )
endfunction    " ----------  end of function s:EscapeFile  ----------
"
"-------------------------------------------------------------------------------
" s:GetGlobalSetting : Get a setting from a global variable.   {{{2
"-------------------------------------------------------------------------------
"
function! s:GetGlobalSetting ( varname )
	if exists ( 'g:'.a:varname )
		exe 'let s:'.a:varname.' = g:'.a:varname
	endif
endfunction    " ----------  end of function s:GetGlobalSetting  ----------
"
"-------------------------------------------------------------------------------
" s:GitCmdLineArgs : Get the base directory of a repository.   {{{2
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
		return ''
	endif
	"
endfunction    " ----------  end of function s:GitCmdLineArgs  ----------
"
"-------------------------------------------------------------------------------
" s:GitRepoBase : Get the base directory of a repository.   {{{2
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
"-------------------------------------------------------------------------------
"
function! s:ImportantMsg ( ... )
	echohl Search
	for line in a:000
		echomsg line
	endfor
	echohl None
endfunction    " ----------  end of function s:ImportantMsg  ----------
"
"-------------------------------------------------------------------------------
" s:VersionLess : Compare two version numbers.   {{{2
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
"
"-------------------------------------------------------------------------------
" Modul setup.   {{{1
"-------------------------------------------------------------------------------
"
" platform specifics   {{{2
"
let s:MSWIN = has("win16") || has("win32")   || has("win64")     || has("win95")
let s:UNIX	= has("unix")  || has("macunix") || has("win32unix")
"
" let s:CmdLineEscChar = ' |"\'
" if s:MSWIN
" 	let s:FilenameEscChar = ''
" else
" 	let s:FilenameEscChar = ' \%#[]'
" endif
"
" settings   {{{2
"
let s:Git_Executable = 'git'      " Git's executable
let s:Git_LoadMenus  = 'yes'      " load the menus?
let s:Git_RootMenu   = '&Git'     " name of the root menu
"
if ! exists ( 's:MenuVisible' )
	let s:MenuVisible = 0           " menus are not visible at the moment
endif
"
call s:GetGlobalSetting ( 'Git_Executable' )
call s:GetGlobalSetting ( 'Git_LoadMenus' )
call s:GetGlobalSetting ( 'Git_RootMenu' )
"
let s:Enabled = 1
let s:DisabledReason = ""
let s:DisabledMessage = "Git-Support not working:"
let s:GitVersion = ""
let s:GitHelpFormat = ""
"
" check Git executable   {{{2
"
if s:Git_Executable =~ '^LANG=\w\+\s.'
	if ! executable ( matchstr ( s:Git_Executable, '^LANG=\w\+\s\+\zs.\+$' ) )
		let s:Enabled = 0
		let s:DisabledReason = "Git not executable: ".s:Git_Executable
	endif
elseif s:Git_Executable =~ '^\(["'']\)\zs.\+\ze\1'
	if ! executable ( matchstr ( s:Git_Executable, '^\(["'']\)\zs.\+\ze\1' ) )
		let s:Enabled = 0
		let s:DisabledReason = "Git not executable: ".s:Git_Executable
	endif
else
	if ! executable ( s:Git_Executable )
		let s:Enabled = 0
		let s:DisabledReason = "Git not executable: ".s:Git_Executable
	endif
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
	command  -bang -nargs=* -complete=file Git                    :call GitS_Run('<args>','<bang>'=='!'?'b':'')
	command!       -nargs=* -complete=file GitRun                 :call GitS_Run('<args>','')
	command!       -nargs=* -complete=file GitBuf                 :call GitS_Run('<args>','b')
	command! -bang -nargs=* -complete=file GitAdd                 :call GitS_Add('<args>','<bang>'=='!'?'ef':'e')
	command!       -nargs=* -complete=file GitBlame               :call GitS_Blame('update','<args>')
	command!       -nargs=* -complete=file GitBranch              :call GitS_Branch('<args>','')
	command!       -nargs=* -complete=file GitCheckout            :call GitS_Checkout('<args>','ce')
	command!       -nargs=* -complete=file GitCommit              :call GitS_Commit('direct','<args>','')
	command!       -nargs=? -complete=file GitCommitFile          :call GitS_Commit('file','<args>','')
	command!       -nargs=0                GitCommitMerge         :call GitS_Commit('merge','','')
	command!       -nargs=+                GitCommitMsg           :call GitS_Commit('msg','<args>','')
	command!       -nargs=* -complete=file GitDiff                :call GitS_Diff('update','<args>')
	command!       -nargs=*                GitFetch               :call GitS_Fetch('<args>','')
	command!       -nargs=*                GitHelp                :call GitS_Help('update','<args>')
	command!       -nargs=* -complete=file GitLog                 :call GitS_Log('update','<args>')
	command!       -nargs=*                GitMerge               :call GitS_Merge('<args>','')
	command!       -nargs=* -complete=file GitMove                :call GitS_Move('<args>','')
	command!       -nargs=* -complete=file GitMv                  :call GitS_Move('<args>','')
	command!       -nargs=*                GitPull                :call GitS_Pull('<args>','')
	command!       -nargs=*                GitPush                :call GitS_Push('<args>','')
	command!       -nargs=* -complete=file GitRemote              :call GitS_Remote('<args>','')
	command!       -nargs=* -complete=file GitRemove              :call GitS_Remove('<args>','e')
	command!       -nargs=* -complete=file GitRm                  :call GitS_Remove('<args>','e')
	command!       -nargs=* -complete=file GitReset               :call GitS_Reset('<args>','e')
	command!       -nargs=* -complete=file GitShow                :call GitS_Show('update','<args>')
	command!       -nargs=*                GitStash               :call GitS_Stash('<args>','')
	command!       -nargs=0                GitStatus              :call GitS_Status('update')
	command!       -nargs=*                GitTag                 :call GitS_Tag('<args>','')
else
	command! -bang -nargs=*                Git                    :call GitS_Help('disabled')
	command!       -nargs=*                GitHelp                :call GitS_Help('disabled')
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
"
highlight default link GitAdd         DiffAdd
highlight default link GitRemove      DiffDelete
highlight default link GitConflict    DiffText
"
" }}}2
"
"-------------------------------------------------------------------------------
" s:Question : Ask the user a question.   {{{1
"-------------------------------------------------------------------------------
"
function! s:Question ( text, ... )
	"
	let ret = -2
	"
	if a:0 == 0 || a:1 == 'normal'
		echohl Search                               " highlight prompt
	elseif a:1 == 'warning'
		echohl Error                                " highlight prompt
	else
		echoerr 'Unknown option : "'.a:1.'"'
		return
	end
	"
	echo a:text.' [y/n]: '
	"
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
	echohl None                                   " reset highlighting
	"
	return ret
endfunction    " ----------  end of function s:Question  ----------
"
"-------------------------------------------------------------------------------
" s:OpenGitBuffer : Put output in a read-only buffer.   {{{1
"-------------------------------------------------------------------------------
"
function! s:OpenGitBuffer ( buf_name )
	"
	" a buffer like this already exists?
	if bufnr ( a:buf_name ) != -1
		" yes -> go to the window containing the buffer
		exe bufwinnr( a:buf_name ).'wincmd w'
		return 0
	endif
	"
	" no -> open a new window
	aboveleft new
	silent exe 'file '.escape( a:buf_name, ' ' )
	"
	" settings of the new buffer
	setlocal noswapfile
	setlocal bufhidden=wipe
	setlocal tabstop=8
	setlocal foldmethod=syntax
	"
	return 1
endfunction    " ----------  end of function s:OpenGitBuffer  ----------
"
"-------------------------------------------------------------------------------

" s:UpdateGitBuffer : Put output in a read-only buffer.   {{{1
"-------------------------------------------------------------------------------
"
function! s:UpdateGitBuffer ( command )
	"
	" save the position
	let pos = line('.')
	"
	" delete the previous contents
	setlocal modifiable
	setlocal noro
	silent exe '1,$delete'
	"
	" insert the output of the command
	let text = system ( a:command )
	"
	silent exe 'put! = text'
	"
	" delete the last line (empty) and return to position
 	normal zR
	normal Gdd
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
" Flags:
" - c : Ask for confirmation.
" - e : Expand empty 'param' to current buffer.
"-------------------------------------------------------------------------------
"
function! s:StandardRun( cmd, param, flags, ... )
	"
	if a:0 == 0
		let flag_check = '[^ce]'
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
	if a:flags =~ 'c' && s:Question ( 'Execute "'.cmd.'"?' ) != 1
		echo "aborted"
		return
	endif
	"
	let text = system ( cmd )
	"
	if v:shell_error == 0 && text =~ '^\_s*$'
		echo "ran successfully"               | " success
	elseif v:shell_error == 0
		echo "ran successfully:\n".text       | " success
	else
		echo "\"".cmd."\" failed:\n\n".text   | " failure
	endif
	"
endfunction    " ----------  end of function s:StandardRun  ----------
"
"-------------------------------------------------------------------------------
" GitS_Fold : fold text for 'git log'   {{{1
"-------------------------------------------------------------------------------
"
function! GitS_Fold ()
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
endfunction    " ----------  end of function GitS_Fold  ----------
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
" - c : Ask for confirmation.
" - e : Expand empty 'param' to current buffer.
" - f : Force add (cmdline param -f).
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
	let cmd = s:Git_Executable.' add '
	"
	if a:flags =~ 'f' | let cmd .= '-f ' | endif
	"
	let cmd .= param
	"
	if a:flags =~ 'c' && s:Question ( 'Execute "'.cmd.'"?' ) != 1
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
function! GitS_Blame( action, ... )
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
		elseif empty( a:1 ) | let param = s:EscapeCurrent()
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
	if s:OpenGitBuffer ( 'Git - blame' )
		"
		let b:GitSupport_BlameFlag = 1
		"
" 		setlocal filetype=gitsdiff
		"
		exe 'nmap          <buffer> <S-F1> :call GitS_Blame("help")<CR>'
		exe 'nmap <silent> <buffer> q      :call GitS_Blame("quit")<CR>'
		exe 'nmap <silent> <buffer> u      :call GitS_Blame("update")<CR>'
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
	let cmd = s:Git_Executable.' blame '.param
	"
	call s:UpdateGitBuffer ( cmd )
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
	call s:UpdateGitBuffer ( cmd )
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
" - c : Ask for confirmation.
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
			let cmd = s:Git_Executable.' commit '.a:param
			"
		endif
		"
	elseif a:mode == 'file'
		"
		" message from file
		if empty( a:param ) | let cmd = s:Git_Executable.' commit -F '.s:EscapeFile( expand('%') )
		else                | let cmd = s:Git_Executable.' commit -F '.a:param
		endif
		"
	elseif a:mode == 'merge'
		"
		" message from ./.git/MERGE_MSG file
		let file = s:GitRepoBase ()
		"
		" could not get base?
		if file == '' | return | endif
		"
		let file .= '/.git/MERGE_MSG'
		"
		" not readable?
		if ! filereadable ( file )
			echo 'could not read the file ".git/MERGE_MSG" /'
						\ .' there does not seem to be a merge conflict (see :help GitCommitMerge)'
			return
		endif
		"
		" commit
		let cmd = s:Git_Executable.' commit -F '.s:EscapeFile( file )
		"
	elseif a:mode == 'msg'
		" message from command line
		let cmd = s:Git_Executable.' commit -m "'.a:param.'"'
	else
		echoerr 'Unknown mode "'.a:mode.'".'
		return
	endif
	"
	if a:flags =~ 'c' && s:Question ( 'Execute "'.cmd.'"?' ) != 1
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
	if s:OpenGitBuffer ( 'Git - commit --dry-run' )
		"
		let b:GitSupport_CommitDryRunFlag = 1
		"
		setlocal filetype=gitsstatus
		setlocal foldtext=GitS_Fold()
		"
		exe 'nmap          <buffer> <S-F1> :call GitS_CommitDryRun("help")<CR>'
		exe 'nmap <silent> <buffer> q      :call GitS_CommitDryRun("quit")<CR>'
		exe 'nmap <silent> <buffer> u      :call GitS_CommitDryRun("update")<CR>'
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
	let cmd = s:Git_Executable.' commit --dry-run '.param
	"
	call s:UpdateGitBuffer ( cmd )
	"
endfunction    " ----------  end of function GitS_CommitDryRun  ----------
"
"-------------------------------------------------------------------------------
" GitS_Diff : execute 'git diff ...'   {{{1
"-------------------------------------------------------------------------------
"
function! GitS_Diff( action, ... )
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
		elseif empty( a:1 ) | let param = s:EscapeCurrent()
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
	if s:OpenGitBuffer ( 'Git - diff' )
		"
		let b:GitSupport_DiffFlag = 1
		"
		setlocal filetype=gitsdiff
		setlocal foldtext=GitS_Fold()
		"
		exe 'nmap          <buffer> <S-F1> :call GitS_Diff("help")<CR>'
		exe 'nmap <silent> <buffer> q      :call GitS_Diff("quit")<CR>'
		exe 'nmap <silent> <buffer> u      :call GitS_Diff("update")<CR>'
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
	let cmd = s:Git_Executable.' diff '.param
	"
	call s:UpdateGitBuffer ( cmd )
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
" GitS_Help : execute 'git help'   {{{1
"-------------------------------------------------------------------------------
"
function! GitS_Help( action, ... )
	"
	let helpcmd = ''
	"
	if a:action == 'disabled'
		call s:ImportantMsg ( s:DisabledMessage, s:DisabledReason )
		return
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
		echo 'test'
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
		setlocal foldtext=GitS_Fold()
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
function! GitS_Merge( param, flags )
	"
	return s:StandardRun ( 'merge', a:param, a:flags, 'c' )
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
	call s:UpdateGitBuffer ( cmd )
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
		setlocal foldtext=GitS_Fold()
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
	if a:0 == 0
		let param = b:GitSupport_Param
	else
		let b:GitSupport_Param = param
	endif
	"
	let cmd = s:Git_Executable.' stash '.param
	"
	call s:UpdateGitBuffer ( cmd )
	"
endfunction    " ----------  end of function GitS_StashList  ----------
"
"-------------------------------------------------------------------------------
" GitS_StashShow : execute 'git stash show ...'   {{{1
"-------------------------------------------------------------------------------
"
function! GitS_StashShow( action, ... )
	"
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
	if a:0 == 0
		let param = b:GitSupport_Param
	else
		let b:GitSupport_Param = param
	endif
	"
	let cmd = s:Git_Executable.' stash '.param
	"
	call s:UpdateGitBuffer ( cmd )
	"
endfunction    " ----------  end of function GitS_StashShow  ----------
"
"-------------------------------------------------------------------------------
" Status : Auxiliary   {{{1
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
			\ }
"
"-------------------------------------------------------------------------------
" s:Status_GetFile : Get the file under the cursor and its status. {{{2
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
			call s:ErrorMsg ( 'No file under the cursor.' )
			return []
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
			call s:ErrorMsg ( 'Unknown section, aborting.' )
			return []
		endif
		"
		let [ f_status, f_name ] = matchlist( line, '^\(..\)\s\(.*\)' )[1:2]
		"
	else
		"
		" regular output
		"
		let c_pos  = line('.')
		let h_pos  = c_pos
		let s_head = ''
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
			call s:ErrorMsg ( 'Not in any section.' )
			return []
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
			call s:ErrorMsg ( 'Unknown section "'.s_head.'", aborting.' )
			return []
		endif
		"
		" get the filename
		if s_code =~ '[smc]'
			let mlist = matchlist( getline(c_pos), '^#\t\([[:alnum:][:space:]]\+\):\s\+\(\S.*\)$' )
		else
			let mlist = matchlist( getline(c_pos), '^#\t\(\)\(\S.*\)$' )
		endif
		"
		" check the filename
		if empty( mlist )
			call s:ErrorMsg ( 'No file under the cursor.' )
			return []
		endif
		"
		let [ f_status, f_name ] = mlist[1:2]
		"
		if s_code == 'c'
			let f_status = 'conflict'
		endif
		"
	endif
	"
	if f_name =~ '^".\+"$'
		let f_name = substitute ( f_name, '\_^"\|"\_$', '', 'g' )
		let f_name = substitute ( f_name, '\\\(.\)', '\1', 'g' )
	endif
	"
	return [ s_code, f_status, f_name ]
	"
endfunction    " ----------  end of function s:Status_GetFile  ----------
"
"-------------------------------------------------------------------------------
" s:Status_FileAction : Execute a command for the file under the cursor. {{{2
"-------------------------------------------------------------------------------
"
function! s:Status_FileAction( action )
	"
	" the file under the cursor
	let fileinfo = s:Status_GetFile()
	"
	if empty( fileinfo )
		return 0
	endif
	"
	let [ s_code, f_status, f_name ] = fileinfo
	"
	" section / action
	"                 | edit  | diff  log   | add   ckout reset rm
	" staged    (b/s) |  x    |  x     x    |  -     -     x     -
	" modified  (b/m) |  x    |  x     x    |  x     x     -     ?
	" untracked (u)   |  x    |  -     -    |  x     -     -     -
	" ignored   (i)   |  x    |  -     -    |  x     -     -     -
	" unmerged  (c)   |  x    |  x     x    |  x     -     -     x
	"  (ckout = checkout)
	"
	" in section 'modified': action 'rm' only for status 'deleted'
	"
	let f_name_esc = '-- '.s:EscapeFile( f_name )
	"
	if a:action == 'edit'
		"
		" any section, action "edit"
		belowright new
		exe "edit ".fnameescape( f_name )
		"
	elseif s_code =~ '[bsmc]' && a:action == 'diff'
		"
		" section "staged", "modified" or "conflict", action "diff"
		call GitS_Diff( 'update', f_name_esc )
		"
	elseif s_code =~ '[bsmc]' && a:action == 'log'
		"
		" section "staged", "modified" or "conflict", action "log"
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
	elseif s_code =~ '[bs]' && a:action == 'reset'
		"
		" section "staged", action "reset"
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
"
"-------------------------------------------------------------------------------
" GitS_Status : execute 'git status'   {{{1
"-------------------------------------------------------------------------------
"
function! GitS_Status( action )
	"
	if a:action == 'help'
		let txt  = s:HelpTxtStd."\n\n"
		let txt .= "i       : toggle \"show ignored files\"\n"
		let txt .= "s       : toggle \"short output\"\n"
		let txt .= "v       : toggle \"verbose output\"\n"
		let txt .= "\n"
		let txt .= "a       : file under cursor: add\n"
		let txt .= "c       : file under cursor: checkout\n"
		let txt .= "od      : file under cursor: open diff\n"
		let txt .= "of      : file under cursor: open file (edit)\n"
		let txt .= "ol      : file under cursor: open log\n"
		let txt .= "r       : file under cursor: reset\n"
		let txt .= "r       : file under cursor: remove (only for unmerged changes)"
		echo txt
		return
	elseif a:action == 'quit'
		close
		return
	elseif a:action == 'update'
		" noop
	elseif a:action == 'ignored'
		if ! s:HasStatusIgnore
			call s:ErrorMsg ( '"show ignored files" not available in Git version '.s:GitVersion.'.' )
			return
		endif
	elseif a:action =~ '\<\%(short\|verbose\)\>'
		" noop
	elseif a:action =~ '\<\%(add\|checkout\|diff\|edit\|log\|reset\)\>'
		"
		if getline('.') =~ '^#' || b:GitSupport_ShortOption
			if s:Status_FileAction ( a:action )
				call GitS_Status( 'update' )
			endif
		else
			call s:ErrorMsg ( 'Not in status section.' )
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
	if s:OpenGitBuffer ( 'Git - status' )
		"
		let b:GitSupport_StatusFlag = 1
		let b:GitSupport_IgnoredOption    = 0
		let b:GitSupport_ShortOption      = 0
		let b:GitSupport_VerboseOption    = 0
		"
		setlocal filetype=gitsstatus
		setlocal foldtext=GitS_Fold()
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
	call s:UpdateGitBuffer ( cmd )
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
	if a:0 == 0
		let param = b:GitSupport_Param
	else
		let b:GitSupport_Param = param
	endif
	"
	let cmd = s:Git_Executable.' tag '.param
	"
	call s:UpdateGitBuffer ( cmd )
	"
endfunction    " ----------  end of function GitS_TagList  ----------
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
	"
	exe ahead.'Commands<TAB>Git :echo "This is a menu header!"<CR>'
	exe ahead.'-Sep00-          :'
	"
	exe ahead.'&add<TAB>:GitAdd           :GitAdd<space>'
	exe ahead.'&blame<TAB>:GitBlame       :GitBlame<space>'
	exe ahead.'&branch<TAB>:GitBranch     :GitBranch<space>'
	exe ahead.'&checkout<TAB>:GitCheckout :GitCheckout<space>'
	exe ahead.'&commit<TAB>:GitCommit     :GitCommit<space>'
	exe ahead.'&diff<TAB>:GitDiff         :GitDiff<space>'
	exe ahead.'&fetch<TAB>:GitFetch       :GitFetch<space>'
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
	"
	" Current File
	let ahead = 'amenu '.s:Git_RootMenu.'.&file.'
	"
	exe ahead.'Current\ File<TAB>Git :echo "This is a menu header!"<CR>'
	exe ahead.'-Sep00-               :'
	"
	exe ahead.'&add<TAB>:GitAdd           :GitAdd<CR>'
	exe ahead.'&blame<TAB>:GitBlame       :GitBlame<CR>'
	exe ahead.'&checkout<TAB>:GitCheckout :GitCheckout<CR>'
	exe ahead.'&diff<TAB>:GitDiff         :GitDiff<CR>'
	exe ahead.'r&m<TAB>:GitRm             :GitRm<CR>'
	exe ahead.'&reset<TAB>:GitReset       :GitReset<CR>'
	"
	" Specials
	let ahead = 'amenu '.s:Git_RootMenu.'.spe&cials.'
	"
	exe ahead.'Specials<TAB>Git :echo "This is a menu header!"<CR>'
	exe ahead.'-Sep00-          :'
	"
	exe ahead.'&commit,\ msg\ from\ file<TAB>:GitCommitFile   :GitCommitFile<space>'
	exe ahead.'&commit,\ msg\ from\ merge<TAB>:GitCommitMerge :GitCommitMerge<CR>'
	exe ahead.'&commit,\ msg\ from\ cmdline<TAB>:GitCommitMsg :GitCommitMsg<space>'
	"
	" Open Buffers
	let ahead = 'amenu '.s:Git_RootMenu.'.'
	"
	exe ahead.'-Sep01-                      :'
	exe ahead.'&run\ git<TAB>:Git           :Git<space>'
	exe ahead.'&branch<TAB>:GitBranch       :GitBranch<CR>'
	exe ahead.'&help\ \.\.\.<TAB>:GitHelp   :GitHelp<space>'
	exe ahead.'&log<TAB>:GitLog             :GitLog<CR>'
	exe ahead.'&remote<TAB>:GitRemote       :GitRemote<CR>'
	exe ahead.'&status<TAB>:GitStatus       :GitStatus<CR>'
	exe ahead.'&tag<TAB>:GitTag             :GitTag<CR>'
	"
endfunction    " ----------  end of function s:InitMenus  ----------
"
"-------------------------------------------------------------------------------
" s:ToolMenu : Add or remove tool menu entries.   {{{1
"-------------------------------------------------------------------------------
"
function! s:ToolMenu( action )
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
endfunction    " ----------  end of function s:ToolMenu  ----------
"
"-------------------------------------------------------------------------------
" Git_AddMenus : Add menus.   {{{1
"-------------------------------------------------------------------------------
"
function! Git_AddMenus()
	if s:MenuVisible == 0 && has ( 'menu' )
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
	if s:MenuVisible == 1 && has ( 'menu' )
		" destroy if visible
		call s:ToolMenu ( 'unloading' )
		exe 'aunmenu <silent> '.s:Git_RootMenu
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
if has ( 'menu' )
	call s:ToolMenu ( 'setup' )
endif
"
" load the menus right now?
if s:Git_LoadMenus == 'yes'
	call Git_AddMenus ()
endif
"
" }}}1
"
" =====================================================================================
"  vim: foldmethod=marker
