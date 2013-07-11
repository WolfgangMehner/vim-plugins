
infilename=""                      # input filename

exec 3<"$infilename"
if [ $? -ne 0 ] ; then
  echo -e "Could not link file descriptor with file '$infilename'\n"
  exit 1
fi

while read line <&3 ; do
  echo -e "$line"
done

exec  3<&-                                      # close file descriptor

