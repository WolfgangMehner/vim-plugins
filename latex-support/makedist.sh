#!/bin/bash
#===============================================================================
#
#          FILE:  makedist.sh
#
#         USAGE:  ./makedist.sh
#
#   DESCRIPTION:  create archive latex-support.zip
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

archive_name='latex-support'
MainTemplateFile='./templates/Templates'

filelist="
 ./autoload/mmtemplates/core.vim
 ./autoload/mmtoolbox/make.vim
 ./autoload/mmtoolbox/tools.vim
 ./doc/latexsupport.txt
 ./doc/templatesupport.txt
 ./doc/toolbox.txt
 ./doc/toolboxmake.txt
 ./latex-support/README.latexsupport
 ./latex-support/codesnippets/*
 ./latex-support/doc/ChangeLog
 ./latex-support/doc/latex-hotkeys.pdf
 ./latex-support/doc/latex-hotkeys.tex
 ./latex-support/rc/*
 ./latex-support/templates/*
 ./latex-support/wordlists/*
 ./ftplugin/make.vim
 ./ftplugin/tex.vim
 ./plugin/latex-support.vim
 ./syntax/template.vim
"
#-------------------------------------------------------------------------------
#   remove personalization from the main template file
#-------------------------------------------------------------------------------
if [ -f "$MainTemplateFile" ] ; then
	cp	"${MainTemplateFile}" "${MainTemplateFile}".save
	sed --in-place "s/^\(\s*SetMacro.*'AUTHOR'\s*,\s*'\)\([^']*\)\(.*\)/\1YOUR NAME\3/" "$MainTemplateFile"
	sed --in-place "s/^\(\s*SetMacro.*'\(AUTHORREF\|COMPANY\|COPYRIGHT\|EMAIL\|LICENSE\|ORGANIZATION\)'\s*,\s*'\)\([^']*\)\(.*\)/\1\4/" "$MainTemplateFile"
	echo 
	grep "[^|]\(AUTHOR\|AUTHORREF\|EMAIL\|ORGANIZATION\)\>" "${MainTemplateFile}"
	echo 
else
  echo -e "File '${MainTemplateFile}' not found!\n"
	exit 1
fi

#-------------------------------------------------------------------------------
#   build archive, remove old one, restore personalized version
#-------------------------------------------------------------------------------
pushd .
cd ..

rm --force "${archive_name}.zip"

zip -r "${archive_name}" ${filelist}

popd

mv	"${MainTemplateFile}".save "${MainTemplateFile}"

