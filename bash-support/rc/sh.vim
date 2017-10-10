" ------------------------------------------------------------------------------
"
" Vim filetype plugin file
"
"   Language :  Bash
"     Plugin :  bash-support.vim
"   Revision :  08.10.2017
" Maintainer :  Wolfgang Mehner <wolfgang-mehner@web.de>
"               (formerly Fritz Mehner <mehner.fritz@web.de>)
"
" ------------------------------------------------------------------------------

" Only do this when not done yet for this buffer
if exists("b:did_bash_support_ftplugin")
	finish
endif
let b:did_bash_support_ftplugin = 1

" ---------- Avoid a wrong syntax highlighting for $(..) and $((..)) ---------
let b:is_bash = 1

" ---------- Key mappings - Quotes -------------------------------------------
"  single quotes around a Word (non-whitespaces)
"  masks the normal mode command '' (jump to the position before the latest jump)
"  double quotes around a Word (non-whitespaces)
"nnoremap    <buffer>   ''   ciW''<Esc>P
"nnoremap    <buffer>   ""   ciW""<Esc>P

" ---------- Key mappings - Tests --------------------------------------------
"  additional mapping : \t1  expands to  [ -<CURSOR>  ]
"  additional mapping : \t2  expands to  [ <CURSOR> -  ]
"nnoremap  <buffer>  <silent>  <LocalLeader>t1   a[ -  ]<Left><Left><Left>
"inoremap  <buffer>  <silent>  <LocalLeader>t1    [ -  ]<Left><Left><Left>

"nnoremap  <buffer>  <silent>  <LocalLeader>t2   a[  -  ]<Left><Left><Left><Left><Left>
"inoremap  <buffer>  <silent>  <LocalLeader>t2    [  -  ]<Left><Left><Left><Left><Left>

" ---------- Set "maplocalleader" as configured using "g:BASH_MapLeader" -----
call Bash_SetMapLeader ()

" maps defined here will use "g:BASH_MapLeader" as <LocalLeader>
" example:
"map  <buffer>  <LocalLeader>eg  :echo "Example Map :)"<CR>

" ---------- Run, compile, code checker --------------------------------------
nnoremap  <buffer>  <silent>  <C-F9>        :Bash<CR>
inoremap  <buffer>  <silent>  <C-F9>   <C-C>:Bash<CR>
vnoremap  <buffer>            <C-F9>        :Bash<CR>
" the ex-command :Bash handles the range in visual mode, do not escape via <C-C>

nnoremap  <buffer>            <S-F9>        :BashScriptArguments<Space>
inoremap  <buffer>            <S-F9>   <C-C>:BashScriptArguments<Space>

nnoremap  <buffer>            <A-F9>        :BashCheck<CR>
inoremap  <buffer>            <A-F9>   <C-C>:BashCheck<CR>

" ---------- Debugger --------------------------------------------------------

" use F9 to start the debugger
"nnoremap  <buffer>  <silent>  <F9>          :BashDB<CR>
"inoremap  <buffer>  <silent>  <F9>     <C-C>:BashDB<CR>
"vnoremap  <buffer>  <silent>  <F9>     <C-C>:BashDB<CR>

" map (D)ebugger (R)un
"nnoremap  <buffer>  <silent>  <LocalLeader>dr       :BashDB<CR>
"inoremap  <buffer>  <silent>  <LocalLeader>dr  <C-C>:BashDB<CR>
"vnoremap  <buffer>  <silent>  <LocalLeader>dr  <C-C>:BashDB<CR>
" map (D)ebugger (C)hoose method
"nnoremap  <buffer>            <LocalLeader>dc       :BashDBDebugger<Space>
"inoremap  <buffer>            <LocalLeader>dc  <C-C>:BashDBDebugger<Space>
"vnoremap  <buffer>            <LocalLeader>dc  <C-C>:BashDBDebugger<Space>

" ---------- Reset "maplocalleader" ------------------------------------------
call Bash_ResetMapLeader ()

