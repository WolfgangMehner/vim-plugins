#!/usr/bin/env lua
--
--------------------------------------------------------------------------------
--         FILE:  release.lua
--
--        USAGE:  lua project/release.lua <plugin> <mode> [<options>]
--
--  DESCRIPTION:  Run from the project's top-level directory.
--
--      OPTIONS:  The plug-in is one of:
--                - awk
--                - bash
--                - c
--                - git
--                - latex
--                - lua
--                - matlab
--                - perl
--                - vim
--
--                The mode is one of:
--                - list
--                - check
--                - zip
--                - archive
--                - cp-repo
--                - help
--
-- REQUIREMENTS:  ---
--         BUGS:  ---
--        NOTES:  ---
--       AUTHOR:  Wolfgang Mehner, <wolfgang-mehner@web.de>
--      COMPANY:  
--      VERSION:  1.0
--      CREATED:  05.01.2016
--     REVISION:  ---
--------------------------------------------------------------------------------
--

------------------------------------------------------------------------
--  Auxiliary Functions   {{{1
------------------------------------------------------------------------

local function escape_shell ( text )
	return string.gsub ( text, '[%(%);&=\' ]', function ( m ) return '\\' .. m end )
end  ----------  end of function escape_shell  ----------

--  }}}1
------------------------------------------------------------------------


------------------------------------------------------------------------
--  Arguments and Lists   {{{1
------------------------------------------------------------------------

local print_help = false

local args = { ... }

-- files for the zip-archive
local filelists      = {}

-- additional files for the stand-alone repository
local filelists_repo = {}

--  }}}1
------------------------------------------------------------------------


------------------------------------------------------------------------
--  Awk   {{{1
------------------------------------------------------------------------

filelists.awk = {
	'autoload/mmtemplates/',
	'doc/awksupport.txt',
	'doc/templatesupport.txt',
	'ftdetect/template.vim',
	'ftplugin/template.vim',
	'plugin/awk-support.vim',
	'syntax/template.vim',
	'awk-support/codesnippets/',
	'awk-support/doc/ChangeLog',
	'awk-support/doc/awk-hotkeys.pdf',
	'awk-support/doc/awk-hotkeys.tex',
	'awk-support/rc/',
	'awk-support/scripts/',
	'awk-support/templates/',
	'awk-support/wordlists/',
	'awk-support/README.md',
}

filelists_repo.awk = {
	'project/release.lua',
}

------------------------------------------------------------------------
--  Bash   {{{1
------------------------------------------------------------------------

filelists.bash = {
	'autoload/mmtemplates/',
	'autoload/mmtoolbox/tools.vim',
	'autoload/mmtoolbox/bash/bashdb.vim',
	'doc/bashsupport.txt',
	'doc/templatesupport.txt',
	'doc/toolbox.txt',
	'doc/bashdbintegration.txt',
	'ftdetect/template.vim',
	'ftplugin/bashhelp.vim',
	'ftplugin/template.vim',
	'plugin/bash-support.vim',
	'syntax/bashhelp.vim',
	'syntax/template.vim',
	'bash-support/codesnippets/',
	'bash-support/doc/ChangeLog',
	'bash-support/doc/bash-hotkeys.pdf',
	'bash-support/doc/bash-hotkeys.tex',
	'bash-support/rc/',
	'bash-support/scripts/',
	'bash-support/templates/',
	'bash-support/wordlists/',
	'bash-support/README.md',
}

filelists_repo.bash = {
	'project/release.lua',
}

------------------------------------------------------------------------
--  C/C++   {{{1
------------------------------------------------------------------------

filelists.c = {
	'autoload/mmtemplates/',
	'autoload/mmtoolbox/cmake.vim',
	'autoload/mmtoolbox/doxygen.vim',
	'autoload/mmtoolbox/make.vim',
	'autoload/mmtoolbox/tools.vim',
	'doc/csupport.txt',
	'doc/templatesupport.txt',
	'doc/toolbox.txt',
	'doc/toolboxcmake.txt',
	'doc/toolboxdoxygen.txt',
	'doc/toolboxmake.txt',
	'ftdetect/template.vim',
	'ftplugin/template.vim',
	'plugin/c.vim',
	'syntax/template.vim',
	'c-support/codesnippets/',
	'c-support/doc/ChangeLog',
	'c-support/doc/c-hotkeys.pdf',
	'c-support/doc/c-hotkeys.tex',
	'c-support/rc/',
	'c-support/scripts/',
	'c-support/templates/',
	'c-support/wordlists/',
	'c-support/README.md',
}

filelists_repo.c = {
	'project/release.lua',
}

------------------------------------------------------------------------
--  Git   {{{1
------------------------------------------------------------------------

filelists.git = {
	'doc/gitsupport.txt',
	'plugin/git-support.vim',
	'git-support/doc/',
	'git-support/rc/',
	'git-support/README.md',
	'syntax/gits*.vim',
}

filelists_repo.git = {
	'git-support/git-doc/',
	'project/release.lua',
}

------------------------------------------------------------------------
--  LaTeX   {{{1
------------------------------------------------------------------------

filelists.latex = {
	'autoload/mmtemplates/',
	'autoload/mmtoolbox/make.vim',
	'autoload/mmtoolbox/tools.vim',
	'doc/latexsupport.txt',
	'doc/templatesupport.txt',
	'doc/toolbox.txt',
	'doc/toolboxmake.txt',
	'ftdetect/template.vim',
	'ftplugin/template.vim',
	'plugin/latex-support.vim',
	'syntax/template.vim',
	'latex-support/codesnippets/',
	'latex-support/doc/ChangeLog',
	'latex-support/doc/latex-hotkeys.pdf',
	'latex-support/doc/latex-hotkeys.tex',
	'latex-support/rc/',
	'latex-support/templates/',
	'latex-support/wordlists/',
	'latex-support/README.md',
}

filelists_repo.latex = {
	'project/release.lua',
}

------------------------------------------------------------------------
--  Lua   {{{1
------------------------------------------------------------------------

filelists.lua = {
	'autoload/mmtemplates/',
	'autoload/mmtoolbox/make.vim',
	'autoload/mmtoolbox/tools.vim',
	'doc/luaref*.txt',
	'doc/luasupport.txt',
	'doc/templatesupport.txt',
	'doc/toolbox.txt',
	'doc/toolboxmake.txt',
	'ftdetect/template.vim',
	'ftplugin/template.vim',
	'plugin/lua-support.vim',
	'syntax/template.vim',
	'lua-support/codesnippets/',
	'lua-support/doc/',
	'lua-support/rc/',
	'lua-support/templates/',
	'lua-support/templates-c-api/',
	'lua-support/README.md',
}

filelists_repo.lua = {
	'lua-support/html2doc/',
	'lua-support/lua-doc/',
	'project/release.lua',
}

------------------------------------------------------------------------
--  Matlab   {{{1
------------------------------------------------------------------------

filelists.matlab = {
	'autoload/mmtemplates/',
	'doc/matlabsupport.txt',
	'doc/templatesupport.txt',
	'ftdetect/template.vim',
	'ftplugin/matlab.vim',
	'ftplugin/template.vim',
	'plugin/matlab-support.vim',
	'syntax/template.vim',
	'matlab-support/codesnippets/',
	'matlab-support/doc/',
	'matlab-support/rc/',
	'matlab-support/templates/',
	'matlab-support/README.md',
}

filelists_repo.matlab = {
	'project/release.lua',
}

------------------------------------------------------------------------
--  Perl   {{{1
------------------------------------------------------------------------

filelists.perl = {
	'autoload/mmtemplates/',
	'autoload/mmtoolbox/make.vim',
	'autoload/mmtoolbox/tools.vim',
	'autoload/perlsupportprofiling.vim',
	'autoload/perlsupportregex.vim',
	'doc/perlsupport.txt',
	'doc/templatesupport.txt',
	'doc/toolbox.txt',
	'doc/toolboxmake.txt',
	'ftdetect/template.vim',
	'ftplugin/template.vim',
	'plugin/perl-support.vim',
	'syntax/template.vim',
	'perl-support/codesnippets/',
	'perl-support/doc/ChangeLog',
	'perl-support/doc/perl-hot-keys.pdf',
	'perl-support/doc/perl-hot-keys.tex',
	'perl-support/doc/pmdesc3.text',
	'perl-support/modules/',
	'perl-support/rc/',
	'perl-support/scripts/',
	'perl-support/templates/',
	'perl-support/wordlists/',
	'perl-support/README.md',
}

filelists_repo.perl = {
	'project/release.lua',
}

------------------------------------------------------------------------
--  VimL   {{{1
------------------------------------------------------------------------

filelists.vim = {
	'autoload/mmtemplates/',
	'doc/templatesupport.txt',
	'doc/vimsupport.txt',
	'ftdetect/template.vim',
	'ftplugin/template.vim',
	'plugin/vim-support.vim',
	'syntax/template.vim',
	'vim-support/codesnippets/',
	'vim-support/doc/ChangeLog',
	'vim-support/doc/vim-hotkeys.pdf',
	'vim-support/doc/vim-hotkeys.tex',
	'vim-support/rc/',
	'vim-support/templates/',
	'vim-support/README.md',
}

filelists_repo.vim = {
	'project/release.lua',
}

------------------------------------------------------------------------
--  TODO   {{{1
------------------------------------------------------------------------

filelists.TODO = {
}

filelists_repo.TODO = {
	'project/release.lua',
}

--  }}}1
------------------------------------------------------------------------


------------------------------------------------------------------------
--  Processing ...
------------------------------------------------------------------------

local plugin_name = args[1] or 'FAILED'
local filelist
local filelist_repo

if #args == 0 then

	print ( '\n=== failed: plug-in missing ===\n' )

	print_help = true

elseif filelists[plugin_name] then

	filelist      = filelists[plugin_name]
	filelist_repo = filelists_repo[plugin_name]

elseif args[1] == 'help' then

	print_help = true

else

	print ( '\n=== failed: unknown plug-in "'..args[1]..'" ===\n' )

	print_help = true

end

local outfile = escape_shell ( plugin_name..'-support.zip' )

for idx, val in ipairs ( filelist or {} ) do
	filelist[ idx ] = escape_shell ( val )
end

if #args == 1 and args[1] ~= 'help' then

	print ( '\n=== failed: mode missing ===\n' )

	print_help = true

elseif args[2] == 'list' then

	local cmd = 'ls -1 '..table.concat ( filelist, ' ' )

	print ( '\n=== listing ===\n' )

	local success, res_reason, res_status = os.execute ( cmd )

	if success then
		print ( '\n=== done ===\n' )
	else
		print ( '\n=== failed: '..res_reason..' '..res_status..' ===\n' )
	end

elseif args[2] == 'check' then

	local flag_dir  = '--directories recurse'
	local flag_excl = '--exclude "*.pdf"'
	local cmd = 'grep '..flag_dir..' '..flag_excl..' -nH ":[[:upper:]]\\+:\\|[Tt][Oo][Dd][Oo]" '..table.concat ( filelist, ' ' )

	print ( '\n=== checking ===\n' )

	local success, res_reason, res_status = os.execute ( cmd )

	if success then
		print ( '\n=== done ===\n' )
	else
		print ( '\n=== failed: '..res_reason..' '..res_status..' ===\n' )
	end

elseif args[2] == 'zip' then

	local cmd = 'zip -r '..outfile..' '..table.concat ( filelist, ' ' )

	print ( '\n=== executing: '..outfile..' ===\n' )

	local success, res_reason, res_status = os.execute ( cmd )

	if success then
		print ( '\n=== successful ===\n' )
	else
		print ( '\n=== failed: '..res_reason..' '..res_status..' ===\n' )
	end

elseif args[2] == 'archive' then

	local cmd = 'git archive --prefix='..plugin_name..'-support/'..' --output='..outfile..' HEAD'

	print ( '\n=== executing: '..outfile..' ===\n' )

	local success, res_reason, res_status = os.execute ( cmd )

	if success then
		print ( '\n=== successful ===\n' )
	else
		print ( '\n=== failed: '..res_reason..' '..res_status..' ===\n' )
	end

elseif args[2] == 'cp-repo' then

	if #args >= 3 then

		local dest_dir = args[3]
		local filelist_compl = {}

		for key, val in pairs ( filelist ) do
			table.insert ( filelist_compl, val )
		end

		for key, val in pairs ( filelist_repo ) do
			table.insert ( filelist_compl, val )
		end

		os.execute ( 'mkdir -p '..dest_dir )
		os.execute ( 'mkdir -p '..dest_dir..'/project' )

		local cmd = 'cp --parents -r '..table.concat ( filelist_compl, ' ' )..' '..dest_dir

		print ( '\n=== copying: '..dest_dir..' ===\n' )

		local success, res_reason, res_status = os.execute ( cmd )

		if success then
			cmd = 'cat '..plugin_name..'-support/README.standalone.md '..plugin_name..'-support/README.md > '..dest_dir..'/README.md'

			success, res_reason, res_status = os.execute ( cmd )
		end

		if success then
			cmd = 'echo "\\ntaken from WolfgangMehner/vim-plugins, revision\\nhttps://github.com/WolfgangMehner/vim-plugins/commit/$(git rev-parse HEAD)" >> '..dest_dir..'/project/commit.txt'

			success, res_reason, res_status = os.execute ( cmd )
		end

		if success then
			print ( '\n=== successful ===\n' )
		else
			print ( '\n=== failed: '..res_reason..' '..res_status..' ===\n' )
		end

	else

		print ( '\n=== failed: no destination given: release.lua cp-repo <dest> ===\n' )

	end

elseif args[2] == 'help' then

	print_help = true

elseif #args >= 2 then

	print ( '\n=== failed: unknown mode "'..args[2]..'" ===\n' )

	print_help = true

end

if print_help then

	print ( '' )
	print ( 'release <plugin> <mode>' )
	print ( '' )
	print ( 'Plug-Ins:' )
	print ( '\tawk' )
	print ( '\tbash' )
	print ( '\tc' )
	print ( '\tgit' )
	print ( '\tlatex' )
	print ( '\tlua' )
	print ( '\tmatlab' )
	print ( '\tperl' )
	print ( '\tvim' )
	print ( '' )
	print ( 'Modes:' )
	print ( '\tlist           - list all files' )
	print ( '\tcheck          - check the release' )
	print ( '\tzip            - create archive via "zip"' )
	print ( '\tarchive        - create archive via "git archive"' )
	print ( '\tcp-repo <dest> - copy the repository' )
	print ( '\thelp           - print help' )
	print ( '' )

end

------------------------------------------------------------------------
-- vim: foldmethod=marker
