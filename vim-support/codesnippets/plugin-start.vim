"
" Prevent duplicate loading:
"
if exists("g:PLUGIN_Version") || &cp
 finish
endif
let g:PLUGIN_Version= "0.1"  						" version number of this script; do not change
"
if v:version < 700
  echohl WarningMsg | echo 'plugin PLUGIN.vim needs Vim version >= 7'| echohl None
endif
