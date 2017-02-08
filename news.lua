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
	New plug-in versions (C/C++ v6.2, Perl v5.4, Bash v4.3, ...) have been release.
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
