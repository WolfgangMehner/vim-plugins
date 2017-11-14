" ------------------------------------------------------------------------------
"
" Vim filetype plugin file
"
" This creates additional maps to sort the output of the profilers
"
"   Language :  Perl (quickfix)
"     Plugin :  perl-support.vim
"   Revision :  15.04.2017
" Maintainer :  Wolfgang Mehner <wolfgang-mehner@web.de>
"               (formerly Fritz Mehner <mehner.fritz@web.de>)
"
" ----------------------------------------------------------------------------

" Only do this when not done yet for this buffer
if exists("b:did_perl_support_quickfix")
	finish
endif
let b:did_perl_support_quickfix = 1

noremap    <buffer>  <silent>  <LocalLeader>rpss       :call perlsupportprofiling#Perl_SmallProfSortInput()<CR>
noremap    <buffer>  <silent>  <LocalLeader>rpfs       :call perlsupportprofiling#Perl_FastProfSortInput()<CR>
noremap    <buffer>  <silent>  <LocalLeader>rpns       :call perlsupportprofiling#Perl_NYTProfSortInput()<CR>
