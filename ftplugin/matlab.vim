"===============================================================================
"
"          File:  matlab.vim
" 
"   Description:  Filetype plugin for MATLAB.
" 
"   VIM Version:  7.0+
"        Author:  Wolfgang Mehner, wolfgang-mehner@web.de
"  Organization:  
"       Version:  1.0
"       Created:  11.04.2010
"      Revision:  24.11.2013
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
" Only do this when not done yet for this buffer
if exists("b:did_Matlab_ftplugin")
	finish
endif
let b:did_Matlab_ftplugin = 1
"
"-------------------------------------------------------------------------------
" settings - tabs + shift
"-------------------------------------------------------------------------------
setlocal tabstop=4
setlocal shiftwidth=4
setlocal expandtab
"
"-------------------------------------------------------------------------------
" set "maplocalleader" as configured using "g:Matlab_MapLeader"
"-------------------------------------------------------------------------------
call Matlab_SetMapLeader ()
"
" maps defined here will use "g:Matlab_MapLeader" as <LocalLeader>
" example:
"map  <buffer>  <LocalLeader>eg  :echo "Example Map :)"<CR>
"
"-------------------------------------------------------------------------------
" reset "maplocalleader"
"-------------------------------------------------------------------------------
call Matlab_ResetMapLeader ()
"
