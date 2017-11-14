" ------------------------------------------------------------------------------
"
" Vim filetype plugin file
"
"   Language :  Perl (POD)
"     Plugin :  perl-support.vim
"   Revision :  15.04.2017
" Maintainer :  Wolfgang Mehner <wolfgang-mehner@web.de>
"               (formerly Fritz Mehner <mehner.fritz@web.de>)
"
" ----------------------------------------------------------------------------

" Only do this when not done yet for this buffer
if exists("b:did_perl_support_pod")
	finish
endif
let b:did_perl_support_pod = 1

" ---------- tabulator / shiftwidth ------------------------------------------
"  Set tabulator and shift width to 4 conforming to the Perl Style Guide.
"  Uncomment the next two lines to force these settings for all files with
"  filetype 'perl' .
"
setlocal  tabstop=4
setlocal  shiftwidth=4
"
" ---------- Add ':' to the keyword characters -------------------------------
"            Tokens like 'File::Find' are recognized as
"            one keyword
"
setlocal iskeyword+=:
"
" ---------- Set "maplocalleader" as configured using "g:Perl_MapLeader" -----
"
call Perl_SetMapLeader ()
"
" ---------- Maps for the Make tool ------------------------------------------
"
 noremap  <buffer>  <silent>  <LocalLeader>rm        :Make<CR>
inoremap  <buffer>  <silent>  <LocalLeader>rm   <C-C>:Make<CR>
 noremap  <buffer>  <silent>  <LocalLeader>rmc       :Make clean<CR>
inoremap  <buffer>  <silent>  <LocalLeader>rmc  <C-C>:Make clean<CR>
 noremap  <buffer>            <LocalLeader>rma       :MakeCmdlineArgs<space>
inoremap  <buffer>            <LocalLeader>rma  <C-C>:MakeCmdlineArgs<space>
 noremap  <buffer>            <LocalLeader>rcm       :MakeFile<space>
inoremap  <buffer>            <LocalLeader>rcm  <C-C>:MakeFile<space>
"
" ---------- Reset "maplocalleader" ------------------------------------------
"
call Perl_ResetMapLeader ()
"
