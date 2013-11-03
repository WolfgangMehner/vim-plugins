"-------------------------------------------------------------------------------
" example for using the C/C++ toolbox together with the project plug-in's "in="
" option (a file like this one can be used as the script set by the "in="
" option):
"   :help project.txt
"   :help project-syntax
"   :help toolbox-cmake
"   :help toolbox-doxygen
"   :help toolbox-make
"-------------------------------------------------------------------------------

let s:project_name = 'TODO'

"-------------------------------------------------------------------------------
" Project
"-------------------------------------------------------------------------------
if ! exists ( 'g:did_project_in_vim' ) || g:did_project_in_vim != s:project_name

	let g:did_project_in_vim = s:project_name

	" in.vim is located in the project's top-level directory:
	let s:mypath = expand ( '<sfile>:p:h' ).'/'

	" --- OR ---

" 	" in.vim is located in a directory below the top-level directory
" 	" (e.g. project/in.vim):
" 	let s:mypath = expand ( '<sfile>:p:h:h' ).'/'

" 	" C: path for 'project_include'
" 	call mmtemplates#core#Resource ( g:C_Templates, 'set', 'path',
" 	\ 'project_include', s:mypath )

" 	" C: set style
" 	call mmtemplates#core#ChooseStyle ( g:C_Templates, "DOXYGEN" )

" 	" CMake: directories
" 	" - the build is located in a sub-directory build/
" 	call mmtoolbox#cmake#Property ( 'set', 'project-dir', s:mypath )
" 	call mmtoolbox#cmake#Property ( 'set', 'build-dir',   s:mypath.'build' )

" 	" Doxygen: files
" 	" - the "Doxyfile" is located in the top-level directory
" 	" - The setting for "log-file" is actually the default
" 	" - the "WARN_LOGFILE" option is the in Doxyfile:
" 	"     WARN_LOGFILE = "doxy_warnings.txt"
" 	call mmtoolbox#doxygen#Property ( 'set', 'config-file', s:mypath.'Doxyfile' )
" 	call mmtoolbox#doxygen#Property ( 'set', 'log-file',    s:mypath.'.doxygen.log' )
" 	call mmtoolbox#doxygen#Property ( 'set', 'error-file',  s:mypath.'doxy_warnings.txt' )

" 	" Make: files
" 	" - the "Makefile" is located in the top-level directory
" 	call mmtoolbox#make#Property ( 'set', 'makefile', s:mypath.'Makefile' )

endif

"-------------------------------------------------------------------------------
" File
"-------------------------------------------------------------------------------
if ! exists ( 'b:did_project_in_vim' )

	let b:did_project_in_vim = 1

" 	" Option: spelling
" 	set spl=en spell

" 	" Option: filetype (additional Doxygen documentation)
" 	if bufname('%') =~ '\V.docu\$'
" 		set filetype=c
" 	endif

endif
