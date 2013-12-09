
TMPDIR=${TMPDIR:-/tmp}                          # defaults to /tmp if unset 

#-------------------------------------------------------------------------------
# Creates a particular temporary directory inside $TMPDIR.
#-------------------------------------------------------------------------------
TEMPORARY_DIR=$(mktemp -d "$TMPDIR/XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX") || \
    { echo "ERROR creating a temporary file"; exit 1; }

#-------------------------------------------------------------------------------
# When the program exits, it tries to remove the temporary folder.
# This code is executed even if the process receives a signal 1,2,3 or 15.
#-------------------------------------------------------------------------------
trap '[ "$TEMPORARY_DIR" ] && rm --recursive --force "$TEMPORARY_DIR"' 0

touch $TEMPORARY_DIR/tempfile                   # new tempfile inside folder

