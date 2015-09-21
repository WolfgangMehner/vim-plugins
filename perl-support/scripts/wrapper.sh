#!/bin/bash
#===============================================================================
#          FILE:  wrapper.sh
#         USAGE:  ./wrapper.sh scriptname [cmd-line-args] 
#   DESCRIPTION:  Wraps the execution of a programm or script.
#                 Use with xterm: xterm -e wrapper.sh scriptname cmd-line-args
#                 This script is used by the Vim plugin perl-support.vim
#       OPTIONS:  ---
#  REQUIREMENTS:  ---
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR:  Dr.-Ing. Fritz Mehner (fgm), mehner.fritz@web.de
#       CREATED:  23.11.2004 18:04:01 CET
#      REVISION:  12.01.2014
#===============================================================================

returncode=0                                    # default return code

if [ ${#} -ge 1 ] ; then
		"${@}"
		returncode=$?
		[ $returncode -ne 0 ] && printf "'${@}' returned ${returncode}\n"
else
	printf "\n!! ${0} : no argument(s) !!\n"
fi

read -p "... press return key ... " dummy
exit $returncode
