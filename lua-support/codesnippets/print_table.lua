function print_table ( t, prefix, done )
	prefix = prefix or ''
	done   = done   or { [t] = true }
	for key, val in pairs ( t ) do
		if type ( val ) == 'table' then
			if not done[val] then
				done[val] = true
				print ( prefix..tostring( key ), tostring( val )..': ...' )
				print_table ( val, prefix..'\t', done )
			else
				print ( prefix..tostring( key ), tostring( val )..': -already printed-' )
			end
		else
			print ( prefix..tostring( key ), val )
		end
	end
end  -----  end of function print_table  -----
