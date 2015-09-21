"===============================================================================
"
"          File:  qf.vim
" 
"   Description:  
" 
"   VIM Version:  7.0+
"        Author:  Dr. Fritz Mehner (fgm), mehner.fritz@web.de
"       Version:  1.0
"       Created:  18.02.2012 19:51
"       License:  Copyright (c) 2012, Dr. Fritz Mehner
"===============================================================================
"
" Only do this when not done yet for this buffer
"
if exists("b:did_PERL_quickfix")
  finish
endif
let b:did_PERL_quickfix = 1

noremap    <buffer>  <silent>  <LocalLeader>rpss       :call perlsupportprofiling#Perl_SmallProfSortInput()<CR>
noremap    <buffer>  <silent>  <LocalLeader>rpfs       :call perlsupportprofiling#Perl_FastProfSortInput()<CR>
noremap    <buffer>  <silent>  <LocalLeader>rpns       :call perlsupportprofiling#Perl_NYTProfSortInput()<CR>
