#!/bin/bash
#===============================================================================
#
#          FILE:  makedist.sh
#
#         USAGE:  ./makedist.sh
#
#   DESCRIPTION:  create archive cvim.zip
#
#       OPTIONS:  ---
#  REQUIREMENTS:  ---
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR:  Dr.-Ing. Fritz Mehner (fgm), mehner.fritz@fh-swf.de
#       COMPANY:  Fachhochschule Südwestfalen, Iserlohn
#       VERSION:  2.0
#       CREATED:  04.01.2013 13:35:48 CEST
#===============================================================================

plugin='c-support'
MainTemplateFile='./templates/Templates'

filelist="
 ./${plugin}/README.csupport
 ./${plugin}/codesnippets/*
 ./${plugin}/doc/ChangeLog
 ./${plugin}/doc/c-hotkeys.pdf
 ./${plugin}/doc/c-hotkeys.tex
 ./${plugin}/rc/*
 ./${plugin}/scripts/*
 ./${plugin}/templates/*.template
 ./${plugin}/templates/Templates
 ./${plugin}/wordlists/*
 ./autoload/mmtemplates/core.vim
 ./autoload/mmtoolbox/cmake.vim
 ./autoload/mmtoolbox/doxygen.vim
 ./autoload/mmtoolbox/make.vim
 ./autoload/mmtoolbox/tools.vim
 ./doc/csupport.txt
 ./doc/templatesupport.txt
 ./doc/toolbox.txt
 ./doc/toolboxcmake.txt
 ./doc/toolboxdoxygen.txt
 ./doc/toolboxmake.txt
 ./ftplugin/c.vim
 ./ftplugin/make.vim
 ./plugin/c.vim
 ./syntax/template.vim
"
#-------------------------------------------------------------------------------
#   remove personalization from the main template file
#-------------------------------------------------------------------------------
if [ -f "$MainTemplateFile" ] ; then
	cp	"${MainTemplateFile}" "${MainTemplateFile}".save
	sed --in-place "s/^\(\s*SetMacro.*'AUTHOR'\s*,\s*'\)\([^']*\)\(.*\)/\1YOUR NAME\3/" "$MainTemplateFile"
	sed --in-place "s/^\(\s*SetMacro.*'\(AUTHORREF\|COMPANY\|COPYRIGHT\|EMAIL\|LICENSE\|ORGANIZATION\)'\s*,\s*'\)\([^']*\)\(.*\)/\1\4/" "$MainTemplateFile"
else
  echo -e "File '${MainTemplateFile}' not found!\n"
	exit 1
fi

#-------------------------------------------------------------------------------
#   build archive, remove old one, restore personalized version
#-------------------------------------------------------------------------------
pushd .
cd ..

rm --force cvim.zip

zip -r cvim.zip ${filelist}

popd

mv "${MainTemplateFile}".save "${MainTemplateFile}"

