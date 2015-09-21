"===============================================================================
"
"          File:  perlsupportprofiling.vim
" 
"   Description:  Plugin perl-support: Profiler support
" 
"   VIM Version:  7.0+
"        Author:  Dr. Fritz Mehner (fgm), mehner.fritz@web.de
"       Version:  1.0
"       Created:  22.02.2009
"      Revision:  ---
"       License:  Copyright (c) 2009-2014, Dr. Fritz Mehner
"===============================================================================
"
" Exit quickly when:
" - this plugin was already loaded
" - when 'compatible' is set
"
if exists("g:loaded_perlsupportprofiling") || &compatible
  finish
endif
let g:loaded_perlsupportregex = "v1.0"
"
let s:MSWIN = has("win16") || has("win32")   || has("win64")    || has("win95")
let s:UNIX	= has("unix")  || has("macunix") || has("win32unix")
"
"------------------------------------------------------------------------------
"  run : SmallProf, data structures     {{{1
"------------------------------------------------------------------------------
let s:Perl_CWD									= ''
let s:Perl_SmallProfOutput   		= 'smallprof.out'
let s:Perl_SmallProfErrorFormat	= '%f:%l:%m'

let s:Perl_SmallProfSortQuickfixField	= {
	\		 'file-name'   : 1 , 
	\		 'line-number' : 2 , 
	\		 'line-count'  : 3 , 
	\		 'time'        : 4 , 
	\		 'ctime'       : 5 , 
	\		 }

let s:Perl_SmallProfSortQuickfixHL	= {
	\		 'file-name'   : '/^[^|]\+/' , 
	\		 'line-number' : '/|\d\+|/' , 
	\		 'line-count'  : '/ \@<=\d\+:\@=/' , 
	\		 'time'        : '/:\@<=\d\+\(:\d\+:\)\@=/' , 
	\		 'ctime'       : '/:\@<=\d\+\(: \)\@=/' , 
	\		 }

"------------------------------------------------------------------------------
"  run : SmallProf, generate statistics     {{{1
"  Also called in the filetype plugin perl.vim
"------------------------------------------------------------------------------
function! perlsupportprofiling#Perl_Smallprof ()
  let Sou   = escape( expand("%:p"), g:Perl_FilenameEscChar ) " name of the file in the current buffer
  if &filetype != "perl"
    echohl WarningMsg | echo Sou.' seems not to be a Perl file' | echohl None
    return
  endif
  silent exe  ":update"
  "
  let l:arguments       = exists("b:Perl_CmdLineArgs") ? " ".b:Perl_CmdLineArgs : ""
  "
	let s:Perl_CWD	= getcwd()
  echohl Search | echon ' ... profiling ... ' | echohl None
  "
	if  s:MSWIN
		if filereadable( '.smallprof' )
			let	profilercmd	= 'perl -d:SmallProf "'.Sou.l:arguments.'"'
		else
			echon "you need a config file '.smallprof' / please see the plugin help"
			return
		endif
	else
		" g : grep format / z : drop zeros (lines which were never called)
		let	profilercmd	= 'SMALLPROF_CONFIG=gz perl -d:SmallProf '.Sou.l:arguments
	endif
	let errortext	= system(profilercmd)
  "
  if v:shell_error
    redraw
		echon errortext
    return
  endif
	"
	redraw!
  echon ' profiling done '
  "
	call perlsupportprofiling#Perl_Smallprof_OpenQuickfix ()

endfunction   " ---------- end of function  Perl_Smallprof  ----------
"
"------------------------------------------------------------------------------
"  run : SmallProf, open existing statistics file    {{{1
"------------------------------------------------------------------------------
function! perlsupportprofiling#Perl_Smallprof_OpenQuickfix ()
	if filereadable( s:Perl_SmallProfOutput )
		exe ':setlocal errorformat='.s:Perl_SmallProfErrorFormat
		exe ':cfile '.s:Perl_SmallProfOutput
		exe ':copen'
		exe ':match Visual '.s:Perl_SmallProfSortQuickfixHL['time']
		exe ':setlocal nowrap'
	else
		echon "No profiling statistics file '".s:Perl_SmallProfOutput."' found."
	endif
endfunction    " ----------  end of function Perl_Smallprof_OpenQuickfix  ----------
"
"------------------------------------------------------------------------------
"  run : SmallProf, sort report     {{{1
"  Rearrange the profiler report.
"------------------------------------------------------------------------------
let s:Perl_SmallProfSortSkipRegex	= {
	\		 'file-name'   : '' , 
	\		 'line-number' : '  n /^[^:]\+:/' , 
	\		 'line-count'  : '! n /^[^:]\+:\d\+:/' , 
	\		 'time'        : '! n /^[^:]\+:\d\+:\d\+:/' , 
	\		 'ctime'       : '! n /^[^:]\+:\d\+:\d\+:\d\+:/' , 
	\		 }

function! perlsupportprofiling#Perl_SmallProfSortQuickfix ( mode )
	"
	if &filetype == 'qf'
		"
		if ! has_key( s:Perl_SmallProfSortQuickfixField, a:mode )
			echomsg	'Allowed sort keys : ['.join( keys(s:Perl_SmallProfSortQuickfixField), '|' ).'].'
			return
		endif
		"
		let filename	= escape( s:Perl_CWD.'/'.s:Perl_SmallProfOutput, g:Perl_FilenameEscChar )
		exe ':edit '.filename
		exe ':2,$sort'.s:Perl_SmallProfSortSkipRegex[a:mode]
		let currentbuffer	= bufnr("%")
		:exit
		exe ':bdelete '.currentbuffer

		exe ':setlocal errorformat='.s:Perl_SmallProfErrorFormat
		exe ':cfile '.filename
		:copen
		exe ':match Visual '.s:Perl_SmallProfSortQuickfixHL[a:mode]
		:setlocal nowrap
		"
	else
		echomsg 'the current buffer is not a QuickFix List (error list)'
	endif
	"
endfunction    " ----------  end of function Perl_SmallProfSortQuickfix  ----------
"
function! perlsupportprofiling#Perl_SmallProfSortInput ( )
		let retval = input( "SmallProf report sort criterion  (tab exp.): ", '', 'customlist,perlsupportprofiling#Perl_SmallProfSortList' )
		redraw!
		call perlsupportprofiling#Perl_SmallProfSortQuickfix( retval )
	return
endfunction    " ----------  end of function Perl_SmallProfSortInput  ----------
"
function! perlsupportprofiling#Perl_FastProfSortInput ( )
		let retval = input( "FastProf report sort criterion  (tab exp.): ", '', 'customlist,perlsupportprofiling#Perl_FastProfSortList' )
		redraw!
		call perlsupportprofiling#Perl_FastProfSortQuickfix( retval )
	return
endfunction    " ----------  end of function Perl_FastProfSortInput  ----------
"
function! perlsupportprofiling#Perl_NYTProfSortInput ( )
		let retval = input( "NYTProf report sort criterion  (tab exp.): ", '', 'customlist,perlsupportprofiling#Perl_NYTProfSortList' )
		redraw!
		call perlsupportprofiling#Perl_NYTProfSortQuickfix( retval )
	return
endfunction    " ----------  end of function Perl_NYTProfSortInput  ----------
"
"------------------------------------------------------------------------------
"  run : Profiler; ex command tab expansion     {{{1
"------------------------------------------------------------------------------
function!	perlsupportprofiling#Perl_ProfSortList ( ArgLead, List )
	" show all types
	if a:ArgLead == ''
		return a:List
	endif
	" show types beginning with a:ArgLead
	let	expansions	= []
	for item in a:List
		if match( item, '\<'.a:ArgLead.'\w*' ) == 0
			call add( expansions, item )
		endif
	endfor
	return	expansions
endfunction    " ----------  end of function Perl_ProfSortList  ----------

"------------------------------------------------------------------------------
"  run : SmallProf, ex command tab expansion     {{{1
"------------------------------------------------------------------------------
function!	perlsupportprofiling#Perl_SmallProfSortList ( ArgLead, CmdLine, CursorPos )
	return	perlsupportprofiling#Perl_ProfSortList( a:ArgLead, keys(s:Perl_SmallProfSortQuickfixField) )
endfunction    " ----------  end of function Perl_SmallProfSortList  ----------

"------------------------------------------------------------------------------
"  run : FastProf, data structures     {{{1
"------------------------------------------------------------------------------
let s:Perl_FastProfOutput   		= 'fastprof.out'
let s:Perl_Fprofpp              = ''
let s:Perl_FastProfErrorFormat	= '%f:%l\ %m'

let s:Perl_FastProfSortQuickfixField	= {
	\		 'file-name'   : 1 , 
	\		 'line-number' : 2 , 
	\		 'time'        : 2 , 
	\		 'line-count'  : 3 , 
	\		 }

let s:Perl_FastProfSortQuickfixHL	= {
	\		 'file-name'   : '/^[^|]\+/' , 
	\		 'line-number' : '/|\d\+|/' , 
	\		 'time'        : '/\(| \)\@<=\d\+\.\d\+/' , 
	\		 'line-count'  : '/ \@<=\d\+:\@=/' , 
	\		 }

"------------------------------------------------------------------------------
"  run : FastProf, generate statistics     {{{1
"  Also called in the filetype plugin perl.vim
"------------------------------------------------------------------------------
function! perlsupportprofiling#Perl_Fastprof ()
  let Sou   = escape( expand("%:p"), g:Perl_FilenameEscChar ) " name of the file in the current buffer
  if &filetype != "perl"
    echohl WarningMsg | echo Sou.' seems not to be a Perl file' | echohl None
    return
  endif
  silent exe  ":update"
  "
  let l:arguments       = exists("b:Perl_CmdLineArgs") ? " ".b:Perl_CmdLineArgs : ""
  "
	let s:Perl_CWD	= getcwd()
  echohl Search | echon ' ... profiling ... ' | echohl None
  "
	let	profilercmd	= 'perl -d:FastProf '.Sou.l:arguments
	let errortext	= system(profilercmd)
  "
  if v:shell_error
    redraw
		echon errortext
    return
  endif
  "
	call perlsupportprofiling#Perl_FastProf_OpenQuickfix ()
	"
	redraw!
  echon ' profiling done '

endfunction   " ---------- end of function  Perl_Fastprof  ----------
"
"------------------------------------------------------------------------------
"  run : FastProf, open existing statistics file    {{{1
"------------------------------------------------------------------------------
function! perlsupportprofiling#Perl_FastProf_OpenQuickfix ()
  "
	if filereadable( s:Perl_FastProfOutput )
		if s:Perl_Fprofpp	== ''
			let	s:Perl_Fprofpp	= tempname()
		endif
		let	profilercmd	= 'fprofpp > '.s:Perl_Fprofpp
		let errortext	= system( profilercmd )
		"
		if v:shell_error
			redraw
			echon errortext
			return
		endif
		"
		exe ':setlocal errorformat='.s:Perl_FastProfErrorFormat
		exe ':cfile '.s:Perl_Fprofpp
		exe ':copen'
		exe ':match Visual '.s:Perl_FastProfSortQuickfixHL['time']
		exe ':setlocal nowrap'
	else
		echon "No profiling statistics file '".s:Perl_FastProfOutput."' found."
	endif
endfunction   " ---------- end of function  Perl_FastProf_OpenQuickfix  ----------

"------------------------------------------------------------------------------
"  run : FastProf, sort report     {{{1
"  Rearrange the profiler report.
"------------------------------------------------------------------------------
let s:Perl_FastProfSortSkipRegex	= {
	\		 'file-name'   : '' , 
	\		 'line-number' : '  n /^[^:]\+:/' , 
	\		 'time'        : '  n /^[^:]\+:/d\+ ' , 
	\		 'line-count'  : '! n /^[^:]\+:\d\+ \d\+\.\d\+ /' , 
	\		 }

function! perlsupportprofiling#Perl_FastProfSortQuickfix ( mode )
	"
	if &filetype == 'qf'
		"
		if ! has_key( s:Perl_FastProfSortQuickfixField, a:mode )
			echomsg	'Allowed sort keys : ['.join( keys(s:Perl_FastProfSortQuickfixField), '|' ).'].'
			return
		endif
		"
		if a:mode == 'time'
			" generate new data to avoid sorting
			let	profilercmd	= 'fprofpp -r > '.s:Perl_Fprofpp
			let errortext	= system( profilercmd )
			"
			if v:shell_error
				redraw
				echon errortext
				return
			endif
		else
			exe ':edit '.s:Perl_Fprofpp
			exe ':3,$sort'.s:Perl_FastProfSortSkipRegex[a:mode]
			let currentbuffer	= bufnr("%")
			:exit
			exe ':bdelete '.currentbuffer
		endif
		"
		exe ':setlocal errorformat='.s:Perl_FastProfErrorFormat
		exe ':cfile '.s:Perl_Fprofpp
		:copen
		exe ':match Visual '.s:Perl_FastProfSortQuickfixHL[a:mode]
		:setlocal nowrap
		"
	else
		echomsg 'the current buffer is not a QuickFix List (error list)'
	endif
	"
endfunction    " ----------  end of function Perl_FastProfSortQuickfix  ----------
"
"------------------------------------------------------------------------------
"  run : FastProf, ex command tab expansion     {{{1
"------------------------------------------------------------------------------
function!	perlsupportprofiling#Perl_FastProfSortList ( ArgLead, CmdLine, CursorPos )
	return	perlsupportprofiling#Perl_ProfSortList( a:ArgLead, keys(s:Perl_FastProfSortQuickfixField) )
endfunction    " ----------  end of function Perl_FastProfSortList  ----------

"------------------------------------------------------------------------------
"  run : NYTProf, data structures     {{{1
"------------------------------------------------------------------------------
let s:Perl_NYTProf_html			 	= 'no'
if exists( 'g:Perl_NYTProf_html' )
	let s:Perl_NYTProf_html	= g:Perl_NYTProf_html
endif

let s:Perl_NYTProf_browser	 	= 'konqueror'
if exists( 'g:Perl_NYTProf_browser' )
	let s:Perl_NYTProf_browser	= g:Perl_NYTProf_browser
endif

let s:Perl_csv2err            = g:Perl_PluginDir.'/perl-support/scripts/csv2err.pl'
let s:Perl_NYTProfErrorFormat	= '%f:%l:%m'
let g:Perl_NYTProfCSVfile			= ''

let s:Perl_NYTProfSortQuickfixHL	= {
	\		 'file'   			 : '/^[^|]\+/' , 
	\		 'line' 				 : '/|\d\+|/' , 
	\		 'time'       	 : '/\(| \)\@<=\d\+\.\d\+:\@=/' , 
	\		 'calls'   		   : '/:\@<=\d\+:\@=/' , 
	\		 'time_per_call' : '/:\@<=\d\+\.\d\+\(: \)\@=/' , 
	\		 }

"------------------------------------------------------------------------------
"  run : NYTProf, generate statistics     {{{1
"  Also called in the filetype plugin perl.vim
"------------------------------------------------------------------------------
function! perlsupportprofiling#Perl_NYTprof ()
  let Sou   = escape( expand("%:p"), g:Perl_FilenameEscChar ) " name of the file in the current buffer
  if &filetype != "perl"
    echohl WarningMsg | echo Sou.' seems not to be a Perl file' | echohl None
    return
  endif
  silent exe  ":update"
  "
  let l:arguments       = exists("b:Perl_CmdLineArgs") ? " ".b:Perl_CmdLineArgs : ""
  "
  echohl Search | echon ' ... profiling ... ' | echohl None
  "
	if  s:MSWIN
		let	profilercmd	= 'perl -d:NYTProf "'.Sou.l:arguments.'"'
	else
		let	profilercmd	= 'perl -d:NYTProf '.Sou.l:arguments
	endif
	let errortext	= system(profilercmd)
  "
  if v:shell_error
    redraw
		echon errortext
    return
  endif
  "
  if s:Perl_NYTProf_html == 'yes'
		let errortext	= system( 'nytprofhtml' )
		if v:shell_error
			redraw
			echon errortext
			return
		endif
	endif
  "
	let errortext	= system( 'nytprofcsv' )
  "
  if v:shell_error
    redraw
		echon errortext
    return
  endif
	"
	redraw!
	if s:Perl_NYTProf_html == 'yes'
		echon ' profiling done -- read a CSV file or load the HTML files'
	else
		echon ' profiling done -- read a CSV file'
	endif
  "
endfunction   " ---------- end of function  Perl_NYTprof  ----------

"------------------------------------------------------------------------------
"  run : NYTProf, generate statistics     {{{1
"  Also called in the filetype plugin perl.vim
"  mode				: read, sort
"  criterion	: file, line, time, calls, time_per_call
"------------------------------------------------------------------------------
function! perlsupportprofiling#Perl_NYTprofReadCSV ( mode, criterion )

	if a:mode == 'sort' && &filetype != 'qf'
		echomsg 'the current buffer is not a QuickFix List (error list)'
		return
	endif

	if a:mode == 'read' || g:Perl_NYTProfCSVfile == ''
		if has("gui_running")
			let g:Perl_NYTProfCSVfile	= browse( 0, 'read a Devel::NYTProf CSV-file', 'nytprof', '*.csv' )
		else
			let	g:Perl_NYTProfCSVfile	= input( 'read a Devel::NYTProf CSV-file : ', '', "file" )
		end
		let g:Perl_NYTProfCSVfile	= substitute( g:Perl_NYTProfCSVfile, '^\s\+', '', '' )
		let g:Perl_NYTProfCSVfile	= substitute( g:Perl_NYTProfCSVfile, '\s\+$', '', '' )
		"
		" return if command canceled
		if g:Perl_NYTProfCSVfile =~ '^$'
			return
		endif
		"
		" return if not a CSV file
		if g:Perl_NYTProfCSVfile !~ '\.csv$'
			echohl WarningMsg | echo g:Perl_NYTProfCSVfile.' seems not to be a CSV file' | echohl None
			return
		endif
		" full path, remove filename and last directory:
		let	currentworkingdirectory	= fnamemodify( g:Perl_NYTProfCSVfile, ":p:h:h" )
		let g:Perl_NYTProfCSVfile		= currentworkingdirectory.'/'.g:Perl_NYTProfCSVfile
	endif
	"
	let sourcefilename	= substitute( g:Perl_NYTProfCSVfile, '-\(pl\|pm\)\(-\(\d\+\)\)\?-\(block\|line\|sub\)\.csv$', '.\1', '' )
	let sourcefilename	= substitute( sourcefilename, '\/nytprof', '', '' )

	if !filereadable( sourcefilename )
		let	sourcefilename_save	= sourcefilename
		let sourcefilename	= findfile( fnamemodify( sourcefilename, ":t") )
		if sourcefilename == ''
			echomsg "Could not find file '".sourcefilename_save."'"
			return
		endif
	endif
	"
	let	makeprg_saved	= &makeprg
	exe ':setlocal errorformat='.s:Perl_NYTProfErrorFormat
	"
	exe ":setlocal makeprg=perl"
	if  s:MSWIN
		silent exe ':make "'.s:Perl_csv2err.'" -s '.a:criterion
					\							.' -i "'.g:Perl_NYTProfCSVfile.'"'
					\							.' -n "'.sourcefilename.'"'
	else
		silent exe ':make  '.s:Perl_csv2err.'  -s '.a:criterion
					\						.' -i  '.escape( g:Perl_NYTProfCSVfile, g:Perl_FilenameEscChar )
					\						.' -n  '.escape( sourcefilename, g:Perl_FilenameEscChar )
	endif
	"
	exe ":setlocal makeprg=".makeprg_saved
	exe	":botright cwindow"
	copen
	setlocal modifiable
	exe ':match Visual '.s:Perl_NYTProfSortQuickfixHL[a:criterion]
  exe ':setlocal nowrap'
	setlocal nomodifiable

endfunction   " ---------- end of function  Perl_NYTprofReadCSV  ----------

"------------------------------------------------------------------------------
"  run : NYTProf, generate statistics     {{{1
"  Also called in the filetype plugin perl.vim
"  mode				: read, sort
"  criterion	: file, line, time, calls, time_per_call
"------------------------------------------------------------------------------
function! perlsupportprofiling#Perl_NYTProfSortQuickfix ( criterion )
	call perlsupportprofiling#Perl_NYTprofReadCSV( 'sort', a:criterion )
endfunction   " ---------- end of function Perl_NYTProfSortQuickfix   ----------
"
"------------------------------------------------------------------------------
"  run : NYTProf, generate statistics     {{{1
"  Also called in the filetype plugin perl.vim
"------------------------------------------------------------------------------
function! perlsupportprofiling#Perl_NYTprofReadHtml ()

	if !has("gui_running")
		echomsg "Function not available: no GUI running."
		return
	end
	if executable( s:Perl_NYTProf_browser ) != 1
		echomsg 'Browser '.s:Perl_NYTProf_browser.' does not exist or is not executable.'
		return
	endif

	if  s:MSWIN
		echomsg "** not yet implemented **"
	else
		let	index	= 'nytprof/index.html'
		if !filereadable( index )
			let	index	= getcwd()
		endif
		let errortext	= system( s:Perl_NYTProf_browser.' '.index.' &' )
		"
		if v:shell_error
			redraw
			echon errortext
			return
		endif
	endif

endfunction   " ---------- end of function  Perl_NYTprofReadHtml  ----------
"
"------------------------------------------------------------------------------
"  run : NYTProf, ex command tab expansion     {{{1
"------------------------------------------------------------------------------
function!	perlsupportprofiling#Perl_NYTProfSortList ( ArgLead, CmdLine, CursorPos )
	return	perlsupportprofiling#Perl_ProfSortList( a:ArgLead, keys(s:Perl_NYTProfSortQuickfixHL) )
endfunction    " ----------  end of function Perl_NYTProfSortList  ----------

" vim: tabstop=2 shiftwidth=2 foldmethod=marker
