--
--------------------------------------------------------------------------------
--         File:  config.lua
--
--        Usage:  ./config.lua
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
--      Created:  04.07.2015
--     Revision:  ---
--------------------------------------------------------------------------------
--

local template_plugin = {
	filename = 'template_plugin.html',
}

template_plugin.order = {
	'head',
	'HTML_HEAD',
	'head_body',
	'TITLE_BAR',
	'PAGE_HEADER_PART1',
	'PAGE_HEADER_OTHERS_PART1',
	'PAGE_HEADER_OTHERS',
	'PAGE_HEADER_OTHERS_PART2',
	'PAGE_HEADER_PART2',
	'MENU_STRUCTURE',
	'FOOTER',
	'body',
}

local config = {}

config.plugin_links = {
	awk   = { id = 4415, name = 'AWK IDE',         }, 
	bash  = { id =  365, name = 'Bash IDE',        }, 
	c     = { id =  213, name = 'C/C++ IDE',       }, 
	git   = { id = 4497, name = 'Git Integration', }, 
	latex = { id = 4405, name = 'LaTeX IDE',       }, 
	lua   = { id = 4950, name = 'Lua IDE',         }, 
	perl  = { id =  556, name = 'Perl IDE',        }, 
	vim   = { id = 3931, name = 'Vim Script IDE',  }, 
}

config.git = {
	input    = 'gitsupport/content.html',
	output   = 'gitsupport.html',
	template = template_plugin,
	fields = {
		TOOL_CAT     = 'Vim Plug-In',
		TOOL_NAME    = 'Git Support',
		TOOL_VERSION = 'AUTO',

		MAINTAINER_NAME = 'Wolfgang Mehner',
		MAINTAINER_MAIL = 'wolfgang-mehner@web.de',

		GITHUB_USER = 'WolfgangMehner',
		GITHUB_REPO = 'git-support',

		IMG_MAIN_MENU = 'gitsupport/git_menu_main.png',
		REF_HELP      = 'doc/gitsupport.html',
	},
	links_plugins = {
		'bash', 'c', 'latex', 'lua', 'perl', 'vim',
	},
	links_others = {
	},
}

config.lua = {
	input    = 'luasupport/content.html',
	output   = 'luasupport.html',
	template = template_plugin,
	fields = {
		TOOL_CAT     = 'Vim Plug-In',
		TOOL_NAME    = 'Lua Support',
		TOOL_VERSION = 'AUTO',

		MAINTAINER_NAME = 'Wolfgang Mehner',
		MAINTAINER_MAIL = 'wolfgang-mehner@web.de',

		GITHUB_USER = 'WolfgangMehner',
		GITHUB_REPO = 'lua-support',

		IMG_MAIN_MENU = 'luasupport/lua_menu_main.png',
		REF_HELP      = 'doc/luasupport.html',
	},
	links_plugins = {
		'bash', 'c', 'git', 'latex', 'perl', 'vim',
	},
	links_others = {
	},
}

return config

