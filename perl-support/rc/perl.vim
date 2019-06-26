" ------------------------------------------------------------------------------
"
" Vim filetype plugin file
"
"   Language :  Perl
"     Plugin :  perl-support.vim
"   Revision :  15.04.2017
" Maintainer :  Wolfgang Mehner <wolfgang-mehner@web.de>
"               (formerly Fritz Mehner <mehner.fritz@web.de>)
"
" ----------------------------------------------------------------------------

" Only do this when not done yet for this buffer
if exists("b:did_perl_support_ftplugin")
	finish
endif
let b:did_perl_support_ftplugin = 1

" ---------- tabulator / shiftwidth ------------------------------------------
"  Set tabulator and shift width to 4 conforming to the Perl Style Guide.
"  Uncomment the next two lines to force these settings for all files with
"  filetype 'perl' .
setlocal  tabstop=4
setlocal  shiftwidth=4

" ---------- Add ':' to the keyword characters -------------------------------
"            Tokens like 'File::Find' are recognized as
"            one keyword
setlocal iskeyword+=:

" ---------- additional mapping : {<CR> always opens a block -----------------
inoremap    <buffer>  {<CR>  {<CR>}<Esc>O
vnoremap    <buffer>  {<CR> s{<CR>}<Esc>kp=iB

" ---------- Set "maplocalleader" as configured using "g:Perl_MapLeader" -----
call Perl_SetMapLeader ()

" Ctrl-F9: run script (alt 1: run it straight away)
 noremap  <buffer>  <silent>  <C-F9>       :Perl<CR>
inoremap  <buffer>  <silent>  <C-F9>  <C-C>:Perl<CR>
"" Ctrl-F9: run script (alt 2: add cmd.-line arguments, then press <Enter> to run)
" noremap  <buffer>            <C-F9>       :Perl<Space>
"inoremap  <buffer>            <C-F9>  <C-C>:Perl<Space>

" F9: run debugger (alt 1: run it straight away)
 noremap  <buffer>  <silent>  <F9>       :PerlDebug<CR>
inoremap  <buffer>  <silent>  <F9>  <C-C>:PerlDebug<CR>

"" F9: run debugger (alt 2: add cmd.-line arguments, then press <Enter> to run)
" noremap  <buffer>            <F9>       :PerlDebug<Space>
"inoremap  <buffer>            <F9>  <C-C>:PerlDebug<Space>

" Alt-F9: run syntax check
 noremap  <buffer>  <silent>  <A-F9>       :PerlCheck<CR>
inoremap  <buffer>  <silent>  <A-F9>  <C-C>:PerlCheck<CR>

" Shift-F9: set command line arguments
 noremap  <buffer>            <S-F9>       :PerlScriptArguments<Space>
inoremap  <buffer>            <S-F9>  <C-C>:PerlScriptArguments<Space>

" Shift-F1: read Perl documentation
 noremap  <buffer>  <silent>  <S-F1>       :PerlDoc<CR>
inoremap  <buffer>  <silent>  <S-F1>  <C-C>:PerlDoc<CR>

" ---------- Maps for the Make tool ------------------------------------------
 noremap  <buffer>  <silent>  <LocalLeader>rm        :Make<CR>
inoremap  <buffer>  <silent>  <LocalLeader>rm   <C-C>:Make<CR>
 noremap  <buffer>  <silent>  <LocalLeader>rmc       :Make clean<CR>
inoremap  <buffer>  <silent>  <LocalLeader>rmc  <C-C>:Make clean<CR>
 noremap  <buffer>            <LocalLeader>rma       :MakeCmdlineArgs<space>
inoremap  <buffer>            <LocalLeader>rma  <C-C>:MakeCmdlineArgs<space>
 noremap  <buffer>            <LocalLeader>rcm       :MakeFile<space>
inoremap  <buffer>            <LocalLeader>rcm  <C-C>:MakeFile<space>

" ---------- Reset "maplocalleader" ------------------------------------------
call Perl_ResetMapLeader ()

