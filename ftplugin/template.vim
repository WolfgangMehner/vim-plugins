"===============================================================================
"
"          File:  template.vim
" 
"   Description:  Filetype plugin for templates.
" 
"   VIM Version:  7.0+
"        Author:  Wolfgang Mehner, wolfgang-mehner@web.de
"  Organization:  
"       Version:  1.0
"       Created:  30.08.2011
"      Revision:  08.07.2014
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
"
" only do this when not done yet for this buffer
if exists("b:did_Template_ftplugin")
  finish
endif
let b:did_Template_ftplugin = 1
"
if ! exists ( '*Templates_CodeComment' )
	"----------------------------------------------------------------------
	" Templates_CommentCode : Comment -> Code   {{{1
	"----------------------------------------------------------------------
	function! Templates_CodeComment() range
		"
		" add '§' at the beginning of the lines
		silent exe ':'.a:firstline.','.a:lastline.'s/^/§/'
		"
	endfunction    " ----------  end of function Templates_CodeComment  ----------
	"
	"----------------------------------------------------------------------
	" Templates_CommentCode : Comment -> Code   {{{1
	"----------------------------------------------------------------------
	function! Templates_CommentCode() range
		"
		" remove '§' from the beginning of the line
		silent exe ':'.a:firstline.','.a:lastline.'s/^\§//'
		"
	endfunction    " ----------  end of function Templates_CommentCode  ----------
	" }}}1
endif
"
 noremap    <buffer>  <silent>  <LocalLeader>cc         :call Templates_CodeComment()<CR>
inoremap    <buffer>  <silent>  <LocalLeader>cc    <Esc>:call Templates_CodeComment()<CR>
 noremap    <buffer>  <silent>  <LocalLeader>cu         :call Templates_CommentCode()<CR>
inoremap    <buffer>  <silent>  <LocalLeader>cu    <Esc>:call Templates_CommentCode()<CR>
"
inoremap  {+  {++}<Left><Left>
inoremap  {-  {--}<Left><Left>
vnoremap  {+  s{++}<Left><Esc>P<Right>%
vnoremap  {-  s{--}<Left><Esc>P<Right>%
"
