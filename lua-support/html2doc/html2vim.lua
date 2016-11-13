--
--------------------------------------------------------------------------------
--         File:  html2vim.lua
--
--        Usage:  ./html2vim.lua
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
--      Created:  12.01.2015
--     Revision:  ---
--------------------------------------------------------------------------------
--

os.setlocale ( 'C' )

------------------------------------------------------------------------
--  settings for Lua 5.1.5
------------------------------------------------------------------------

--local lua_major           = 5
--local lua_minor           = 1
--local lua_release         = 5
--local lua_date            = 'Feb 13 2012'
--local lua_copyright       = '2006 - 2012'
--local doc_filename        = os.getenv ( 'HOME' ) .. '/Programme/VimPlugins/doc/luaref51.txt'
--local link_main_component = 'lua51'
--local html_filename       = '/home/wolfgang/Software/lua-5.1.5/doc/manual.html'

------------------------------------------------------------------------
--  settings for Lua 5.2.4
------------------------------------------------------------------------

--local lua_major           = 5
--local lua_minor           = 2
--local lua_release         = 4
--local lua_date            = 'Feb 23 2015'
--local lua_copyright       = '2011 - 2015'
--local doc_filename        = os.getenv ( 'HOME' ) .. '/Programme/VimPlugins/doc/luaref52.txt'
--local link_main_component = 'lua52'
--local html_filename       = '/home/wolfgang/Software/lua-5.2.4/doc/manual.html'

------------------------------------------------------------------------
--  settings for Lua 5.3.3
------------------------------------------------------------------------

local lua_major           = 5
local lua_minor           = 3
local lua_release         = 3
local lua_date            = 'May 30 2016'
local lua_copyright       = '2015 - 2016'
local doc_filename        = os.getenv ( 'HOME' ) .. '/Programme/VimPlugins/doc/luaref53.txt'
local link_main_component = 'lua53'
local html_filename       = '/home/wolfgang/Software/lua-5.3.3/doc/manual.html'

------------------------------------------------------------------------
--  links to all versions (since Lua 5.3.1)
------------------------------------------------------------------------

local lua_all_version_links = '|lua51| |lua52| |lua53|'

------------------------------------------------------------------------

-- all the html tags we handle
local handle_single = {}
local handle_double = {}

-- :TODO:18.01.2015 20:34:19:WM: find unicode for some tags
-- :TODO:18.01.2015 20:34:19:WM: find unicode for pi
local html_text_code_replace_data = {
	[ '#124' ] = '|',

	acute  = '´',
	amp    = '&',
	copy   = '©',
	gt     = '>',
	lsquo  = "'",
	le     = '<=',
	lt     = '<',
	nbsp   = ' ',
	ndash  = '-',
	middot = '.',
	pi     = 'pi',
	rsquo  = "'",
	sect   = '§',
}

-- basic settings
local textwidth = 78

-- templates for generated text
local templates = {
	rule_single = string.rep ( '-', textwidth ),
	rule_double = string.rep ( '=', textwidth ),

	toc_sec_1 = '%d.',
	toc_sec_2 = '%d.%d',
	toc_sec_3 = '%d.%d.%d',
	toc_1 = '%-6s%-51s%s',
	toc_2 = '%-7s%-50s%s',
	toc_3 = '%-8s%-49s%s',
	header_1 = '%d.  %s',
	header_2 = '%d.%d  %s',
	header_3 = '%d.%d.%d  %s',
	anchor_1 = '*'..link_main_component..'-sec%d*',
	anchor_2 = '*'..link_main_component..'-sec%d.%d*',
	anchor_3 = '*'..link_main_component..'-sec%d.%d.%d*',
	link_1 = '|'..link_main_component..'-sec%d|',
	link_2 = '|'..link_main_component..'-sec%d.%d|',
	link_3 = '|'..link_main_component..'-sec%d.%d.%d|',

	anchor_c_api = '*'..link_main_component..'-%s*',
	link_c_api   = '|'..link_main_component..'-%s|',
	anchor_pdf   = '*'..link_main_component..'-%s*',
	link_pdf     = '|'..link_main_component..'-%s|',
} 

local TOP_ANCHOR = {}                 -- unique key, used to pass information around

------------------------------------------------------------------------
--  paragraphs -- assemble a paragraph   {{{1
------------------------------------------------------------------------

------------------------------------------------------------------------
--  t_rightalign   {{{2
------------------------------------------------------------------------

function t_rightalign ( data, t_rigth )

	local padding = data.opt.textwidth - #t_rigth
	return string.rep ( ' ', padding ) .. t_rigth

end  -----  end of function t_rightalign  -----

------------------------------------------------------------------------
--  t_leftrightalign   {{{2
------------------------------------------------------------------------

function t_leftrightalign ( data, t_left, t_rigth )

	local padding = data.opt.textwidth - #t_left - #t_rigth
	return t_left .. string.rep ( ' ', padding ) .. t_rigth

end  -----  end of function t_leftrightalign  -----

------------------------------------------------------------------------
--  t_add   {{{2
------------------------------------------------------------------------

local function t_add ( data, text, opt )

	opt = opt or {}

	if data.p_collect then
		error ( 'inside a paragraph' )
	end

	if type ( text ) == 'table' then
		text = table.concat ( text, ' ' )
	end

	if string.match ( text, '^%s*$' ) then
		if opt.newline then
			table.insert ( data.text, '' )
		end
		return
	end

	text = string.match ( text, '^%s*(.-)%s*$' )

	if opt.rightalign then
		text = t_rightalign ( data, text )
	end

	table.insert ( data.text, text )

	if opt.newline then
		table.insert ( data.text, '' )
	end
end  -----  end of function t_add  -----

------------------------------------------------------------------------
--  t_set_anchor   {{{2
------------------------------------------------------------------------

local ANCHOR_DATA = nil
local ANCHOR_POS  = {}

local function t_set_anchor ( data )

	ANCHOR_DATA = data
	data[ANCHOR_POS] = #data.text + 1

end  -----  end of function t_set_anchor  -----

------------------------------------------------------------------------
--  t_add_anchor   {{{2
------------------------------------------------------------------------

local function t_add_anchor ( anchor )

	local data = ANCHOR_DATA
	local pos  = data[ANCHOR_POS]

	text = t_rightalign ( data, anchor )

	table.insert ( data.text, pos, text )

	data[ANCHOR_POS] = pos + 1
end  -----  end of function t_add_anchor  -----

------------------------------------------------------------------------
--  t_assemble   {{{2
------------------------------------------------------------------------

local function t_assemble ( data, sep )
	
	local idx_1, idx_N = 1, #data.text

	if idx_N == 0 then
		return ''
	end

	while sep == ' ' and data.text[idx_N] == '' do
		idx_N = idx_N - 1
	end

	return table.concat ( data.text, sep, idx_1, idx_N )

end  -----  end of function t_assemble  -----

------------------------------------------------------------------------
--  p_add   {{{2
------------------------------------------------------------------------

local function p_add ( data, text )

	if not data.p_collect then
		error ( 'not inside a paragraph' )
	end

	if string.match ( text, '^%s*$' ) then
		return
	end

	text = string.gsub ( text, '%s+$', ' ' )

	data.p_accu.text = data.p_accu.text .. text

end  -----  end of function p_add  -----

------------------------------------------------------------------------
--  p_wrapup   {{{2
------------------------------------------------------------------------

function html_text_code_replace ( code )

	if not html_text_code_replace_data [ code ] then
		print ( string.format ( '!!! can not replace code &%s;', code ) )
		return 'TODO'
	end

	return html_text_code_replace_data [ code ]

end  -----  end of function html_text_code_replace  -----


local function p_wrapup ( data, transform )

	if not data.p_collect then
		return
	end

	data.p_collect = false

	local text = data.p_accu.text

	if string.match ( text, '^%s*$' ) then
		--print ( string.format ( '--- skipping empty paragraph' ) )
		return
	end

	-- replace html codes &code;
	text = string.gsub ( text, '&(#?%w+);', html_text_code_replace )

	-- remove leading and trailing whitespaces
	text = string.match ( text, '^%s*(.-)%s*$' )

	-- collapse whitespaces
	text = string.gsub ( text, '%s+', ' ' )

	local t_format, t_tail = '', text 

	while t_tail and t_tail ~= '' do
		local line = ''

		while t_tail do

			local word = string.match ( t_tail, '^%S+' )

			if not word then
				break
			elseif #line + #word + 1 <= data.opt.textwidth then
				if #line == 0 then
					line = word
				else
					line = line .. ' ' .. word
				end

				t_tail = string.match ( t_tail, '^%S+%s+(.*)' )
			else
				break
			end
		end

		t_format = t_format .. line .. '\n'
	end

	if transform then
		t_format = transform ( t_format )
	end

	t_add ( data, t_format )

end  -----  end of function p_wrapup  -----

--  }}}2
------------------------------------------------------------------------

------------------------------------------------------------------------
--  handle_single -- handle tags <tag> without a matching </tag>   {{{1
------------------------------------------------------------------------

------------------------------------------------------------------------
--  handle_single.p   {{{2
------------------------------------------------------------------------

function handle_single.p ( data, opt )

	local class

	if opt then
		class = string.lower ( string.match ( opt, '[cC][lL][aA][sS][sS]="([^"]+)"' ) )
	end

	p_wrapup ( data )

	if class == 'footer' then
		-- since Lua 5.3 we need to insert the rule before the footer by hand
		t_add ( data, '', { newline = true, } )
		t_add ( data, templates.rule_single, { newline = true, } )
	end

	data.p_collect = true
	data.p_accu = {
		in_class = class,
		text = '',
	}

end  -----  end of function handle_single.p  -----

------------------------------------------------------------------------
--  handle_single.p_end   {{{2
------------------------------------------------------------------------

function handle_single.p_end ( data, opt )

	if data.p_accu.in_class == 'footer' then
		-- since Lua 5.3 we need to insert a line-break by hand
		p_wrapup ( data, function ( text )
			return string.gsub ( text, '(Last update:)%s', '%1\n', 1 )
		end )
	else
		p_wrapup ( data )
	end

end  -----  end of function handle_single.p_end  -----

------------------------------------------------------------------------
--  handle_single.hr   {{{2
------------------------------------------------------------------------

function handle_single.hr ( data, opt )

	assert ( opt == nil )

	p_wrapup ( data )

	t_add ( data, '', { newline = true, } )
	t_add ( data, templates.rule_single, { newline = true, } )
end  -----  end of function handle_single.hr  -----

function handle_single.img ( data, opt )

	local _, src = string.match ( opt, 'src=(["\'])([^"\']+)%1' )

	print ( string.format ( '--- skipping image "%s"', src ) )

end  -----  end of function handle_single.img  -----

--  }}}2
------------------------------------------------------------------------

------------------------------------------------------------------------
--  handle_double -- handle matching tags <tag> ... </tag>   {{{1
------------------------------------------------------------------------

------------------------------------------------------------------------
--  handle_double.head   {{{2
------------------------------------------------------------------------

function handle_double.head ( data, opt, text )
	-- noop
end  -----  end of function handle_double.head  -----

------------------------------------------------------------------------
--  handle_double.h1   {{{2
------------------------------------------------------------------------

function handle_double.h1 ( data, opt, text )

	assert ( opt == nil )

	p_wrapup ( data )

	local text_data = parse_html ( text )

	local text_cc = t_assemble ( text_data, ' ' )

	if string.match ( text_cc, 'Lua %d+%.%d+ Reference Manual' ) then
		print ( string.format ( '--- found special header "%s"', text_cc ) )

		t_add ( data, text_data.text, { newline = true, } )
	elseif string.match ( text_cc, '%d+ %- [%w ]+' )
			or string.match ( text_cc, '%d+ &ndash; [%w ]+' ) then

		local chp, name = string.match ( text_cc, '(%d+) %S+ ([%w ]+)' )

		local t_sec  = string.format ( templates.toc_sec_1, chp, name )
		local t_link = string.format ( templates.link_1, chp, name )
		local t_line = string.format ( templates.toc_1, t_sec, name, t_link )

		local h_left = string.format ( templates.header_1, chp, name )
		local h_rght = string.format ( templates.anchor_1, chp, name )

		local h_line = t_leftrightalign ( data, h_left, h_rght )

		table.insert ( data.toc, t_line )

		t_add ( data, '', { newline = true, } )
		t_add ( data, templates.rule_double )
		t_add ( data, h_line )
		t_add ( data, templates.rule_double )
		t_set_anchor ( data )
		t_add ( data, '', { newline = true, } )
	else
		print ( string.format ( '!!! skip UNKNOWN header(1) "%s"', text_cc ) )
	end

end  -----  end of function handle_double.h1  -----

------------------------------------------------------------------------
--  handle_double.h2   {{{2
------------------------------------------------------------------------

function handle_double.h2 ( data, opt, text )

	assert ( opt == nil )

	p_wrapup ( data )

	local text_data = parse_html ( text )

	local text_cc = t_assemble ( text_data, ' ' )

	if string.match ( text_cc, '%d+.%d+ %- [%w ]+' )
			or string.match ( text_cc, '%d+.%d+ &ndash; [%w ]+' ) then

		local chp, sec, name = string.match ( text_cc, '(%d+).(%d+) %S+ ([%w ]+)' )

		local t_sec  = string.format ( templates.toc_sec_2, chp, sec, name )
		local t_link = string.format ( templates.link_2, chp, sec, name )
		local t_line = string.format ( templates.toc_2, t_sec, name, t_link )

		local h_left = string.format ( templates.header_2, chp, sec, name )
		local h_rght = string.format ( templates.anchor_2, chp, sec, name )

		local h_line = t_leftrightalign ( data, h_left, h_rght )

		table.insert ( data.toc, t_line )

		t_add ( data, '', { newline = true, } )
		t_add ( data, templates.rule_single )
		t_add ( data, h_line )
		t_add ( data, templates.rule_single )
		t_set_anchor ( data )
		t_add ( data, '', { newline = true, } )
	else
		print ( string.format ( '!!! skip UNKNOWN header(2) "%s"', text_cc ) )
	end

end  -----  end of function handle_double.h2  -----

------------------------------------------------------------------------
--  handle_double.h3   {{{2
------------------------------------------------------------------------

function handle_double.h3 ( data, opt, text )

	assert ( opt == nil )

	p_wrapup ( data )

	local text_data = parse_html ( text )

	local text_cc = t_assemble ( text_data, ' ' )

	if string.match ( text_cc, '%d+.%d+.%d+ %- [%w ]+' )
			or string.match ( text_cc, '%d+.%d+.%d+ &ndash; [%w ]+' ) then

		-- subsection header

		local chp, sec, ssec, name = string.match ( text_cc, '(%d+).(%d+).(%d+) %S+ ([%w ]+)' )

		local t_sec  = string.format ( templates.toc_sec_3, chp, sec, ssec, name )
		local t_link = string.format ( templates.link_3, chp, sec, ssec, name )
		local t_line = string.format ( templates.toc_3, t_sec, name, t_link )

		local h_left = string.format ( templates.header_3, chp, sec, ssec, name )
		local h_rght = string.format ( templates.anchor_3, chp, sec, ssec, name )

		local h_line = t_leftrightalign ( data, h_left, h_rght )

		table.insert ( data.toc, t_line )

		t_add ( data, '', { newline = true, } )
		t_add ( data, templates.rule_single )
		t_add ( data, h_line )
		t_add ( data, templates.rule_single )
		t_set_anchor ( data )
		t_add ( data, '', { newline = true, } )
	elseif text_data[TOP_ANCHOR] and string.match ( text_data[TOP_ANCHOR], 'pdf%-[_%a][_.:%w]*' ) then

		-- predefined function

		local f_name = string.match ( text_data[TOP_ANCHOR], 'pdf%-([_%a][_.:%w]*)' )

		local h_rght = string.format ( templates.anchor_pdf, f_name )

		-- replace html codes &code;
		text_cc = string.gsub ( text_cc, '&(#?%w+);', html_text_code_replace )

		t_set_anchor ( data )
		t_add ( data, h_rght, { rightalign = true, } )
		t_add ( data, text_cc..' ~', { newline = true, } )

	elseif text_data[TOP_ANCHOR] and string.match ( text_data[TOP_ANCHOR], 'luaL?_[%w_]+' ) then

		-- C-function

		local f_name = string.match ( text_data[TOP_ANCHOR], '(luaL?_[%w_]+)' )

		local h_rght = string.format ( templates.anchor_c_api, f_name )

		-- replace html codes &code;
		text_cc = string.gsub ( text_cc, '&(#?%w+);', html_text_code_replace )

		t_set_anchor ( data )
		t_add ( data, h_rght, { rightalign = true, } )
		t_add ( data, text_cc..' ~' )

	else
		print ( string.format ( '!!! skip UNKNOWN header(3) "%s"', text_cc ) )
	end

	handle_single.p ( data, nil )

end  -----  end of function handle_double.h3  -----

------------------------------------------------------------------------
--  handle_double.h4   {{{2
------------------------------------------------------------------------

function handle_double.h4 ( data, opt, text )

	assert ( opt == nil )

	p_wrapup ( data )

	local text_data = parse_html ( text )

	local text_cc = t_assemble ( text_data, ' ' )

	t_add ( data, text_cc )

	handle_single.p ( data, nil )

end  -----  end of function handle_double.h4  -----

------------------------------------------------------------------------
--  handle_double.small   {{{2
------------------------------------------------------------------------

function handle_double.small ( data, opt, text, space )

	--assert ( opt == nil )

	local class

	if opt then
		class = string.match ( opt, 'CLASS="([^"]+)"' )
	end

	if data.p_collect then

		local text_data = parse_html ( text, { in_paragraph = true, } )

		local text_cc = t_assemble ( text_data, ' ' )

		p_add ( data, text_cc..space )

	else
		if class == 'footer' then
			local text_data = parse_html ( text )

			local text = t_assemble ( text_data, ' ' )

			t_add ( data, text )
		else
			error ( '<small> outside a paragraph with unknown class' )
		end
	end

end  -----  end of function handle_double.small  -----

------------------------------------------------------------------------
--  handle_double.b   {{{2
------------------------------------------------------------------------

function handle_double.b ( data, opt, text, space )

	assert ( opt == nil )

	if data.p_collect then
		local text_data = parse_html ( text, { in_paragraph = true, } )
		p_add ( data, t_assemble ( text_data, ' ' )..space )
	else
		error ( '<b> outside a paragraph' )
	end

end  -----  end of function handle_double.b  -----

------------------------------------------------------------------------
--  handle_double.em   {{{2
------------------------------------------------------------------------

function handle_double.em ( data, opt, text, space )

	assert ( opt == nil )

	-- replace html codes &code; and remove tags
	text = string.gsub ( text, '&(#?%w+);', html_text_code_replace )
	text = string.gsub ( text, '</?%w+>', '' )

	if data.p_collect then
		p_add ( data, text..space )
	else
		error ( '<em> outside a paragraph' )
	end

end  -----  end of function handle_double.em  -----

------------------------------------------------------------------------
--  handle_double.code   {{{2
------------------------------------------------------------------------

function handle_double.code ( data, opt, text, space )

	assert ( opt == nil )

	-- replace html codes &code; and remove tags
	text = string.gsub ( text, '&(#?%w+);', html_text_code_replace )
	text = string.gsub ( text, '</?%w+>', '' )

	if data.p_collect then
		p_add ( data, text..space )
	else
		t_add ( data, text )
	end

end  -----  end of function handle_double.code  -----

------------------------------------------------------------------------
--  handle_double.span   {{{2
------------------------------------------------------------------------

function handle_double.span ( data, opt, text, space )

	assert ( opt ~= nil )

	local class = string.match ( opt, 'class="([^"]+)"' )

	if data.p_collect then
		if class == 'apii' then
			local text_data = parse_html ( text, { in_paragraph = true, } )

			local text = text_data.text[1]

			text = string.gsub ( text, '%(', '( ' )
			text = string.gsub ( text, '%)', ' )' )
			text = string.gsub ( text, '|', ' | ' )

			p_wrapup ( data )
			t_add ( data, text, { rightalign = true, } )
			handle_single.p ( data, nil )
		else
			error ( '<span> inside a paragraph with unknown class' )
		end
	else
		error ( '<span> outside a paragraph' )
	end

end  -----  end of function handle_double.span  -----

------------------------------------------------------------------------
--  handle_double.pre   {{{2
------------------------------------------------------------------------

function handle_double.pre ( data, opt, text, space )

	assert ( opt == nil )

	if string.match ( text, '^%s*\n' ) then
		text = string.match ( text, '^%s*\n(.-)%s*$' )
	elseif string.match ( text, '^%S' ) then
		text = string.match ( text, '^(.-)%s*$' )
		text = '    '..string.gsub ( text, '\n', '\n    ' )
	end

	-- replace html codes &code; and remove tags
	text = string.gsub ( text, '&(#?%w+);', html_text_code_replace )
	text = string.gsub ( text, '</?%w+>', '' )

	-- TODO: handle tags in <pre>

	if data.p_collect then
		p_wrapup ( data )
		t_add ( data, '>\n' .. text .. '\n<' )
		handle_single.p ( data, nil )
	else
		t_add ( data, '>\n' .. text .. '\n<' )
	end

end  -----  end of function handle_double.pre  -----

------------------------------------------------------------------------
--  handle_double.a   {{{2
------------------------------------------------------------------------

function handle_double.a ( data, opt, text, space )

	if data.p_collect then

		local _, name = string.match ( opt, 'name=(["\'])([^"\']+)%1' )
		local _, href = string.match ( opt, '[hH][rR][eE][fF]=(["\'])([^"\']+)%1' )

		if href and string.match ( href, 'www%.lua%.org/license%.html' ) and string.match ( text, 'Lua license' ) then
			-- link to the licence
			print ( string.format ( '--- found special link "%s"', text ) )
			p_add ( data, string.format ( "%s (see %s)", text, href ) )
		elseif href and string.match ( href, 'contents%.html#contents' ) and string.match ( text, 'contents' ) then
			-- link to the contents (table of contents)
			print ( string.format ( '--- found special link "%s"', text ) )
			p_add ( data, string.format ( "%s |%s-contents|", text, link_main_component )..space )
		elseif href and string.match ( href, 'contents%.html#index' ) and string.match ( text, 'index' ) then
			-- link to the contents (function index)
			print ( string.format ( '--- found special link "%s"', text ) )
			p_add ( data, string.format ( "%s |TODO-link|", text )..space )
		elseif href and string.match ( href, 'http://www%.lua%.org/manual/' ) and string.match ( text, 'other versions' ) then
			-- link to other versions (we replace it with our own links)
			print ( string.format ( '--- found special link "%s"', text ) )
			p_add ( data, string.format ( "%s %s", text, lua_all_version_links )..space )
		elseif href and string.match ( href, '#%d+%.%d+%.%d+' ) then
			-- link to a subsection
			print ( string.format ( '--- found subsection link "%s"', href ) )

			local chp, sec, ssec = string.match ( href, '#(%d+)%.(%d+)%.(%d+)' )
			p_add ( data, string.format ( templates.link_3, chp, sec, ssec )..space )
		elseif href and string.match ( href, '#%d+%.%d+' ) then
			-- link to a section
			print ( string.format ( '--- found section link "%s"', href ) )

			local chp, sec = string.match ( href, '#(%d+)%.(%d+)' )
			p_add ( data, string.format ( templates.link_2, chp, sec )..space )
		elseif href and string.match ( href, '#%d+' ) then
			-- link to a chapter
			print ( string.format ( '--- found chapter link "%s"', href ) )

			local chp = string.match ( href, '#(%d+)' )
			p_add ( data, string.format ( templates.link_1, chp )..space )
		elseif href and string.match ( href, '#pdf%-[_%l][_.:%w]*' ) then
			-- link to a predefined function
			print ( string.format ( '--- found pdf link "%s"', href ) )

			local f_name = string.match ( href, '#pdf%-([_%a][_.:%w]*)' )
			p_add ( data, string.format ( templates.link_pdf, f_name )..space )
		elseif href and string.match ( href, '#luaL?_[%w_]+' ) then
			-- link to a C-function
			print ( string.format ( '--- found C-API link "%s"', href ) )

			local f_name = string.match ( href, '#(luaL?_[%w_]+)' )
			p_add ( data, string.format ( templates.link_c_api, f_name )..space )
		elseif href and string.match ( href, '#pdf%-LUAL?_[%w_]+' ) then
			-- link to C-macro

			local f_name = string.match ( href, '#pdf%-(LUAL?_[%w_]+)' )
			p_add ( data, string.format ( '%s ('..templates.link_c_api..')', f_name, f_name )..space )
		elseif name and string.match ( name, 'pdf%-io%.std%l+' ) then
			-- library symbol anchor

			local f_name = string.match ( name, 'pdf%-(io%.std%l+)' )
			t_add_anchor ( string.format ( templates.anchor_pdf, f_name ) )
			p_add ( data, f_name..space )
		elseif name and string.match ( name, 'lua_[%w_]+' ) then
			-- C-function (lua_...) anchor

			local f_name = string.match ( name, '(lua_[%w_]+)' )
			t_add_anchor ( string.format ( templates.anchor_c_api, f_name ) )
			p_add ( data, f_name..space )
		elseif name and string.match ( name, 'pdf%-luaopen_[%w_]+' ) then
			-- C-function (luaopen_...) anchor

			local f_name = string.match ( name, 'pdf%-(luaopen_[%w_]+)' )
			t_add_anchor ( string.format ( templates.anchor_c_api, f_name ) )
			p_add ( data, f_name..space )
		elseif name and string.match ( name, 'pdf%-LUAL?_[%w_]+' ) then
			-- C-macro anchor

			local f_name = string.match ( name, 'pdf%-(LUAL?_[%w_]+)' )
			t_add_anchor ( string.format ( templates.anchor_c_api, f_name ) )
			p_add ( data, f_name..space )
		elseif name then
			-- UNKNOWN
			print ( string.format ( '!!! found UNKNOWN anchor "%s" in paragraph ("%s")', name, text ) )
			local text_data = parse_html ( text, { in_paragraph = true, } )
			p_add ( data, t_assemble ( text_data, ' ' )..space )
		elseif href then
			-- UNKNOWN
			print ( string.format ( '!!! found UNKNOWN link "%s" in paragraph ("%s")', href, text ) )
			local text_data = parse_html ( text, { in_paragraph = true, } )
			p_add ( data, t_assemble ( text_data, ' ' )..space )
		end

	else
		local _, name = string.match ( opt, 'name=(["\'])([^"\']+)%1' )
		local _, href = string.match ( opt, 'href=(["\'])([^"\']+)%1' )

		if name and string.match ( name, '^[%d.]+$' ) then
			-- section anchor
			print ( string.format ( '--- found section anchor "%s"', name ) )
			data [ TOP_ANCHOR ] = name
		elseif name and string.match ( name, 'pdf%-[_%a][_.:%w]*' ) then
			-- predefined function anchor
			print ( string.format ( '--- found pdf anchor "%s"', name ) )
			data [ TOP_ANCHOR ] = name
		elseif name and string.match ( name, 'luaL?_[%w_]+' ) then
			-- C-function anchor
			print ( string.format ( '--- found C-API anchor "%s"', name ) )
			data [ TOP_ANCHOR ] = name
		elseif name then
			-- UNKNOWN
			print ( string.format ( '!!! found UNKNOWN anchor "%s" outside paragraph ("%s")', name, text ) )
		elseif href then
			-- UNKNOWN
			print ( string.format ( '!!! found UNKNOWN link "%s" outside paragraph ("%s")', href, text ) )
		end

--		if name then
--			table.insert ( data.anchors, name )
--		end

		local text_data = parse_html ( text )
		t_add ( data, text_data.text )
	end

end  -----  end of function handle_double.a  -----

------------------------------------------------------------------------
--  handle_double.ul   {{{2
------------------------------------------------------------------------

function handle_double.ul ( data, opt, text, space )

	assert ( opt == nil )

	if data.p_collect then
		p_wrapup ( data )
	end

	local list_data = parse_html ( text, { textwidth = data.opt.textwidth - 2, } )

	local repl = function ( str )
		if string.match ( str, '^\n[><]$' ) then
			return str
		else
			return '\n  '
		end
	end

	for idx, l_item in ipairs ( list_data.text ) do
		t_add ( data, '- ' .. string.gsub ( l_item, '\n[><]?', repl ) )
	end

end  -----  end of function handle_double.ul  -----

------------------------------------------------------------------------
--  handle_double.li   {{{2
------------------------------------------------------------------------

function handle_double.li ( data, opt, text, space )

	assert ( opt == nil )

	if data.p_collect then
		error ( '<li> inside a paragraph' )
	end

	local text_data = parse_html ( text, { textwidth = data.opt.textwidth, in_paragraph = true, } )

	t_add ( data, t_assemble ( text_data, '\n' ) )

end  -----  end of function handle_double.li  -----

------------------------------------------------------------------------
--  handle_double.div   {{{2
------------------------------------------------------------------------

function handle_double.div ( data, opt, text, space )

	local class

	if opt then
		class = string.lower ( string.match ( opt, '[cC][lL][aA][sS][sS]="([^"]+)"' ) )
	end

	if class == 'menubar' then
		-- since 5.3.1 this holds the links: contents, index, other versions

		if data.p_collect then
			p_wrapup ( data )
		end

		t_add ( data, '', { newline = true, } )
		t_add ( data, templates.rule_single, { newline = true, } )

		local text_data = parse_html ( text, { in_paragraph = true, } )
		local text = t_assemble ( text_data, ' ' )

		text = string.gsub ( text, '\n', ' ' )

		t_add ( data, text )

		handle_single.p ( data, nil )
	else
		error ( '<div> inside a paragraph with unknown class' )
	end

end  -----  end of function handle_double.div  -----

--  }}}2
------------------------------------------------------------------------

------------------------------------------------------------------------
--  parse_html   {{{1
------------------------------------------------------------------------

------------------------------------------------------------------------
--  parse_matching_tag   {{{2
------------------------------------------------------------------------

function parse_matching_tag ( str_html, tag )
--	tag2, options, text, space, tail = string.match ( str_html, '^<(a) ([^>]+)>(.-)</[aA]>(%s*)(.*)' )
--	tag2, text, space, tail = string.match ( str_html, '^<(%w+)>(.-)</%1>(%s*)(.*)' )
--	tag2, options, text, space, tail = string.match ( str_html, '^<(%w+) ([^>]+)>(.-)</%1>(%s*)(.*)' )

	local tag_pat = tag
	
	if tag == 'a' then
		tag_pat = '[aA]'
	end

	local level = 1           -- start behind first opening tag
	local pos   = 2           -- enough of a offset not to find the first opening tag

	local options
	local tag_end = string.find ( str_html, '>', 1, true )
	local tag_compl = string.sub ( str_html, 1, tag_end )

	if string.match ( tag_compl, '<'..tag_pat..'%s' ) then
		options = string.match ( tag_compl, '<'..tag_pat..'%s+(%S.*)>' )
	end

	while level > 0 do

		local pos1, pos2, tag2 = string.find ( str_html, '(</?'..tag_pat..'[%s>])', pos )

		if not tag2 then
			print ( '"'..str_html..'"' )
		end

		if string.match ( tag2, '<'..tag_pat..'[%s>]' ) then
			level = level + 1
		elseif string.match ( tag2, '</'..tag_pat..'>' ) then
			level = level - 1
		end

		text_end = pos1 - 1          -- in case of a closing tag: end of inner text
		pos      = pos2 + 1          -- in case of a closing tag: will end up behind it
	end

	local pos_skip_white = string.find ( str_html, '%S', pos ) or pos

	local text  = string.sub ( str_html, tag_end+1, text_end )
	local space = string.sub ( str_html, pos, pos_skip_white-1 )
	local tail  = string.sub ( str_html, pos_skip_white, -1 )

	return tag, options, text, space, tail

end  -----  end of function parse_matching_tag  -----

--  }}}2
------------------------------------------------------------------------

function parse_html ( str_html, options )

	local debug = print
--	local debug = function () end

	options = options or {}

	local data = {
		toc       = {},
		text      = {},
		anchors   = {},
		p_collect = false,

		opt = {
			textwidth = options.textwidth or textwidth,
		}
	}

	-- behave as in paragraph
	if options.in_paragraph then
		handle_single.p ( data, nil )
	end

	while str_html ~= '' do
	--for i = 1, 3000 do
		if str_html == '' then
			break
		end

		--print ( '>>> '..i..' > '..string.gsub ( string.sub ( str_html, 1, 24 ), '\n', ' ' ) )

		local tag_orig = string.match ( str_html, '^<([!/]?%w+)' ), nil
		local tag      = tag_orig
		local tail     = nil
		local skip     = false
		local matching = false
		local tag2, options, text, space

		if tag then
			tag = string.lower ( tag )
		end

		if tag == '!doctype' then
			-- skip "<!DOCTYPE ...>"
			tail = string.match ( str_html, '^<[^>]+>%s*(.*)' )
			skip = true
		elseif tag == 'html' or tag == 'body' then
			-- skip "<html>", "</html>", "<body>", ...
			tail = string.match ( str_html, '^<[^>]+>%s*(.*)' )
			skip = true
		elseif tag == '/body' or tag == '/html' then
			break
		elseif tag == '/p' then
			handle_single.p_end ( data, nil )
			tail = string.match ( str_html, '^<[^>]+>%s*(.*)' )
			skip = true
		elseif tag and string.match ( tag, '^/' ) then
			-- should not encounter </...>
			debug ( '>>> '..string.gsub ( string.sub ( str_html, 1, 72 ), '\n', ' ' ) )
			error ( 'mismatched tags' )
		elseif tag and string.match ( tag, '^!' ) then
			-- should not encounter <!...> other than the above
			debug ( '>>> '..string.gsub ( string.sub ( str_html, 1, 72 ), '\n', ' ' ) )
			error ( 'unknown tags' )
		elseif handle_single [ tag ] and string.match ( str_html, '^<%w+>' ) then
			tag2, space, tail = string.match ( str_html, '^<(%w+)>(%s*)(.*)' )
		elseif handle_single [ tag ] and string.match ( str_html, '^<%w+%s' ) then
			tag2, options, space, tail = string.match ( str_html, '^<(%w+) ([^>]+)>(%s*)(.*)' )
		elseif string.match ( str_html, '^<%w+>' )
				or string.match ( str_html, '^<%w+%s' ) then
			tag2, options, text, space, tail = parse_matching_tag ( str_html, tag_orig )
			matching = tag2 ~= nil
		elseif string.match ( str_html, '^<!%-%-' ) then
			tail = string.match ( str_html, '^<[^>]+>%s*(.*)' )
			skip = true
		end

		if space then
			space = string.gsub ( space, '%s+', ' ' )
		end

		if skip then
			-- noop
		elseif tag and not tag2 then
			debug ( '>>> '..string.gsub ( string.sub ( str_html, 1, 72 ), '\n', ' ' ) )
			error ( string.format ( 'no matching tag "%s"', tag ) )
		elseif matching then
			if handle_double[tag] then
				handle_double[tag] ( data, options, text, space )
			else
				debug ( '>>> '..string.gsub ( string.sub ( str_html, 1, 72 ), '\n', ' ' ) )
				error ( string.format ( 'no rule to handle the tag "%s"', tag ) )
			end
		elseif tag then
			if handle_single[tag] then
				handle_single[tag] ( data, options, space )
			else
				debug ( '>>> '..string.gsub ( string.sub ( str_html, 1, 72 ), '\n', ' ' ) )
				error ( string.format ( 'no rule to handle the tag "%s"', tag ) )
			end
		end

		if not tail then
			text, tail = string.match ( str_html, '^([^<]+)(.*)' )

			if data.p_collect then
				p_add ( data, text )
			else
				t_add ( data, text )
			end
		end

		str_html = tail

	end

	-- wrapup current paragraph
	if data.p_collect then
		p_wrapup ( data )
	end

	return data

end  -----  end of function parse_html  -----

--  }}}1
------------------------------------------------------------------------

--print ( string.format ( '"%s" "%s" "%s" "%s"', parse_matching_tag ( '<em class="id">opening long bracket of level <em class="blah">n</em></em> ', 'em' ) ) )

-- header inserted before the generated documentation to make the format Vim compatible
header_txt = [[
*luaref%MAJOR%%MINOR%.txt*             Lua %MAJOR%.%MINOR% Reference Manual                %DATE%

Lua %MAJOR%.%MINOR%.%RELEASE% Reference Manual                                   *%LINKMAIN%* *luaref%MAJOR%%MINOR%*

by Roberto Ierusalimschy, Luiz Henrique de Figueiredo, Waldemar Celes
Copyright © %COPYRIGHT% Lua.org, PUC-Rio. Freely available under the terms of
the Lua license (see http://www.lua.org/license.html).

Formated for Vim help by
  Wolfgang Mehner <wolfgang-mehner at web.de>

==============================================================================
0.  Table of Contents                                         *%LINKMAIN%-contents*
==============================================================================

]]

-- footer inserted after the generated documentation
footer_txt = [[

Formated for Vim help:
]] .. os.date ( '%a %b %d %H:%M:%S %Z %Y' ) .. '\n' .. [[

==============================================================================
vim:tw=78:expandtab:ts=4:ft=help:norl:
]]

-- replace text in the header
local replace = {
	MAJOR     = lua_major,
	MINOR     = lua_minor,
	RELEASE   = lua_release,
	DATE      = lua_date,
	COPYRIGHT = lua_copyright,
	LINKMAIN  = link_main_component
}

header_txt = string.gsub ( header_txt, '%%(%w+)%%', replace )

-- read the html file
local str_main = ''

local fin = assert ( io.open ( html_filename, 'r' ) )

for line in fin:lines() do
	str_main = str_main .. ( line .. '\n' )
end

assert ( io.close ( fin ) )

-- parse the html file
local data = parse_html ( str_main )

-- write the output
local fout = assert ( io.open ( doc_filename, 'w' ) )

fout:write ( header_txt )

for _, txt in ipairs ( data.toc ) do
	fout:write ( txt )
	fout:write ( '\n' )
end

if ( lua_major == 5 and lua_minor >= 3 ) or lua_major >= 6 then
	-- since Lua 5.3 we need to insert the rule after the ToC by hand
	fout:write ( '\n' )
	fout:write ( templates.rule_single )
	fout:write ( '\n\n' )
end

for _, txt in ipairs ( data.text ) do
	fout:write ( txt )
	fout:write ( '\n' )
end

fout:write ( footer_txt )

assert ( io.close ( fout ) )

------------------------------------------------------------------------
--  vim: foldmethod=marker
