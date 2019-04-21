"-------------------------------------------------------------------------------
" Git-Support
"
" the settings are documented here:
"  :help gitsupport-configuration
" the syntax highlighting is documented here:
"  :help gitsupport-syntax
"-------------------------------------------------------------------------------

"let g:Git_BinPath    = '/path/to/git/exe'
"let g:Git_Executable = 'LANG=en_US git'

"let g:Git_LoadMenus  = 'yes'
"let g:Git_RootMenu   = '&Git'

"" open the status window
"nnoremap <silent> <F10>       :GitStatus<CR>
"inoremap <silent> <F10>  <C-C>:GitStatus<CR>

"" cmd-line completion
"" (use ctrl+s for commands, since we do not want to remap ctrl+c,
"" "s" stands for Git 's'ubcommands)
"let g:Git_MapCompleteBranch  = '<c-b>'
"let g:Git_MapCompleteCommand = '<c-s>'
"let g:Git_MapCompleteRemote  = '<c-r>'
"let g:Git_MapCompleteTag     = '<c-t>'

" syntax highlighting (bright background)
" needs to be updated every time we change the colorscheme

augroup GitSupport
"autocmd VimEnter,ColorScheme * highlight GitComment
autocmd VimEnter,ColorScheme * highlight GitHeading     cterm=bold                              gui=bold
autocmd VimEnter,ColorScheme * highlight GitHighlight1  ctermfg=Green                           guifg=DarkGreen
autocmd VimEnter,ColorScheme * highlight GitHighlight2  ctermfg=DarkYellow                      guifg=DarkYellow
autocmd VimEnter,ColorScheme * highlight GitHighlight3  cterm=bold  ctermfg=Cyan                gui=bold  guifg=DarkCyan
"autocmd VimEnter,ColorScheme * highlight GitWarning
autocmd VimEnter,ColorScheme * highlight GitAdd         ctermfg=Green                           guifg=SeaGreen
autocmd VimEnter,ColorScheme * highlight GitRemove      ctermfg=Red                             guifg=Red
autocmd VimEnter,ColorScheme * highlight GitConflict    cterm=bold  ctermfg=White  ctermbg=Red  gui=bold  guifg=White  guibg=Red
augroup END

"" syntax highlighting (dark background)
"" needs to be updated every time we change the colorscheme
"
"augroup GitSupport
""autocmd VimEnter,ColorScheme * highlight GitComment
"autocmd VimEnter,ColorScheme * highlight GitHeading     cterm=bold                              gui=bold
"autocmd VimEnter,ColorScheme * highlight GitHighlight1  ctermfg=Green                           guifg=Green
"autocmd VimEnter,ColorScheme * highlight GitHighlight2  ctermfg=Yellow                          guifg=Yellow
"autocmd VimEnter,ColorScheme * highlight GitHighlight3  cterm=bold  ctermfg=Cyan                gui=bold  guifg=Cyan
""autocmd VimEnter,ColorScheme * highlight GitWarning
"autocmd VimEnter,ColorScheme * highlight GitAdd         ctermfg=Green                           guifg=Green
"autocmd VimEnter,ColorScheme * highlight GitRemove      ctermfg=Red                             guifg=Red
"autocmd VimEnter,ColorScheme * highlight GitConflict    cterm=bold  ctermfg=White  ctermbg=Red  gui=bold  guifg=White  guibg=Red
"augroup END

"" custom menu
"let g:Git_CustomMenu = [
"			\ [ '&grep, word under cursor',  ':GitGrepTop', ':GitGrepTop <WORD><EXECUTE>' ],
"			\ [ '&grep, version x..y',       ':GitGrepTop', ':GitGrepTop -i "Version[^[:digit:]]\+<CURSOR>"' ],
"			\ [ '-SEP1-',                    '',            '' ],
"			\ [ '&log, grep commit msg..',   ':GitLog',     ':GitLog -i --grep="<CURSOR>"' ],
"			\ [ '&log, grep diff word',      ':GitLog',     ':GitLog -p -S "<CURSOR>"' ],
"			\ [ '&log, grep diff line',      ':GitLog',     ':GitLog -p -G "<CURSOR>"' ],
"			\ [ '-SEP2-',                    '',            '' ],
"			\ [ '&merge, fast-forward only', ':GitMerge',   ':GitMerge --ff-only <CURSOR>' ],
"			\ [ '&merge, no commit',         ':GitMerge',   ':GitMerge --no-commit <CURSOR>' ],
"			\ [ '&merge, abort',             ':GitMerge',   ':GitMerge --abort<EXECUTE>' ],
"			\ ]
