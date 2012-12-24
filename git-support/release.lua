--
--------------------------------------------------------------------------------
--         FILE:  release.lua
--        USAGE:  ./release.lua
--  DESCRIPTION:  
--      OPTIONS:  ---
-- REQUIREMENTS:  ---
--         BUGS:  ---
--        NOTES:  ---
--       AUTHOR:  Wolfgang Mehner, <wolfgang-mehner@web.de>
--      COMPANY:  
--      VERSION:  1.0
--      CREATED:  24.12.12
--     REVISION:  ---
--------------------------------------------------------------------------------
--

function escape_shell ( text )
	return string.gsub ( text, '[%(%);&=\' ]', function ( m ) return '\\' .. m end )
end  ----------  end of function escape_shell  ----------

local outfile = 'git-support.zip'

local filelist = {
	'doc/gitsupport.txt',
	'plugin/git-support.vim',
	'git-support/doc/',
	'git-support/README.gitsupport',
	'syntax/gitsbranch.vim',
	'syntax/gitslog.vim',
	'syntax/gitsstatus.vim',
}

outfile = escape_shell ( outfile )
for idx, val in ipairs ( filelist ) do
	filelist[ idx ] = escape_shell ( val )
end

local cmd = 'zip -r '..outfile..' '..table.concat ( filelist, ' ' )

print ( '\n=== executing: '..outfile..' ===\n' )

local success, res_reason, res_status = os.execute ( cmd )

if success then
	print ( '\n=== successful ===\n' )
else
	print ( '\n=== failed: '..res_reason..' '..res_status..' ===\n' )
end

