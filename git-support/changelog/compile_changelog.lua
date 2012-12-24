--
--------------------------------------------------------------------------------
--         FILE:  compile_changelog.lua
--        USAGE:  lua compile_changelog.lua 
--  DESCRIPTION:  
--      OPTIONS:  ---
-- REQUIREMENTS:  ---
--         BUGS:  ---
--        NOTES:  ---
--       AUTHOR:  Wolfgang Mehner (WM), <wolfgang-mehner@web.de>
--      COMPANY:  
--      VERSION:  1.0
--      CREATED:  2012-10-13 14:49:54 CEST
--     REVISION:  ---
--------------------------------------------------------------------------------
--

local ifs = io.popen ( 'ls -v /usr/share/doc/git/RelNotes/*.txt' )

local filename = 'changelog.txt'

for file in ifs:lines() do
	os.execute ( 'cat '..file..' >> '..filename )
	os.execute ( 'echo "" >> '..filename )
end

os.execute ( 'gzip '..filename )

