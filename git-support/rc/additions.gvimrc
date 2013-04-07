"-------------------------------------------------------------------------------
" Moving cursor to other windows:
"  shift-down   : change window focus to lower one (cyclic)
"  shift-up     : change window focus to upper one (cyclic)
"  shift-left   : change window focus to one on left
"  shift-right  : change window focus to one on right
"-------------------------------------------------------------------------------
nnoremap  <s-down>   <c-w>w
nnoremap  <s-up>     <c-w>W
nnoremap  <s-left>   <c-w>h
nnoremap  <s-right>  <c-w>l
"
"-------------------------------------------------------------------------------
" Some additional hot keys:
"  shift-F3  : call gvim file browser
"-------------------------------------------------------------------------------
 noremap  <silent> <s-F3>       :silent browse confirm e<CR>
inoremap  <silent> <s-F3>  <Esc>:silent browse confirm e<CR>
"
"-------------------------------------------------------------------------------
" toggle insert mode <--> normal mode with the <RightMouse>-key
"-------------------------------------------------------------------------------
nnoremap  <RightMouse>  <Insert>
inoremap  <RightMouse>  <ESC>
"
"-------------------------------------------------------------------------------
" use font with clearly distinguishable brackets: ()[]{}
"-------------------------------------------------------------------------------
set guifont=Monospace\ 11
"set guifont=Luxi\ Mono\ 14
"
