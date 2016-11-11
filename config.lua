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
	'PAGE_HEADER_LINKS_PART1',
	'PAGE_HEADER_PLUGIN',
	'PAGE_HEADER_OTHERS',
	'PAGE_HEADER_LINKS_PART2',
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

local link_awk   = { ID = 4415, NAME = 'AWK IDE',         PAGE = 'awksupport.html',   DOC = 'doc/awksupport.html',   MAPS = 'awksupport/awk-hotkeys.pdf',     }
local link_bash  = { ID =  365, NAME = 'Bash IDE',        PAGE = 'bashsupport.html',  DOC = 'doc/bashsupport.html',  MAPS = 'bashsupport/bash-hotkeys.pdf',   }
local link_c     = { ID =  213, NAME = 'C/C++ IDE',       PAGE = 'csupport.html',     DOC = 'doc/csupport.html',     MAPS = 'csupport/c-hotkeys.pdf',         }
local link_git   = { ID = 4497, NAME = 'Git Integration', PAGE = 'gitsupport.html',   DOC = 'doc/gitsupport.html',   }
local link_latex = { ID = 4405, NAME = 'LaTeX IDE',       PAGE = 'latexsupport.html', DOC = 'doc/latexsupport.html', MAPS = 'latexsupport/latex-hotkeys.pdf', }
local link_lua   = { ID = 4950, NAME = 'Lua IDE',         PAGE = 'luasupport.html',   DOC = 'doc/luasupport.html',   }
local link_perl  = { ID =  556, NAME = 'Perl IDE',        PAGE = 'perlsupport.html',  DOC = 'doc/perlsupport.html',  MAPS = 'perlsupport/perl-hot-keys.pdf',  }
local link_vim   = { ID = 3931, NAME = 'Vim Script IDE',  PAGE = 'vimsupport.html',   DOC = 'doc/vimsupport.html',   MAPS = 'vimsupport/vim-hotkeys.pdf',     }

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
		VIMORG_ID    = link_awk.ID,

		MAINTAINER_NAME = 'Wolfgang Mehner',
		MAINTAINER_MAIL = 'wolfgang-mehner@web.de',

		GITHUB_USER = 'WolfgangMehner',
		GITHUB_REPO = 'awk-support',

		IMG_MAIN_FILE    = 'awksupport/menu_main.png',
		IMG_MAIN_CAPTION = 'root menu',

		REF_README = 'blob/master/README.md',
		REF_HELP   = link_awk.DOC,

		PAGE_HEADER_MAPPINGS = { { REF_MAPS = link_awk.MAPS, } },
		PAGE_HEADER_PLUGIN = {
			link_bash, link_c, link_latex, link_lua, link_perl, link_vim,
		},
		PAGE_HEADER_OTHERS = {
		},
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
		VIMORG_ID    = link_bash.ID,

		MAINTAINER_NAME = 'Wolfgang Mehner',
		MAINTAINER_MAIL = 'wolfgang-mehner@web.de',

		GITHUB_USER = 'WolfgangMehner',
		GITHUB_REPO = 'bash-support',

		IMG_MAIN_FILE    = 'bashsupport/menu_main.png',
		IMG_MAIN_CAPTION = 'root menu',

		REF_README = 'blob/master/README.md',
		REF_HELP   = link_bash.DOC,

		PAGE_HEADER_MAPPINGS = { { REF_MAPS = link_bash.MAPS, } },
		PAGE_HEADER_MEDIA = {
			{ PARAGRAPH = [[Plugin featured in the <a target=_blank href="http://hackerpublicradio.org">Hacker Public Radio</a> episode <a target=_blank href="http://hackerpublicradio.org/eps.php?id=1091">Useful Vim Plugins</a>]], },
			{ PARAGRAPH = [[The installation explained: <a target=_blank href="http://www.thegeekstuff.com">The Geek Stuff</a> article<br>
			<a target=_blank href="http://www.thegeekstuff.com/2009/02/make-vim-as-your-bash-ide-using-bash-support-plugin/">Make Vim as Your Bash-IDE Using bash-support Plugin</a>]], },
			{ PARAGRAPH = [[Plugin featured in the <a target=_blank href="http://www.linux.com">Linux.com</a> article <a target=_blank href="http://www.linux.com/articles/114359">Turn Vim into a bash IDE</a>]], },
			{ PARAGRAPH = [[Covered in the Oct./Nov. 2007 issue of <a target=_blank href="http://www.cul.de/freex.html">freeX</a>, "Vim als Bash-IDE" (German)]], },
		},
		PAGE_HEADER_PLUGIN = {
			link_awk, link_c, link_latex, link_lua, link_perl, link_vim,
		},
		PAGE_HEADER_OTHERS = {
			{ NAME = 'Bash Style Guide<br>(English)', LINK = 'https://lug.fh-swf.de/vim/vim-bash/StyleGuideShell.en.pdf' },
			{ NAME = 'Bash Style Guide<br>(German)',  LINK = 'https://lug.fh-swf.de/vim/vim-bash/StyleGuideShell.de.pdf' },
			{ NAME = 'Bash Bookmarks',                LINK = 'https://github.com/FritzMehner/Bash-Bookmarks' },
			{ NAME = 'Bash Parallel<br>Processing',   LINK = 'https://github.com/FritzMehner/Bash-Runpar' },
		},
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
		VIMORG_ID    = link_c.ID,

		MAINTAINER_NAME = 'Wolfgang Mehner',
		MAINTAINER_MAIL = 'wolfgang-mehner@web.de',

		GITHUB_USER = 'WolfgangMehner',
		GITHUB_REPO = 'c-support',

		IMG_MAIN_FILE    = 'csupport/menu_main.png',
		IMG_MAIN_CAPTION = 'root menu',

		REF_README = 'blob/master/README.md',
		REF_HELP   = link_c.DOC,

		PAGE_HEADER_MAPPINGS = { { REF_MAPS = link_c.MAPS, } },
		PAGE_HEADER_MEDIA = {
			{ PARAGRAPH = [[Plugin featured in the <a target=_blank href="http://www.thegeekstuff.com">The Geek Stuff</a> tutorial<br>
			<a target=_blank href="http://www.thegeekstuff.com/2009/01/tutorial-make-vim-as-your-cc-ide-using-cvim-plugin/">Make Vim as Your C/C++ IDE Using c.vim Plugin</a>]], },
		},
		PAGE_HEADER_PLUGIN = {
			link_bash, link_git, link_latex, link_lua, link_perl, link_vim,
		},
		PAGE_HEADER_OTHERS = {
		},
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
		VIMORG_ID    = link_git.ID,

		MAINTAINER_NAME = 'Wolfgang Mehner',
		MAINTAINER_MAIL = 'wolfgang-mehner@web.de',

		GITHUB_USER = 'WolfgangMehner',
		GITHUB_REPO = 'git-support',

		IMG_MAIN_FILE    = 'gitsupport/git_menu_main.png',
		IMG_MAIN_CAPTION = 'root menu',

		REF_README = 'blob/master/README.md',
		REF_HELP   = link_git.DOC,

		PAGE_HEADER_PLUGIN = {
			link_bash, link_c, link_latex, link_lua, link_perl, link_vim,
		},
		PAGE_HEADER_OTHERS = {
		},
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
		VIMORG_ID    = link_latex.ID,

		MAINTAINER_NAME = 'Wolfgang Mehner',
		MAINTAINER_MAIL = 'wolfgang-mehner@web.de',

		GITHUB_USER = 'WolfgangMehner',
		GITHUB_REPO = 'latex-support',

		IMG_MAIN_FILE    = 'latexsupport/menu_main.png',
		IMG_MAIN_CAPTION = 'root menu',

		REF_README = 'blob/master/README.md',
		REF_HELP   = link_latex.DOC,

		PAGE_HEADER_MAPPINGS = { { REF_MAPS = link_latex.MAPS, } },
		PAGE_HEADER_PLUGIN = {
			link_awk, link_bash, link_c, link_git, link_perl, link_lua,
		},
		PAGE_HEADER_OTHERS = {
		},
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
		VIMORG_ID    = link_lua.ID,

		MAINTAINER_NAME = 'Wolfgang Mehner',
		MAINTAINER_MAIL = 'wolfgang-mehner@web.de',

		GITHUB_USER = 'WolfgangMehner',
		GITHUB_REPO = 'lua-support',

		IMG_MAIN_FILE    = 'luasupport/lua_menu_main.png',
		IMG_MAIN_CAPTION = 'root menu',

		REF_README = 'blob/master/README.md',
		REF_HELP   = link_lua.DOC,

		PAGE_HEADER_PLUGIN = {
			link_bash, link_c, link_git, link_latex, link_perl, link_vim,
		},
		PAGE_HEADER_OTHERS = {
		},
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
		VIMORG_ID    = link_perl.ID,

		MAINTAINER_NAME = 'Wolfgang Mehner',
		MAINTAINER_MAIL = 'wolfgang-mehner@web.de',

		GITHUB_USER = 'WolfgangMehner',
		GITHUB_REPO = 'perl-support',

		IMG_MAIN_FILE    = 'perlsupport/menu_main.png',
		IMG_MAIN_CAPTION = 'root menu',

		REF_README = 'blob/master/README.md',
		REF_HELP   = link_perl.DOC,

		PAGE_HEADER_MAPPINGS = { { REF_MAPS = link_perl.MAPS, } },
		PAGE_HEADER_MEDIA = {
			{ PARAGRAPH = [[Covered in the 01/2016 issue of <a target=_blank href="http://www.linux-magazin.de/">Linux-Magazin</a>,<br>
			<a target=_blank href="http://www.linux-magazin.de/Ausgaben/2016/01/Bitparade">Entwicklungsumgebungen für Perl</a> (in German)]], },
			{ PARAGRAPH = [[Plugin featured in the <a target=_blank href="http://hackerpublicradio.org">Hacker Public Radio</a> episode <a target=_blank href="http://hackerpublicradio.org/eps.php?id=1091">Useful Vim Plugins</a>]], },
			{ PARAGRAPH = [[Plugin presented at the <a target=_blank href="http://www.perl-workshop.de/de/2009/index.html">11. Deutscher Perl-Workshop</a> in Frankfurt, 2009<br>
			and mentioned on <a target=_blank href="http://www.heise.de/developer/artikel/11-Deutscher-Perl-Workshop-in-Frankfurt-849271.html">heise online</a>]], },
			{ PARAGRAPH = [[Plugin featured in the <a target=_blank href="http://www.thegeekstuff.com">The Geek Stuff</a> article<br>
			<a target=_blank href="http://www.thegeekstuff.com/2009/01/make-vim-as-your-perl-ide-using-perl-supportvim-plugin/">Make Vim as Your Perl IDE Using perl-support.vim Plugin</a>]], },
		},
		PAGE_HEADER_PLUGIN = {
			link_awk, link_bash, link_c, link_git, link_latex, link_lua,
		},
		PAGE_HEADER_OTHERS = {
			{ NAME = 'Perl Gnuplot<br>Interface', LINK = 'http://search.cpan.org/~mehner/Graphics-GnuplotIF-1.8/' },
		},
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
		VIMORG_ID    = link_vim.ID,

		MAINTAINER_NAME = 'Wolfgang Mehner',
		MAINTAINER_MAIL = 'wolfgang-mehner@web.de',

		GITHUB_USER = 'WolfgangMehner',
		GITHUB_REPO = 'vim-support',

		IMG_MAIN_FILE    = 'vimsupport/menu_main.png',
		IMG_MAIN_CAPTION = 'root menu',

		REF_README = 'blob/master/README.md',
		REF_HELP   = link_vim.DOC,

		PAGE_HEADER_MAPPINGS = { { REF_MAPS = link_vim.MAPS, } },
		PAGE_HEADER_PLUGIN = {
			link_awk, link_bash, link_c, link_git, link_latex, link_lua,
		},
		PAGE_HEADER_OTHERS = {
		},
	},
}

return config

