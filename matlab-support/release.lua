--
--------------------------------------------------------------------------------
--         FILE:  release_matlab.lua
--        USAGE:  ./release_matlab.lua
--  DESCRIPTION:  
--      OPTIONS:  ---
-- REQUIREMENTS:  ---
--         BUGS:  ---
--        NOTES:  ---
--       AUTHOR:  Wolfgang Mehner, <wolfgang-mehner@web.de>
--      COMPANY:  
--      VERSION:  1.0
--      CREATED:  14.09.11
--     REVISION:  24.11.13
--------------------------------------------------------------------------------
--

function escape_shell ( text )
	return string.gsub ( text, '[%(%);&=\' ]', function ( m ) return '\\' .. m end )
end  ----------  end of function escape_shell  ----------

local args = { ... }

local outfile = 'matlab-support.zip'

local filelist = {
	'autoload/mmtemplates/',
	'doc/matlabsupport.txt',
	'doc/templatesupport.txt',
	'ftplugin/matlab.vim',
	'plugin/matlab-support.vim',
	'matlab-support/doc/',
	'matlab-support/rc/',
	'matlab-support/templates/',
	'matlab-support/README.matlabsupport',
}

outfile = escape_shell ( outfile )
for idx, val in ipairs ( filelist ) do
	filelist[ idx ] = escape_shell ( val )
end

local print_help = false

if #args == 0 then

	print ( '\n=== failed: mode missing ===\n' )

	print_help = true

elseif args[1] == 'check' then

	local cmd = 'grep -nH ":[[:upper:]]\\+:\\|[Tt][Oo][Dd][Oo]" '..table.concat ( filelist, ' ' )

	print ( '\n=== checking ===\n' )

	local success, res_reason, res_status = os.execute ( cmd )

	if success then
		print ( '\n=== done ===\n' )
	else
		print ( '\n=== failed: '..res_reason..' '..res_status..' ===\n' )
	end

elseif args[1] == 'zip' then

	local cmd = 'zip -r '..outfile..' '..table.concat ( filelist, ' ' )

	print ( '\n=== executing: '..outfile..' ===\n' )

	local success, res_reason, res_status = os.execute ( cmd )

	if success then
		print ( '\n=== successful ===\n' )
	else
		print ( '\n=== failed: '..res_reason..' '..res_status..' ===\n' )
	end

elseif args[1] == 'help' then

	print_help = true

else

	print ( '\n=== failed: unknown mode "'..args[1]..'" ===\n' )

	print_help = true

end

if print_help then

	print ( '' )
	print ( 'release <mode>' )
	print ( '' )
	print ( '\tcheck - check the release' )
	print ( '\tzip   - create archive' )
	print ( '\thelp  - print help' )
	print ( '' )

end
