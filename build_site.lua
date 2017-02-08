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
--                data - {+DESCRIPTION+} ({+TYPE+})
--      Returns:  {+RETURNS+}
------------------------------------------------------------------------

function read_file ( filename, data )
  
  local fin, msg = io.open ( filename, 'r' )

  if not fin then
    io.stderr:write ( '\nCould not load the data:\n'..msg..'\n\n' )
    os.exit ( 1 )
  end

	local data = data or {}
	local section, position

  for line in fin:lines() do
    
    local sec_name, sec_param = string.match ( line, '^%s*<!%-%- ::([A-Z0-9_@]+)::([A-Z_]+):: %-%->%s*$' )

		local sec_list_name, sec_list_pos = string.match ( sec_name or '', '([A-Z0-9_]+)@([A-Z0-9_]+)' )

    if sec_name then
			if sec_param == 'START' then
				if sec_list_name then
					section, position = sec_list_name, sec_list_pos
					data[section] = data[section] or {}
					data[section][position] = ''
				else
					section, position = sec_name, nil
					data[section] = ''
				end
			elseif sec_param == 'END' then
				section = nil
			else
				io.stderr:write ( '\nUnknown section parameter:\n'..sec_param..'\n\n' )
				os.exit ( 1 )
      end
    elseif section then
			if position then
				data[section][position] = data[section][position] .. line .. '\n'
			else
				data[section] = data[section] .. line .. '\n'
			end
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
--         Name:  generate_chunk   {{{1
--      Purpose:  {+PURPOSE+}
--  Description:  {+DESCRIPTION+}
--   Parameters:  chunk_data - {+DESCRIPTION+} ({+TYPE+})
--                chunk_name - {+DESCRIPTION+} ({+TYPE+})
--                fields - {+DESCRIPTION+} ({+TYPE+})
--                field_name - {+DESCRIPTION+} ({+TYPE+}, optional)
--      Returns:  {+RETURNS+}
------------------------------------------------------------------------

function generate_chunk ( chunk_data, chunk_name, fields, field_name )

	local part = chunk_data[chunk_name]
	local res  = ''

	field_name = field_name or chunk_name

	if type ( part ) == 'table' then
		assert ( part.ENTRY, '"ENTRY" missing from list' )
		local l = fields[field_name]
		if l then
			if #l > 0 and part.HEAD then
				res = res .. generate_chunk ( part, 'HEAD', l.header or l )
			end
			for idx, val in ipairs ( l ) do
				res = res .. generate_chunk ( part, 'ENTRY', val )
			end
			if #l > 0 and part.TAIL then
				res = res .. generate_chunk ( part, 'TAIL', l.header or l )
			end
		end
	else
		res = string.gsub ( part, '%%([A-Z0-9_]+)%%', fields )
	end

	return res
end  -----  end of function generate_chunk  -----

------------------------------------------------------------------------
--         Name:  generate_output   {{{1
--      Purpose:  {+PURPOSE+}
--  Description:  {+DESCRIPTION+}
--   Parameters:  config - {+DESCRIPTION+} ({+TYPE+})
--                chunk_data - {+DESCRIPTION+} ({+TYPE+})
--      Returns:  {+RETURNS+}
------------------------------------------------------------------------

function generate_output ( config, chunk_data )

	local fout, msg = io.open ( config.plugin.output, 'w' )

  if not fout then
    io.stderr:write ( '\nCan not open the output file:\n'..msg..'\n\n' )
    os.exit ( 1 )
  end

	for idx, name in ipairs ( config.plugin.template.order ) do
		
		local part
		local chunk_name, field_name = name

		if string.match ( chunk_name, '[%u%d_]+:[%u%d_]+' ) then
			chunk_name, field_name = string.match ( chunk_name, '([%u%d_]+):([%u%d_]+)' )
		end

		if not chunk_data[chunk_name] then
			io.stderr:write ( '\nCan not find the part:\n'..chunk_name..'\n\n' )
			part = ''
		else
			part = generate_chunk ( chunk_data, chunk_name, config.plugin.fields, field_name )
		end

		fout:write ( part )

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

local chunk_data = {}
read_file ( config.plugin.template.filename, chunk_data )
read_file ( config.plugin.input,             chunk_data )

chunk_data.head = [[
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<html>
	<head>
]]
chunk_data.head_body = [[
	</head>
	<body>
]]
chunk_data.body = [[
	</body>
</html>
]]

config.plugin.fields.DATE = os.date ( '%B %d %Y' )
if config.plugin.fields.TOOL_VERSION == 'AUTO' then
	config.plugin.fields.TOOL_VERSION = read_version ( config.plugin.fields.REF_HELP )
end

generate_output ( config, chunk_data )


------------------------------------------------------------------------
-- vim: foldmethod=marker
