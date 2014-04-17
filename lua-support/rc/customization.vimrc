"===================================================================================
"         FILE:  .vimrc
"  DESCRIPTION:  suggestion for a personal configuration file ~/.vimrc
"       AUTHOR:  Wolfgang Mehner
"      VERSION:  1.0
"      CREATED:  17.06.2012
"     REVISION:  
"===================================================================================
"
"===================================================================================
" GENERAL SETTINGS
"===================================================================================
"
"-------------------------------------------------------------------------------
" Use Vim settings, rather then Vi settings.
" This must be first, because it changes other options as a side effect.
"-------------------------------------------------------------------------------
set nocompatible
"
"-------------------------------------------------------------------------------
" Enable file type detection. Use the default filetype settings.
" Also load indent files, to automatically do language-dependent indenting.
"-------------------------------------------------------------------------------
filetype  plugin on
filetype  indent on
"
"-------------------------------------------------------------------------------
" Switch syntax highlighting on.
"-------------------------------------------------------------------------------
syntax    on
"
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
"
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
set history=50                  " keep 50 lines of command line history
set hlsearch                    " highlight the last used search pattern
set incsearch                   " do incremental searching
set listchars=tab:>.,eol:\$     " strings to use in 'list' mode
set mouse=a                     " enable the use of the mouse
set nowrap                      " do not wrap lines
set popt=left:8pc,right:3pc     " print options
set ruler                       " show the cursor position all the time
set shiftwidth=2                " number of spaces to use for each step of indent
set showcmd                     " display incomplete commands
set smartindent                 " smart autoindenting when starting a new line
set tabstop=2                   " number of spaces that a <Tab> counts for
set visualbell                  " visual bell instead of beeping
set wildignore=*.bak,*.o,*.e,*~ " wildmenu: ignore these extensions
set wildmenu                    " command-line completion in an enhanced mode
"
"-------------------------------------------------------------------------------
"  Highlight paired brackets
"-------------------------------------------------------------------------------
highlight MatchParen ctermbg=blue guibg=lightyellow
"
"===================================================================================
" BUFFERS and WINDOWS
"===================================================================================
"
"-------------------------------------------------------------------------------
" Change the working directory to the directory containing the current file
"-------------------------------------------------------------------------------
if has("autocmd")
  autocmd BufEnter * :lchdir %:p:h
endif
"
"-------------------------------------------------------------------------------
" Fast switching between buffers
" The current buffer will be saved before switching to the next one.
" Choose :bprevious or :bnext
"-------------------------------------------------------------------------------
 noremap  <silent> <s-tab>       :if &modifiable && !&readonly &&
     \                      &modified <CR> :write<CR> :endif<CR>:bprevious<CR>
inoremap  <silent> <s-tab>  <C-C>:if &modifiable && !&readonly &&
     \                      &modified <CR> :write<CR> :endif<CR>:bprevious<CR>
"
"-------------------------------------------------------------------------------
" Leave the editor with Ctrl-q: Write all changed buffers and exit Vim
"-------------------------------------------------------------------------------
nnoremap  <C-q>    :wqall<CR>
"
"===================================================================================
" HOT KEYS
"===================================================================================
"
"-------------------------------------------------------------------------------
"     F2  -  write file without confirmation
"     F3  -  call file explorer Ex
"     F4  -  show tag under curser in the preview window (tagfile must exist!)
"     F5  -  show the current list of errors
"     F6  -  close the quickfix window (error list)
"     F7  -  display previous error
"     F8  -  display next error
"     F12 -  list buffers and edit n-th buffer
"-------------------------------------------------------------------------------
"
noremap   <silent> <F2>         :write<CR>
noremap   <silent> <F3>         :Explore<CR>
noremap   <silent> <F4>         :execute ":ptag ".expand("<cword>")<CR>
noremap   <silent> <F5>         :copen<CR>
noremap   <silent> <F6>         :cclose<CR>
noremap   <silent> <F7>         :cprevious<CR>
noremap   <silent> <F8>         :cnext<CR>
noremap            <F12>        :ls<CR>:edit #
"
inoremap  <silent> <F2>    <C-C>:write<CR>
inoremap  <silent> <F3>    <C-C>:Explore<CR>
inoremap  <silent> <F4>    <C-C>:execute ":ptag ".expand("<cword>")<CR>
inoremap  <silent> <F5>    <C-C>:copen<CR>
inoremap  <silent> <F6>    <C-C>:cclose<CR>
inoremap  <silent> <F7>    <C-C>:cprevious<CR>
inoremap  <silent> <F8>    <C-C>:cnext<CR>
inoremap           <F12>   <C-C>:ls<CR>:edit #
"
"-------------------------------------------------------------------------------
" autocomplete parenthesis, brackets and braces
"-------------------------------------------------------------------------------
inoremap  (  ()<Left>
inoremap  [  []<Left>
inoremap  {  {}<Left>
"
" surround content
vnoremap  (  s()<Esc>P<Right>%
vnoremap  [  s[]<Esc>P<Right>%
vnoremap  {  s{}<Esc>P<Right>%
"
" surround content with additional spaces
vnoremap  )  s(<Space><Space>)<Esc><Left>P<Right><Right>%
vnoremap  ]  s[<Space><Space>]<Esc><Left>P<Right><Right>%
vnoremap  }  s{<Space><Space>}<Esc><Left>P<Right><Right>%
"
"-------------------------------------------------------------------------------
" autocomplete quotes
"-------------------------------------------------------------------------------
"
inoremap  ''  ''<Left>
inoremap  ""  ""<Left>
"
" surround content (visual and select mode)
xnoremap  '  s''<Esc>P<Right>
xnoremap  "  s""<Esc>P<Right>
xnoremap  `  s``<Esc>P<Right>
"
"===================================================================================
" VARIOUS PLUGIN CONFIGURATIONS
"===================================================================================
"
"-------------------------------------------------------------------------------
" Lua-Support
"-------------------------------------------------------------------------------
"
" the settings are documented here:
"  :help lua-configuration
"
"-------------------------------------------------------------------------------
"
"let g:Lua_LoadMenus  = 'auto'
"let g:Lua_RootMenu   = '&Lua'
"
"let g:Lua_MapLeader  = '\'
"
"let g:Lua_Executable   = 'lua'
"let g:Lua_CompilerExec = 'luac'
"let g:Lua_CompiledExtension = 'luac'
"
"let g:Lua_LclTemplateFile = '~/ TODO /Templates'
"
