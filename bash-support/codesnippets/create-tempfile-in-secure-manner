
TMPDIR=${TMPDIR:-/tmp}                          # defaults to /tmp if unset 

#-------------------------------------------------------------------------------
# Creates a particular temporary directory inside $TMPDIR.
# mkdir(1) is an atomic check-and-create operation.
#-------------------------------------------------------------------------------
TEMPORARY_DIR=$(mktemp -d "$TMPDIR/XXXXXXXXXXXXXXXXXXXXXXXXXXXXX") || \
    { echo "ERROR creating a temporary file"; exit 1; }

#-------------------------------------------------------------------------------
# When the program exits, it tries to remove the temporary folder.
# This code is executed even if the process receives a signal 1,2,3 or 15.
#-------------------------------------------------------------------------------
trap 'rm --recursive --force "$TEMPORARY_DIR"' 0

touch $TEMPORARY_DIR/tempfile                   # new tempfile inside folder

