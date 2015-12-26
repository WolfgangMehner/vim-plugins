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
	'FEATURES',
	'MENU_STRUCTURE',
	'FOOTER',
	'body',
}

local template_index = {
	filename = 'template_index.html',
}

template_index.order = {
	'head',
	'HTML_HEAD',
	'head_body',
	'TITLE_BAR',
	'FEATURES',
	'PLUGIN_LIST',
	'TOOLBOX_LIST',
	'FOOTER',
	'FOOTNOTE',
	'body',
}

local config = {}

config.plugin_links = {
	awk   = { id = 4415, name = 'AWK IDE',         doc = '',                    },
	bash  = { id =  365, name = 'Bash IDE',        doc = '',                    },
	c     = { id =  213, name = 'C/C++ IDE',       doc = '',                    },
	git   = { id = 4497, name = 'Git Integration', doc = 'doc/gitsupport.html', },
	latex = { id = 4405, name = 'LaTeX IDE',       doc = '',                    },
	lua   = { id = 4950, name = 'Lua IDE',         doc = 'doc/luasupport.html', },
	perl  = { id =  556, name = 'Perl IDE',        doc = '',                    },
	vim   = { id = 3931, name = 'Vim Script IDE',  doc = '',                    },
}

config.index = {
	input    = 'template_index.html',
	output   = 'index.html',
	template = template_index,
	fields = {
		MAINTAINER_NAME = 'Wolfgang Mehner',
		MAINTAINER_MAIL = 'wolfgang-mehner@web.de',
	},
	links_plugins = {
	},
	links_others = {
	},
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

		IMG_MAIN_FILE    = 'gitsupport/git_menu_main.png',
		IMG_MAIN_CAPTION = 'root menu',

		REF_README = 'blob/master/README.md',
		REF_HELP   = config.plugin_links.git.doc,
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

		IMG_MAIN_FILE    = 'luasupport/lua_menu_main.png',
		IMG_MAIN_CAPTION = 'root menu',

		REF_README = 'blob/master/README.md',
		REF_HELP   = config.plugin_links.lua.doc,
	},
	links_plugins = {
		'bash', 'c', 'git', 'latex', 'perl', 'vim',
	},
	links_others = {
	},
}

return config

