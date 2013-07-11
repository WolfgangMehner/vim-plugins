
outfilename=""                      # output filename

exec 4>"$outfilename"
if [ $? -ne 0 ] ; then
  echo -e "Could not link file descriptor with file '$outfilename'\n"
  exit 1
fi

echo -e "text"  >&4

exec  4>&-                                      # close file descriptor

