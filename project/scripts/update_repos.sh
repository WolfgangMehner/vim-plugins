#!/bin/bash -
#===============================================================================
#
#          FILE: update_repos.sh
#
#         USAGE: ./update_repos.sh
#
#   DESCRIPTION: Update information on standalone repos.
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Wolfgang Mehner (WM), wolfgang-mehner@web.de
#  ORGANIZATION: 
#       CREATED: 18.10.2017 22:29
#      REVISION:  ---
#===============================================================================

set -o nounset                                  # Treat unset variables as an error
shopt -s extglob

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
	echo $NAME"Support"
	cd $NAME"Support"

	if [ ${?} -ne 0 ] ; then
		echo ""
		continue
	fi

	git fetch

	echo ""
	cd ..
done

for NAME in $LIST; do
	echo $NAME"Support"
	cd $NAME"Support"

	if [ ${?} -ne 0 ] ; then
		echo ""
		continue
	fi

	SHORT_STAT=$(git diff --shortstat)
	SHA_MASTER=$(git for-each-ref --format='%(objectname)' refs/heads/master)
	SHA_ORIGIN=$(git for-each-ref --format='%(objectname)' refs/remotes/origin/master)

	if [ "$SHORT_STAT" != "" ] ; then
		echo "  requires commit: $SHORT_STAT"
	fi
	if [ $SHA_MASTER != $SHA_ORIGIN ] ; then
		SHA_BASE=$(git merge-base $SHA_MASTER $SHA_ORIGIN)

		if [ $SHA_MASTER == $SHA_BASE ] ; then
			echo "  requires merge"
		elif [ $SHA_ORIGIN == $SHA_BASE ] ; then
			echo "  requires push"
		else
			echo "  OUT OF DATE"
		fi
	fi

	COMMIT_MSG=$(git log -n1)
	SHA_ORIGINAL=${COMMIT_MSG##*commit\/}

	cd ..

	cd ../VimPlugins/

	TAG_NAME="_repos_/"${NAME,,}"-support"

	SHA_TAG=$(git for-each-ref --format='%(objectname)' refs/tags/$TAG_NAME)

	if [ "$SHA_TAG" != "$SHA_ORIGINAL" ] ; then
		if [ "$SHA_TAG" == "" ] ; then
			echo "  tag not set"
		else
			echo "  tag outdated"
		fi

		read -p "Update tag? [y/n] " ANSWER

		if [ "${ANSWER,,}" == 'y' ] ; then
			echo "  setting tag .."
			git tag -f $TAG_NAME $SHA_ORIGINAL
		fi
	fi

	echo ""
	cd ../VimRepos/
done
