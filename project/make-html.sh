#!/bin/bash - 
#===============================================================================
#
#          FILE:  make-html.sh
# 
#         USAGE:  ./make-html.sh 
# 
#   DESCRIPTION:  performs these steps:
#                 - switch to the ./doc directory
#                 - do the helptags there
#                 - run "vim2html.pl"
# 
#       OPTIONS:  ---
#  REQUIREMENTS:  ---
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR:  Dr.-Ing. Fritz Mehner (fgm), mehner@web.de
#       VERSION:  1.0
#       CREATED:  20.03.2009
#      REVISION:  15.11.2014
#===============================================================================

set -o nounset                              # Treat unset variables as an error

PROJECT_BASE_DIR=$(git rev-parse --show-toplevel)

# go to doc/
cd $PROJECT_BASE_DIR/doc

# redo the helptags
echo -e "producing the helptags ..."
vim -c  ':helptags . | q'

# run vim2html on all files
if [ -r tags ]; then
	echo -e "running vim2html ..."
	$PROJECT_BASE_DIR/project/vim2html.pl tags *.txt
else
	echo -e "tag file not found, aborting"
	exit 1
fi

# move all the produced files to doc-html/
echo -e "moving results to doc-html/ ..."
mkdir -p $PROJECT_BASE_DIR/doc-html
mv *.css *.html $PROJECT_BASE_DIR/doc-html
