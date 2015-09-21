#!/bin/bash - 
#===============================================================================
#
#          FILE: checkversion.sh
# 
#         USAGE: ./checkversion.sh plugin [major version number]
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Dr. Fritz Mehner (fgm), mehner.fritz@web.de
#       CREATED: 11.08.2013 10:02
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error

#===  FUNCTION  ================================================================
#         NAME:  usage
#  DESCRIPTION:  Display usage information.
#===============================================================================
function usage ()
{
	cat <<- EOT

  Usage :  ${0##/*/} plugin [major version number]

	EOT
}    # ----------  end of function usage  ----------

[ ${#} -lt 1 ] && usage && exit 0

major=${2:-[[:digit:]]+}                         # major version number or digits
regex='version[^[:digit:]]+'$major

case $1 in
	awk)
		echo -e "-- check awk --"
		egrep -Rin "$regex" awk-support plugin/awk-support.vim  doc/awksupport.txt
		;;

	bash)
		echo -e "-- check bash --"
		egrep -Rin "$regex" bash-support plugin/bash-support.vim  doc/bashsupport.txt
		;;

	c)
		echo -e "-- check c --"
		egrep -Rin "$regex" c-support plugin/c.vim  doc/csupport.txt
		;;

	latex)
		echo -e "-- check latex --"
		egrep -Rin "$regex" latex-support plugin/latex.vim  doc/latexsupport.txt
		;;

	perl)
		echo -e "-- check perl --"
		egrep -Rin "$regex" perl-support plugin/perl-support.vim  doc/perlsupport.txt 
		;;

	vim)
		echo -e "-- check vim --"
		egrep -Rin "$regex" vim-support plugin/vim-support.vim  doc/vimsupport.txt 
		;;

	*)
		echo -e "** no plugin with name '$1' **"
		;;

esac    # --- end of case ---

