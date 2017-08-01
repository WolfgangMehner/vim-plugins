"===============================================================================
"
"          File:  lua.vim
" 
"   Description:  Filetype plugin for Lua.
" 
"   VIM Version:  7.0+
"        Author:  Wolfgang Mehner, wolfgang-mehner@web.de
"  Organization:  
"       Version:  1.0
"       Created:  26.03.2014
"      Revision:  01.08.2017
"       License:  Copyright (c) 2014-2017, Wolfgang Mehner
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

" Only do this when not done yet for this buffer
if exists("b:did_lua_support_ftplugin")
	finish
endif
let b:did_lua_support_ftplugin = 1

"-------------------------------------------------------------------------------
" set "maplocalleader" as configured using "g:Lua_MapLeader"
"-------------------------------------------------------------------------------
call Lua_SetMapLeader ()

" maps defined here will use "g:Lua_MapLeader" as <LocalLeader>
" example:
"map  <buffer>  <LocalLeader>eg  :echo "Example Map :)"<CR>

"-------------------------------------------------------------------------------
" run, compile, code checker
"-------------------------------------------------------------------------------

nnoremap  <buffer>  <silent>  <F9>         :Lua<CR>
inoremap  <buffer>  <silent>  <F9>    <C-C>:Lua<CR>

nnoremap  <buffer>  <silent>  <S-F9>       :LuaCompile<CR>
inoremap  <buffer>  <silent>  <S-F9>  <C-C>:LuaCompile<CR>

nnoremap  <buffer>  <silent>  <A-F9>       :LuaCheck<CR>
inoremap  <buffer>  <silent>  <A-F9>  <C-C>:LuaCheck<CR>

"-------------------------------------------------------------------------------
" reset "maplocalleader"
"-------------------------------------------------------------------------------
call Lua_ResetMapLeader ()

