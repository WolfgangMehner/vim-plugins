--
--------------------------------------------------------------------------------
--         File:  news.lua
--
--        Usage:  ./news.lua
--
--  Description:  
--
--      Options:  ---
-- Requirements:  ---
--         Bugs:  ---
--        Notes:  ---
--       Author:  Wolfgang Mehner (WM), <wolfgang-mehner@web.de>
-- Organization:  
--      Version:  1.0
--      Created:  14.11.2016
--     Revision:  ---
--------------------------------------------------------------------------------
--

local news = {}

function add ( item )
	for idx, val in ipairs ( item ) do
		val = string.gsub ( val, '\n%s*', ' ' )
		val = string.gsub ( val, '^%s*', '' )
		val = string.gsub ( val, '%s*$', '' )
		item[idx] = val
	end

	item.PAR_FIRST = item[1]
	table.insert ( news, item )
end  -----  end of function add  -----

add {
	bash = true,
	lua = true,

	HEADLINE = 'Run scripts in terminal windows',
	DATE     = 'Jan 2018',
	ID       = 'TERMINALS_JAN2018',
	[[
	The preview versions of Bash-Support and Lua-Support can now run code asynchronously inside the editor, using a terminal window.
	This relies on Vim's new <code>+terminal</code> feature, or Neovim's terminal integration.
	]],
	[[
	Set the output method using:
	<pre>:BashOutputMethod terminal<br>:LuaOutputMethod terminal</pre>
	Then the script will be run inside a terminal window.
	The interpreter can be started the usual way, using the map <code>\rr</code>, the menu entry <code>Bash/Lua -> Run -> run</code>,
	the ex-command <code>:Bash</code>, or <code>:Lua</code>.
	]],
	[[
	Once the script execution finished, the map <code>\qf</code> can be used inside the terminal window to load its contents into quickfix.
	The map <code>\qj</code> loads quickfix and immediately jumps to the first error.
	]],
	[[
	See
	<a target=_blank href="https://github.com/WolfgangMehner/bash-support">WolfgangMehner/bash-support</a> and
	<a target=_blank href="https://github.com/WolfgangMehner/lua-support">WolfgangMehner/lua-support</a>
	for the preview versions which already include this feature.
	Up to now, a new window is opened every time, which will still need to be improved.
	]],
}

add {
	awk = true,
	bash = true,
	c = true,
	lua = true,

	HEADLINE = 'Customizable file skeletons',
	DATE     = 'Jul 2017',
	ID       = 'SKELETONS_JUL2017',
	[[
	The mechanism which inserts file headers into new files was been extended for various plug-ins.
	The default behavior remains the same, but you can now automatically insert more than one templates.
	]],
	[[
	The list of templates to be inserted is defined via so-called <i>properties</i>, directly inside the template library.
	Use the set-up wizard to create a template customization file.
	The wizard is accessible via the menu entry <code>*ROOT MENU* -> Snippets-> template setup wizard</code>.
	]],
	[[
	In the template file, set the corresponding property, <i>e.g.</i>:
	<pre>SetProperty ( 'Bash::FileSkeleton::Script', 'Comments.shebang;Comments.file header; ;Skeleton.script-set' )</pre>
	The property is a semicolon-separated list of templates to be inserted.
	The above example will insert a shebang, a file description comment,
	and the default set commands from the template "Skeleton.script-set".
	If a space appears as an entry in the list, an empty line is inserted ( <code>'...; ;...'</code> ).
	]],
	[[
	You will find short examples in the template customization files delivered with the plug-ins, see <code>*-support/rc/custom.templates</code>.
	Help is available for each property:
	<pre>:help Bash::FileSkeleton::Script</pre>
	For scripting languages, the following are supported:
	<pre>Awk::FileSkeleton::Script Bash::FileSkeleton::Script Lua::FileSkeleton::Script</pre>
	For C-Support, the list of templates can be different for headers and source files, as well as for C and C++ files:
	<pre>C::FileSkeleton::Header Cpp::FileSkeleton::Header C::FileSkeleton::Source Cpp::FileSkeleton::Source</pre>
	]],
	[[
	See
	<a target=_blank href="https://github.com/WolfgangMehner/awk-support">WolfgangMehner/awk-support</a>,
	<a target=_blank href="https://github.com/WolfgangMehner/bash-support">WolfgangMehner/bash-support</a>,
	<a target=_blank href="https://github.com/WolfgangMehner/c-support">WolfgangMehner/c-support</a>, and
	<a target=_blank href="https://github.com/WolfgangMehner/lua-support">WolfgangMehner/lua-support</a>
	for the preview versions which already include this feature.
	]],
}

add {
	lua = true,
	perl = true,

	HEADLINE = 'Lua and Perl Incorporated in SpaceVim',
	DATE     = 'Jan 2017',
	ID       = 'SPACE_VIM_JAN2017',
	[[
	Lua-Support and Perl-Support have been added to <a target=_blank href="https://github.com/SpaceVim/SpaceVim">SpaceVim/SpaceVim</a>.
	Go and have a look!
	]],
}

add {
	latex = true,

	HEADLINE = 'Run the LaTeX Typesetter in the Background',
	DATE     = 'Sep 2016',
	ID       = 'LATEX_BACKGROUND_SEP2016',
	[[
	A new version of LaTeX-Support is in the works.
	It uses the new <code>+job</code> feature of Vim to run external processes in the background.
	]],
	[[
	Call the new ex-command <code>:LatexProcessing background</code> to switch to background processing.
	Now the typesetter is run asynchronously, you can continue to edit the document at the same time.
	In case of errors, a warning message will be displayed after the external process finished.
	Use <code>:LatexErrors</code> to load the error messages into quickfix.
	]],
	[[
	See <a target=_blank href="https://github.com/WolfgangMehner/latex-support">WolfgangMehner/latex-support</a> for the preview version.
	]],
}

add {
	lua = true,

	HEADLINE = 'Read Lua\'s Reference Manuals Inside Vim',
	DATE     = 'Aug 2016',
	ID       = 'LUA_REF_MANUAL_AUG2016',
	[[
	Lua's reference manuals are included in Vim's help format in the new version of the plug-in (Lua-Support v1.0).
	This way the documentation of Lua's standard library is accessible without switching to another application.
	]],
	[[
	With the cursor on the name of a Lua function (or variable) from the standard library,
	hit the map <b>\h3</b> to jump to the corresponding entry in the Lua 5.3 reference manual.
	Likewise, <b>\h1</b> and <b>\h2</b> get you to Lua 5.1 and Lua 5.2, respectively.
	Don't forget to create the helptags first, via <code>:helptags &lt;dir></code>.
	]]
}

add {
	all = true,

	HEADLINE = 'New Plug-in Versions Released',
	DATE     = 'Jul/Aug 2016',
	ID       = 'NEW_PLUGINS_JUL2016',
	[[
	New plug-in versions (C/C++ v6.2, Perl v5.4, Bash v4.3, ...) have been released.
	The updates focus on better configurability of the template library.
	The new releases include improved templates,
	the highlights are much better looking menus for Bash, Perl, and LaTeX.
	The make and CMake tools now include tab-completion for make targets.
	]],
	[[
	The template libraries can now be extended and configured much easier.
	All plug-ins come with a set-up wizard, accessible via the menu entry <code>*ROOT MENU* -> Snippets-> template setup wizard</code>.
	You can use it to create a personalization file which will be loaded by all plug-ins.
	This is a central place to set your name, mail, and your preferred date and time format.
	]],
	[[
	Furthermore, every template library can be extended independently from the stock templates using template customization files.
	They can also be created using the wizard.
	Since they are located outside the plug-in directories, they will not be overwritten by future updates.
	]],
	[[
	The Make Tool now comes with tab-completion for make targets.
	After the Makefile has been set using <code>:MakeFile</code>, you can complete the targets while typing a <code>:Make &lt;target></code> command.
	Similarly, <code>:CMake</code> supports the completion after setting <code>:CMakeBuildLocation &lt;dir></code>.
	Then, you can also use <code>:CMakeCache</code> to display your cached variables.
	Also try <code>:CMakeCurses</code> and <code>:CMakeGui</code>
	]],
}

return news
