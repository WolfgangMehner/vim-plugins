" Vim filetype plugin file
"
"   Language :  Perl
"     Plugin :  perl-support.vim
" Maintainer :  Fritz Mehner <mehner@fh-swf.de>
"
" ----------------------------------------------------------------------------
"
" Only do this when not done yet for this buffer
"
if exists("b:did_POD_ftplugin")
  finish
endif
let b:did_POD_ftplugin = 1
"
" ---------- tabulator / shiftwidth ------------------------------------------
"  Set tabulator and shift width to 4 conforming to the Perl Style Guide.
"  Uncomment the next two lines to force these settings for all files with
"  filetype 'perl' .
"
setlocal  tabstop=4
setlocal  shiftwidth=4
if exists('g:Perl_Perltidy') && g:Perl_Perltidy == 'on' && executable("perltidy")
	setlocal equalprg='perltidy'
endif
"
" ---------- Add ':' to the keyword characters -------------------------------
"            Tokens like 'File::Find' are recognized as
"            one keyword
"
setlocal iskeyword+=:
"
" ---------- Do we have a mapleader other than '\' ? ------------
"
if exists("g:Perl_MapLeader")
  let maplocalleader  = g:Perl_MapLeader
endif
"
" ---------- Perl dictionary -------------------------------------------------
" This will enable keyword completion for Perl
" using Vim's dictionary feature |i_CTRL-X_CTRL-K|.
"
if exists("g:Perl_Dictionary_File")
  let save=&dictionary
  silent! exe 'setlocal dictionary='.g:Perl_Dictionary_File
  silent! exe 'setlocal dictionary+='.save
endif
"
"
" ---------- Key mappings : function keys ------------------------------------
"
"  Shift-F1   read Perl documentation
" Vim (non-GUI) : shifted keys are mapped to their unshifted key !!!
"
if has("gui_running")
  "
   map    <buffer>  <silent>  <S-F1>             :call Perl_perldoc()<CR><CR>
  imap    <buffer>  <silent>  <S-F1>        <C-C>:call Perl_perldoc()<CR><CR>
endif
"
"-------------------------------------------------------------------------------
"   Key mappings for menu entries
"   The mappings can be switched on and off by g:Perl_NoKeyMappings
"-------------------------------------------------------------------------------
"
if !exists("g:Perl_NoKeyMappings") || ( exists("g:Perl_NoKeyMappings") && g:Perl_NoKeyMappings!=1 )
  " ---------- plugin help -----------------------------------------------------
  "
  nnoremap    <buffer>  <silent>  <LocalLeader>hp         :call Perl_HelpPerlsupport()<CR>
  inoremap    <buffer>  <silent>  <LocalLeader>hp    <C-C>:call Perl_HelpPerlsupport()<CR>
  "
  " ----------------------------------------------------------------------------
  " Comments
  " ----------------------------------------------------------------------------
  "
  nnoremap    <buffer>  <silent>  <LocalLeader>cb         :call Perl_CommentBlock("a")<CR>
  vnoremap    <buffer>  <silent>  <LocalLeader>cb    <C-C>:call Perl_CommentBlock("v")<CR>
  nnoremap    <buffer>  <silent>  <LocalLeader>cn         :call Perl_UncommentBlock()<CR>
  "
  " ----------------------------------------------------------------------------
  " Snippets
  " ----------------------------------------------------------------------------
  "
  nnoremap    <buffer>  <silent>  <LocalLeader>nr         :call Perl_CodeSnippet("read")<CR>
  nnoremap    <buffer>  <silent>  <LocalLeader>nw         :call Perl_CodeSnippet("write")<CR>
  vnoremap    <buffer>  <silent>  <LocalLeader>nw    <Esc>:call Perl_CodeSnippet("wv")<CR>
  nnoremap    <buffer>  <silent>  <LocalLeader>ne         :call Perl_CodeSnippet("edit")<CR>
  nnoremap    <buffer>  <silent>  <LocalLeader>nv         :call Perl_CodeSnippet("view")<CR>
  "
  inoremap    <buffer>  <silent>  <LocalLeader>nr    <Esc>:call Perl_CodeSnippet("read")<CR>
  inoremap    <buffer>  <silent>  <LocalLeader>nw    <Esc>:call Perl_CodeSnippet("write")<CR>
  inoremap    <buffer>  <silent>  <LocalLeader>ne    <Esc>:call Perl_CodeSnippet("edit")<CR>
  inoremap    <buffer>  <silent>  <LocalLeader>nv    <Esc>:call Perl_CodeSnippet("view")<CR>
  "
  " ----------------------------------------------------------------------------
  " POD
  " ----------------------------------------------------------------------------
  "
  nnoremap    <buffer>  <silent>  <LocalLeader>pod        :call Perl_PodCheck()<CR>
  nnoremap    <buffer>  <silent>  <LocalLeader>podh       :call Perl_POD('html')<CR>
  nnoremap    <buffer>  <silent>  <LocalLeader>podm       :call Perl_POD('man')<CR>
  nnoremap    <buffer>  <silent>  <LocalLeader>podt       :call Perl_POD('text')<CR>
  "
  inoremap    <buffer>  <silent>  <LocalLeader>pod   <Esc>:call Perl_PodCheck()<CR>
  inoremap    <buffer>  <silent>  <LocalLeader>podh  <Esc>:call Perl_POD('html')<CR>
  inoremap    <buffer>  <silent>  <LocalLeader>podm  <Esc>:call Perl_POD('man')<CR>
  inoremap    <buffer>  <silent>  <LocalLeader>podt  <Esc>:call Perl_POD('text')<CR>
  "
endif
" ----------------------------------------------------------------------------
"
