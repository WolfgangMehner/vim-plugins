"===============================================================================
"
"          File:  sh.vim
" 
"   Description:  Additonal maps for bash-support (version 4.0+)
" 
"   VIM Version:  7.0+
"        Author:  Dr. Fritz Mehner (fgm), mehner.fritz@fh-swf.de
"  Organization:  FH Südwestfalen, Iserlohn
"       Version:  1.0
"       Created:  20.05.2013 17:20
"      Revision:  ---
"       License:  Copyright (c) 2013, Dr. Fritz Mehner
"===============================================================================
"
"-------------------------------------------------------------------------------
" additional mapping : single quotes around a Word (non-whitespaces)
"                      masks the normal mode command '' (jump to the position
"                      before the latest jump)
" additional mapping : double quotes around a Word (non-whitespaces)
"-------------------------------------------------------------------------------
nnoremap    <buffer>   ''   ciW''<Esc>P
nnoremap    <buffer>   ""   ciW""<Esc>P
"
"-------------------------------------------------------------------------------
" generate tests
" additional mapping : \t1  expands to  [ -<CURSOR>  ]
" additional mapping : \t2  expands to  [ <CURSOR> -  ]
"-------------------------------------------------------------------------------
nnoremap  <buffer>  <silent>  <LocalLeader>t1   a[ -  ]<Left><Left><Left>
inoremap  <buffer>  <silent>  <LocalLeader>t1    [ -  ]<Left><Left><Left>
"
nnoremap  <buffer>  <silent>  <LocalLeader>t2   a[  -  ]<Left><Left><Left><Left><Left>
inoremap  <buffer>  <silent>  <LocalLeader>t2    [  -  ]<Left><Left><Left><Left><Left>
"
