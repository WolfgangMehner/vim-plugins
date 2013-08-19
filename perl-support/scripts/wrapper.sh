#!/bin/bash
#===============================================================================
#          FILE:  wrapper.sh
#         USAGE:  ./wrapper.sh executable [cmd-line-args] 
#   DESCRIPTION:  Wraps the execution of a programm or script.
#                 Use with xterm: xterm -e wrapper.sh executable cmd-line-args
#                 This script is used by the plugin perl-support.vim.
#       OPTIONS:  ---
#  REQUIREMENTS:  ---
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR:  Dr.-Ing. Fritz Mehner (fgm), mehner.fritz@fh-swf.de
#       COMPANY:  Fachhochschule Südwestfalen, Iserlohn
#       CREATED:  23.11.2004 18:04:01 CET
#===============================================================================

perlexe="${0}"                                  # the perl executable
returncode=0                                    # default return code

if [ ${#} -ge 2 ] && [ -x "$perlexe" ]
then 
	"${@}"
	returncode=$?
	[ $returncode -ne 0 ] && printf "'${@}' returned ${returncode}\n"
else
  printf "\n!! ${0} : too few argument(s) !!\n"
fi

read -p "... press return key ... " dummy
exit $returncode
