#!/bin/bash
#===============================================================================
#
#          FILE:  makedist.sh
#
#         USAGE:  ./makedist.sh
#
#   DESCRIPTION:  create archive perl-support.zip
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

plugin='perl-support'
MainTemplateFile='./templates/Templates'

filelist="
 ./${plugin}/README.perlsupport
 ./${plugin}/codesnippets/*
 ./${plugin}/doc/ChangeLog
 ./${plugin}/doc/perl-hot-keys.pdf
 ./${plugin}/doc/perl-hot-keys.tex
 ./${plugin}/doc/pmdesc3.text
 ./${plugin}/modules/*
 ./${plugin}/rc/*
 ./${plugin}/scripts/*
 ./${plugin}/templates/*
 ./${plugin}/wordlists/*
 ./autoload/mmtemplates/core.vim
 ./autoload/mmtoolbox/make.vim
 ./autoload/mmtoolbox/tools.vim
 ./autoload/perlsupportprofiling.vim
 ./autoload/perlsupportregex.vim
 ./doc/perlsupport.txt
 ./doc/templatesupport.txt
 ./doc/toolbox.txt
 ./doc/toolboxmake.txt
 ./ftplugin/make.vim
 ./ftplugin/perl.vim
 ./ftplugin/pod.vim
 ./ftplugin/qf.vim
 ./plugin/perl-support.vim
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

zip -r "${plugin}" ${filelist} -x *.save

popd

mv "${MainTemplateFile}".save "${MainTemplateFile}"

