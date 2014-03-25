filename = 'TODO';

fid = fopen ( filename, 'r' );

if fid ~= -1
    C = textscan ( fid, '%f %f %f', 'commentstyle', '#', 'delimiter', '', 'collectoutput', false );

    fclose ( fid );
else
    error ( 'Could not open the file "%s" for reading.', filename );
end

