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
"      Revision:  04.01.2016
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

" only do this when not done yet for this buffer
if exists("b:did_Template_ftplugin")
  finish
endif
let b:did_Template_ftplugin = 1

"-------------------------------------------------------------------------------
" Editing: repeat comments, ...
"-------------------------------------------------------------------------------

" default: -something-
setlocal comments=sO:§\ -,mO:§\ \ ,eO:§§,:§
" default: tcq
" - remove auto-wrap text
" - keep autowrap comments
" - add insertion of comment leader after hitting <Enter>, o, O
" - add do not break lines which were already to long
setlocal formatoptions-=t
setlocal formatoptions+=rol

