------------------------------------------------------------------------
--         Name:  load_in_env
--      Purpose:  Load a file in an environment and run it.
--  Description:  Load the file in the provided environment and run the
--                resulting chunk. The success is indicated by two return
--                arguments, thus you can write:
--
--                    assert ( load_in_env ( filename, env ) )
--
--   Parameters:  filename - name of the file (string)
--                loading_env - environment to use (table)
--      Returns:  success - true, if loading was successful (boolean)
--                message - error message, if unsuccessful (string)
------------------------------------------------------------------------

function load_in_env ( filename, loading_env )

	if not filename then
		return false, 'No filename given.'
	end

	-- load and check
	local chunk, msg = loadfile ( filename, 'bt', loading_env )

	if not chunk then
		return false, 'Could not read the data "'..filename..'":\n'..msg
	end

	-- run in loading_env
	local success, msg = pcall ( chunk )

	if not success then
		return false, 'Could not read the data "'..filename..'":\n'..msg
	end

	return true

end  -----  end of function load_in_env  -----
