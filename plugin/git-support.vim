"===============================================================================
"
"          File:  git-support.vim
" 
"   Description:  Provides access to Git's functionality from inside Vim.
" 
"   VIM Version:  7.0+
"        Author:  Wolfgang Mehner, wolfgang-mehner@web.de
"  Organization:  
"       Version:  0.1
"       Created:  06.10.2012
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
let g:GitSupport_Version= '0.1'     " version number of this script; do not change
"
"-------------------------------------------------------------------------------
" Modul setup.   {{{1
"-------------------------------------------------------------------------------
"
"-------------------------------------------------------------------------------
" s:VersionLess : Compare two version numbers.   {{{2
"-------------------------------------------------------------------------------
function! s:VersionLess ( v1, v2 )
	"
	let l1 = matchlist( a:v1, '^\(\d\+\)\.\(\d\+\)\%(\.\(\d\+\)\)\?\%(\.\(\d\+\)\)\?$' )
	let l2 = matchlist( a:v2, '^\(\d\+\)\.\(\d\+\)\%(\.\(\d\+\)\)\?\%(\.\(\d\+\)\)\?$' )
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
let s:MSWIN = has("win16") || has("win32")   || has("win64")     || has("win95")
let s:UNIX	= has("unix")  || has("macunix") || has("win32unix")
"
let s:SettingsEscChar = ' |"\'
if s:MSWIN
	let s:FilenameEscChar = ''
else
	let s:FilenameEscChar = ' \%#[]'
endif
"
" added in 1.7.2:
" - "git status --ignored"
" - "git status -s -b"
let s:HasStatusIgnore = 0
let s:HasStatusBranch = 0
"
let s:GitVersion = system( 'git --version' )
if s:GitVersion =~ 'git version [0-9.]\+'
	let s:GitVersion = matchstr( s:GitVersion, 'git version \zs[0-9.]\+' )
	"
	if ! s:VersionLess ( s:GitVersion, '1.7.2' )
		let s:HasStatusIgnore = 1
		let s:HasStatusBranch = 1
	endif
	"
else
	echoerr 'Can not obtain the version number of Git.'
endif
"
let s:HelpTxtStd  = "S-F1    : help\n"
let s:HelpTxtStd .= "q       : close\n"
let s:HelpTxtStd .= "u       : update"
"
let s:HelpTxtStdNoUpdate  = "S-F1    : help\n"
let s:HelpTxtStdNoUpdate .= "q       : close"
"
command! -bang -nargs=* -complete=file GitAdd                 :call GitS_Add('<args>','<bang>'=='!',1)
command!       -nargs=0                GitBranch              :call GitS_Branch('update')
command!       -nargs=* -complete=file GitCheckout            :call GitS_Checkout('direct','<args>',1)
command!       -nargs=* -complete=file GitCheckoutFiles       :call GitS_Checkout('files','<args>',1)
command!       -nargs=* -complete=file GitCommit              :call GitS_Commit('direct','<args>',1)
command!       -nargs=? -complete=file GitCommitFile          :call GitS_Commit('file','<args>',1)
command!       -nargs=+                GitCommitMsg           :call GitS_Commit('msg','<args>',1)
command!       -nargs=* -complete=file GitDiff                :call GitS_Diff('update','<args>')
command!       -nargs=?                GitHelp                :call GitS_Help('update','<args>')
command!       -nargs=0                GitLog                 :call GitS_Log('update')
command!       -nargs=0                GitRemote              :call GitS_Remote('update')
command!       -nargs=* -complete=file GitReset               :call GitS_Reset('<args>',1)
command!       -nargs=0                GitStatus              :call GitS_Status('update')
"
"-------------------------------------------------------------------------------
" s:Question : Ask the user a question.   {{{1
"-------------------------------------------------------------------------------
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
" s:OpenManBuffer : Put output in a read-only buffer.   {{{1
"-------------------------------------------------------------------------------
function! s:OpenManBuffer ( buf_name )
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
endfunction    " ----------  end of function s:OpenManBuffer  ----------
"
"-------------------------------------------------------------------------------
" s:UpdateManBuffer : Put output in a read-only buffer.   {{{1
"-------------------------------------------------------------------------------
function! s:UpdateManBuffer ( command )
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
endfunction    " ----------  end of function s:UpdateManBuffer  ----------
"
"-------------------------------------------------------------------------------
" GitS_Add : execute 'git add ...'   {{{1
"-------------------------------------------------------------------------------
"
function! GitS_Add( files, force, confirmation )
	"
	if empty( a:files )
		let files = expand ( '%' )
	else
		let files = a:files
	endif
	"
	let cmd = 'git add '
	"
	if a:force | let cmd .= '-f ' | endif
	"
	let cmd .= '-- '.files
	"
	if a:confirmation && s:Question ( 'Execute "'.cmd.'"?' ) != 1
		echo "aborted"
		return
	endif
	"
	let text = system ( cmd )
	"
	if v:shell_error == 0
		" success
		echo "ran successfully"
	else
		" failure
		echo "\"".cmd."\" failed:\n\n".text
		if ! a:force
			echo "\nUse \":GitAdd! ...\" to force adding the files.\n"
		endif
	endif
	"
endfunction    " ----------  end of function GitS_Add  ----------
"
"-------------------------------------------------------------------------------
" GitS_Branch : execute 'git branch'   {{{1
"-------------------------------------------------------------------------------
"
function! GitS_Branch( action )
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
	if s:OpenManBuffer ( 'Git : branch' )
		"
		let b:GitSupportBranchFlag = 1
		"
		setlocal filetype=gitsbranch
		"
		exe 'nmap          <buffer> <S-F1> :call GitS_Branch("help")<CR>'
		exe 'nmap <silent> <buffer> q      :call GitS_Branch("quit")<CR>'
		exe 'nmap <silent> <buffer> u      :call GitS_Branch("update")<CR>'
	endif
	"
	let cmd = 'git branch -avv'
	"
	call s:UpdateManBuffer ( cmd )
	"
endfunction    " ----------  end of function GitS_Branch  ----------
"
"-------------------------------------------------------------------------------
" GitS_Checkout : execute 'git checkout ...'   {{{1
"-------------------------------------------------------------------------------
"
function! GitS_Checkout( mode, what, confirmation )
	"
	if a:mode == 'direct'
		" checkout ...
		let cmd = 'git checkout '.a:what
	elseif a:mode == 'files'
		"
		" checkout files
		"
		if empty( a:what ) | let files = expand ( '%' )
		else               | let files = a:what
		endif
		"
		let cmd = 'git checkout -- '.files
		"
	else
		echoerr 'Unknown mode "'.a:mode.'".'
		return
	endif
	"
	if a:confirmation && s:Question ( 'Execute "'.cmd.'"?' ) != 1
		echo "aborted"
		return
	endif
	"
	let text = system ( cmd )
	"
	if v:shell_error == 0
		" success
		echo "ran successfully"
	else
		" failure
		echo "\"".cmd."\" failed:\n\n".text
	endif
	"
endfunction    " ----------  end of function GitS_Checkout  ----------
"
"-------------------------------------------------------------------------------
" GitS_Commit : execute 'git checkout ...'   {{{1
"-------------------------------------------------------------------------------
"
function! GitS_Commit( mode, what, confirmation )
	"
	if a:mode == 'direct'
		" commit ...
		let cmd = 'git commit '.a:what
	elseif a:mode == 'file'
		"
		" message from file

		if empty( a:what ) | let file = expand ( '%' )
		else               | let file = a:what
		endif
		"
		let cmd = 'git commit -F '.file
		"
	elseif a:mode == 'msg'
		"
		" message from command line
		let cmd = 'git commit -m "'.a:what.'"'
		"
	else
		echoerr 'Unknown mode "'.a:mode.'".'
		return
	endif
	"
	if a:confirmation && s:Question ( 'Execute "'.cmd.'"?' ) != 1
		echo "aborted"
		return
	endif
	"
	let text = system ( cmd )
	"
	if v:shell_error == 0
		" success
		echo "ran successfully"
	else
		" failure
		echo "\"".cmd."\" failed:\n\n".text
	endif
	"
endfunction    " ----------  end of function GitS_Commit  ----------
"
"-------------------------------------------------------------------------------
" GitS_Diff : execute 'git diff ...'   {{{1
"-------------------------------------------------------------------------------
"
function! GitS_Diff( action, ... )
	"
	" TODO: change working directories
	"
	let files = ''
	"
	if a:action == 'help'
		echo s:HelpTxtStd
		return
	elseif a:action == 'quit'
		close
		return
	elseif a:action == 'update'
		if a:0 == 0
			" noop
		elseif empty( a:1 )
			let files = expand ( '%' )
		else
			let files = a:1
		endif
	else
		echoerr 'Unknown action "'.a:action.'".'
		return
	endif
	"
	if s:OpenManBuffer ( 'Git : diff' )
		"
		let b:GitSupportDiffFlag = 1
		"
		let b:GitSupportCWD = getcwd ()
		"
		setlocal filetype=gitsstatus
		"
		exe 'nmap          <buffer> <S-F1> :call GitS_Diff("help")<CR>'
		exe 'nmap <silent> <buffer> q      :call GitS_Diff("quit")<CR>'
		exe 'nmap <silent> <buffer> u      :call GitS_Diff("update")<CR>'
	endif
	"
	if a:0 == 0
		let files = b:GitSupportFiles
	else
		let b:GitSupportFiles = files
	endif
	"
	let cmd = 'git diff -- '.files
	"
	call s:UpdateManBuffer ( cmd )
	"
endfunction    " ----------  end of function GitS_Diff  ----------
"
"-------------------------------------------------------------------------------
" GitS_Help : execute 'git log'   {{{1
"-------------------------------------------------------------------------------
"
function! GitS_Help( action, ... )
	"
	let helpcmd = ''
	"
	if a:action == 'help'
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
" 		for i in range( 1, len(b:GitSupportTOC) )
" 			echo i.' - '.b:GitSupportTOC[i-1][1]
" 		endfor
" 		return
	else
		echoerr 'Unknown action "'.a:action.'".'
		return
	endif
	"
	if s:OpenManBuffer ( 'Git : help' )
		"
		let b:GitSupportHelpFlag = 1
		"
		setlocal filetype=man
		"
		exe 'nmap          <buffer> <S-F1> :call GitS_Help("help")<CR>'
		exe 'nmap <silent> <buffer> q      :call GitS_Help("quit")<CR>'
		"
		exe 'nmap <silent> <buffer> c      :call GitS_Help("toc")<CR>'
	endif
	"
	let cmd = 'git help '.helpcmd
	"
	call s:UpdateManBuffer ( cmd )
	"
" 	let b:GitSupportTOC = []
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
" 		call add ( b:GitSupportTOC, [ pos, item ] )
"  		"
"  	endwhile
" 	"
" 	call setpos ('.',cpos)
	"
endfunction    " ----------  end of function GitS_Help  ----------
"
"-------------------------------------------------------------------------------
" GitS_LogFold : fold text for 'git log'   {{{1
"-------------------------------------------------------------------------------
"
function! GitS_LogFold ()
	" search for the first line which starts with a space
	" -> this is the first line of the commit message
	let pos = v:foldstart
	while pos <= v:foldend
		if getline(pos) =~ '^\s\+\S'
			break
		endif
		let pos += 1
	endwhile
	if pos > v:foldend | let pos = v:foldstart | endif
	return v:folddashes.' '.substitute( getline(pos), '^\s\+', '', '' ).' '
endfunction    " ----------  end of function GitS_LogFold  ----------
"
"-------------------------------------------------------------------------------
" GitS_Log : execute 'git log'   {{{1
"-------------------------------------------------------------------------------
"
function! GitS_Log( action )
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
	if s:OpenManBuffer ( 'Git : log' )
		"
		let b:GitSupportLogFlag = 1
		"
		setlocal filetype=gitslog
		setlocal foldtext=GitS_LogFold()
		"
		exe 'nmap          <buffer> <S-F1> :call GitS_Log("help")<CR>'
		exe 'nmap <silent> <buffer> q      :call GitS_Log("quit")<CR>'
		exe 'nmap <silent> <buffer> u      :call GitS_Log("update")<CR>'
	endif
	"
	let cmd = 'git log'
	"
	call s:UpdateManBuffer ( cmd )
	"
endfunction    " ----------  end of function GitS_Log  ----------
"
"-------------------------------------------------------------------------------
" GitS_Remote : execute 'git remote'   {{{1
"-------------------------------------------------------------------------------
"
function! GitS_Remote( action )
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
	if s:OpenManBuffer ( 'Git : remote' )
		"
		let b:GitSupportRemoteFlag = 1
		"
		"setlocal filetype=
		"
		exe 'nmap          <buffer> <S-F1> :call GitS_Remote("help")<CR>'
		exe 'nmap <silent> <buffer> q      :call GitS_Remote("quit")<CR>'
		exe 'nmap <silent> <buffer> u      :call GitS_Remote("update")<CR>'
	endif
	"
	let cmd = 'git remote -v'
	"
	call s:UpdateManBuffer ( cmd )
	"
endfunction    " ----------  end of function GitS_Remote  ----------
"
"-------------------------------------------------------------------------------
" GitS_Reset : execute 'git reset ...'   {{{1
"-------------------------------------------------------------------------------
"
function! GitS_Reset( files, confirmation )
	"
	if empty( a:files )
		let files = expand ( '%' )
	else
		let files = a:files
	endif
	"
	let cmd = 'git reset '
	let cmd .= '-- '.files
	"
	if a:confirmation && s:Question ( 'Execute "'.cmd.'"?' ) != 1
		echo "aborted"
		return
	endif
	"
	let text = system ( cmd )
	"
	if v:shell_error == 0
		" success
		echo "\"".cmd."\" successful:\n\n".text
	else
		" failure
		echo '"'.cmd.'" failed:'."\n\n".text
	endif
	"
endfunction    " ----------  end of function GitS_Reset  ----------
"
"-------------------------------------------------------------------------------
" s:Status_FileAction : execute a command for the file under the cursor {{{1
"-------------------------------------------------------------------------------
"
function! s:Status_FileAction( action )
	"
	" the file and the action
	let c_pos  = line('.')
	let h_pos  = c_pos
	let s_head = ''
	let s_name = ''
	let s_code = ''
	"
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
	if s_head == ''
		echo 'Not in any section.'
		return 0
	elseif s_head == 'Changes to be committed'
		let s_name = 'staged'
		let s_code = 's'
	elseif s_head == 'Changed but not updated' || s_head == 'Changes not staged for commit'
		let s_name = 'modified'
		let s_code = 'm'
	elseif s_head == 'Untracked files'
		let s_name = 'untracked'
		let s_code = 'u'
	elseif s_head == 'Ignored files'
		let s_name = 'ignored'
		let s_code = 'i'
	else
		echoerr 'Unknown section "'.s_head.'", aborting.'
		return 0
	endif
	"
	if s_code =~ '[sm]'
		let mlist = matchlist( getline(c_pos), '^#\t\([[:alnum:][:space:]]\+\):\s\+\(\S.*\)$' )
	else
		let mlist = matchlist( getline(c_pos), '^#\t\(\)\(\S.*\)$' )
	endif
	"
	if empty( mlist )
		echo 'No file under the cursor.'
		return 0
	endif
	"
	let [ f_status, f_name ] = mlist[1:2]
	"
	" section / action
	"           | edit  | diff  log   | add   ckout reset
	" staged    |  x    |  x     x    |  -     -     x
	" modified  |  x    |  x     x    |  x     x     -
	" untracked |  x    |  -     -    |  x     -     -
	" ignored   |  x    |  -     -    |  x     -     -
	"  (ckout = checkout)
	"
	if a:action == 'edit'
		"
		" any section, action "edit"
		belowright new
		exe "edit ".escape( f_name, s:FilenameEscChar )
		"
	elseif s_code =~ '[sm]' && a:action == 'diff'
		"
		" section "staged" or "modified", action "diff"
		call GitS_Diff( 'update', f_name )
		"
	elseif s_code =~ '[sm]' && a:action == 'log'
		"
		" section "staged" or "modified", action "log"
		call GitS_Log( 'update', f_name )
		"
	elseif s_code == 'i' && a:action == 'add'
		"
		" section "ignored", action "add"
		if s:Question( 'Add ignored file "'.f_name.'"?', 'warning' ) == 1
			call GitS_Add( f_name, 1, 0 )
			return 1
		endif
		"
	elseif s_code == 'u' && a:action == 'add'
		"
		" section "untracked", action "add"
		if s:Question( 'Add untracked file "'.f_name.'"?' ) == 1
			call GitS_Add( f_name, 0, 0 )
			return 1
		endif
		"
	elseif s_code == 'm' && a:action == 'add'
		"
		" section "modified", action "add"
		"
		if f_status == 'modified'
			" add a modified file?
			if s:Question( 'Add file "'.f_name.'"?' ) == 1
				call GitS_Add( f_name, 0, 0 )
				return 1
			endif
		elseif f_status == 'deleted'
			" add a deleted file? -> remove it?
			" TODO: need to run "git rm <file>"
			echo 'Adding not implemented yet for file status "'.f_status.'".'
		else
			echo 'Adding not implemented yet for file status "'.f_status.'".'
		endif
		"
	elseif s_code == 'm' && a:action == 'checkout'
		"
		" section "modified", action "checkout"
		"
		if f_status == 'modified' || f_status == 'deleted'
			" check out a modified or deleted file?
			if s:Question( 'Checkout file "'.f_name.'"?' ) == 1
				call GitS_Checkout( 'files', f_name, 0 )
				return 1
			endif
		else
			echo 'Checking out not implemented yet for file status "'.f_status.'".'
		endif
		"
	elseif s_code == 's' && a:action == 'reset'
		"
		" section "staged", action "reset"
		"
		if f_status == 'modified' || f_status == 'new file' || f_status == 'deleted'
			" reset a modified, new or deleted file?
			if s:Question( 'Reset file "'.f_name.'"?' ) == 1
				call GitS_Reset( f_name, 0 )
				return 1
			endif
		else
			echo 'Reseting not implemented yet for file status "'.f_status.'".'
		endif
		"
	else
		"
		" action not implemented for section
		"
		echo 'Can not execute "'.a:action.'" in section "'.s_name.'".'
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
	let newCWD = ''
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
		let txt .= "r       : file under cursor: reset"
		echo txt
		return
	elseif a:action == 'quit'
		close
		return
	elseif a:action == 'update'
		let newCWD = getcwd ()
	elseif a:action == 'ignored'
		if ! s:HasStatusIgnore
			echo '"show ignored files" not available in Git version '.s:GitVersion.'.'
			return
		endif
	elseif a:action =~ '\<\%(short\|verbose\)\>'
		" noop
	elseif a:action =~ '\<\%(add\|checkout\|diff\|edit\|log\|reset\)\>'
		"
		if getline('.') =~ '^#'
			if s:Status_FileAction ( a:action )
				call GitS_Status( 'update' )
			endif
		else
			echo 'Not in status section.'
		endif
		"
		return
	else
		echoerr 'Unknown action "'.a:action.'".'
		return
	endif
	"
	if s:OpenManBuffer ( 'Git : status' )
		"
		let b:GitSupportStatusFlag = 1
		let b:GitSupportIgnored    = 0
		let b:GitSupportShort      = 0
		let b:GitSupportVerbose    = 0
		"
		let b:GitSupportCWD = getcwd ()
		"
		setlocal filetype=gitsstatus
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
	if a:action == 'update'
		if newCWD != b:GitSupportCWD
			exe	'lchdir '.escape( newCWD, s:FilenameEscChar )
			let b:GitSupportCWD = getcwd ()
		endif
	elseif a:action == 'ignored'
		let b:GitSupportIgnored = ( b:GitSupportIgnored + 1 ) % 2
	elseif a:action == 'short'
		let b:GitSupportShort = ( b:GitSupportShort + 1 ) % 2
	elseif a:action == 'verbose'
		let b:GitSupportVerbose = ( b:GitSupportVerbose + 1 ) % 2
	endif
	"
	let cmd = 'git status'
	"
	if b:GitSupportIgnored == 1 &&   s:HasStatusIgnore | let cmd .= ' --ignored'        | endif
	if b:GitSupportShort   == 1 &&   s:HasStatusBranch | let cmd .= ' --short --branch' | endif
	if b:GitSupportShort   == 1 && ! s:HasStatusBranch | let cmd .= ' --short'          | endif
	if b:GitSupportVerbose == 1                        | let cmd .= ' --verbose'        | endif
	"
	call s:UpdateManBuffer ( cmd )
	"
endfunction    " ----------  end of function GitS_Status  ----------
" }}}1
"
" =====================================================================================
"  vim: foldmethod=marker
