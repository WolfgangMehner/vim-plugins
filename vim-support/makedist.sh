#!/bin/bash
#===============================================================================
#
#          FILE:  makedist.sh
#
#         USAGE:  ./makedist.sh
#
#   DESCRIPTION:  create archive vim-support.zip
#
#       OPTIONS:  ---
#  REQUIREMENTS:  ---
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR:  Dr.-Ing. Fritz Mehner (fgm), mehner.fritz@fh-swf.de
#       COMPANY:  Fachhochschule Südwestfalen, Iserlohn
#       VERSION:  2.0
#       CREATED:  11.08.2013 19:22:37 CEST
#===============================================================================

plugin='vim-support'
MainTemplateFile='./templates/Templates'

filelist="
 ./autoload/mmtemplates/core.vim
 ./doc/vimsupport.txt
 ./doc/templatesupport.txt
 ./${plugin}/codesnippets/*
 ./${plugin}/doc/vim-hotkeys.pdf
 ./${plugin}/doc/vim-hotkeys.tex
 ./${plugin}/doc/ChangeLog
 ./${plugin}/rc/*
 ./${plugin}/README.vimsupport
 ./${plugin}/scripts/*
 ./${plugin}/templates/*.templates
 ./${plugin}/templates/Templates
 ./plugin/vim-support.vim
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

rm --force "${plugin}.zip"

zip -r "${plugin}" ${filelist}

popd

mv "${MainTemplateFile}".save "${MainTemplateFile}"

