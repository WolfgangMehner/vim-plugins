"-------------------------------------------------------------------------------
" File
"-------------------------------------------------------------------------------
if exists ( 'b:did_project_in_vim' )
	finish
endif
let b:did_project_in_vim = 1

" Option: spelling
set spl=en spell

"-------------------------------------------------------------------------------
" Project
"-------------------------------------------------------------------------------
if exists ( 'g:did_project_in_vim' ) && g:did_project_in_vim == 'VimWebsite'
	finish
endif
let g:did_project_in_vim = 'VimWebsite'

" C: path for 'project_include'
let  mypath = expand ( '<sfile>:p:h:h' ).'/'

" Make: directories
call mmtoolbox#make#Property ( 'set', 'makefile', mypath.'Makefile' )
