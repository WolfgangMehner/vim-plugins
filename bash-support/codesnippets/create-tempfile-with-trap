
#-----------------------------------------------------------------------
#  cleanup temporary file in case of a keyboard interrupt (SIGINT)  
#  or a termination signal (SIGTERM)
#-----------------------------------------------------------------------
function cleanup_temp 
{
  [ -e $tmpfile ] && rm --force $tmpfile
  exit 0
} 

trap  cleanup_temp  SIGHUP SIGINT SIGPIPE SIGTERM 

tmpfile=$(mktemp) || { echo "$0: creation of temporary file failed!"; exit 1; }

# use tmpfile ...

rm --force $tmpfile

