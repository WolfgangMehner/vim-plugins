"-------------------------------------------------------------------------------
" Git-Support
"-------------------------------------------------------------------------------
"
" the settings are documented here:
"  :help gitsupport-configuration
" the syntax highlighting is documented here:
"  :help gitsupport-syntax
"
"-------------------------------------------------------------------------------
"
"let g:Git_Executable = 'LANG=en_US git'
"
"let g:Git_LoadMenus  = 'yes'
"let g:Git_RootMenu   = '&Git'
"
" open the status window
" noremap <silent> <F10>       :GitStatus<CR>
"inoremap <silent> <F10>  <C-C>:GitStatus<CR>
"
" syntax highlighting (bright background)
"
"highlight GitComment
highlight GitHeading1    cterm=bold                              gui=bold
highlight GitHeading2    cterm=bold  ctermfg=Cyan                gui=bold  guifg=DarkCyan
highlight GitHighlight1  ctermfg=Green                           guifg=DarkGreen
highlight GitHighlight2  ctermfg=DarkYellow                      guifg=DarkYellow
"highlight GitWarning
highlight GitAdd         ctermfg=Green                           guifg=SeaGreen
highlight GitRemove      ctermfg=Red                             guifg=Red
highlight GitConflict    cterm=bold  ctermfg=White  ctermbg=Red  gui=bold  guifg=White  guibg=Red
"
" " syntax highlighting (dark background)
" "
" "highlight GitComment
" highlight GitHeading1    cterm=bold                              gui=bold
" highlight GitHeading2    cterm=bold  ctermfg=Cyan                gui=bold  guifg=Cyan
" highlight GitHighlight1  ctermfg=Green                           guifg=Green
" highlight GitHighlight2  ctermfg=Yellow                          guifg=Yellow
" "highlight GitWarning
" highlight GitAdd         ctermfg=Green                           guifg=Green
" highlight GitRemove      ctermfg=Red                             guifg=Red
" highlight GitConflict    cterm=bold  ctermfg=White  ctermbg=Red  gui=bold  guifg=White  guibg=Red
"
