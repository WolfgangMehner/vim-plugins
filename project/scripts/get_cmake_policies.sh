#!/bin/bash -
#===============================================================================
#
#          FILE: get_cmake_policies.sh
#
#         USAGE: ./get_cmake_policies.sh
#
#   DESCRIPTION: 
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Wolfgang Mehner (WM), wolfgang-mehner@web.de
#  ORGANIZATION: 
#       CREATED: 16.10.2017
#      REVISION:  ---
#===============================================================================

set -o nounset                                  # Treat unset variables as an hrror
shopt -s extglob

CMAKE_VERSION="3.10"
POLICY_MIN=0
POLICY_MAX=71

DOC_URL="https://cmake.org/cmake/help/v$CMAKE_VERSION/policy/CMP%04d.html"

for (( POLICY=POLICY_MIN; POLICY<=POLICY_MAX; POLICY+=1 )); do
	#printf "processing policy CMP%04d\n" $POLICY

	printf -v URL $DOC_URL $POLICY

	TEXT=$( wget -O - $URL 2> /dev/null )

	# <span id="policy:CMP0027"></span><h1>CMP0027<a class="headerlink" href="#cmp0027" title="Permalink to this headline">¶</a></h1>
	# <p>Conditionally linked imported targets with missing include directories.</p>
	#
	# <span id="policy:CMP0030"></span><h1>CMP0030<a class="headerlink" href="#cmp0030" title="Permalink to this headline">¶</a></h1>
	# <p>The <span class="target" id="index-0-command:use_mangled_mesa"></span><a class="reference internal" href="../command/use_mangled_mesa.html#command:use_mangled_mesa" title="use_mangled_mesa"><code class="xref cmake cmake-command docutils literal"><span class="pre">use_mangled_mesa()</span></code></a> command should not be called.</p>

	HEAD=${TEXT#*<span id=?policy:CMP[[:digit:]][[:digit:]][[:digit:]][[:digit:]]?><\/span><h1>}
	HEAD=${HEAD%%<\/p>*}

	P_NAME=${HEAD%%<a*}
	P_DESC=${HEAD##*<p>}

	P_DESC=$( echo $P_DESC | tr -d \\n )

	P_VERSION=${TEXT#*This policy was introduced in CMake version }
	P_VERSION=${P_VERSION%%.[^[:digit:]]*}

	#echo $HEAD
	#echo $P_NAME
	#echo $P_DESC
	#echo $P_VERSION

	printf "\\ [ '%s', '%s', '%s' ],\n" "$P_NAME" "$P_DESC" "$P_VERSION"
done

