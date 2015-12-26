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
	'PAGE_HEADER_MAPPINGS',
	'PAGE_HEADER_PART2',
	'PAGE_HEADER_OTHERS_PART1',
	'PAGE_HEADER_OTHERS',
	'PAGE_HEADER_OTHERS_PART2',
	'PAGE_HEADER_PART3',
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
	awk   = { id = 4415, name = 'AWK IDE',         page = 'awksupport.html',   doc = 'doc/awksupport.html',   },
	bash  = { id =  365, name = 'Bash IDE',        page = 'bashsupport.html',  doc = 'doc/bashsupport.html',  maps = 'bashsupport/bash-hotkeys.pdf',  },
	c     = { id =  213, name = 'C/C++ IDE',       page = 'csupport.html',     doc = 'doc/csupport.html',     maps = 'csupport/c-hotkeys.pdf',        },
	git   = { id = 4497, name = 'Git Integration', page = 'gitsupport.html',   doc = 'doc/gitsupport.html',   },
	latex = { id = 4405, name = 'LaTeX IDE',       page = 'latexsupport.html', doc = 'doc/latexsupport.html', },
	lua   = { id = 4950, name = 'Lua IDE',         page = 'luasupport.html',   doc = 'doc/luasupport.html',   },
	perl  = { id =  556, name = 'Perl IDE',        page = 'perlsupport.html',  doc = 'doc/perlsupport.html',  maps = 'perlsupport/perl-hot-keys.pdf', },
	vim   = { id = 3931, name = 'Vim Script IDE',  page = 'vimsupport.html',   doc = 'doc/vimsupport.html',   },
}

config.project_links = {
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

config.awk = {
	input    = 'awksupport/content.html',
	output   = 'awksupport.html',
	template = template_plugin,
	fields = {
		TOOL_CAT     = 'Vim Plug-In',
		TOOL_NAME    = 'AWK Support',
		TOOL_VERSION = 'AUTO',

		MAINTAINER_NAME = 'Wolfgang Mehner',
		MAINTAINER_MAIL = 'wolfgang-mehner@web.de',

		GITHUB_USER = 'WolfgangMehner',
		GITHUB_REPO = 'vim-plugins',

		IMG_MAIN_FILE    = 'awksupport/main.png',
		IMG_MAIN_CAPTION = 'root menu',

		REF_README = 'blob/master/awk-support/README.awksupport',
		REF_HELP   = config.plugin_links.awk.doc,
	},
	links_plugins = {
		'bash', 'c', 'latex', 'lua', 'perl', 'vim',
	},
	links_others = {
	},
}

config.bash = {
	input    = 'bashsupport/content.html',
	output   = 'bashsupport.html',
	template = template_plugin,
	fields = {
		TOOL_CAT     = 'Vim Plug-In',
		TOOL_NAME    = 'Bash Support',
		TOOL_VERSION = 'AUTO',

		MAINTAINER_NAME = 'Wolfgang Mehner',
		MAINTAINER_MAIL = 'wolfgang-mehner@web.de',

		GITHUB_USER = 'WolfgangMehner',
		GITHUB_REPO = 'vim-plugins',

		IMG_MAIN_FILE    = 'bashsupport/root-menu.png',
		IMG_MAIN_CAPTION = 'root menu',

		REF_README = 'blob/master/bash-support/README.bashsupport',
		REF_HELP   = config.plugin_links.bash.doc,
		REF_MAPS   = config.plugin_links.bash.maps,
	},
	links_plugins = {
		'awk', 'c', 'latex', 'lua', 'perl', 'vim',
	},
	links_others = {
		{ name = 'Bash Style Guide (en)', link = 'https://lug.fh-swf.de/vim/vim-bash/StyleGuideShell.en.pdf' },
		{ name = 'Bash Style Guide (de)', link = 'https://lug.fh-swf.de/vim/vim-bash/StyleGuideShell.de.pdf' },
	},
}

config.c = {
	input    = 'csupport/content.html',
	output   = 'csupport.html',
	template = template_plugin,
	fields = {
		TOOL_CAT     = 'Vim Plug-In',
		TOOL_NAME    = 'C/C++ Support',
		TOOL_VERSION = 'AUTO',

		MAINTAINER_NAME = 'Wolfgang Mehner',
		MAINTAINER_MAIL = 'wolfgang-mehner@web.de',

		GITHUB_USER = 'WolfgangMehner',
		GITHUB_REPO = 'vim-plugins',

		IMG_MAIN_FILE    = 'csupport/root.png',
		IMG_MAIN_CAPTION = 'root menu',

		REF_README = 'blob/master/c-support/README.csupport',
		REF_HELP   = config.plugin_links.c.doc,
		REF_MAPS   = config.plugin_links.c.maps,
	},
	links_plugins = {
		'bash', 'git', 'latex', 'lua', 'perl', 'vim',
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

config.latex = {
	input    = 'latexsupport/content.html',
	output   = 'latexsupport.html',
	template = template_plugin,
	fields = {
		TOOL_CAT     = 'Vim Plug-In',
		TOOL_NAME    = 'LaTeX Support',
		TOOL_VERSION = 'AUTO',

		MAINTAINER_NAME = 'Wolfgang Mehner',
		MAINTAINER_MAIL = 'wolfgang-mehner@web.de',

		GITHUB_USER = 'WolfgangMehner',
		GITHUB_REPO = 'vim-plugins',

		IMG_MAIN_FILE    = 'latexsupport/root.png',
		IMG_MAIN_CAPTION = 'root menu',

		REF_README = 'blob/master/latex-support/README.latexsupport',
		REF_HELP   = config.plugin_links.latex.doc,
	},
	links_plugins = {
		'awk', 'bash', 'c', 'git', 'perl', 'lua',
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

config.perl = {
	input    = 'perlsupport/content.html',
	output   = 'perlsupport.html',
	template = template_plugin,
	fields = {
		TOOL_CAT     = 'Vim Plug-In',
		TOOL_NAME    = 'Perl Support',
		TOOL_VERSION = 'AUTO',

		MAINTAINER_NAME = 'Wolfgang Mehner',
		MAINTAINER_MAIL = 'wolfgang-mehner@web.de',

		GITHUB_USER = 'WolfgangMehner',
		GITHUB_REPO = 'perl-support',

		IMG_MAIN_FILE    = 'perlsupport/main.png',
		IMG_MAIN_CAPTION = 'root menu',

		REF_README = 'blob/master/README.md',
		REF_HELP   = config.plugin_links.perl.doc,
		REF_MAPS   = config.plugin_links.perl.maps,
	},
	links_plugins = {
		'awk', 'bash', 'c', 'git', 'latex', 'lua',
	},
	links_others = {
	},
}

config.vim = {
	input    = 'vimsupport/content.html',
	output   = 'vimsupport.html',
	template = template_plugin,
	fields = {
		TOOL_CAT     = 'Vim Plug-In',
		TOOL_NAME    = 'Vim Support',
		TOOL_VERSION = 'AUTO',

		MAINTAINER_NAME = 'Wolfgang Mehner',
		MAINTAINER_MAIL = 'wolfgang-mehner@web.de',

		GITHUB_USER = 'WolfgangMehner',
		GITHUB_REPO = 'vim-plugins',

		IMG_MAIN_FILE    = 'vimsupport/main.png',
		IMG_MAIN_CAPTION = 'root menu',

		REF_README = 'blob/master/vim-support/README.vimsupport',
		REF_HELP   = config.plugin_links.vim.doc,
	},
	links_plugins = {
		'awk', 'bash', 'c', 'git', 'latex', 'lua',
	},
	links_others = {
	},
}

return config
