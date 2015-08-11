#!/usr/bin/env lua
--
--------------------------------------------------------------------------------
--         File:  build_site.lua
--
--        Usage:  ./build_site.lua <site-name>
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

------------------------------------------------------------------------
--         Name:  read_file   {{{1
--      Purpose:  {+PURPOSE+}
--  Description:  {+DESCRIPTION+}
--   Parameters:  filename - {+DESCRIPTION+} ({+TYPE+})
--      Returns:  {+RETURNS+}
------------------------------------------------------------------------

function read_file ( filename )
  
  local fin, msg = io.open ( filename, 'r' )

  if not fin then
    io.stderr:write ( '\nCould not load the data:\n'..msg..'\n\n' )
    os.exit ( 1 )
  end

  local data = {}
  local section

  for line in fin:lines() do
    
    local sec_name, sec_param = string.match ( line, '^%s*<!%-%- ::([A-Z0-9_]+)::([A-Z_]+):: %-%->%s*$' )

    if sec_name then
			if sec_param == 'START' then
				section = sec_name
				data[section] = data[section] or ''
			elseif sec_param == 'END' then
				section = nil
			else
				io.stderr:write ( '\nUnknown section parameter:\n'..sec_param..'\n\n' )
				os.exit ( 1 )
      end
    elseif section then
      data[section] = data[section] .. line .. '\n'
    end
  end

  assert ( io.close ( fin ) )
  
  return data

end  -----  end of function read_file  -----

------------------------------------------------------------------------
--         Name:  read_version   {{{1
--      Purpose:  {+PURPOSE+}
--  Description:  {+DESCRIPTION+}
--   Parameters:  filename - {+DESCRIPTION+} ({+TYPE+})
--      Returns:  {+RETURNS+}
------------------------------------------------------------------------

function read_version ( filename )
  
  local fin, msg = io.open ( filename, 'r' )

  if not fin then
    io.stderr:write ( '\nCould not load the data:\n'..msg..'\n\n' )
    os.exit ( 1 )
  end

  local version = 'n/a'

  for line in fin:lines() do
    
    local m = string.match ( line, '[vV]ersion%s+(%S+)' )

		if m then
			version = m
			break
		end

  end

  assert ( io.close ( fin ) )
  
  return version

end  -----  end of function read_version  -----

------------------------------------------------------------------------
--         Name:  generate_link_table   {{{1
--      Purpose:  {+PURPOSE+}
--  Description:  {+DESCRIPTION+}
--   Parameters:  fout - {+DESCRIPTION+} ({+TYPE+})
--                config - {+DESCRIPTION+} ({+TYPE+})
--                template_data - {+DESCRIPTION+} ({+TYPE+})
--                custom_data - {+DESCRIPTION+} ({+TYPE+})
--      Returns:  {+RETURNS+}
------------------------------------------------------------------------

function generate_link_table ( fout, config, template_data, custom_data )

	function handle_part ( name )
		local part = custom_data[name] or template_data[name]

		if not part then
			io.stderr:write ( '\nCan not find the part:\n'..name..'\n\n' )
			os.exit ( 1 )
		else
			part = string.gsub ( part, '%%([A-Z0-9_]+)%%', config.plugin.fields )

			fout:write ( part )
		end
	end  -----  end of function handle_part  -----

	if #config.plugin.links_plugins > 1 then
		handle_part ( 'PAGE_HEADER_PLUGIN_HEAD' )
	end
	for idx, short_name in ipairs ( config.plugin.links_plugins ) do

		config.plugin.fields.LINK_ID   = config.plugin_links[ short_name ].id
		config.plugin.fields.LINK_NAME = config.plugin_links[ short_name ].name

		handle_part ( 'PAGE_HEADER_PLUGIN_LINK' )
	end
	
	if #config.plugin.links_others > 1 then
		handle_part ( 'PAGE_HEADER_PROJECT_HEAD' )
	end
	for idx, short_name in ipairs ( config.plugin.links_others ) do

		config.plugin.fields.PROJECT_LINK = config.project_links[ short_name ].link
		config.plugin.fields.PROJECT_NAME = config.project_links[ short_name ].name

		handle_part ( 'PAGE_HEADER_PROJECT_LINK' )
	end

end  -----  end of function generate_link_table  -----

------------------------------------------------------------------------
--         Name:  generate_output   {{{1
--      Purpose:  {+PURPOSE+}
--  Description:  {+DESCRIPTION+}
--   Parameters:  config - {+DESCRIPTION+} ({+TYPE+})
--                template_data - {+DESCRIPTION+} ({+TYPE+})
--                custom_data - {+DESCRIPTION+} ({+TYPE+})
--      Returns:  {+RETURNS+}
------------------------------------------------------------------------

function generate_output ( config, template_data, custom_data )

	local fout, msg = io.open ( config.plugin.output, 'w' )

  if not fout then
    io.stderr:write ( '\nCould not load the data:\n'..msg..'\n\n' )
    os.exit ( 1 )
  end

	for idx, name in ipairs ( config.plugin.template.order ) do
		
		local part = custom_data[name] or template_data[name]

		if name == 'PAGE_HEADER_OTHERS' then
			generate_link_table ( fout, config, template_data, custom_data )
		elseif not part then
			io.stderr:write ( '\nCan not find the part:\n'..name..'\n\n' )
			os.exit ( 1 )
		else
			part = string.gsub ( part, '%%([A-Z0-9_]+)%%', config.plugin.fields )

			fout:write ( part )
		end

	end

  assert ( io.close ( fout ) )
end  -----  end of function generate_output  -----

--  }}}1
------------------------------------------------------------------------

local args = { ... }

-- script name, version and help text
local script_name    = './build_site'
local script_version = '1.0'

local help_text_short = script_name..' [options]'

local help_text = help_text_short..'\n\n'..[[
Options:
	-p <name>         name of the plug-in

	-h, --help        print this help
	-v, --version     print version information
]]

-- check for "--help" and "--version", exit
for idx, arg in ipairs ( args ) do
  if arg == '-h' or arg == '--help' then
    print ( help_text )
    return 1
  elseif arg == '-v' or arg == '--version' then
    print ( 'version '..script_version )
    return 1
  end
end

local options = {
  plugin   = '',
}

-- go through arguments
local idx = 1

while idx <= #args do

  if args[idx] == '-p' then
    options.plugin = args[idx+1]
    idx = idx + 2
  elseif args[idx] == '-h' or args[idx] == '--help' or args[idx] == '-v' or args[idx] == '--version' then
    -- noop
    idx = idx + 1
  else
    io.stderr:write ( '\nUnknown option: '..args[idx]..'\n\n' )
    return 1
  end

end

if options.plugin == '' then
   io.stderr:write ( '\nPlug-in not given (-p <name>), aborting.\n\n' )
   return 1
end

local config = dofile ( 'config.lua' )

config.plugin = config [ options.plugin ]

if not config.plugin then
   io.stderr:write ( '\nPlug-in  "'..options.plugin..'" not known, aborting.\n\n' )
   return 1
end

local custom_data   = read_file ( config.plugin.input )
local template_data = read_file ( config.plugin.template.filename )

template_data.head = [[
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<html>
	<head>
]]
template_data.head_body = [[
	</head>
	<body>
]]
template_data.body = [[
	</body>
</html>
]]

config.plugin.fields.DATE         = os.date ( '%B %d %Y' )
config.plugin.fields.VIMORG_ID    = config.plugin_links[ options.plugin ].id
if config.plugin.fields.TOOL_VERSION == 'AUTO' then
	config.plugin.fields.TOOL_VERSION = read_version ( config.plugin.fields.REF_HELP )
end

generate_output ( config, template_data, custom_data )

