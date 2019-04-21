"===============================================================================
"
"          File:  customization.vimrc
"
"   Description:  suggestion for a personal configuration file ~/.vimrc
"
"   VIM Version:  7.0+
"        Author:  Wolfgang Mehner, wolfgang-mehner@web.de
"                 Dr. Fritz Mehner (fgm), mehner.fritz@web.de
"      Revision:  15.04.2019
"       License:  Copyright (c) 2009-2018, Dr. Fritz Mehner
"                 Copyright (c) 2019, Wolfgang Mehner
"===============================================================================

"===============================================================================
" GENERAL SETTINGS
"===============================================================================

"-------------------------------------------------------------------------------
" Use Vim settings, rather then Vi settings.
" This must be first, because it changes other options as a side effect.
"-------------------------------------------------------------------------------
set nocompatible

"-------------------------------------------------------------------------------
" Enable file type detection. Use the default filetype settings.
" Also load indent files, to automatically do language-dependent indenting.
"-------------------------------------------------------------------------------
filetype  plugin on
filetype  indent on

"-------------------------------------------------------------------------------
" Switch syntax highlighting on.
"-------------------------------------------------------------------------------
syntax    on

"-------------------------------------------------------------------------------
" Platform specific items:
" - central backup directory (has to be created)
" - default dictionary
" Uncomment your choice.
"
" Using a backupdir under UNIX/Linux: you may want to include a line similar to:
"   find  $HOME/.vim.backupdir -name "*" -type f -mtime +60 -exec rm -f {} \;
" in one of your shell startup files (e.g. $HOME/.profile).
"-------------------------------------------------------------------------------
if  has("win16") || has("win32")     || has("win64") ||
  \ has("win95") || has("win32unix")
"  runtime mswin.vim
"  set backupdir =$VIM\vimfiles\backupdir
"  set dictionary=$VIM\vimfiles\wordlists/german.list
else
"  set backupdir =$HOME/.vim.backupdir
"  set dictionary=$HOME/.vim/wordlists/german.list,$HOME/.vim/wordlists/english.list
endif

"-------------------------------------------------------------------------------
" Various settings
"-------------------------------------------------------------------------------
set autoindent                  " copy indent from current line
set autoread                    " read open files again when changed outside Vim
set autowrite                   " write a modified buffer on each :next , ...
set backspace=indent,eol,start  " backspacing over everything in insert mode
set backup                      " keep a backup file
set browsedir=current           " which directory to use for the file browser
set complete+=k                 " scan the files given with the 'dictionary' option
set formatoptions+=j            " remove comment leader when joining lines
set history=50                  " keep 50 lines of command line history
set hlsearch                    " highlight the last used search pattern
set incsearch                   " do incremental searching
set listchars=tab:>.,eol:\$     " strings to use in 'list' mode
set mouse=a                     " enable the use of the mouse
set popt=left:8pc,right:3pc     " print options
set ruler                       " show the cursor position all the time
set shiftwidth=2                " number of spaces to use for each step of indent
set showcmd                     " display incomplete commands
set smartindent                 " smart autoindenting when starting a new line
set tabstop=2                   " number of spaces that a <Tab> counts for
set visualbell                  " visual bell instead of beeping
set wildignore=*.bak,*.o,*.e,*~ " wildmenu: ignore these extensions
set wildmenu                    " command-line completion in an enhanced mode
set nowrap                      " do not wrap lines

"-------------------------------------------------------------------------------
"  Highlight paired brackets
"-------------------------------------------------------------------------------
"highlight MatchParen ctermbg=blue guibg=lightyellow

"===============================================================================
" BUFFERS, WINDOWS
"===============================================================================

"-------------------------------------------------------------------------------
" When editing a file, always jump to the last known cursor position.
" Don't do it when the position is invalid or when inside an event handler
" (happens when dropping a file on gvim).
"-------------------------------------------------------------------------------
if has("autocmd")
	augroup MyResetCursor
	autocmd BufReadPost *
				\ if line("'\"") > 0 && line("'\"") <= line("$") |
				\   exe "normal! g`\"" |
				\ endif
	augroup END
endif

"-------------------------------------------------------------------------------
" Change the working directory to the directory containing the current file
"-------------------------------------------------------------------------------
if has("autocmd")
	augroup MySetLocalDir
	autocmd BufEnter * :lchdir %:p:h
	augroup END
endif

"-------------------------------------------------------------------------------
" Fast switching between buffers
" The current buffer will be saved before switching to the next one.
" Choose :bprevious or :bnext
"-------------------------------------------------------------------------------
"nnoremap  <silent> <s-tab>       :if !&readonly && &modifiable && &modified <CR>
"			\                            :write<CR> :endif<CR> :bprevious<CR>
"inoremap  <silent> <s-tab>  <C-C>:if !&readonly && &modifiable && &modified <CR>
"			\                            :write<CR> :endif<CR> :bprevious<CR>

"-------------------------------------------------------------------------------
" Leave the editor with Ctrl-q: Write all changed buffers and exit Vim
"-------------------------------------------------------------------------------
nnoremap  <C-q>    :wqall<CR>

"-------------------------------------------------------------------------------
" Some additional hot keys
"
"    F2   -  write file without confirmation
"    F3   -  call file explorer Ex
"    F4   -  show tag under cursor in the preview window (tagfile must exist!)
"    F5   -  open quickfix error window
"    F6   -  close quickfix error window
"    F7   -  display previous error
"    F8   -  display next error
"    F12  -  list buffers and prompt for a buffer name
"-------------------------------------------------------------------------------

noremap   <silent> <F2>         :write<CR>
noremap   <silent> <F3>         :Explore<CR>
nnoremap  <silent> <F4>         :execute ":ptag ".expand("<cword>")<CR>
noremap   <silent> <F5>         :copen<CR>
noremap   <silent> <F6>         :cclose<CR>
noremap   <silent> <F7>         :cprevious<CR>
noremap   <silent> <F8>         :cnext<CR>
noremap            <F12>        :buffer <C-D>
noremap            <S-F12>      :sbuffer <C-D>

inoremap  <silent> <F2>    <Esc>:write<CR>
inoremap  <silent> <F3>    <Esc>:Explore<CR>
inoremap  <silent> <F4>    <Esc>:execute ":ptag ".expand("<cword>")<CR>
inoremap  <silent> <F5>    <Esc>:copen<CR>
inoremap  <silent> <F6>    <Esc>:cclose<CR>
inoremap  <silent> <F7>    <Esc>:cprevious<CR>
inoremap  <silent> <F8>    <Esc>:cnext<CR>
inoremap           <F12>   <C-C>:buffer <C-D>
inoremap           <S-F12> <C-C>:sbuffer <C-D>

"-------------------------------------------------------------------------------
" Always wrap lines in the quickfix buffer
"-------------------------------------------------------------------------------
"autocmd BufReadPost quickfix  setlocal wrap | setlocal linebreak

"===============================================================================
" AUTOCOMPLETE BRACKETS, QUOTES
"===============================================================================

"-------------------------------------------------------------------------------
" Autocomplete parenthesis, brackets and braces
"-------------------------------------------------------------------------------

inoremap  (  ()<Left>
inoremap  [  []<Left>
inoremap  {  {}<Left>

" surround content
vnoremap  (  s()<Esc>P<Right>%
vnoremap  [  s[]<Esc>P<Right>%
vnoremap  {  s{}<Esc>P<Right>%

" surround content with additional spaces
vnoremap  )  s(<Space><Space>)<Esc><Left>P<Right><Right>%
vnoremap  ]  s[<Space><Space>]<Esc><Left>P<Right><Right>%
vnoremap  }  s{<Space><Space>}<Esc><Left>P<Right><Right>%

"-------------------------------------------------------------------------------
" Autocomplete quotes
"-------------------------------------------------------------------------------

" surround content (visual and select mode)
vnoremap  '  s''<Esc>P<Right>
vnoremap  "  s""<Esc>P<Right>
vnoremap  `  s``<Esc>P<Right>

"===============================================================================
" VARIOUS PLUGIN CONFIGURATIONS
"===============================================================================

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
