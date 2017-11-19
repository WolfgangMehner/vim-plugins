#!/bin/bash - 
#===============================================================================
#
#          FILE: check_repos.sh
#
#         USAGE: ./check_repos.sh
#
#   DESCRIPTION: Short status of standalone repos.
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Wolfgang Mehner (WM), wolfgang-mehner@web.de
#  ORGANIZATION: 
#       CREATED: 18.10.2017 22:30
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error

LIST="
Awk
Bash
C
Git
Latex
Lua
Matlab
Perl
Vim
"

for NAME in $LIST; do
	cd $NAME"Support"

	if [ ${?} -ne 0 ] ; then
		continue
	fi

	printf "%-6s : %s (%s )\n" $NAME "$(git log -n1 --date=short --pretty=format:"%ad : %s")" "$(git diff --shortstat HEAD)"
	cd ..
done | sort -k 2
