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
	'PAGE_HEADER_MEDIA',
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
	awk   = { id = 4415, name = 'AWK IDE',         page = 'awksupport.html',   doc = 'doc/awksupport.html',   maps = 'awksupport/awk-hotkeys.pdf',     },
	bash  = { id =  365, name = 'Bash IDE',        page = 'bashsupport.html',  doc = 'doc/bashsupport.html',  maps = 'bashsupport/bash-hotkeys.pdf',   },
	c     = { id =  213, name = 'C/C++ IDE',       page = 'csupport.html',     doc = 'doc/csupport.html',     maps = 'csupport/c-hotkeys.pdf',         },
	git   = { id = 4497, name = 'Git Integration', page = 'gitsupport.html',   doc = 'doc/gitsupport.html',   },
	latex = { id = 4405, name = 'LaTeX IDE',       page = 'latexsupport.html', doc = 'doc/latexsupport.html', maps = 'latexsupport/latex-hotkeys.pdf', },
	lua   = { id = 4950, name = 'Lua IDE',         page = 'luasupport.html',   doc = 'doc/luasupport.html',   },
	perl  = { id =  556, name = 'Perl IDE',        page = 'perlsupport.html',  doc = 'doc/perlsupport.html',  maps = 'perlsupport/perl-hot-keys.pdf',  },
	vim   = { id = 3931, name = 'Vim Script IDE',  page = 'vimsupport.html',   doc = 'doc/vimsupport.html',   maps = 'vimsupport/vim-hotkeys.pdf',     },
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

		IMG_MAIN_FILE    = 'awksupport/menu_main.png',
		IMG_MAIN_CAPTION = 'root menu',

		REF_README = 'blob/master/awk-support/README.md',
		REF_HELP   = config.plugin_links.awk.doc,
		REF_MAPS   = config.plugin_links.awk.maps,
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

		IMG_MAIN_FILE    = 'bashsupport/menu_main.png',
		IMG_MAIN_CAPTION = 'root menu',

		REF_README = 'blob/master/bash-support/README.md',
		REF_HELP   = config.plugin_links.bash.doc,
		REF_MAPS   = config.plugin_links.bash.maps,
	},
	links_plugins = {
		'awk', 'c', 'latex', 'lua', 'perl', 'vim',
	},
	links_others = {
		{ name = 'Bash Style Guide<br>(English)', link = 'https://lug.fh-swf.de/vim/vim-bash/StyleGuideShell.en.pdf' },
		{ name = 'Bash Style Guide<br>(German)',  link = 'https://lug.fh-swf.de/vim/vim-bash/StyleGuideShell.de.pdf' },
		{ name = 'Bash Bookmarks',                link = 'https://github.com/FritzMehner/Bash-Bookmarks' },
		{ name = 'Bash Parallel<br>Processing',   link = 'https://github.com/FritzMehner/Bash-Runpar' },
	},
	links_media = {
		[[Plugin featured in the <a target=_blank href="http://hackerpublicradio.org">Hacker Public Radio</a> episode <a target=_blank href="http://hackerpublicradio.org/eps.php?id=1091">Useful Vim Plugins</a>]],
		[[The installation explained: <a target=_blank href="http://www.thegeekstuff.com">The Geek Stuff</a> article<br>
		<a target=_blank href="http://www.thegeekstuff.com/2009/02/make-vim-as-your-bash-ide-using-bash-support-plugin/">Make Vim as Your Bash-IDE Using bash-support Plugin</a>]],
		[[Plugin featured in the <a target=_blank href="http://www.linux.com">Linux.com</a> article <a target=_blank href="http://www.linux.com/articles/114359">Turn Vim into a bash IDE</a>]],
		[[Covered in the Oct./Nov. 2007 issue of <a target=_blank href="http://www.cul.de/freex.html">freeX</a>, "Vim als Bash-IDE" (German)]],
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

		IMG_MAIN_FILE    = 'csupport/menu_main.png',
		IMG_MAIN_CAPTION = 'root menu',

		REF_README = 'blob/master/c-support/README.md',
		REF_HELP   = config.plugin_links.c.doc,
		REF_MAPS   = config.plugin_links.c.maps,
	},
	links_plugins = {
		'bash', 'git', 'latex', 'lua', 'perl', 'vim',
	},
	links_others = {
	},
	links_media = {
		[[Plugin featured in the <a target=_blank href="http://www.thegeekstuff.com">The Geek Stuff</a> tutorial<br>
		<a target=_blank href="http://www.thegeekstuff.com/2009/01/tutorial-make-vim-as-your-cc-ide-using-cvim-plugin/">Make Vim as Your C/C++ IDE Using c.vim Plugin</a>]],
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
		GITHUB_REPO = 'latex-support',

		IMG_MAIN_FILE    = 'latexsupport/menu_main.png',
		IMG_MAIN_CAPTION = 'root menu',

		REF_README = 'blob/master/README.md',
		REF_HELP   = config.plugin_links.latex.doc,
		REF_MAPS   = config.plugin_links.latex.maps,
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

		IMG_MAIN_FILE    = 'perlsupport/menu_main.png',
		IMG_MAIN_CAPTION = 'root menu',

		REF_README = 'blob/master/README.md',
		REF_HELP   = config.plugin_links.perl.doc,
		REF_MAPS   = config.plugin_links.perl.maps,
	},
	links_plugins = {
		'awk', 'bash', 'c', 'git', 'latex', 'lua',
	},
	links_others = {
		{ name = 'Perl Gnuplot<br>Interface', link = 'http://search.cpan.org/~mehner/Graphics-GnuplotIF-1.8/' },
	},
	links_media = {
		[[Covered in the 01/2016 issue of <a target=_blank href="http://www.linux-magazin.de/">Linux-Magazin</a>,<br>
		<a target=_blank href="http://www.linux-magazin.de/Ausgaben/2016/01/Bitparade">Entwicklungsumgebungen für Perl</a> (in German)]],
		[[Plugin featured in the <a target=_blank href="http://hackerpublicradio.org">Hacker Public Radio</a> episode <a target=_blank href="http://hackerpublicradio.org/eps.php?id=1091">Useful Vim Plugins</a>]],
		[[Plugin presented at the <a target=_blank href="http://www.perl-workshop.de/de/2009/index.html">11. Deutscher Perl-Workshop</a> in Frankfurt, 2009<br>
		and mentioned on <a target=_blank href="http://www.heise.de/developer/artikel/11-Deutscher-Perl-Workshop-in-Frankfurt-849271.html">heise online</a>]],
		[[Plugin featured in the <a target=_blank href="http://www.thegeekstuff.com">The Geek Stuff</a> article<br>
		<a target=_blank href="http://www.thegeekstuff.com/2009/01/make-vim-as-your-perl-ide-using-perl-supportvim-plugin/">Make Vim as Your Perl IDE Using perl-support.vim Plugin</a>]],
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
		GITHUB_REPO = 'vim-support',

		IMG_MAIN_FILE    = 'vimsupport/menu_main.png',
		IMG_MAIN_CAPTION = 'root menu',

		REF_README = 'blob/master/README.md',
		REF_HELP   = config.plugin_links.vim.doc,
		REF_MAPS   = config.plugin_links.vim.maps,
	},
	links_plugins = {
		'awk', 'bash', 'c', 'git', 'latex', 'lua',
	},
	links_others = {
	},
}

return config

