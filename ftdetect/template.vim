"===============================================================================
"
"          File:  template.vim
" 
"   Description:  Filetype detection for templates.
"
"                 Straight out of the documentation:
"                 - do not overwrite the filetype if it has already been set
" 
"   VIM Version:  7.0+
"        Author:  Wolfgang Mehner, wolfgang-mehner@web.de
"  Organization:  
"       Version:  1.0
"       Created:  07.06.2015
"      Revision:  ---
"       License:  Copyright (c) 2015, Wolfgang Mehner
"===============================================================================

autocmd BufNewFile,BufRead *.template,*.templates,Templates setfiletype template
