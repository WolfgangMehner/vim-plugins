#!/bin/bash
#===============================================================================
#          FILE:  wrapper.sh
#         USAGE:  ./wrapper.sh scriptname [cmd-line-args] 
#   DESCRIPTION:  Wraps the execution of a programm or script.
#                 Use with xterm: xterm -e wrapper.sh scriptname cmd-line-args
#                 This script is used by the Vim plugin bash-support.vim
#       OPTIONS:  ---
#  REQUIREMENTS:  ---
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR:  Dr.-Ing. Fritz Mehner (fgm), mehner.fritz@web.de
#       CREATED:  23.11.2004 18:04:01 CET
#      REVISION:  ---
#===============================================================================

scriptname="${1}"                               # name of the script to execute
returncode=0                                    # default return code

if [ ${#} -ge 1 ] ; then
  if [ -x "$scriptname" ] ; then                # start an executable script?
    "${@}"
  else
    $SHELL "${@}"                               # start a script which is not executable
  fi
  returncode=$?
  [ $returncode -ne 0 ] && printf "'${@}' returned ${returncode}\n"
else
  printf "\n!! ${0} : no argument(s) !!\n"
fi

read -p "... press return key ... " dummy
exit $returncode
