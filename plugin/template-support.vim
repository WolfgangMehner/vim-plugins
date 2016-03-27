"===============================================================================
"
"          File:  template-support.vim
"
"   Description:  
"
"   VIM Version:  7.0+
"        Author:  Wolfgang Mehner, wolfgang-mehner@web.de
"  Organization:  
"       Version:  see variable g:TemplateSupport_Version below
"       Created:  27.12.2015
"      Revision:  ---
"       License:  Copyright (c) 2015-2016, Wolfgang Mehner
"                 This program is free software; you can redistribute it and/or
"                 modify it under the terms of the GNU General Public License as
"                 published by the Free Software Foundation, version 2 of the
"                 License.
"                 This program is distributed in the hope that it will be
"                 useful, but WITHOUT ANY WARRANTY; without even the implied
"                 warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
"                 PURPOSE.
"                 See the GNU General Public License version 2 for more details.
"===============================================================================

"-------------------------------------------------------------------------------
" Basic checks.   {{{1
"-------------------------------------------------------------------------------

" need at least 7.0
if v:version < 700
	echohl WarningMsg
	echo 'The plugin template-support.vim needs Vim version >= 7.'
	echohl None
	finish
endif

" prevent duplicate loading
" need compatible
if &cp || ( exists('g:TemplateSupport_Version') && ! exists('g:TemplateSupport_DevelopmentOverwrite') )
	finish
endif
let g:TemplateSupport_Version= '1.0'     " version number of this script; do not change

"-------------------------------------------------------------------------------
" Modul setup.   {{{1
"-------------------------------------------------------------------------------

let s:MSWIN = has("win16") || has("win32")   || has("win64")    || has("win95")
let s:UNIX	= has("unix")  || has("macunix") || has("win32unix")

let s:Templates_RootMenu = '&Templates'         " name of the root menu

if ! exists ( 's:MenuVisible' )
	let s:MenuVisible = 0                         " menus are not visible at the moment
endif

let g:TemplateSupport_Records = {}

let s:filetype_list = mmtemplates#config#GetAll ()

let s:filetype_names = keys ( s:filetype_list )
call sort ( s:filetype_names )

let s:filetype_exclude = {
      \ 'awk'   : 1,
      \ 'bash'  : 1,
      \ 'c'     : 1,
      \ 'latex' : 1,
      \ 'lua'   : 1,
      \ 'perl'  : 1,
      \ 'vim'   : 1,
      \ }

let s:filetype_names_orig = copy ( s:filetype_names )

let s:filetype_names = []

for ft in s:filetype_names_orig
  if ! has_key ( s:filetype_exclude, ft )
    call add ( s:filetype_names, ft )

    let g:TemplateSupport_Records[ft] = {
          \ 'filetype' : ft,
          \ 'loaded'   : 0,
          \ 'menus'    : 0,
          \ 'list'     : s:filetype_list[ft],
          \ }
  endif
endfor

unlet s:filetype_names_orig

"-------------------------------------------------------------------------------
" s:CodeComment : Code -> Comment   {{{1
"-------------------------------------------------------------------------------

function! s:CodeComment( ft ) range

  let rec = g:TemplateSupport_Records[a:ft]

	let cmt_pre  = mmtemplates#core#Resource ( rec.templates, 'get', 'property', 'Comments::LinePrefix'  )[0]
	let cmt_post = mmtemplates#core#Resource ( rec.templates, 'get', 'property', 'Comments::LinePostfix' )[0]

	let cmt_pre  = escape ( cmt_pre,  '/\&~' )
	let cmt_post = escape ( cmt_post, '/\&~' )

	" add '%' at the beginning of the lines
	silent exe ":".a:firstline.",".a:lastline."s/.*/".cmt_pre."&".cmt_post."/"

endfunction    " ----------  end of function s:CodeComment  ----------

"-------------------------------------------------------------------------------
" s:CommentCode : Comment -> Code   {{{1
"-------------------------------------------------------------------------------

function! s:CommentCode( ft, toggle ) range

  let rec = g:TemplateSupport_Records[a:ft]

	let cmt_pre  = mmtemplates#core#Resource ( rec.templates, 'get', 'property', 'Comments::LinePrefix'  )[0]
	let cmt_post = mmtemplates#core#Resource ( rec.templates, 'get', 'property', 'Comments::LinePostfix' )[0]

	let cmt_indicator = '\V\^'.escape( cmt_pre, '\' )
	let cmt_pattern   = '\V\^'.escape( cmt_pre, '\/' ).'\(\.\*\)'

	if cmt_post != ''
		let cmt_indicator .= '\.\*'.escape( cmt_post, '\' ).'\s\*\$'
		let cmt_pattern   .=        escape( cmt_post, '\/' ).'\s\*\$'
	endif

	let cmt_pre  = escape ( cmt_pre,  '/\&~' )
	let cmt_post = escape ( cmt_post, '/\&~' )

	" remove comments:
	" - remove comment from the line
	" and, in toggling mode:
	" - if the line is not a comment, comment it
	for i in range( a:firstline, a:lastline )
		if 0 <= match( getline( i ), cmt_indicator )
			silent exe i."s/".cmt_pattern."/\\1/"
		elseif a:toggle
			silent exe i."s/.*/".cmt_pre."&".cmt_post."/"
		endif
	endfor

endfunction    " ----------  end of function s:CommentCode  ----------

"-------------------------------------------------------------------------------
" s:SetupTemplates : Initial loading of the templates.   {{{1
"-------------------------------------------------------------------------------

function! s:SetupTemplates ( rec )

  let rec = a:rec

	"-------------------------------------------------------------------------------
	" setup template library
	"-------------------------------------------------------------------------------
	let rec.templates = mmtemplates#core#NewLibrary ( 'api_version', '1.0' )

	" mapleader
	if empty ( g:Templates_MapLeader )
		call mmtemplates#core#Resource ( rec.templates, 'set', 'property', 'Templates::Mapleader', '\' )
	else
		call mmtemplates#core#Resource ( rec.templates, 'set', 'property', 'Templates::Mapleader', g:Templates_MapLeader )
	endif

	" maps: special operations
	call mmtemplates#core#Resource ( rec.templates, 'set', 'property', 'Templates::RereadTemplates::Map', 'ntr' )
	call mmtemplates#core#Resource ( rec.templates, 'set', 'property', 'Templates::ChooseStyle::Map',     'nts' )
	call mmtemplates#core#Resource ( rec.templates, 'set', 'property', 'Templates::SetupWizard::Map',     'ntw' )

	" syntax: comments
	call mmtemplates#core#ChangeSyntax ( rec.templates, 'comment', '§' )

	" comments: settings for 'code to comment' and vice versa
	call mmtemplates#core#Resource ( rec.templates, 'add', 'property', 'Comments::LinePrefix',  '' )
	call mmtemplates#core#Resource ( rec.templates, 'add', 'property', 'Comments::LinePostfix', '' )

	"-------------------------------------------------------------------------------
	" load template library
	"-------------------------------------------------------------------------------

	if ! empty ( rec.list )
		call mmtemplates#core#AddCustomTemplateFiles ( rec.templates, rec.list, rec.filetype."'s templates" )
	endif

	" personal templates (shared across template libraries) (optional, existence of file checked by template engine)
	call mmtemplates#core#ReadTemplates ( rec.templates, 'personalization',
				\ 'name', 'personal', 'map', 'ntp' )

endfunction    " ----------  end of function s:SetupTemplates  ----------

"-------------------------------------------------------------------------------
" s:CreateMenus : Create menus.   {{{1
"-------------------------------------------------------------------------------

function! s:CreateMenus ( rec )

  let rec = a:rec

	if ! s:MenuVisible
		exe 'anoremenu '.s:Templates_RootMenu.'.Template\ Support  <Nop>'
		exe 'anoremenu '.s:Templates_RootMenu.'.-Sep00-            <Nop>'

		let MenuVisible = 1
	endif

	let rec.rootmenu = s:Templates_RootMenu.'.'.'&'.rec.filetype

	let my_root = rec.rootmenu
	let my_name = rec.filetype

	let ft_str = string( rec.filetype )
	let my_var = 'g:TemplateSupport_Records['.ft_str.'].templates'

	exe 'anoremenu '.my_root.'.'.my_name.'<TAB>Templates  <Nop>'
	exe 'anoremenu '.my_root.'.-Sep00-                    <Nop>'

	" get the mapleader (correctly escaped)
	let [ esc_mapl, err ] = mmtemplates#core#Resource ( rec.templates, 'escaped_mapleader' )

	call mmtemplates#core#CreateMenus ( my_var, my_root, 'sub_menu', '&Comments',          'priority', 500 )
	call mmtemplates#core#CreateMenus ( my_var, my_root, 'sub_menu', 'Manage\ &Templates', 'priority', 600 )
	call mmtemplates#core#CreateMenus ( my_var, my_root, 'sub_menu', '&Help',              'priority', 700 )

	"-------------------------------------------------------------------------------
	" Comments
	"-------------------------------------------------------------------------------

	let ahead = 'anoremenu <silent> '.my_root.'.Comments.'
	let vhead = 'vnoremenu <silent> '.my_root.'.Comments.'

	let cmt_pre  = mmtemplates#core#Resource ( rec.templates, 'get', 'property', 'Comments::LinePrefix' )[0]

	if ! empty ( cmt_pre )
		exe ahead.'&code\ ->\ comment<TAB>'.esc_mapl.'cc         :call <SID>CodeComment('.ft_str.')<CR>'
		exe vhead.'&code\ ->\ comment<TAB>'.esc_mapl.'cc         :call <SID>CodeComment('.ft_str.')<CR>'
		exe ahead.'c&omment\ ->\ code<TAB>'.esc_mapl.'co         :call <SID>CommentCode('.ft_str.',0)<CR>'
		exe vhead.'c&omment\ ->\ code<TAB>'.esc_mapl.'co         :call <SID>CommentCode('.ft_str.',0)<CR>'
		exe ahead.'&toggle\ code\ <->\ com\.<TAB>'.esc_mapl.'ct  :call <SID>CommentCode('.ft_str.',1)<CR>'
		exe vhead.'&toggle\ code\ <->\ com\.<TAB>'.esc_mapl.'ct  :call <SID>CommentCode('.ft_str.',1)<CR>'

		exe ahead.'-Sep01- <Nop>'
	endif

	"-------------------------------------------------------------------------------
	" Template Library
	"-------------------------------------------------------------------------------

	call mmtemplates#core#CreateMenus ( my_var, my_root, 'do_templates' )
	call mmtemplates#core#CreateMenus ( my_var, my_root, 'do_specials', 'specials_menu', 'Manage\ &Templates'	)

endfunction    " ----------  end of function s:CreateMenus  ----------

"-------------------------------------------------------------------------------
" s:CreateMaps : Create maps.   {{{1
"-------------------------------------------------------------------------------

function! s:CreateMaps ( rec )

  let rec = a:rec
	let ft_str = string ( a:rec.filetype )

	"-------------------------------------------------------------------------------
	" settings - local leader
	"-------------------------------------------------------------------------------
	if ! empty ( g:Templates_MapLeader )
		if exists ( 'g:maplocalleader' )
			let ll_save = g:maplocalleader
		endif
		let g:maplocalleader = g:Templates_MapLeader
	endif

	"-------------------------------------------------------------------------------
	" comments
	"-------------------------------------------------------------------------------

	let cmt_pre  = mmtemplates#core#Resource ( rec.templates, 'get', 'property', 'Comments::LinePrefix' )[0]

	if ! empty ( cmt_pre )
		exe ' noremap    <buffer>  <silent>  <LocalLeader>cc         :call <SID>CodeComment('.ft_str.')<CR>'
		exe 'inoremap    <buffer>  <silent>  <LocalLeader>cc    <Esc>:call <SID>CodeComment('.ft_str.')<CR>'
		exe ' noremap    <buffer>  <silent>  <LocalLeader>co         :call <SID>CommentCode('.ft_str.',0)<CR>'
		exe 'inoremap    <buffer>  <silent>  <LocalLeader>co    <Esc>:call <SID>CommentCode('.ft_str.',0)<CR>'
		exe ' noremap    <buffer>  <silent>  <LocalLeader>ct         :call <SID>CommentCode('.ft_str.',1)<CR>'
		exe 'inoremap    <buffer>  <silent>  <LocalLeader>ct    <Esc>:call <SID>CommentCode('.ft_str.',1)<CR>'
	endif

	"-------------------------------------------------------------------------------
	" settings - reset local leader
	"-------------------------------------------------------------------------------
	if ! empty ( g:Templates_MapLeader )
		if exists ( 'll_save' )
			let g:maplocalleader = ll_save
		else
			unlet g:maplocalleader
		endif
	endif

	"-------------------------------------------------------------------------------
	" Template Library
	"-------------------------------------------------------------------------------

	call mmtemplates#core#CreateMaps ( 'g:TemplateSupport_Records['.ft_str.'].templates', g:Templates_MapLeader, 'do_special_maps', 'do_jump_map', 'do_del_opt_map' )

endfunction    " ----------  end of function s:CreateMaps  ----------

"-------------------------------------------------------------------------------
" s:HandleFiletype : Callback for a filetype.   {{{1
"
" Parameters:
"   ft - the name of the filetype (string)
" Returns:
"   -
"-------------------------------------------------------------------------------

function! s:HandleFiletype ( ft )
  
  let rec = g:TemplateSupport_Records[a:ft]

  if ! rec.loaded
    call s:SetupTemplates ( rec )

    let rec.loaded = 1
  endif

  if ! rec.menus
    call s:CreateMenus ( rec )

    let rec.menus = 1
  endif

  call s:CreateMaps ( rec )

endfunction    " ----------  end of function s:HandleFiletype  ----------

"-------------------------------------------------------------------------------
" Setup: Templates and menus.   {{{1
"-------------------------------------------------------------------------------

if has( 'autocmd' )
  for ft in s:filetype_names
    exe 'autocmd FileType '.ft.' call <SID>HandleFiletype ( '.string( ft ).' )'
  endfor
endif
" }}}1
"-------------------------------------------------------------------------------

" =====================================================================================
"  vim: foldmethod=marker
