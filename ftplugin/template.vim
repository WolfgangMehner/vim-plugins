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
" only do this when not done yet for this buffer
if exists("b:did_Template_ftplugin")
  finish
endif
let b:did_Template_ftplugin = 1
"
"----------------------------------------------------------------------
" b:CommentCode : Comment -> Code   {{{1
"----------------------------------------------------------------------
function! b:CodeComment() range
  "
  " add '§' at the beginning of the lines
  silent exe ':'.a:firstline.','.a:lastline.'s/^/§/'
  "
endfunction    " ----------  end of function b:CodeComment  ----------
"
"----------------------------------------------------------------------
" b:CommentCode : Comment -> Code   {{{1
"----------------------------------------------------------------------
function! b:CommentCode() range
  "
  " remove '§' from the beginning of the line
  silent exe ':'.a:firstline.','.a:lastline.'s/^\§//'
  "
endfunction    " ----------  end of function b:CommentCode  ----------
" }}}1
"
 noremap    <buffer>  <silent>  <LocalLeader>cc         :call b:CodeComment()<CR>
inoremap    <buffer>  <silent>  <LocalLeader>cc    <Esc>:call b:CodeComment()<CR>
 noremap    <buffer>  <silent>  <LocalLeader>cu         :call b:CommentCode()<CR>
inoremap    <buffer>  <silent>  <LocalLeader>cu    <Esc>:call b:CommentCode()<CR>
"
inoremap  {+  {++}<Left><Left>
inoremap  {-  {--}<Left><Left>
vnoremap  {+  s{++}<Left><Esc>P<Right>%
vnoremap  {-  s{--}<Left><Esc>P<Right>%
"
