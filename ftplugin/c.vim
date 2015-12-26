" ------------------------------------------------------------------------------
"
" Vim filetype plugin file
"
"   Language :  C
"     Plugin :  c.vim 
" Maintainer :  Wolfgang Mehner <wolfgang-mehner@web.de>
"               (formerly Fritz Mehner <mehner.fritz@web.de>)
"
" ------------------------------------------------------------------------------
"
" Only do this when not done yet for this buffer
" 
if exists("b:did_C_ftplugin")
  finish
endif
let b:did_C_ftplugin = 1
"
"-------------------------------------------------------------------------------
" additional mapping : complete a classical C comment: '/*' => '/* | */'
"-------------------------------------------------------------------------------
inoremap  <buffer>  /*       /*<Space><Space>*/<Left><Left><Left>
vnoremap  <buffer>  /*      s/*<Space><Space>*/<Left><Left><Left><Esc>p
"
"-------------------------------------------------------------------------------
" additional mapping : complete a classical C multi-line comment: 
"                      '/*<CR>' =>  /*
"                                    * |
"                                    */
"-------------------------------------------------------------------------------
inoremap  <buffer>  /*<CR>  /*<CR><CR>/<Esc>kA<Space>
"
"-------------------------------------------------------------------------------
" additional mapping : {<CR> always opens a block
"-------------------------------------------------------------------------------
inoremap  <buffer>  {<CR>    {<CR>}<Esc>O
vnoremap  <buffer>  {<CR>   S{<CR>}<Esc>Pk=iB
"
"-------------------------------------------------------------------------------
" set "maplocalleader" as configured using "g:C_MapLeader"
"-------------------------------------------------------------------------------
call C_SetMapLeader ()
"
"-------------------------------------------------------------------------------
" additional mapping : Make tool
"-------------------------------------------------------------------------------
 noremap  <buffer>  <silent>  <LocalLeader>rm        :Make<CR>
inoremap  <buffer>  <silent>  <LocalLeader>rm   <C-C>:Make<CR>
 noremap  <buffer>  <silent>  <LocalLeader>rmc       :Make clean<CR>
inoremap  <buffer>  <silent>  <LocalLeader>rmc  <C-C>:Make clean<CR>
 noremap  <buffer>            <LocalLeader>rma       :MakeCmdlineArgs<space>
inoremap  <buffer>            <LocalLeader>rma  <C-C>:MakeCmdlineArgs<space>
 noremap  <buffer>            <LocalLeader>rcm       :MakeFile<space>
inoremap  <buffer>            <LocalLeader>rcm  <C-C>:MakeFile<space>
"
"-------------------------------------------------------------------------------
" reset "maplocalleader"
"-------------------------------------------------------------------------------
call C_ResetMapLeader ()
"
